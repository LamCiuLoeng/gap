<%inherit file="gapproject.templates.master"/>

<%
	from gapproject.util.mako_filter import b, na
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
<!-- script type="text/javascript" src="/javascript/jquery.validate.js" language="javascript"></script -->
<!-- script type="text/javascript" src="/javascript/thickbox-compressed.js" language="javascript"></script -->
<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.ui.datepicker.validation.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/ui.datepicker.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/cl_order_form_edit.js?v=1" language="javascript"></script>
<!--script type="text/javascript" src="/javascript/custom/gap_cl_ac.js" language="javascript"></script-->
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
  	<td width="64" valign="top" align="left">
  		<a href="${return_url}"><img src="/images/images/menu_gap_g.jpg"/></a>
  	</td>
    <td width="64" valign="top" align="left">
    	<a class="confirm" href="#" onclick="confirmOrder()"><img src="/images/images/menu_confirm_g.jpg"/></a>
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

<form id="orderForm" action="/carelabel/save" method="post">
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
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Company&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<select name="shipCompany" class="input-style1-40fonts" id="shipCompany">	
										<option value="-1">&nbsp;</option>
					          		%for st in shipTos:
	          							<option value="${st.id}">${st.company|b}</option>
	          						%endfor
          							</select>
								</td>
							</tr>
							<tr>
								<td align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Address&nbsp;:&nbsp;
								</td>
								<td>&nbsp;</td>
								<td>
								% if first_order:
									<textarea name="shipAddress" cols="45" rows="5" class="textarea-style" id="shipAddress">${first_order.shipAddress}</textarea>
								% else:
									<textarea name="shipAddress" cols="45" rows="5" class="textarea-style" id="shipAddress"></textarea>
								% endif
								</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Phone&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
								% if first_order:
									<input name="shipTel" type="text" class="input-style1" id="shipTel" size="30" value="${first_order.shipTel}" />
								% else:
									<input name="shipTel" type="text" class="input-style1" id="shipTel" size="30" />
								% endif
								</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Fax&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
								% if first_order:
									<input name="shipFax" type="text" class="input-style1" id="shipFax" size="30" value="${first_order.shipFax}" />
								% else:
									<input name="shipFax" type="text" class="input-style1" id="shipFax" size="30" />
								% endif
								</td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Contact&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
								% if first_order:
									<input name="shipAttn" type="text" class="input-style1" id="shipAttn" size="30" value="${first_order.shipAttn}" />
								% else:
									<input name="shipAttn" type="text" class="input-style1" id="shipAttn" size="30" />
								% endif
								</td>
							</tr>
							<tr>
								<td height="26" align="right"><img src="/images/search_07.jpg" width="7" height="7" />Style No#&nbsp;:</td>
								<td>&nbsp;</td>
								<td><input name="styleNo" type="text" class="input-style1" id="styleNo" size="30" /></td>
							</tr>
							<tr>
								<td height="26" align="right"><img src="/images/search_07.jpg" width="7" height="7" />Style Name&nbsp;:</td>
								<td>&nbsp;</td>
								<td><input name="styleName" type="text" class="input-style1" id="styleName" size="30" /></td>
							</tr>
							<tr>
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Vendor PO#&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<input name="vendorPO" type="text" class="input-style1" id="vendorPO" size="30" />
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
									<textarea name="remark" cols="45" rows="5" class="textarea-style" id="remark"></textarea>
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
								<td height="26" align="right">
									<img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Company&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<select name="billCompany" class="input-style1-40fonts" id="billCompany">	
										<option value="-1">&nbsp;</option>
					          		%for st in billTos:
	          							<option value="${st.id}">${st.company|b}</option>
	          						%endfor
          							</select>
								</td>
							</tr>
							<tr>
								<td align="right"><img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Address&nbsp;:&nbsp;</td>
								<td>&nbsp;</td>
								<td>
								% if first_order:
									<textarea name="billAddress" cols="45" rows="5" class="textarea-style" id="billAddress">${first_order.billAddress}</textarea>
								% else:
									<textarea name="billAddress" cols="45" rows="5" class="textarea-style" id="billAddress"></textarea>
								% endif
								</td>
							</tr>
							<tr>
								<td height="26" align="right"><img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Phone&nbsp;:</td>
								<td>&nbsp;</td>
								<td>
								% if first_order:
									<input name="billTel" type="text" class="input-style1" id="billTel" size="30" value="${first_order.billTel}" />
								% else:
									<input name="billTel" type="text" class="input-style1" id="billTel" size="30" />
								% endif
								</td>
							</tr>
							<tr>
								<td height="26" align="right"><img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Fax&nbsp;:</td>
								<td>&nbsp;</td>
								<td>
								% if first_order:
									<input name="billFax" type="text" class="input-style1" id="billFax" size="30" value="${first_order.billFax}" />
								% else:
									<input name="billFax" type="text" class="input-style1" id="billFax" size="30" />
								% endif
								</td>
							</tr>
							<tr>
								<td height="26" align="right"><img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Contact&nbsp;:</td>
								<td>&nbsp;</td>
								<td>
								% if first_order:
									<input name="billAttn" type="text" class="input-style1" id="billAttn" size="30" value="${first_order.billAttn}" />
								% else:
									<input name="billAttn" type="text" class="input-style1" id="billAttn" size="30" />
								% endif
								</td>
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
										<option value="BY OCEAN">BY OCEAN</option>
										<option value="BY AIR">BY AIR</option>
										<option value="BY DHL">BY DHL</option>
										<option value="BY FEDEX">BY FEDEX</option>
										<option value="BY UPS">BY UPS</option>
										<option value="BY TNT">BY TNT</option>
										<option value="BY S.F EXPRESS">BY S.F EXPRESS</option>
										<option value="BY COURIER">BY COURIER</option>
										<option value="BY TRUCK">BY TRUCK</option>
										<option value="BY OTHER">BY OTHER</option>
									</select>
								</td>
							</tr>
							<tr>
								<td height="26" align="right" class="otherInstruction">
									Other Ship Instruction&nbsp;:
								</td>
								<td>&nbsp;</td>
								<td>
									<textarea name="otherInstruction" cols="45" rows="5" class="textarea-style otherInstruction"></textarea>
								</td>
							</tr>
							<tr>
								<td height="26" align="right">Customer Order Date:</td>
								<td>&nbsp;</td>
								<td><input type="text" class="datePicker v_is_date" value="" id="orderDate" name="orderDate" style="width:250px;"></td>
							</tr>
							<tr>
								<td height="26" align="right">Division&nbsp;:</td>
								<td>&nbsp;</td>
								<td><input name="division" type="text" class="input-style1" id="division" size="30" /></td>
							</tr>
							<tr>
								<td height="26" align="right">Country Of Origin&nbsp;:</td>
								<td>&nbsp;</td>
								<td>
									<select id="countryOfOrigin" name="countryOfOrigin">
										<option></option>
										<option value="Bulgarian">Bulgarian</option>
										<option value="Chinese">Chinese</option>
										<option value="Croatian">Croatian</option>
										<option value="English (UK)">English (UK)</option>
										<option value="English (US)">English (US)</option>
										<option value="Eyptian">Eyptian</option>
										<option value="French">French</option>
										<option value="Greek">Greek</option>
										<option value="Hungarian">Hungarian</option>
										<option value="Indonesian (Bahasa)">Indonesian (Bahasa)</option>
										<option value="Italian">Italian</option>
										<option value="Japanese">Japanese</option>
										<option value="Korean">Korean</option>
										<option value="Serbian">Serbian</option>
										<option value="Spanish">Spanish</option>
										<option value="Ukrainian">Ukrainian</option>
									</select>
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
		<td><span id="hint-content">Click 'Confirm' button once qty is entered! Initial order qty for each item should be 250 pcs, and all increase order quantity should be in a multiple number of 250 pcs! If you need to make a change or cancel an order, please contact your r-pac representative within 24 hours!</span></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
