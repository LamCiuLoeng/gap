<%inherit file="gapproject.templates.master"/>

<%def name="extTitle()">r-pac - Access - Role</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/custom/access.css" type="text/css" />
</%def>

<%def name="extJavaScript()">
    <script type="text/javascript" language="JavaScript">
    //
        $(document).ready(function(){
            $("form").submit(function(){
                var uigs = new Array();
                $("option","#userInGroup").each(function(){
                    uigs.push( $(this).val() );
                });

                var uogs = new Array();
                $("option","#userOutGroup").each(function(){
                    uogs.push( $(this).val() );
                });

                $(this).append("<input type='hidden' name='uigs' value='"+uigs.join("|")+"'/>");
                $(this).append("<input type='hidden' name='uogs' value='"+uogs.join("|")+"'/>");


                var pigs = new Array();
                $("option","#permissionInGroup").each(function(){
                    pigs.push( $(this).val() );
                });

                var pogs = new Array();
                $("option","#permissionOutGroup").each(function(){
                    pogs.push( $(this).val() );
                });

                $(this).append("<input type='hidden' name='pigs' value='"+pigs.join("|")+"'/>");
                $(this).append("<input type='hidden' name='pogs' value='"+pogs.join("|")+"'/>");

            });
        });

        function toSave(){
            if(!$("#group_name").val()){
               alert("Please input the role's name!");
               return false;
            }else{
                var p = {
                    action : "${values.get('ACTION','')}",
                    id : "${values.get('id','')}",
                    k : 'GROUP',
                    v : $("#group_name").val(),
                    t : Date.parse(new Date())
                }
                $.getJSON('/access/ajaxCheck',p,function(r){
                    if(r.code!=0){
                        alert(r.msg);
                        return;
                    }else{
                        $("form").submit();
                    }
                });
            }
        }

        function addOption(d1,d2){
            var div1 = $("#"+d1);
            var div2 = $("#"+d2);
            $(":selected",div1).each(function(){
                div2.append(this);
            });
        }

    //
    </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/access/index"><img src="/images/images/menu_am_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toSave()"><img src="/images/images/menu_save_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Access&nbsp;&nbsp;&gt;&nbsp;&nbsp;Role Management</div>

<div>
    <form action="/access/save_group" method="POST">
        ${widget(values)|n}
        %if showuser:
            <input type="hidden" name="U" value="TRUE"/>
        %endif
    </form>
</div>

<div style="clear:both"><br /></div>

<div style="overflow: auto; width: 1300px;">
    %if showuser:
    <div class="s_m_div" style="float: left;">
        <div class="select_div">
            <ul>
                <li><label for="userInGroup">Include the users : </label></li>
                <li>
                    <select name="userInGroup" id="userInGroup" multiple="">
                        %for u in included:
                            <option value="${u.user_id}">${u.user_name}</option>
                        %endfor
                    </select>
                </li>
            </ul>
        </div>
        <div class="bt_div">
            <input type="image" value="Add" onclick="addOption('userOutGroup','userInGroup');return false;" src="/images/images/right2left.jpg"/>
            <br/><br/>
            <input type="image" value="Delete" onclick="addOption('userInGroup','userOutGroup');return false;" src="/images/images/left2right.jpg"/>
        </div>
        <div class="select_div">
            <ul>
                <li><label for="userOutGroup">Exclude the users : </label></li>
                <li>
                    <select name="userOutGroup" id="userOutGroup" multiple="">
                        %for u in excluded:
                            <option value="${u.user_id}">${u.user_name}</option>
                        %endfor
                    </select>
                </li>
            </ul>
        </div>
    </div>
    %endif 

    <div class="s_m_div">
        <div class="select_div">
            <ul>
                <li><label for="permissionInGroup">Get the permissions : </label></li>
                <li>
                    <select name="permissionInGroup" id="permissionInGroup" multiple="">
                        %for p in got:
                            <option value="${p.permission_id}">${p}</option>
                        %endfor
                    </select>
                </li>
            </ul>
        </div>
        <div class="bt_div">
            <input type="image" value="Add" onclick="addOption('permissionOutGroup','permissionInGroup');return false;" src="/images/images/right2left.jpg"/>
            <br/><br/>
            <input type="image" value="Delete" onclick="addOption('permissionInGroup','permissionOutGroup');return false;" src="/images/images/left2right.jpg"/>
        </div>
        <div class="select_div">
            <ul>
                <li><label for="permissionOutGroup">Don't get the permissions : </label></li>
                <li>
                    <select name="permissionOutGroup" id="permissionOutGroup" multiple="">
                        %for p in lost:
                            <option value="${p.permission_id}">${p}</option>
                        %endfor
                    </select>
                </li>
            </ul>
        </div>
    </div>
</div>

