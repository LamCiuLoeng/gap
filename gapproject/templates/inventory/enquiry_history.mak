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

<div class="nav-tree">  Inventory For GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp; Detail</div>
<div class="case-list-one">
            <ul>
                <li class="label"><label id="item_number.label" for="item_number" class="fieldlabel">Bag Item Code</label></li>
                <li><input type="text" id="item_number" class="width-250" name="item_number" value="${item_number}" disabled="disabled"/></li>
            </ul>
</div>
<div style="clear:both"><br /></div>
<div style="clear:both"><br /></div>


%if result:
<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1000px; margin-left:3px;">
    <thead>
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="10"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
        <tr>
            <th width="100">Warehouse</th>
            <th width="200">Bag Item Code</th>
            <th width="100">Type</th>
            <th width="160">Qty ${values.get('t', '')}</th>
            <th width="200">Qty(Before action)</th>
            <th width="200">Qty(After action)</th>
            <th width="200">Remark</th>
            <th width="160">OrderNO</th>
            <th width="180">Created Time</th>
            <th width="100">Created By</th>
        </tr>
    </thead>
    <tbody>
			%for u in tmpl_context.paginators.result.items:
        <tr id="${u.id}" height="30">
            <td>${u.warehouse}&nbsp;</td>
            <td>${u.item}&nbsp;</td>
            <td>
                %if u.type=='received': 
                <span style="color:green; font-weight:bold;">${u.type}</span>
                %else:
                <span style="color:red; font-weight:bold;">${u.type}</span>
                %endif
                &nbsp;
            </td>
            <td>${u.qty}&nbsp;</td>
            <td>${u.before_qty}&nbsp;</td>
            <td>${u.after_qty}&nbsp;</td>
            <td>${u.remark}&nbsp;</td>
            <td>${u.orderHeader.orderNO if u.orderHeader else ''}&nbsp;</td>
            <td>${Date2Text(u.createTime, "%Y-%m-%d %H:%M:%S") if u.createTime else ''}&nbsp;</td>
            <td>${u.issuedBy}&nbsp;</td>

        </tr>
			%endfor
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="10"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
    </tbody>
</table>
%endif