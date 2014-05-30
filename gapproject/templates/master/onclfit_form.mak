<%inherit file="gapproject.templates.master"/>
<%namespace name="tw" module="tw.core.mako_util"/>
<%def name="extTitle()">r-pac - Master</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/jquery.multiSelect.css" type="text/css" media="screen"/>
 <style type="text/css">

.width-220 {
    width: 220px;
}
  </style>
</%def>
<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery.multiSelect.js"></script>
<script type="text/javascript" src="/javascript/custom/gap_master_size.js"></script>
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[    	
		function toSave(){
		    var fs = ["division_id","category_id","name"];
		    var labels = ["Department Name","Category Name","Fit Name"];
		    var msg = [];
		    for(var i=0;i<fs.length;i++){
		        var t = $("#"+fs[i]);
		        if(!t.val()){ msg.push("The '" +labels[i]+ "' could not be blank!"); }
		    }
		    if(msg.length > 0){
		        alert(msg.join("\n"));
		        return false;
		    }else{
    			$("form").submit();
		    }
		}
		
		function toCancel(){
		  if(window.confirm("Are you sure to leave this page without saving your edit?")){
		      window.location.href = "/onclfit/index";
		  }else{
		      return false;
		  }
		}
		
		function changedep(c){
            var obj = $(c);
            if(!obj.val()){
              $("#category_id").html('');
            }else{
                var p = {
                    'division_id' : obj.val(),
                    't' : Date.parse(new Date())
                }
                $.getJSON('/onclsize/ajaxdep',p,function(r){
                    if(r.code != 0 ){
                        alert(r.msg);
                    }else{
                        var html = '<option></option>';
                        for(var i = 0 ;i < r.d.length;i++){
                            html += '<option value="'+r.d[i][0]+'">'+r.d[i][1]+'</option>';
                        }
                        $("#category_id").html(html);
                    }
                });
            }
        }
		
		function changecat(c){
		    var obj = $(c);
            if(!obj.val()){
              $("#fit_id").html('');
            }else{
                var p = {
                    'cat_id' : obj.val(),
                    't' : Date.parse(new Date())
                }
                $.getJSON('/onclsize/ajaxcat',p,function(r){
                    if(r.code != 0 ){
                        alert(r.msg);
                    }else{
                        var html = '<option></option>';
                        for(var i = 0 ;i < r.d.length;i++){
                            html += '<option value="'+r.d[i][0]+'">'+r.d[i][1]+'</option>';
                        }
                        $("#fit_id").html(html);
                    }
                });
            } 
		}
    //]]>
   </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/onclfit/index"><img src="/images/images/menu_onclfit_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toSave()"><img src="/images/images/menu_save_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toCancel()"><img src="/images/images/menu_cancel_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Master&nbsp;&nbsp;&gt;&nbsp;&nbsp;New or Update</div>

<div>
	<form action="/onclfit/save" method="post" class="required onclfitsearchform">
	   <input type="hidden" name="id" value="${values.get('id','')}"/>
        <div class="case-list-one">
            <ul>
                <li class="label"><label id="division_id.label" for="division_id" class="fieldlabel">Department Name</label></li>
                <li>
                    <select name="division_id" class="width-250" id="division_id" onchange="changedep(this)">
                        <option value=""></option>
                        %for d in divs:
                            <option value="${d.id}" ${tw.attrs([("selected",d.id == values.get('division_id',None))])}>${d}</option>
                        %endfor
                    </select>
                </li>
            </ul>
            <ul>
                <li class="label"><label id="name.label" for="name" class="fieldlabel">Fit Name</label></li>
                <li><input type="text" name="name" id="name" class="width-250" value="${values.get('name','')}"/></li>
            </ul>
        </div>
        <div class="case-list-one">
            <ul>
                <li class="label"><label id="category_id.label" for="category_id" class="fieldlabel">Category Name</label></li>
                <li>
                    <select name="category_id" class="width-250" id="category_id" onchange="changecat(this)">
                        <option value=""></option>
                        %for c in cats:
                            <option value="${c.id}" ${tw.attrs([("selected",c.id == values.get('category_id',None))])}>${c}</option>
                        %endfor
                    </select>
                </li>
            </ul>
        </div>
    </form>
</div>
