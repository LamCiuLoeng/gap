<!DOCTYPE html>
<%!
	from tg.flash import get_flash,get_status
	from repoze.what.predicates import not_anonymous,in_group,has_permission
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>${self.extTitle()}</title>
<link type="images/x-icon" rel="shortcut icon" href="/favicon.ico" />
<link type="text/css" rel="stylesheet" href="/css/impromt.css" />
<link type="text/css" rel="stylesheet" href="/css/screen.css" />
<link type="text/css" rel="stylesheet" href="/css/all.css" />
<script type="text/javascript" src="/javascript/jquery.1.7.1.min.js"></script>
${self.extCSS()}
<script type="text/javascript" src="/javascript/common.js"></script>
<script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js"></script>
<script type="text/javascript" src="/javascript/jquery.bgiframe.pack.js" language="javascript"></script>
%if get_flash():
<script language="JavaScript" type="text/javascript">
    $(document).ready(function(){
        %if get_status() == "ok":
        showMsg("${get_flash()|n}");
        %elif get_status() == "warn":
        showError("${get_flash()|n}");
        %endif
    });
</script>
%endif
${self.extJavaScript()}
</head>
<body>
    <div> 
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td width="200" valign="middle"><img src="/images/logo.jpg" width="737" height="72" /></td>
                <td valign="middle" bgcolor="#EDF6FF">
                    <div id="pageLogin"><span class="welcome">Welcome :</span> ${request.identity["user"].display_name} | <a href="/">Home</a> | <a href="/logout_handler">Logout</a></div>
                </td>
            </tr>
        </table>
    </div>
    <div class="menu-tab">
        <ul>
            % if has_permission("MAIN"):
                <li class="${'highlight' if tab_focus=='main' else ''}"><a href="/index">Main</a></li>
            %endif
            
            % if has_permission("TRACKING"):
                <li class="${'highlight' if tab_focus=='view' else ''}"><a href="/tracking">Tracking</a></li>
            % endif
            
            % if has_permission("MAIN_ORDER_OLD_NAVY_CARE_LABELS"):
                <li class="${'highlight' if tab_focus=='manage_ship_info' else ''} exttab"><a href="/oncl/manageAddress">Manage Ship Info</a></li>
            %endif
            
            % if has_permission("REPORTS"):
                <li class="${'highlight' if tab_focus=='report' else ''}"><a href="/report">Report</a></li>
            % endif
            
            % if has_permission("MASTER"):
                <li class="${'highlight' if tab_focus=='master' else ''}"><a href="/master">Master</a></li>
            %endif

            
            % if has_permission("ACCESS"):
                <li class="${'highlight' if tab_focus=='access' else ''}"><a href="/access">Access</a></li>
            %endif
           
            % if has_permission("HELP"):
                <li class="${'highlight' if tab_focus=='help' else ''}"><a href="/help">Help</a></li>
            %endif
        </ul>
    </div>
    <div class="clear"></div>
    ${self.header()}
    ${self.body()}
    <div id="footer"><span style="margin-right:40px">Copyright r-pac International Corp.</span></div>
</body>
</html>
<%def name="extTitle()">r-pac</%def>
<%def name="extCSS()"></%def>
<%def name="extJavaScript()"></%def>
<%def name="header()"></%def>