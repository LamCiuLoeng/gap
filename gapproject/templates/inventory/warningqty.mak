<%inherit file="gapproject.templates.master"/>
<%def name="extTitle()">r-pac - Inventory Set Warning Qty</%def>
<%def name="extCSS()">
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/numeric.js"></script>
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

    var checkForm = function(){
        var qty = $("input[name='warning_qty']").val();
        
        if(!checkNum(qty)){
            showError("Please input correct qty!");
        }else{
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

            <td width="64" valign="top" align="left"><a href="/inventory/index"><img src="/images/images/menu_inventory_g.jpg"/></a></td>

            <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
            <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
            </tr>
        </tbody></table>
</div>

<div class="nav-tree">Inventory&nbsp;&nbsp;&gt;&nbsp;&nbsp;Set Warning Qty</div>

<div style="clear:both"><br /><br /><br /></div>

%if inventory:
<form id="update-form" action="/inventory/saveWarningQty" method="post">
<input type="hidden" name="id" value="${inventory.id}" /> 

<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:930px; margin-left:2px;">
    <thead>
        <tr>
            <th width="150" height="20">Bag Item Code</th>
            <th width="100">Warehouse</th>
            <th width="100">Inventory qty</th>
            <th width="200">Warning Qty</th>
            <th width="220">Change Warning Qty</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>${inventory.item}&nbsp;</td>
            <td>${inventory.warehouse}&nbsp;</td>
            <td>${inventory.qty}&nbsp;</td>
            <td>${inventory.warning_qty}&nbsp;</td>
            <td>
                <input type="text" name="warning_qty" class="numeric" />&nbsp;
                 <a class="submit" href="#" onclick="checkForm()"><img src="/images/images/menu_submit_g.jpg"></a>
            </td>
        </tr>
        
    </tbody>
</table>
</form>
%endif
