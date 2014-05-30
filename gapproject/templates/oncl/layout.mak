<%inherit file="gapproject.templates.master"/>

<%
	from gapproject.util.mako_filter import b, na
	from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - GAP - Order Old Navy Care Labels</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/jquery-ui-1.9.2.custom.min.css" type="text/css" />
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
<script type="text/javascript" src="/javascript/jquery-ui-1.9.2.custom.min.js" language="javascript"></script>

<script type="text/javascript" src="/javascript/custom/oncl_form.js" language="javascript"></script>
<script language="JavaScript" type="text/javascript">
    //<![CDATA[
        $(document).ready(function(){
            $(".pcominput").numeric();
            $( "#layoutinfo" ).dialog({
                  resizable: false,
                  height:500,
                  width: 800,
                  modal: true,
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
        
        
        function showInfo(){
            var msg = checkLayout();
            if(msg.length > 0){
                var m = '<ul>';
                for(var i=0;i<msg.length;i++){ m += '<li>' + msg[i] + '</li>'; }
                m += '</ul>';
                showError(m);
                return;
            }
            
            var params = {
                order_id : ${obj.id},
                t : Date.parse(new Date())
            }
            
            var cids = [];
            $("[name^='care']").each(function(){
                var t = $(this);
                if(t.val()){ cids.push(t.val()); }
            });
            
            
            var wids = [];
            $("[name^='warning']").each(function(){
                var t = $(this);
                if(t.val()){ wids.push(t.val()); }
            });
            
            
            params['cids'] = cids.join("|");
            params['wids'] = wids.join("|");
            var coms = [];
            
            $("select[name^='com']").each(function(){
                var k = $(this);
                if(k.val()){
                    var tmp = [];
                    tmp.push($(this).val());
                    var n = k.attr('name');
                    $("select[name^='f" + n + "']").each(function(){
                        var m = $(this);
                        if(m.val()){ tmp.push(m.val()); }
                    });
                    
                    coms.push(tmp.join(','));
                }
            })
                
            params['coms'] = coms.join("|");
                
            $.getJSON('/oncl/ajaxLayoutInfo',params,function(r){
                if(r.code != 0 ){
                    alert(r.msg);
                }else{
                    $("#size_td").text( $("#sizeId :selected").attr('ref') );
                    $("#co_td").text( $("#coId :selected").text() );
                    $("#com_td").html(r.composition );
                    $("#care_td").html(r.cares);
                    $("#warn_td").html(r.warngs);   
                    $( "#layoutinfo" ).dialog('open');
                }
            })
        }
    //]]>
   </script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
  	<td width="64" valign="top" align="left">
  		<a href="/oncl/placeorder"><img src="/images/images/oncl_g.jpg"/></a>
  	</td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Order Old Navy Care Labels</div>

<form id="orderForm" action="/oncl/savelayout" method="post">
<input type="hidden" name="orderHeaderId" value="${obj.id}"/>

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
				<table border="0" cellspacing="0" cellpadding="0" style="width:850px">
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
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tbody><tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td style="width:10px;">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">
                                        <sup><span style="color:red">*</span></sup>Division:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>${obj.division}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">
                                        <sup><span style="color:red">*</span></sup>Category:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>${obj.category}</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">
                                        <sup><span style="color:red">*</span></sup>Size:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="sizeId" id="sizeId" class="input-style1">
                                            <option value=""></option>
                                            %for s in sizes:
                                                <option value="${s['id']}" ref="${s['ref']}">${s['name']}</option>
                                            %endfor
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">
                                        Fit:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="fitId" id="fitId" class="input-style1">
                                            <option value=""></option>
                                            %for f in fits:
                                                <option value="${f.id}">${f}</option>
                                            %endfor
                                        </select>
                                    </td>
                                </tr>
                                <tr class="realCom">
                                    <td height="26" align="right">
                                        <sup><span style="color:red">*</span></sup>Composition:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <table class="comtable">
                                            <tr>
                                                <td>Part</td>
                                                <td><select name="com10" class="input-style1 comselect">
                                                        <option value=""></option>
                                                        %for s in sections:
                                                            <option value="${s.id}">${s}</option>
                                                        %endfor
                                                    </select/>
                                                </td>
                                                <td><input type="button" class="btn" value="Add" onclick="addCom()"/></td>
                                            </tr>
                                            <tr>
                                                <td>Material</td>
                                                <td>
                                                    <select name="fcom10_10" class="input-style1 fcomselect">
                                                        <option value=""></option>
                                                        %for f in fibers:
                                                            <option value="${f.id}">${f}</option>
                                                        %endfor
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
                                                <td>Part</td>
                                                <td>
                                                    <select name="com" class="input-style1 comselect">
                                                        <option value=""></option>
                                                        %for s in sections:
                                                            <option value="${s.id}">${s}</option>
                                                        %endfor
                                                    </select/>
                                                </td>
                                                <td><input type="button" class="btn" value="Delete" onclick="delCom(this)"/></td>
                                            </tr>
                                            <tr>
                                                <td>Material</td>
                                                <td>
                                                    <select name="" class="input-style1 fcomselect">
                                                        <option value=""></option>
                                                        %for f in fibers:
                                                            <option value="${f.id}">${f}</option>
                                                        %endfor
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
                                    <td height="26" align="right">
                                        <sup><span style="color:red">*</span></sup>Care Instructions:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="care01" id="care10"  class="input-style1">
                                            <option value=""></option>
                                            %for c in cares:
                                                <option value="${c.id}">${c}</option>
                                            %endfor
                                        </select>&nbsp;<input type="button" value="Add" class="btn" onclick="addCare()"/>
                                    </td>
                                </tr>
                                <tr class="care template">
                                    <td height="26" align="right">&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="care" id="care"  class="input-style1">
                                            <option value=""></option>
                                            %for c in cares:
                                                <option value="${c.id}">${c}</option>
                                            %endfor
                                        </select>&nbsp;<input type="button" value="Delete" class="btn" onclick="delCare(this)"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">
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
                                    <td height="26" align="right">
                                        <sup><span style="color:red">*</span></sup>Warnings:
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="warning01" id="warning10"  class="input-style1">
                                            <option value=""></option>
                                            %for w in warnings:
                                                <option value="${w.id}">${w}</option>
                                            %endfor
                                        </select>&nbsp;<input type="button" value="Add" class="btn" onclick="addWarn()"/>
                                    </td>
                                </tr>
                                <tr class="warning template">
                                    <td height="26" align="right">&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <select name="warning" id="warning"  class="input-style1">
                                            <option value=""></option>
                                            %for w in warnings:
                                                <option value="${w.id}">${w}</option>
                                            %endfor
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
                            <table border="0" cellspacing="0" cellpadding="0" style="width:850px;">
                                <tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td style="width:10px">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">Style#</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="styleNo" id="styleNo" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">Color Code</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="colorCode" id="colorCode" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">Style Description</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="styleDesc" id="styleDesc" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">CC Description</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="ccDesc" id="ccDesc" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">Vendor</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="vendor" id="vendor" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">Season</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="season" id="season" value="" class="input-style1"/></td>
                                </tr>
                                <tr>
                                    <td height="26" align="right">Month/Year Of Manufacture</td>
                                    <td>&nbsp;</td>
                                    <td><input type="text" name="manufacture" id="manufacture" value="" class="input-style1"/></td>
                                </tr>
                            </table>
                        </td>
                    </tr>                        
                    <!-- tracing end -->
				</table>
                <p style="text-align:right"><input type="button" value="Confirm" class="btn" onclick="showInfo()"/></p>        
				</td>
				<td>&nbsp;</td>
			</tr>
		</table>
		</td>
	</tr>

</table>
<br />


</form>



<div style="display:none">
    <table>
        <tr id='material_template'>
            <td>&nbsp;</td>
            <td>
                <select name="" class="input-style1 fcomselect">
                    <option value=""></option>
                    %for f in fibers:
                        <option value="${f.id}">${f}</option>
                    %endfor
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
          <td style="width:150px">Old Navy care label : </td><td>${obj.item}</td>
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
          <td valign="top">Composition : </td><td id="com_td"></td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
          <td valign="top">Care Instructions : </td><td id="care_td"></td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
          <td valign="top">Warnings : </td><td id="warn_td"></td>
      </tr>
  </table>
</div>


<div style="clear:both"><br/><br/></div>