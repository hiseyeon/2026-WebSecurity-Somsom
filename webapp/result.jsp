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
        if (s == null || s.equals("-")) return "-";
        try { return String.format("%,d", Long.parseLong(s.trim())) + "원"; }
        catch (Exception e) { return esc(s); }
    }
%>
<%
    String  resultType   = (String)  request.getAttribute("resultType");
    String  who          = (String)  request.getAttribute("who");
    String  contractId   = (String)  request.getAttribute("contractId");
    String  brandName    = (String)  request.getAttribute("brandName");
    String  influencerId = (String)  request.getAttribute("influencerId");
    String  adFee        = (String)  request.getAttribute("adFee");
    String  failReason   = (String)  request.getAttribute("failReason");

    Boolean stepAesKey   = (Boolean) request.getAttribute("stepAesKey");
    Boolean stepDecrypt  = (Boolean) request.getAttribute("stepDecrypt");
    Boolean stepHash     = (Boolean) request.getAttribute("stepHash");
    Boolean stepBrandSig = (Boolean) request.getAttribute("stepBrandSig");
    Boolean stepInfluSig = (Boolean) request.getAttribute("stepInfluencerSig");

    if (resultType   == null) resultType   = "verifyFail";
    if (contractId   == null) contractId   = "-";
    if (brandName    == null) brandName    = "-";
    if (influencerId == null) influencerId = "-";
    if (adFee        == null) adFee        = "-";

    boolean isCreate    = "createSuccess".equals(resultType);
    boolean isFinalSign = "signSuccess".equals(resultType);
    boolean isSuccess   = isCreate || isFinalSign;

    String[] stepNames = {
        "전자봉투 잠금 해제",
        "계약서 내용 복원",
        "위변조 여부 확인",
        "브랜드 서명 확인",
        "내 전자서명 추가"
    };
    Boolean[] stepVals = { stepAesKey, stepDecrypt, stepHash, stepBrandSig, stepInfluSig };
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>처리 결과 | 안전한 광고 계약 관리</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background: #f0f4f8;
        padding: 32px 16px;
        color: #2d3748;
    }

    .container { max-width: 680px; margin: 0 auto; }

    /* ── 결과 배너 ── */
    .result-banner {
        border-radius: 12px;
        padding: 40px 32px;
        text-align: center;
        margin-bottom: 24px;
    }
    .banner-create { background: #ebf8ff; border: 1px solid #bee3f8; }
    .banner-sign   { background: #1a202c; border: 1px solid #1a202c; }
    .banner-fail   { background: #fff;    border: 1px solid #fed7d7; }

    .result-icon {
        width: 52px; height: 52px;
        margin: 0 auto 14px;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 1.5rem; font-weight: 700;
    }
    .banner-create .result-icon { background: #fff;    color: #2b6cb0; }
    .banner-sign   .result-icon { background: #2d3748; color: #90cdf4; }
    .banner-fail   .result-icon { background: #fff5f5; color: #c53030; }

    .result-title { font-size: 1.4rem; font-weight: 700; margin-bottom: 8px; }
    .banner-create .result-title { color: #1a202c; }
    .banner-sign   .result-title { color: #ffffff; }
    .banner-fail   .result-title { color: #c53030; }

    .result-subtitle { font-size: 0.9rem; line-height: 1.7; }
    .banner-create .result-subtitle { color: #2b6cb0; }
    .banner-sign   .result-subtitle { color: #cbd5e0; }
    .banner-fail   .result-subtitle { color: #718096; }

    /* ── 카드 ── */
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
    .section-title.red { color: #c53030; border-left-color: #c53030; }

    /* ── 진행 내역 ── */
    .step-list { display: flex; flex-direction: column; }
    .step-item {
        display: flex; align-items: center; gap: 14px;
        padding: 11px 0; border-bottom: 1px solid #f1f5f9;
    }
    .step-item:last-child { border-bottom: none; }
    .step-icon {
        width: 28px; height: 28px; min-width: 28px;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 0.82rem; font-weight: 700;
    }
    .step-icon.pass { background: #ebf8ff; color: #2b6cb0; }
    .step-icon.fail { background: #fff5f5; color: #c53030; }
    .step-icon.skip { background: #f7fafc; color: #a0aec0; }
    .step-name { font-size: 0.88rem; font-weight: 600; color: #1f2937; flex: 1; }
    .step-label { font-size: 0.75rem; font-weight: 700; padding: 3px 8px; border-radius: 5px; }
    .step-label.pass { background: #ebf8ff; color: #2b6cb0; }
    .step-label.fail { background: #fff5f5; color: #c53030; }
    .step-label.skip { background: #f7fafc; color: #a0aec0; }

    /* ── 계약 요약 ── */
    .info-grid { display: grid; grid-template-columns: 120px 1fr; gap: 10px 16px; }
    .info-key { font-size: 0.84rem; color: #718096; font-weight: 600; }
    .info-val { font-size: 0.88rem; color: #1a202c; font-weight: 600; }
    .info-val.blue { color: #2b6cb0; }

    /* ── 적용된 보안 ── */
    .sec-list { display: flex; flex-direction: column; }
    .sec-item {
        display: flex; align-items: center; gap: 12px;
        padding: 10px 0; border-bottom: 1px solid #f1f5f9;
    }
    .sec-item:last-child { border-bottom: none; }
    .sec-check {
        width: 24px; height: 24px; min-width: 24px;
        border-radius: 50%;
        background: #ebf8ff; color: #2b6cb0;
        display: flex; align-items: center; justify-content: center;
        font-size: 0.75rem; font-weight: 700;
    }
    .sec-name { font-size: 0.87rem; font-weight: 600; color: #1f2937; flex: 1; }
    .sec-file {
        font-size: 0.72rem; color: #a0aec0;
        font-family: 'Courier New', monospace;
    }

    /* ── 안내/실패 박스 ── */
    .next-note {
        background: #f7fafc;
        border: 1px solid #e2e8f0;
        border-left: 4px solid #3182ce;
        border-radius: 8px;
        padding: 14px 16px;
        font-size: 0.86rem;
        color: #4a5568;
        line-height: 1.6;
    }
    .next-note strong { color: #2b6cb0; }

    .fail-box {
        background: #fff5f5;
        border: 1px solid #fed7d7;
        border-left: 4px solid #c53030;
        border-radius: 8px;
        padding: 14px 16px;
        font-size: 0.86rem;
        color: #742a2a;
        line-height: 1.6;
    }
    .fail-box strong { color: #c53030; }

    /* ── 버튼 ── */
    .btn-row { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; margin-top: 8px; }
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
    .btn-dark { background: #1a202c; color: #fff; }
    .btn-dark:hover { background: #2d3748; transform: translateY(-1px); }

    @media (max-width: 600px) {
        .card { padding: 24px 22px; }
        .result-banner { padding: 30px 22px; }
        .btn-row { flex-direction: column; }
        .btn { width: 100%; }
    }
</style>
</head>
<body>
<div class="container">

    <!-- 결과 배너 -->
    <div class="result-banner <%=
        isCreate    ? "banner-create" :
        isFinalSign ? "banner-sign"   : "banner-fail" %>">

        <div class="result-icon"><%= isSuccess ? "✓" : "!" %></div>

        <div class="result-title"><%=
            isCreate    ? "계약서가 안전하게 작성되었어요" :
            isFinalSign ? "계약이 체결되었습니다" :
                          "요청을 처리하지 못했어요" %></div>

        <div class="result-subtitle"><%=
            isCreate    ? "내용 암호화와 브랜드 전자서명까지 완료되었어요.<br>이제 인플루언서가 내용을 확인하고 서명할 차례예요." :
            isFinalSign ? "양측의 전자서명이 모두 완료된 최종 계약서가 안전하게 보관되었어요." :
                          "아래 내용을 확인한 뒤 다시 시도해 주세요." %></div>
    </div>

    <!-- 진행 내역 (인플루언서 흐름에서만 표시) -->
    <% if (!isCreate && stepAesKey != null) { %>
    <div class="card">
        <div class="section-title <%= isFinalSign ? "" : "red" %>">진행 내역</div>
        <div class="step-list">
            <% for (int i = 0; i < stepNames.length; i++) {
                Boolean v = stepVals[i];
                if (v == null && !isFinalSign) continue;
                String st    = (v == null) ? "skip" : (v ? "pass" : "fail");
                String icon  = (v == null) ? "-"    : (v ? "✓"    : "✕");
                String label = (v == null) ? "미진행" : (v ? "완료" : "실패");
            %>
            <div class="step-item">
                <div class="step-icon <%= st %>"><%= icon %></div>
                <div class="step-name"><%= stepNames[i] %></div>
                <span class="step-label <%= st %>"><%= label %></span>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <!-- 계약 요약 (성공 시) -->
    <% if (isSuccess) { %>
    <div class="card">
        <div class="section-title">계약 요약</div>
        <div class="info-grid">
            <div class="info-key">계약 번호</div>
            <div class="info-val"><%= esc(contractId) %></div>
            <div class="info-key">브랜드</div>
            <div class="info-val"><%= esc(brandName) %></div>
            <div class="info-key">인플루언서</div>
            <div class="info-val"><%= esc(influencerId) %></div>
            <div class="info-key">광고비</div>
            <div class="info-val blue"><%= money(adFee) %></div>
        </div>
    </div>

    <!-- 적용된 보안 -->
    <div class="card">
        <div class="section-title">이 계약서에 적용된 보안</div>
        <div class="sec-list">
            <div class="sec-item">
                <div class="sec-check">✓</div>
                <div class="sec-name">계약 내용 암호화 <span style="color:#a0aec0; font-weight:400;">— 당사자 외 열람 불가</span></div>
                <span class="sec-file">AES-256</span>
            </div>
            <div class="sec-item">
                <div class="sec-check">✓</div>
                <div class="sec-name">열람 키 보호 <span style="color:#a0aec0; font-weight:400;">— 인플루언서만 열 수 있음</span></div>
                <span class="sec-file">RSA-2048</span>
            </div>
            <div class="sec-item">
                <div class="sec-check">✓</div>
                <div class="sec-name">위변조 감지 <span style="color:#a0aec0; font-weight:400;">— 한 글자만 바뀌어도 차단</span></div>
                <span class="sec-file">SHA-256</span>
            </div>
            <div class="sec-item">
                <div class="sec-check">✓</div>
                <div class="sec-name">브랜드 전자서명 <span style="color:#a0aec0; font-weight:400;">— 작성자 보증·부인 방지</span></div>
                <span class="sec-file">전자서명</span>
            </div>
            <% if (isFinalSign) { %>
            <div class="sec-item">
                <div class="sec-check">✓</div>
                <div class="sec-name">인플루언서 전자서명 <span style="color:#a0aec0; font-weight:400;">— 계약 체결 확정</span></div>
                <span class="sec-file">전자서명</span>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <!-- 다음 단계 안내 (작성 완료 시) -->
    <% if (isCreate) { %>
    <div class="card">
        <div class="next-note">
            <strong>다음 단계</strong><br>
            아래 [인플루언서 확인 화면으로] 버튼을 누르면 인플루언서 입장에서
            계약서 안전 확인과 내용 열람, 서명까지 진행할 수 있어요.
        </div>
    </div>
    <% } %>

    <!-- 실패 사유 -->
    <% if (!isSuccess && failReason != null) { %>
    <div class="card">
        <div class="section-title red">자세한 사유</div>
        <div class="fail-box">
            <strong>처리하지 못한 이유</strong><br>
            <%= esc(failReason) %>
        </div>
    </div>
    <% } %>

    <!-- 버튼 -->
    <div class="btn-row">
        <a href="index.jsp" class="btn btn-secondary">메인으로</a>
        <% if (isCreate) { %>
        <a href="SignContractServlet" class="btn btn-primary">인플루언서 확인 화면으로</a>
        <% } else if (!isSuccess) { %>
        <a href="<%= "influencer".equals(who) ? "SignContractServlet" : "createContract.jsp" %>" class="btn btn-primary">다시 시도하기</a>
        <% } %>
    </div>

</div>
</body>
</html>
