<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>

<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>광고 계약서 작성 | 안전한 광고 계약 관리</title>

<style>
    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }

    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background: #f0f4f8;
        padding: 32px 16px;
        color: #2d3748;
    }

    .container {
        max-width: 720px;
        margin: 0 auto;
    }

    .page-header {
        text-align: center;
        margin-bottom: 32px;
    }

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

    .page-header h1 {
        font-size: 1.6rem;
        margin: 8px 0 8px;
        color: #1a202c;
    }

    .page-header p {
        color: #718096;
        font-size: 0.92rem;
        line-height: 1.6;
    }

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

    .form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
    }

    .form-group {
        display: flex;
        flex-direction: column;
    }

    label {
        font-size: 0.82rem;
        font-weight: 600;
        color: #4a5568;
        margin-bottom: 5px;
    }

    label .required {
        color: #e53e3e;
        margin-left: 2px;
    }

    input[type="text"],
    input[type="email"],
    input[type="number"],
    input[type="date"],
    select {
        border: 1px solid #cbd5e0;
        border-radius: 6px;
        padding: 9px 12px;
        font-size: 0.9rem;
        font-family: inherit;
        color: #2d3748;
        transition: border-color 0.2s;
        background: #fff;
    }

    input:focus,
    select:focus {
        outline: none;
        border-color: #3182ce;
        box-shadow: 0 0 0 2px rgba(49,130,206,0.2);
    }

    .hint {
        font-size: 0.75rem;
        color: #718096;
        margin-top: 4px;
        line-height: 1.4;
    }

    .security-note {
        background: #f7fafc;
        border: 1px solid #e2e8f0;
        border-left: 4px solid #3182ce;
        border-radius: 8px;
        padding: 14px 16px;
        font-size: 0.84rem;
        color: #4a5568;
        line-height: 1.6;
        margin-bottom: 20px;
    }

    .security-note strong {
        color: #2b6cb0;
    }

    .btn-row {
        display: flex;
        gap: 12px;
        justify-content: center;
        align-items: center;
        margin-top: 24px;
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
	}

	.btn-secondary:hover {
	    background: #f1f5f9;
	    color: #2d3748;
	}

	.btn-primary {
	    background: #1e40af;
	    color: #ffffff;
	}

	.btn-primary:hover {
	    background: #1d4ed8;
	    transform: translateY(-1px);
	}

    @media (max-width: 600px) {
        .form-grid {
            grid-template-columns: 1fr;
        }

        .form-group[style] {
            grid-column: auto !important;
        }

        .card {
            padding: 24px 22px;
        }

        .btn-row {
            flex-direction: column;
        }

        .btn {
            width: 100%;
        }
    }
</style>

