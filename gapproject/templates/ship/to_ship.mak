<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style type="text/css">
label{
    display: block;
}
</style>
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.validate.min.js"></script>
<script type="text/javascript" src="/javascript/jquery.ui.datepicker.validation.min.js"></script>
<script type="text/javascript">

    $(function(){
        $(".numeric").numeric({ negative : false });
        $('#re-save-form').validate();
        var dateFormat = 'yy-mm-dd';
        $(".datePicker").datepicker({dateFormat: dateFormat});

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
</head>
<body>
<div class="nav-tree">To Ship&nbsp;&nbsp;:&nbsp;&nbsp;</div>
<img src="/images/search_10.jpg" width="600" height="2" />
<div style="clear:both"><br/></div>
% if details:
<form id="re-save-form" action="/ship/saveShip" method="post">
<input type="hidden" name="orderID" value="${order_header.id}" />
<input type="hidden" name="warehouseID" value="${warehouse.id}" />
<input type="hidden" name="detailIDs" value="" />

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td width="100%" align="left" valign="top">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="100%" valign="top" align="left">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0"> 
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;r-pac Confirmation No&nbsp;:
                                </td>
                                <td>
                                    ${order_header.orderNO}
                                </td>
                            </tr> 
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Invoice Number&nbsp;:
                                </td>
                                <td>
                                    <input type="text" name="invoiceNumber"/>
                                </td>
                            </tr> 
                            <!--
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Invoice(USD)&nbsp;:
                                </td>
                                <td>
                                    <"System Auto Calculate">
                                </td>
                            </tr> -->
                            <!-- <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Other Invoice(USD)&nbsp;:
                                </td>
                                <td>
                                    <input type="text" name="otherInvoice" class="numeric"/>
                                </td>
                            </tr> -->
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;*Ship Date (yyyy-mm-dd)&nbsp;:
                                </td>
                                <td>
                                    <input type="text" name="createTime" class="datePicker required dpDate"/>
                                </td>
                            </tr>
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;&nbsp;Remarks&nbsp;:
                                </td>
                                <td>
                     <textarea id="remark"  name="remark" cols="45" rows="4" class="textarea-style"></textarea>
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
</table>
<div style="clear:both"><br/></div>

<table cellspacing="0" cellpadding="0" border="0" width="100%" class="gridTable">
    <thead>
    <tr>
        <td align="center" width="120" class="wt-td">Bag Item No.</td>
        <td align="center" width="60" class="wt-td">Warehouse</td>
        <td align="center" width="60" class="wt-td">Price(USD)</td>
        <td align="center" width="60" class="wt-td">Order Qty</td>
        <!-- <td align="center" width="60" class="wt-td">Qty Reserved</td> -->
        <td align="center" width="60" class="wt-td">Available Qty</td>
        <td align="center" width="60" class="wt-td">Qty Shipped</td>
        <td align="center" width="120" class="wt-td">*Ship Qty</td>
        <td align="center" width="120" class="wt-td">*Internal ref. OrderNumber</td>
        <td align="center" width="80" class="wt-td">InvoiceDate(yyyy-mm-dd)</td>
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
        # qtyReserved = d.qtyReserved
        avaQty =  d.item.availableQtyByWarehouse(warehouse.id)
        qtyShipped = d.qtyShipped
        maxShipQty = qty - qtyShipped if (qty - qtyShipped) <=  avaQty else avaQty
    %>
        <td height="30" align="center" class="t-td">${d.item}</td> 
        <td align="center" class="t-td">${warehouse.name}</td>
        <td align="center" class="t-td">${d.item.getPrice(warehouse.regionID)}</td> 
        <td align="center" class="t-td">${qty}</td> 
        <%doc><td align="center" class="t-td">${qtyReserved}</td></%doc>  
        <td align="center" class="t-td">${avaQty}</td>
        <td align="center" class="t-td">${qtyShipped}</td> 
        % if qtyShipped >= qty or avaQty < 1:
        <td align="center" class="t-td">&nbsp;</td>
        <td align="center" class="t-td">&nbsp;</td>
        <td align="center" class="t-td">&nbsp;</td>
        % else:
        <td align="center" class="t-td">
            <input type="text" name="qty-${d.id}"  min="1" max="${maxShipQty}" class="required numeric digits"/>
        </td>
        <td align="center" class="t-td">    
            <input type="text" name="internalPO-${d.id}" class="required"/>
        </td>
        <td align="center" class="t-td">    
            <input type="text" name="invoiceDate-${d.id}" class="datePicker dpDate"/>
        </td>
        % endif
    </tr>
    %endfor
    <tr>
        <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="9">&nbsp;</td>
    </tr>
    <tr>
        <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="9">
              <a class="submit" href="javascript:toSubmit()"><img src="/images/images/menu_submit_g.jpg"></a>
        </td>
        </tr>
    </tbody>
</table>
</form>
% endif
<div style="clear:both"><br /></div>

</body>
</html>