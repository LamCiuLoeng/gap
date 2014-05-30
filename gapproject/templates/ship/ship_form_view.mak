<%inherit file="gapproject.templates.master"/>

<%
	from gapproject.util.mako_filter import b, na
	from gapproject.util.common import rpacEncrypt, Date2Text
	from repoze.what.predicates import in_group
	from gapproject.util.gap_const import orderStatus, SHIPPED_COMPLETE, CANCEL, RESERVED_FAIL
%>

<%def name="extTitle()">r-pac - GAP - Ship Item</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<!-- <link rel="stylesheet" href="/javascript/smartspin/smartspinner.css" type="text/css" /> -->
<link rel="stylesheet" href="/javascript/jquery.nyroModal/styles/nyroModal.css" type="text/css" media="screen" />
<link rel="stylesheet" href="http://code.jquery.com/ui/1.8.6/themes/start/jquery-ui.css" type="text/css" /> 
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/numeric.js" language="javascript"></script>
<!-- <script type="text/javascript" src="/javascript/smartspin/smartspinner.js" language="javascript"></script> -->
<script type="text/javascript" src="/javascript/jquery.nyroModal/js/jquery.nyroModal.custom.min.js"></script>
<!--[if (gte IE 5)&(lt IE 9)]>
    <script type="text/javascript" src="/javascript/jquery.nyroModal/js/jquery.nyroModal-ie6.min.js"></script>
<![endif]-->
<script type="text/javascript" src="/javascript/jquery.validate.min.js"></script>

<script type="text/javascript" src="/javascript/jquery-ui-1.8.6.min.js"></script> 
<script type="text/javascript" src="/javascript/jquery.ui.datepicker.validation.min.js"></script>

<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	$(function(){
        var width = 830;
        var height = 600;
        $('.nyroModal').nyroModal({
          sizes: {
            initW: width, initH: height,
            minW: width, minH: height,
            w: width, h: height
          },
          closeOnClick: false,
          callbacks: {
            beforeShowCont: function() { 
                width = $('.nyroModalCont').width();
                height = $('.nyroModalCont').height();
                $('.nyroModalCont iframe').css('width', width);
                $('.nyroModalCont iframe').css('height', height);
            },
            afterClose: function() {
                parent.window.location.reload();
            }
          }
        });


        // $('#ship-form').validate();

	// 	$("input[name^='qty-']").each(function(){
	// 		var t = $(this);
	// 		var m = parseInt(t.attr('max'))
	// 		t.spinit({min:0, max: m, 
	// 			initValue: m,
	// 			stepInc:1, pageInc:30, 
	// 			height: 30, width: 100});
	// 	});

        $('#select-all').click(function(){
            $("input[name^='detail-']").attr("checked", 'true');
        });
	});

	var toShip = function(){
		var ids = [];
        $("input[name^='detail-']:checked").each(function(){
            ids.push($(this).val());
        });
        if(ids.length > 0){
            $("input[name='shipIDs']").val(ids.join('|'));
            $("#ship-form").submit();
        }else{
            showError('Please select one item at least!');
        }
	};

	var toReserve = function(){
        var ids = [];
		$("input[name^='detail-']:checked").each(function(){
            ids.push($(this).val());
        });
        if(ids.length > 0){
            $("input[name='reserveIDs']").val(ids.join('|'));
            $("#re-form").submit();
        }else{
            showError('Please select one item at least!');
        }
    };

    var toRelease = function(){
        var ids = [];
        $("input[name^='detail-']:checked").each(function(){
            ids.push($(this).val());
        });
        if(ids.length > 0){
            $("input[name='reserveIDs']").val(ids.join('|'));
            $("#rel-form").submit();
        }else{
            showError('Please select one item at least!');
        }
    };

    var toCancel = function(sno){
        if (confirm('Are you sure to cancel <' +  sno + '>?' )) {
            $('#calcel-form-' + sno).submit();
        }
    }

	//]]>
</script>
</%def>
<div id="function-menu">
	<table width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
			<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
			<td width="64" valign="top" align="left">
				<a href="/ship/index"><img src="/images/images/menu_back_g.jpg"/></a>
			</td>
            
            % if order_header.status != CANCEL and order_header.status != SHIPPED_COMPLETE:
            <%doc>
			<td width="64" valign="top" align="left">
				<a href="javascript:toReserve()">
					<img src="/images/images/menu_reserve_g.jpg"/>
				</a>
			</td>
            <td width="64" valign="top" align="left">
                <a href="javascript:toRelease()">
                    <img src="/images/images/menu_release_g.jpg"/>
                </a>
            </td>
            </%doc>
			<td width="64" valign="top" align="left">
				<a href="javascript:toShip()"><img src="/images/images/menu_ship_g.jpg"/></a>
			</td>
           % endif
            <td width="64" valign="top" align="left">
                <a href="/receive/new" target="_blank"><img src="/images/images/menu_receive_item_g.jpg"/></a>
            </td>
			<td width="23" valign="top" align="left">
				<img height="21" width="23" src="/images/images/menu_last.jpg"/>
			</td>
			<td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
		</tr>
		</tbody>
	</table>
</div>

<div class="nav-tree">GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Ship Item&nbsp;&nbsp;&gt;&nbsp;&nbsp;Ship Form</div>
<form id="re-form" method="post" action="/ship/reserve" class="nyroModal">
    <input type="hidden" name="orderID" value="${order_header.id}" />
    <input type="hidden" name="warehouseID" value="${order_header.region.region_warehouse[0].id}" />
    <input type="hidden" name="reserveIDs" value="" />
