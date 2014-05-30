<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.common import Date2Text
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
            <!--
            <td width="64" valign="top" align="left"><a href="#" onclick="toSearch()"><img src="/images/images/menu_search_g.jpg"/></a></td> -->
            <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
            <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
            </tr>
        </tbody></table>
</div>

<div class="nav-tree">  Inventory For GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Inventory Detail</div>

    <div class="case-list-one">
            <ul>
                <li class="label"><label id="item_number.label" for="item_number" class="fieldlabel">Bag Item Code</label></li>
                <li><input type="text" id="item_number" class="width-250" name="item_number" value="${item.item_number}" disabled="disabled"/></li>
            </ul>
            <ul>
                <li class="label"><label id="item_number.label" for="item_number" class="fieldlabel">Date</label></li>
                <li><input type="text" id="item_number" class="width-250" name="item_number" value="${Date2Text(date)}" disabled="disabled"/></li>
            </ul>
    </div>

<div style="clear:both"><br /></div>
<div style="clear:both"><br /></div>



%if warehouses:

<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1000px; margin-left:2px;">
    <thead>
        
        <tr>
            <th width="160">Bag Item No.</th>
            <th width="100">Brand</th>
            <th width="90">Warehouse</th>
            <th width="120">On Hand Qty</th>
            <!-- <th width="120">Reserved Qty</th> -->
            <th width="120">Available Qty</th>
            <th width="60">Unit</th>
            
        </tr>
    </thead>
    <tbody>
			%for index, w in enumerate(warehouses):
        %if index%2==0:
            <tr class="odd" height="26">
            %else:
            <tr class="even" height="26">
        %endif
            <td>${item.item_number}&nbsp;</td>
            <td>${item.category.name}&nbsp;</td>
            <td>${w.name}&nbsp;</td>
            <td>${item.onHandQtyByWarehouse(w.id)}&nbsp;</td>
            <%doc><td>${item.reservedQtyByWarehouse(w.id)}&nbsp;</td></%doc>
            <td>${item.availableQtyByWarehouse(w.id)}&nbsp;</td>
            <td>PCS</td>
        </tr>
			%endfor
    </tbody>
</table>

%endif
