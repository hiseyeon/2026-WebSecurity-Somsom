package adcontract;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public class ContractValidator {

    private static final DateTimeFormatter DATE_FORMAT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public String validate(String contractText) {
        if (contractText == null || contractText.isBlank()) {
            return "계약서 내용이 비어 있습니다.";
        }

        String[] requiredKeys = {
            "contractId", "contractDate",
            "brandName", "brandRegNo", "brandContact",
            "influencerName", "influencerId", "platform", "followers",
            "adType", "adFee", "productName", "postCount", "postDeadline",
            "disclosureRequired",
            "paymentDate", "paymentMethod", "accountNo", "bankName",
            "penaltyRate", "cancelDeadline",
            "issuer"
        };

        for (String key : requiredKeys) {
            String value = parseField(contractText, key);
            if (value == null || value.isBlank()) {
                return "필수 항목 누락: " + key;
            }
        }

        String adFee = parseField(contractText, "adFee");
        if (!isPositiveLong(adFee)) {
            return "광고비(adFee)가 올바른 숫자가 아닙니다: " + adFee;
        }

        String postCount = parseField(contractText, "postCount");
        if (!isPositiveInt(postCount)) {
            return "게시물 수(postCount)가 올바른 양의 정수가 아닙니다: " + postCount;
        }

        String followers = parseField(contractText, "followers");
        if (!isPositiveLong(followers)) {
            return "팔로워 수(followers)가 올바른 숫자가 아닙니다: " + followers;
        }

        String postDeadline = parseField(contractText, "postDeadline");
        if (!isValidDate(postDeadline)) {
            return "게시 마감일(postDeadline) 날짜 형식이 잘못되었습니다 (yyyy-MM-dd): " + postDeadline;
        }

        String paymentDate = parseField(contractText, "paymentDate");
        if (!isValidDate(paymentDate)) {
            return "정산일(paymentDate) 날짜 형식이 잘못되었습니다 (yyyy-MM-dd): " + paymentDate;
        }

        String cancelDeadline = parseField(contractText, "cancelDeadline");
        if (!isValidDate(cancelDeadline)) {
            return "계약 취소 마감일(cancelDeadline) 날짜 형식이 잘못되었습니다 (yyyy-MM-dd): " + cancelDeadline;
        }

        String penaltyRate = parseField(contractText, "penaltyRate");
        if (!isPenaltyRateValid(penaltyRate)) {
            return "위약금 비율(penaltyRate)은 0~100 사이의 정수여야 합니다: " + penaltyRate;
        }

        return null;
    }

    private String parseField(String text, String key) {
        for (String line : text.split("\n")) {
            line = line.trim();
            if (line.startsWith(key + "=")) {
                return line.substring(key.length() + 1).trim();
            }
        }
        return null;
    }

    private boolean isPositiveInt(String value) {
        if (value == null) return false;
        try {
            int v = Integer.parseInt(value.trim());
            return v > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private boolean isPositiveLong(String value) {
        if (value == null) return false;
        try {
            long v = Long.parseLong(value.trim());
            return v > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private boolean isValidDate(String value) {
        if (value == null) return false;
        try {
            LocalDate.parse(value.trim(), DATE_FORMAT);
            return true;
        } catch (DateTimeParseException e) {
            return false;
        }
    }

    private boolean isPenaltyRateValid(String value) {
        if (value == null) return false;
        try {
            int rate = Integer.parseInt(value.trim());
            return rate >= 0 && rate <= 100;
        } catch (NumberFormatException e) {
            return false;
        }
    }
}