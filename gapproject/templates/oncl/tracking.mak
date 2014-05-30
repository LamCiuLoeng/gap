<%inherit file="gapproject.templates.master"/>

<%
	from gapproject.util.mako_filter import b, na
	from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - GAP - Order Old Navy Care Labels</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/jquery-ui-1.10.3.custom.min.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<style type="text/css">
	.input-width{
		width : 300px
	}
	
	#warning {
		font:italic small-caps bold 16px/1.2em Arial;
	}
	
	.option_c,.option_n {
	   display : none;
	}
	
	.gridTable td{
	   padding : 5px 2px 5px 2px;
	   height : 30px;
	}
	
	
</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery-ui-.10.3.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<script language="JavaScript" type="text/javascript">
//<![CDATA[
      $(document).ready(function(){
          $(".num").numeric();
          var height = $(window).height();
            //Change Overlay Height
            $(".jquery-ui-dialog-overlay-element").css('height',height);
            
          $( ".datePicker" ).datepicker({
            dateFormat: 'yy-mm-dd'
          });
      
          $( "#box" ).dialog({ autoOpen: false,
                               title : 'Edit Status',
                               modal : true,
                               width : 400,
                               height : 250,
                               resizable: true,
                               buttons : [
                                            {text:"Submit",click: function(){ ajaxSend(); }},
                                            {text:"Close", click: function() { $( this ).dialog( "close" ); } }
                                         ]
          });
      });
      
      function toSubmit(){
          $("#searhForm").attr("action","/oncl/tracking");
          $("#searhForm").submit();   
      }
      
      function toExport(){
          $("#searhForm").attr("action","/oncl/export");
          $("#searhForm").submit();   
      }
      
      function toEditStatus(){
          var cbs = $(".cboxClass:checked");
          if(cbs.length != 1){ alert('Please select one and only one record to edit!'); }
          else{           
              $("#box").dialog('open');
          }
      }
      
      function check_number(v){
        var pattern = /^[\d\.]+$/;
        return pattern.test(v); 
     }
      
    
      function ajaxSend(){
          var status = $('#box_status').val();
          var id = $(".cboxClass:checked").val();
          var params = {
              'id' : id,
              'status' : status,
              't' : Date.parse(new Date())
          };
          
          if(status == '2'){
              params['courier'] = $("#box_courier").val();
              params['trackingNo'] = $("#box_number").val();
              params['invoice'] = $("#box_invoice").val();
              
              if(!params['courier'] || !params['trackingNo'] || !params['invoice']){
                  alert('Please input the "Courier","Tracking numbers","Invoice number" !');
                  return;
              }         
          }else if(status == '0'){
             var price = $("#price").val();
             if(!price){
                alert('Please input the "250 bundle price"!');
                return;
             }else if(!check_number(price)){
                alert('Please input the correct price,tha value should be digital!');
                return;
             }
              params['price'] = $("#price").val();
          }
                        
          $.getJSON('/oncl/ajaxAction',params,function(r){
              if(r.code != '0'){
                  alert(r.msg);
              }else{
                  alert('Update the record successfully!');
                  window.location.reload(true);
              }
          })
      }
      
      
      function changeStatus(obj){
        var t = $(obj);
        if(t.val() == 2){  //it's complete
            $(".option_c").show();
        }else if(t.val() == 0){ //it's new
            $(".option_n").show();
        }else{
            $(".option_c,.option_n").hide();
        }
      }
//]]>
</script>

</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
  	<td width="64" valign="top" align="left"><a href="/tracking"><img src="/images/images/menu_return_g.jpg"/></a></td>  	
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Order Old Navy Care Labels</div>

<div style="margin: 10px 0px; overflow: hidden;">
<form action="/oncl/tracking" method="POST" id="searhForm">
        <div class="case-list-one">
            <ul>
                <li class="label">JOB NO<label id="no" for="no" class="fieldlabel"></label></li>
                <li><input name="no" type="text" id="no" class="width-250" value="${values.get('no','')}"></li>
            </ul>
            <ul>
                <li class="label">Job Status</li>
                <li>
                    <select name="status" id="status" class="width-250">
                        <option value=""></option>
                        %for (code,label) in [('0','Open'),('-1','Pending Quote approval'),('1','Printing'),('2','Completed'),('-2','Cancelled'),]:
                            %if code == values.get('status',None):
                                <option value="${code}" selected="selected">${label}</option>
                            %else:
                                <option value="${code}">${label}</option>
                            %endif
                        %endfor
                    </select>
                </li>
            </ul>
            <ul>
                <li class="label">
                    <label id="Label1" for="style" class="fieldlabel">r-pac manufacturing location</label></li>
                <li>
                    <select name="printShopId" id="printShopId" class="width-250">
                        <option value=""> </option>
                        %for p in printshops:
                            %if unicode(p.id) == values.get('printShopId',None) : 
                                <option value="${p.id}" selected="selected">${p}</option>
                            %else:
                                <option value="${p.id}">${p}</option>
                            %endif
                        %endfor
                    </select>
                </li>
            </ul>
        </div>
        <div class="case-list-one">
            <ul>
                <li class="label">Old Navy PO</li>
                <li><input name="onclpo" type="text" id="onclpo" class="width-250" value="${values.get('onclpo','')}"></li>
            </ul>
            <ul>
                <li class="label">Vendor PO</li>
                <li><input name="vendorpo" type="text" id="vendorpo" class="width-250" value="${values.get('vendorpo','')}"/></li>
            </ul>
            <!-- 
            <ul>
                <li class="label">
                    <label id="itemId" for="itemId" class="fieldlabel">Item</label></li>
                <li>
                    <input name="style" type="text" id="style" class="width-250"></li>
            </ul>
            -->
        </div>
        
        
        <div class="case-list-one" style="clear: both; width: 922px;">
            <ul style="width: 910px;">
                <li class="label" style="height: 40px; line-height: 40px;">
                    <label id="Label2" for="create_time_start" class="fieldlabel">
                        Create Date(yyyy-mm-dd)</label></li>
                <li style="width: 560px; float: left; font-size: 11px; font-weight: bold; line-height: 20px;">
                    <div>
                        <span style="width: 270px; display: block; float: left;">From</span> <span>To</span></div>
                    <div>
                        <input name="create_time_start" type="text" id="create_time_start" class="datePicker width-250" value="${values.get('create_time_start','')}"/>
                        &nbsp;&nbsp;&nbsp;&nbsp;
                        <input name="create_time_end" type="text" id="create_time_end"  class="datePicker width-250" value="${values.get('create_time_end','')}"/>
                    </div>
                </li>
            </ul>
        </div>
        
        <div class="clear"></div>
        
        <div style="margin-left: 10px; margin-top: 15px;">
            <input type="button" name="bntSearch" value="Search" id="bntSearch" class="btn" onclick="toSubmit()"/>
            &nbsp;&nbsp;
            %if in_group('Admin') or in_group('AE') :
            <input type="button" class="btn btndisable" id="btnMark" value="Edit status" onclick="toEditStatus()"/>
            &nbsp;&nbsp;
            %endif
            <input type="button" name="btnExport" value="Export" id="btnExport" class="btn" onclick="toExport()"/>
        </div>

