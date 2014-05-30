<%inherit file="gapproject.templates.master"/>

<%
	from gapproject.util.mako_filter import b, na
	from gapproject.util.common import rpacEncrypt, Date2Text
	from repoze.what.predicates import in_group, has_permission
%>

<%def name="extTitle()">r-pac - GAP</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/thickbox.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<link rel="stylesheet" href="/css/flora.datepicker.css" type="text/css" />
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery.columnfilters.js" language="javascript"></script>
<!-- <script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js" language="javascript"></script> -->
<script type="text/javascript" src="/javascript/thickbox-compressed.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/ui.datepicker.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/order_form_update.js" language="javascript"></script>

<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	
	//]]>
</script>
</%def>

<div id="function-menu">
	<table width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
			<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
			<td width="64" valign="top" align="left">
				<a href="${return_url}"><img src="/images/images/menu_gap_g.jpg"/></a>
			</td>
			<td width="64" valign="top" align="left">
				<a class="confirm" href="#" onclick="toConfirm()"><img src="/images/images/menu_confirm_g.jpg"/></a>
			</td>
			<td width="64" valign="top" align="left">
				<a href="${return_url}"><img src="/images/images/menu_return_g.jpg"/></a>
			</td>
			<td width="23" valign="top" align="left">
				<img height="21" width="23" src="/images/images/menu_last.jpg"/>
			</td>
			<td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
		</tr>
		</tbody>
	</table>
</div>
<form id="orderForm" action="/order/saveUpdate" method="post">
<input type="hidden" name="order_id" value="${order_header.id}">
<div class="nav-tree">GAPProject&nbsp;&nbsp;&gt;&nbsp;&nbsp;Order Form</div>
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
									<td height="26" align="right" class="title2">&nbsp;PO#&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">&nbsp;${order_header.orderNO|b}</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">&nbsp;Shipped Date&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">
									##% if in_group("AE"):
									%if has_permission("MAIN_INVENTORY_ENQUIRY_BY_WAREHOUSE"):
									<input name="shippedDate" id="shippedDate" type="text" class="input-style1 datePicker" value="${Date2Text(order_header.shippedDate)|b}" />
									% endif
									</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td>&nbsp;</td>
									<td>&nbsp;</td>
									<td>&nbsp;</td>
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
									<td height="26" align="right" class="title2">
										&nbsp;r-pac Regional Contact&nbsp;:
									</td>
									<td>&nbsp;</td>
									<td class="padding6px"><a href="mailto:${order_header.region.regionMailAddress}">${order_header.region.regionMailAddress|b}</a></td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Invoice NO&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">
									##% if in_group("AE"):
									%if has_permission("MAIN_INVENTORY_ENQUIRY_BY_WAREHOUSE"):
									<input name="invoiceNO" id="invoiceNO" type="text" class="input-style1" value="${order_header.invoiceNO}" />
									% endif
									&nbsp;
									</td>
								</tr>
								<tr>
									<td height="26" align="right" class="title2">Invoice Total&nbsp;:</td>
									<td>&nbsp;</td>
									<td class="padding6px">
									##% if in_group("AE"):
									%if has_permission("MAIN_INVENTORY_ENQUIRY_BY_WAREHOUSE"):
									<input name="invoiceTotal" id="invoiceTotal" type="text" class="input-style1" value="${order_header.invoiceTotal}" />
									% endif
									</td>
								</tr>
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
</form>