<%inherit file="gapproject.templates.master"/>

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
	
</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>

<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.ui.datepicker.validation.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/ui.datepicker.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/oncl_form.js" language="javascript"></script>

</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="64" valign="top" align="left"><a href="/oncl/tracking"><img src="/images/images/menu_return_g.jpg"/></a></td>
  	<td width="64" valign="top" align="left">
        <a href="/getpdf/index?id=${obj.id}"><img src="/images/images/export_layout_g.jpg"/></a>
    </td>
    %if in_group('Admin') or in_group('AE') :
    <td width="64" valign="top" align="left">
        <a href="/oncl/updateorder?id=${obj.id}"><img src="/images/images/menu_revise_g.jpg"/></a>
    </td>
    <td width="64" valign="top" align="left">
  		<a href="/oncl/getexcel?id=${obj.id}"><img src="/images/images/export_order_g.jpg"/></a>
  	</td>
    %endif 
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;View Old Navy Care Labels</div>
<div style="width:1000px">
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
                            <td>&nbsp;</td>
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
                            <td width="10">&nbsp;</td>
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
                            
                            <td width="50%" align="left" valign="top">
                            <table border="0" cellspacing="0" cellpadding="0" style="width:100%">
                                <tbody><tr>
                                    <td width="120">&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td width="30">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Company Name&nbsp;: </td>
                                    <td class="tdct tdcttop">${obj.billCompany}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Attention&nbsp;:&nbsp;</td>
                                    <td class="tdct">${obj.billAttn}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 1&nbsp;:</td>
                                    <td class="tdct">${obj.billAddress}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 2&nbsp;:</td>
                                    <td class="tdct">${obj.billAddress2}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 3&nbsp;:</td>
                                    <td class="tdct">${obj.billAddress3}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;City/Town</td>
                                    <td class="tdct">${obj.billCity}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;State&nbsp;:</td>
                                    <td class="tdct">${obj.billState}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Zip Code&nbsp;:</td>
                                    <td class="tdct">${obj.billZip}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Country&nbsp;:</td>
                                    <td class="tdct">${obj.billCountry}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Phone&nbsp;:</td>
                                    <td class="tdct">${obj.billTel}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Fax #&nbsp;:</td>
                                    <td class="tdct">${obj.billFax}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Email&nbsp;:</td>
                                    
                                    <td class="tdct">${obj.billEmail}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Remark&nbsp;:</td>
                                    <td class="tdct">${obj.billRemark}</td>
                                    <td>&nbsp;</td>
                                </tr>
                            </tbody></table>
                            </td>
                            <td>&nbsp;</td>
                            <td width="50%" align="left" valign="top">
                            <table border="0" cellspacing="0" cellpadding="0" style="width:100%">
                                <tbody><tr>
                                    <td width="120">&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td width="30">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Company Name&nbsp;: </td>
                                    <td class="tdct tdcttop">${obj.shipCompany}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Attention&nbsp;:&nbsp;</td>
                                    <td class="tdct">${obj.shipAttn}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 1&nbsp;:</td>
                                    <td class="tdct">${obj.shipAddress}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 2&nbsp;:</td>
                                    <td class="tdct">${obj.shipAddress2}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 3&nbsp;:</td>
                                    <td class="tdct">${obj.shipAddress3}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;City/Town</td>
                                    <td class="tdct">${obj.shipCity}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;State&nbsp;:</td>
                                    <td class="tdct">${obj.shipState}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Zip Code&nbsp;:</td>
                                    <td class="tdct">${obj.shipZip}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Country&nbsp;:</td>
                                    <td class="tdct">${obj.shipCountry}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Phone&nbsp;:</td>
                                    <td class="tdct">${obj.shipTel}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Fax #&nbsp;:</td>
                                    <td class="tdct">${obj.shipFax}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Email&nbsp;:</td>
                                    <td class="tdct">${obj.shipEmail}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Remark&nbsp;:</td>
                                    <td class="tdct">${obj.shipRemark}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Special Instructions&nbsp;:</td>
                                    <td class="tdct">${obj.shipInstructions}</td>
                                    <td>&nbsp;</td>
                                </tr>
                            </tbody></table>
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
                                                    <tr style="color:blue">
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
                                    <tr>                     
                                        <th style="width:200px" rowspan="2">Fit</th>
                                        <th colspan="3">Size</th>
                                        <th style="width:200px" rowspan="2">Qty</th>
                                    </tr>
                                    <tr>
                                        <th>US Size</th><th>Chinese Size</th><th>Canada-French Size</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                    %for v in obj.sizeFitQty:
                                        <tr class="size_tr">
                                            <td style="height:26px;border-left : 1px solid #ccc;">${v['FIT']}</td>
                                            <!-- T is us_size, china_size, japan_size,canada_size,spanish_size -->
                                            <%
                                            	T = v['T'].split('$')
                                            %>
                                            <td>${T[0]}</td>
                                            <td>${T[1]}</td>
                                            <td>${T[3] if len(T) > 4 else '' }</td>
                                            <td>${v['RQ']}</td>
                                        </tr>
                                    %endfor
                                    <tr>
                                        <td colspan="4" style="height:26px;border-left : 1px solid #ccc;text-align:right">&nbsp;</td>
                                        <td>Total Qty : ${obj.totalQty}</td>
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
</div>    
    
<div style="clear:both"></div>