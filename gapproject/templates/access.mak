<%inherit file="gapproject.templates.master"/>

<%
  from repoze.what.predicates import has_permission
%>

<%def name="extTitle()">r-pac - Access</%def>

<div class="main-div">
	<div id="main-content">
	   %if has_permission("ACCESS_USER"):
          <div class="block">
	    	  <a href="/access/user"><img src="/images/user.jpg" width="55" height="55" alt="" /></a>
	    	  <p><a href="/access/user">User</a></p>
	      </div>
	   %endif
	
	   %if has_permission("ACCESS_ROLE"):
          <div class="block">
              <a href="/access/group"><img src="/images/group.jpg" width="55" height="55" alt="" /></a>
              <p><a href="/access/group">Role</a></p>
          </div>
	   %endif
	   
	   <!--
	   %if has_permission("ACCESS_PERMISSION"):
          <div class="block">
              <a href="/access/permission"><img src="/images/permission.jpg" width="55" height="55" alt="" /></a>
              <p><a href="/access/permission">Permission</a></p>
          </div>
	   %endif 
	   -->
	</div>
</div>