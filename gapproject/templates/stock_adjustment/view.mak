<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.mako_filter import b, na
    from repoze.what.predicates import in_group
    from gapproject.util.common import Date2Text
%>

<%def name="extTitle()">GAP - Stock Adjustment</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/jquery.autocomplete.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<link rel="stylesheet" href="/css/thickbox.css" type="text/css" />
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
<script type="text/javascript" src="/javascript/jquery-impromptu.3.1.min.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.validate.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/thickbox-compressed.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript">

var toApprove = function(){
    var form = $('#ad-Form');
    $.prompt("Are you sure to confirm these now?",
        {opacity: 0.6,
            prefix:'cleanblue',
            buttons:{'Yes':true,'No,Go Back':false},
            focus : 1,
            callback : function(v,m,f){
                if(v){
                    form.submit();
                }
            }
        }
    );
}
</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="64" valign="top" align="left">
        <a href="javascript:history.back()"><img src="/images/images/menu_back_g.jpg"/></a>
    </td>
    <td width="64" valign="top" align="left"><a href="/stockAdjustment/new_form"><img src="/images/images/menu_new_g.jpg"/></a></td>
    % if header.status != 'Approved'.upper():
    <td width="64" valign="top" align="left">
        <a class="confirm" href="javascript:void(0)" onclick="toApprove()"><img src="/images/images/menu_approve_g.jpg"/></a>
    </td>
    % endif
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Stock Adjustment&nbsp;&nbsp;&gt;&nbsp;&nbsp;View</div>

<form id="ad-Form" action="/stockAdjustment/approve" method="post">
<input type="hidden" name="sadid" value="${header.id}"/>

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
                                <td width="180">&nbsp;</td>
                            </tr>
                             <tr>
                                <td height="26" align="right" class="title2">
                                    *Stock Adjustment No:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.no}
                                </td>
                            </tr> 
                            <tr>
                                <td height="26" align="right" class="title2">
                                    *Warehouse:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.warehouse.name}
                                </td>
                            </tr> 
                            <tr>
                                <td height="26" align="right" class="title2">
                                    *Adjustment Reason:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.remark}
                                </td>
                            </tr>
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Status:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.status}
                                </td>
                            </tr>   
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Adjustment Date:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${Date2Text(header.createTime, '%Y-%m-%d')}
                                </td>
                            </tr>  
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Adjustment By:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.issuedBy}
                                </td>
                            </tr>
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Approved Date:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${Date2Text(header.approvedDate, '%Y-%m-%d %H:%M:%S') if header.approvedDate else ''}
                                </td>
                            </tr>   
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Approved By:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.approvedBy or ''}
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
</div>

%if details:
<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1000px; margin-left:2px;">
    <thead>
            <th width="100">Line No.</th>
            <th width="200">Bag Item No#</th>
            <th width="120">Warehouse</th>
            <th width="120">On Hand Qty</th>
            <!-- <th width="120">Reserved Qty</th> -->
            <th width="120">Available Qty</th>
            <th width="120">*Type</th>
            <th width="140">*Adjustment Qty</th>
            <th width="80">Base Unit</th>
        </tr>
    </thead>
    <tbody>
            %for index, d in enumerate(details):
        %if index%2==0:
            <tr class="odd" height="36">
            %else:
            <tr class="even" height="36">
        %endif
            <td>${index+1}</td>
            <td>${d.item.item_number}&nbsp;</td>
            <td>${d.warehouse.name}&nbsp;</td>
            <td>${d.onHandQty}&nbsp;</td>
            <td>${d.availableQty}&nbsp;</td>
            <td>${d.type}</td>
            <td>${d.qty}</td>
            <td>PCS&nbsp;</td>
        </tr>
            %endfor 
    </tbody>
</table>
%endif

</form>
