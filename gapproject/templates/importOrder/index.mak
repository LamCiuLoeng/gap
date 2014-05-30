<%inherit file="gapproject.templates.master"/>
<%
	from gapproject.util.mako_filter import b
	from gapproject.util.common import rpacEncrypt
%>
<%def name="extTitle()">r-pac - Order</%def>
<%def name="extJavaScript()">
<script language="JavaScript" type="text/javascript">
    //<![CDATA[
    	$(document).ready(function(){
            $("form").submit(function(){
                var filename = $("#fileName").val();
                if( filename == "" || ! /\.xls(x)?$/.test( filename) ){
                    alert("Please select a MS Excel file!");
                    return false;
                }
            });


        });
            
		function getFileName(obj){
		    var tmp = $(obj);
			var path = tmp.val();
			if( path && path.length > 0){
				var location = path.lastIndexOf("\\") > -1 ?path.lastIndexOf("\\") + 1 : 0;
				var fn = path.substr( location,path.length-location );	
				$("#fileName").val(fn);
			}
		}
	//]]>
    </script>
</%def>
<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
            <tr>
            <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>

            <td width="64" valign="top" align="left"><img src="/images/images/menu_gap_g.jpg"/></td>

            <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
            <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
            </tr>
        </tbody></table>
</div>

<div class="nav-tree">GAPProject&nbsp;&nbsp;&gt;&nbsp;&nbsp;Import Order</div>

<div>
	<form action="/importOrder/handleImport/" enctype="multipart/form-data" method="POST">
		<div class="case-list-one">
			<ul style="width:750px">
				<li class="label"><label for="fileName">Vendor : </label></li>
				<li>
					<select name="vendor" class="input-style1-40fonts" id="vendor">
						<option value="NULL"></option>
	          		%for vendor in vendors:
	          			<option value="${vendor.user_id}">${vendor.display_name|b}</option>
	          		%endfor
          			</select>
				</li>
			</ul>
			<ul style="width:750px">
				<li class="label"><label for="fileName">File Name : </label></li>
				<li><input type="text" name="fileName" id="fileName" style="width: 250px;"/></li>
			</ul>
			<ul style="width:750px">
				<li class="label"><label for="filePath">File Path : </label></li>
				<li><input type="file" name="filePath" id="filePath" onchange="getFileName(this);" size="60"/>&nbsp;&nbsp;<input type="Submit" value="Upload"/></li>
			</ul>
		</div>
	</form>
</div>

<div style="clear:both"><br /></div>

%if import_result:
<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:900px">
    <thead>
        <tr>
            <th width="300">r-pac Confirmation No</th>
            <th width="300">Vendor PO#</th>
            <th width="150">Order Date</th>
            <th width="150">Total Qty</th>
            <th width="150">Issued By</th>
            <th width="150">Region</th>
        </tr>
    </thead>
    <tbody>
			%for u in import_result:
        <tr>
            <td><a href="/order/view?code=${rpacEncrypt(u.id)}" class="'link-text'">${u.orderNO}</a>&nbsp;</td>
            <td>${u.vendorPO}&nbsp;</td>
            <td>${u.orderDate}&nbsp;</td>
            <td>${u.total_qty()}&nbsp;</td>
            <td>${u.issuedBy}&nbsp;</td>
            <td>${u.region}&nbsp;</td>
        </tr>
			%endfor
    </tbody>
</table>

%endif

