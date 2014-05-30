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
from gapproject.widgets.report import *

from gapproject.util.gap_const import *

# import transaction


# Current inventory levels
class VoReportController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose("gapproject.templates.report.voreport")
    @tabFocus(tab_type="report")
    def  index(self, **kw):
        return {"widget": voReportSearchForm}

    @expose()
    def export(self, **kw):
        try:
            current = dt.now()
            dateStr = current.strftime("%Y%m%d")
            fileDir = os.path.join(config.get("public_dir"), "report", 'vo', dateStr)
            if not os.path.exists(fileDir):
                os.makedirs(fileDir)
            templatePath = os.path.join(config.get("public_dir"), 'TEMPLATE', "VO_TEMPLATE.xlsx")
            tempFileName = os.path.join(fileDir, "tmp_%s.xlsx" % current.strftime("%Y%m%d%H%M%S"))
            realFileName = os.path.join(fileDir, "orders_report_%s.xlsx" % current.strftime("%Y%m%d%H%M%S"))
            shutil.copy(templatePath, tempFileName)
            report_xls = InventoryExcel(templatePath=tempFileName, destinationPath=realFileName)
            data = []
            if kw:
                data = self._query_vo_result(kw)
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
            redirect("/voreport/index")

    def _query_vo_result(self, kw):
        warehouses = []
        conditions = []
        itemConditions = []
        invoiceDateConditions = []

        if kw.get("warehouseID", False):
                warehouse = getOr404(Warehouse, kw.get("warehouseID"))
                warehouses = [warehouse]
        else:
            warehouses = Warehouse.get_all()

        if kw.get("createStartDate", False) and kw.get("createEndDate", False):
            b_date = dt.strptime(kw.get("createStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
            e_date = dt.strptime(kw.get("createEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
            conditions.append(OrderInfoHeader.orderDate >= b_date)
            conditions.append(OrderInfoHeader.orderDate <= e_date)
        elif kw.get("createStartDate", False):
            b_date = dt.strptime(kw.get("createStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
            conditions.append(OrderInfoHeader.orderDate >= b_date)
        elif kw.get("createEndDate", False):
            e_date = dt.strptime(kw.get("createEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
            conditions.append(OrderInfoHeader.orderDate <= e_date)

        if kw.get("categoryID", False):
                conditions.append(Item.categoryID == int(kw.get("categoryID", "")))
                itemConditions.append(Item.categoryID == int(kw.get("categoryID", "")))

        if kw.get("userID", False):
            conditions.append(OrderInfoHeader.issuedById == int(kw.get("userID")))

        if kw.get("invoiceStartDate", False) and kw.get("invoiceEndDate", False):
            b_date = dt.strptime(kw.get("invoiceStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
            e_date = dt.strptime(kw.get("invoiceEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
            invoiceDateConditions.append(ShipItem.invoiceDate >= b_date)
            invoiceDateConditions.append(ShipItem.invoiceDate <= e_date)
        elif kw.get("invoiceStartDate", False):
            b_date = dt.strptime(kw.get("invoiceStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
            invoiceDateConditions.append(ShipItem.invoiceDate >= b_date)
        elif kw.get("invoiceEndDate", False):
            e_date = dt.strptime(kw.get("invoiceEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
            invoiceDateConditions.append(ShipItem.invoiceDate <= e_date)

        data = []
        region_ids = [w.regionID for w in warehouses]

        if invoiceDateConditions:
            shipItems = DBSession.query(ShipItem).join(OrderInfoHeader, OrderInfoDetail, Item).filter(and_(
                      OrderInfoHeader.regionID.in_(region_ids),
                      OrderInfoHeader.status > CANCEL, ShipItem.active == 0))
            for c in itemConditions:
                    shipItems = shipItems.filter(c)
            for c in invoiceDateConditions:
                    shipItems = shipItems.filter(c)
            shipItems = shipItems.order_by(ShipItem.warehouseID, ShipItem.orderID, ShipItem.id).all()
            for s in shipItems:
                h = s.orderHeader
                d = s.orderDetail
                item = s.item
                warehouse = s.warehouse
                price = item.getPrice(warehouse.regionID)
                data.append((h.issuedBy.display_name, h.orderNO,
                    h.vendorPO, getattr(h, 'orderDate'), s.createTime, s.invoiceDate,
                    item.category.name, item.item_number, warehouse.name, d.qty,
                    s.qty, d.qty - d.qtyShipped, price * 1000,
                    price * s.qty,
                    s.header.invoiceNumber
                    ))
        else:
            orders = DBSession.query(OrderInfoHeader).join(OrderInfoDetail, Item).filter(and_(
                      OrderInfoHeader.regionID.in_(region_ids),
                      OrderInfoHeader.status > CANCEL))
            for c in conditions:
                orders = orders.filter(c)

            orders = orders.order_by(OrderInfoHeader.regionID, OrderInfoHeader.id).all()

            for h in orders:
                warehouse = h.region.region_warehouse[0]
                details = DBSession.query(OrderInfoDetail).join(Item).filter(
                          OrderInfoDetail.headerID == h.id)
                for c in itemConditions:
                    details = details.filter(c)
                details = details.order_by(OrderInfoDetail.id).all()
                for d in details:
                    shipItems = DBSession.query(ShipItem).filter(and_(
                        ShipItem.active == 0, ShipItem.orderDetailID == d.id)).order_by(ShipItem.id).all()
                    tmpQty = d.qty
                    item = d.item
                    price = item.getPrice(warehouse.regionID)
                    if shipItems:
                        for s in shipItems:
                            tmpQty -= s.qty
                            data.append((h.issuedBy.display_name, h.orderNO,
                                h.vendorPO, getattr(h, 'orderDate'), s.createTime, s.invoiceDate,
                                item.category.name, item.item_number, warehouse.name, d.qty,
                                s.qty, tmpQty, price * 1000,
                                price * s.qty,
                                s.header.invoiceNumber
                                ))
                    else:
                        data.append((h.issuedBy.display_name, h.orderNO,
                                h.vendorPO, getattr(h, 'orderDate'), '', '',
                                item.category.name, item.item_number, warehouse.name, tmpQty,
                                '', tmpQty, price * 1000,
                                '',
                                ''
                                ))

        return data
