<%inherit file="gapproject.templates.master"/>
<%namespace name="tw" module="tw.core.mako_util"/>
<%
	from gapproject.util.mako_filter import b, na
	from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - GAP - Order Old Navy Care Labels</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/jquery-ui-1.10.3.custom.min.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<style type="text/css">
	.input-width{
		width : 300px
	}
	
	#warning {
		font:italic small-caps bold 16px/1.2em Arial;
	}
	
	.error {
	   background-color: #FFEEEE !important;
	   border: 1px solid #FF6600 !important;
	}
	
	.input-width{
        width : 300px;
    }
    
    .input-style2{
       border: #aaa solid 1px;
        width: 80px;
        background-color: #FFe;
    }
    
    .input-style3 {
        border: #aaa solid 1px;
        width: 150px;
        background-color: #FFe;
    }
    
    .comtable,.caretable{
       border: 1px solid #CCCCCC;
        padding: 5px;
        background: #4e7596;
        margin: 5px 5px 5px 0px;
        color: #FFF;
    }
    
    .template {
        display : none;
    }
    
    .label{
       background-color: #4e7596;
        border-bottom: #FFF solid 1px;
        padding-right: 10px;
        font-family: Tahoma, Geneva, sans-serif;
        color: #fff;
        font-size: 12px;
        font-weight: bold;
        text-decoration: none;
        
    }
    
    .num{
        text-align : right;
    }
</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<!-- <script type="text/javascript" src="/javascript/jquery-ui-1.9.2.custom.min.js" language="javascript"></script> -->
<script type="text/javascript" src="/javascript/jquery-ui-.10.3.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/oncl_form.js" language="javascript"></script>
<script language="JavaScript" type="text/javascript">
//<![CDATA[
        $(document).ready(function(){
            loadCare();
            loadWarn();
            loadContent();
            $(".pcominput").numeric();
            $(".num").numeric();
            $( "#layoutinfo" ).dialog({
                  resizable: true,
                  height:500,
                  width: 800,
                  modal: true,
                  //position : "center",
                  autoOpen : false,
                  buttons: {
                    "Confirm": function() {
                        toLayoutSubmit();
                        //$( this ).dialog( "close" );
                    },
                    Cancel: function() {
                      $( this ).dialog( "close" );
                    }
                  }
                });
                
        });
        
        function showAddress(k){
            var obj = $(k);
            if(obj.val() == 'View Detail'){
                $(".address_tr").show();
                obj.val('Hide Detail');
            }else{
                $(".address_tr").hide();
                obj.val('View Detail');
            }
        }
        
        function changeAdd(){
            var v = $("#addressID").val();
            if(v == 'OTHER'){
                $("input,textarea","#billTbl").val('');
                $("input,textarea","#shipTbl").val('');
                $(".address_tr").show();
                $("#viewbtn").val('Hide Detail');
            }else{
                var params = {
                    addressID : v,
                    t : Date.parse(new Date())
                }
                $.getJSON('/oncl/ajaxAddress',params,function(r){
                    if(r.code != 0 ){
                        alert(r.msg);                    
                    }else{
                        var fs = ["shipCompany","shipAttn","shipAddress","shipAddress2","shipAddress3","shipCity","shipState",\
                                "shipZip","shipCountry","shipTel","shipFax","shipEmail","shipRemark","billCompany","billAttn",\
                                "billAddress","billAddress2","billAddress3","billCity","billState","billZip","billCountry","billTel",\
                                "billFax","billEmail","billRemark",];
                        for(var i=0;i<fs.length;i++){
                            $("#"+fs[i]).val(r[fs[i]]);
                        }
                        
                        $(".address_tr").hide();
                        $("#viewbtn").val('View Detail');
                    }
                })
            }
        }
//]]>
</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
  	<td width="64" valign="top" align="left"><a href="/index"><img src="/images/images/menu_return_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Order Old Navy Care Labels</div>