</table>
<div style="clear:both">
	&nbsp;&nbsp;
	<input type="image" src="/images/new_item.jpg" onclick="toAdd();return false;"/>
</div>
<br />
<table cellspacing="0" cellpadding="0" border="0" class="gridTable" style="margin-left:10px">
	<thead>
	<tr>
		<td height="35" align="center" class="wt-td">Care Label Item No#</td>
		<td align="center" width="100" class="wt-td">Size</td>
		<!--td align="center" width="100" class="wt-td">Product Description</td-->
		<td align="center" width="150" class="wt-td">Price(per 1000pcs)</td>
		<td align="center" class="wt-td">Quantity</td>
	</tr>
	</thead>
	<tbody>
	<tr>
		<td height="25" class="t-td" style="border-left:1px solid #CCCCCC">
			<select name="clitem_1_ext" class="input-style1-40fonts">
                <option value="0" selected>&nbsp;</option>
                % for i in range(1,11):
                <option value="${i}" selected>CARELABEL-${i}</option>
                % endfor
          	</select>
			<!--input type="text" class="required ajaxSearchField input-style1-40fonts" name="clitem_1_ext" fieldName="clitem_detail" /-->
		</td>
		<td align="center" class="t-td">
			<select name="clsize_1_ext" class="input-style1-40fonts">
                <option value="0" selected>&nbsp;</option>
                <option value="xs/tp/xp">xs/tp/xp</option>
                <option value="s/p/p">s/p/p</option>
                <option value="m/m/m">m/m/m</option>
                <option value="l/g/g">l/g/g</option>
                <option value="xl/tg/xg">xl/tg/xg</option>
                <option value="2T-3T/2A-3A/2A-3A">2T-3T/2A-3A/2A-3A</option>
                <option value="4t-5T/4A-5A/4A-5A">4t-5T/4A-5A/4A-5A</option>
                <option value="s/p/p (socks)">s/p/p (socks)</option>
                <option value="m/m/m (socks)">m/m/m (socks)</option>
                <option value="l/g/g (socks)">l/g/g (socks)</option>
                <option value="0-6 mths">0-6 mths</option>
                <option value="6-12 mths">6-12 mths</option>
                <option value="12-24 mths">12-24 mths</option>
                <option value="12-18 mths">12-18 mths</option>
                <option value="0-3 mths">0-3 mths</option>
                <option value="3-6 mths">3-6 mths</option>
                <option value="18-24 mths">18-24 mths</option>
                <option value="2T/2A/2A">2T/2A/2A</option>
                <option value="3T/3A/3A">3T/3A/3A</option>
                <option value="4T/4A/4A">4T/4A/4A</option>
                <option value="5T/5A/5A">5T/5A/5A</option>
          	</select>
		</td>
		<!--td align="center" class="t-td">
			<select name="artdesc_1_ext" class="input-style1-40fonts">
                <option value="0">please select Article description</option>
                <option value="Bag">Bag</option>
                <option value="Belt">Belt</option>
                <option value="Blazer">Blazer</option>
                <option value="Blouse">Blouse</option>
                <option value="Blouson">Blouson</option>
                <option value="Cap">Cap</option>
                <option value="Cardigan">Cardigan</option>
                <option value="Coat">Coat</option>
                <option value="Cuff">Cuff</option>
                <option value="Dress">Dress</option>
                <option value="Glasses">Glasses</option>
                <option value="Gloves">Gloves</option>
                <option value="hair decoration">hair decoration</option>
                <option value="Hat">Hat</option>
                <option value="Jacket">Jacket</option>
                <option value="Jeans">Jeans</option>
                <option value="Jewellery">Jewellery</option>
                <option value="Leggings">Leggings</option>
                <option value="Pullover">Pullover</option>
                <option value="Scarf">Scarf</option>
                <option value="Shoes">Shoes</option>
                <option value="Shorts">Shorts</option>
                <option value="Skirt">Skirt</option>
                <option value="tie">tie</option>
                <option value="Tights">Tights</option>
                <option value="Top">Top</option>
                <option value="Trousers">Trousers</option>
                <option value="T-Shirt">T-Shirt</option>
                <option value="Tunica">Tunica </option>
                <option value="Turtleneck">Turtleneck </option>
                <option value="waistcoat">waistcoat</option>
                <option value="wallet">wallet</option>
                <option value="Parka">Parka</option>
                <option value="Corset">Corset</option>
                <option value="Bolero">Bolero</option>
                <option value="Head - band">Head - band</option>
            </select>
		</td-->
		<td align="center" class="t-td">30USD</td>
		<td align="center" class="bt-td">
			<input type="text" class="required numeric" name="quantity_1_ext" style="text-align:right;width:150px;" />
		</td>
	</tr>
	<tr id="item_x_ext" class="template" style="display:none">
		<td height="25" class="t-td" style="border-left:1px solid #CCCCCC">
			<select name="clitem_x_ext" class="input-style1-40fonts">
                <option value="0" selected>&nbsp;</option>
                % for i in range(1,11):
                <option value="${i}" selected>CARELABEL-${i}</option>
                % endfor
          	</select>
			<!--input type="text" class="" name="clitem_x_ext" fieldName="clitem_detail" /-->
		</td>
		<td align="center" class="t-td">
			<select name="clsize_x_ext" class="input-style1-40fonts">
                <option value="0" selected>&nbsp;</option>
                <option value="xs/tp/xp">xs/tp/xp</option>
                <option value="s/p/p">s/p/p</option>
                <option value="m/m/m">m/m/m</option>
                <option value="l/g/g">l/g/g</option>
                <option value="xl/tg/xg">xl/tg/xg</option>
                <option value="2T-3T/2A-3A/2A-3A">2T-3T/2A-3A/2A-3A</option>
                <option value="4t-5T/4A-5A/4A-5A">4t-5T/4A-5A/4A-5A</option>
                <option value="s/p/p (socks)">s/p/p (socks)</option>
                <option value="m/m/m (socks)">m/m/m (socks)</option>
                <option value="l/g/g (socks)">l/g/g (socks)</option>
                <option value="0-6 mths">0-6 mths</option>
                <option value="6-12 mths">6-12 mths</option>
                <option value="12-24 mths">12-24 mths</option>
                <option value="12-18 mths">12-18 mths</option>
                <option value="0-3 mths">0-3 mths</option>
                <option value="3-6 mths">3-6 mths</option>
                <option value="18-24 mths">18-24 mths</option>
                <option value="2T/2A/2A">2T/2A/2A</option>
                <option value="3T/3A/3A">3T/3A/3A</option>
                <option value="4T/4A/4A">4T/4A/4A</option>
                <option value="5T/5A/5A">5T/5A/5A</option>
          	</select>
		</td>
		<!--td align="center" class="t-td">
			<select name="artdesc_x_ext" class="input-style1-40fonts">
                <option value="0">please select Article description</option>
                <option value="Bag">Bag</option>
                <option value="Belt">Belt</option>
                <option value="Blazer">Blazer</option>
                <option value="Blouse">Blouse</option>
                <option value="Blouson">Blouson</option>
                <option value="Cap">Cap</option>
                <option value="Cardigan">Cardigan</option>
                <option value="Coat">Coat</option>
                <option value="Cuff">Cuff</option>
                <option value="Dress">Dress</option>
                <option value="Glasses">Glasses</option>
                <option value="Gloves">Gloves</option>
                <option value="hair decoration">hair decoration</option>
                <option value="Hat">Hat</option>
                <option value="Jacket">Jacket</option>
                <option value="Jeans">Jeans</option>
                <option value="Jewellery">Jewellery</option>
                <option value="Leggings">Leggings</option>
                <option value="Pullover">Pullover</option>
                <option value="Scarf">Scarf</option>
                <option value="Shoes">Shoes</option>
                <option value="Shorts">Shorts</option>
                <option value="Skirt">Skirt</option>
                <option value="tie">tie</option>
                <option value="Tights">Tights</option>
                <option value="Top">Top</option>
                <option value="Trousers">Trousers</option>
                <option value="T-Shirt">T-Shirt</option>
                <option value="Tunica">Tunica </option>
                <option value="Turtleneck">Turtleneck </option>
                <option value="waistcoat">waistcoat</option>
                <option value="wallet">wallet</option>
                <option value="Parka">Parka</option>
                <option value="Corset">Corset</option>
                <option value="Bolero">Bolero</option>
                <option value="Head - band">Head - band</option>
            </select-->
        </td>
        <td align="center" class="t-td">30USD</td>
		<td align="center" class="bt-td">
			<input type="text" name="quantity_x_ext" class="numeric" style="text-align:right;width:150px;">
		</td>
		<td align="center" class="t-td">
			<input type="button" name="clear_x_ext" value="Remove" onclick="toRemove(this)" />
		</td>
	</tr>
	</tbody>
</table>
<div style="float: left; padding-left: 800px;">
<br />
<a class="confirm" href="#" onclick="confirmOrder()"><img src="/images/images/menu_confirm_g.jpg"/></a>
&nbsp;&nbsp;
<a href="${return_url}" onclick="return toCancel()"><img src="/images/images/menu_cancel_g.jpg"/></a>
<br />
<br />
<br />
<br />
<br />
<br />
</div>
</form>
<div style="clear:both"><br/><br/></div>