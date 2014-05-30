<%!
	from repoze.what.predicates import in_group
	from gapproject.util.mako_filter import b, na
%>
<%inherit file="gapproject.templates.master"/>
<%def name="extTitle()">r-pac - Master</%def>
<%def name="extCSS()">
<link rel="stylesheet" href="/css/thickbox.css" type="text/css" />
<link rel="stylesheet" href="/css/jquery.autocomplete.css" type="text/css" />
</%def>
<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/thickbox-compressed.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/gap_ac.js" language="javascript"></script>
<script language="JavaScript" type="text/javascript">
    var url = '/${funcURL}';
    function toSearch(){
        $("form")[0].submit();
    }
    function disable(){
        if(getCboxStr()==''){
            alert('Please at least select one checkbox before this operation!')
            return false;
        }
        $('#selected_ids').val(getCboxStr())
        $("#ckboxForm").attr('action', url+'/disable')
        $("#ckboxForm").submit();
    }
    function enable(){
        if(getCboxStr()==''){
            alert('Please at least select one checkbox before this operation!')
            return false;
        }
        $('#selected_ids').val(getCboxStr())
        $("#ckboxForm").attr('action', url+'/enable')
        $("#ckboxForm").submit();
    }
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
<div style="margin-bottom:5px;">
    <form method="post" id="ckboxForm">
        <input type="hidden" name="selected_ids" id="selected_ids" />
    </form>
    % if not in_group("AE"):
    <input type="button" class="btn" value="Disable Selected" onclick="disable()"/>
    <input type="button" class="btn" value="Enable Selected" onclick="enable()"/>
    % endif
</div>
<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:900px">
    <thead>
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="10"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
        <tr>
            % if not in_group("AE"):
            <th width="10"><input type="checkbox" onclick="selectAll(this)"/></th>
            % endif
            <th width="450">Item Number</th>
            % for region in regions:
            <th width="450">${region.name}</th>
            % endfor
        </tr>
    </thead>
    <tbody>
			%for u in tmpl_context.paginators.result.items:
        <tr>
            % if not in_group("AE"):
            <td><input type="checkbox" class="cboxClass" value="${u.id}"/></td>
            % endif
            <td>${u.item_number}&nbsp;</td>
            % for region in regions:
            % for price in u.item_price:
            % if price.region == region and price.active == 0:
            % if in_group("AE"):
            <td>${price.price|b}</td>
            % else:
            <td><a href="/${funcURL}/update?id=${price.id}" class="${'required link-text' if price.active==1 else 'link-text'}">${price.price|b}</a></td>
            % endif
            % endif
            % endfor
            % endfor
        </tr>
			%endfor
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="10"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
    </tbody>
</table>

%endif

