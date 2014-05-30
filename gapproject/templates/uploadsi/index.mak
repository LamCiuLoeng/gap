<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.mako_filter import b,tp
    from gapproject.util.common import Date2Text, rpacEncrypt
    from gapproject.util.gap_const import orderStatus, SHIPPED_COMPLETE, CANCEL, RESERVED_FAIL
%>

<%def name="extTitle()">r-pac - GAP - Upload SI</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/flora.datepicker.css" type="text/css" media="screen"/>
<link rel="stylesheet" href="/css/jquery.autocomplete.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<style>
#tooltipdiv {
    display:none;
    background:transparent url(/images/jqueryTools/white_arrow.png);
    font-size:12px;
    height:70px;
    width:160px;
    padding:25px;
}
</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery.tools.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.columnfilters.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.bgiframe.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/ui.datepicker.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/gap_ac.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/gap_search.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.validate.min.js"></script>
<script language="JavaScript" type="text/javascript">
    //<![CDATA[
$(document).ready(function(){

    $('#uploadform').validate({
        rules: { sifile: { required: true, accept: "xls|xlsx", filesize: 1048576  }},
        messages: { sifile: "  **File must be xls or xlsx, less than 1MB!" }
    });

    var dateFormat = 'yy-mm-dd';
    
    $(".datePicker").datepicker({firstDay: 1 , dateFormat: dateFormat});
    $(".v_is_date").attr("jVal",
                         "{valid:function (val) {if(val!=''){return /^[0-9]{4}\\-[0-9]{2}\\-[0-9]{2}$/.test(val) }return true;}, message:'YYYY-MM-DD', styleType:'cover'}");    
});

var search_url = "/uploadsi/index";

function toSearch(){
    var f = $(".tableform");
    $(f).attr("action", search_url).submit();
}

    //]]>
</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="64" valign="top" align="left"><a href="/"><img src="/images/images/menu_gap_g.jpg"/></a></td>
    <td width="64" valign="top" align="left">
        <a href="javascript:toSearch()">
            <img src="/images/images/menu_search_g.jpg"/>
        </a>
    </td>
    <td width="64" valign="top" align="left"><a href="/uploadsi/new"><img src="/images/images/menu_new_g.jpg"/></a></td>
    <td width="23" valign="top" align="left">
        <img height="21" width="23" src="/images/images/menu_last.jpg"/>
    </td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div style="clear:both"></div>
 
<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Upload SI&nbsp;&nbsp;&gt;&nbsp;&nbsp;Search</div>
<div style="width:1200px;margin:0px;">

    <div style="overflow:hidden;margin:5px 0px 5px 0px">
        <form name="DataTable" class="tableform" method="post" action="index">
            <div>
                ${search_form(value=values)|n}
            </div>
        </form>
    </div>
</div>
<div style="clear:both"><br /></div>
<div id="recordsArea">
    <table class="gridTable" cellpadding="0" cellspacing="0" border="0">
        <%
            label_attrs = [ ('Upload No.', 220),
                            ('SI File Name', 220), 
                            ('Created By', 150), ('Created Date', 200),
                            ('Download', 200)
                            ]

            my_page = tmpl_context.paginators.collections
            pager = my_page.pager(symbol_first = "<<", show_if_single_page = True)
        %>
        <thead>
            %if my_page.item_count > 0 :
            <tr>
                <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="${len(label_attrs)}">
                    ${pager}, <span>${my_page.first_item} - ${my_page.last_item}, ${my_page.item_count} records</span>
                </td>
            </tr>
            %endif
            <tr height="26">
                % for label,width in label_attrs:
                    <th width="${width}">${label|b}</th>
                % endfor
            </tr>
        </thead>
        <tbody>
            % for index,item in enumerate(my_page.items):

            %if index%2==0:
            <tr class="odd">
            %else:
            <tr class="even">
            %endif
                <td>
                <a href="/uploadsi/view?ushid=${item.id}">
                ${item.id|b}
                </a>
                <td>${item.filename|b}</td>
                <td>${item.issuedBy|b}</td>
                <td>${Date2Text(item.createTime)|b}</td>
                <td><a href="${item.filepath}" target="_blank">${item.filename}</a></td>
            </tr>
            % endfor

            %if my_page.item_count > 0 :
            <tr>
                <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="${len(label_attrs)}">
                    ${pager}, <span>${my_page.first_item} - ${my_page.last_item}, ${my_page.item_count} records</span>
                </td>
            </tr>
            %endif
        </tbody>
    </table>
</div>

<div id="tooltipdiv"></div>