package adcontract;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/SignContractServlet")
public class SignContractServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /**
     * [A·B 연동] A(CreateContractServlet)와 동일한 데이터 폴더 규칙.
     * -Dcontract.data.dir=경로 로 지정 가능, 미지정 시 사용자 홈의 AdContractData.
     * (기존 getRealPath("/")+"../data" 는 톰캣 배포 폴더라서 A의 저장 위치와 달라
     *  검증이 항상 실패했음 → A와 동일 규칙으로 통일)
     */
    private String resolveDataDir() throws IOException {
        String dataDir = System.getProperty("contract.data.dir");
        if (dataDir == null || dataDir.isEmpty()) {
            dataDir = new java.io.File(System.getProperty("user.home"), "AdContractData").getPath();
        }
        return new java.io.File(dataDir).getCanonicalPath();
    }

    /**
     * [A·B 연동] 검증 전용 진입점(GET).
     * 전자봉투 검증만 수행하고 단계 결과(stepXxx)와 복호화된 계약서(decryptedText)를
     * reviewContract.jsp 로 forward 한다. 2차 서명은 사용자가 내용 확인·동의 후 POST 로 진행.
     * (index.jsp → 이 doGet → reviewContract.jsp → 동의 → doPost → result.jsp)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String dataDir = resolveDataDir();

        EnvelopeVerifier verifier = new EnvelopeVerifier(dataDir);
        EnvelopeVerifier.VerifyResult verifyResult = verifier.verify();

        request.setAttribute("stepAesKey", verifyResult.stepAesKey);
        request.setAttribute("stepDecrypt", verifyResult.stepDecrypt);
        request.setAttribute("stepHash", verifyResult.stepHash);
        request.setAttribute("stepBrandSig", verifyResult.stepBrandSig);
        request.setAttribute("decryptedText", verifyResult.decryptedText);
        request.setAttribute("failReason", verifyResult.failReason);

        request.getRequestDispatcher("reviewContract.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String dataDir = resolveDataDir(); // [A·B 연동] A와 동일 폴더 사용

        EnvelopeVerifier verifier = new EnvelopeVerifier(dataDir);
        EnvelopeVerifier.VerifyResult verifyResult = verifier.verify();

        request.setAttribute("stepAesKey", verifyResult.stepAesKey);
        request.setAttribute("stepDecrypt", verifyResult.stepDecrypt);
        request.setAttribute("stepHash", verifyResult.stepHash);
        request.setAttribute("stepBrandSig", verifyResult.stepBrandSig);

        if (!verifyResult.isFullyVerified()) {
            request.setAttribute("resultType", "verifyFail");
            request.setAttribute("who", "influencer");
            request.setAttribute("failReason", verifyResult.failReason);
            request.getRequestDispatcher("result.jsp").forward(request, response);
            return;
        }

        ContractValidator validator = new ContractValidator();
        String validationError = validator.validate(verifyResult.decryptedText);

        if (validationError != null) {
            request.setAttribute("resultType", "verifyFail");
            request.setAttribute("who", "influencer");
            request.setAttribute("failReason", "계약서 유효성 오류: " + validationError);
            request.getRequestDispatcher("result.jsp").forward(request, response);
            return;
        }

        boolean signSuccess = false;

        try {
            ContractSigner signer = new ContractSigner(dataDir);
            signer.sign(verifyResult.contractBytes);
            signSuccess = true;
        } catch (Exception e) {
            request.setAttribute("resultType", "verifyFail");
            request.setAttribute("who", "influencer");
            request.setAttribute("stepInfluencerSig", false);
            request.setAttribute("failReason", "인플루언서 서명 생성 실패: " + e.getMessage());
            request.getRequestDispatcher("result.jsp").forward(request, response);
            return;
        }

        String contractText = verifyResult.decryptedText;

        request.setAttribute("stepInfluencerSig", signSuccess);
        request.setAttribute("resultType", "signSuccess");
        request.setAttribute("who", "influencer");
        request.setAttribute("contractId", parseField(contractText, "contractId"));
        request.setAttribute("brandName", parseField(contractText, "brandName"));
        request.setAttribute("influencerId", parseField(contractText, "influencerId"));
        request.setAttribute("adFee", parseField(contractText, "adFee"));

        request.getRequestDispatcher("result.jsp").forward(request, response);
    }

    private String parseField(String text, String key) {
        if (text == null) return null;

        for (String line : text.split("\n")) {
            line = line.trim();

            if (line.startsWith(key + "=")) {
                return line.substring(key.length() + 1).trim();
            }
        }

        return null;
    }
}