</head>
<body>
    <div class="container">

    <div class="page-header">
        <div class="label">브랜드 계약 관리</div>
        <h1>새 광고 계약을 작성하세요</h1>
        <p>
            광고 조건, 정산 정보, 게시 일정을 입력하면<br>
            인플루언서가 검토할 수 있는 계약서가 생성됩니다.
        </p>
    </div>

    <div class="security-note">
        <strong>안내</strong><br>
        입력한 광고비, 계좌번호, 게시 조건은 안전하게 보호되며,
        계약서 생성 후에는 변조 여부와 브랜드 확인 기록을 검증할 수 있습니다.
    </div>

    <form action="CreateContractServlet" method="post">

        <div class="card">
            <div class="section-title">브랜드 정보</div>

            <div class="form-grid">
                <div class="form-group">
                    <label>브랜드명 <span class="required">*</span></label>
                    <input type="text" name="brandName" placeholder="예: 오설록 티하우스" required>
                </div>

                <div class="form-group">
                    <label>사업자등록번호 <span class="required">*</span></label>
                    <input type="text" name="brandRegNo" placeholder="예: 220-81-00674" required>
                </div>

                <div class="form-group" style="grid-column: span 2">
                    <label>브랜드 이메일 <span class="required">*</span></label>
                    <input type="email" name="brandContact" placeholder="예: marketing@brand.com" required>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="section-title">인플루언서 정보</div>

            <div class="form-grid">
                <div class="form-group">
                    <label>인플루언서 이름 <span class="required">*</span></label>
                    <input type="text" name="influencerName" placeholder="예: 김민지" required>
                </div>

                <div class="form-group">
                    <label>인플루언서 ID <span class="required">*</span></label>
                    <input type="text" name="influencerId" placeholder="예: minji_life" required>
                </div>

                <div class="form-group">
                    <label>활동 플랫폼 <span class="required">*</span></label>
                    <select name="platform" required>
                        <option value="">선택하세요</option>
                        <option value="Instagram">Instagram</option>
                        <option value="YouTube">YouTube</option>
                        <option value="TikTok">TikTok</option>
                        <option value="NaverBlog">네이버 블로그</option>
                        <option value="Twitter">Twitter/X</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>팔로워 수 <span class="required">*</span></label>
                    <input type="number" name="followers" placeholder="예: 280000" min="0" required>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="section-title">광고 조건</div>

            <div class="form-grid">
                <div class="form-group">
                    <label>광고 유형 <span class="required">*</span></label>
                    <select name="adType" required>
                        <option value="">선택하세요</option>
                        <option value="협찬">협찬</option>
                        <option value="광고비지급">광고비 지급</option>
                        <option value="협찬+광고비지급">협찬 + 광고비 지급</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>광고비 (원) <span class="required">*</span></label>
                    <input type="number" name="adFee" placeholder="예: 3500000" min="0" required>
                    <span class="hint">계약 단가 보호 대상입니다.</span>
                </div>

                <div class="form-group" style="grid-column: span 2">
                    <label>제품명 <span class="required">*</span></label>
                    <input type="text" name="productName" placeholder="예: 제주 녹차 세트" required>
                </div>

                <div class="form-group">
                    <label>게시물 수 <span class="required">*</span></label>
                    <input type="number" name="postCount" placeholder="예: 3" min="1" required>
                </div>

                <div class="form-group">
                    <label>게시 마감일 <span class="required">*</span></label>
                    <input type="date" name="postDeadline" required>
                </div>

                <div class="form-group">
                    <label>필수 해시태그</label>
                    <input type="text" name="hashTag" placeholder="예: #브랜드명 #제품명 #광고">
                </div>

                <div class="form-group">
                    <label>광고 표기 의무 <span class="required">*</span></label>
                    <select name="disclosureRequired" required>
                        <option value="true">필수</option>
                        <option value="false">해당 없음</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="section-title">정산 조건</div>

            <div class="form-grid">
                <div class="form-group">
                    <label>정산일 <span class="required">*</span></label>
                    <input type="date" name="paymentDate" required>
                </div>

                <div class="form-group">
                    <label>정산 방법 <span class="required">*</span></label>
                    <select name="paymentMethod" required>
                        <option value="">선택하세요</option>
                        <option value="계좌이체">계좌이체</option>
                        <option value="현금">현금</option>
                        <option value="수표">수표</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>계좌번호 <span class="required">*</span></label>
                    <input type="text" name="accountNo" placeholder="예: 110-123-456789" required>
                    <span class="hint">정산 정보 보호 대상입니다.</span>
                </div>

                <div class="form-group">
                    <label>은행명 <span class="required">*</span></label>
                    <input type="text" name="bankName" placeholder="예: 신한은행" required>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="section-title">위약금 조건</div>

            <div class="form-grid">
                <div class="form-group">
                    <label>위약금 비율 (%) <span class="required">*</span></label>
                    <input type="number" name="penaltyRate" placeholder="예: 20" min="0" max="100" required>
                </div>

                <div class="form-group">
                    <label>계약 취소 가능 기한 <span class="required">*</span></label>
                    <input type="date" name="cancelDeadline" required>
                </div>
            </div>
        </div>

        <div class="btn-row">
            <button type="button" class="btn btn-secondary"
                    onclick="if (history.length > 1) { history.back(); } else { location.href='index.jsp'; }">
                뒤로가기
            </button>

            <button type="submit" class="btn btn-primary">
                계약서 생성하기
            </button>
        </div>

    </form>
</div>

</body>
</html>