<form id="orderForm" action="/oncl/saveorder" method="post">
<input type="hidden" name="status" id="status" value=""/>
<div style="width:1000px">
<table width="1000" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="15">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
	   <td>&nbsp;</td>
	   <td height="50" colspan="2" bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;"><strong>Address Books :</strong> 
	       <select id="addressID" name='addressID' class="input-style1" onchange="changeAdd()">
	           %for a in address:
	               <option value="${a.id}">Ship To : ${a.shipCompany} --- Bill To : ${a.billCompany}</option>
	           %endfor
	               <option value="OTHER">Other</option>
	       </select>
	       &nbsp;<input type="button" class="btn" id="viewbtn" value="View Detail" onclick="showAddress(this)"/>
	   </td>
	</tr>
	<tr><td>&nbsp;</td></tr>
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
									<strong>&nbsp;&nbsp;&nbsp;&nbsp;Bill To&nbsp;:</strong>
								</td>
								<td>
									<img src="/images/search_10.jpg" width="380" height="2" />
								</td>
							</tr>
						</table>
						</td>
						<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="70">
									<strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ship To&nbsp;:</strong>
								</td>
								<td>
									<img src="/images/search_10.jpg" width="380" height="2" />
								</td>
							</tr>
						</table>
						</td>
					</tr>
					%if len(address) > 0:
					   <tr style="display:none" class="address_tr">
					%else:
					   <tr class="address_tr">
					%endif
						<td width="50%" valign="top">
    						<table border="0" cellpadding="0" cellspacing="0" style="padding: 0; margin: 0;" id="billTbl">
                                        <tbody><tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td width="10">
                                                &nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Company
                                                    Name&nbsp;: 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billCompany" class="input-style1 valid" name="billCompany" size="30" style="margin: 4px 0 4px 0;" type="text" value="${values.get('billCompany','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                &nbsp;Attention&nbsp;:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billAttn" class="input-style1" name="billAttn" size="30" type="text" value="${values.get('billAttn','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Address 1&nbsp;:&nbsp; 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="billAddress" class="textarea-style valid" cols="45" name="billAddress" rows="3">${values.get('billAddress','')}</textarea>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="label">
                                                &nbsp;Address 2&nbsp;:&nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="billAddress2" class="textarea-style valid" cols="45" name="billAddress2" rows="3" style="margin: 2px 0;">${values.get('billAddress2','')}</textarea>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="label">
                                                &nbsp;Address 3&nbsp;:&nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="billAddress3" class="textarea-style valid" cols="45" name="billAddress3" rows="3">${values.get('billAddress3','')}</textarea>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;City/Town&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billCity" class="input-style1 valid" name="billCity" size="30" type="text" value="${values.get('billCity','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;State&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billState" class="input-style1 valid" name="billState" size="30" type="text" value="${values.get('billState','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                &nbsp;Zip Code&nbsp;:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billZip" class="input-style1 valid" name="billZip" size="30" type="text" value="${values.get('billZip','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                
                                                <sup><span style="color:red">*</span></sup> &nbsp;Country&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billCountry" class="input-style1 valid" name="billCountry" size="30" type="text" value="${values.get('billCountry','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Phone
                                                    #&nbsp;: 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billTel" class="input-style1 valid" name="billTel" size="30" type="text" value="${values.get('billTel','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                &nbsp;Fax #&nbsp;:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billFax" class="input-style1" name="billFax" size="30" type="text" value="${values.get('billFax','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Email&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billEmail" class="input-style1 valid" name="billEmail" size="30" type="text" value="${values.get('billEmail','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                Remark&nbsp;:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="billRemark" class="textarea-style" cols="45" name="billRemark" rows="3">${values.get('billRemark','')}</textarea>
                                            </td>
                                        </tr>
                                    </tbody></table>
                        </td>
						<td width="50%" valign="top">
    						<table border="0" cellpadding="0" cellspacing="0" style="padding: 0; margin: 0;" id="shipTbl">
                                <tbody>
                                <tr>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td width="10">
                                        &nbsp;
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;Company&nbsp;Name:
                                        
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipCompany" class="input-style1 valid" name="shipCompany" size="30" style="margin: 4px 0 4px 0;" type="text" value="${values.get('shipCompany','')}"  >
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        &nbsp;Attention&nbsp;:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipAttn" class="input-style1" name="shipAttn" size="30" type="text" value="${values.get('shipAttn','')}">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;Address 1&nbsp;:&nbsp; 
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <textarea id="shipAddress" class="textarea-style valid" cols="45" name="shipAddress" rows="3">${values.get('shipAddress','')}</textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" class="label">
                                        &nbsp;Address 2&nbsp;:&nbsp;
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <textarea id="shipAddress2" class="textarea-style valid" cols="45" name="shipAddress2" rows="3" style="margin: 2px 0;">${values.get('shipAddress2','')}</textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" class="label">
                                        &nbsp;Address 3&nbsp;:&nbsp;
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <textarea id="shipAddress3" class="textarea-style valid" cols="45" name="shipAddress3" rows="3">${values.get('shipAddress3','')}</textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;City/Town&nbsp;:
                                        
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipCity" class="input-style1 valid" name="shipCity" size="30" type="text" value="${values.get('shipCity','')}">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;State&nbsp;:
                                        
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipState" class="input-style1 valid" name="shipState" size="30" type="text" value="${values.get('shipState','')}">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        &nbsp;Zip Code&nbsp;:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipZip" class="input-style1 valid" name="shipZip" size="30" type="text" value="${values.get('shipZip','')}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;Country&nbsp;:
                                        
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipCountry" class="input-style1 valid" name="shipCountry" size="30" type="text" value="${values.get('shipCountry','')}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;Phone
                                            #&nbsp;: 
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipTel" class="input-style1 valid" name="shipTel" size="30" type="text" value="${values.get('shipTel','')}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        &nbsp;Fax #&nbsp;:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipFax" class="input-style1" name="shipFax" size="30" type="text" value="${values.get('shipFax','')}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;Email&nbsp;:
                                        
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipEmail" class="input-style1 valid" name="shipEmail" size="30" type="text" value="${values.get('shipEmail','')}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        Remark&nbsp;:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <textarea id="shipRemark" class="textarea-style" cols="45" name="shipRemark" rows="3">${values.get('shipRemark','')}</textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        Special Instructions&nbsp;:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <textarea id="shipInstructions" class="textarea-style" cols="45" name="shipInstructions" rows="3"></textarea>
                                    </td>
                                </tr>                                              
                            </tbody></table>
						</td>
						
					</tr>
					<tr><td>&nbsp;</td></tr>
					<tr>
					   <td colspan="2">
    					   <p style="text-align:right; padding:0px 0px 0px 50px">
                            <input type="button" onclick="showInfo()" class="btn" value="Request for quote">
                            </p> 
					   </td>
					</tr>
					<tr><td>&nbsp;</td></tr>
					<tr>
                        <td colspan="2">
                        
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tbody><tr>
                                <td width="100" height="24" bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;">
                                    <strong>Order Info&nbsp;:</strong>
                                    </td>
                                  <td bgcolor="#669999">&nbsp;</td>
                            </tr>
                        </tbody></table>
                        </td>
                        
                    </tr>
                    <!-- new field begin -->
                    <tr>
                        <td valign="top" colspan="2">
                            <table border="0" cellspacing="0" cellpadding="0" style="width:850px">
                                <tbody><tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td style="width:10px;">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup>Old Navy PO Number
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <input name="onclpo" id="onclpo" type="text" class="input-style1">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label" style="font-weight: normal;">
                                        Vendor PO Number
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <input name="vendorpo" id="vendorpo" type="text" class="input-style1">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup>Item Code
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="itemId" id="itemId" class="input-style1" onchange='onChangeItem(this)'>
                                            <option value="" ref=''></option>
                                            %for item in items:
                                                <option value="${item.id}" ref='${item.desc}'>${item}</option>
                                            %endfor
                                        </select>
                                        <br />
                                        <p><span id='itemcodedesc'></span></p>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup>r-pac manufacturing location</td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="printShopId" id="printShopId" class="input-style1">
                                            <option value=""></option>
                                            %for l in locations:
                                                <option value="${l.id}">${l}</option>
                                            %endfor
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup>Department</td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="divisionId" id="divisionId" class="input-style1" onchange='onChangeDivision(this)'>
                                            <option value=""></option>
                                            %for d in divisions:
                                                <option value="${d.id}">${d}</option>
                                            %endfor                                            
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup>Category
                                    </td>
                                    <td>&nbsp;</td>
                                    <td><select name="categoryId" id="categoryId" class="input-style1" onchange='onChangeCategory(this)'></select></td>
                                </tr>
                                
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                            </tbody></table>
                        </td>
                    </tr>
                    <!-- new field end -->
                    <tr>
                        <td valign="top" colspan="2">
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tbody>
                                 <tr>
                                    <td width="100" height="24" bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;">
                                      <strong>Layout Info&nbsp;:</strong>
                                      </td>
                                    <td bgcolor="#669999">&nbsp;</td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <!-- care label field end -->
                    <tr>
                        <td valign="top" colspan="2">
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tbody><tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td style="width:10px;">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                
                                <tr class="realCom">
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup>Fabric Content:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <table class="comtable">
                                            <tr>
                                                <td>Garment Part</td>
                                                <td><select name="com10" class="input-style1 comselect">
                                                        <option value="NOSELECTED"></option>
                                                        <option value="" selected="selected">NONE</option>
                                                        %for s in sections:
                                                            <option value="${s.id}">${s}</option>
                                                        %endfor
                                                    </select/>
                                                </td>
                                                <td><input type="button" class="btn" value="Add" onclick="addCom()"/></td>
                                            </tr>
                                            <tr>
                                                <td>Content</td>
                                                <td>
                                                    <select name="fcom10_10" class="input-style1 fcomselect">
                                                        
                                                    </select>
                                                    &nbsp;
                                                    <input type="text" name="pcom10_10" class="input-style2 pcominput" value=""/>%
                                                </td>
                                                <td><input type="button" class="btn" value="Add" onclick="addFP(this)"/></td>
                                            </tr>
                                        </table>
                                    
                                    </td>
                                </tr>
                                <tr class="com template">
                                    <td height="26" align="right">&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <table class="comtable">
                                            <tr>
                                                <td>Garment Part</td>
                                                <td>
                                                    <select name="com" class="input-style1 comselect">
                                                        <option value="NOSELECTED"></option>
                                                        <option value="" selected="selected">NONE</option>
                                                        %for s in sections:
                                                            <option value="${s.id}">${s}</option>
                                                        %endfor
                                                    </select/>
                                                </td>
                                                <td><input type="button" class="btn" value="Delete" onclick="delCom(this)"/></td>
                                            </tr>
                                            <tr>
                                                <td>Content</td>
                                                <td>
                                                    <select name="" class="input-style1 fcomselect">
                                                        
                                                    </select>
                                                    &nbsp;
                                                    <input type="text" name="" class="input-style2 pcominput" value=""/>%
                                                </td>
                                                <td><input type="button" class="btn" value="Add" onclick="addFP(this)"/></td>
                                            </tr>
                                            
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup>Care Instructions:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        %for label,value in [("Wash","wash"),("Bleach","bleach"),("Dry","dry"),("Iron","iron"),("Professional textile care (Dry Clean)","dryclean"),("Special Care","specialcare")]:
                                            <table class="caretable">
                                                <tr>
                                                    <td style="width:200px">${label}</td>
                                                    <td><select name="care_${value}_10" class="input-style1">
                                                            
                                                        </select/>
                                                    </td>
                                                    <td><input type="button" class="btn" value="Add" onclick="addCare(this);"/></td>
                                                </tr>
                                                <tr class="template">
                                                    <td style="width:200px">&nbsp;</td>
                                                    <td><select name="care_${value}_xx" class="input-style1">
                                                        </select/>
                                                    </td>
                                                    <td><input type="button" class="btn" value="Delete" onclick="delCare(this);"/></td>
                                                </tr>
                                            </table>
                                        %endfor
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup>Country of Origin:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="coId" id="coId"  class="input-style1">
                                            <option value=""></option>
                                            %for c in cos:
                                                <option value="${c.id}">${c}</option>
                                            %endfor
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup>Warnings:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="warning01" class="input-style1">
                                        </select>&nbsp;<input type="button" value="Add" class="btn" onclick="addWarn()"/>
                                    </td>
                                </tr>
                                <tr class="warning template">
                                    <td height="26" align="right">&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="warning" class="input-style1">
                                        </select>&nbsp;<input type="button" value="Delete" class="btn" onclick="delWarn(this)"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                            </tbody></table>
                           
                        </td>
                    </tr>
                    <!-- care label field end -->
                    <!-- tracing begin -->
                    <tr>
                        <td valign="top" colspan="2">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tbody>
                                <tr>
                                  <td width="600" height="24" bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;"><strong>Traceability info (add to care label)&nbsp;:&nbsp;<span style="color:red">OPTIONAL</span></strong>
                                    </td>
                                  <td bgcolor="#669999">&nbsp;</td>
                                  </tr>
                            </tbody>
                        </table>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top" colspan="2">
                            <table border="0" cellspacing="0" cellpadding="0" style="width:850px;">
                                <tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td style="width:10px">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Style#</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="styleNo" id="styleNo" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Color Code</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="colorCode" id="colorCode" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Style Description</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="styleDesc" id="styleDesc" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">CC Description</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="ccDesc" id="ccDesc" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Vendor</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="vendor" id="vendor" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Season</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="season" id="season" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Month/Year Of Manufacture</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="manufacture" id="manufacture" value="" class="input-style1"/></td>
                                </tr>
                            </table>
                        </td>
                    </tr>                        
                    <!-- tracing end -->
                    <tr><td>&nbsp;</td></tr>
                    <!-- size begin -->
                    <tr>
                        <td valign="top" colspan="2">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tbody>
                                <tr>
                                  <td width="100" height="24" bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;"><strong>Size&nbsp;:</strong>
                                    </td>
                                  <td bgcolor="#669999">&nbsp;</td>
                                  </tr>
                            </tbody>
                        </table>
                        </td>
                    </tr>
                    <tr><td>&nbsp;</td></tr>
                    <tr>
                        <td colspan="2">
                            <table cellspacing="0" cellpadding="0" border="0" class="gridTable" id="sizetb" style="background:white">
                                <thead>
                                    <tr style="text-align: center;">                     
                                        <th style="width:200px">Fit</th>
                                        <th style="width:250px">Size</th>
                                        <th style="width:150px">Qty</th>
                                        <th style="width:150px">Round Up Qty</th>
                                        <th style="width:100px">&nbsp;</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="size_tr">
                                        <td style="border-left: #ccc solid 1px;"><select name="fitId10" class="input-style3" onchange="onChangeFit(this)"></select></td>
                                        <td><select name="sizeId10" class="input-style3" onchange="onChangeSize(this)"></select></td>
                                        <td><input name="qty10" type="text" class="input-style2 num" onchange="chqty(this)"/><input type="hidden" name="scontent10" value=""/></td>
                                        <td>&nbsp;<span class="roundup"></span></td>
                                        <td><input type="button" class="btn" value="Add" onclick="addSize()"/></td>
                                    </tr>
                                    <tr class="size_template template">
                                        <td style="border-left: #ccc solid 1px;"><select name="fitId" class="input-style3" onchange="onChangeFit(this)"></select></td>
                                        <td><select name="sizeId" class="input-style3" onchange="onChangeSize(this)"></select></td>
                                        <td><input name="qty" type="text" class="input-style2 num" onchange="chqty(this)"/><input type="hidden" name="scontent" value=""/></td>
                                        <td>&nbsp;<span class="roundup"></span></td>
                                        <td><input type="button" class="btn" value="Delete" onclick="delSize(this)"/></td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <!-- size end -->
				</table>
                                            
               <p style="text-align:right; padding:0px 0px 0px 50px">
                    <input type="button" onclick="showInfo()" class="btn" value="Request for quote">
                    </p>      
				</td>

			</tr>
		</table>
		</td>
	</tr>
</table>
</div>
<br />
<div>
    
</div>
</form>



<div style="display:none">
    <table>
        <tr id='material_template'>
            <td>&nbsp;</td>
            <td>
                <select name="" class="input-style1 fcomselect">
                    
                </select>
                &nbsp;
                <input type="text" name="" class="input-style2 pcominput" value=""/>%
            </td>
            <td><input type="button" class="btn" value="Delete" onclick="delFP(this)"/></td>
        </tr>
    </table>
</div>


<div style="display:none" id="layoutinfo" >
  <table cellspacing="3" cellpadding="3" style="">
      <tr>
          <td style="width:150px">Old Navy care label : </td><td id="item_td"></td>
      </tr>
      <tr>
          <td>Size : </td><td id="size_td"></td>
      </tr>
      <tr>
          <td>Country of Origin : </td><td id="co_td"></td>
      </tr>
      <tr>
          <td colspan="2">RN 54023 CA 17897</td>
      </tr>
      <tr>
          <td valign="top">Fabric Content : </td><td id="com_td"></td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
          <td valign="top">Care Instructions : </td><td id="care_td"></td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
          <td valign="top">Warnings : </td><td id="warn_td"></td>
      </tr>
      <tr>
        <td valign="top">Care Symbols : </td>
        <td id="symbols_td">
            <table id='symbol_tb'></table>
        </td>
      </tr>
  </table>
</div>

<div style="clear:both"></div>
