<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>계약서 검토 | Ad Contract Safe</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background: #f0f4f8;
        padding: 32px 16px;
        color: #2d3748;
    }

    .container { max-width: 720px; margin: 0 auto; }

    /* ── 페이지 헤더 ── */
    .page-header { text-align: center; margin-bottom: 32px; }

    .page-header .label {
        display: inline-block;
        background: #f0fdf4;
        color: #166534;
        font-size: 0.78rem;
        font-weight: 700;
        padding: 6px 12px;
        border-radius: 20px;
        margin-bottom: 12px;
    }

    .page-header h1 { font-size: 1.6rem; margin: 8px 0 8px; color: #1a202c; }
    .page-header p  { color: #718096; font-size: 0.92rem; line-height: 1.6; }

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
        color: #166534;
        border-left: 4px solid #16a34a;
        padding-left: 10px;
        margin-bottom: 20px;
    }

    /* ── 검증 단계 목록 ── */
    .step-list { display: flex; flex-direction: column; }

    .step-item {
        display: flex;
        align-items: center;
        gap: 14px;
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

    .step-icon.pass    { background: #f0fdf4; color: #16a34a; }
    .step-icon.fail    { background: #fff1f2; color: #e11d48; }
    .step-icon.pending { background: #f8fafc; color: #94a3b8; }

    .step-name { font-size: 0.88rem; font-weight: 600; color: #1f2937; flex: 1; }

    .step-tag {
        font-size: 0.7rem; font-weight: 700;
        padding: 3px 8px; border-radius: 4px;
        font-family: 'Courier New', monospace;
    }

    .step-tag.pass    { background: #f0fdf4; color: #16a34a; }
    .step-tag.fail    { background: #fff1f2; color: #e11d48; }
    .step-tag.pending { background: #f8fafc; color: #94a3b8; }

    /* ── 계약서 내용 표 ── */
    .contract-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.84rem;
    }

    .contract-table tr {
        border-bottom: 1px dashed #e2e8f0;
    }

    .contract-table tr:last-child { border-bottom: none; }

    .contract-table td {
        padding: 8px 4px;
        vertical-align: top;
    }

    .contract-table td.key {
        width: 140px;
        color: #64748b;
        font-weight: 600;
        white-space: nowrap;
    }

    .contract-table td.val {
        color: #1f2937;
        font-weight: 600;
    }

    .contract-table td.val.sensitive { color: #1e40af; }

    /* ── 안내 박스 ── */
    .info-note {
        background: #f0fdf4;
        border: 1px solid #bbf7d0;
        border-left: 4px solid #16a34a;
        border-radius: 8px;
        padding: 14px 16px;
        font-size: 0.84rem;
        color: #14532d;
        line-height: 1.6;
        margin-bottom: 20px;
    }

    .warn-note {
        background: #fffbeb;
        border: 1px solid #fde68a;
        border-left: 4px solid #f59e0b;
        border-radius: 8px;
        padding: 14px 16px;
        font-size: 0.84rem;
        color: #78350f;
        line-height: 1.6;
        margin-bottom: 20px;
    }

    /* ── 서명 동의 ── */
    .agree-box {
        background: #fff;
        border: 2px solid #bbf7d0;
        border-radius: 10px;
        padding: 22px 24px;
    }

    .agree-title { font-size: 0.95rem; font-weight: 700; color: #166534; margin-bottom: 10px; }
    .agree-desc  { font-size: 0.84rem; color: #374151; line-height: 1.7; margin-bottom: 18px; }

    .agree-check {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 20px;
        cursor: pointer;
    }

    .agree-check input[type="checkbox"] {
        width: 18px; height: 18px;
        accent-color: #16a34a;
        cursor: pointer;
    }

    .agree-check span { font-size: 0.88rem; font-weight: 600; color: #1f2937; }

    /* ── 버튼 ── */
    .btn-row {
        display: flex;
        gap: 12px;
        justify-content: center;
        align-items: center;
        margin-top: 24px;
        flex-wrap: wrap;
    }

    .btn {
        padding: 11px 28px;
        border-radius: 7px;
        font-size: 0.95rem;
        font-weight: 600;
        cursor: pointer;
        border: none;
        font-family: inherit;
        transition: all 0.2s;
    }

    .btn-secondary {
        background: #ffffff;
        color: #4a5568;
        border: 1px solid #e2e8f0;
    }

    .btn-secondary:hover { background: #f1f5f9; }

    .btn-sign { background: #16a34a; color: #ffffff; }
    .btn-sign:hover { background: #15803d; transform: translateY(-1px); }
    .btn-sign:disabled { background: #9ca3af; cursor: not-allowed; transform: none; }

    @media (max-width: 600px) {
        .card { padding: 24px 22px; }
        .contract-table td.key { width: 100px; }
        .btn-row { flex-direction: column; }
        .btn { width: 100%; }
    }
</style>
</head>
<body>

<%
    // ── [수정4] GET 직접 접근 차단 ──────────────────────────────
    // SignContractServlet이 forward로 넘긴 경우에만 정상 동작
    // GET으로 직접 접근하면 안내 메시지 표시
    boolean isForwarded = (request.getAttribute("stepAesKey") != null);

    // 검증 단계 결과 (SignContractServlet이 setAttribute로 넘긴 값)
    Boolean stepAesKey   = (Boolean) request.getAttribute("stepAesKey");
    Boolean stepDecrypt  = (Boolean) request.getAttribute("stepDecrypt");
    Boolean stepHash     = (Boolean) request.getAttribute("stepHash");
    Boolean stepBrandSig = (Boolean) request.getAttribute("stepBrandSig");

    // [수정3] 복호화된 계약서 텍스트에서 파싱
    String decryptedText = (String) request.getAttribute("decryptedText");

    // 계약서 필드 파싱 헬퍼 (JSP 내부용)
    java.util.Map<String, String> fields = new java.util.LinkedHashMap<>();
    if (decryptedText != null) {
        for (String line : decryptedText.split("\n")) {
            line = line.trim();
            int idx = line.indexOf('=');
            if (idx > 0) {
                fields.put(line.substring(0, idx).trim(), line.substring(idx + 1).trim());
            }
        }
    }

    // 검증 전체 통과 여부
    boolean verified = Boolean.TRUE.equals(stepAesKey)
                    && Boolean.TRUE.equals(stepDecrypt)
                    && Boolean.TRUE.equals(stepHash)
                    && Boolean.TRUE.equals(stepBrandSig);

    String[] stepNames = {
        "인플루언서 개인키로 AES 키 복호화",
        "AES 키로 계약서 복호화",
        "SHA-256 해시값 비교",
        "브랜드 공개키로 1차 서명 검증"
    };
    String[] stepTags = { "RSA", "AES", "SHA-256", "RSA" };
%>


<div class="container">

    <div class="page-header">
        <div class="label">🧑‍💼 인플루언서 · 2단계</div>
        <h1>계약서를 검토하고 서명합니다</h1>
        <p>브랜드의 1차 서명을 검증한 뒤 계약 내용을 확인하고<br>
           동의하면 인플루언서 개인키로 2차 서명합니다.</p>
    </div>

    <% if (!isForwarded) { %>
    <!-- [수정4] GET 직접 접근 시 안내 -->
    <div class="warn-note">
        <strong>전자봉투 검증이 필요합니다</strong><br>
        이 화면은 먼저 <strong>전자봉투 검증</strong>을 완료해야 접근할 수 있습니다.
        메인 화면에서 인플루언서 버튼을 눌러 검증을 시작하세요.
    </div>
    <div class="btn-row">
        <a href="index.jsp" style="text-decoration:none;">
            <button class="btn btn-secondary">메인으로 돌아가기</button>
        </a>
    </div>

    <% } else { %>

    <!-- ── [수정2] 검증 단계 결과 표시 ── -->
    <div class="card">
        <div class="section-title">자동 검증 결과</div>
        <div class="step-list">
            <% for (int i = 0; i < stepNames.length; i++) {
                Boolean stepVal = (Boolean) request.getAttribute(
                    new String[]{"stepAesKey","stepDecrypt","stepHash","stepBrandSig"}[i]);
                String st    = (stepVal == null) ? "pending" : (stepVal ? "pass" : "fail");
                String icon  = (stepVal == null) ? "-"       : (stepVal ? "O"    : "X");
                String label = (stepVal == null) ? "대기"     : (stepVal ? "성공" : "실패");
            %>
            <div class="step-item">
                <div class="step-icon <%= st %>"><%= icon %></div>
                <div class="step-name"><%= stepNames[i] %></div>
                <span class="step-tag <%= st %>">
                    <%= stepTags[i] %> · <%= label %>
                </span>
            </div>
            <% } %>
        </div>
    </div>

    <% if (verified && decryptedText != null) { %>

    <!-- ── [수정3] 복호화된 계약서 내용 표시 ── -->
    <div class="card">
        <div class="section-title">복호화된 계약서 내용</div>
        <table class="contract-table">
            <tr><td class="key">계약서 ID</td>    <td class="val"><%= fields.getOrDefault("contractId", "-") %></td></tr>
            <tr><td class="key">계약일</td>        <td class="val"><%= fields.getOrDefault("contractDate", "-") %></td></tr>
            <tr><td class="key">브랜드명</td>      <td class="val"><%= fields.getOrDefault("brandName", "-") %></td></tr>
            <tr><td class="key">인플루언서 ID</td> <td class="val"><%= fields.getOrDefault("influencerId", "-") %></td></tr>
            <tr><td class="key">플랫폼</td>        <td class="val"><%= fields.getOrDefault("platform", "-") %></td></tr>
            <tr><td class="key">광고비</td>
                <td class="val sensitive"><%= fields.getOrDefault("adFee", "-") %> 원</td></tr>
            <tr><td class="key">광고 유형</td>     <td class="val"><%= fields.getOrDefault("adType", "-") %></td></tr>
            <tr><td class="key">제품명</td>        <td class="val"><%= fields.getOrDefault("productName", "-") %></td></tr>
            <tr><td class="key">게시물 수</td>     <td class="val"><%= fields.getOrDefault("postCount", "-") %></td></tr>
            <tr><td class="key">게시 마감일</td>   <td class="val"><%= fields.getOrDefault("postDeadline", "-") %></td></tr>
            <tr><td class="key">위약금 비율</td>   <td class="val"><%= fields.getOrDefault("penaltyRate", "-") %>%</td></tr>
            <tr><td class="key">정산일</td>        <td class="val"><%= fields.getOrDefault("paymentDate", "-") %></td></tr>
            <tr><td class="key">계좌번호</td>
                <td class="val sensitive"><%= fields.getOrDefault("accountNo", "-") %></td></tr>
        </table>
    </div>

    <!-- ── [수정5] 2차 서명 폼 (mode=sign, 검증 재실행 없이 서명만 요청) ── -->
    <div class="card">
        <div class="section-title">인플루언서 2차 서명</div>
        <div class="agree-box">
            <div class="agree-title">✍️ 계약 동의 및 서명</div>
            <div class="agree-desc">
                위 계약 내용을 모두 확인하였으며 브랜드의 1차 서명 검증이 완료되었습니다.<br>
                동의하시면 인플루언서 개인키로 <strong>2차 전자서명</strong>이 생성되고
                최종 전자봉투가 완성됩니다.
            </div>
            <label class="agree-check">
                <input type="checkbox" id="agreeCheck"
                       onchange="document.getElementById('signBtn').disabled = !this.checked">
                <span>계약 내용을 확인하였으며 동의합니다.</span>
            </label>

            <form action="SignContractServlet" method="post">
                <div class="btn-row" style="margin-top:0; justify-content:flex-start;">
                    <button type="button" class="btn btn-secondary"
                            onclick="location.href='index.jsp'">
                        메인으로
                    </button>
                    <button type="submit" id="signBtn" class="btn btn-sign" disabled>
                        ✍️ 2차 서명 및 최종 봉투 생성
                    </button>
                </div>
            </form>
        </div>
    </div>

    <% } else if (!verified) { %>
    <!-- 검증 실패 시 서명 불가 안내 -->
    <div class="warn-note">
        <strong>서명 불가</strong><br>
        검증 단계 중 하나 이상이 실패하였습니다.
        계약서가 위변조되었거나 잘못된 전자봉투일 수 있습니다. 브랜드 측에 재발급을 요청하세요.
    </div>
    <div class="btn-row">
        <a href="index.jsp" style="text-decoration:none;">
            <button class="btn btn-secondary">메인으로 돌아가기</button>
        </a>
    </div>
    <% } %>

    <% } // end isForwarded %>

</div>
</body>
</html>
