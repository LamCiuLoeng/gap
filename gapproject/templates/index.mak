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
        %if has_permission("MAIN_ORDER_GID_POLYBAGS"):
            <div class="block">
                <a href="/order/index"><img src="/images/order.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/order/index">Order GID Polybags</a></p>
            </div>
        %endif
        
        %if has_permission("MAIN_ORDER_FORM_IMPORT"):
            <div class="block">
                <a href="/importOrder/index"><img src="/images/import.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/importOrder/index">Order Form Import</a></p>
            </div>
        %endif
        
        %if has_permission("MAIN_INVENTORY_ENQUIRY_BY_WAREHOUSE"):
            <div class="block">
                <a href="/enquiry/bywarehouse"><img src="/images/bywarehouse.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/enquiry/bywarehouse">Inventory Enquiry By Warehouse</a></p>
            </div>
        %endif
        
        %if has_permission("MAIN_RECEIVE_ITEM"):
             <div class="block">
                <a href="/receive/index"><img src="/images/receiveitem.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/receive/index">Receive Item</a></p>
            </div>
         %endif      
        
        %if has_permission("MAIN_SHIP_ITEM"):        
             <div class="block">
                <a href="/ship/index"><img src="/images/shipitem.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/ship/index">Ship Item</a></p>
            </div>
        %endif

                
        %if has_permission("MAIN_UPLOAD_SI_TO_SHIP"):
            <div class="block">
                <a href="/uploadsi/index"><img src="/images/uploadsi.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/uploadsi/index">Upload SI To Ship</a></p>
            </div>
        %endif

        %if has_permission("MAIN_STOCK_ADJUSTMENT"):
            <div class="block">
                <a href="/stockAdjustment/index"><img src="/images/adjustment.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/stockAdjustment/index">Stock Adjustment</a></p>
            </div>
        %endif
                
        
        %if has_permission("MAIN_INVENTORY_FOR_GAP"):
            <div class="block">
                <a href="/enquiry/byweek"><img src="/images/byweek.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/enquiry/byweek">Inventory For GAP</a></p>
            </div>
        % endif
            
        %if has_permission("MAIN_ORDER_GAP_PRICE_TICKET"):
            <div class="block">
                <a href="http://gappolybag2.r-pac.com.hk/login.ashx?q=${request.identity["user"].code}&type=order"><img src="/images/import.jpg" width="55" height="55" alt="" /></a>
                <p><a href="http://gappolybag2.r-pac.com.hk/login.ashx?q=${request.identity["user"].code}&type=order">Order Gap Price Ticket</a></p>
            </div>
        %endif       
           
        %if has_permission("MAIN_ORDER_OLD_NAVY_CARE_LABELS"):
            <div class="block">
                <a href="/oncl/placeorder"><img src="/images/bby_mockup.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/oncl/placeorder">Order Old Navy Care Labels</a></p>
            </div>
        %endif
     
    </div>
</div>