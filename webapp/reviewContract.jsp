<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    // [보안] 사용자 유래 값 HTML 이스케이프 (XSS 방지)
    private static String esc(String s) {
        if (s == null) return "";
        StringBuilder b = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '<':  b.append("&lt;");   break;
                case '>':  b.append("&gt;");   break;
                case '&':  b.append("&amp;");  break;
                case '"':  b.append("&quot;"); break;
                case '\'': b.append("&#39;");  break;
                default:   b.append(c);
            }
        }
        return b.toString();
    }

    // 금액을 1,234,567원 형태로 표시
    private static String money(String s) {
        try { return String.format("%,d", Long.parseLong(s.trim())) + "원"; }
        catch (Exception e) { return esc(s); }
    }
%>
<%
    // SignContractServlet(doGet)이 검증 결과를 forward 한 경우에만 열람 가능
    boolean isForwarded = (request.getAttribute("stepAesKey") != null);

    Boolean stepAesKey   = (Boolean) request.getAttribute("stepAesKey");
    Boolean stepDecrypt  = (Boolean) request.getAttribute("stepDecrypt");
    Boolean stepHash     = (Boolean) request.getAttribute("stepHash");
    Boolean stepBrandSig = (Boolean) request.getAttribute("stepBrandSig");

    String decryptedText = (String) request.getAttribute("decryptedText");

    java.util.Map<String, String> f = new java.util.LinkedHashMap<>();
    if (decryptedText != null) {
        for (String line : decryptedText.split("\n")) {
            line = line.trim();
            int idx = line.indexOf('=');
            if (idx > 0) {
                f.put(line.substring(0, idx).trim(), line.substring(idx + 1).trim());
            }
        }
    }

    boolean verified = Boolean.TRUE.equals(stepAesKey)
                    && Boolean.TRUE.equals(stepDecrypt)
                    && Boolean.TRUE.equals(stepHash)
                    && Boolean.TRUE.equals(stepBrandSig);

    String[][] steps = {
        {"전자봉투 잠금 해제", "RSA"},
        {"계약서 내용 복원",   "AES-256"},
        {"위변조 여부 확인",   "SHA-256"},
        {"브랜드 서명 확인",   "전자서명"}
    };
    Boolean[] stepVals = { stepAesKey, stepDecrypt, stepHash, stepBrandSig };

    String disclosure = "true".equals(f.get("disclosureRequired")) ? "광고 표기 필수" : "해당 없음";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>계약서 확인 | 안전한 광고 계약 관리</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background: #f0f4f8;
        padding: 32px 16px;
        color: #2d3748;
    }

    .container { max-width: 720px; margin: 0 auto; }

    .page-header { text-align: center; margin-bottom: 32px; }

    .page-header .label {
        display: inline-block;
        background: #ebf8ff;
        color: #2b6cb0;
        font-size: 0.78rem;
        font-weight: 700;
        padding: 6px 12px;
        border-radius: 20px;
        margin-bottom: 12px;
    }

    .page-header h1 { font-size: 1.6rem; margin: 8px 0 8px; color: #1a202c; }
    .page-header p  { color: #718096; font-size: 0.92rem; line-height: 1.6; }

    .card {
        background: #fff;
        border-radius: 10px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.07);
        padding: 28px 32px;
        margin-bottom: 20px;
    }

    .section-title {
        font-size: 1rem;
        font-weight: 700;
        color: #2b6cb0;
        border-left: 4px solid #3182ce;
        padding-left: 10px;
        margin-bottom: 20px;
    }

    /* 안전 확인 단계 */
    .step-list { display: flex; flex-direction: column; }

    .step-item {
        display: flex; align-items: center; gap: 14px;
        padding: 11px 0;
        border-bottom: 1px solid #f1f5f9;
    }
    .step-item:last-child { border-bottom: none; }

    .step-icon {
        width: 28px; height: 28px; min-width: 28px;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 0.82rem; font-weight: 700;
    }
    .step-icon.pass    { background: #ebf8ff; color: #2b6cb0; }
    .step-icon.fail    { background: #fff5f5; color: #c53030; }
    .step-icon.pending { background: #f7fafc; color: #a0aec0; }

    .step-name { font-size: 0.88rem; font-weight: 600; color: #1f2937; flex: 1; }

    .step-tag {
        font-size: 0.7rem; font-weight: 700;
        padding: 3px 8px; border-radius: 4px;
        font-family: 'Courier New', monospace;
    }
    .step-tag.pass    { background: #ebf8ff; color: #2b6cb0; }
    .step-tag.fail    { background: #fff5f5; color: #c53030; }
    .step-tag.pending { background: #f7fafc; color: #a0aec0; }

    .safe-strip {
        margin-top: 16px;
        background: #ebf8ff;
        border: 1px solid #bee3f8;
        border-radius: 8px;
        padding: 12px 16px;
        font-size: 0.86rem;
        color: #2b6cb0;
        font-weight: 600;
    }

    /* 계약 내용 */
    .contract-table { width: 100%; border-collapse: collapse; font-size: 0.86rem; }
    .contract-table tr { border-bottom: 1px dashed #e2e8f0; }
    .contract-table tr:last-child { border-bottom: none; }
    .contract-table td { padding: 9px 4px; vertical-align: top; }
    .contract-table td.key { width: 130px; color: #718096; font-weight: 600; white-space: nowrap; }
    .contract-table td.val { color: #1a202c; font-weight: 600; }
    .contract-table td.val.blue { color: #2b6cb0; }

    /* 안내 박스 */
    .info-note {
        background: #f7fafc;
        border: 1px solid #e2e8f0;
        border-left: 4px solid #3182ce;
        border-radius: 8px;
        padding: 14px 16px;
        font-size: 0.86rem;
        color: #4a5568;
        line-height: 1.6;
        margin-bottom: 20px;
    }
    .info-note strong { color: #2b6cb0; }

    .fail-note {
        background: #fff5f5;
        border: 1px solid #fed7d7;
        border-left: 4px solid #c53030;
        border-radius: 8px;
        padding: 14px 16px;
        font-size: 0.86rem;
        color: #742a2a;
        line-height: 1.6;
        margin-bottom: 20px;
    }
    .fail-note strong { color: #c53030; }

    /* 서명 동의 */
    .agree-desc { font-size: 0.86rem; color: #4a5568; line-height: 1.7; margin-bottom: 18px; }

    .agree-check {
        display: flex; align-items: center; gap: 10px;
        background: #f7fafc;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 14px 16px;
        margin-bottom: 20px;
        cursor: pointer;
    }
    .agree-check input[type="checkbox"] {
        width: 18px; height: 18px;
        accent-color: #3182ce;
        cursor: pointer;
    }
    .agree-check span { font-size: 0.9rem; font-weight: 600; color: #1a202c; }

    /* 버튼 */
    .btn-row { display: flex; gap: 12px; justify-content: center; align-items: center; flex-wrap: wrap; margin-top: 4px; }

    .btn {
        padding: 11px 28px;
        border-radius: 7px;
        font-size: 0.95rem;
        font-weight: 600;
        cursor: pointer;
        border: none;
        font-family: inherit;
        transition: all 0.2s;
        text-decoration: none;
        display: inline-block;
        text-align: center;
    }
    .btn-secondary { background: #fff; color: #4a5568; border: 1px solid #e2e8f0; }
    .btn-secondary:hover { background: #f7fafc; }
    .btn-primary { background: #3182ce; color: #fff; }
    .btn-primary:hover { background: #2b6cb0; transform: translateY(-1px); }
    .btn-primary:disabled { background: #a0aec0; cursor: not-allowed; transform: none; }

    @media (max-width: 600px) {
        .card { padding: 24px 22px; }
        .contract-table td.key { width: 100px; }
        .btn-row { flex-direction: column; }
        .btn { width: 100%; }
    }
</style>
</head>
<body>
<div class="container">

    <div class="page-header">
        <div class="label">인플루언서 · 계약 확인</div>
        <h1>받은 계약서를 확인해 주세요</h1>
        <p>안전 확인을 통과한 계약서만 열람할 수 있어요.<br>
           내용을 확인하고 동의하면 회원님의 전자서명으로 계약이 체결됩니다.</p>
    </div>

<% if (!isForwarded) { %>

    <div class="info-note">
        <strong>계약서 확인은 메인 화면에서 시작할 수 있어요.</strong><br>
        메인 화면에서 [인플루언서] 버튼을 누르면 받은 계약서의 안전 확인이 자동으로 진행됩니다.
    </div>
    <div class="btn-row">
        <a href="index.jsp" class="btn btn-secondary">메인으로 돌아가기</a>
    </div>

<% } else { %>

    <div class="card">
        <div class="section-title">계약서 안전 확인</div>
        <div class="step-list">
            <% for (int i = 0; i < steps.length; i++) {
                Boolean v = stepVals[i];
                String st    = (v == null) ? "pending" : (v ? "pass" : "fail");
                String icon  = (v == null) ? "-"       : (v ? "✓"    : "✕");
                String label = (v == null) ? "대기"    : (v ? "통과" : "실패");
            %>
            <div class="step-item">
                <div class="step-icon <%= st %>"><%= icon %></div>
                <div class="step-name"><%= steps[i][0] %></div>
                <span class="step-tag <%= st %>"><%= steps[i][1] %> · <%= label %></span>
            </div>
            <% } %>
        </div>
        <% if (verified) { %>
        <div class="safe-strip">✓ 안전한 계약서예요. 위변조 없이 브랜드의 전자서명까지 확인되었습니다.</div>
        <% } %>
    </div>

    <% if (verified && decryptedText != null) { %>

    <div class="card">
        <div class="section-title">계약 내용</div>
        <table class="contract-table">
            <tr><td class="key">계약 번호</td>   <td class="val"><%= esc(f.getOrDefault("contractId", "-")) %></td></tr>
            <tr><td class="key">계약일</td>      <td class="val"><%= esc(f.getOrDefault("contractDate", "-")) %></td></tr>
            <tr><td class="key">브랜드</td>      <td class="val"><%= esc(f.getOrDefault("brandName", "-")) %></td></tr>
            <tr><td class="key">인플루언서</td>  <td class="val"><%= esc(f.getOrDefault("influencerName", "-")) %> (<%= esc(f.getOrDefault("influencerId", "-")) %>)</td></tr>
            <tr><td class="key">플랫폼</td>      <td class="val"><%= esc(f.getOrDefault("platform", "-")) %></td></tr>
            <tr><td class="key">광고 유형</td>   <td class="val"><%= esc(f.getOrDefault("adType", "-")) %></td></tr>
            <tr><td class="key">제품명</td>      <td class="val"><%= esc(f.getOrDefault("productName", "-")) %></td></tr>
            <tr><td class="key">광고비</td>      <td class="val blue"><%= money(f.getOrDefault("adFee", "-")) %></td></tr>
            <tr><td class="key">게시물 수</td>   <td class="val"><%= esc(f.getOrDefault("postCount", "-")) %>건</td></tr>
            <tr><td class="key">게시 마감일</td> <td class="val"><%= esc(f.getOrDefault("postDeadline", "-")) %></td></tr>
            <tr><td class="key">해시태그</td>    <td class="val"><%= esc(f.getOrDefault("hashTag", "-")) %></td></tr>
            <tr><td class="key">광고 표기</td>   <td class="val"><%= disclosure %></td></tr>
            <tr><td class="key">정산일</td>      <td class="val"><%= esc(f.getOrDefault("paymentDate", "-")) %></td></tr>
            <tr><td class="key">정산 방법</td>   <td class="val"><%= esc(f.getOrDefault("paymentMethod", "-")) %></td></tr>
            <tr><td class="key">입금 계좌</td>   <td class="val blue"><%= esc(f.getOrDefault("bankName", "-")) %> <%= esc(f.getOrDefault("accountNo", "-")) %></td></tr>
            <tr><td class="key">위약금 비율</td> <td class="val"><%= esc(f.getOrDefault("penaltyRate", "-")) %>%</td></tr>
            <tr><td class="key">계약 취소 기한</td><td class="val"><%= esc(f.getOrDefault("cancelDeadline", "-")) %></td></tr>
        </table>
    </div>

    <div class="card">
        <div class="section-title">계약 동의 및 서명</div>
        <div class="agree-desc">
            위 내용을 확인하셨다면 아래에 동의해 주세요.<br>
            동의하는 순간 회원님 명의의 <strong>전자서명</strong>이 계약서에 추가되고 계약이 체결됩니다.
            서명 이후에는 계약 내용을 변경할 수 없어요.
        </div>
        <label class="agree-check">
            <input type="checkbox" id="agreeCheck"
                   onchange="document.getElementById('signBtn').disabled = !this.checked">
            <span>계약 내용을 확인했으며 동의합니다.</span>
        </label>

        <form action="SignContractServlet" method="post">
            <div class="btn-row">
                <a href="index.jsp" class="btn btn-secondary">메인으로</a>
                <button type="submit" id="signBtn" class="btn btn-primary" disabled>
                    동의하고 서명하기
                </button>
            </div>
        </form>
    </div>

    <% } else if (!verified) { %>

    <div class="fail-note">
        <strong>계약서를 확인할 수 없어요.</strong><br>
        안전 확인 중 일부 단계를 통과하지 못했습니다. 계약서가 손상되었거나
        전달 과정에서 변경되었을 수 있어요. 브랜드에게 계약서 재발송을 요청해 주세요.
    </div>
    <div class="btn-row">
        <a href="index.jsp" class="btn btn-secondary">메인으로 돌아가기</a>
    </div>

    <% } %>

<% } %>

</div>
</body>
</html>
