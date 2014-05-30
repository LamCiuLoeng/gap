<%inherit file="gapproject.templates.master"/>

<%
    from repoze.what.predicates import  in_group

%>

<%def name="extTitle()">r-pac - Inventory For GAP</%def>
<%def name="extCSS()">
<link rel="stylesheet" href="/css/jquery.autocomplete.css" type="text/css" />
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
</%def>
<%def name="extJavaScript()">
<script type="text/javascript" src="/javascript/numeric.js"></script>
<script type="text/javascript" src="/javascript/jquery.autocomplete.pack.js" language="javascript"></script>
<script type="text/javascript" src="/javascript/custom/gap_ac.js"></script>
<script language="JavaScript" type="text/javascript">

    function toSearch(){

        if($("#item_number").val()==''){
             $.prompt("Please input 'Bag Item No'!", {opacity: 0.6,prefix:'cleanred'});
        }else{
            $("form")[0].submit();
        }
    }
   
</script>
</%def>
<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
            <tr>
            <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>

            <td width="64" valign="top" align="left"><a href="/"><img src="/images/images/menu_gap_g.jpg"/></a></td>

            <td width="64" valign="top" align="left"><a href="javascript:toSearch()"><img src="/images/images/menu_search_g.jpg"/></a></td>

            <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
            <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
            </tr>
        </tbody></table>
</div>

<div class="nav-tree">Inventory For GAP&nbsp;&nbsp;&gt;&nbsp;&nbsp;Search</div>


<div>
	${search_form(values,action=("/enquiry/byweek"))|n}
</div>

<div style="clear:both"><br /></div>



%if result:

<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1200px;">
    <thead>
        <tr>
        <td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="20">
            <a class="pager_link" href="/enquiry/byweek/?item_number=${values.get('item_number')}&w=${prev_week}">Prev Week</a>
            <span class="pager_dotdot">......</span>
            <a class="pager_link" href="/enquiry/byweek/?item_number=${values.get('item_number')}&w=${this_week}">Current Week</a>
            <span class="pager_dotdot">......</span>
            <a class="pager_link" href="/enquiry/byweek/?item_number=${values.get('item_number')}&w=${next_week}">Next Week</a>
        </td>
    </tr>
        <tr>
            % for h in header:
                <th colspan="2">
                    ${h[0]}
                    <div><span style="color:${h[2]};">${h[1]}</span></div>
                </th>
            % endfor 
            <th colspan="2">Total This Week</th>
            <th colspan="2">Current<div>${now['date']}</div></th>
        </tr>
        <tr>
        % for i in range(len(header)+1):
        <th>Qty Received</th><!-- <th>Reserved Qty</th> --><th>Qty Shipped</th>
        % endfor
        <th colspan="2">Available Qty</th>
        </tr> 

    </thead>
    <tbody>
			
        <tr height="30">
            %for i, u in enumerate(result):
            <td>
                % if u[0]:
                <a target="_blank" href="/enquiry/receivedDetail?c=${values.get('itemID')}&t=received&s=${header[i][1]}&e=${header[i][1]}">${u[0]}&nbsp;</a>
                % else:
                ${u[0]}&nbsp;
                % endif
            </td>
            <%doc>
            <td>
                % if u[1]:
                <a target="_blank" href="/enquiry/reservedDetail?c=${values.get('itemID')}&t=shipped&s=${header[i][1]}&e=${header[i][1]}">${u[1]}&nbsp;</a>
                % else:
                ${u[1]}&nbsp;
                % endif
            </td>
            </%doc>
            <td>
                % if u[1]:
    <a target="_blank" href="/enquiry/shippedDetail?c=${values.get('itemID')}&t=shipped&s=${header[i][1]}&e=${header[i][1]}">${u[1]}&nbsp;</a>
                % else:
                ${u[1]}&nbsp;
                % endif
            </td>
            %endfor
            <td>${qty_received}</td>
            <%doc><td>${qty_reserved}</td></%doc>
            <td>${qty_shipped}</td>
            <td colspan="2">
                % if now['qty']:
                <a target="_blank" href="/enquiry/idetail?c=${values.get('itemID')}">${now['qty']}</a>
                % else:
                ${now['qty']}
                % endif
            </td>
        </tr>
    </tbody>
</table>

%endif
