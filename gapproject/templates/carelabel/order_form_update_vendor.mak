<%inherit file="gapproject.templates.master"/>

<%
	from gapproject.util.mako_filter import b, na
	from gapproject.util.common import Date2Text
	from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - GAP</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/jquery.autocomplete.css" type="text/css" />
<link rel="stylesheet" href="/css/flora.datepicker.css" type="text/css" media="screen"/>
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<link rel="stylesheet" href="/css/thickbox.css" type="text/css" />
<style type="text/css">
	.input-width{
		width : 300px
	}
	
	#warning {
		font:italic small-caps bold 16px/1.2em Arial;
	}
</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.validate.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/thickbox-compressed.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.ui.datepicker.validation.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/ui.datepicker.js" language="javascript"></script>
<!--script type="text/javascript" src="/javascript/custom/order_form_edit.js" language="javascript"></script-->
<script type="text/javascript" src="/javascript/custom/order_form_update.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/gap_ac.js" language="javascript"></script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
  	<td width="64" valign="top" align="left">
  		<a href="${return_url}"><img src="/images/images/menu_gap_g.jpg"/></a>
  	</td>
    <td width="64" valign="top" align="left">
    	<a class="confirm" href="#" onclick="toConfirm()"><img src="/images/images/menu_confirm_g.jpg"/></a>
    </td>
    <td width="64" valign="top" align="left">
    	<a href="${return_url}" onclick="return toCancel()"><img src="/images/images/menu_cancel_g.jpg"/></a>
    </td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAPProject&nbsp;&nbsp;&gt;&nbsp;&nbsp;Order Form</div>

