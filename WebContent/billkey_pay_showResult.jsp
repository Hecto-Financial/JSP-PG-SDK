<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.settle.pg.HttpClientUtil"%>
<%@ page import="com.settle.pg.EncryptUtil"%>
<%@ page import="com.settle.pg.StringUtil"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>
<%@ page import="org.slf4j.Logger"%>
<%@ page import="org.slf4j.LoggerFactory"%>
<%@ page import="net.sf.json.JSONObject"%>
<%@ include file="config.jsp" %>
<%@ include file="escapeUtil.jsp" %>
<% request.setCharacterEncoding("UTF-8");%>
<%
/**
 * 신용카드 빌키 결제 API 결과 처리 (2회차 결제)
 * - 호출 경로: /spay/APICardActionPay.do (게이트웨이, JSON, UI 없음 / 서버 간 통신)
 * - 빌키 결제 전용 샘플입니다. 카드번호 직접 입력(수기결제)은 지원하지 않습니다.
 */
Logger logger = LoggerFactory.getLogger("trans");

String aesKey = AES256_KEY;         //AES256 암복호화 키
String licenseKey = LICENSE_KEY;    //라이센스 키
// 게이트웨이(API) 서버 = 취소/빌키결제 공통 호스트 (테스트 tbgw / 운영 gw)
String serverURL = CANCEL_SERVER;
int connTimeout = CONN_TIMEOUT;
int readTimeout = READ_TIMEOUT;

//요청 파라미터(헤더)
Map<String,String> REQ_HEADER = new LinkedHashMap<String,String>();
REQ_HEADER.put("mchtId",    StringUtil.isNull(request.getParameter("mchtId")));     //상점아이디
REQ_HEADER.put("ver",       StringUtil.isNull(request.getParameter("ver")));        //버전
REQ_HEADER.put("method",    StringUtil.isNull(request.getParameter("method")));     //결제수단(CA)
REQ_HEADER.put("bizType",   StringUtil.isNull(request.getParameter("bizType")));    //업무구분(B0)
REQ_HEADER.put("encCd",     StringUtil.isNull(request.getParameter("encCd")));      //암호화구분
REQ_HEADER.put("mchtTrdNo", StringUtil.isNull(request.getParameter("mchtTrdNo")));  //상점주문번호
REQ_HEADER.put("trdDt",     StringUtil.isNull(request.getParameter("trdDt")));      //요청일자
REQ_HEADER.put("trdTm",     StringUtil.isNull(request.getParameter("trdTm")));      //요청시간
REQ_HEADER.put("mobileYn",  StringUtil.isNull(request.getParameter("mobileYn")));   //모바일여부
REQ_HEADER.put("osType",    StringUtil.isNull(request.getParameter("osType")));     //운영체제구분

//요청 파라미터(바디) - 빌키 결제 전용(카드번호 등 수기 입력 필드 없음)
Map<String,String> REQ_BODY = new LinkedHashMap<String,String>();
REQ_BODY.put("pktHash",     StringUtil.isNull(request.getParameter("pktHash")));        //해쉬값
REQ_BODY.put("pmtprdNm",    StringUtil.isNull(request.getParameter("pmtprdNm")));       //상품명
REQ_BODY.put("mchtCustNm",  StringUtil.isNull(request.getParameter("mchtCustNm")));     //상점고객명
REQ_BODY.put("mchtCustId",  StringUtil.isNull(request.getParameter("mchtCustId")));     //상점고객아이디
REQ_BODY.put("email",       StringUtil.isNull(request.getParameter("email")));          //이메일
REQ_BODY.put("billKey",     StringUtil.isNull(request.getParameter("billKey")));        //빌키
REQ_BODY.put("instmtMon",   StringUtil.isNull(request.getParameter("instmtMon")));      //할부개월수
REQ_BODY.put("crcCd",       StringUtil.isNull(request.getParameter("crcCd")));          //통화구분
REQ_BODY.put("taxTypeCd",   StringUtil.isNull(request.getParameter("taxTypeCd")));      //세금유형
REQ_BODY.put("trdAmt",      StringUtil.isNull(request.getParameter("trdAmt")));         //거래금액
REQ_BODY.put("taxAmt",      StringUtil.isNull(request.getParameter("taxAmt")));         //과세금액
REQ_BODY.put("vatAmt",      StringUtil.isNull(request.getParameter("vatAmt")));         //부가세금액
REQ_BODY.put("taxFreeAmt",  StringUtil.isNull(request.getParameter("taxFreeAmt")));     //비과세금액
REQ_BODY.put("svcAmt",      StringUtil.isNull(request.getParameter("svcAmt")));         //봉사료
REQ_BODY.put("notiUrl",     StringUtil.isNull(request.getParameter("notiUrl")));        //결과처리URL
REQ_BODY.put("mchtParam",   StringUtil.isNull(request.getParameter("mchtParam")));      //기타주문정보

