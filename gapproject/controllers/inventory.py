# -*- coding: utf-8 -*-
# from __future__ import division
import traceback
import urllib
import os
import shutil
import random
from datetime import datetime as dt

# turbogears imports
from tg import expose
from tg import redirect, validate, flash, request, config
from tg.decorators import *

# third party imports
#from pylons.i18n import ugettext as _
from repoze.what import predicates, authorize
from repoze.what.predicates import not_anonymous, in_group, has_permission

from sqlalchemy.sql import *

# project specific imports
from gapproject.lib.base import BaseController

from gapproject.model import *

from gapproject.util.common import *
from gapproject.util.excel_helper import *
from gapproject.widgets import *
from gapproject.widgets.inventory import *

# import transaction


class InventoryController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose("gapproject.templates.inventory.report")
    @tabFocus(tab_type="report")
    def report(self, **kw):
        return {"widget": inventoryReportSearchForm}

    @expose()
    def export(self, **kw):
        try:
            current = dt.now()
            dateStr = current.strftime("%Y%m%d")
            fileDir = os.path.join(config.get("public_dir"), "report", 'inventory', dateStr)
            if not os.path.exists(fileDir):
                os.makedirs(fileDir)
            templatePath = os.path.join(config.get("public_dir"), 'TEMPLATE', "INVENTORY_TEMPLATE_AE.xlsx")
            if in_group('Buyer'):
                templatePath = os.path.join(config.get("public_dir"), 'TEMPLATE', "INVENTORY_TEMPLATE.xlsx")
            tempFileName = os.path.join(fileDir, "tmp_%s.xlsx" % current.strftime("%Y%m%d%H%M%S"))
            realFileName = os.path.join(fileDir, "report_%s.xlsx" % current.strftime("%Y%m%d%H%M%S"))
            shutil.copy(templatePath, tempFileName)
            report_xls = InventoryExcel(templatePath=tempFileName, destinationPath=realFileName)
            data = []
            if kw:
                if in_group('Buyer'):
                    data = self._query_buyer_result(kw)
                else:
                    data = self._query_ae_result(kw)
            report_xls.inputData(data=data)
            report_xls.outputData()
            try:
                os.remove(tempFileName)
            except:
                pass
            return serveFile(unicode(realFileName))
        except:
            traceback.print_exc()
            flash("Export Fail.")
            redirect("/inventory/report")

    def _query_buyer_result(self, kw):
        try:
            conditions = []
            shipConditions = []
            warehouses = Warehouse.get_all()
            e_date = dt.now()
            items = DBSession.query(Item).filter(Item.active == 0).order_by(Item.categoryID, Item.item_number).all()

            if kw.get("warehouseID", False):
                warehouse = getOr404(Warehouse, kw.get("warehouseID"))
                warehouses = [warehouse]

            if kw.get("item_number", False):
                items = DBSession.query(Item).filter(and_(Item.active == 0,
                    Item.__table__.c.item_number.op('ilike')("%%%s%%" % kw["item_number"].strip()))
                    ).order_by(Item.categoryID, Item.item_number).all()

            if kw.get("createStartDate", False) and kw.get("createEndDate", False):
                b_date = dt.strptime(kw.get("createStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                e_date = dt.strptime(kw.get("createEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
                conditions.append(OrderInfoHeader.orderDate >= b_date)
                conditions.append(OrderInfoHeader.orderDate <= e_date)
                shipConditions.append(ShipItem.createTime >= b_date)
                shipConditions.append(ShipItem.createTime <= e_date)
            elif kw.get("createStartDate", False):
                b_date = dt.strptime(kw.get("createStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                conditions.append(OrderInfoHeader.orderDate >= b_date)
                shipConditions.append(ShipItem.createTime >= b_date)
            elif kw.get("createEndDate", False):
                e_date = dt.strptime(kw.get("createEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
                conditions.append(OrderInfoHeader.orderDate <= e_date)
                shipConditions.append(ShipItem.createTime <= e_date)

            data = []
            # print warehouses
            for w in warehouses:
                for item in items:
                    orders = DBSession.query(OrderInfoHeader).join(OrderInfoDetail,
                        Item).filter(OrderInfoHeader.status > 0).filter(
                        OrderInfoDetail.itemID == item.id).filter(OrderInfoHeader.regionID == w.regionID)
                    for value in conditions:
                        orders = orders.filter(value)
                    orders = orders.order_by(OrderInfoHeader.id).all()
                    # print len(orders)
                    avaQty = item.availableQtyByWarehouse(w.id, date=e_date)
                    if orders:
                        tmp_data = []
                        details = DBSession.query(OrderInfoDetail).filter(and_(OrderInfoDetail.itemID == item.id,
                            OrderInfoDetail.headerID.in_([o.id for o in orders]))).order_by(OrderInfoDetail.id).all()
                        for index, d in enumerate(details):
                            order = d.header
                            # print order.issuedBy.display_name
                            ship_items = DBSession.query(ShipItem).filter(ShipItem.active == 0).filter(ShipItem.orderDetailID == d.id)
                            for value in shipConditions:
                                ship_items = ship_items.filter(value)
                            ship_items = ship_items.order_by(ShipItem.id).all()
                            # print ship_items
                            if ship_items:
                                for j, si in enumerate(ship_items):
                                    # print si.qty
                                    tmp = [''] * 15
                                    tmp[0] = item.category.name  # brand
                                    tmp[1] = order.orderNO
                                    tmp[2] = item.item_number  # bag item no
                                    tmp[3] = order.issuedBy.display_name  # vendor
                                    tmp[4] = si.createTime
                                    tmp[5] = getattr(order, 'orderDate')
                                    tmp[6] = getattr(d, 'qty')
                                    tmp[7] = 0 - si.qty
                                    tmp[8] = si.createTime
                                    tmp[9] = si.header.invoiceNumber
                                    tmp[10] = item.getPrice(w.regionID) * 1000
                                    tmp[11] = item.getPrice(w.regionID) * si.qty
                                    tmp[12] = w.name
                                    tmp[13] = getattr(order, 'region').name
                                    tmp[14] = ''
                                    tmp_data.append(tmp)
                            else:
                                tmp = [''] * 15
                                tmp[0] = item.category.name  # brand
                                tmp[1] = order.orderNO
                                tmp[2] = item.item_number  # bag item no
                                tmp[3] = order.issuedBy.display_name
                                tmp[4] = getattr(order, 'orderDate')
                                tmp[5] = getattr(order, 'orderDate')
                                tmp[6] = getattr(d, 'qty')
                                tmp[10] = item.getPrice(w.regionID) * 1000  # unit price
                                tmp[12] = w.name  # warehouse
                                tmp[14] = ''
                                tmp_data.append(tmp)
                        if tmp_data:
                            sorted(tmp_data, key=lambda tmp: tmp[4])
                        data = data + tmp_data
                    else:
                        tmp = [''] * 15
                        tmp[0] = item.category.name  # brand
                        tmp[2] = item.item_number  # bag item no
                        tmp[10] = item.getPrice(w.regionID) * 1000  # unit price
                        tmp[12] = w.name  # warehouse
                        tmp[14] = ''
                        # print tmp
                        data.append(tmp)
                    if data:
                        data[-1][-1] = avaQty
            return data
        except:
            traceback.print_exc()

    def _query_ae_result(self, kw):
        try:
            conditions = []
            receiveConditions = []
            shipConditions = []
            warehouses = Warehouse.get_all()
            e_date = dt.now()
            items = DBSession.query(Item).filter(Item.active == 0).order_by(Item.categoryID, Item.item_number).all()

            if kw.get("warehouseID", False):
                warehouse = getOr404(Warehouse, kw.get("warehouseID"))
                warehouses = [warehouse]

            if kw.get("item_number", False):
                items = DBSession.query(Item).filter(and_(Item.active == 0,
                    Item.__table__.c.item_number.op('ilike')("%%%s%%" % kw["item_number"].strip()))
                    ).order_by(Item.categoryID, Item.item_number).all()

            if kw.get("createStartDate", False) and kw.get("createEndDate", False):
                b_date = dt.strptime(kw.get("createStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                e_date = dt.strptime(kw.get("createEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
                conditions.append(OrderInfoHeader.orderDate >= b_date)
                conditions.append(OrderInfoHeader.orderDate <= e_date)
                receiveConditions.append(ReceiveItem.createTime >= b_date)
                receiveConditions.append(ReceiveItem.createTime <= e_date)
                shipConditions.append(ShipItem.createTime >= b_date)
                shipConditions.append(ShipItem.createTime <= e_date)
            elif kw.get("createStartDate", False):
                b_date = dt.strptime(kw.get("createStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                conditions.append(OrderInfoHeader.orderDate >= b_date)
                receiveConditions.append(ReceiveItem.createTime >= b_date)
                shipConditions.append(ShipItem.createTime >= b_date)
            elif kw.get("createEndDate", False):
                e_date = dt.strptime(kw.get("createEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
                conditions.append(OrderInfoHeader.orderDate <= e_date)
                receiveConditions.append(ReceiveItem.createTime <= e_date)
                shipConditions.append(ShipItem.createTime <= e_date)

            data = []
            # print warehouses
            # print items
            cols = 19
            for w in warehouses:
                for item in items:
                    orders = DBSession.query(OrderInfoHeader).join(OrderInfoDetail,
                        Item).filter(and_(OrderInfoHeader.status > 0, OrderInfoDetail.itemID == item.id,
                        OrderInfoHeader.regionID == w.regionID))
                    receiveItems = DBSession.query(ReceiveItem).filter(and_(ReceiveItem.active == 0,
                        ReceiveItem.warehouseID == w.id, ReceiveItem.itemID == item.id))
                    for value in conditions:
                        orders = orders.filter(value)
                    for value in receiveConditions:
                        receiveItems = receiveItems.filter(value)
                    orders = orders.order_by(OrderInfoHeader.id).all()
                    receiveItems = receiveItems.order_by(ReceiveItem.id).all()
                    # print len(orders)
                    avaQty = item.availableQtyByWarehouse(w.id, date=e_date)
                    inventoryDeficit = item.inventoryDeficitByWarehouse(w.id, date=e_date)
                    tmp_data = []
                    if not receiveItems and not orders:
                        tmp = [''] * cols
                        tmp[0] = item.category.name  # brand
                        tmp[2] = item.item_number  # bag item no
                        tmp[12] = item.getPrice(w.regionID) * 1000  # unit price
                        tmp[14] = w.name  # warehouse
                        # print tmp
                        data.append(tmp)
                    if receiveItems:
                        for ri in receiveItems:
                            tmp = [''] * cols
                            tmp[0] = item.category.name  # brand
                            tmp[2] = item.item_number  # bag item no
                            tmp[4] = ri.createTime
                            tmp[5] = ri.qty
                            tmp[12] = item.getPrice(w.regionID) * 1000  # unit price
                            tmp[14] = w.name  # warehouse
                            tmp_data.append(tmp)
                    if orders:
                        details = DBSession.query(OrderInfoDetail).filter(and_(OrderInfoDetail.itemID == item.id,
                            OrderInfoDetail.headerID.in_([o.id for o in orders]))).order_by(OrderInfoDetail.id).all()
                        for index, d in enumerate(details):
                            order = d.header
                            # print order.issuedBy.display_name
                            # ship_items = d.order_detail_ship_item
                            ship_items = DBSession.query(ShipItem).filter(ShipItem.active == 0).filter(ShipItem.orderDetailID == d.id)
                            # for value in shipConditions:
                            #     ship_items = ship_items.filter(value)
                            ship_items = ship_items.order_by(ShipItem.id).all()
                            # print ship_items
                            if ship_items:
                                for j, si in enumerate(ship_items):
                                    # print si.qty
                                    tmp = [''] * cols
                                    tmp[0] = item.category.name  # brand
                                    tmp[1] = order.orderNO
                                    tmp[2] = item.item_number  # bag item no
                                    tmp[3] = order.issuedBy.display_name  # vendor
                                    tmp[4] = si.createTime
                                    tmp[6] = getattr(order, 'orderDate')
                                    tmp[7] = getattr(d, 'qty')
                                    tmp[8] = 0 - si.qty
                                    tmp[9] = si.createTime
                                    tmp[10] = si.header.invoiceNumber
                                    tmp[11] = si.invoiceDate or ''
                                    tmp[12] = item.getPrice(w.regionID) * 1000
                                    tmp[13] = item.getPrice(w.regionID) * si.qty
                                    tmp[14] = w.name
                                    tmp[15] = getattr(order, 'region').name
                                    tmp[-3] = order.remark
                                    tmp_data.append(tmp)
                            else:
                                tmp = [''] * cols
                                tmp[0] = item.category.name  # brand
                                tmp[1] = order.orderNO
                                tmp[2] = item.item_number  # bag item no
                                tmp[3] = order.issuedBy.display_name
                                tmp[4] = getattr(order, 'orderDate')
                                tmp[6] = getattr(order, 'orderDate')
                                tmp[7] = getattr(d, 'qty')
                                tmp[12] = item.getPrice(w.regionID) * 1000  # unit price
                                tmp[14] = w.name  # warehouse
                                tmp[-3] = order.remark
                                tmp_data.append(tmp)
                    if tmp_data:
                        tmp_data = sorted(tmp_data, key=lambda tmp: tmp[4])
                        data = data + tmp_data
                    if data:
                        data[-1][-2] = avaQty
                        data[-1][-1] = inventoryDeficit
            return data
        except:
            traceback.print_exc()

    def _query_history_result(self, kw):
        try:
            conditions = []

            if kw.get("warehouseID", False):
                conditions.append(WarehouseHistory.warehouseID == kw["warehouseID"])

            if kw.get("type", False):
                conditions.append(WarehouseHistory.type == kw["type"])

            if kw.get("item_number", False):
                conditions.append(Item.__table__.c.item_number.op('ilike')("%%%s%%" % kw["item_number"].strip()))

            if kw.get("categoryID", False):
                conditions.append(Item.categoryID == kw["categoryID"].strip())

            if kw.get("user_id", False):
                conditions.append(OrderInfoHeader.issuedById == kw["user_id"].strip())

            if kw.get("createStartDate", False) and kw.get("createEndDate", False):
                b_date = dt.strptime(kw.get("createStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                e_date = dt.strptime(kw.get("createEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
                conditions.append(WarehouseHistory.createTime >= b_date)
                conditions.append(WarehouseHistory.createTime <= e_date)
            elif kw.get("createStartDate", False):
                b_date = dt.strptime(kw.get("createStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                conditions.append(WarehouseHistory.createTime >= b_date)
            elif kw.get("createEndDate", False):
                e_date = dt.strptime(kw.get("createEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
                conditions.append(WarehouseHistory.createTime <= e_date)

            obj = DBSession.query(WarehouseHistory).join(Item, OrderInfoHeader).filter(WarehouseHistory.active == 0)
            if len(conditions):
                for value in conditions:
                    obj = obj.filter(value)
            if kw.get('action', False):
                return obj.order_by(OrderInfoHeader.id, WarehouseHistory.id)
            else:
                return obj.order_by(desc(WarehouseHistory.id) if kw.get('o', 'desc') == 'desc' else WarehouseHistory.id)
        except:
            traceback.print_exc()
