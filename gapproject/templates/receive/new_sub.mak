

<%
    from gapproject.util.mako_filter import b, na
    from repoze.what.predicates import in_group
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>r-pac - Receive Item - GAP</title>
<link type="images/x-icon" rel="shortcut icon" href="/favicon.ico" />
<link type="text/css" rel="stylesheet" href="/css/impromt.css" />
<link type="text/css" rel="stylesheet" href="/css/screen.css" />
<link type="text/css" rel="stylesheet" href="/css/all.css" />
<link rel="stylesheet" href="/css/jquery.autocomplete.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<style type="text/css">
    .input-width{
        width : 300px
    }
    
    #warning {
        font:italic small-caps bold 16px/1.2em Arial;
    }
</style>
<script type="text/javascript" src="/javascript/jquery.1.7.1.min.js"></script>
<script type="text/javascript" src="/javascript/common.js"></script>
<script type="text/javascript" src="/javascript/jquery.bgiframe.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript">
$(function(){
    $(".ajaxSearchField").each(function(){
        var jqObj = $(this);
        
        jqObj.autocomplete("/enquiry/getAjaxField", {
            extraParams: {
                'fieldName': jqObj.attr("fieldName")
                },
                
                formatItem: function(item){
                    return item[0]
                },
                
                matchCase: false
        });
    });

    $('#submit-btn').click(function(){
        var p = window.opener.document;
        var f = $('#search-form');
        var warehouseID = $('#warehouseID', p).val();
        if(warehouseID){
            var notInItemID = $('#itemIDs', p).val();
            var receivedDate = $('#receivedDate', p).val();
            $("input[name='notInItemID']", f).val(notInItemID);
            $("input[name='warehouseID']", f).val(warehouseID);
            $("input[name='receivedDate']", f).val(receivedDate);
            f.submit();
        }
    });

    $('#selectAll').click(function(){
        $(":checkbox").attr("checked",'true');
    });

    $('#ok-btn').click(function(){
        var itemIDs = [];
        var p = window.opener.document;
        var pf = $('#receiveForm', p);
        // var f = $('#search-form');
        // var warehouseID = $('#warehouseID', p).val();
        // if(warehouseID){
        //     var remark = $('#remark', p).val();
        //     var notInItemID = $('#notInItemID', p).val();
        //     $("input[name='notInItemID']", pf).val(notInItemID);
        //     // $("input[name='warehouseID']", f).val(warehouseID);
        //     // $("input[name='remark']", f).val(remark); 
        // }
        
        $("input:checked").each(function(){
            var v = $(this).val();
            itemIDs.push(v);

        });
        if(itemIDs.length > 0){
            var oldItemIDs = $('#itemIDs', p).val();
            if(oldItemIDs){
                itemIDs = oldItemIDs.split('|').concat(itemIDs);
            }

            var newItemIDs = itemIDs.join('|') || ''
            $("input[name='itemIDs']", pf).val(newItemIDs); 
            pf.attr('action', '/receive/new');
            pf.submit(); 
        }
            // p.location.reload(); 
        window.close();
    });
});



</script>

</head>
<body>
<div style="clear:both"></div>
<div class="nav-tree">Receive Item&nbsp;&nbsp;&gt;&nbsp;&nbsp;Search Item</div>
<form id="search-form" action="/receive/newSub" method="post">
<input type="hidden" name="notInItemID" value="" />
<input type="hidden" name="warehouseID" value="" />
<input type="hidden" name="receivedDate" value="" />

    <div class="case-list-one">
            <ul>
                <li class="label"><label id="item_number.label" for="item_number" class="fieldlabel">Bag Item No</label></li>
                <li><input xmlns="http://www.w3.org/1999/xhtml" type="text" name="item_number" class="width-250 ajaxSearchField ac_input" id="item_number" value="" fieldname="item_no" autocomplete="off"></li>

                <li class="label"><label for="search" class="fieldlabel">&nbsp;</label></li>
                <li><input id="submit-btn" type="button" value="Search" /></li>
            </ul>
    </div>

</form>

<div style="clear:both"><br /></div>
<div>
&nbsp;
<button id="ok-btn" type="button">&nbsp;&nbsp;&nbsp;&nbsp;Ok&nbsp;&nbsp;&nbsp;&nbsp;</button>
&nbsp;&nbsp;&nbsp;&nbsp;
<button type="button" onClick="javascript:self.close();">&nbsp;&nbsp;Cancel&nbsp;&nbsp;</button>
</div>
<div style="clear:both"><br /></div>
%if result:
<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:800px; margin-left:2px;">
    <thead>
        <tr>
            <td style="text-align:left;border:0 none;"><button id="selectAll" type="button">
                &nbsp;&nbsp;&nbsp;Select All&nbsp;&nbsp;&nbsp;</button></td>
            <td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="5"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
        <tr>
            <th width="100">Select?</th>
            <th width="180">Bag Item No#</th>
            <th width="100">Warehouse</th>
            <th width="120">On Hand Qty</th>
            <th width="120">Available Qty</th>
            <th width="80">Base Unit</th>
        </tr>
    </thead>
    <tbody>
            %for index, i in enumerate(tmpl_context.paginators.result.items):
        %if index%2==0:
            <tr class="odd" height="26">
            %else:
            <tr class="even" height="26">
        %endif
            <td><input type="checkbox" name="itemID-${i.id}" value="${i.id}"/></td>
            <td>${i.item_number}&nbsp;</td>
            <td>${warehouse.name}&nbsp;</td>
            <td>${i.onHandQtyByWarehouse(warehouse.id)}&nbsp;</td>
            <td>${i.availableQtyByWarehouse(warehouse.id)}&nbsp;</td>
            <td>PCS&nbsp;</td>
        </tr>
            %endfor
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="11"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
    </tbody>
</table>
%endif
</body>
</html>