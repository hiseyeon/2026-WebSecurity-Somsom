package adcontract;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/SignContractServlet")
public class SignContractServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String dataDir = getServletContext().getRealPath("/") + "../data";

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