<%inherit file="gapproject.templates.master"/>
<%namespace name="tw" module="tw.core.mako_util"/>
<%
	from gapproject.util.mako_filter import b, na,roundup250
	from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - GAP - Order Old Navy Care Labels</%def>

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
	
	.title2{
	   color : #4e7596;
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
	
	.tdct {
	   border-bottom : 1px solid #ccc;
	   border-left : 1px solid #ccc;
	   border-right : 1px solid #ccc;
       background-color: #feffdc;
       padding-left: 10px;
	}
	
	.tdcttop {
	   border-top : 1px solid #ccc;
	}
	
	.tdctleft {
       border-left : 1px solid #ccc;
    }
	
	.tbbd {
	   border: #999 solid 2px;
	}
	
	.innertb {
	   padding : 3px;
	}
	
	.innertb td {
	   padding : 5px;
	}
	
	.num{
        text-align : right;
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
	
	.template {
        display : none;
    }
</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>

<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.ui.datepicker.validation.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/ui.datepicker.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/oncl_form.js?v=2" language="javascript"></script>
<script language="JavaScript" type="text/javascript">
//<![CDATA[
    $(document).ready(function(){
        $(".num").numeric();
    });
    
    function toSubmit(){
        var msg = [];
        
        $(".error").removeClass("error");
        
        var fields = ['shipCompany','billCompany','shipAddress','billAddress',
                      'shipCity','billCity','shipState','billState',
                      'shipCountry','billCountry','shipTel','billTel','shipEmail','billEmail'];
        var allOK = true;         
        for(var i=0;i<fields.length;i++){
            var name = fields[i];
            if(!$("#"+name).val()){
                $("#"+name).addClass('error');
                allOK = false;
            }
        }
        if(!allOK){ msg.push('Please fill in the required field(s)!'); }
        
        var qtyOK = true;
        
        $(".num").each(function(){
            var t = $(this);
            if(!t.val() || !check_number(t.val())){
                t.addClass(".error");
                qtyOK = false;
            }
        });
        if(!allOK){ msg.push('Please fill in the required field(s)!'); }
        
        if(msg.length > 0){
            var m = '<ul>';
            for(var i=0;i<msg.length;i++){ m += '<li>' + msg[i] + '</li>'; }
            m += '</ul>';
            showError(m);
            return;
        }else{
            $(".template").remove();
            $("form").submit();
        }        

    }
    
    function toCancel(){
        if(window.confirm('Are you sure to leave this page without saving your edit?')){
            window.location.href = '/oncl/viewOrder?id=${obj.id}';
        }
    }
//]]>
</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="64" valign="top" align="left"><a href="/oncl/tracking"><img src="/images/images/menu_return_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;View Old Navy Care Labels</div>
<div style="width:1000px">
<form id="orderForm" action="/oncl/saveupdate" method="post">
<input type="hidden" name="id" value="${obj.id}"/>
<table width="1000" border="0" cellspacing="0" cellpadding="0">
        <tbody>
        <tr>
            <td width="15">&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tbody>
                 
                  <tr>
                    <td align="left" valign="top">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tbody>
                         <tr>
                            <td height="50"  bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;">Order No : ${obj.no}</td>
                            <td height="50"  bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;">Order Date : ${obj.createTime.strftime("%Y-%m-%d %H:%M")}</td>
                          </tr>
                        <tr><td>&nbsp;</td></tr>
                        <tr>
                            <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tbody><tr>
                                    <td width="70">
                                        <strong>&nbsp;&nbsp;&nbsp;&nbsp;Bill To&nbsp;:</strong>
                                    </td>
                                    <td><img src="/images/search_10.jpg" width="380" height="2"></td>
                                </tr>
                            </tbody></table>
                            </td>

                            <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tbody><tr>
                                    <td width="70">
                                        <strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ship To&nbsp;:</strong>
                                    </td>
                                    <td><img src="/images/search_10.jpg" width="380" height="2"></td>
                                </tr>
                            </tbody></table>
                            </td>
                        </tr>
                        <tr>
                            <td width="50%" valign="top">
                                <table border="0" cellpadding="0" cellspacing="0" style="padding: 0; margin: 0;" id="billTbl">
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
                                                <sup><span style="color:red">*</span></sup> &nbsp;Company
                                                    Name&nbsp;: 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billCompany" class="input-style1 valid" name="billCompany" size="30" style="margin: 4px 0 4px 0;" type="text" value="${obj.billCompany}">
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
                                                <input id="billAttn" class="input-style1" name="billAttn" size="30" type="text" value="${obj.billAttn}"/>
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
                                                <textarea id="billAddress" class="textarea-style valid" cols="45" name="billAddress" rows="3">${obj.billAddress}</textarea>
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
                                                <textarea id="billAddress2" class="textarea-style valid" cols="45" name="billAddress2" rows="3" style="margin: 2px 0;">${obj.billAddress2}</textarea>
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
                                                <textarea id="billAddress3" class="textarea-style valid" cols="45" name="billAddress3" rows="3">${obj.billAddress3}</textarea>
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
                                                <input id="billCity" class="input-style1 valid" name="billCity" size="30" type="text" value="${obj.billCity}"/>
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
                                                <input id="billState" class="input-style1 valid" name="billState" size="30" type="text" value="${obj.billState}"/>
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
                                                <input id="billZip" class="input-style1 valid" name="billZip" size="30" type="text" value="${obj.billZip}"/>
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
                                                <input id="billCountry" class="input-style1 valid" name="billCountry" size="30" type="text" value="${obj.billCountry}"/>
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
                                                <input id="billTel" class="input-style1 valid" name="billTel" size="30" type="text" value="${obj.billTel}"/>
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
                                                <input id="billFax" class="input-style1" name="billFax" size="30" type="text" value="${obj.billFax}"/>
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
                                                <input id="billEmail" class="input-style1 valid" name="billEmail" size="30" type="text" value="${obj.billEmail}"/>
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
                                                <textarea id="billRemark" class="textarea-style" cols="45" name="billRemark" rows="3">${obj.billRemark}</textarea>
                                            </td>
                                        </tr>
                                    </tbody>
                                 </table>
                            </td>
                            <td width="50%" valign="top">
                                <table border="0" cellpadding="0" cellspacing="0" style="padding: 0; margin: 0;" id="shipTbl">
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
                                                <sup><span style="color:red">*</span></sup> &nbsp;Company&nbsp;Name:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="shipCompany" class="input-style1 valid" name="shipCompany" size="30" style="margin: 4px 0 4px 0;" type="text" value="${obj.shipCompany}">
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
                                                <input id="shipAttn" class="input-style1" name="shipAttn" size="30" type="text" value="${obj.shipAttn}">
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
                                                <textarea id="shipAddress" class="textarea-style valid" cols="45" name="shipAddress" rows="3">${obj.shipAddress}</textarea>
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
                                                <textarea id="shipAddress2" class="textarea-style valid" cols="45" name="shipAddress2" rows="3" style="margin: 2px 0;">${obj.shipAddress2}</textarea>
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
                                                <textarea id="shipAddress3" class="textarea-style valid" cols="45" name="shipAddress3" rows="3">${obj.shipAddress3}</textarea>
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
                                                <input id="shipCity" class="input-style1 valid" name="shipCity" size="30" type="text" value="${obj.shipCity}">
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
                                                <input id="shipState" class="input-style1 valid" name="shipState" size="30" type="text" value="${obj.shipState}">
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
                                                <input id="shipZip" class="input-style1 valid" name="shipZip" size="30" type="text" value="${obj.shipZip}"/>
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
                                                <input id="shipCountry" class="input-style1 valid" name="shipCountry" size="30" type="text" value="${obj.shipCountry}"/>
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
                                                <input id="shipTel" class="input-style1 valid" name="shipTel" size="30" type="text" value="${obj.shipTel}"/>
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
                                                <input id="shipFax" class="input-style1" name="shipFax" size="30" type="text" value="${obj.shipFax}"/>
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
                                                <input id="shipEmail" class="input-style1 valid" name="shipEmail" size="30" type="text" value="${obj.shipEmail}"/>
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
                                                <textarea id="shipRemark" class="textarea-style" cols="45" name="shipRemark" rows="3">${obj.shipRemark}</textarea>
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
                                                <textarea id="shipInstructions" class="textarea-style" cols="45" name="shipInstructions" rows="3">${obj.shipInstructions}</textarea>
                                            </td>
                                        </tr>                                              
                                    </tbody></table>
                            </td>
                        </tr>
                        <tr><td>&nbsp;</td></tr>
                        <tr>
                           <td colspan="2">
                               <p style="text-align:right; padding:0px 0px 0px 50px">
                                <input type="button" onclick="toSubmit()" class="btn" value="Save">&nbsp;
                                <input type="button" onclick="toCancel()" class="btn" value="Cancel">
                               </p> 
                           </td>
                        </tr>
                    </tbody></table>
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
                            <table border="0" cellspacing="0" cellpadding="0" style="width:100%">
                                <tbody><tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Old Navy PO Number&nbsp;:</td>
                                    <td class="tdct tdcttop">${obj.onclpo}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Vendor PO Number&nbsp;:</td>
                                    <td class="tdct">${obj.vendorpo}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Item Code&nbsp;:</td>
                                    <td class="tdct">${obj.itemCopy}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">r-pac manufacturing location&nbsp;:</td>
                                    <td class="tdct">${obj.printShopCopy}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Department&nbsp;:</td>
                                    <td class="tdct">${obj.divisionCopy}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Category&nbsp;:</td>
                                    <td class="tdct">${obj.categoryCopy}</td>
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
                            <tbody><tr>
                                <td width="100" height="24" bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;">
                                  <strong>Layout Info&nbsp;:</strong>
                                  </td>
                                <td bgcolor="#669999">&nbsp;</td>
                            </tr>
                        </tbody></table>
                        </td>
                    </tr>
                    <!-- care label field begin -->
                    <tr>
                        <td valign="top">
                            <table border="0" cellspacing="0" cellpadding="0" style="width:100%">
                                <tbody><tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>                               
                                <tr class="realCom">
                                    <td height="26" align="right" class="label">Fabric Content:</td>
                                    <td class="tdct tdcttop">                                        
                                        <table style="width:100%" class="innertb">
                                            <tr>
                                                <td><strong>Index</strong></td>
                                                <td style="width:16%"><strong>English</strong></td>
                                                <td style="width:16%"><strong>Canada-French</strong></td>
                                                <td style="width:16%"><strong>Indonesian</strong></td>
                                                <td style="width:16%"><strong>Japanese</strong></td>
                                                <td style="width:16%"><strong>Chinese</strong></td>
                                                <td style="width:5%"><strong>Percentage</strong></td>
                                            </tr>
                                            %for indexx, d in enumerate(coms):
                                                <tr style="color:blue">
                                                    <td class="tdcttop">Garment Part ${indexx+1}</td>
                                                    <td class="tdcttop tdctleft">${d['E']}</td>
                                                    <td class="tdcttop tdctleft">${d['F']}</td>
                                                    <td class="tdcttop tdctleft">${d['I']}</td>
                                                    <td class="tdcttop tdctleft">${d['J']}</td>
                                                    <td class="tdcttop tdctleft">${d['C']}</td>
                                                    <td class="tdcttop tdctleft">&nbsp;</td>
                                                </tr>
                                                %for indexy,i in enumerate(d['data']):
                                                    <tr>
                                                        <td class="tdcttop">Content ${indexx+1}.${indexy+1}</td>
                                                        <td class="tdcttop tdctleft">${i['E']}</td>
                                                        <td class="tdcttop tdctleft">${i['F']}</td>
                                                        <td class="tdcttop tdctleft">${i['I']}</td>
                                                        <td class="tdcttop tdctleft">${i['J']}</td>
                                                        <td class="tdcttop tdctleft">${i['C']}</td>
                                                        <td class="tdcttop tdctleft">${i['PERCENTAGE']}%</td>
                                                    </tr>
                                                %endfor
                                            %endfor
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Care Instructions:</td>
                                    <td class="tdct">
                                        <table style="width:100%" class="innertb">
                                            <tr>
                                                <td><strong>Index</strong></td>
                                                <td style="width:19%"><strong>English</strong></td>
                                                <td style="width:19%"><strong>Canada-French</strong></td>
                                                <td style="width:19%"><strong>Indonesian</strong></td>
                                                <td style="width:19%"><strong>Japanese</strong></td>
                                                <td style="width:19%"><strong>Chinese</strong></td>
                                            </tr>
                                            %for label,key in [("Wash","wash"),("Bleach","bleach"),("Dry","dry"),("Iron","iron"),("Professional textile care (Dry Clean)","dryclean"),("Special Care","specialcare")]:
                                                %if key in cares:
                                                    <tr>
                                                        <td colspan="6">${label}</td>
                                                    </tr>
                                                    %for index,(e,f,i,j,c) in enumerate(zip(*cares[key])):
                                                        <tr>
                                                            <td class="tdcttop">${index+1}</td>
                                                            <td class="tdcttop tdctleft">${e}</td>
                                                            <td class="tdcttop tdctleft">${f}</td>
                                                            <td class="tdcttop tdctleft">${i}</td>
                                                            <td class="tdcttop tdctleft">${j}</td>
                                                            <td class="tdcttop tdctleft">${c}</td>
                                                        </tr>
                                                    %endfor
                                                %endif
                                            %endfor
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        Country of Origin:
                                    </td>
                                    <td class="tdct">${clobj.coCopy}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Warnings:</td>
                                    <td class="tdct">   
                                        <table style="width:100%" class="innertb">
                                            <tr>
                                                <td><strong>Index</strong></td>
                                                <td style="width:20%"><strong>English</strong></td>
                                                <td style="width:20%"><strong>Canada-French</strong></td>
                                                <td style="width:20%"><strong>Indonesian</strong></td>
                                                <td style="width:20%"><strong>Japanese</strong></td>
                                                <td style="width:20%"><strong>Chinese</strong></td>
                                            </tr>
                                            %for index,(e,f,i,j,c) in enumerate(zip(*warns)):
                                                <tr>
                                                    <td class="tdcttop">${index+1}</td>
                                                    <td class="tdcttop tdctleft">${e}</td>
                                                    <td class="tdcttop tdctleft">${f}</td>
                                                    <td class="tdcttop tdctleft">${i}</td>
                                                    <td class="tdcttop tdctleft">${j}</td>
                                                    <td class="tdcttop tdctleft">${c}</td>
                                                </tr>
                                            %endfor
                                        </table>
                                    </td>
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
                        <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tbody><tr>
                                <td width="300" height="24" bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;"><strong>Traceability info (add to care label)&nbsp;:</strong>
                                 </td>
                                <td bgcolor="#669999">&nbsp;</td>
                            </tr>
                        </tbody></table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table border="0" cellspacing="0" cellpadding="0" style="width:100%">
                                <tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Style# :</td>
                                    <td class="tdct tdcttop">${clobj.styleNo}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Color Code :</td>
                                    <td class="tdct">${clobj.colorCode}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Style Description :</td>
                                    <td class="tdct">${clobj.styleDesc}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">CC Description :</td>
                                    <td class="tdct">${clobj.ccDesc}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Vendor :</td>
                                    <td class="tdct">${clobj.vendor}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Season :</td>
                                    <td class="tdct">${clobj.season}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Month/Year Of Manufacture :</td>
                                    <td class="tdct">${clobj.manufacture}</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                            </table>
                        </td>
                    </tr>                        
                    <!-- tracing end --> 
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
                            <table cellspacing="0" cellpadding="0" border="0" class="gridTable" id="sizetb" style="background-color: #feffdc;width:100%">
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
                                    %for v in sizes:
                                        <tr class="size_tr">
                                            <td>
                                                <select name="oldFitId${v['ID']}" onchange="onChangeFit(this)" ${tw.attrs([('disabled',len(fits)<1)])} class="input-style3">
                                                    <option value=""></option>
                                                    %for f in fits:
                                                        <option value="${f['id']}" ${tw.attrs([('selected',unicode(f['id']) == unicode(v['F']))])}>${f['name']}</option>
                                                    %endfor
                                                </select>
                                            </td>
                                            <td>
                                                <select name="oldSizeId${v['ID']}" class="input-style3">
                                                    %for s in v['sizerange']:
                                                        <option value="${s['id']}" ref="${s['ref']}" ${tw.attrs([('selected',unicode(v['S']) == unicode(s['id']))])}>${s['name']}</option>
                                                    %endfor
                                                </select>
                                            </td>
                                            <td><input type="text" name="oldQty${v['ID']}" value="${v['RQ']}" class="input-style2 num" onchange="chqty(this)"/></td>
                                            <td><span class="roundup">${v['RQ']}</span></td>
                                            <td><input type="button" class="btn" value="Delete" onclick="delSize(this)"/></td>
                                        </tr>
                                    %endfor
                                       <tr class="size_template template">
                                            <td style="border-left: #ccc solid 1px;">
                                                <select name="fitId" class="input-style3" onchange="onChangeFit(this)" ${tw.attrs([('disabled',len(fits)<1)])}>
                                                    <option value=""></option>
                                                    %for f in fits:
                                                        <option value="${f['id']}">${f['name']}</option>
                                                    %endfor
                                                </select>
                                            </td>
                                            <td><select name="sizeId" class="input-style3"></select></td>
                                            <td><input name="qty" type="text" class="input-style2 num" onchange="chqty(this)"/></td>
                                            <td>&nbsp;<span class="roundup"></span></td>
                                            <td><input type="button" class="btn" value="Delete" onclick="delSize(this)"/></td>
                                        </tr>                                                                              
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <tr><td>&nbsp;</td></tr>
                    <!-- size end -->
            </tbody></table>
            </td>
        </tr>
    </tbody></table>
    <p style="text-align:right; padding:0px 0px 0px 50px">
        <input type="button" onclick="addSize()" class="btn" value="Add Size">&nbsp;
        <input type="button" onclick="toSubmit()" class="btn" value="Save">&nbsp;
        <input type="button" onclick="toCancel()" class="btn" value="Cancel">
    </p>      
 
</form>
</div>    
<div style="clear:both"></div>