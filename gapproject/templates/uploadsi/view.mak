<%inherit file="gapproject.templates.master"/>

<%
    from gapproject.util.mako_filter import b, na
    from repoze.what.predicates import in_group
    from gapproject.util.common import Date2Text
%>

<%def name="extTitle()">GAP Upload SI</%def>

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

</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="64" valign="top" align="left">
        <a href="/uploadsi/index"><img src="/images/images/menu_back_g.jpg"/></a>
    </td>
    <td width="64" valign="top" align="left">
        <a href="/uploadsi/new"><img src="/images/images/menu_new_g.jpg"/></a>
    </td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Upload SI&nbsp;&nbsp;&gt;&nbsp;&nbsp;View</div>

<table width="1000" border="0" cellspacing="0" cellpadding="0">
    
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
                                    SI File Name:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${header.filename}
                                </td>
                            </tr> 
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Download:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    <a target="_blank" href="${header.filepath}">${header.filename}</a>
                                </td>
                            </tr>  
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Created Date:
                                </td>
                                <td>&nbsp;</td>
                                <td class="padding6px">
                                    ${Date2Text(header.createTime, '%Y-%m-%d')}
                                </td>
                            </tr>  
                            <tr>
                                <td height="26" align="right" class="title2">
                                    Created By:
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

</table>

<div style="clear:both">
    &nbsp;&nbsp;
</div>


<div style="clear:both"></div>

<div class="nav-tree"><img src="/images/error.gif">
    <span style="color:red; font-weight: bold; font-size: 14px;">Fail Items&nbsp;(${len(fdetails)} records):</span>
</div>

<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1000px; margin-left:2px;">
    <thead>
            <th width="220">r-pac Confirmation No.</th>
            <th width="200">Item Code</th>
            <th width="120">Internal ref. order number</th>
            <th width="80">Ship Qty</th>
            <th width="120">Invoice No.</th>
            <th width="80">Delivery Date</th>
            <th width="80">Invoice Issue Date</th>
        </tr>
    </thead>
    %if fdetails:
    <tbody>
            %for index, d in enumerate(fdetails):
        %if index%2==0:
            <tr class="odd" height="36">
            %else:
            <tr class="even" height="36">
        %endif
            <td>${d.orderNO}</td>
            <td>${d.itemNumber}&nbsp;</td>
            <td>${d.internalPO}&nbsp;</td>
            <td>${d.shipQty}&nbsp;</td>
            <td>${d.invoiceNumber}&nbsp;</td>
            <td>${d.deliveryDate}&nbsp;</td>
            <td>${d.invoiceDate}&nbsp;</td>
        </tr>
            %endfor 
    </tbody>
    %endif
</table>


<br />
<img src="/images/search_10.jpg" width="1000" height="2" />
<br />
<br />

<div class="nav-tree"><span style="color:green; font-weight: bold; font-size: 14px;">Success Items&nbsp;(${len(sdetails)} records):</span></div>
<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1000px; margin-left:2px;">
    <thead>
            <th width="220">r-pac Confirmation No.</th>
            <th width="200">Item Code</th>
            <th width="120">Internal ref. order number</th>
            <th width="80">Ship Qty</th>
            <th width="120">Invoice No.</th>
            <th width="80">Delivery Date</th>
            <th width="80">Invoice Issue Date</th>
        </tr>
    </thead>
    %if sdetails:
    <tbody>
            %for index, d in enumerate(sdetails):
        %if index%2==0:
            <tr class="odd" height="36">
            %else:
            <tr class="even" height="36">
        %endif
            <td>${d.orderNO}</td>
            <td>${d.itemNumber}&nbsp;</td>
            <td>${d.internalPO}&nbsp;</td>
            <td>${d.shipQty}&nbsp;</td>
            <td>${d.invoiceNumber}&nbsp;</td>
            <td>${d.deliveryDate}&nbsp;</td>
            <td>${d.invoiceDate}&nbsp;</td>
        </tr>
            %endfor 
    </tbody>
    %endif
</table>

