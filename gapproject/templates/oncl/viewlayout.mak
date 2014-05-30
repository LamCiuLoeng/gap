<%inherit file="gapproject.templates.master"/>

<%
	from gapproject.util.mako_filter import b, na
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
	
	.input-style2{
	   border: #aaa solid 1px;
        width: 50px;
        background-color: #FFe;
	}
	
	.comtable{
	   border : 1px solid;
	   padding: 5px;
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
<script type="text/javascript" src="/javascript/custom/oncl_form.js" language="javascript"></script>
<script language="JavaScript" type="text/javascript">
    //<![CDATA[
        $(document).ready(function(){
            $(".pcominput").numeric();
        });
        
    //]]>
   </script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
  	<td width="64" valign="top" align="left">
  		<a href="/oncl/tracking"><img src="/images/images/oncl_g.jpg"/></a>
  	</td>
  	<td width="64" valign="top" align="left">
        <a href="/oncl/viewOrder?id=${obj.orderHeaderId}"><img src="/images/images/order_info_g.jpg"/></a>
    </td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Order Old Navy Care Labels</div>

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
                            <tbody><tr>
                                <td width="100">
                                    <strong>&nbsp;&nbsp;&nbsp;&nbsp;Layout Info&nbsp;:</strong>
                                </td>
                                <td>
                                    <img src="/images/search_10.jpg" width="630" height="2">
                                </td>
                            </tr>
                        </tbody></table>
                        </td>
                        
                    </tr>
                    <!-- new field begin -->
                    <tr>
                        <td valign="top">
                            <table border="0" cellspacing="0" cellpadding="0" style="width:850px">
                                <tbody><tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td style="width:10px">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">
                                        Division:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>${obj.orderHeader.division}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">
                                        Category:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>${obj.orderHeader.category}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">
                                        Size:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>${obj.size}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">
                                        Fit:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>${obj.fit}</td>
                                </tr>
                                
                                <tr class="realCom">
                                    <td height="26" align="right" valign="top" class="title2">
                                        Composition:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <ul style="list-style-type:none">
                                            %for d in coms:
                                                <li>
                                                    Part : ${d['name']}
                                                    <ul style="padding-left:50px">
                                                         %for i,p in d['component']:
                                                            <li>${i}  -  ${p}%</li>
                                                         %endfor
                                                    </ul>
                                                </li>
                                            %endfor
                                        </ul>
                                    </td>
                                </tr>
                                
                                <tr>
                                    <td height="26" align="right" valign="top" class="title2">
                                        Care Instructions:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        %for c in cares:
                                            ${c}<br />
                                        %endfor
                                    </td>
                                </tr>

                                <tr>
                                    <td height="26" align="right" class="title2">
                                        Country of Origin:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>${obj.co}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" valign="top" class="title2">
                                        Warnings:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        %for w in warns:
                                            ${w}<br />
                                        %endfor
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
                    <!-- new field end -->
                    <!-- tracing begin -->
                    <tr>
                        <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tbody><tr>
                                <td width="100">
                                    <strong>&nbsp;&nbsp;&nbsp;&nbsp;Traceability&nbsp;:</strong>
                                </td>
                                <td>
                                    <img src="/images/search_10.jpg" width="630" height="2">
                                </td>
                            </tr>
                        </tbody></table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table border="0" cellspacing="0" cellpadding="0" style="width:850px">
                                <tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td style="width:10px">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">Style# :</td>
                                    <td>&nbsp;</td>
                                    <td>${obj.styleNo}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">Color Code :</td>
                                    <td>&nbsp;</td>
                                    <td>${obj.colorCode}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">Style Description :</td>
                                    <td>&nbsp;</td>
                                    <td>${obj.styleDesc}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">CC Description :</td>
                                    <td>&nbsp;</td>
                                    <td>${obj.ccDesc}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">Vendor :</td>
                                    <td>&nbsp;</td>
                                    <td>${obj.vendor}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">Season :</td>
                                    <td>&nbsp;</td>
                                    <td>${obj.season}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="title2">Month/Year Of Manufacture :</td>
                                    <td>&nbsp;</td>
                                    <td>${obj.manufacture}</td>
                                </tr>
                            </table>
                        </td>
                    </tr>                        
                    <!-- tracing end -->
				</table>      
				</td>
				<td>&nbsp;</td>
			</tr>
		</table>
		</td>
	</tr>

</table>


<div style="clear:both"><br/><br/></div>