</form>


<div style="clear:both"><br/><br/></div>

<div id="recordsArea" style="margin: 5px 0px 10px 10px">
<%
    my_page = tmpl_context.paginators.result
    pager = my_page.pager(symbol_first="<<",show_if_single_page=True)
%>
<table cellspacing="0" cellpadding="0" border="0" id="dataTable" class="gridTable">
    <thead>
        <tr>                     
            <th width="100"><input type="checkbox" value="0" onclick="selectAll(this)"></th>
            <th width="180">JOB NO</th>
            <th width="100">Old Navy PO</th>
            <th width="150">Vendor PO</th>
            <th width="150">Item</th>
            <th width="200">Create Date (HKT)</th>
            <th width="200">Create by</th>
            <th width="150">Total QTY</th>
            <th width="200">r-pac manufacturing location</th>
            <th width="150">Status</th>
            <th width="150">Completion Date(HKT)</th>
            <th width="150">Courier</th>
            <th width="150">Tracking numbers</th>
            <th width="150">Invoice number</th>
            %if in_group('Admin') or in_group('AE') :
                <th width="100">Invoice Total</th>
            %endif
        </tr>
    </thead>
    <tbody>
        %if len(result) < 1:
            <tr>
                <td colspan="20" style="border-left:1px solid #ccc">No records found!</td>
            </tr>
        %else:
            % for index,h in enumerate(result):
                <tr>
                    <td style="border-left:1px solid #cccccc;">&nbsp;
                        %if h.status not in [-2,2]:
                        <input type="checkbox" class="cboxClass" name="" value="${h.id}"/>
                        %endif
                     </td>
                    <td>&nbsp;<a href="/oncl/viewOrder?id=${h.id}">${h.no}</a></td>
                    <td>&nbsp;${h.onclpo}</td>
                    <td>&nbsp;${h.vendorpo}</td>
                    <td>&nbsp;${h.item}</td>
                    <td>&nbsp;${h.createTime.strftime("%Y-%m-%d %H:%M")}</td>
                    <td>&nbsp;${h.issuedBy}</td>
                    <td>&nbsp;${h.totalQty}</td>
                    <td>&nbsp;${h.printShop}</td>
                    <td>&nbsp;
                        %if h.status == 0:
                            <span style="font-weight: bold; color: blue">Open</span>
                        %elif h.status == 1:
                            <span style="font-weight: bold; color: orange">Printing</span>
                        %elif h.status == 2:
                            <span style="font-weight: bold; color: green">Completed</span>
                        %elif h.status == -2:
                            <span style="font-weight: bold; color: red">Cancelled</span>
                        %elif h.status == -1:
                            <span style="font-weight: bold; color: black">Pending quote approval</span>
                        %endif
                    </td>
                    <td>&nbsp;${h.completeDate}</td>
                    <td>&nbsp;${h.courier}</td>
                    <td>&nbsp;${h.trackingNo}</td>
                    <td>&nbsp;${h.invoice}</td>
                    %if in_group('Admin') or in_group('AE') :
                        <td>&nbsp;${h.amount}</td>
                    %endif
                </tr>
            %endfor
        %endif
        %if my_page.item_count > 0 :
            <tr>
                <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="20">
                    ${pager}, <span>${my_page.first_item} - ${my_page.last_item}, ${my_page.item_count} records</span>
                </td>
            </tr>
        %endif
    </tbody>            
</table>       
</div>



<div id="box">
    <table>
        <tr>
            <td style="width:120px">Status</td>
            <td>
                <select id="box_status" onchange='changeStatus(this)'>
                    <option value=""></option>
                    <option value="-1">Pending quote approval</option>
                    <option value="0">Open</option>
                    <!-- <option value="1">Printing</option> -->
                    <option value="2">Complete</option>
                    <option value="-2">Cancel</option>
                </select>
            </td>
        </tr>
        <tr class="option_c"><td>Courier</td><td><input type="text" id="box_courier"/></td></tr>
        <tr class="option_c"><td>Tracking numbers</td><td><input type="text" id="box_number"/></td></tr>
        <tr class="option_c"><td>Invoice number</td><td><input type="text" id="box_invoice"/></td></tr>
        <tr class="option_n"><td>price/each</td><td><input type="text" id="price" class="num"/></td></tr>
    </table>
</div>