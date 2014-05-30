<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>r-pac - Ship Item</title>
<link type="images/x-icon" rel="shortcut icon" href="/favicon.ico" />
<link type="text/css" rel="stylesheet" href="/css/screen.css" />
<link type="text/css" rel="stylesheet" href="/css/all.css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<%	
	from tg.flash import get_flash
	from gapproject.util.common import Date2Text
%>
<script type="text/javascript" src="/javascript/jquery.1.7.1.min.js"></script>
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<script type="text/javascript">
</script>
</head>

<body>
<div class="nav-tree">Ship Detail&nbsp;&nbsp;:&nbsp;&nbsp;</div>

% if details:
<img src="/images/search_10.jpg" width="600" height="2" />

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td width="100%" align="left" valign="top">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="100%" valign="top" align="left">
                        <table width="500" border="0" cellspacing="0" cellpadding="0">
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
<!--                             <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Invoice Number&nbsp;:
                                </td>
                                <td>
                     				${header.invoiceNumber}
                                </td>
                            </tr> 
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Invoice(USD)&nbsp;:
                                </td>
                                <td>
                     				<input type="text" name="invoice" class="numeric" value="${header.invoice}" />
                                </td>
                            </tr> -->
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
                     ${header.remark}
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
<table cellspacing="0" cellpadding="0" border="0" width="500" class="gridTable">
	<thead>
	<tr>
		<td align="center" width="200" class="wt-td">Bag Item No.</td>
        <td align="center" width="100" class="wt-td">Qty Shipped</td>
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
 		<td align="center" class="t-td">${s.qty}</td> 
 
	</tr>
	%endfor
	</tbody>
</table>
<div style="clear:both"><br /><br /><br /></div>
% endif
</body>
</html>