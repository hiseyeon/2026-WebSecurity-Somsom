<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>

<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인플루언서 광고 계약 관리 시스템</title>

<style>
    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }

    html,
    body {
        width: 100%;
        min-height: 100vh;
    }

    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background: #f0f4f8;
        color: #2d3748;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 24px;
    }

    .container {
        background: #ffffff;
        border-radius: 14px;
        box-shadow: 0 8px 28px rgba(15, 23, 42, 0.08);
        padding: 56px 48px;
        max-width: 600px;
        width: 100%;
        text-align: center;
    }

    .logo {
        width: 58px;
        height: 58px;
        margin: 0 auto 16px;
        border-radius: 18px;
        background: #eff6ff;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .logo img {
        width: 34px;
        height: 34px;
        object-fit: contain;
    }

    h1 {
        font-size: 1.55rem;
        color: #1a202c;
        margin-bottom: 10px;
        letter-spacing: -0.4px;
        line-height: 1.4;
    }

    .subtitle {
        color: #718096;
        font-size: 0.95rem;
        margin-bottom: 40px;
        line-height: 1.7;
    }

    .card-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        margin-bottom: 32px;
    }

    .card {
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 30px 22px;
        cursor: pointer;
        transition: all 0.2s ease;
        text-decoration: none;
        display: block;
        color: inherit;
        background: #ffffff;
    }

    .card:hover {
        border-color: #2563eb;
        box-shadow: 0 10px 24px rgba(37, 99, 235, 0.12);
        transform: translateY(-3px);
    }

    .card.brand {
        background: #eff6ff;
        border-color: #bfdbfe;
    }

    .card.brand:hover {
        background: #dbeafe;
        border-color: #2563eb;
    }

    .card.influencer {
        background: #f8fafc;
        border-color: #cbd5e1;
    }

    .card.influencer:hover {
        background: #eef2ff;
        border-color: #4f46e5;
        box-shadow: 0 10px 24px rgba(79, 70, 229, 0.10);
    }

    .card-icon {
        width: 48px;
        height: 48px;
        margin: 0 auto 14px;
        border-radius: 14px;
        background: rgba(255, 255, 255, 0.72);
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .card-icon img {
        width: 30px;
        height: 30px;
        object-fit: contain;
    }

    .card-title {
        font-size: 1rem;
        font-weight: 700;
        margin-bottom: 8px;
        color: #1f2937;
        letter-spacing: -0.2px;
    }

    .card-desc {
        font-size: 0.84rem;
        color: #64748b;
        line-height: 1.6;
    }

    .badge-row {
        display: flex;
        justify-content: center;
        gap: 8px;
        flex-wrap: wrap;
    }

    .badge {
        background: #f1f5f9;
        color: #475569;
        font-size: 0.75rem;
        font-weight: 600;
        padding: 6px 11px;
        border-radius: 20px;
    }

    @media (max-width: 600px) {
        .container {
            padding: 42px 24px;
        }

        .card-grid {
            grid-template-columns: 1fr;
        }

        h1 {
            font-size: 1.35rem;
        }

        .subtitle {
            font-size: 0.9rem;
        }
    }
</style>

</head>

<body>
    <div class="container">
        <div class="logo">
            <img src="assets/security.png" alt="보안 계약 관리">
        </div>

    <h1>인플루언서 광고 계약 관리 시스템</h1>

    <p class="subtitle">
        광고비, 정산 정보, 게시 조건처럼 민감한 계약 내용을 보호하고<br>
        양측이 확인한 계약 내용을 안전하게 기록합니다.
    </p>

    <div class="card-grid">
        <a href="createContract.jsp" class="card brand">
            <div class="card-icon">
                <img src="assets/company.png" alt="브랜드 담당자">
            </div>
            <div class="card-title">브랜드 담당자</div>
            <div class="card-desc">
                광고 조건을 입력하고<br>
                계약서를 생성합니다
            </div>
        </a>

        <a href="reviewContract.jsp" class="card influencer">
            <div class="card-icon">
                <img src="assets/user.png" alt="인플루언서">
            </div>
            <div class="card-title">인플루언서</div>
            <div class="card-desc">
                전달받은 계약 내용을<br>
                확인하고 동의합니다
            </div>
        </a>
    </div>

    <div class="badge-row">
        <span class="badge">계약 내용 보호</span>
        <span class="badge">변조 여부 확인</span>
        <span class="badge">양측 서명 기록</span>
        <span class="badge">정산 정보 보호</span>
    </div>
</div>

</body>
</html>
