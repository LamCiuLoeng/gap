<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.inventory_helper import getOrders
    from repoze.what.predicates import  in_group

%>

<%def name="extTitle()">r-pac - Inventory Enquiry By Warehouse</%def>
<%def name="extCSS()">
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
</%def>
<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/numeric.js"></script>
<script language="JavaScript" type="text/javascript">

    function toSearch(){
        $("form")[0].submit();
    }
   
</script>
</%def>
<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
            <tr>
            <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
             <td width="64" valign="top" align="left"><a href="/"><img src="/images/images/menu_gap_g.jpg"/></a></td>
            <td width="64" valign="top" align="left"><a href="#" onclick="toSearch()"><img src="/images/images/menu_search_g.jpg"/></a></td>
            <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
            <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
            </tr>
        </tbody></table>
</div>

<div class="nav-tree">  Inventory Enquiry By Item&nbsp;&nbsp;&gt;&nbsp;&nbsp;Warehouse Detail</div>

    <div class="case-list-one">
            <ul>
                <li class="label"><label id="item_number.label" for="item_number" class="fieldlabel">Bag Item Code</label></li>
                <li><input type="text" id="item_number" class="width-250" name="item_number" value="${item_number}" disabled="disabled"/></li>
            </ul>
    </div>

<div style="clear:both"><br /></div>
<div style="clear:both"><br /></div>



%if result:

<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1000px; margin-left:2px;">
    <thead>
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="10"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
        <tr>
            <th width="160">Bag Item Code</th>
            <th width="100">Brand</th>
            <th width="90">Warehouse</th>
            <th width="120">Stock Inventory</th>
            <th width="120">Qty Shipped</th>
            <th width="60">Unit</th>
            
        </tr>
    </thead>
    <tbody>
			%for index, u in enumerate(tmpl_context.paginators.result.items):
        %if index%2==0:
            <tr class="odd" height="26">
            %else:
            <tr class="even" height="26">
        %endif
            <td>${u.item}&nbsp;</td>
            <td>${u.item.category.name}&nbsp;</td>
            <td>${u.warehouse}&nbsp;</td>
            <td>${u.qty}&nbsp;</td>
            <td>${u.shippedQty}&nbsp;</td>
            <td>PCS</td>
        </tr>
			%endfor
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="10"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
    </tbody>
</table>

%endif