<form id="orderForm" action="/order/saveVendorUpdate" method="post">
<input type="hidden" name="region" value="${order.regionID}" />
<input type="hidden" name="order_id" value="${order.id}" />
<table width="1000" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="15">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="850" align="left" valign="top">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="70">
									<strong>&nbsp;&nbsp;&nbsp;&nbsp;Ship To&nbsp;:</strong>
								</td>
								<td>
									<img src="/images/search_10.jpg" width="330" height="2" />
								</td>
							</tr>
						</table>
						</td>
						<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="70">
									<strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bill To&nbsp;:</strong>
								</td>
								<td>
									<img src="/images/search_10.jpg" width="330" height="2" />
								</td>
							</tr>
						</table>
						</td>
					</tr>
					<tr>
						<td width="50%" valign="top">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="120">&nbsp;</td>
								<td width="10">&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td height="26" align="right">PVDN#&nbsp;:</td>
								<td width="10">&nbsp;</td>
								<td>${request.identity["user"].user_name}</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Company&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<input name="shipCompany" id="shipCompany" type="text" class="input-style1" value="${order.shipCompany|b}" />
								</td>
							</tr>
							<tr>
								<td align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Address&nbsp;:&nbsp;
								</td>
								<td>&nbsp;</td>
								<td>
									<textarea name="shipAddress" cols="45" rows="5" class="textarea-style" id="shipAddress">${order.shipAddress|b}</textarea>
								</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Phone&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<input name="shipTel" type="text" class="input-style1" id="shipTel" size="30" value="${order.shipTel|b}" />
								</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Fax&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<input name="shipFax" type="text" class="input-style1" id="shipFax" size="30" value="${order.shipFax|b}" />
								</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Contact&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<input name="shipAttn" type="text" class="input-style1" id="shipAttn" size="30" value="${order.shipAttn|b}" />
								</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Vendor PO#&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<input name="vendorPO" type="text" class="input-style1" id="vendorPO" size="30" value="${order.vendorPO|b}" />
								</td>
							</tr>
							<tr>
								<td colspan="2">&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td height="26" align="right">Remark&nbsp;:</td>
								<td>&nbsp;</td>
								<td>
									<textarea name="remark" cols="45" rows="5" class="textarea-style" id="remark">${order.remark}</textarea>
								</td>
							</tr>
						</table>
						</td>
						<td width="50%" valign="top">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="120">&nbsp;</td>
								<td width="10">&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td height="26" align="right">PVDN#&nbsp;:</td>
								<td width="10">&nbsp;</td>
								<td>${request.identity["user"].user_name}</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Company&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<input name="billCompany" id="billCompany" type="text" class="input-style1" size="30" value="${order.billCompany|b}" />
								</td>
							</tr>
							<tr>
								<td align="right"><img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Address&nbsp;:&nbsp;</td>
								<td>&nbsp;</td>
								<td>
									<textarea name="billAddress" cols="45" rows="5" class="textarea-style" id="billAddress">${order.billAddress|b}</textarea>
								</td>
							</tr>
							<tr>
								<td height="26" align="right"><img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Phone&nbsp;:</td>
								<td>&nbsp;</td>
								<td>
									<input name="billTel" type="text" class="input-style1" id="billTel" size="30" value="${order.billTel|b}" />
								</td>
							</tr>
							<tr>
								<td height="26" align="right"><img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Fax&nbsp;:</td>
								<td>&nbsp;</td>
								<td>
									<input name="billFax" type="text" class="input-style1" id="billFax" size="30" value="${order.billFax|b}" />
								</td>
							</tr>
							<tr>
								<td height="26" align="right"><img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Contact&nbsp;:</td>
								<td>&nbsp;</td>
								<td>
									<input name="billAttn" type="text" class="input-style1" id="billAttn" size="30" value="${order.billAttn|b}" />
								</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />
									&nbsp;r-pac Regional Contact&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td><a href="mailto:${order.region.regionMailAddress}">${order.region.regionMailAddress|b}</a></td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Ship Instruction&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<select id="shipInstruction" name="shipInstruction">
										<option></option>
										% if order.shipInstruction == "BY OCEAN":
										<option selected value="BY OCEAN">BY OCEAN</option>
										% else:
										<option value="BY OCEAN">BY OCEAN</option>
										% endif
										% if order.shipInstruction == "BY AIR":
										<option selected value="BY AIR">BY AIR</option>
										% else:
										<option value="BY AIR">BY AIR</option>
										% endif
										% if order.shipInstruction == "BY DHL":
										<option selected value="BY DHL">BY DHL</option>
										% else:
										<option value="BY DHL">BY DHL</option>
										% endif
										% if order.shipInstruction == "BY FEDEX":
										<option selected value="BY FEDEX">BY FEDEX</option>
										% else:
										<option value="BY FEDEX">BY FEDEX</option>
										% endif
										% if order.shipInstruction == "BY UPS":
										<option selected value="BY UPS">BY UPS</option>
										% else:
										<option value="BY UPS">BY UPS</option>
										% endif
										% if order.shipInstruction == "BY TNT":
										<option selected value="BY TNT">BY TNT</option>
										% else:
										<option value="BY TNT">BY TNT</option>
										% endif
										% if order.shipInstruction == "BY S.F EXPRESS":
										<option selected value="BY S.F EXPRESS">BY S.F EXPRESS</option>
										% else:
										<option value="BY S.F EXPRESS">BY S.F EXPRESS</option>
										% endif
										% if order.shipInstruction == "BY COURIER":
										<option selected value="BY COURIER">BY COURIER</option>
										% else:
										<option value="BY COURIER">BY COURIER</option>
										% endif
										% if order.shipInstruction == "BY TRUCK":
										<option selected value="BY TRUCK">BY TRUCK</option>
										% else:
										<option value="BY TRUCK">BY TRUCK</option>
										% endif
										% if order.shipInstruction not in ["BY FEDEX", "BY UPS", "BY TNT", "BY S.F EXPRESS", "BY COURIER", "BY COURIER", "BY TRUCK"]:
										<option selected value="BY OTHER">BY OTHER</option>
										% else:
										<option value="BY OTHER">BY OTHER</option>
										% endif
									</select>
								</td>
							</tr>
							<tr>
								<td height="26" align="right" class="otherInstruction">
									Other Ship Instruction&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
								% if order.shipInstruction not in ["BY FEDEX", "BY UPS", "BY TNT", "BY S.F EXPRESS", "BY COURIER", "BY COURIER", "BY TRUCK"]:
									<textarea name="otherInstruction" cols="45" rows="5" class="textarea-style otherInstruction">${order.shipInstruction}</textarea>
								% else:
									<textarea name="otherInstruction" cols="45" rows="5" class="textarea-style otherInstruction"></textarea>
								% endif
								</td>
							</tr>
							<tr>
								<td height="26" align="right">Customer Order Date:</td>
								<td>&nbsp;</td>
								<td><input type="text" class="datePicker v_is_date" value="${Date2Text(order.orderDate, '%Y-%m-%d')}" id="orderDate" name="orderDate" style="width:250px;"></td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
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
	<tr>
		<td>&nbsp;</td>
		<td><img src="/images/search_10.jpg" width="970" height="2" /></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><span id="hint-content">Click 'Confirm' button once qty is entered! Initial order qty for each item should be 250 pcs, and all increase order quantity should be in a multiple number of 250 pcs!</span></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
