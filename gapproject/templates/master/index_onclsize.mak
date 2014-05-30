<%!
	from repoze.what.predicates import in_group
%>
<%inherit file="gapproject.templates.master"/>
<%namespace name="tw" module="tw.core.mako_util"/>

<%def name="extTitle()">r-pac - Master</%def>

<%def name="extJavaScript()">
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[
		function toSearch(){
		    $("form").attr('action','/onclsize/index');
			$("form").submit();
		}
		
		function changedep(c){
		    var obj = $(c);
		    if(!obj.val()){
		      $("#category_id").html('');
		    }else{
		        var p = {
		            'division_id' : obj.val(),
		            't' : Date.parse(new Date())
		        }
		        $.getJSON('/onclsize/ajaxdep',p,function(r){
		            if(r.code != 0 ){
		                alert(r.msg);
		            }else{
		                var html = '<option></option>';
		                for(var i = 0 ;i < r.d.length;i++){
		                    html += '<option value="'+r.d[i][0]+'">'+r.d[i][1]+'</option>';
		                }
		                $("#category_id").html(html);
		            }
		        });
		    }
		}
		
		function toExport(){
		  $("form").attr('action','/onclsize/export');
		  $("form").submit();
		}
		
		function toDelete(id,obj){
		  if(window.confirm("Are you sure to delete this record ?")){
		      var p = {
		          'id' : id,
		          't' : Date.parse(new Date())
		      }
		      $.getJSON('/onclsize/ajaxDel',p,function(r){
		          if(r.code == 0){ $($(obj).parents("tr")).remove(); }
		          alert(r.msg);		          
		      });
		  }else{
		      return False;
		  }
		}
		
    //]]>
   </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/onclsize/index"><img src="/images/images/menu_onclsize_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toSearch()"><img src="/images/images/menu_search_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toExport()"><img src="/images/images/menu_export_g.jpg"/></a></td>
    %if in_group("Admin"):
    <td width="64" valign="top" align="left"><a href="/onclsize/add"><img src="/images/images/menu_new_g.jpg"/></a></td>
    %endif
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Master&nbsp;&nbsp;&gt;&nbsp;&nbsp;Search</div>

<form action="/onclsize/index" method="post" class="required onclsizesearchform">
   
    <div class="case-list-one">
        <ul>
            <li class="label"><label id="division_id.label" for="division_id" class="fieldlabel">Department Name</label></li>
            <li>
                <select name="division_id" class="width-250" id="division_id" onchange="changedep(this)">
                    <option value=""></option>
                    %for d in divs:
                        <option value="${d.id}" ${tw.attrs([("selected",unicode(d.id) == values['division_id'])])}>${d}</option>
                    %endfor
                </select>
            </li>
        </ul>
    </div>
    <div class="case-list-one">
        <ul>
            <li class="label"><label id="category_id.label" for="category_id" class="fieldlabel">Category Name</label></li>
            <li>
                <select name="category_id" class="width-250" id="category_id">
                    <option value=""></option>
                    %for c in cats:
                        <option value="${c.id}" ${tw.attrs([("selected",unicode(c.id) == values['category_id'])])}>${c}</option>
                    %endfor
                </select>
            </li>
        </ul>
    </div>
</form>
    
<div style="clear:both"><br /></div>

    <%
        my_page = tmpl_context.paginators.result
        pager = my_page.pager(symbol_first="<<",show_if_single_page=True)
    %>
	<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1300px">
		<thead>
			
			<tr>
				<th width="100" style="height:20px">Department</th>
				<th width="500">Category</th>
				<th width="100">Fit</th>
				<th width="120">US Size</th>
				<th width="120">China Size</th>
				<th width="120">Japanese Size</th>
				<th width="120">Canada-French</th>
				<th width="120">Spanish</th>
				<th width="100">Action</th>
			</tr>
		</thead>
		<tbody>
		    %if len(result) < 1:
                <tr>
                    <td colspan="20" style="border-left:1px solid #ccc">No records found!</td>
                </tr>
            %else:
    			% for div,cat,size in result:
    			<tr>
    				<td style="height:18px">${div}</td>
    				<td>${cat}&nbsp;</td>
    				<td>${size.fit}&nbsp;</td>
    				<td>${size.us_size}&nbsp;</td>
    				<td>${size.china_size}&nbsp;</td>
    				<td>${size.japan_size}&nbsp;</td>
    				<td>${size.canada_size}&nbsp;</td>
    				<td>${size.spanish_size}&nbsp;</td>
    				<td><a href="/onclsize/update?id=${size.id}">Edit</a>&nbsp;&nbsp;<a href="#" onclick="toDelete(${size.id},this)">Delete</a></td>
    			</tr>
    			%endfor
    	    %endif 
			%if my_page.item_count > 0 :
            <tr>
                <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="20">
                    ${pager}, <span>${my_page.first_item} - ${my_page.last_item}, ${my_page.item_count} records</span>
                </td>
            </tr>
        %endif
		</tbody>
	</table>


