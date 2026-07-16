# JSP-PG-SDK

헥토파이낸셜 PG 연동을 위한 JSP 샘플 코드입니다.

## ⚠️ 샘플 사용 시 주의사항

> 이 저장소는 연동 방법을 설명하는 참고용 샘플이며 운영용 완성 모듈이 아닙니다.
> 인증·인가, 입력값 검증, CSRF 방어, 키 관리, 로그 마스킹은 실제 운영 환경의
> 정책에 맞게 가맹점에서 구현해야 합니다.

- 샘플 JSP를 인터넷에 그대로 노출하거나 운영 서비스에 그대로 배포하지 마십시오.
- 취소 및 자동결제 API에는 가맹점의 인증·권한·CSRF 보호를 적용하십시오.
- `pay_encryptParams.jsp`는 해시·암호문을 생성해 반환하는 페이지이므로 인증 없이
  외부에 노출하면 누구나 임의 금액에 대한 유효한 `pktHash`를 얻을 수 있어
  거래금액 위변조 방지가 무력화됩니다. 운영에서는 로그인 세션 등으로 접근을
  보호하고, 거래금액은 클라이언트 전달 값이 아닌 가맹점 서버에 저장된 주문
  정보에서 조회하여 해시를 생성하십시오.
- 테스트 MID와 테스트 키는 운영에 사용할 수 없습니다. 운영 키를 소스 저장소에
  커밋하지 말고 가맹점의 안전한 설정 관리 방식을 적용하십시오.
- 샘플에는 연동 확인을 위한 요청·응답 및 암호화 대상 값 로그가 포함되어 있습니다.
  특히 SHA256 해시 로그의 평문(`hashPlain`)에는 **라이센스키가 평문으로 포함**되어
  매 거래마다 로그 파일에 기록됩니다. 운영 적용 전 해당 로그를 제거하거나
  키 부분을 마스킹하고, 개인정보와 결제정보도 제거하거나 마스킹하십시오.
- 결과 출력 JSP는 연동 결과를 확인하기 위한 샘플 화면이며, `escapeUtil.jsp`의
  `escapeHtml`/`escapeJs`로 출력 인코딩을 적용해 두었습니다. 화면을 수정하거나
  새로 작성할 때에도 출력 위치(HTML/JavaScript)에 맞는 인코딩을 유지하십시오.

## 🔒 TLS 보안

`HttpClientUtil`은 JRE 기본 TrustStore로 서버 인증서 체인을 검증하고
`HttpsURLConnection`의 기본 호스트명 검증을 유지합니다. 모든 인증서나 호스트명을
신뢰하는 우회 설정은 사용하지 않으며, `Tls12OrHigherSocketFactory`를 통해
TLS 1.2 이상 프로토콜만 활성화합니다.

## 파일 구조

```
/(Project Root Directory)
│  .classpath		<--- eclipse 프로젝트 정보
│  .project		<--- eclipse 프로젝트 정보
├─.settings		<--- eclipse 프로젝트 정보
├─src
│  │  logback.xml		<--- logback 설정파일(*자사에 맞게 변경 필요)
│  │
│  └─com
│      └─settle
│          └─pg
│                  EncryptUtil.java	<--- 암호화 유틸
│                  HttpClientUtil.java	<--- HTTP 커넥션 유틸
│                  StringUtil.java	<--- 문자열 유틸
│                  Tls12OrHigherSocketFactory.java <--- TLS 1.2 이상 통신 설정
│
└─WebContent
     |   
    │  index.html			<--- index페이지
    │  config.jsp			<--- 기본정보 설정파일(*자사에 맞게 변경 필요)
    │  escapeUtil.jsp		<--- HTML/JavaScript 출력 인코딩 유틸
     |   
    │  pay_form.jsp		<--- 결제시 메인 폼
    │  pay_encryptParams.jsp	<--- 결제시 파라미터 암호화 및 해쉬 처리 페이지
     |   pay_autoPayResult.jsp		<--- 휴대폰 자동연장결제시 사용되는 페이지
    │  pay_receiveResult.jsp		<--- 결제 완료 후 응답파라미터 수신페이지
    │  pay_showResult.jsp		<--- 자식페이지에서 전달된 응답파라미터 출력
     |   
    │  cancel_form.jsp		<--- 취소 메인 폼
    │  cancel_showResult.jsp		<--- 취소 처리 및 결과 화면
     |   
    │  receiveNoti.jsp		<--- 결제 완료 후 노티 수신 페이지
    │  processNoti.jsp		<--- 노티 수신 후 처리하는 페이지
     |   
    └─WEB-INF
        └─lib			<--- 의종성 jar패키지 위치
```

