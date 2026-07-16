<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="net.sf.json.JSONObject"%>
<%@ page import="com.settle.pg.EncryptUtil"%>
<%@ page import="com.settle.pg.StringUtil"%>
<%@ page import="org.slf4j.Logger"%>
<%@ page import="org.slf4j.LoggerFactory"%>
<%@ include file="config.jsp" %>
<%@ include file="escapeUtil.jsp" %>
<% request.setCharacterEncoding("utf-8"); %>
<%
/** 로거 얻기 */
Logger logger = LoggerFactory.getLogger("trans");

/** 설정 정보 저장 */
String aesKey = AES256_KEY;


/** 응답 파라미터 세팅 */
Map<String,String> RES_PARAMS = new LinkedHashMap<String,String>();
RES_PARAMS.put("mchtId",            StringUtil.isNull(request.getParameter("mchtId")));             //상점아이디
RES_PARAMS.put("outStatCd",         StringUtil.isNull(request.getParameter("outStatCd")));          //결과코드
RES_PARAMS.put("outRsltCd",         StringUtil.isNull(request.getParameter("outRsltCd")));          //거절코드
RES_PARAMS.put("outRsltMsg",        StringUtil.isNull(request.getParameter("outRsltMsg")));         //결과메세지
RES_PARAMS.put("method",            StringUtil.isNull(request.getParameter("method")));             //결제수단
RES_PARAMS.put("mchtTrdNo",         StringUtil.isNull(request.getParameter("mchtTrdNo")));          //상점주문번호
RES_PARAMS.put("mchtCustId",        StringUtil.isNull(request.getParameter("mchtCustId")));         //상점고객아이디
RES_PARAMS.put("trdNo",             StringUtil.isNull(request.getParameter("trdNo")));              //세틀뱅크 거래번호
RES_PARAMS.put("trdAmt",            StringUtil.isNull(request.getParameter("trdAmt")));             //거래금액
RES_PARAMS.put("mchtParam",         StringUtil.isNull(request.getParameter("mchtParam")));          //상점 예약필드
RES_PARAMS.put("authDt",            StringUtil.isNull(request.getParameter("authDt")));             //승인일시
RES_PARAMS.put("authNo",            StringUtil.isNull(request.getParameter("authNo")));             //승인번호
RES_PARAMS.put("reqIssueDt",     	StringUtil.isNull(request.getParameter("reqIssueDt")));       	//채번요청일시
RES_PARAMS.put("intMon",            StringUtil.isNull(request.getParameter("intMon")));             //할부개월수
RES_PARAMS.put("fnNm",              StringUtil.isNull(request.getParameter("fnNm")));               //카드사명
RES_PARAMS.put("fnCd",              StringUtil.isNull(request.getParameter("fnCd")));               //카드사코드
RES_PARAMS.put("pointTrdNo",        StringUtil.isNull(request.getParameter("pointTrdNo")));         //포인트거래번호
RES_PARAMS.put("pointTrdAmt",       StringUtil.isNull(request.getParameter("pointTrdAmt")));        //포인트거래금액
RES_PARAMS.put("cardTrdAmt",        StringUtil.isNull(request.getParameter("cardTrdAmt")));         //신용카드결제금액
RES_PARAMS.put("vtlAcntNo",         StringUtil.isNull(request.getParameter("vtlAcntNo")));          //가상계좌번호
RES_PARAMS.put("expireDt",          StringUtil.isNull(request.getParameter("expireDt")));           //입금기한
RES_PARAMS.put("cphoneNo",          StringUtil.isNull(request.getParameter("cphoneNo")));           //휴대폰번호
RES_PARAMS.put("billKey",           StringUtil.isNull(request.getParameter("billKey")));            //자동결제키
RES_PARAMS.put("csrcAmt",           StringUtil.isNull(request.getParameter("csrcAmt")));            //현금영수증 발급 금액(네이버페이)


//AES256 복호화 필요 파라미터
String[] DECRYPT_PARAMS = {"mchtCustId", "trdAmt", "pointTrdAmt", "cardTrdAmt", "vtlAcntNo", "cphoneNo", "csrcAmt"};




