# -*- coding: utf-8 -*-
from sqlalchemy import *

from tg import request
from repoze.what.predicates import not_anonymous, in_group, has_permission

from gapproject.model import *
from gapproject.widgets.components import *
from gapproject.util.gap_const import *

__all__ = ['receiveSearchForm', 'orderSearchFormInstance', 'stockAdjustmentSearchForm', 'uploadSiSearchForm']


getOptions = lambda obj, first=[("", "")], order_by="name": lambda: first + [(str(o.id), str(o)) for o in DBSession.query(obj).filter(obj.active == 0).order_by(getattr(obj, order_by))]


#===============================================================================
# widget for gap project
#===============================================================================
class ReceiveSearchForm(RPACForm):

    categories = DBSession.query(Category).filter(Category.active == 0).order_by(Category.name).all()

    fields = [
        RPACSelect("warehouseID", label_text="Warehouse", options=getOptions(Warehouse)),
        RPACAjaxText("item_number", label_text="Bag Item No", attrs={'fieldName': 'item_no'}),
        # RPACAjaxText("internalPO", label_text="Internal PO#", attrs={'fieldName': 'internalPO'}),
        RPACText("no", label_text="Receive No.", attrs={'fieldName': 'no'}),
        ]
receiveSearchForm = ReceiveSearchForm()


class OrderSearchForm(RPACForm):
    statusOptions = [('', ''), (str(NEW), 'New'), (str(SHIPPED_PART), 'Shipped Part'),
        (str(SHIPPED_COMPLETE), 'Shipped Complete'), (str(CANCEL), 'Cancel')
    ]

    fields = [RPACSearchText("orderNO", label_text="r-pac Confirmation No#", attrs={'fieldName': 'orderNO'}),
              RPACSearchText("vendorPO", label_text="Vendor PO#", attrs={'fieldName': 'vendorPO'}),
              RPACCalendarPicker("orderDate", label_text="Issued Date"),
              RPACAjaxText("item_no", label_text="Bag Item No", attrs={'fieldName': 'item_no'}),
              RPACSelect("status", label_text="Status", options=statusOptions),
              ]

orderSearchFormInstance = OrderSearchForm()


class StockAdjustmentSearchForm(RPACForm):

    categories = DBSession.query(Category).filter(Category.active == 0).order_by(Category.name).all()

    fields = [
        RPACSelect("warehouseID", label_text="Warehouse", options=getOptions(Warehouse)),
        RPACAjaxText("item_number", label_text="Bag Item No", attrs={'fieldName': 'item_no'}),
        # RPACAjaxText("internalPO", label_text="Internal PO#", attrs={'fieldName': 'internalPO'}),
        ]
stockAdjustmentSearchForm = StockAdjustmentSearchForm()


class UploadSiSearchForm(RPACForm):
    fields = [
        RPACCalendarPicker("createStartDate", label_text="Date From"),
        RPACCalendarPicker("createEndDate", label_text="Date to"),
        ]

uploadSiSearchForm = UploadSiSearchForm()
