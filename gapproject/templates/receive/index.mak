<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.common import Date2Text
    from repoze.what.predicates import  in_group

%>

<%def name="extTitle()">r-pac - GAP - Receive Item</%def>
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
            <td width="64" valign="top" align="left"><a href="/receive/new"><img src="/images/images/menu_new_g.jpg"/></a></td>
            <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
            <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
            </tr>
        </tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Receive Item&nbsp;&nbsp;&gt;&nbsp;&nbsp;Search</div>


<div>
	${search_form(values,action=("/receive/index"))|n}
</div>

<div style="clear:both"><br /></div>
<!--
<span id="hint-content">&nbsp;*If action is 'Receive', the 'Select Order' is  optional.</span><br/>
<span id="hint-content">&nbsp;*If action is 'StockAdjust', the 'Internal PO#' is  no need to input.</span>
-->

%if result:
<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1200px; margin-left:2px;">
    <thead>
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="11"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
        <tr>
            <th width="180">Receive No.</th>
            <th width="120">Received Date</th>
            <th width="100">Warehouse</th>
            <th width="120">Received By</th>
            <th width="200">Remark</th>
        </tr>
    </thead>
    <tbody>
			%for index, r in enumerate(tmpl_context.paginators.result.items):
        %if index%2==0:
            <tr class="odd" height="26">
            %else:
            <tr class="even" height="26">
        %endif
            <td><a href="/receive/view?recid=${r.id}">${r.no}</a>&nbsp;</td>
            <td>${Date2Text(r.createTime)}&nbsp;</td>
            <td>${r.warehouse.name}&nbsp;</td>
            <td>${r.issuedBy.user_name}&nbsp;</td>
            <td>${r.remark}&nbsp;</td>
        </tr>
			%endfor
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="11"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
    </tbody>
</table>
%endif