//응답 파라미터(헤더)
Map<String,String> RES_HEADER = new LinkedHashMap<String,String>();
RES_HEADER.put("mchtId", "");
RES_HEADER.put("ver", "");
RES_HEADER.put("method", "");
RES_HEADER.put("bizType", "");
RES_HEADER.put("encCd", "");
RES_HEADER.put("mchtTrdNo", "");
RES_HEADER.put("trdNo", "");
RES_HEADER.put("trdDt", "");
RES_HEADER.put("trdTm", "");
RES_HEADER.put("outStatCd", "");
RES_HEADER.put("outRsltCd", "");
RES_HEADER.put("outRsltMsg", "");

//응답 파라미터(바디)
Map<String,String> RES_BODY = new LinkedHashMap<String,String>();
RES_BODY.put("pktHash", "");
RES_BODY.put("trdAmt", "");
RES_BODY.put("billKey", "");
RES_BODY.put("cardNo", "");         //마스킹된 카드번호(사전 협의 가맹점 한정)
RES_BODY.put("vldDtMon", "");
RES_BODY.put("vldDtYear", "");
RES_BODY.put("issrId", "");
RES_BODY.put("cardNm", "");
RES_BODY.put("cardKind", "");
RES_BODY.put("ninstmtTypeCd", "");
RES_BODY.put("instmtMon", "");
RES_BODY.put("apprNo", "");

//AES256 암호화 필요 파라미터(요청) - 금액 항목만
String[] ENCRYPT_PARAMS = {"trdAmt", "taxAmt", "vatAmt", "taxFreeAmt", "svcAmt"};
//AES256 복호화 필요 파라미터(응답)
String[] DECRYPT_PARAMS = {"trdAmt"};

/** ===============================================================================================
 *   SHA256 해쉬 처리
 *   조합필드 : 거래일자 + 거래시간 + 상점아이디 + 상점거래번호 + 거래금액(평문) + 라이센스키
 *  =============================================================================================== */
String hashPlain="";
String hashCipher="";
try{
    hashPlain = String.format("%s%s%s%s%s%s"
              ,REQ_HEADER.get("trdDt")
              ,REQ_HEADER.get("trdTm")
              ,REQ_HEADER.get("mchtId")
              ,REQ_HEADER.get("mchtTrdNo")
              ,REQ_BODY.get("trdAmt")
              ,licenseKey);
    hashCipher = EncryptUtil.digestSHA256(hashPlain);
}catch(Exception e){
    logger.error("["+REQ_HEADER.get("mchtTrdNo")+"][SHA256 HASHING] Hashing Fail! : " + e.toString());
}finally{
    REQ_BODY.put("pktHash", hashCipher);
}

/** AES256 암호화 처리 */
try{
    for(int i=0; i < ENCRYPT_PARAMS.length; i++){
        String aesPlain = REQ_BODY.get(ENCRYPT_PARAMS[i]);
        if( !("".equals(aesPlain))){
            byte[] aesCipherRaw = EncryptUtil.aes256EncryptEcb(aesKey, aesPlain);
            REQ_BODY.put(ENCRYPT_PARAMS[i], EncryptUtil.encodeBase64(aesCipherRaw));
        }
    }
}catch(Exception e){
    logger.error("[" + REQ_HEADER.get("mchtTrdNo") + "][AES256 Encrypt] Fail! : " + e.toString());
}

//URL설정
String requestUrl = serverURL + "/spay/APICardActionPay.do";

//요청파라미터 세팅 (params, data 이름은 변경 금지)
Map<String,Object> reqParam = new HashMap<String,Object>();
reqParam.put("params", REQ_HEADER );
reqParam.put("data", REQ_BODY);

/** API호출(가맹점->헥토파이낸셜) 및 응답 처리 */
Map<String, String> respParam = new HashMap<String, String>();
try{
    HttpClientUtil httpClientUtil = new HttpClientUtil();
    String resData = httpClientUtil.sendApi(requestUrl, reqParam, connTimeout, readTimeout);

    JSONObject resp = JSONObject.fromObject(resData);
    JSONObject respHeader = resp.has("params")? resp.getJSONObject("params") : null;
    JSONObject respBody =  resp.has("data")? resp.getJSONObject("data") : null;

    if( respHeader != null ){
        for (String key : RES_HEADER.keySet()) {
            respParam.put(key, StringUtil.isNull( respHeader.has(key)? respHeader.getString(key) : ""));
        }
    }else{
        for (String key : RES_HEADER.keySet()) respParam.put(key, "");
    }
    if( respBody != null){
        for (String key : RES_BODY.keySet()) {
            respParam.put(key, StringUtil.isNull( respBody.has(key)? respBody.getString(key) : ""));
        }
    }else{
        for (String key : RES_BODY.keySet()) respParam.put(key, "");
    }
}catch (Exception e){
    respParam.put("outStatCd", "0031");
    respParam.put("outRsltCd", "9999");
    respParam.put("outRsltMsg", "[Response Parsing Error]" + e.toString());
    logger.error("["+REQ_HEADER.get("mchtTrdNo")+"][Response Parsing Error]" + e.toString());
}