</table>
<!--div style="clear:both">
	&nbsp;&nbsp;
	<input type="image" src="/images/new_item.jpg" onclick="toAdd();return false;"/>
</div-->
<br />
<table cellspacing="0" cellpadding="0" border="0" class="gridTable" style="margin-left:10px">
	<thead>
	<tr>
		<td height="35" align="center" width="250" class="wt-td" style="border-left:1px solid #CCCCCC">Bag Item No#</td>
		<td align="center" width="100" class="wt-td">Width</td>
		<td align="center" width="100" class="wt-td">Length</td>
		<td align="center" width="100" class="wt-td">Gusset</td>
		<td align="center" width="100" class="wt-td">Lip</td>
		<td align="center" width="150" class="wt-td">Price(per 1000pcs)</td>
		<td align="center" width="100" class="wt-td">Quantity</td>
	</tr>
	</thead>
	<tbody>
	% for detail in order_details:
	<tr>
		<td height="25" class="t-td" style="border-left:1px solid #CCCCCC">
			${detail.item.item_number}
			<input type="hidden" name="item_${detail.id}_ext" fieldName="item_detail" value="${detail.item.item_number}" />
		</td>
		<td align="center" class="t-td">${detail.item.width|b}</td>
		<td align="center" class="t-td">${detail.item.length|b}</td>
		<td align="center" class="t-td">${detail.item.gusset|b}</td>
		<td align="center" class="t-td">${detail.item.lip|b}</td>
		<td align="center" class="t-td">${detail.price.price * 1000}</td>
		<td align="center" class="bt-td">
			<input type="text" class="required numeric" name="quantity_${detail.id}_ext" style="text-align:right;width:150px;" value="${detail.qty}" />
		</td>
	</tr>
	% endfor
	<!--tr id="item_x_ext" class="template" style="display:none">
		<td height="25" class="t-td" style="border-left:1px solid #CCCCCC">
			<input type="text" class="" name="item_x_ext" fieldName="item_detail" />
		</td>
		<td align="center" class="t-td">&nbsp;</td>
		<td align="center" class="t-td">&nbsp;</td>
		<td align="center" class="t-td">&nbsp;</td>
		<td align="center" class="t-td">&nbsp;</td>
		<td align="center" class="t-td">&nbsp;</td>
		<td align="center" class="bt-td">
			<input type="text" name="quantity_x_ext" class="numeric" style="text-align:right;width:150px;">
		</td>
		<td align="center" class="t-td">
			<input type="button" name="clear_x_ext" value="Remove" onclick="toRemove(this)" />
		</td>
	</tr-->
	</tbody>
</table>
<div style="float: left; padding-left: 800px;">
<br />
<a class="confirm" href="#" onclick="toConfirm()"><img src="/images/images/menu_confirm_g.jpg"/></a>
&nbsp;&nbsp;
<a href="${return_url}" onclick="return toCancel()"><img src="/images/images/menu_cancel_g.jpg"/></a>
</div>
</form>
