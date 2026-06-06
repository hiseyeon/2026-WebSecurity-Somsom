package adcontract;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;


@WebServlet("/CreateContractServlet")
public class CreateContractServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOG = Logger.getLogger(CreateContractServlet.class.getName());

    private static final int MAX_FIELD_LEN = 200;
    private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");
    private static final Set<String> PLATFORMS =
            Set.of("Instagram", "YouTube", "TikTok", "NaverBlog", "Twitter");
    private static final Set<String> AD_TYPES =
            Set.of("협찬", "광고비지급", "협찬+광고비지급");
    private static final Set<String> PAY_METHODS =
            Set.of("계좌이체", "현금", "수표");
    private static final Set<String> BOOLS = Set.of("true", "false");

    private static final class ValidationResult {
        final boolean valid;
        final String message;
        private ValidationResult(boolean valid, String message) {
            this.valid = valid;
            this.message = message;
        }
        static ValidationResult ok()             { return new ValidationResult(true, null); }
        static ValidationResult fail(String msg) { return new ValidationResult(false, msg); }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // [데이터 저장 폴더]
        // 실행 옵션 -Dcontract.data.dir=경로 로 지정할 수 있고, 미지정 시 사용자 홈 아래
        // "AdContractData" 폴더를 사용한다. → 어느 PC에서도 동작하며 소스에 개인 경로/
        // 사용자명이 노출되지 않는다. A·B 가 같은 기본값을 쓰므로 동일 폴더를 공유한다.
        // (톰캣 배포 위치(getRealPath)는 재배포 시 초기화되어 사용하지 않는다.)
        String dataDir = System.getProperty("contract.data.dir");
        if (dataDir == null || dataDir.isEmpty()) {
            dataDir = new java.io.File(System.getProperty("user.home"), "AdContractData").getPath();
        }
        dataDir = new java.io.File(dataDir).getCanonicalPath();

        String brandName          = param(request, "brandName");
        String brandRegNo         = param(request, "brandRegNo");
        String brandContact       = param(request, "brandContact");
        String influencerName     = param(request, "influencerName");
        String influencerId       = param(request, "influencerId");
        String platform           = param(request, "platform");
        String followers          = param(request, "followers");
        String adType             = param(request, "adType");
        String adFee              = param(request, "adFee");
        String productName        = param(request, "productName");
        String postCount          = param(request, "postCount");
        String postDeadline       = param(request, "postDeadline");
        String hashTag            = param(request, "hashTag");
        String disclosureRequired = param(request, "disclosureRequired");
        String paymentDate        = param(request, "paymentDate");
        String paymentMethod      = param(request, "paymentMethod");
        String accountNo          = param(request, "accountNo");
        String bankName           = param(request, "bankName");
        String penaltyRate        = param(request, "penaltyRate");
        String cancelDeadline     = param(request, "cancelDeadline");

        ValidationResult vr = validate(
                brandName, brandRegNo, brandContact,
                influencerName, influencerId, platform, followers,
                adType, adFee, productName, postCount, postDeadline, hashTag, disclosureRequired,
                paymentDate, paymentMethod, accountNo, bankName, penaltyRate, cancelDeadline);

        if (!vr.valid) {
            forwardError(request, response, vr.message);
            return;
        }

        try {
            ContractFileManager.createAndSaveContract(
                    dataDir,
                    brandName, brandRegNo, brandContact,
                    influencerName, influencerId, platform, followers,
                    adType, adFee, productName,
                    postCount, postDeadline, hashTag, disclosureRequired,
                    paymentDate, paymentMethod, accountNo, bankName,
                    penaltyRate, cancelDeadline);

            if (!KeyManager.keysExist(dataDir)) {
                KeyManager.generateAndSaveAllKeys(dataDir);
            }

            EnvelopeCreator.EnvelopeResult r = EnvelopeCreator.createEnvelope(dataDir);

            request.setAttribute("mode", "create");
            request.setAttribute("success", r.isSuccess());
            request.setAttribute("message", r.getMessage());
            request.setAttribute("contractPath", r.getContractPath());
            request.setAttribute("encryptedContractPath", r.getEncryptedContractPath());
            request.setAttribute("ivPath", r.getIvPath());
            request.setAttribute("encryptedAesKeyPath", r.getEncryptedAesKeyPath());
            request.setAttribute("contractHashPath", r.getContractHashPath());
            request.setAttribute("brandSignaturePath", r.getBrandSignaturePath());

            if (r.isSuccess()) {
                request.setAttribute("contractContent",
                        ContractFileManager.readContractAsString(dataDir));
            }
            request.getRequestDispatcher("/result.jsp").forward(request, response);

        } catch (IllegalArgumentException e) {
            // 입력 검증(제어문자 등)에서 거부된 경우: 사용자에게 일반 안내
            forwardError(request, response, "입력값에 허용되지 않은 문자가 포함되어 있습니다.");
        } catch (Exception e) {
            // G33: 상세 예외는 서버 로그로만, 사용자에게는 일반 메시지
            LOG.log(Level.SEVERE, "계약서 처리 실패", e);
            forwardError(request, response, "처리 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
        }
    }

    private void forwardError(HttpServletRequest request, HttpServletResponse response,
                              String message) throws ServletException, IOException {
        request.setAttribute("mode", "create");
        request.setAttribute("success", false);
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/result.jsp").forward(request, response);
    }

    // G64: 논리적으로 완전한 검증 (필수 / 길이 / 형식 / 허용값 / 범위)
    private ValidationResult validate(
            String brandName, String brandRegNo, String brandContact,
            String influencerName, String influencerId, String platform, String followers,
            String adType, String adFee, String productName,
            String postCount, String postDeadline, String hashTag, String disclosureRequired,
            String paymentDate, String paymentMethod, String accountNo, String bankName,
            String penaltyRate, String cancelDeadline) {

        String[][] required = {
                {brandName, "브랜드명"}, {brandRegNo, "사업자등록번호"}, {brandContact, "브랜드 연락처"},
                {influencerName, "인플루언서 이름"}, {influencerId, "인플루언서 ID"}, {platform, "플랫폼"},
                {followers, "팔로워 수"}, {adType, "광고 유형"}, {adFee, "광고비"}, {productName, "제품명"},
                {postCount, "게시물 수"}, {postDeadline, "게시 마감일"}, {paymentDate, "정산일"},
                {paymentMethod, "정산 방법"}, {accountNo, "계좌번호"}, {bankName, "은행명"},
                {penaltyRate, "위약금 비율"}, {cancelDeadline, "계약 취소 마감일"}
        };
        for (String[] f : required) {
            if (isBlank(f[0])) return ValidationResult.fail(f[1] + "을(를) 입력하세요.");
            if (f[0].length() > MAX_FIELD_LEN) return ValidationResult.fail(f[1] + "이(가) 너무 깁니다.");
        }

        if (!EMAIL.matcher(brandContact).matches())
            return ValidationResult.fail("브랜드 이메일 형식이 올바르지 않습니다.");
        if (!isNonNegativeLong(followers))
            return ValidationResult.fail("팔로워 수는 0 이상의 숫자여야 합니다.");
        if (!isNonNegativeLong(adFee))
            return ValidationResult.fail("광고비는 0 이상의 숫자여야 합니다.");

        Integer posts = toInt(postCount);
        if (posts == null || posts < 1)
            return ValidationResult.fail("게시물 수는 1 이상의 숫자여야 합니다.");

        Integer penalty = toInt(penaltyRate);
        if (penalty == null || penalty < 0 || penalty > 100)
            return ValidationResult.fail("위약금 비율은 0~100 사이의 숫자여야 합니다.");

        if (!isIsoDate(postDeadline) || !isIsoDate(paymentDate) || !isIsoDate(cancelDeadline))
            return ValidationResult.fail("날짜 형식(yyyy-MM-dd)이 올바르지 않습니다.");

        if (!PLATFORMS.contains(platform))        return ValidationResult.fail("플랫폼 값이 올바르지 않습니다.");
        if (!AD_TYPES.contains(adType))           return ValidationResult.fail("광고 유형 값이 올바르지 않습니다.");
        if (!PAY_METHODS.contains(paymentMethod)) return ValidationResult.fail("정산 방법 값이 올바르지 않습니다.");
        if (!BOOLS.contains(disclosureRequired))  return ValidationResult.fail("광고 표기 여부 값이 올바르지 않습니다.");

        if (hashTag != null && hashTag.length() > MAX_FIELD_LEN)
            return ValidationResult.fail("해시태그가 너무 깁니다.");

        return ValidationResult.ok();
    }

    private String param(HttpServletRequest request, String name) {
        String val = request.getParameter(name);
        return val == null ? "" : val.trim();
    }

    private boolean isBlank(String s) {
        return s == null || s.isEmpty();
    }

    private boolean isNonNegativeLong(String s) {
        Long v = toLong(s);
        return v != null && v >= 0;
    }

    private Long toLong(String s) {
        try { return Long.valueOf(s); } catch (NumberFormatException e) { return null; }
    }

    private Integer toInt(String s) {
        try { return Integer.valueOf(s); } catch (NumberFormatException e) { return null; }
    }

    private boolean isIsoDate(String s) {
        try { java.time.LocalDate.parse(s); return true; }
        catch (java.time.format.DateTimeParseException e) { return false; }
    }
}