## 📄 파일 설명

### 🔧 공통 페이지
- **index.html**: 인덱스 페이지입니다.
- **config.jsp**: 상점아이디, 암복호화키 등을 설정할 수 있는 설정 파일입니다.
- **escapeUtil.jsp**: 요청·응답 파라미터를 화면에 출력할 때 사용하는 HTML/JavaScript 이스케이프 유틸입니다. 결과 출력 JSP에서 include하여 사용합니다.
- **receiveNoti.jsp**: 결제 또는 취소 처리가 완료된 후, 헥토파이낸셜에서 가맹점으로 전달하는 노티(결과통보)를 수신하는 페이지입니다.
- **processNoti.jsp**: receiveNoti.jsp에서 결제 또는 취소의 성공/실패에 따라 적절한 로직을 수행하는 메소드를 정의한 파일입니다.

### 💳 결제 관련 페이지
- **pay_form.jsp**: 결제 요청 시 사용자로부터 정보를 입력받는 Form 페이지입니다. 결제는 Form POST 방식으로 처리됩니다.
- **pay_encryptParams.jsp**: pay_form.jsp에서 암호화가 필요한 파라미터들을 AJAX 통신으로 암호화하는 페이지입니다. 또한 SHA256 해시 처리도 수행합니다.
- **pay_receiveResult.jsp**: 결제창에서 결제가 완료된 이후 닫기 버튼을 누를 때, 헥토파이낸셜로부터 응답 파라미터를 수신하는 페이지입니다.
- **pay_showResult.jsp**: pay_receiveResult.jsp에서 받은 파라미터를 부모창으로 전송할 수 있는데, 이때 전송된 파라미터들을 수신하여 출력하는 페이지입니다.
- **pay_autoPayResult.jsp**: 휴대폰 자동연장결제 시 사용되는 결제 및 결과화면 페이지입니다.

### ❌ 취소 관련 페이지
- **cancel_form.jsp**: 취소 요청 시 사용자로부터 정보를 입력받는 Form 페이지입니다.
- **cancel_showResult.jsp**: 헥토파이낸셜과 Server to Server로 커넥션하여, 취소 요청을 하고 응답을 받아 결과를 출력하는 페이지입니다.

## 🔄 프로세스 처리 순서

- **결제 처리 순서**: pay_form.jsp → pay_encryptParams.jsp → pay_receiveResult.jsp → pay_showResult.jsp
- **휴대폰 자동연장 결제**: pay_form.jsp → pay_autoPayResult.jsp
- **취소 처리 순서**: cancel_form.jsp → cancel_showResult.jsp
- **노티 처리 순서**: receiveNoti.jsp → processNoti.jsp

## ⚙️ config.jsp 설정 파일 변수 설명

- **PG_MID**: 상점아이디. 테스트환경에서의 상점아이디는 샘플소스에 기재되어 있습니다. 상용테스트 시에는 헥토파이낸셜에서 발급한 MID로 설정하셔야 합니다. 이 값은 외부에 노출되어서는 안됩니다.
- **LICENSE_KEY**: MID당 하나의 라이센스키가 발급됩니다. SHA256 해시체크 용도로 사용됩니다. 이 값은 외부에 노출되어서는 안됩니다.
- **AES256_KEY**: 개인정보/민감정보를 암복호화하는데 사용되는 키로서, 외부에 노출되어서는 안됩니다.
- **PAYMENT_SERVER**: 헥토파이낸셜 결제 처리 서버의 URL입니다. 변경하지 마십시오.
- **CANCEL_SERVER**: 헥토파이낸셜 취소 처리 서버의 URL입니다. 변경하지 마십시오.
- **CONN_TIMEOUT**: 헥토파이낸셜 API 통신 연결 타임아웃입니다.
- **READ_TIMEOUT**: 헥토파이낸셜 API 통신 수신 타임아웃입니다.

## 📢 노티 수신 페이지

- **파일명**: receiveNoti.jsp
- 결제 또는 취소 완료 후 헥토파이낸셜 서버에서 콜백으로 호출하게 되는 페이지이며, 헥토파이낸셜에서 가맹점으로 노티를 전송합니다.
- nextUrl(결과페이지)에서는 성공/실패에 대한 결과 화면을 고객에게 리턴하여 주시고,
- notiUrl(노티수신페이지)에서는 가맹점의 실제 내부데이터, DB를 처리하시면 됩니다.