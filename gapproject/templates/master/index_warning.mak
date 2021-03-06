<%!
	from repoze.what.predicates import in_group
%>
<%inherit file="gapproject.templates.master"/>

<%def name="extTitle()">r-pac - Master</%def>

<%def name="extJavaScript()">
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[
		function toSearch(){
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
    <td width="64" valign="top" align="left"><a href="#" onclick="toSearch()"><img src="/images/images/menu_search_g.jpg"/></a></td>
    %if in_group("Admin"):
    <td width="64" valign="top" align="left"><a href="/${funcURL}/add"><img src="/images/images/menu_new_g.jpg"/></a></td>
    %endif
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Master&nbsp;&nbsp;&gt;&nbsp;&nbsp;Search</div>

<div>
	${searchWidget(values,action=("/%s/index" %funcURL))|n}
</div>

<div style="clear:both"><br /></div>

%if result:

	<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1100px">
		<thead>
			<tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="10"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
			<tr>
				<th width="200">Trans ID</th>
				<th width="200">English Term</th>
				<th width="200">Context</th>
				<th width="200">Chinese</th>
				<th width="200">UK English</th>
			</tr>
		</thead>
		<tbody>
			%for u in tmpl_context.paginators.result.items:
			<tr>
				<td>
					%if in_group("Admin"):
					<a href="/${funcURL}/update?id=${u.id}">${u.trans_id}</a>
					%else:
					${u.trans_id}
					%endif
					&nbsp;
				</td>
				<td>${u.english_term}&nbsp;</td>
				<td>${u.context}&nbsp;</td>
				<td>${u.chinese}&nbsp;</td>
				<td>${u.uk_english}&nbsp;</td>
			</tr>
			%endfor
			<tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="10"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
		</tbody>
	</table>

%endif

