# -*- coding: utf-8 -*-
import traceback
import urllib
import os
import shutil
import random
from datetime import datetime as dt
from decimal import Decimal

from win32com.client import DispatchEx

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
from gapproject.widgets.new_inventory import *
from gapproject.util.gap_const import *

import transaction


class ShipController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose('gapproject.templates.ship.index')
    @paginate('collections', items_per_page=25)
    @tabFocus(tab_type="main")
    def index(self, **kw):
        try:
            search_form = orderSearchFormInstance

            if kw:
                result = self._query_result(kw)

                return dict(search_form=search_form,
                            collections=result,
                            values=kw,
                            return_url='/',
                            )
            else:
                return dict(search_form=search_form,
                            collections=[],
                            values={},
                            return_url='/',
                            )
        except:
            flash("The service is not avaiable now,please try it later.", status="warn")
            traceback.print_exc()
            redirect('/')

    @expose('gapproject.templates.ship.ship_form_view')
    @tabFocus(tab_type="main")
    def view(self, **kw):
        (flag, id) = rpacDecrypt(kw.get("code", ""))

        if not flag:
            flash("Please don't access the resource illegally!")
            redirect('/ship/index')

        order_header = getOr404(OrderInfoHeader, id)

        if len(order_header.order_details) < 1:
            flash("There's no order related to this PO!", "warn")
            redirect('/ship/index')
        shipItems = DBSession.query(ShipItemHeader).filter(and_(ShipItemHeader.active == 0,
            ShipItemHeader.orderID == order_header.id)).order_by(ShipItemHeader.id).all()
        return {"order_header": order_header,
                "order_details": order_header.order_details,
                'return_url': '/',
                'shipItems': shipItems,
                }

    @expose('gapproject.templates.ship.ship_detail_view')
    @tabFocus(tab_type="main")
    def viewDetail(self, **kw):

        shHeader = getOr404(ShipItemHeader, kw.get('shid'))

        if len(shHeader.ship_item_details) < 1:
            flash("There's no details related to this!", "warn")
            redirect('/ship/index')

        return {"header": shHeader,
                "details": [d for d in shHeader.ship_item_details if d.active == 0]}

    @expose()
    def cancelShip(self, **kw):
        shHeader = getOr404(ShipItemHeader, kw.get('shid'))
        try:
            orderHeader = shHeader.orderHeader
            shHeader.active = 1
            shHeader.remark = 'Cancel'
            shHeader.lastModifyTime = dt.now()
            shHeader.lastModifyBy = request.identity["user"]
            DBSession.query(ShipItem).filter(and_(ShipItem.headerID == shHeader.id,
                ShipItem.active == 0)).update({ShipItem.active: 1,
                                                    ShipItem.lastModifyTime: dt.now(),
                                                    ShipItem.lastModifyById: request.identity["user"].user_id})

            orderHeader.status = NEW
        except:
            transaction.doom()
            traceback.print_exc()
            flash("The service is not avaiable now!", "warn")
        else:
            flash("Cancel successfully!")
        redirect('/ship/view?code=%s' % rpacEncrypt(shHeader.orderID))

    @expose('gapproject.templates.ship.ship_detail_order_view')
    @tabFocus(tab_type="main")
    def viewDetail4Order(self, **kw):

        shHeader = getOr404(ShipItemHeader, kw.get('shid'))

        if len(shHeader.ship_item_details) < 1:
            flash("There's no details related to this!", "warn")
            redirect('/ship/index')

        return {"header": shHeader,
                "details": shHeader.ship_item_details}

    @expose('gapproject.templates.ship.ship_detail_view')
    def viewDetailSave(self, **kw):
        shHeader = getOr404(ShipItemHeader, kw.get('shid'))

        if len(shHeader.ship_item_details) < 1:
            flash("There's no details related to this!", "warn")
            redirect('/ship/index')
        try:
            shHeader.invoiceNumber = kw.get('invoiceNumber')
            shHeader.invoice = float(kw.get('invoice')) if kw.get('invoice') else None
            if kw.get('remark', ''):
                shHeader.remark = kw.get('remark', '')
            # shHeader.otherInvoice = float(kw.get('otherInvoice')) if kw.get('otherInvoice') else None
            for k in kw:
                if k.startswith("invoiceDate-"):
                    si = getOr404(ShipItem, int(k.split("-")[1]))
                    if kw[k]:
                        si.invoiceDate = kw[k]
                        DBSession.flush()

            DBSession.flush()
        except:
            traceback.print_exc()
            transaction.doom()
            flash("The service is not avaiable now!", "warn")
            redirect('/ship/index')
        else:
            flash("Update Successfully!")
            return {"header": shHeader,
                "details": shHeader.ship_item_details}

    @expose('gapproject.templates.ship.reserve')
    @tabFocus(tab_type="main")
    def reserve(self, **kw):
        order_header = getOr404(OrderInfoHeader, kw.get('orderID'))
        warehouse = getOr404(Warehouse, kw.get('warehouseID'))
        details = DBSession.query(OrderInfoDetail).filter(OrderInfoDetail.id.in_(
            kw.get('reserveIDs').split('|'))).order_by(OrderInfoDetail.id).all()
        return {'order_header': order_header, 'warehouse': warehouse, 'details': details}

    @expose('gapproject.templates.ship.release')
    @tabFocus(tab_type="main")
    def release(self, **kw):
        order_header = getOr404(OrderInfoHeader, kw.get('orderID'))
        warehouse = getOr404(Warehouse, kw.get('warehouseID'))
        details = DBSession.query(OrderInfoDetail).filter(OrderInfoDetail.id.in_(
            kw.get('reserveIDs').split('|'))).order_by(OrderInfoDetail.id).all()
        return {'order_header': order_header, 'warehouse': warehouse, 'details': details}

    @expose('gapproject.templates.ship.to_ship')
    @tabFocus(tab_type="main")
    def toShip(self, **kw):
        order_header = getOr404(OrderInfoHeader, kw.get('orderID'))
        warehouse = getOr404(Warehouse, kw.get('warehouseID'))
        details = DBSession.query(OrderInfoDetail).filter(OrderInfoDetail.id.in_(
            kw.get('shipIDs').split('|'))).order_by(OrderInfoDetail.id).all()
        return {'order_header': order_header, 'warehouse': warehouse, 'details': details}

    @expose('')
    @tabFocus(tab_type="main")
    def saveReserve(self, **kw):
        orderHeader = getOr404(OrderInfoHeader, kw.get('orderID'))
        warehouse = getOr404(Warehouse, kw.get('warehouseID'))
        try:
            reserveItems = []
            details = DBSession.query(OrderInfoDetail).filter(OrderInfoDetail.id.in_(
                    kw.get('detailIDs').split('|'))).order_by(OrderInfoDetail.id).all()
            for d in details:
                reserveItem = ReserveItem()
                reserveItem.qty = int(kw.get('qty-%s' % d.id))
                reserveItem.item = d.item
                reserveItem.warehouse = warehouse
                reserveItem.orderID = orderHeader.id
                reserveItem.orderDetail = d
                reserveItem.issuedBy = request.identity["user"]
                reserveItem.lastModifyBy = request.identity["user"]
                reserveItems.append(reserveItem)
            DBSession.add_all(reserveItems)
            DBSession.flush()
            if orderHeader.is_all_reserve_success and orderHeader.status < SHIPPED_PART:
                orderHeader.status = ALL_RESERVED_SUCCESS
            else:
                orderHeader.status = PARTIAL_RESERVED_SUCCESS
        except:
            transaction.doom()
            traceback.print_exc()
            flash("The service is not avaiable now!", "warn")
        else:
            flash("Reserved successfully!")
        redirect('/ship/view?code=%s' % rpacEncrypt(orderHeader.id))

    @expose('')
    @tabFocus(tab_type="main")
    def saveRelease(self, **kw):
        orderHeader = getOr404(OrderInfoHeader, kw.get('orderID'))
        warehouse = getOr404(Warehouse, kw.get('warehouseID'))
        try:
            reserveItems = []
            details = DBSession.query(OrderInfoDetail).filter(OrderInfoDetail.id.in_(
                    kw.get('detailIDs').split('|'))).order_by(OrderInfoDetail.id).all()
            for d in details:
                reserveItem = ReserveItem()
                reserveItem.qty = 0 - int(kw.get('qty-%s' % d.id))
                reserveItem.item = d.item
                reserveItem.warehouse = warehouse
                reserveItem.orderID = orderHeader.id
                reserveItem.orderDetail = d
                reserveItem.issuedBy = request.identity["user"]
                reserveItem.lastModifyBy = request.identity["user"]
                reserveItems.append(reserveItem)
            DBSession.add_all(reserveItems)
            DBSession.flush()
            if orderHeader.status < SHIPPED_PART and orderHeader.is_reserve_fail:
                orderHeader.status = RESERVED_FAIL
            elif orderHeader.status < SHIPPED_PART and not orderHeader.is_all_reserve_success:
                orderHeader.status = PARTIAL_RESERVED_SUCCESS
        except:
            transaction.doom()
            traceback.print_exc()
            flash("The service is not avaiable now!", "warn")
        else:
            flash("Released successfully!")
        redirect('/ship/view?code=%s' % rpacEncrypt(orderHeader.id))

    @expose('')
    @tabFocus(tab_type="main")
    def saveShip(self, **kw):
        orderHeader = getOr404(OrderInfoHeader, kw.get('orderID'))
        warehouse = getOr404(Warehouse, kw.get('warehouseID'))
        try:
            shipItems = []
            details = DBSession.query(OrderInfoDetail).filter(OrderInfoDetail.id.in_(
                    kw.get('detailIDs').split('|'))).order_by(OrderInfoDetail.id).all()
            shipHeader = ShipItemHeader()
            shipHeader.no = 'SHI%s' % dt.now().strftime('%Y%m%d')
            shipHeader.invoiceNumber = kw.get('invoiceNumber', '').strip()
            # shipHeader.invoice
            # shipHeader.otherInvoice = float(kw.get('otherInvoice').strip()) if kw.get('otherInvoice').strip() else None
            shipHeader.remark = kw.get('remark', None)
            shipHeader.warehouse = warehouse
            shipHeader.orderHeader = orderHeader
            shipHeader.createTime = kw.get('createTime')
            shipHeader.issuedBy = request.identity["user"]
            shipHeader.lastModifyBy = request.identity["user"]
            # invoice = 0
            for d in details:
                shipItem = ShipItem()
                shipItem.qty = int(kw.get('qty-%s' % d.id))
                shipItem.internalPO = kw.get('internalPO-%s' % d.id)
                shipItem.header = shipHeader
                shipItem.item = d.item
                shipItem.warehouse = warehouse
                shipItem.orderID = orderHeader.id
                shipItem.orderDetail = d
                shipItem.createTime = shipHeader.createTime
                shipItem.issuedBy = request.identity["user"]
                shipItem.lastModifyBy = request.identity["user"]
                ### updated by weber 2013-02-05
                shipItem.invoiceDate = kw.get('invoiceDate-%s' % d.id) if kw.get('invoiceDate-%s' % d.id) else None
                shipItems.append(shipItem)
                # invoice += Price.get_price(warehouse.regionID, d.item.id).price * shipItem.qty
            # if invoice > 0:
            #     shipHeader.invoice = invoice
            DBSession.add_all(shipItems)
            DBSession.flush()
            shipHeader.no = '%s%05d' % (shipHeader.no, shipHeader.id)
            if orderHeader.is_shipped_complete:
                orderHeader.status = SHIPPED_COMPLETE
            else:
                orderHeader.status = SHIPPED_PART
        except:
            transaction.doom()
            traceback.print_exc()
            flash("The service is not avaiable now!", "warn")
        else:
            flash("Shipped successfully!")
        redirect('/ship/view?code=%s' % rpacEncrypt(orderHeader.id))

    def _query_result(self, kw):
        try:
            conditions = []

            if kw.get("orderDate", False):
                b_date = dt.strptime(kw.get("orderDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                conditions.append(OrderInfoHeader.orderDate >= b_date)

            if kw.get("vendorPO", False):
                conditions.append(OrderInfoHeader.vendorPO.like("%%%s%%" % kw.get("vendorPO", "")))

            if kw.get("orderNO", False):
                conditions.append(OrderInfoHeader.orderNO.like("%%%s%%" % kw.get("orderNO", "")))

            if kw.get("item_no", False):
                conditions.append(OrderInfoHeader.id == OrderInfoDetail.headerID)
                conditions.append(OrderInfoDetail.itemID == Item.id)
                conditions.append(Item.item_number.like("%%%s%%" % kw.get("item_no", "")))

            if kw.get('status', False):
                conditions.append(OrderInfoHeader.status == int(kw.get('status')))

            if len(conditions):
                order = DBSession.query(OrderInfoHeader).filter(OrderInfoHeader.status > 0)

                for condition in conditions:
                    order = order.filter(condition)

                result = order.order_by(desc(OrderInfoHeader.orderDate)).all()
            else:
                result = DBSession.query(OrderInfoHeader).order_by(desc(OrderInfoHeader.orderDate)).all()

            return result
        except:
            traceback.print_exc()