</form>
<form id="rel-form" method="post" action="/ship/release" class="nyroModal">
    <input type="hidden" name="orderID" value="${order_header.id}" />
    <input type="hidden" name="warehouseID" value="${order_header.region.region_warehouse[0].id}" />
    <input type="hidden" name="reserveIDs" value="" />
</form>
<form id="ship-form" method="post" action="/ship/toShip" class="nyroModal">
    <input type="hidden" name="orderID" value="${order_header.id}" />
    <input type="hidden" name="warehouseID" value="${order_header.region.region_warehouse[0].id}" />
    <input type="hidden" name="shipIDs" value="" />
</form>

% if shipItems:
<img src="/images/search_10.jpg" width="600" height="2" />
<div class="nav-tree">Shipped:</div>

<div style="clear:both"><br /></div>
<table cellspacing="0" cellpadding="0" border="0" width="1200" class="gridTable">
	<thead>
	<tr>
        <td height="20" align="center" width="200" class="wt-td">Ship No.</td>
		<td align="center" width="200" class="wt-td">Shipped Date</td>
		<td align="center" width="200" class="wt-td">Warehouse</td>
		<td align="center" width="200" class="wt-td">Invoice Number</td>
		<!--<td align="center" width="200" class="wt-td">Invoice(USD)</td> -->
        <!-- <td align="center" width="200" class="wt-td">Other Invoice(USD)</td> -->
        <td align="center" width="200" class="wt-td">Shipped By</td>
        <td align="center" width="200" class="wt-td">Remark</td>
        <td align="center" width="200" class="wt-td">SI File</td>
        <td align="center" width="200" class="wt-td">Action</td>
	</tr>
	</thead>
	<tbody>
	%for index, s in enumerate(shipItems):
	%if index%2==0:
	<tr class="even">
	%else:
	<tr class="odd">
	%endif
		<td height="20" class="t-td"><a href="/ship/viewDetail?shid=${s.id}" class="nyroModal" target="_blank">${s.no}</a></td>
		<td align="center" class="t-td">${Date2Text(s.createTime)}</td> 
		<td align="center" class="t-td">${s.warehouse}</td> 
 		<td align="center" class="t-td">${s.invoiceNumber|b}</td>
 		<!--<td align="center" class="t-td">${s.invoice|b}</td> --> 
        <!-- <td align="center" class="t-td">${s.otherInvoice|b}</td>  -->
        <td align="center" class="t-td">${s.issuedBy}</td> 
 		<td align="center" class="t-td">${s.remark|b}</td> 
        <td align="center" class="t-td">
            % if s.filename and s.filepath:
            <a target="_blank" href="${s.filepath}">${s.filename}</a>
            % else:
            &nbsp;
            % endif
        </td> 
        <td align="center" class="t-td">
            <form id="calcel-form-${s.no}" method="post" action="/ship/cancelShip">
                <input type="hidden" name="shid" value="${s.id}" /> 
            </form>
            <a href="#" onclick="toCancel('${s.no}')">
                <img src="/images/images/menu_cancel_g.jpg">
            </a>
        </td> 
	</tr>
	%endfor
	</tbody>
</table>
<div style="clear:both"><br /><br /></div>
% endif
<img src="/images/search_10.jpg" width="600" height="2" />
<table width="1000" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td width="850" align="left" valign="top">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="850" valign="top" align="left">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="180">&nbsp;</td>
                            </tr>
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;r-pac Confirmation No&nbsp;:
                                </td>
                                <td>
                                    ${order_header.orderNO}
                                </td>
                            </tr>
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;status&nbsp;:
                                </td>
                                <td>
                                    ${orderStatus.get(order_header.status, '')}
                                </td>
                            </tr>
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Region&nbsp;:
                                </td>
                                <td>
                                    ${order_header.region}
                                </td>
                            </tr>
                            <tr>
                                <td height="26" align="left" class="title2">
                                    &nbsp;&nbsp;Warehouse&nbsp;:
                                </td>
                                <td>
                                    ${order_header.region.region_warehouse[0]}
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

% if order_details:
<div style="clear:both"><br /></div>
<table cellspacing="0" cellpadding="0" border="0" width="1000" class="gridTable">
	<thead>
	<tr>
        <td height="35" align="center" width="100" class="wt-td">
            Select?&nbsp;<button type="button" id="select-all">&nbsp;All&nbsp;</button>
        </td>
        <td height="35" align="center" width="200" class="wt-td">Bag Item No#</td>
		<td align="center" width="200" class="wt-td">Order Qty</td>
        <!-- <td align="center" width="200" class="wt-td">Qty Reserved</td> -->
		<td align="center" width="200" class="wt-td">Qty Shipped</td>
	</tr>
	</thead>
	<tbody>
	<%
		order_details.sort(key = lambda x: x.id)
	%>
	%for index, detail in enumerate(order_details):
	%if index%2==0:
	<tr class="even">
	%else:
	<tr class="odd">
	%endif
        <td height="25" class="t-td">
            % if not detail.is_shipped_complete:
            <input type="checkbox" name="detail-${detail.id}" value="${detail.id}" />
            % else:
            &nbsp;
            % endif
        </td>
		<td height="25" class="t-td">${detail.item|b}</td>
		<td align="center" class="t-td">${detail.qty|b}</td> 
       <%doc> <td align="center" class="t-td">${detail.qtyReserved}</td> </%doc>
		<td align="center" class="t-td">${detail.qtyShipped}</td>  
	</tr>
	%endfor
	</tbody>
</table>
% endif