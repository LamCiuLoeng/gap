<%inherit file="gapproject.templates.master"/>
<%def name="extTitle()">r-pac - Order</%def>
<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
            <tr>
            <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>

            <td width="64" valign="top" align="left"><img src="/images/images/menu_gap_g.jpg"/></td>

            <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
            <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
            </tr>
        </tbody></table>
</div>

<div class="nav-tree">GAPProject&nbsp;&nbsp;&gt;&nbsp;&nbsp;Order</div>

<div>
	${search_form(values,action=("/order/index"), title=title)|n}
</div>

<div style="clear:both"><br /></div>

