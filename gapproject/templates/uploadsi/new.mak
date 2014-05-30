<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.mako_filter import b,tp
    from gapproject.util.common import Date2Text, rpacEncrypt
%>

<%def name="extTitle()">r-pac - GAP - Upload SI</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<style>

</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery.validate.min.js"></script>
<script language="JavaScript" type="text/javascript">
    //<![CDATA[
$(document).ready(function(){
    $('#uploadform').validate({
        rules: { sifile: { required: true, accept: "xls|xlsx"}},
        messages: { sifile: "  **File must be xls or xlsx!" }
    });
});

    //]]>
</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="64" valign="top" align="left"><a href="/"><img src="/images/images/menu_gap_g.jpg"/></a></td>
    <td width="64" valign="top" align="left">
        <a href="/uploadsi/index">
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
 
<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Upload SI Report To Create Shipment</div>
<br />
&nbsp;&nbsp;<img src="/images/error.gif">
<br />
&nbsp;&nbsp;<strong class="title2">
r-pac Confirmation# must be in SO Other Ref!
<br />
&nbsp;&nbsp;&nbsp;Please don't change anything in SI's report after downloaded from ERP!
<br />
&nbsp;&nbsp;&nbsp;The Delivery Date's format must be 'dd/mm/yyyy'!
<br />
&nbsp;&nbsp;&nbsp;Please do not upload duplicate data!
</strong>
<br /><br />
<img src="/images/search_10.jpg" width="700" height="2" />
<div style="clear:both"><br /></div>
<div style="width:800px;margin:30px 0 0 100px;">
<form id="uploadform" action="/uploadsi/createShip" method="post" enctype="multipart/form-data">
&nbsp;&nbsp;&nbsp;&nbsp;SI Report File: &nbsp;&nbsp;<input type="file" name="sifile" id="sifile" /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Submit" />
</form>
</div>
<div style="clear:both"><br /></div>