/** ======================================================================
        AES256 복호화 처리(Base64 decoding -> AES-256-ECB decrypt )
    ======================================================================   */
try{
    for(int i=0; i < DECRYPT_PARAMS.length; i++){
        if( RES_PARAMS.containsKey(DECRYPT_PARAMS[i]) ){
            String aesCipher = (RES_PARAMS.get(DECRYPT_PARAMS[i])).trim();
            if( !("".equals(aesCipher))){
                byte[] aesCipherRaw = EncryptUtil.decodeBase64(aesCipher);
                String aesPlain = new String(EncryptUtil.aes256DecryptEcb(aesKey, aesCipherRaw), "UTF-8");
                
                RES_PARAMS.put(DECRYPT_PARAMS[i], aesPlain);//복호화된 데이터로 세팅
                logger.info("["+RES_PARAMS.get("mchtTrdNo")+"][AES256 Decrypt] "+DECRYPT_PARAMS[i]+"["+aesCipher+"] ---> ["+aesPlain+"]");
            }
        }
    }
}catch(Exception e){
    logger.error("[" + RES_PARAMS.get("mchtTrdNo") + "][AES256 Decrypt] AES256 Decrypt Fail! : " + e.toString());
}

//응답 파라미터 로깅
StringBuffer logStr = new StringBuffer();
logStr.append("["+RES_PARAMS.get("mchtTrdNo")+"][Response Data] ");
for (Map.Entry<String, String> entry : RES_PARAMS.entrySet()) {
    logStr.append(entry.getKey()+"("+entry.getValue()+") ");
}
logger.info(logStr.toString());
%>
<html>
<head>
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
<meta http-equiv="X-UA-Compatible" content="ie=edge">
<title>S'Pay 결제 결과 페이지</title>
<style type="text/css">
    body            {font-family:굴림; font-size:10pt; color:#000000; text-decoration:none;}
    font            {font-family:굴림; font-size:10pt; color:#000000; text-decoration:none;}
    td              {font-family:굴림; font-size:10pt; color:#000000; text-decoration:none; padding:3px; border:1px solid #e1e1e1;}
    .left           {padding-left:5px; width:100px;}
    .right          {padding-left:5px;}
    .wrapper        {max-width:700px;border:1px solid #e1e1e1;}
    .tab            {background-color:#f1f1f1;padding:10px 20px;border:1px solid #e1e1e1; font-weight: bold; font-size:1.1em;}
    table           {width:100%; border-collapse:collapse;}
    .button         {padding:5px 20px; border-radius:20px; border:1px solid #ccc; width:70%; margin:5px 0px; transition:0.3s; cursor:pointer;}
    .button:hover   {background-color:#aaaaaa;}
</style>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script>
//결제 결과 세팅
var _PAY_RESULT = {
        mchtId :        "<%= escapeJs(RES_PARAMS.get("mchtId")) %>",
        outStatCd :     "<%= escapeJs(RES_PARAMS.get("outStatCd")) %>",
        outRsltCd :     "<%= escapeJs(RES_PARAMS.get("outRsltCd")) %>",
        outRsltMsg :    "<%= escapeJs(RES_PARAMS.get("outRsltMsg")) %>",
        method :        "<%= escapeJs(RES_PARAMS.get("method")) %>",
        mchtTrdNo :     "<%= escapeJs(RES_PARAMS.get("mchtTrdNo")) %>",
        mchtCustId :    "<%= escapeJs(RES_PARAMS.get("mchtCustId")) %>",
        trdNo :         "<%= escapeJs(RES_PARAMS.get("trdNo")) %>",
        trdAmt :        "<%= escapeJs(RES_PARAMS.get("trdAmt")) %>",
        mchtParam :     "<%= escapeJs(RES_PARAMS.get("mchtParam")) %>",
        authDt :        "<%= escapeJs(RES_PARAMS.get("authDt")) %>",
        authNo :        "<%= escapeJs(RES_PARAMS.get("authNo")) %>",
        reqIssueDt :  	"<%= escapeJs(RES_PARAMS.get("reqIssueDt")) %>",
        intMon :        "<%= escapeJs(RES_PARAMS.get("intMon")) %>",
        fnNm :          "<%= escapeJs(RES_PARAMS.get("fnNm")) %>",
        fnCd :          "<%= escapeJs(RES_PARAMS.get("fnCd")) %>",
        pointTrdNo :    "<%= escapeJs(RES_PARAMS.get("pointTrdNo")) %>",
        pointTrdAmt :   "<%= escapeJs(RES_PARAMS.get("pointTrdAmt")) %>",
        cardTrdAmt :    "<%= escapeJs(RES_PARAMS.get("cardTrdAmt")) %>",
        vtlAcntNo :     "<%= escapeJs(RES_PARAMS.get("vtlAcntNo")) %>",
        expireDt :      "<%= escapeJs(RES_PARAMS.get("expireDt")) %>",
        cphoneNo :      "<%= escapeJs(RES_PARAMS.get("cphoneNo")) %>",
        billKey :       "<%= escapeJs(RES_PARAMS.get("billKey")) %>",
        csrcAmt :       "<%= escapeJs(RES_PARAMS.get("csrcAmt")) %>"
};

//main으로 결과 전달
function sendResult()
{
    if(top.opener){
        //팝업창
        top.opener.rstparamSet(_PAY_RESULT);
        top.opener.goResult();
        self.close();
    }
    else{//iframe
        parent.postMessage(JSON.stringify({action:"HECTO_IFRAME_CLOSE", params: _PAY_RESULT}), "*");
    }
}
</script>
</head>
<body>
<h2>승인 요청 결과</h2>
<div class="wrapper">
    <div class="tab">응답 파라미터</div>
    <table>
        <tr>
            <td class="left">mchtId</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("mchtId")) %></td>
        </tr>
        <tr>
            <td class="left">outStatCd</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("outStatCd")) %></td>
        </tr>
        <tr>
            <td class="left">outRsltCd</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("outRsltCd")) %></td>
        </tr>
        <tr>
            <td class="left">outRsltMsg</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("outRsltMsg")) %></td>
        </tr>
        <tr>
            <td class="left">method</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("method")) %></td>
        </tr>
        <tr>
            <td class="left">mchtTrdNo</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("mchtTrdNo")) %></td>
        </tr>
        <tr>
            <td class="left">mchtCustId</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("mchtCustId")) %></td>
        </tr>
        <tr>
            <td class="left">trdNo</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("trdNo")) %></td>
        </tr>
        <tr>
            <td class="left">trdAmt</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("trdAmt")) %></td>
        </tr>
        <tr>
            <td class="left">mchtParam</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("mchtParam")) %></td>
        </tr>
        <tr>
            <td class="left">authDt</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("authDt")) %></td>
        </tr>
        <tr>
            <td class="left">authNo</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("authNo")) %></td>
        </tr>
        <tr>
            <td class="left">reqIssueDt</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("reqIssueDt")) %></td>
        </tr>
        <tr>
            <td class="left">intMon</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("intMon")) %></td>
        </tr>
        <tr>
            <td class="left">fnNm</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("fnNm")) %></td>
        </tr>
        <tr>
            <td class="left">fnCd</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("fnCd")) %></td>
        </tr>
        <tr>
            <td class="left">pointTrdNo</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("pointTrdNo")) %></td>
        </tr>
        <tr>
            <td class="left">pointTrdAmt</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("pointTrdAmt")) %></td>
        </tr>
        <tr>
            <td class="left">cardTrdAmt</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("cardTrdAmt")) %></td>
        </tr>
        <tr>
            <td class="left">vtlAcntNo</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("vtlAcntNo")) %></td>
        </tr>
        <tr>
            <td class="left">expireDt</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("expireDt")) %></td>
        </tr>
        <tr>
            <td class="left">cphoneNo</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("cphoneNo")) %></td>
        </tr>
        <tr>
            <td class="left">billKey</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("billKey")) %></td>
        </tr>
        <tr>
            <td class="left">csrcAmt</td>
            <td class="right"><%= escapeHtml(RES_PARAMS.get("csrcAmt")) %></td>
        </tr>

        <tr>
            <td colspan="2" style="text-align: center;">
                <input class="button" type="button" value="확인" onclick="sendResult()" /> 
            </td>
        </tr>
    </table>
</div>
</body>
</html>