<%inherit file="gapproject.templates.master"/>

<%
  from repoze.what.predicates import not_anonymous, in_group, has_permission
%>

<%def name="extTitle()">r-pac - Help</%def>

<div style="width:1000px;padding:20px;">
	    <table cellspacing="0" cellpadding="0" border="0" id="dataTable" class="gridTable">
	       <thead>
    	       <tr>
    	           <th style="height:30px;width:250px">Location</th>
    	           <th style="width:250px">E-mail</th>
    	           <th style="width:500px">Telephone</th>
    	       </tr>
	       </thead>
        %for s in shops:
	       <tr>
	           <td style="border-left:1px solid #ccc;height:25px;">${s.name}</td>
	           <td><a href="mailto:${s.email}">${s.email}</a></td>
	           <td>${s.telephone}</td>
	       </tr>
	    %endfor
	    </table>
</div>