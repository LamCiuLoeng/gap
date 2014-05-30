<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.validate.min.js"></script>
<script type="text/javascript">
    $(function(){
        $(".numeric").numeric({ negative : false });
        // $(".numeric").numeric();
        $('#re-save-form').validate();
    });
    var toSubmit = function(){
        var detailIDs = []
        $("input[name^='qty-']").each(function(){
            var id = $(this).attr('name').split('-')[1]
            detailIDs.push(id);
        });
        if(detailIDs.length > 0){
            if(window.confirm("Are you sure to submit these now?")){
                $("input[name='detailIDs']").val(detailIDs.join('|'));
                $('#re-save-form').submit();
            }
        }

    };
</script>

<div class="nav-tree">Release&nbsp;&nbsp;:&nbsp;&nbsp;</div>
<img src="/images/search_10.jpg" width="600" height="2" />
<div style="clear:both"><br/></div>
% if details:
<form id="re-save-form" action="/ship/saveRelease" method="post">
<input type="hidden" name="orderID" value="${order_header.id}" />
<input type="hidden" name="warehouseID" value="${warehouse.id}" />
<input type="hidden" name="detailIDs" value="" />
<table cellspacing="0" cellpadding="0" border="0" width="760" class="gridTable">
    <thead>
    <tr>
        <td align="center" width="100" class="wt-td">Bag Item No.</td>
        <td align="center" width="80" class="wt-td">Warehouse</td>
        <td align="center" width="80" class="wt-td">Order Qty</td>
        <td align="center" width="80" class="wt-td">Qty Reserved</td>
        <td align="center" width="80" class="wt-td">Qty Shipped</td>
        <td align="center" width="80" class="wt-td">Available Qty</td>
        <td align="center" width="160" class="wt-td">Release Qty</td>
    </tr>
    </thead>
    <tbody>
    %for index, d in enumerate(details):
    %if index%2==0:
    <tr class="even">
    %else:
    <tr class="odd">
    %endif
    <%
        qty = d.qty
        qtyReserved = d.qtyReserved
        qtyShipped = d.qtyShipped
        availableQty = d.item.availableQtyByWarehouse(warehouse.id)
    %>
        <td height="20" align="center" class="t-td">${d.item}</td> 
        <td align="center" class="t-td">${warehouse.name}</td>
        <td align="center" class="t-td">${qty}</td> 
        <td align="center" class="t-td">${qtyReserved}</td>  
        <td align="center" class="t-td">${qtyShipped}</td>
        <td align="center" class="t-td">${availableQty}</td>  
        <td align="center" class="t-td">
            % if qtyReserved - qtyShipped > 0:
            <input type="text" name="qty-${d.id}" min="1" max='${qtyReserved - qtyShipped}' class="required numeric digits"/>
            % else:
            &nbsp;
            % endif
        </td>
    </tr>
    %endfor
    <tr>
        <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="7">&nbsp;</td>
    </tr>
    <tr>
        <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="7">
              <a class="submit" href="javascript:toSubmit()"><img src="/images/images/menu_submit_g.jpg"></a>
        </td>
        </tr>
    </tbody>
</table>
</form>
% endif
<div style="clear:both"><br /></div>
