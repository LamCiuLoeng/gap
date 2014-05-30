<%inherit file="gapproject.templates.master"/>

<%
  from repoze.what.predicates import has_permission
%>

<%def name="extTitle()">r-pac - Report</%def>

<div class="main-div">
	<div id="main-content">

        % if has_permission("REPORTS_INTERNAL_REPORT"):
          <div class="block">
	    	  <a href="/inventory/report"><img src="/images/report.jpg" width="55" height="55" alt="" /></a>
	    	  <p><a href="/inventory/report">Internal Report</a></p>
	    	  <div class="block-content">The module is for the "Internal Report" .</div>
	      </div>
        % endif


        % if has_permission("REPORTS_ITEM_RECEIVED_REPORT"):
            <div class="block">
              <a href="/irreport/index"><img src="/images/price.jpg" width="55" height="55" alt="" /></a>
              <p><a href="/irreport/index">Item Received Report</a></p>
              <div class="block-content">The module is for the "Item Received Report" .</div>
            </div>
        % endif


        % if has_permission("REPORTS_CURRENT_INVENTORY_REPORT"):
            <div class="block">
      	    	<a href="/cireport/index"><img src="/images/cireport.jpg" width="55" height="55" alt="" /></a>
      	    	<p><a href="/cireport/index">Current Inventory Report</a></p>
      	    	<div class="block-content">The module is for the "Current inventory levels" .</div>
    	    </div>
        %endif

        % if has_permission("REPORTS_ORDERS_REPORT"):
            <div class="block">
              <a href="/voreport/index"><img src="/images/voreport.jpg" width="55" height="55" alt="" /></a>
              <p><a href="/voreport/index">Orders Report</a></p>
              <div class="block-content">The module is for the "Vendor orders info" .</div>
            </div>
        % endif

	</div>
</div>
