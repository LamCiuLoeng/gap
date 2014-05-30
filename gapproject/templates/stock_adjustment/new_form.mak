<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.mako_filter import b, na
    from repoze.what.predicates import in_group
%>

<%def name="extTitle()">GAP - Stock Adjustment</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<!-- <link rel="stylesheet" href="/javascript/smartspin/smartspinner.css" type="text/css" /> -->
<style type="text/css">
    .input-width{
        width : 300px
    }
    
    #warning {
        font:italic small-caps bold 16px/1.2em Arial;
    }
</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<!-- <script type="text/javascript" src="/javascript/smartspin/smartspinner.js" language="javascript"></script> -->
<script type="text/javascript" src="/javascript/jquery.validate.min.js" language="javascript"></script>\
<script type="text/javascript">
    $(document).ready(function(){
    $(".numeric").numeric({ negative : false });
    // $("input[name^='adjustmentQty-']").each(function(){
    //         var t = $(this);
    //         t.spinit({min:1, 
    //             initValue: 1,
    //             stepInc:1, pageInc:30, 
    //             height: 30, width: 100});
    // });
    $('#ad-form').validate();
});

var toAdd = function(){
    var w = $('#tmp-warehouseID').val() || $('#warehouseID').val();
    if(w ||  (typeof w) === 'undefined'){
        $('#warehouseID').val(w);
        var url = '/stockAdjustment/new';
window.open(url, 'SearchItem','height=600,width=800,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no, status=yes');  
    }else{
       $.prompt('Please select a warehouse first!',{opacity: 0.6,prefix:'cleanred'}); 
    }
};
var toConfirm = function(){
    
    $.prompt("Are you sure to confirm these now?",
        {opacity: 0.6,
            prefix:'cleanblue',
            buttons:{'Yes':true,'No,Go Back':false},
            focus : 1,
            callback : function(v,m,f){
                if(v){
                    $("#ad-form").attr('action', '/stockAdjustment/save');
                    $("#ad-form").submit();
                }
            }
        }
    );
};

var changeType = function(id){
    var t = $('#adjustmentQty-'+id);
    // t.spinit({min:1,
    //             initValue: 1,
    //             stepInc:1, pageInc:30, 
    //             height: 30, width: 100});
    if($('#type-' + id).val() == 'LESS'){
        var max = parseInt(t.attr('maxnum'));
        t.attr('max', max);
        $('#ad-form').validate();
    }else{
        t.removeAttr('max');
        $('#ad-form').validate();
    }
};
</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="64" valign="top" align="left">
       <a href="javascript:history.back()"><img src="/images/images/menu_back_g.jpg"/></a>
    </td>
    <td width="64" valign="top" align="left"><a href="/stockAdjustment/new_form"><img src="/images/images/menu_new_g.jpg"/></a></td>
    % if warehouse:
    <td width="64" valign="top" align="left">
        <a class="confirm" href="javascript:void(0)" onclick="toConfirm()"><img src="/images/images/menu_confirm_g.jpg"/></a>
    </td>
    % endif
    <td width="64" valign="top" align="left">
        <a href="/receive/index" onclick="return toCancel()"><img src="/images/images/menu_cancel_g.jpg"/></a>
    </td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Stock Adjustment&nbsp;&nbsp;&gt;&nbsp;&nbsp;New</div>

<form id="ad-form" action="/stockAdjustment/new_form" method="post">
<input type="hidden" name="itemIDs" value="${values.get('itemIDs') if values else ''}" id="itemIDs"/>
<input type="hidden" id="warehouseID" name="warehouseID" value="${warehouse.id if warehouse else ''}" />

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
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>

                                <td>
                                    <img src="/images/search_10.jpg" width="600" height="2" />
                                </td>
                            </tr>
                        </table>
                        </td>
                    </tr>
                    <tr>
                        <td width="850" valign="top" align="left">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="120">&nbsp;</td>
                            </tr>
                            <tr>
                                <td height="26" align="left">
                                    &nbsp;&nbsp;*Warehouse&nbsp;:
                                </td>
                                <td>
                                    % if warehouse:
                                    ${warehouse.name}
                                    % else:
                                    <select name="tmp-warehouseID" id="tmp-warehouseID">
                                        <option value="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</option>
                                        % for w in warehouses:
                                        <option value="${w.id}">${w.name}</option>
                                        % endfor
                                    </select>
                                    % endif
                                </td>
                            </tr> 
                            <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td height="26" align="left">
                                    &nbsp;&nbsp;&nbsp;*Adjustment Reason&nbsp;:
                                </td>
                                <td>
                     <textarea id="remark" name="remark" cols="45" rows="4" class="textarea-style required">${values.get('remark', '')}</textarea>
                                </td>
                            </tr>            
                        </table>
                        </td>
                    </tr>
                </table>
                </td>
                <td>&nbsp;</td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
    </tr>
</table>

<div style="clear:both">
    &nbsp;&nbsp;
    <a href="javascript:void(0)" onclick="toAdd()">
        <img src="/images/new_item.jpg" />
    </a>
</div>
%if result:
<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1000px; margin-left:2px;">
    <thead>
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="11"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
            <th width="100">Line No.</th>
            <th width="200">Bag Item No#</th>
            <th width="120">Warehouse</th>
            <th width="120">On Hand Qty</th>
            <!-- <th width="120">Reserved Qty</th> -->
            <th width="120">Available Qty</th>
            <th width="120">*Type</th>
            <th width="100">*Adjustment Qty</th>
            <th width="80">Base Unit</th>
        </tr>
    </thead>
    <tbody>
            %for index, i in enumerate(tmpl_context.paginators.result.items):
        %if index%2==0:
            <tr class="odd" height="36">
            %else:
            <tr class="even" height="36">
        %endif
            <td>${index+1}</td>
            <td>${i.item_number}&nbsp;</td>
            <td>${warehouse.name}&nbsp;</td>
            <td>${i.onHandQtyByWarehouse(warehouse.id)}&nbsp;</td>
            <td>${i.availableQtyByWarehouse(warehouse.id)}&nbsp;</td>
            <td>
                <select name="type-${i.id}" id="type-${i.id}" onchange="changeType(${i.id})">
                    <option value="ADD">&nbsp;ADD&nbsp;</option>
                    % if i.availableQtyByWarehouse(warehouse.id) > 0:
                    <option value="LESS">LESS</option>
                    % endif
                </select>
            </td>
            <td>
                <% 
                    onHandQty = i.onHandQtyByWarehouse(warehouse.id)
                    availableQty = i.availableQtyByWarehouse(warehouse.id)
                %>
                <input type="hidden" name="onHandQty-${i.id}" value="${onHandQty}" />
                <input type="hidden" name="availableQty-${i.id}" value="${availableQty}" />
                <input type="text" id="adjustmentQty-${i.id}" name="adjustmentQty-${i.id}" min="1" maxnum="${availableQty}" class="numeric required digits"/>
            </td>
            <td>PCS&nbsp;</td>
        </tr>
            %endfor
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="11"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
    </tbody>
</table>
%endif

</form>
