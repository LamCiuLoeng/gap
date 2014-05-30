<%inherit file="gapproject.templates.master"/>

<%
	from gapproject.util.mako_filter import b, na
	from gapproject.util.common import rpacEncrypt, Date2Text
	from repoze.what.predicates import in_group,has_permission
	from gapproject.util.gap_const import orderStatus, CANCEL, NEW, SHIPPED_PART
%>

<%def name="extTitle()">r-pac - GAP</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/thickbox.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<link rel="stylesheet" href="/javascript/jquery.nyroModal/styles/nyroModal.css" type="text/css" media="screen" />
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery.columnfilters.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.bgiframe.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/thickbox-compressed.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.nyroModal/js/jquery.nyroModal.custom.min.js"></script>
<!--[if (gte IE 5)&(lt IE 9)]>
    <script type="text/javascript" src="/javascript/jquery.nyroModal/js/jquery.nyroModal-ie6.min.js"></script>
<![endif]-->

<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	$(function(){
		var width = 800;
        var height = 600;
        $('.nyroModal').nyroModal({
          sizes: {
            initW: width, initH: height,
            minW: width, minH: height,
            w: width, h: height
          },
          closeOnClick: false,
          callbacks: {
            beforeShowCont: function() { 
                width = $('.nyroModalCont').width();
                height = $('.nyroModalCont').height();
                $('.nyroModalCont iframe').css('width', width);
                $('.nyroModalCont iframe').css('height', height);
            },
            afterClose: function() {
                parent.window.location.reload();
            }
          }
        });
	});

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
</%def>

<div id="function-menu">
	<table width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
			<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
			<td width="64" valign="top" align="left">
				<a href="${return_url}"><img src="/images/images/menu_gap_g.jpg"/></a>
			</td>
			##% if (in_group("AE") or in_group("Admin")) and can_update == True and order_header.status > CANCEL and order_header.status < SHIPPED_PART:
			% if has_permission("MAIN_INVENTORY_ENQUIRY_BY_WAREHOUSE") and can_update == True and order_header.status > CANCEL and order_header.status < SHIPPED_PART:
			<td width="64" valign="top" align="left">
				<a href="/order/vendorUpdate?code=${rpacEncrypt(order_header.id)}">
					<img src="/images/images/menu_update_g.jpg"/>
				</a>
			</td>
			% endif
			<td width="64" valign="top" align="left">
				<a href="/order/exportPDFFile?id=${order_header.id}">
					<img src="/images/images/menu_export_g.jpg"/>
				</a>
			</td>
			##% if in_group("AE") or in_group("Admin"):
			%if has_permission("MAIN_INVENTORY_ENQUIRY_BY_WAREHOUSE"):
			<td width="64" valign="top" align="left">
				<a href="#" onclick="toConfirm()">
					<img src="/images/images/menu_cancel_g.jpg"/>
				</a>
			</td>
			% endif
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

<form style="display:none" action="/order/cancel?code=${rpacEncrypt(order_header.id)}" method="post">
</form>

<div class="nav-tree">GAPProject&nbsp;&nbsp;&gt;&nbsp;&nbsp;Order Form</div>

% if shipItems:
<div style="clear:both"></div>
<img src="/images/search_10.jpg" width="600" height="2" />
<div class="nav-tree">Shipped:</div>

<div style="clear:both"><br /></div>
<table cellspacing="0" cellpadding="0" border="0" width="800" class="gridTable">
	<thead>
	<tr>
        <td height="20" align="center" width="200" class="wt-td">Ship No.</td>
		<td align="center" width="200" class="wt-td">Shipped Date</td>
<!-- 		<td align="center" width="200" class="wt-td">Invoice Number</td>
		<td align="center" width="200" class="wt-td">Invoice(USD)</td> -->
        <td align="center" width="200" class="wt-td">Remark</td>
	</tr>
	</thead>
	<tbody>
	%for index, s in enumerate(shipItems):
	%if index%2==0:
	<tr class="even">
	%else:
	<tr class="odd">
	%endif
		<td height="20" class="t-td"><a href="/ship/viewDetail4Order?shid=${s.id}" class="nyroModal" target="_blank">${s.no}</a></td>
		<td align="center" class="t-td">${Date2Text(s.createTime)}</td> 
<!--  		<td align="center" class="t-td">${s.invoiceNumber|b}</td> 
 		<td align="center" class="t-td">${s.invoice|b}</td>   -->
 		<td align="center" class="t-td">${s.remark|b}</td> 
	</tr>
	%endfor
	</tbody>
</table>
<div style="clear:both"><br /></div>
% endif

<div style="width:1100px">
	<table width="1000" border="0" cellspacing="0" cellpadding="0">
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
								<!-- <tr>
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

<p id="hint-content" style="margin-left:10px">If you need to make a change or cancel an order, please contact your r-pac representative.<br /><br /></p>

<table cellspacing="0" cellpadding="0" border="0" class="gridTable" style="margin-left:10px">
	<thead>
	<tr>
        <td height="35" align="center" width="200" class="wt-td" style="border-left:1px solid #CCCCCC">Bag Item No#</td>
		<td align="center" width="100" class="wt-td">Width</td>
		<td align="center" width="100" class="wt-td">Length</td>
		<td align="center" width="100" class="wt-td">Gusset</td>
		<td align="center" width="100" class="wt-td">Lip</td>
		<td align="center" width="150" class="wt-td">Price(per 1000pcs)</td>
		<td align="center" width="150" class="wt-td">Quantity</td>
		<td align="center" width="150" class="wt-td">Qty Shipped</td>
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
		<td height="25" class="t-td" style="border-left:1px solid #CCCCCC">${detail.item|b}</td>
		<td align="center" class="t-td">${detail.item.width|b}</td>
		<td align="center" class="t-td">${detail.item.length|b}</td>
		<td align="center" class="t-td">${detail.item.gusset|b}</td>
		<td align="center" class="t-td">${detail.item.lip|b}</td>
		<td align="center" class="t-td">${str(detail.price.price * 1000)|b}</td>
		<td align="center" class="t-td">${detail.qty|b}</td> 
		<td align="center" class="t-td">${detail.qtyShipped}</td>
	</tr>
	%endfor
	</tbody>
</table>