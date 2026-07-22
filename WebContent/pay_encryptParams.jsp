<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@ page import="net.sf.json.JSONObject"%>
<%@page import="org.slf4j.Logger"%>
<%@page import="org.slf4j.LoggerFactory"%>
<%@ page import="com.settle.pg.StringUtil"%>
<%@ page import="com.settle.pg.EncryptUtil"%>
<%@ include file="config.jsp" %>
<%
/** ============================================================================================
 *  [운영 적용 시 필수 확인]
 *  이 페이지는 결제 요청 파라미터의 SHA256 해시와 AES256 암호문을 생성해 반환하는 샘플입니다.
 *
 *  1. 이 페이지를 인증(로그인 세션 등) 없이 외부에 노출하지 마십시오.
 *     인증 없이 노출되면 누구나 임의 금액에 대한 유효한 pktHash를 얻을 수 있어
 *     해시의 목적인 거래금액 위변조 방지가 무력화됩니다.
 *  2. 거래금액(plainTrdAmt)을 요청 파라미터로 받아 그대로 해시하는 것은 테스트 편의를 위한
 *     구성입니다. 운영에서는 가맹점 서버에 저장된 주문 정보에서 금액을 조회하여 해시를
 *     생성하고, 클라이언트가 전달한 금액은 신뢰하지 마십시오.
 *  ============================================================================================ */

/** 로거 얻기 */
Logger logger = LoggerFactory.getLogger("trans");

/** 설정 정보 얻기 */
String licenseKey = LICENSE_KEY;
String aesKey = AES256_KEY;

/** 해쉬 및 aes256암호화 후 리턴 될 json */
JSONObject rsp = new JSONObject();

/** SHA256 해쉬 파라미터 */
String mchtId       = StringUtil.isNull(request.getParameter("mchtId"));
String method       = StringUtil.isNull(request.getParameter("method"));
String mchtTrdNo    = StringUtil.isNull(request.getParameter("mchtTrdNo"));
String trdDt        = StringUtil.isNull(request.getParameter("trdDt"));
String trdTm        = StringUtil.isNull(request.getParameter("trdTm"));
String trdAmt       = StringUtil.isNull(request.getParameter("plainTrdAmt"));

/** AES256 암호화 파라미터 */
HashMap<String,String> params = new HashMap<String, String>();
params.put("trdAmt",            trdAmt);
params.put("mchtCustNm",        StringUtil.isNull(request.getParameter("plainMchtCustNm")));
params.put("cphoneNo",          StringUtil.isNull(request.getParameter("plainCphoneNo")));
params.put("email",             StringUtil.isNull(request.getParameter("plainEmail")));
params.put("mchtCustId",        StringUtil.isNull(request.getParameter("plainMchtCustId")));
params.put("taxAmt",            StringUtil.isNull(request.getParameter("plainTaxAmt")));
params.put("vatAmt",            StringUtil.isNull(request.getParameter("plainVatAmt")));
params.put("taxFreeAmt",        StringUtil.isNull(request.getParameter("plainTaxFreeAmt")));
params.put("svcAmt",            StringUtil.isNull(request.getParameter("plainSvcAmt")));
params.put("clipCustNm",        StringUtil.isNull(request.getParameter("plainClipCustNm")));
params.put("clipCustCi",        StringUtil.isNull(request.getParameter("plainClipCustCi")));
params.put("clipCustPhoneNo",   StringUtil.isNull(request.getParameter("plainClipCustPhoneNo")));


/*============================================================================================================================================
 *  SHA256 해쉬 처리
 *조합 필드 : 상점아이디 + 결제수단 + 상점주문번호 + 요청일자 + 요청시간 + 거래금액(평문) + 라이센스키
 *============================================================================================================================================*/
String hashPlain = String.format("%s%s%s%s%s%s%s", mchtId, method, mchtTrdNo, trdDt, trdTm, trdAmt, licenseKey);
String hashCipher ="";
/** SHA256 해쉬 처리 */
try{
    hashCipher = EncryptUtil.digestSHA256(hashPlain);//해쉬 값
}catch(Exception e){
    logger.error("["+mchtTrdNo+"][SHA256 HASHING] Hashing Fail! : " + e.toString());
    throw e;
}finally{
    //[주의] hashPlain에는 라이센스키가 평문으로 포함됩니다. 운영 적용 시 이 로그를 제거하거나 키 부분을 마스킹하십시오.
    logger.info("["+mchtTrdNo+"][SHA256 HASHING] Plain Text["+hashPlain+"] ---> Cipher Text["+hashCipher+"]");
    rsp.put("hashCipher", hashCipher); // sha256 해쉬 결과 저장
}

/*============================================================================================================================================
 *  AES256 암호화 처리(AES-256-ECB encrypt -> Base64 encoding)
 *============================================================================================================================================ */
try{
    for (Map.Entry<String, String> entry : params.entrySet()) {
        String key   = entry.getKey();
        String value =  entry.getValue();
        
        String aesPlain = params.get(key);
        if( !("".equals(aesPlain))){
            byte[] aesCipherRaw = EncryptUtil.aes256EncryptEcb(aesKey, aesPlain);
            String aesCipher = EncryptUtil.encodeBase64(aesCipherRaw);
            
            params.put(key, aesCipher);//암호화된 데이터로 세팅
            logger.info("["+mchtTrdNo+"][AES256 Encrypt] "+key+"["+aesPlain+"] ---> ["+aesCipher+"]");
        }
    }

}catch(Exception e){
    logger.error("["+mchtTrdNo+"][AES256 Encrypt] AES256 Fail! : " + e.toString());
    throw e;
}finally{
    JSONObject encParams = JSONObject.fromObject(params); //aes256 암호화 결과 저장
    rsp.put("encParams", encParams);
}
/* 결과 리턴 */
out.println(rsp);













%>