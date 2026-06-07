<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String  resultType      = (String)  request.getAttribute("resultType");
    String  who             = (String)  request.getAttribute("who");
    String  contractId      = (String)  request.getAttribute("contractId");
    String  brandName       = (String)  request.getAttribute("brandName");
    String  influencerId    = (String)  request.getAttribute("influencerId");
    String  adFee           = (String)  request.getAttribute("adFee");
    String  failReason      = (String)  request.getAttribute("failReason");

    Boolean stepAesKey      = (Boolean) request.getAttribute("stepAesKey");
    Boolean stepDecrypt     = (Boolean) request.getAttribute("stepDecrypt");
    Boolean stepHash        = (Boolean) request.getAttribute("stepHash");
    Boolean stepBrandSig    = (Boolean) request.getAttribute("stepBrandSig");
    Boolean stepInfluSig    = (Boolean) request.getAttribute("stepInfluencerSig");

    if (resultType   == null) resultType   = "verifyFail";
    if (contractId   == null) contractId   = "-";
    if (brandName    == null) brandName    = "-";
    if (influencerId == null) influencerId = "-";
    if (adFee        == null) adFee        = "-";

    boolean isSuccess   = !"verifyFail".equals(resultType);
    boolean isFinalSign = "signSuccess".equals(resultType);
    boolean isCreate    = "createSuccess".equals(resultType);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>처리 결과 | Ad Contract Safe</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background: #f0f4f8;
        padding: 32px 16px;
        color: #2d3748;
    }
    .container { max-width: 680px; margin: 0 auto; }

    /* 결과 배너 */
    .result-banner {
        border-radius: 14px;
        padding: 40px 32px;
        text-align: center;
        margin-bottom: 24px;
    }
    .banner-create { background: linear-gradient(135deg, #eff6ff, #dbeafe); border: 2px solid #93c5fd; }
    .banner-sign   { background: linear-gradient(135deg, #f0fdf4, #dcfce7); border: 2px solid #86efac; }
    .banner-fail   { background: linear-gradient(135deg, #fff1f2, #ffe4e6); border: 2px solid #fda4af; }

    .result-icon { font-size: 3.2rem; margin-bottom: 14px; display: block; }
    .result-title { font-size: 1.45rem; font-weight: 700; margin-bottom: 8px; }
    .banner-create .result-title { color: #1e40af; }
    .banner-sign   .result-title { color: #166534; }
    .banner-fail   .result-title { color: #9f1239; }

    .result-subtitle { font-size: 0.92rem; line-height: 1.6; }
    .banner-create .result-subtitle { color: #1d4ed8; }
    .banner-sign   .result-subtitle { color: #15803d; }
    .banner-fail   .result-subtitle { color: #be123c; }

    /* 카드 */
    .card {
        background: #fff;
        border-radius: 10px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.07);
        padding: 28px 32px;
        margin-bottom: 20px;
    }
    .section-title {
        font-size: 1rem; font-weight: 700;
        border-left: 4px solid #2563eb;
        padding-left: 10px; margin-bottom: 20px;
        color: #1e40af;
    }
    .section-title.green { border-left-color: #16a34a; color: #166534; }
    .section-title.red   { border-left-color: #e11d48; color: #9f1239; }

    /* 단계별 체크리스트 */
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
    .step-icon.pass { background: #f0fdf4; color: #16a34a; }
    .step-icon.fail { background: #fff1f2; color: #e11d48; }
    .step-icon.skip { background: #f8fafc; color: #94a3b8; }
    .step-name { font-size: 0.88rem; font-weight: 600; color: #1f2937; flex: 1; }
    .step-label {
        font-size: 0.75rem; font-weight: 700;
        padding: 3px 8px; border-radius: 5px;
    }
    .step-label.pass { background: #f0fdf4; color: #16a34a; }
    .step-label.fail { background: #fff1f2; color: #e11d48; }
    .step-label.skip { background: #f8fafc; color: #94a3b8; }

    /* 계약 요약 */
    .info-grid { display: grid; grid-template-columns: 130px 1fr; gap: 8px 16px; }
    .info-key { font-size: 0.82rem; color: #64748b; font-weight: 600; }
    .info-val { font-size: 0.85rem; color: #1f2937; font-weight: 600; }
    .info-val.blue { color: #1e40af; }

    /* 파일 목록 */
    .file-list { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .file-item {
        background: #f8fafc; border: 1px solid #e2e8f0;
        border-radius: 7px; padding: 10px 13px;
        font-size: 0.79rem; color: #374151;
        font-family: 'Courier New', monospace;
        display: flex; align-items: center; gap: 7px;
    }
    .file-item.new { background: #f0fdf4; border-color: #bbf7d0; color: #166534; }

    /* 실패 사유 */
    .fail-reason-box {
        background: #fff1f2; border: 1px solid #fecdd3;
        border-left: 4px solid #e11d48;
        border-radius: 8px; padding: 14px 16px;
        font-size: 0.86rem; color: #881337; line-height: 1.6;
    }
    .fail-reason-box strong { color: #9f1239; }

    /* 다음 단계 안내 */
    .next-box {
        background: #fffbeb; border: 1px solid #fde68a;
        border-left: 4px solid #f59e0b;
        border-radius: 8px; padding: 14px 16px;
        font-size: 0.84rem; color: #78350f; line-height: 1.6;
    }
    .next-box strong { color: #92400e; }

    /* 버튼 */
    .btn-row { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; margin-top: 8px; }
    .btn {
        padding: 11px 24px; border-radius: 7px;
        font-size: 0.92rem; font-weight: 600;
        cursor: pointer; font-family: inherit;
        transition: all 0.2s; text-decoration: none;
        display: inline-block; border: none;
    }
    .btn-home    { background: #1e40af; color: #fff; }
    .btn-home:hover { background: #1d4ed8; transform: translateY(-1px); }
    .btn-review  { background: #16a34a; color: #fff; }
    .btn-review:hover { background: #15803d; transform: translateY(-1px); }
    .btn-secondary { background: #fff; color: #4a5568; border: 1px solid #e2e8f0; }
    .btn-secondary:hover { background: #f1f5f9; }

    @media (max-width: 600px) {
        .card { padding: 24px 22px; }
        .result-banner { padding: 30px 22px; }
        .file-list { grid-template-columns: 1fr; }
        .btn-row { flex-direction: column; }
        .btn { text-align: center; }
    }
</style>
</head>
<body>
<div class="container">

    <!-- 결과 배너 -->
    <div class="result-banner <%=
        isCreate    ? "banner-create" :
        isFinalSign ? "banner-sign"   : "banner-fail" %>">

        <span class="result-icon"><%=
            isCreate    ? "&#128196;" :
            isFinalSign ? "&#9989;"   : "&#128683;" %></span>

        <div class="result-title"><%=
            isCreate    ? "계약서 생성 및 1차 서명 완료" :
            isFinalSign ? "2차 서명 완료 · 최종 계약 완성" :
                          "서명 검증 실패 · 계약 진행 불가" %></div>

        <div class="result-subtitle"><%=
            isCreate    ? "AES 암호화와 브랜드 1차 전자서명이 적용된 전자봉투가 생성되었습니다." :
            isFinalSign ? "인플루언서 2차 서명 완료. 양측 서명이 포함된 최종 계약서가 완성되었습니다." :
                          "브랜드 서명 검증에 실패하였습니다. 계약서가 위변조되었거나 잘못된 봉투입니다." %></div>
    </div>

    <!-- 단계별 체크리스트 (signSuccess / verifyFail 시) -->
    <% if (!isCreate) { %>
    <div class="card">
        <div class="section-title <%= isFinalSign ? "green" : "red" %>">단계별 처리 결과</div>
        <div class="step-list">
            <%
                // 선언 블록 없이 인라인 삼항 연산자로 처리
                String[][] stepDefs = {
                    {"인플루언서 개인키로 AES 키 복호화"},
                    {"AES 키로 계약서 복호화"},
                    {"SHA-256 해시값 비교"},
                    {"브랜드 공개키로 1차 서명 검증"},
                    {"인플루언서 2차 서명 생성"}
                };
                Boolean[] stepVals = {
                    stepAesKey, stepDecrypt, stepHash, stepBrandSig, stepInfluSig
                };

                for (int i = 0; i < stepDefs.length; i++) {
                    Boolean v = stepVals[i];
                    if (v == null && !isFinalSign) continue;

                    String st    = (v == null) ? "skip" : (v ? "pass" : "fail");
                    String icon  = (v == null) ? "-"    : (v ? "O"    : "X");
                    String label = (v == null) ? "미실행" : (v ? "성공" : "실패");
            %>
            <div class="step-item">
                <div class="step-icon <%= st %>"><%= icon %></div>
                <div class="step-name"><%= stepDefs[i][0] %></div>
                <span class="step-label <%= st %>"><%= label %></span>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <!-- 계약 요약 (성공 시) -->
    <% if (isSuccess) { %>
    <div class="card">
        <div class="section-title <%= isFinalSign ? "green" : "" %>">계약 요약</div>
        <div class="info-grid">
            <div class="info-key">계약서 ID</div>
            <div class="info-val"><%= contractId %></div>
            <div class="info-key">브랜드명</div>
            <div class="info-val"><%= brandName %></div>
            <div class="info-key">인플루언서 ID</div>
            <div class="info-val"><%= influencerId %></div>
            <div class="info-key">광고비</div>
            <div class="info-val blue"><%= adFee.equals("-") ? "-" : adFee + " 원" %></div>
        </div>
    </div>

    <!-- 생성된 파일 목록 -->
    <div class="card">
        <div class="section-title">생성된 파일</div>
        <div class="file-list">
            <div class="file-item">encrypted_contract.bin</div>
            <div class="file-item">encrypted_aes_key.bin</div>
            <div class="file-item">iv.bin</div>
            <div class="file-item">contract_hash.bin</div>
            <div class="file-item">brand_signature.bin</div>
            <% if (isFinalSign) { %>
            <div class="file-item new">influencer_signature.bin [NEW]</div>
            <% } %>
        </div>
    </div>
    <% } %>

    <!-- createSuccess 다음 단계 안내 -->
    <% if (isCreate) { %>
    <div class="card">
        <div class="section-title">다음 단계 안내</div>
        <div class="next-box">
            <strong>인플루언서에게 전달하세요</strong><br>
            생성된 전자봉투 파일을 인플루언서에게 전달하면,
            인플루언서가 검토 후 2차 서명을 진행할 수 있습니다.
        </div>
    </div>
    <% } %>

    <!-- 실패 사유 -->
    <% if (!isSuccess && failReason != null) { %>
    <div class="card">
        <div class="section-title red">실패 사유</div>
        <div class="fail-reason-box">
            <strong>오류 내용</strong><br>
            <%= failReason %>
        </div>
    </div>
    <% } %>

    <!-- 버튼 -->
    <div class="btn-row">
        <a href="index.jsp" class="btn btn-home">메인으로</a>
        <% if (isCreate) { %>
        <a href="reviewContract.jsp" class="btn btn-review">인플루언서 검토 화면으로</a>
        <% } else if (!isSuccess) { %>
        <a href="index.jsp" class="btn btn-secondary">다시 시작하기</a>
        <% } %>
    </div>

</div>
</body>
</html>
