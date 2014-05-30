# -*- coding: utf-8 -*-
from sqlalchemy import *

from tg import request
from repoze.what.predicates import not_anonymous, in_group, has_permission

from gapproject.model import *
from gapproject.widgets.components import *

__all__ = ['inventorySearchForm', 'inventoryHistorySearchForm', 'inventoryReportSearchForm', 'enquiryByWarehouseForm',
            'enquiryByItemForm', 'enquiryByWeekForm']


getOptions = lambda obj, first=[("", "")], order_by="name": lambda: first + [(str(o.id), str(o)) for o in DBSession.query(obj).filter(obj.active == 0).order_by(getattr(obj, order_by))]


#===============================================================================
# widget for gap project
#===============================================================================

#--------------------- for master item code
class InventorySearchForm(RPACForm):
    itemOptions = [('', [('', '')])]
    categories = DBSession.query(Category).filter(Category.active == 0).order_by(Category.name).all()
    for c in categories:
        items = []
        for item in c.category_items:
            items.append((str(item.id), item.item_number))
        itemOptions.append((c.name, items))
    fields = [
        RPACSelect("warehouseID", label_text="Warehouse", options=getOptions(Warehouse)),
        # RPACSelect("itemID", label_text="Bag Item Code", options=itemOptions),
        RPACAjaxText("item_number", label_text="Bag Item No", attrs={'fieldName': 'item_no'}),
        RPACAjaxText("orderNO", label_text="r-pac Confirmation PO#", attrs={'fieldName': 'orderNO'}),
        RPACAjaxText("vendorPO", label_text="Vendor PO#", attrs={'fieldName': 'vendorPO'}),
        ]
inventorySearchForm = InventorySearchForm()


class InventoryHistorySearchForm(RPACForm):
    typeOptions = [("", ""), ("received", "received"), ("shipped", "shipped")]
    fields = [
        RPACSelect("warehouseID", label_text="Warehouse", options=getOptions(Warehouse, first=[])),
        RPACAjaxText("item_number", label_text="Bag Item No", attrs={'fieldName': 'item_no'}),
        RPACCalendarPicker("createStartDate", label_text="CreatedTime(from)"),
        RPACCalendarPicker("createEndDate", label_text="CreatedTime(to)"),
        RPACSelect("type", label_text="Action Type", options=typeOptions),
        ]
inventoryHistorySearchForm = InventoryHistorySearchForm()


class InventoryReportSearchForm(RPACForm):
    # typeOptions = [("", ""), ("received", "Received"), ("shipped", "Shipped")]
    # vendorOptions = [("", "")] + [(str(v.user_id), v.display_name) for v in DBSession.query(User).filter(and_(
        # User.active == 0, User.user_name != None, User.display_name != None, User.billing_name != None,
        # User.password != None)).order_by(User.user_id)]
    fields = [
        # RPACSelect("categoryID", label_text="Brand", options=getOptions(Category)),
        # RPACText("item_number", label_text="Bag Item No"),
        RPACSelect("warehouseID", label_text="Warehouse", options=getOptions(Warehouse)),
        RPACAjaxText("item_number", label_text="Bag Item No", attrs={'fieldName': 'item_no'}),
        # RPACSelect("user_id", label_text="Vendor", options=vendorOptions),
        # RPACCalendarPicker("shippedStartDate", label_text="Date shipped(from)"),
        # RPACCalendarPicker("shippedEndDate", label_text="Date shipped(to)"),
        RPACCalendarPicker("createStartDate", label_text="(Received/Order)Date From"),
        RPACCalendarPicker("createEndDate", label_text="(Received/Order)Date to"),
        ]
    #if not in_group("Buyer"):
        #fields.append(RPACSelect("type", label_text="Action Type", options=typeOptions))

inventoryReportSearchForm = InventoryReportSearchForm()


# for Enquiry By Warehouse
class EnquiryByWarehouseForm(RPACForm):

    fields = [
        RPACSelect("warehouseID", label_text="Warehouse", options=getOptions(Warehouse, first=[])),
        RPACSelect("categoryID", label_text="Brand", options=getOptions(Category)),
        RPACAjaxText("item_number", label_text="Bag Item No.", attrs={'fieldName': 'item_no'}),
        ]
enquiryByWarehouseForm = EnquiryByWarehouseForm()


# for Enquiry By Item
class EnquiryByItemForm(RPACForm):

    fields = [
        RPACText("item_number", label_text="Bag Item No"),
        RPACSelect("categoryID", label_text="Brand", options=getOptions(Category)),
        ]
enquiryByItemForm = EnquiryByItemForm()


"""
options = [
            ("Apples", ["apple1","apple2"]),
            ("Oranges", ["orange1","orange2"]),
        ]"""


# for Enquiry By week
class EnquiryByWeekForm(RPACForm):
    itemOptions = [('', [('', '')])]
    categories = DBSession.query(Category).filter(Category.active == 0).order_by(Category.name).all()
    for c in categories:
        items = []
        for item in c.category_items:
            items.append((str(item.id), item.item_number))
        itemOptions.append((c.name, items))
    fields = [
        # RPACSelect("itemID", label_text="Bag Item No", options=itemOptions),
        RPACAjaxText("item_number", label_text="Bag Item No", attrs={'fieldName': 'item_no'}),
        ]
enquiryByWeekForm = EnquiryByWeekForm()
