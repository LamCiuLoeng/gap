# -*- coding: utf-8 -*-
from sqlalchemy import *

from gapproject.model import *
from gapproject.widgets.components import *

__all__ = ['ciReportSearchForm', 'voReportSearchForm', 'irReportSearchForm']


getOptions = lambda obj, first=[("", "")], order_by="name": lambda: first + [(str(o.id), str(o)) for o in DBSession.query(obj).filter(obj.active == 0).order_by(getattr(obj, order_by))]


#===============================================================================
# widget for gap project
#===============================================================================

class CiReportSearchForm(RPACForm):

    fields = [
        # RPACSelect("categoryID", label_text="Brand", options=getOptions(Category)),
        # RPACText("item_number", label_text="Bag Item No"),
        RPACSelect("warehouseID", label_text="Warehouse", options=getOptions(Warehouse)),
        RPACAjaxText("item_number", label_text="Bag Item No", attrs={'fieldName': 'item_no'}),
        # RPACCalendarPicker("createStartDate", label_text="Date From"),
        # RPACCalendarPicker("createEndDate", label_text="Date to"),
        ]

ciReportSearchForm = CiReportSearchForm()


class VoReportSearchForm(RPACForm):
    vendorOptions = [("", "")] + [(str(v.user_id), v.display_name) for v in DBSession.query(User).filter(and_(
        User.active == 0, User.user_name != None, User.display_name != None, User.billing_name != None,
        User.password != None)).order_by(User.display_name)]

    fields = [
        # RPACText("item_number", label_text="Bag Item No"),
        RPACSelect("warehouseID", label_text="Warehouse", options=getOptions(Warehouse)),
        RPACSelect("categoryID", label_text="Brand", options=getOptions(Category)),
        # RPACAjaxText("item_number", label_text="Bag Item No", attrs={'fieldName': 'item_no'}),
        RPACCalendarPicker("createStartDate", label_text="Order Date From"),
        RPACCalendarPicker("createEndDate", label_text="Order Date To"),
        RPACCalendarPicker("invoiceStartDate", label_text="Invoice Date From"),
        RPACCalendarPicker("invoiceEndDate", label_text="Invoice Date To"),
        RPACSelect("userID", label_text="Vendor", options=vendorOptions),

        ]

voReportSearchForm = VoReportSearchForm()


class IrReportSearchForm(RPACForm):

    fields = [
        RPACSelect("warehouseID", label_text="Warehouse", options=getOptions(Warehouse)),
        RPACAjaxText("item_number", label_text="Bag Item No", attrs={'fieldName': 'item_no'}),
    ]

irReportSearchForm = IrReportSearchForm()