/** AES256 복호화 처리 */
try{
    for(int i=0; i< DECRYPT_PARAMS.length; i++){
        if( respParam.containsKey(DECRYPT_PARAMS[i]) ){
            String aesCipher = (respParam.get(DECRYPT_PARAMS[i])).trim();
            if( !("".equals(aesCipher))){
                byte[] aesCipherRaw = EncryptUtil.decodeBase64(aesCipher);
                String aesPlain = new String(EncryptUtil.aes256DecryptEcb(aesKey, aesCipherRaw), "UTF-8");
                respParam.put(DECRYPT_PARAMS[i], aesPlain);
            }
        }
    }
}catch(Exception e){
    logger.error("[" + REQ_HEADER.get("mchtTrdNo") + "][AES256 Decrypt] Fail! : " + e.toString());
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>헥토파이낸셜</title>
<style type="text/css">
#STPG_RSLT      {font-family:굴림; font-size:10pt;}
#STPG_RSLT h4   {background-color:#f1f1f1; padding:4px; margin:2px;}
</style>
</head>
<body>
<h3>빌키 결제 응답 결과</h3>
<div id="STPG_RSLT">
    <table>
        <tr><td colspan="2" style="text-align:center;"><h4>params</h4></td></tr>
        <tr><td>mchtId[상점아이디]</td><td><%= escapeHtml(respParam.get("mchtId")) %></td></tr>
        <tr><td>ver[버전]</td><td><%= escapeHtml(respParam.get("ver")) %></td></tr>
        <tr><td>method[결제수단]</td><td><%= escapeHtml(respParam.get("method")) %></td></tr>
        <tr><td>bizType[업무구분]</td><td><%= escapeHtml(respParam.get("bizType")) %></td></tr>
        <tr><td>encCd[암호화구분]</td><td><%= escapeHtml(respParam.get("encCd")) %></td></tr>
        <tr><td>mchtTrdNo[상점주문번호]</td><td><%= escapeHtml(respParam.get("mchtTrdNo")) %></td></tr>
        <tr><td>trdNo[헥토파이낸셜 거래번호]</td><td><%= escapeHtml(respParam.get("trdNo")) %></td></tr>
        <tr><td>trdDt[요청일자]</td><td><%= escapeHtml(respParam.get("trdDt")) %></td></tr>
        <tr><td>trdTm[요청시간]</td><td><%= escapeHtml(respParam.get("trdTm")) %></td></tr>
        <tr><td>outStatCd[거래상태코드]</td><td><%= escapeHtml(respParam.get("outStatCd")) %></td></tr>
        <tr><td>outRsltCd[거래결과코드]</td><td><%= escapeHtml(respParam.get("outRsltCd")) %></td></tr>
        <tr><td>outRsltMsg[결과메세지]</td><td><%= escapeHtml(respParam.get("outRsltMsg")) %></td></tr>
        <tr><td colspan="2" style="text-align:center;"><h4>data</h4></td></tr>
        <tr><td>pktHash[해쉬값]</td><td><%= escapeHtml(respParam.get("pktHash")) %></td></tr>
        <tr><td>trdAmt[거래금액]</td><td><%= escapeHtml(respParam.get("trdAmt")) %></td></tr>
        <tr><td>cardNo[카드번호(마스킹)]</td><td><%= escapeHtml(respParam.get("cardNo")) %></td></tr>
        <tr><td>vldDtYear[유효기간(년)]</td><td><%= escapeHtml(respParam.get("vldDtYear")) %></td></tr>
        <tr><td>vldDtMon[유효기간(월)]</td><td><%= escapeHtml(respParam.get("vldDtMon")) %></td></tr>
        <tr><td>issrId[발급사아이디]</td><td><%= escapeHtml(respParam.get("issrId")) %></td></tr>
        <tr><td>cardNm[카드사명]</td><td><%= escapeHtml(respParam.get("cardNm")) %></td></tr>
        <tr><td>cardKind[카드종류명]</td><td><%= escapeHtml(respParam.get("cardKind")) %></td></tr>
        <tr><td>ninstmtTypeCd[무이자할부타입]</td><td><%= escapeHtml(respParam.get("ninstmtTypeCd")) %></td></tr>
        <tr><td>instmtMon[할부개월수]</td><td><%= escapeHtml(respParam.get("instmtMon")) %></td></tr>
        <tr><td>apprNo[승인번호]</td><td><%= escapeHtml(respParam.get("apprNo")) %></td></tr>
        <tr style="background-color:yellow;"><td>billKey[빌키]</td><td><%= escapeHtml(respParam.get("billKey")) %></td></tr>
        <tr>
            <td colspan="2" style="text-align:center;">
                <input type="button" value="돌아가기" style="margin-top:20px;" onclick="location.href='billkey_pay_form.jsp'">
            </td>
        </tr>
    </table>
</div>
</body>
</html>
