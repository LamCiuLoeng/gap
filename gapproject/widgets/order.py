# -*- coding: utf-8 -*-

from gapproject.model import *
from gapproject.widgets.components import *

__all__ = ['regionSearchFormInstance',
           'orderSearchFormInstance'
           ]


getOptions = lambda obj,order_by="name": [(str(o.id), o) for o in DBSession.query(obj).filter(obj.active==0).order_by(getattr(obj, order_by))]

class RegionSearchForm(RPACSubmitForm):
    fields = [RPACSelect("regionID", label_text="Region", options=getOptions(Region)),
              ]

regionSearchFormInstance = RegionSearchForm()

class OrderSearchForm(RPACForm):
    fields = [RPACSearchText("orderNO", label_text = "r-pac Confirmation#", attrs = {'fieldName' : 'orderNO'}),
              RPACSearchText("vendorPO", label_text = "Vendor PO#", attrs = {'fieldName' : 'vendorPO'}),
              RPACCalendarPicker("orderDate", label_text = "Issued Date"),
              RPACAjaxText("item_no", label_text = "Bag ItemNo", attrs = {'fieldName' : 'item_no'}),
              ]

orderSearchFormInstance = OrderSearchForm()





