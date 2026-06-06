package adcontract;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;


public final class ContractFileManager {

    private static final String CONTRACT_FILE = "ad_contract.txt";
    private static final String ISSUER = "AdContractSystem";

    private ContractFileManager() {
    }

    public static String createAndSaveContract(
            String dataDir,
            String brandName, String brandRegNo, String brandContact,
            String influencerName, String influencerId, String platform, String followers,
            String adType, String adFee, String productName,
            String postCount, String postDeadline, String hashTag, String disclosureRequired,
            String paymentDate, String paymentMethod, String accountNo, String bankName,
            String penaltyRate, String cancelDeadline) throws IOException {

        String contractId = generateContractId();
        String contractDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

        String content = buildContractContent(
                contractId, contractDate,
                brandName, brandRegNo, brandContact,
                influencerName, influencerId, platform, followers,
                adType, adFee, productName, postCount, postDeadline, hashTag, disclosureRequired,
                paymentDate, paymentMethod, accountNo, bankName,
                penaltyRate, cancelDeadline);

        ensureDir(dataDir);

        String filePath = dataDir + "/" + CONTRACT_FILE;
        Files.write(Paths.get(filePath), content.getBytes(StandardCharsets.UTF_8));
        return filePath;
    }

    private static String buildContractContent(
            String contractId, String contractDate,
            String brandName, String brandRegNo, String brandContact,
            String influencerName, String influencerId, String platform, String followers,
            String adType, String adFee, String productName,
            String postCount, String postDeadline, String hashTag, String disclosureRequired,
            String paymentDate, String paymentMethod, String accountNo, String bankName,
            String penaltyRate, String cancelDeadline) {

        StringBuilder sb = new StringBuilder();
        appendField(sb, "contractId", contractId);
        appendField(sb, "contractDate", contractDate);
        sb.append("\n");
        sb.append("── 브랜드 정보 ──────────────────\n");
        appendField(sb, "brandName", brandName);
        appendField(sb, "brandRegNo", brandRegNo);
        appendField(sb, "brandContact", brandContact);
        sb.append("\n");
        sb.append("── 인플루언서 정보 ──────────────\n");
        appendField(sb, "influencerName", influencerName);
        appendField(sb, "influencerId", influencerId);
        appendField(sb, "platform", platform);
        appendField(sb, "followers", followers);
        sb.append("\n");
        sb.append("── 광고 조건 ────────────────────\n");
        appendField(sb, "adType", adType);
        appendField(sb, "adFee", adFee);
        appendField(sb, "productName", productName);
        appendField(sb, "postCount", postCount);
        appendField(sb, "postDeadline", postDeadline);
        appendField(sb, "hashTag", hashTag);
        appendField(sb, "disclosureRequired", disclosureRequired);
        sb.append("\n");
        sb.append("── 정산 조건 ────────────────────\n");
        appendField(sb, "paymentDate", paymentDate);
        appendField(sb, "paymentMethod", paymentMethod);
        appendField(sb, "accountNo", accountNo);
        appendField(sb, "bankName", bankName);
        sb.append("\n");
        sb.append("── 위약금 조건 ──────────────────\n");
        appendField(sb, "penaltyRate", penaltyRate);
        appendField(sb, "cancelDeadline", cancelDeadline);
        sb.append("\n");
        appendField(sb, "issuer", ISSUER);

        return sb.toString();
    }


    private static void appendField(StringBuilder sb, String key, String value) {
        String v = value == null ? "" : value;
        if (containsControlChars(v)) {
            throw new IllegalArgumentException("허용되지 않은 제어문자가 포함된 입력입니다: " + key);
        }
        sb.append(key).append('=').append(v).append('\n');
    }

    private static boolean containsControlChars(String s) {
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c != '\t' && (c < 0x20 || c == 0x7F)) { 
                return true;
            }
        }
        return false;
    }

    public static byte[] readContractBytes(String dataDir) throws IOException {
        return Files.readAllBytes(Paths.get(dataDir + "/" + CONTRACT_FILE));
    }

    public static String readContractAsString(String dataDir) throws IOException {
        return new String(readContractBytes(dataDir), StandardCharsets.UTF_8);
    }

    private static void ensureDir(String dataDir) throws IOException {
        File dir = new File(dataDir);
        if (!dir.exists() && !dir.mkdirs()) {
            throw new IOException("data 디렉터리를 생성하지 못했습니다: " + dir.getAbsolutePath());
        }
    }

    private static String generateContractId() {
        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String suffix = UUID.randomUUID().toString().substring(0, 4).toUpperCase();
        return "CTR-" + date + "-" + suffix;
    }
}
