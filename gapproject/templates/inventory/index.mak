<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.inventory_helper import getOrders
    from repoze.what.predicates import  in_group

%>

<%def name="extTitle()">r-pac - Inventory</%def>
<%def name="extCSS()">
<link rel="stylesheet" href="/css/jquery.autocomplete.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
</%def>
<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/numeric.js"></script>
<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/gap_ac.js"></script>
<script language="JavaScript" type="text/javascript">
    $(function(){
        $(".numeric").numeric();
    });

    function toSearch(){
        $("form")[0].submit();
    }

    var checkNum = function(num){
        var re = /^[1-9]\d*$/;
        return re.test(num)
    }

    var checkForm = function(id, maxQty, warehouseID, itemID){
        var type = $("select[name='type-"+id+ "']").val(); 
        var qty = $("input[name='qty-"+id+ "']").val();
        var orderID = $("select[name='orderID-"+id+ "']").val();
        var internalPO = $.trim($("input[name='internalPO-"+id+ "']").val());

        if(!type){
            showError("Please Select Action!");
        }else if(!checkNum(qty)){
            showError("Please input correct qty!");
        }else if(type=="shipped" && parseInt(qty)>parseInt(maxQty)){
                showError("Please input correct qty!");
        }else if(type=="shipped" && orderID==''){
                showError("Please select order!");
        }else if(!internalPO){
                showError("Please input InternalPO!");
        }else{
            $("input[name='id']").val(id);
            $("input[name='warehouseID']").val(warehouseID);
            $("input[name='itemID']").val(itemID);
            $("input[name='orderID']").val(orderID);
            $("input[name='internalPO']").val(internalPO);
            $('#update-form').submit();
        }
    }
   
</script>
</%def>
<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
            <tr>
            <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>

            <td width="64" valign="top" align="left"><a href="#" onclick="toSearch()"><img src="/images/images/menu_search_g.jpg"/></a></td>
            % if in_group("AE") or in_group("Admin"):
            <td width="64" valign="top" align="left"><a href="/inventory/history"><img src="/images/images/menu_history_g.jpg"/></a></td>
            % endif
            <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
            <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
            </tr>
        </tbody></table>
</div>

<div class="nav-tree">Inventory&nbsp;&nbsp;&gt;&nbsp;&nbsp;Search</div>


<div>
	${search_form(values,action=("/inventory/index"))|n}
</div>

<div style="clear:both"><br /></div>
<!--
<span id="hint-content">&nbsp;*If action is 'Receive', the 'Select Order' is  optional.</span><br/>
<span id="hint-content">&nbsp;*If action is 'StockAdjust', the 'Internal PO#' is  no need to input.</span>
-->

%if result:
<form id="update-form" action="/inventory/update" method="post">
<input type="hidden" name="search_warehouseID" value="${values.get('warehouseID', '')}"/> 
<input type="hidden" name="search_item_number" value="${values.get('item_number', '')}"/> 
<input type="hidden" name="search_page" value="${values.get('page', 1)}"/> 
<input type="hidden" name="id" /> 
<input type="hidden" name="warehouseID" />
<input type="hidden" name="itemID" />
<input type="hidden" name="orderID" />
<input type="hidden" name="internalPO" />

<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1200px; margin-left:2px;">
    <thead>
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="11"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
        <tr>
            <th width="160">Bag Item No</th>
            <th width="90">Warehouse</th>
            <th width="120">Stock Inventory</th>
            <th width="120">Qty Shipped</th>
            % if in_group("AE") or in_group("Admin"):
            <th width="120">Select Action</th>
            <th width="120">Select Order</th>
            <th width="120">Action Qty</th>
            <th width="100">Internal PO#</th>
            <th width="100">Remark</th>
            <th width="120">Set Warning Qty</th>
            % endif
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
            <td>${u.warehouse}&nbsp;</td>
            <td>${u.qty}&nbsp;</td>
            <td>${u.shippedQty}&nbsp;</td>
            % if in_group("AE") or in_group("Admin"):
            <td>
                <select name="type-${u.id}">
                    <option value=""></option>
                    <option value="received">Receive</option>
                    %if u.qty > 0:
                    <option value="shipped">Ship</option>
                    <!--<option value="shipped">StockAdjust</option>-->
                    %endif  
                </select>
                
            </td>
            <td>
                <%
                    orders = getOrders(u.warehouse.id, u.item.id)
                %>
                % if orders:
                <select name="orderID-${u.id}">
                    <option value=""></option>
                 
                    % for o in orders:
                    <option value="${o.id}">${o.orderNO}</option>
                    % endfor 
                </select>
                % endif
            </td>
            <td><input type="text" name="qty-${u.id}" class="numeric" size="10" /></td>
            <td><input type="text" name="internalPO-${u.id}" /></td>
            <td>
                <textarea name="remark-${u.id}" style="width:180px; height:70px;"></textarea>&nbsp;
                <a class="submit" href="#" onclick="checkForm('${u.id}', '${u.qty}', '${u.warehouse.id}', '${u.item.id}')"><img src="/images/images/menu_submit_g.jpg"></a>
            </td>
            <td><a href="/inventory/setWarningQty?id=${u.id}" target="_bank">Set</a></td>
            % endif
        </tr>
			%endfor
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="11"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
    </tbody>
</table>
</form>
%endif
