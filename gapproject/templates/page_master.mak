<%inherit file="gapproject.templates.master"/>

<%!
	from tg.flash import get_flash,get_status
	from repoze.what.predicates import has_permission
%>

<%def name="extTitle()">r-pac - Master</%def>
<%def name="extCSS()">
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
</%def>
<div class="main-div">
	<div id="main-content">
        %if has_permission("MASTER_CATEGORY"):
    		<div class="block">
    			<a href="/category/index"><img src="/images/category.jpg" width="55" height="55" alt="" /></a>
    			<p><a href="/category/index">Category</a></p>
    			<div class="block-content">The module is the Category master of the "GAP Project" .</div>
    		</div>
        %endif
        
        %if has_permission("MASTER_ITEM"):
    		<div class="block">
    			<a href="/item/index"><img src="/images/item.jpg" width="55" height="55" alt="" /></a>
    			<p><a href="/item/index">Item</a></p>
    			<div class="block-content">The module is the item master of the "GAP Project" .</div>
    		</div>
        %endif
        
        %if has_permission("MASTER_REGION"):
    		<div class="block">
    			<a href="/region/index"><img src="/images/region.jpg" width="55" height="55" alt="" /></a>
    			<p><a href="/region/index">Region</a></p>
    			<div class="block-content">The module is the region master of the "GAP Project" .</div>
    		</div>
        %endif

        %if has_permission("MASTER_PRICE"):
    		<div class="block">
    			<a href="/price/index"><img src="/images/price.jpg" width="55" height="55" alt="" /></a>
    			<p><a href="/price/index">Price</a></p>
    			<div class="block-content">The module is the price master of the "GAP Project" .</div>
    		</div>
        %endif

        %if has_permission("MASTER_CONTACT"):
    		<div class="block">
    			<a href="/contact/index"><img src="/images/contact.jpg" width="55" height="55" alt="" /></a>
    			<p><a href="/contact/index">Contact</a></p>
    			<div class="block-content">The module is the contact master of the "GAP Project" .</div>
    		</div>
        %endif
        
        
        %if has_permission("MASTER_WAREHOUSE"):
    		<div class="block">
    			<a href="/warehouse/index"><img src="/images/warehouse.jpg" width="55" height="55" alt="" /></a>
    			<p><a href="/warehouse/index">Warehouse</a></p>
    			<div class="block-content">The module is the warehouse master of the "GAP Project" .</div>
    		</div>
        %endif
        
        %if has_permission("MASTER_BILLTO"):
    		<div class="block">
    			<a href="/billto/index"><img src="/images/billto.jpg" width="55" height="55" alt="" /></a>
    			<p><a href="/billto/index">BillTo</a></p>
    			<div class="block-content">The module is the BillTo master of the "GAP Project" .</div>
    		</div>
        %endif
        
        %if has_permission("MASTER_SHIPTO"):
    		<div class="block">
    			<a href="/shipto/index"><img src="/images/shipto.jpg" width="55" height="55" alt="" /></a>
    			<p><a href="/shipto/index">ShipTo</a></p>
    			<div class="block-content">The module is the ShipTo master of the "GAP Project" .</div>
    		</div>
        %endif

        %if has_permission("MASTER_GAP_ONCL_DEPARTMENT"):
    	    <div class="block">
    	    	<a href="/oncldivision/index"><img src="/images/oncl_dept.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/oncldivision/index">GAP ONCL Department</a></p>
    	    </div>
        %endif
    
        %if has_permission("MASTER_GAP_ONCL_CATEGORY"):
    	    <div class="block">
    	    	<a href="/onclcategory/index"><img src="/images/oncl_cat.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/onclcategory/index">GAP ONCL Category</a></p>
    	    </div>
        %endif
    	
    	%if has_permission("MASTER_GAP_ONCL_FIT"):
    	    <div class="block">
                <a href="/onclfit/index"><img src="/images/oncl_size.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/onclfit/index">GAP ONCL Fit</a></p>
            </div>
        %endif
        
        %if has_permission("MASTER_GAP_ONCL_SIZE"):
    	    <div class="block">
    	    	<a href="/onclsize/index"><img src="/images/oncl_size.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/onclsize/index">GAP ONCL Size</a></p>
    	    </div>
        %endif
    	
    	%if has_permission("MASTER_GAP_CARE_INSTRUCTION"):
    	    <div class="block">
    	    	<a href="/careinstruction/index"><img src="/images/oncl_care.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/careinstruction/index">GAP Care Instruction</a></p>
    	    </div>
    	%endif
    	
    	%if has_permission("MASTER_GAP_CHINA_PRODUCT_NAME"):
    	    <div class="block">
    	    	<a href="/chinaproductname/index"><img src="/images/import.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/chinaproductname/index">GAP China Product Name</a></p>
    	    </div>
    	%endif
    	    	
    	%if has_permission("MASTER_GAP_COUNTRY"):
    	    <div class="block">
    	    	<a href="/country/index"><img src="/images/import.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/country/index">GAP Country</a></p>
    	    </div>
    	%endif    	

    	%if has_permission("MASTER_GAP_FIBER"):
    	    <div class="block">
    	    	<a href="/fiber/index"><img src="/images/import.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/fiber/index">GAP Fiber</a></p>
    	    </div>
    	%endif
    	
    	%if has_permission("MASTER_GAP_FINISHES_WEAVE"):
    	    <div class="block">
    	    	<a href="/finishesweave/index"><img src="/images/import.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/finishesweave/index">GAP Finishes Weave</a></p>
    	    </div>
    	%endif
    	
    	%if has_permission("MASTER_GAP_FITS_DESCRIPTION"):
    	    <div class="block">
    	    	<a href="/fitsdescription/index"><img src="/images/import.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/fitsdescription/index">GAP Fits Description</a></p>
    	    </div>
    	%endif
    	    	
    	%if has_permission("MASTER_GAP_SECTIONAL_CALL_OUT"):
    	    <div class="block">
    	    	<a href="/sectionalcallout/index"><img src="/images/import.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/sectionalcallout/index">GAP Sectional Call Out</a></p>
    	    </div>
    	%endif    	
    	
    	%if has_permission("MASTER_GAP_WARNING"):
    	    <div class="block">
    	    	<a href="/warning/index"><img src="/images/import.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/warning/index">GAP Warning</a></p>
    	    </div>
    	%endif

	</div>
</div>
