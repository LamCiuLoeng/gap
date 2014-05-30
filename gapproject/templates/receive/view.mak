<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.mako_filter import b, na
    from repoze.what.predicates import in_group
    from gapproject.util.common import Date2Text
    from datetime import timedelta, datetime as dt
%>

<%def name="extTitle()">GAP Receive Item</%def>

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
};

var toCancel = function() {
    $.prompt("Are you sure to cancel ?",
        {opacity: 0.6,
            prefix:'cleanblue',
            buttons:{'Yes':true,'No,Go Back':false},
            focus : 1,
            callback : function(v,m,f){
                if(v){
                    $('#cancel-form').submit();
                }
            }
        }
    );
};
</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="64" valign="top" align="left">
        <a href="/receive/index"><img src="/images/images/menu_back_g.jpg"/></a>
    </td>
    % if dt.now() < header.createTime + timedelta(minutes=20) or in_group('Admin'):
    <td width="64" valign="top" align="left">
        <a href="javascript:toCancel();"><img src="/images/images/menu_cancel_g.jpg"></a>
    </td>
    % endif
    <td width="64" valign="top" align="left">
        <a href="/receive/new"><img src="/images/images/menu_new_g.jpg"/></a>
    </td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Receive Item&nbsp;&nbsp;&gt;&nbsp;&nbsp;View</div>

<form id="cancel-form" method="post" action="/receive/tocancel"> 
    <input type="hidden" name='headerID' value="${header.id}" />
</form>

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
                                    Receive No:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.no}
                                </td>
                            </tr> 
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Warehouse:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.warehouse.name}
                                </td>
                            </tr> 
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Remarks:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.remark}
                                </td>
                            </tr>  
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Received Date:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${Date2Text(header.createTime)}
                                </td>
                            </tr>  
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Received By:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.issuedBy}
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
            <th width="120">Internal PO#</th>
            <th width="120">Received Qty</th>
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
            <td>${d.internalPO}&nbsp;</td>
            <td>${d.qty}&nbsp;</td>
            <td>PCS&nbsp;</td>
        </tr>
            %endfor 
    </tbody>
</table>
%endif
