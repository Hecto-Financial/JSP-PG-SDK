# JSP-PG-SDK

헥토파이낸셜 PG 결제창(UI) 연동을 위한 JSP 샘플 코드입니다.

> 공식 개발자 문서: [https://developers.hectofinancial.co.kr/docs/api/pg/sdk/01-sdk](https://developers.hectofinancial.co.kr/docs/api/pg/sdk/01-sdk)

## 개요

본 샘플코드는 **결제창(UI) 방식**입니다. 헥토파이낸셜 JavaScript SDK(`SettlePG`)를 사용하여 팝업 또는 iframe 형태로 결제창을 띄웁니다.

- API 직접 호출(Non-UI) 방식은 별도 샘플 코드를 참고하세요.
- 민감정보 암호화(AES256) 및 해시 생성은 반드시 서버(JSP)에서 처리해야 합니다.

## 파일 구조

```
/(Project Root Directory)
├── .classpath                          # Eclipse 프로젝트 정보
├── .project                            # Eclipse 프로젝트 정보
├── .settings/                          # Eclipse 프로젝트 설정
├── src/
│   ├── logback.xml                     # Logback 로그 설정파일 (* 자사에 맞게 변경 필요)
│   └── com/settle/pg/
│       ├── EncryptUtil.java            # AES256 암복호화 및 SHA256 해시 유틸
│       ├── HttpClientUtil.java         # HTTP 통신 유틸
│       └── StringUtil.java             # 문자열 유틸
└── WebContent/
    ├── index.html                      # 인덱스 페이지
    ├── config.jsp                      # 기본정보 설정파일 (* 자사에 맞게 변경 필요)
    ├── pay_form.jsp                    # 결제 메인 폼
    ├── pay_encryptParams.jsp           # 파라미터 AES256 암호화 및 SHA256 해시 처리 (AJAX)
    ├── pay_receiveResult.jsp           # 결제 완료 후 응답 파라미터 수신 페이지
    ├── pay_showResult.jsp              # 결제 결과 출력 페이지
    ├── pay_autoPayResult.jsp           # 휴대폰 자동연장 결제 결과 페이지
    ├── cancel_form.jsp                 # 취소 요청 폼
    ├── cancel_showResult.jsp           # 취소 처리 및 결과 화면
    ├── receiveNoti.jsp                 # 결제/취소 완료 후 노티 수신 페이지
    ├── processNoti.jsp                 # 노티 수신 후 처리 로직
    └── WEB-INF/lib/                    # 의존성 JAR 패키지
```

## 파일 설명

### 공통 파일
- **config.jsp**: 상점아이디, 암복호화키, 서버 URL 등을 설정합니다. 운영 환경에서는 반드시 실제 값으로 교체해야 합니다.
- **EncryptUtil.java**: AES-256-ECB 암복호화(Base64 인코딩) 및 SHA-256 해시 생성 유틸 클래스입니다.
- **HttpClientUtil.java**: 헥토파이낸셜 서버와의 HTTP 통신을 처리하는 유틸 클래스입니다.
- **receiveNoti.jsp**: 결제 또는 취소 완료 후, 헥토파이낸셜 서버에서 가맹점으로 전달하는 노티(결과통보)를 수신하는 페이지입니다.
- **processNoti.jsp**: 노티 수신 후 성공/실패에 따라 가맹점 내부 로직을 처리하는 메소드를 정의한 파일입니다.

### 결제 관련 파일
- **pay_form.jsp**: 결제 요청 폼 페이지입니다. AJAX로 `pay_encryptParams.jsp`를 호출하여 민감정보를 암호화한 후 SDK를 통해 결제창을 띄웁니다.
- **pay_encryptParams.jsp**: `pay_form.jsp`에서 AJAX로 호출되며, 민감정보 AES256 암호화 및 SHA256 해시 생성을 처리합니다.
- **pay_receiveResult.jsp**: 결제창에서 결제 완료 후 응답 파라미터를 수신하는 페이지입니다.
- **pay_showResult.jsp**: `pay_receiveResult.jsp`로부터 파라미터를 전달받아 결제 결과를 출력합니다.
- **pay_autoPayResult.jsp**: 휴대폰 자동연장 결제 시 사용되는 결제 및 결과 페이지입니다.

### 취소 관련 파일
- **cancel_form.jsp**: 취소 요청 시 필요한 정보를 입력받는 폼 페이지입니다.
- **cancel_showResult.jsp**: 헥토파이낸셜과 Server to Server 통신으로 취소를 요청하고 결과를 출력합니다.

## 페이지 처리 순서

| 기능 | 순서 |
|------|------|
| 결제 | pay_form.jsp → pay_encryptParams.jsp(AJAX) → pay_receiveResult.jsp → pay_showResult.jsp |
| 휴대폰 자동연장 결제 | pay_form.jsp → pay_autoPayResult.jsp |
| 취소 | cancel_form.jsp → cancel_showResult.jsp |
| 노티 | receiveNoti.jsp → processNoti.jsp |

## config.jsp 설정 변수

| 변수명 | 설명 |
|--------|------|
| `PG_MID` | 상점아이디. 테스트용 MID는 소스에 기재되어 있습니다. 운영 시 헥토파이낸셜에서 발급한 MID로 교체하세요. **외부 노출 금지** |
| `LICENSE_KEY` | MID당 1개 발급되는 라이센스키. SHA256 해시 생성에 사용됩니다. **외부 노출 금지** |
| `AES256_KEY` | 개인정보/민감정보 AES256 암복호화에 사용되는 키. **외부 노출 금지** |
| `PAYMENT_SERVER` | 헥토파이낸셜 결제창 서버 URL. 테스트/운영 서버 주석을 전환하여 사용합니다. |
| `CANCEL_SERVER` | 헥토파이낸셜 취소 API 서버 URL. 테스트/운영 서버 주석을 전환하여 사용합니다. |
| `CONN_TIMEOUT` | HTTP 연결 타임아웃 (밀리초) |
| `READ_TIMEOUT` | HTTP 수신 타임아웃 (밀리초) |

## 노티(Noti) 수신

결제 또는 취소 완료 후 헥토파이낸셜 서버에서 가맹점의 `receiveNoti.jsp`를 콜백 호출합니다.

- `nextUrl`(결과 페이지): 고객에게 결제 성공/실패 결과 화면을 반환합니다.
- `notiUrl`(노티 수신 페이지): 가맹점 내부 데이터/DB를 처리합니다.
- 처리 완료 시 `"OK"`, 실패 시 `"FAIL"` 반환 (FAIL 반환 시 설정된 횟수만큼 재전송).

## 테스트 환경

- 결제창 테스트 서버: `https://tbnpg.settlebank.co.kr`
- 취소 API 테스트 서버: `https://tbgw.settlebank.co.kr`
- 테스트 MID 및 키 정보는 개발자 문서를 참고하세요.
- 테스트 환경에서는 **실제 카드번호 사용을 금지**합니다.

## 문의

- 기술 문의: [헥토파이낸셜 개발자 센터](https://developers.hectofinancial.co.kr)
- 가맹점 문의: 1688-5130
