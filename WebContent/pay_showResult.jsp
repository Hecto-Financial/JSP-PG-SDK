<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.settle.pg.StringUtil"%>
<%@ include file="escapeUtil.jsp" %>
<% request.setCharacterEncoding("utf-8"); %>
<%
/** 넘어온 응답 파라미터 받기 */
String mchtId           = StringUtil.isNull(request.getParameter("respMchtId"));            //상점아이디
String outStatCd        = StringUtil.isNull(request.getParameter("respOutStatCd"));         //결과코드
String outRsltCd        = StringUtil.isNull(request.getParameter("respOutRsltCd"));         //거절코드
String outRsltMsg       = StringUtil.isNull(request.getParameter("respOutRsltMsg"));        //결과메세지
String method           = StringUtil.isNull(request.getParameter("respMethod"));            //결제수단
String mchtTrdNo        = StringUtil.isNull(request.getParameter("respMchtTrdNo"));         //상점주문번호
String mchtCustId       = StringUtil.isNull(request.getParameter("respMchtCustId"));        //상점고객아이디
String trdNo            = StringUtil.isNull(request.getParameter("respTrdNo"));             //세틀뱅크 거래번호
String trdAmt           = StringUtil.isNull(request.getParameter("respTrdAmt"));            //거래금액
String mchtParam        = StringUtil.isNull(request.getParameter("respMchtParam"));         //상점예약필드
String authDt           = StringUtil.isNull(request.getParameter("respAuthDt"));            //승인일시
String authNo           = StringUtil.isNull(request.getParameter("respAuthNo"));            //승인번호
String reqIssueDt    	= StringUtil.isNull(request.getParameter("respReqIssueDt"));     	//채번요청일시
String intMon           = StringUtil.isNull(request.getParameter("respIntMon"));            //할부개월수
String fnNm             = StringUtil.isNull(request.getParameter("respFnNm"));              //카드사명
String fnCd             = StringUtil.isNull(request.getParameter("respFnCd"));              //카드사코드
String pointTrdNo       = StringUtil.isNull(request.getParameter("respPointTrdNo"));        //포인트거래번호
String pointTrdAmt      = StringUtil.isNull(request.getParameter("respPointTrdAmt"));       //포인트거래금액
String cardTrdAmt       = StringUtil.isNull(request.getParameter("respCardTrdAmt"));        //신용카드결제금액
String vtlAcntNo        = StringUtil.isNull(request.getParameter("respVtlAcntNo"));         //가상계좌번호
String expireDt         = StringUtil.isNull(request.getParameter("respExpireDt"));          //입금만료일시
String cphoneNo         = StringUtil.isNull(request.getParameter("respCphoneNo"));          //휴대폰번호
String billKey          = StringUtil.isNull(request.getParameter("respBillKey"));           //자동결제키
String csrcAmt          = StringUtil.isNull(request.getParameter("respCsrcAmt"));           //현금영수증 발급 금액(네이버페이)
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
    table           {width:100%; border-collapse:collapse;}
    .left           {padding-left:5px; width:200px;}
    .right          {padding-left:5px;}
    .wrapper        {width:700px;border:1px solid #e1e1e1;}
    .tab            {background-color:#f1f1f1;padding:10px 20px;border:1px solid #e1e1e1; font-weight: bold; font-size:1.1em;}
    .button         {padding:5px 20px; border-radius:20px; border:1px solid #ccc; width:70%; margin:5px 0px; transition:0.3s; cursor:pointer;}
    .button:hover   {background-color:#aaaaaa;}
</style>
</head>
<body>
<h2>승인 요청 결과</h2>
<div class="wrapper">
    <div class="tab">응답 파라미터</div>
    <table>
        <tr>
            <td class="left">mchtId[상점아이디]</td>
            <td class="right"><%= escapeHtml(mchtId) %></td>
        </tr>
        <tr>
            <td class="left">outStatCd[거래상태]</td>
            <td class="right"><%= escapeHtml(outStatCd) %></td>
        </tr>
        <tr>
            <td class="left">outRsltCd[거절코드]</td>
            <td class="right"><%= escapeHtml(outRsltCd) %></td>
        </tr>
        <tr>
            <td class="left">outRsltMsg[메세지]</td>
            <td class="right"><%= escapeHtml(outRsltMsg) %></td>
        </tr>
        <tr>
            <td class="left">method[결제수단]</td>
            <td class="right"><%= escapeHtml(method) %></td>
        </tr>
        <tr>
            <td class="left">mchtTrdNo[상점주문번호]</td>
            <td class="right"><%= escapeHtml(mchtTrdNo) %></td>
        </tr>
        <tr>
            <td class="left">mchtCustId[상점고객아이디]</td>
            <td class="right"><%= escapeHtml(mchtCustId) %></td>
        </tr>
        <tr>
            <td class="left">trdNo[세틀뱅크거래번호]</td>
            <td class="right"><%= escapeHtml(trdNo) %></td>
        </tr>
        <tr>
            <td class="left">trdAmt[거래금액]</td>
            <td class="right"><%= escapeHtml(trdAmt) %></td>
        </tr>
        <tr>
            <td class="left">mchtParam[상점예약필드]</td>
            <td class="right"><%= escapeHtml(mchtParam) %></td>
        </tr>

        <tr>
            <td class="left">authDt[승인일시]</td>
            <td class="right"><%= escapeHtml(authDt) %></td>
        </tr>
        <tr>
            <td class="left">authNo[승인번호]</td>
            <td class="right"><%= escapeHtml(authNo) %></td>
        </tr>
     	<tr>
            <td class="left">reqIssueDt[채번요청일시]</td>
            <td class="right"><%= escapeHtml(reqIssueDt) %></td>
        </tr>
        <tr>
            <td class="left">intMon[할부개월수]</td>
            <td class="right"><%= escapeHtml(intMon) %></td>
        </tr>
        <tr>
            <td class="left">fnNm[카드사명]</td>
            <td class="right"><%= escapeHtml(fnNm) %></td>
        </tr>
        <tr>
            <td class="left">fnCd[카드사코드]</td>
            <td class="right"><%= escapeHtml(fnCd) %></td>
        </tr>
        <tr>
            <td class="left">pointTrdNo[포인트거래번호]</td>
            <td class="right"><%= escapeHtml(pointTrdNo) %></td>
        </tr>
        <tr>
            <td class="left">pointTrdAmt[포인트거래금액]</td>
            <td class="right"><%= escapeHtml(pointTrdAmt) %></td>
        </tr>
        <tr>
            <td class="left">cardTrdAmt[신용카드결제금액]</td>
            <td class="right"><%= escapeHtml(cardTrdAmt) %></td>
        </tr>
        <tr>
            <td class="left">vtlAcntNo[가상계좌번호]</td>
            <td class="right"><%= escapeHtml(vtlAcntNo) %></td>
        </tr>
        <tr>
            <td class="left">expireDt[입금기한]</td>
            <td class="right"><%= escapeHtml(expireDt) %></td>
        </tr>
        <tr>
            <td class="left">cphoneNo[휴대폰번호]</td>
            <td class="right"><%= escapeHtml(cphoneNo) %></td>
        </tr>
        <tr>
            <td class="left">billKey[자동결제키]</td>
            <td class="right"><%= escapeHtml(billKey) %></td>
        </tr>
        <tr>
            <td class="left">csrcAmt[현금영수증 발급 금액(네이버페이)]</td>
            <td class="right"><%= escapeHtml(csrcAmt) %></td>
        </tr>
        <tr>
            <td colspan="2" style="text-align: center;">
                <input class="button" type="button" name="button" value="돌아가기" onclick="location.href='pay_form.jsp'">
            </td>
        </tr>
    </table>
</div>
</body>
</html>