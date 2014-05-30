<%inherit file="gapproject.templates.master"/>
<%
    from gapproject.util.common import Date2Text
%>
<%def name="extTitle()">r-pac - Inventory</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/flora.datepicker.css" type="text/css" media="screen"/>
</%def>
<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/ui.datepicker.js"></script>
<script language="JavaScript" type="text/javascript">
    $(function(){
        var dateFormat = 'yy-mm-dd';

        $(".datePicker").datepicker({firstDay: 1 , dateFormat: dateFormat});

        $(".v_is_date").attr("jVal",

        "{valid:function (val) {if(val!=''){return /^[0-9]{4}\\-[0-9]{2}\\-[0-9]{2}$/.test(val) }return true;}, message:'YYYY-MM-DD', styleType:'cover'}");
    });

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

            <td width="64" valign="top" align="left"><a href="/enquiry/byweek"><img src="/images/images/menu_gap_g.jpg"/></a></td>
            <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
            <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
            </tr>
        </tbody></table>
</div>

<div class="nav-tree">  Inventory For GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp; Reserved Qty Detail</div>
<div class="case-list-one">
            <ul>
                <li class="label"><label id="item_number.label" for="item_number" class="fieldlabel">Bag Item No.</label></li>
                <li><input type="text" id="item_number" class="width-250" name="item_number" value="${item.item_number}" disabled="disabled"/></li>
            </ul>
            <ul>
                <li class="label"><label id="date.label" for="date" class="fieldlabel">Date</label></li>
                <li><input type="text" id="date" class="width-250" name="date" value="${date}" disabled="disabled"/></li>
            </ul>
</div>
<div style="clear:both"><br /></div>
<div style="clear:both"><br /></div>


%if result:
<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1000px; margin-left:3px;">
    <thead>
        <tr>
            <th width="100">Warehouse</th>
            <th width="200">Bag Item Code</th>
            <th width="160">Order Qty</th>
            <th width="160">Qty Reserved</th>
            <th width="160">r-pac Confirmation No.</th>
            <th width="180">Created Time</th>
            <th width="100">Created By</th>
        </tr>
    </thead>
    <tbody>
			%for u in result:
        <tr id="${u.id}" height="30">
            <td>${u.warehouse}&nbsp;</td>
            <td>${u.item}&nbsp;</td>
            <td>${u.orderDetail.qty}&nbsp;</td>
            <td>${u.qty}&nbsp;</td>
            <td>${u.orderHeader.orderNO if u.orderHeader else ''}&nbsp;</td>
            <td>${Date2Text(u.createTime, "%Y-%m-%d %H:%M:%S") if u.createTime else ''}&nbsp;</td>
            <td>${u.issuedBy}&nbsp;</td>

        </tr>
			%endfor
    </tbody>
</table>
%endif