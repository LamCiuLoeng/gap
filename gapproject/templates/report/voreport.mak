<%inherit file="gapproject.templates.master"/>
<%
    from gapproject.util.common import Date2Text
%>
<%def name="extTitle()">r-pac - Vendor orders info Report</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/flora.datepicker.css" type="text/css" media="screen"/>
<link rel="stylesheet" href="/css/jquery.autocomplete.css" type="text/css" />
</%def>
<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/ui.datepicker.js"></script>
<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/inventory.js"></script>
<script type="text/javascript" src="/javascript/custom/gap_ac.js"></script>
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
            <td width="64" valign="top" align="left"><a href="/"><img src="/images/images/menu_gap_g.jpg"/></a></td>
            <td width="64" valign="top" align="left"><a href="#" onclick="toSearch()"><img src="/images/images/menu_export_g.jpg"/></a></td>
            
            <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
            <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
            </tr>
        </tbody></table>
</div>

<div class="nav-tree">Vendor orders info&nbsp;&nbsp;&gt;&nbsp;&nbsp;Report</div>


<div>
	${widget(values,action=("/voreport/export"))|n}
</div>

<div style="clear:both"><br /></div>