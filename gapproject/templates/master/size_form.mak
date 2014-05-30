<%inherit file="gapproject.templates.master"/>

<%
	from gapproject.util.mako_filter import b, na
	#from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - Master</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/jquery.multiSelect.css" type="text/css" media="screen"/>
 <style type="text/css">

.width-220 {
    width: 220px;
}
  </style>
</%def>
<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/custom/gap_master_size.js"></script>
<script type="text/javascript" src="/javascript/jquery.multiSelect.js"></script>
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[
    	$(document).ready(function(){
    		$(".jqery_multiSelect").multiSelect();
    	});
    	
		function toSave(){
			$("form").submit();
		}
		
		function toUpdate() {
			$("form").attr("action", "/item/updateAttr");
			$("form").submit();
		}
    //]]>
   </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/${funcURL}/index"><img src="/images/images/menu_${funcURL}_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toSave()"><img src="/images/images/menu_save_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="/${funcURL}/index"><img src="/images/images/menu_cancel_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Master&nbsp;&nbsp;&gt;&nbsp;&nbsp;New or Update</div>

<div>
	<form action="/onclsize/saveUpdate" method="post" class="onclsizeupdateform required">
	<input type="hidden" name="id" value="${size.id}" />	
    <div class="case-list-one">
    		<ul>
    			<li class="label"><label id="western_size.label" for="western_size" class="fieldlabel">Western Size</label></li>
    			<li><input type="text" id="western_size" class="width-250" name="western_size" value="${size.western_size|b}" /></li>
    		</ul>
    		<ul>
    			<li class="label"><label id="china_size_count.label" for="china_size_count" class="fieldlabel">China Size Count</label></li>
    			<li>
    				<select name="china_size_count" class="width-250" id="china_size_count">
        				<option value=""></option>
        				% for count in range(1, 11):
        				%if count == len(china_values):
        				<option value="${count}" selected>${count}</option>
        				%else:
        				<option value="${count}">${count}</option>
        				%endif
        				% endfor
        			</select>
        		</li>
    		</ul>
    		% for value in china_values.itervalues():
    		<ul>
    			<li class="label"><label id="china_size.label" for="china_size" class="fieldlabel">China Size</label></li>
    			<li><input type="text" id="china_size" class="width-250 china_size" name="china_size" value="${value}" /></li>
    		</ul>
    		% endfor
    		% for key in china_values.iterkeys():
    		<ul>
    			<li class="label"><label id="china_size_kind.label" for="china_size_kind" class="fieldlabel">China Size Kind</label></li>
    			<li><input type="text" id="china_size_kind" class="width-250 china_size_kind" name="china_size_kind" value="${key}" /></li>
    		</ul>
    		% endfor
    </div>
    <div class="case-list-one">
    		<ul>
    			<li class="label"><label id="category_id.label" for="category_id" class="fieldlabel">Category Name</label></li>
    			<li>
    				<select name="category_id" class="width-250" id="category_id">
    					%for category in categories:
    					%if category.id == size.category.id:
    					<option value="${category.id}" selected>${category.name}</option>
    					%else:
    					<option value="${category.id}">${category.name}</option>
    					%endif
    					%endfor
    				</select>
    			</li>
    		</ul>
    		<ul>
    			<li class="label"><label id="japan_size_count.label" for="japan_size_count" class="fieldlabel">Japan Size Count</label></li>
    			<li>
    				<select name="japan_size_count" class="width-250" id="japan_size_count">
        				<option value=""></option>
        				% for count in range(1, 11):
        				% if count == len(japan_values):
        				<option value="${count}" selected>${count}</option>
        				% else:
        				<option value="${count}">${count}</option>
        				% endif
        				% endfor
        			</select>
        		</li>
    		</ul>
    		% for value in japan_values.itervalues():
    		<ul>
    			<li class="label"><label id="japan_size.label" for="japan_size" class="fieldlabel">Japan Size</label></li>
    			<li><input type="text" id="japan_size" class="width-250 japan_size" name="japan_size" value="${value}" /></li>
    		</ul>
    		% endfor
    		% for key in japan_values.iterkeys():
    		<ul>
    			<li class="label"><label id="japan_size_kind.label" for="japan_size_kind" class="fieldlabel">Japan Size Kind</label></li>
    			<li><input type="text" id="japan_size_kind" class="width-250 japan_size_kind" name="japan_size_kind" value="${key}" /></li>
    		</ul>
    		% endfor
    </div>
</form>
</div>





