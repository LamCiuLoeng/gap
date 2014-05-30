<%inherit file="gapproject.templates.master"/>

<%!
    from tg.flash import get_flash,get_status
    from repoze.what.predicates import is_user,has_permission
%>

<%def name="extTitle()">r-pac - Main</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
</%def>

<div class="main-div">
    <div id="main-content">
        %if has_permission("TRACKING_GID_POLYBAGS_TRACKING"):
            <div class="block">
                <a href="/order/search"><img src="/images/order.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/order/search">GID Polybags Tracking</a></p>
            </div>
        % endif
              
        %if has_permission("TRACKING_GAP_PRICE_TICKETS_ORDER_TRACKING"):
            <div class="block">
                <a href="http://gappolybag2.r-pac.com.hk/login.ashx?q=${request.identity["user"].code}&type=check"><img src="/images/import.jpg" width="55" height="55" alt="" /></a>
                <p><a href="http://gappolybag2.r-pac.com.hk/login.ashx?q=${request.identity["user"].code}&type=check">Gap price tickets order tracking</a></p>
            </div>
        %endif        

        %if has_permission("TRACKING_OLD_NAVY_CARE_LABELS_ORDER_TRACKING"):
            <div class="block">
                <a href="/oncl/tracking"><img src="/images/bby_mockup.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/oncl/tracking">Old navy Care Labels order tracking</a></p>
            </div>
        %endif
        
    </div>
</div>