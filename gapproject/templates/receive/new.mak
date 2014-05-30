<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.mako_filter import b, na
    from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - Receive Item - GAP</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/jquery.autocomplete.css" type="text/css" />
<link rel="stylesheet" href="http://code.jquery.com/ui/1.8.6/themes/start/jquery-ui.css" type="text/css" /> 
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<style type="text/css">
    .input-width{
        width : 300px
    }
    
    #warning {
        font:italic small-caps bold 16px/1.2em Arial;
    }
</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/jquery-ui-1.8.6.min.js"></script> 
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.validate.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.ui.datepicker.validation.min.js"></script>
<script type="text/javascript" src="/javascript/custom/receive.js" language="javascript"></script>
<script type="text/javascript">
 $(function(){
        // $('#re-save-form').validate();
        var dateFormat = 'yy-mm-dd';
        $(".datePicker").datepicker({dateFormat: dateFormat});

    });
</script>

</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="64" valign="top" align="left">
        <a href="javascript:history.back()"><img src="/images/images/menu_back_g.jpg"/></a>
    </td>
    <td width="64" valign="top" align="left">
        <a href="/receive/new"><img src="/images/images/menu_new_g.jpg"/></a>
    </td>
    % if warehouse:
    <td width="64" valign="top" align="left">
        <a class="confirm" href="javascript:void(0)" onclick="toConfirm()"><img src="/images/images/menu_confirm_g.jpg"/></a>
    </td>
    % endif
    <td width="64" valign="top" align="left">
        <a href="/receive/index" onclick="return toCancel()"><img src="/images/images/menu_cancel_g.jpg"/></a>
    </td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Receive Item&nbsp;&nbsp;&gt;&nbsp;&nbsp;New</div>
<form id="receiveForm" action="/receive/save" method="post">
<input type="hidden" name="itemIDs" value="${values.get('itemIDs') if values else ''}" id="itemIDs"/>
<input type="hidden" id="warehouseID" name="warehouseID" value="${warehouse.id if warehouse else ''}" />
<table width="1000" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td width="15">&nbsp;</td>
        <td>&nbsp;</td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td width="850" align="left" valign="top">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>

                                <td>
                                    <img src="/images/search_10.jpg" width="600" height="2" />
                                </td>
                            </tr>
                        </table>
                        </td>
                    </tr>
                    <tr>
                        <td width="850" valign="top" align="left">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="120">&nbsp;</td>
                            </tr>
                            <tr>
                                <td height="26" align="left">
                                    <img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Warehouse&nbsp;:
                                </td>
                                <td>
                                    % if warehouse:
                                    ${warehouse.name}
                                    % else:
                                    <select name="tmp-warehouseID" id="tmp-warehouseID">
                                        <option value="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</option>
                                        % for w in warehouses:
                                        <option value="${w.id}">${w.name}</option>
                                        % endfor
                                    </select>
                                    % endif
                            </tr> 
                            <tr>
                                <td height="26" align="left">
                                    <img src="/images/search_07.jpg" width="7" height="7" />&nbsp;Received Date&nbsp;:
                                </td>
                                <td>
                                    <input id="receivedDate" type="text" name="receivedDate" class="datePicker required dpDate" value="${receivedDate}" />
                                </td>
                            </tr>  
                            <tr>
                                <td height="26" align="left">
                                    &nbsp;&nbsp;&nbsp;Remarks&nbsp;:
                                </td>
                                <td>
                     <textarea id="remark"  name="remark" cols="45" rows="4" class="textarea-style">${values.get('remark', '')}</textarea>
                                </td>
                            </tr>            
                        </table>
                        </td>
                    </tr>
                </table>
                </td>
                <td>&nbsp;</td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
    </tr>
</table>

<div style="clear:both">
    &nbsp;&nbsp;
    <a href="javascript:toAdd()">
        <img src="/images/new_item.jpg">
    </a>
</div>
%if result:
<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:800px; margin-left:2px;">
    <thead>
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="11"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
            <th width="100">Line No.</th>
            <th width="200">Bag Item No#</th>
            <th width="120">*Quantity(PCS)</th>
            <th width="120">*Internal PO#</th>
        </tr>
    </thead>
    <tbody>
            %for index, i in enumerate(tmpl_context.paginators.result.items):
        %if index%2==0:
            <tr class="odd" height="26">
            %else:
            <tr class="even" height="26">
        %endif
            <td>${index+1}</td>
            <td>${i.item_number}&nbsp;</td>
            <td>
        <input type="text" id="qty-${i.id}" name="qty-${i.id}" min="1" class="numeric required digits"/>&nbsp;</td>
            <td><input type="text" id="internalPO-${i.id}" name="internalPO-${i.id}" class="required"/>&nbsp;</td>
        </tr>
            %endfor
        <tr><td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="11"><span>${tmpl_context.paginators.result.pager()}, ${tmpl_context.paginators.result.item_count} records</span></td></tr>
    </tbody>
</table>
%endif
</form>
