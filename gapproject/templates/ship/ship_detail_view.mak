<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>r-pac - Ship Item</title>
<link type="images/x-icon" rel="shortcut icon" href="/favicon.ico" />
<link type="text/css" rel="stylesheet" href="/css/screen.css" />
<link type="text/css" rel="stylesheet" href="/css/all.css" />
<link rel="stylesheet" href="http://code.jquery.com/ui/1.8.6/themes/start/jquery-ui.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<%	
	from tg.flash import get_flash
	from gapproject.util.common import Date2Text
%>
<script type="text/javascript" src="/javascript/jquery.1.7.1.min.js"></script>
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery-ui-1.8.6.min.js"></script> 
<script type="text/javascript" src="/javascript/jquery.validate.min.js"></script>
<script type="text/javascript" src="/javascript/jquery.ui.datepicker.validation.min.js"></script>
<script type="text/javascript">
$(function(){
	$(".numeric").numeric({ negative : false });
    var dateFormat = 'yy-mm-dd';
    $(".datePicker").datepicker({dateFormat: dateFormat});
});
var toSubmit = function(){
	if(window.confirm("Are you sure to submit these now?")){
		$('#save-form').submit();
	}
};
</script>
</head>

<body>
<div class="nav-tree">Ship Detail&nbsp;&nbsp;:&nbsp;&nbsp;</div>
% if get_flash():
<div style="clear:both"><br/></div>
<div style="margin-left:200px; color:red;font-weight:bolder;">${get_flash()}</div>
<div style="clear:both"><br/></div>
% endif

% if details:
<img src="/images/search_10.jpg" width="600" height="2" />
<form id="save-form" action="/ship/viewDetailSave" method="post">
	<input type="hidden" name="shid" value="${header.id}" />
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td width="100%" align="left" valign="top">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="100%" valign="top" align="left">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Ship No&nbsp;:
                                </td>
                                <td>
                                    ${header.no}
                                </td>
                            </tr> 
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;r-pac Confirmation No&nbsp;:
                                </td>
                                <td>
                                    ${header.orderHeader.orderNO}
                                </td>
                            </tr> 
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Invoice Number&nbsp;:
                                </td>
                                <td>
                     				<input type="text" name="invoiceNumber" value="${header.invoiceNumber}"/>
                                </td>
                            </tr> 
                            <!--
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Invoice(USD)&nbsp;:
                                </td>
                                <td>
                     				<input type="text" name="invoice" class="numeric" value="${header.invoice}" />
                                </td>
                            </tr>
                        -->
                            <!-- <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Other Invoice(USD)&nbsp;:
                                </td>
                                <td>
                     				<input type="text" name="otherInvoice" class="numeric" value="${header.otherInvoice}"/>
                                </td>
                            </tr> -->
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;&nbsp;Remarks&nbsp;:
                                </td>
                                <td>
                     <textarea id="remark"  name="remark" cols="45" rows="4" class="textarea-style">${header.remark}</textarea>
                                </td>
                            </tr>  
                            
                        </table>
                        </td>
                    </tr>
                </table>
                </td>
                <td>&nbsp;</td>
            </tr>
        </table>
        </td>
    </tr>
</table>

<div style="clear:both"><br/></div>
<table cellspacing="0" cellpadding="0" border="0" width="760" class="gridTable">
	<thead>
	<tr>
		<td align="center" width="100" class="wt-td">Bag Item No.</td>
		<td align="center" width="100" class="wt-td">Warehouse</td>
        <td align="center" width="130" class="wt-td">Price(USD)</td>
        <td align="center" width="100" class="wt-td">Qty Shipped</td>
        <td align="center" width="120" class="wt-td">Internal ref. OrderNumber</td>
        <td align="center" width="120" class="wt-td">Invoice Date</td>
	</tr>
	</thead>
	<tbody>
	%for index, s in enumerate(details):
	%if index%2==0:
	<tr class="even">
	%else:
	<tr class="odd">
	%endif
		<td align="center" class="t-td">${s.item}</td> 
		<td align="center" class="t-td">${s.warehouse}</td> 
        <td align="center" class="t-td">${s.item.getPrice(s.warehouse.regionID)}</td> 
 		<td align="center" class="t-td">${s.qty}</td> 
 		<td align="center" class="t-td">${s.internalPO}</td>  
        <td align="center" class="t-td"><input type="text" name="invoiceDate-${s.id}" class="datePicker dpDate" value="${Date2Text(s.invoiceDate)}"/></td>  
	</tr>
    <tr>
        <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="9">&nbsp;</td>
    </tr>
    <tr>
         <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="6">
              <a style="float:right" class="submit" href="javascript:toSubmit()"><img src="/images/images/menu_submit_g.jpg"></a>
        </td>
    </tr>
	%endfor
	</tbody>
</table>


<div style="clear:both"><br /></div>
</form>
% endif
</body>
</html>