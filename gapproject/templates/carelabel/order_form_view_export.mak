<%
	from tg.flash import get_flash,get_status
	from gapproject.util.mako_filter import b, na
	from gapproject.util.common import rpacEncrypt, Date2Text
	from repoze.what.predicates import in_group
	from gapproject.util.gap_const import orderStatus, CANCEL, NEW, SHIPPED_PART
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>r-pac - GAP</title>

<link type="images/x-icon" rel="shortcut icon" href="/favicon.ico" />
<link type="text/css" rel="stylesheet" href="/css/impromt.css" />
<link type="text/css" rel="stylesheet" href="/css/screen.css" />
<link type="text/css" rel="stylesheet" href="/css/all.css" />
<link rel="stylesheet" href="/css/thickbox.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />

<script type="text/javascript" src="/javascript/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="/javascript/common.js"></script>
<script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js"></script>
<script type="text/javascript" src="/javascript/jquery.bgiframe.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.columnfilters.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.bgiframe.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/thickbox-compressed.js" language="javascript"></script>
%if get_flash():
<script language="JavaScript" type="text/javascript">
    $(document).ready(function(){
        %if get_status() == "ok":
        showMsg("${get_flash()|n}");
        %elif get_status() == "warn":
        showError("${get_flash()|n}");
        %endif
    });
</script>
%endif
<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	function toConfirm(){
		$.prompt("We are going to cancel your order information in our Production System upon your final confirmation.<br /> \
				 Are you sure to cancel the order now?",
	    		{opacity: 0.6,
	    		 prefix:'cleanblue',
	    		 buttons:{'Yes':true,'No,Go Back':false},
	    		 focus : 1,
	    		 callback : function(v,m,f){
	    		 	if(v){
	    		 		$("form").submit();
	    		 	}
	    		 }
	    		}
	    	);
}
	//]]>
</script>

</head>
<body>

<div style="width:1100px">
	<table width="1000" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="15">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>
			<table width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
				<tr>
					<td>
					<table width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
						<tr>
							<td height="40" class="title1">Order Confirmation</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						</tr>
						</tbody>
					</table>
					</td>
					<td>&nbsp;</td>
				</tr>
				</tbody>
			</table>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td align="left" valign="top">
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr>
							<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="70">
										<strong>&nbsp;&nbsp;&nbsp;&nbsp;Ship To&nbsp;:</strong>
									</td>
									<td><img src="/images/search_10.jpg" width="380" height="2" /></td>
								</tr>
							</table>
							</td>
							<td width="10">&nbsp;</td>
							<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="70">
										<strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bill To&nbsp;:</strong>
									</td>
									<td><img src="/images/search_10.jpg" width="380" height="2" /></td>
								</tr>
							</table>
							</td>
						</tr>
						<tr>
							<td width="50%" align="left" valign="top">
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="120">&nbsp;</td>
									<td width="10">&nbsp;</td>
									<td>&nbsp;</td>
									<td width="30">&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Company&nbsp;: </td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.shipCompany|b}</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Address&nbsp;:&nbsp;</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.shipAddress|b}</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Phone&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.shipTel|b}</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Fax&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.shipFax|b}</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Contact&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.shipAttn|b}</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">&nbsp;</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">&nbsp;r-pac Confirmation No&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.orderNO|b}</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">&nbsp;Region&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.region|b}</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">&nbsp;Status&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;
										% if order_header.status > CANCEL  and order_header.status < SHIPPED_PART:
											${orderStatus.get(NEW)}&nbsp;
										% else:
											${orderStatus.get(order_header.status)}&nbsp;
										% endif
									</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Customer Order Date&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${Date2Text(order_header.orderDate)|b}</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">&nbsp;Shipping Instruction&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.shipInstruction|b}</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">&nbsp;Remark&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.remark|b}</td>
									<td>&nbsp;</td>
								</tr>
							</table>
							</td>
							<td>&nbsp;</td>
							<td width="50%" align="left" valign="top">
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="140">&nbsp;</td>
									<td width="10">&nbsp;</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Company&nbsp;: </td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.billCompany|b}</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Address&nbsp;:&nbsp;</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.billAddress|b}</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Phone&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.billTel|b}</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Fax&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.billFax|b}</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Contact&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.billAttn|b}</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">&nbsp;</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">&nbsp;Vendor PO#:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.vendorPO|b}</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">&nbsp;Total Quantity:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.total_qty()}</td>
								</tr>
								<tr>
                                    <td height="26" align="right" class="title2">&nbsp;Total Amount:</td>
                                    <td>&nbsp;</td>
                                    <td class="padding6px">&nbsp;${total_value}</td>
                                </tr>
								<tr>
									<td height="26" align="right" class="title2">
										&nbsp;r-pac Regional Contact&nbsp;:
									</td>
									<td>&nbsp;</td>
									<td class="padding6px"><a href="mailto:${order_header.region.regionMailAddress}">${order_header.region.regionMailAddress|b}</a></td>
								</tr>
								<!--
								<tr>
									<td height="26" align="right" class="title2">Invoice NO&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">${order_header.invoiceNO|b}</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Invoice Total&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">${order_header.invoiceTotal|b}</td>
								</tr> -->
							</table>
							</td>
						</tr>
					</table>
					</td>
				</tr>
			</table>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
	</table>
</div>
<div style="clear:both"><br /></div>
<div>
<span id="hint-content">If you need to make a change or cancel an order, please contact your r-pac representative.</span>
<br /><br />
</div>
<table cellspacing="0" cellpadding="0" border="0" width="1400" class="gridTable">
	<thead>
	<tr>
        <td height="35" align="center" width="200" class="wt-td">Bag Item No#</td>
		<td align="center" width="200" class="wt-td">Width</td>
		<td align="center" width="200" class="wt-td">Length</td>
		<td align="center" width="200" class="wt-td">Gusset</td>
		<td align="center" width="200" class="wt-td">Lip</td>
		<td align="center" width="200" class="wt-td">Price(per 1000pcs)</td>
		<td align="center" width="200" class="wt-td">Quantity</td>
	</tr>
	</thead>
	<tbody>
	<%
		order_details.sort(key = lambda x: x.id)
	%>
	%for index, detail in enumerate(order_details):
	%if index%2==0:
	<tr class="even">
	%else:
	<tr class="odd">
	%endif
		<td height="25" class="t-td">${detail.item|b}</td>
		<td align="center" class="t-td">${detail.item.width|b}</td>
		<td align="center" class="t-td">${detail.item.length|b}</td>
		<td align="center" class="t-td">${detail.item.gusset|b}</td>
		<td align="center" class="t-td">${detail.item.lip|b}</td>
		<td align="center" class="t-td">${str(detail.price.price * 1000)|b}</td>
		<td align="center" class="t-td">${detail.qty|b}</td> 
	</tr>
	%endfor
	</tbody>
</table>
<div id="footer"><span style="margin-right:40px">Copyright r-pac International Corp.</span></div>
</body>
</html>