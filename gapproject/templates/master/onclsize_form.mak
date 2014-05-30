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
		    var fs = ["division_id","category_id","us_size","china_size","japan_size"];
		    var labels = ["Department Name","Category Name","US Size","China Size","Japanese Size"];
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
		      window.location.href = "/onclsize/index";
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
    <td width="176" valign="top" align="left"><a href="/onclsize/index"><img src="/images/images/menu_onclsize_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toSave()"><img src="/images/images/menu_save_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toCancel()"><img src="/images/images/menu_cancel_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Master&nbsp;&nbsp;&gt;&nbsp;&nbsp;New or Update</div>

<div>
	<form action="/onclsize/save" method="post" class="required onclsizesearchform">
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
                <li class="label"><label id="fit_id.label" for="fit_id" class="fieldlabel">Fit</label></li>
                <li>
                    <select name="fit_id" class="width-250" id="fit_id">
                        <option value=""></option>
                        %for f in fits:
                            <option value="${f.id}" ${tw.attrs([("selected",f.id == values.get('fit_id',None))])}>${f}</option>
                        %endfor
                    </select>
                </li>
            </ul>
            <ul>
                <li class="label"><label id="china_size.label" for="china_size" class="fieldlabel">China Size</label></li>
                <li><input type="text" name="china_size" id="china_size" class="width-250" value="${values.get('china_size','')}"/></li>
            </ul>
            <ul>
                <li class="label"><label id="canada_size.label" for="canada_size" class="fieldlabel">Canada-French Size</label></li>
                <li><input type="text" name="canada_size" id="canada_size" class="width-250" value="${values.get('canada_size','')}"/></li>
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
            <ul>
                <li class="label"><label id="us_size.label" for="us_size" class="fieldlabel">US Size</label></li>
                <li><input type="text" name="us_size" id="us_size" class="width-250" value="${values.get('us_size','')}"/></li>
            </ul>
            <ul>
                <li class="label"><label id="japan_size.label" for="japan_size" class="fieldlabel">Japanese Size</label></li>
                <li><input type="text" name="japan_size" id="japan_size" class="width-250" value="${values.get('japan_size','')}"/></li>
            </ul>
            <ul>
                <li class="label"><label id="spanish_size.label" for="spanish_size" class="fieldlabel">Spanish Size</label></li>
                <li><input type="text" name="spanish_size" id="spanish_size" class="width-250" value="${values.get('spanish_size','')}"/></li>
            </ul>
        </div>
    </form>
</div>





