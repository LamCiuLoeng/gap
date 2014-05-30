# -*- coding: utf-8 -*-
import traceback
import urllib
import os
import shutil
import random
from datetime import timedelta, datetime as dt

# turbogears imports
from tg import expose
from tg import redirect, validate, flash, request, config
from tg.decorators import *

# third party imports
#from pylons.i18n import ugettext as _
from repoze.what import predicates, authorize
from repoze.what.predicates import not_anonymous, in_group, has_permission

from sqlalchemy.sql import *
from sqlalchemy.sql.functions import sum

# project specific imports
from gapproject.lib.base import BaseController

from gapproject.model import *

from gapproject.util.common import *
from gapproject.util.excel_helper import *
from gapproject.widgets import *
from gapproject.widgets.inventory import *

import transaction


class EnquiryController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose('gapproject.templates.inventory.bywarehouse')
    @paginate('result', items_per_page=20)
    @tabFocus(tab_type="main")
    def bywarehouse(self, **kw):
        try:
            search_form = enquiryByWarehouseForm
            if kw:
                warehouse = DBSession.query(Warehouse).get(kw.get('warehouseID'))
                q = self._query_item(kw)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, values=kw, search_form=search_form, warehouse=warehouse)
            else:
                return dict(result=[], values={}, search_form=search_form, warehouse='')
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    @expose('gapproject.templates.inventory.byitem')
    @paginate('result', items_per_page=20)
    @tabFocus(tab_type="main")
    def byitem(self, **kw):
        try:
            search_form = enquiryByItemForm
            if kw:
                q = self._query_item(kw)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, values=kw, search_form=search_form)
            else:
                return dict(result=[], values={}, search_form=search_form)
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    @expose('gapproject.templates.inventory.byweek')
    # @paginate('result', items_per_page=20)
    @tabFocus(tab_type="main")
    def byweek(self, **kw):
        try:
            search_form = enquiryByWeekForm
            if kw:
                today = dt.now().date()
                weekday = kw.get('w', None)
                if weekday:
                    weekday = dt.strptime(weekday, '%Y%m%d')
                else:
                    weekday = today
                week = self._return_week(weekday)
                prev_week = (week[0] - timedelta(days=1)).strftime('%Y%m%d')
                next_week = (week[-1] + timedelta(days=1)).strftime('%Y%m%d')
                this_week = today.strftime('%Y%m%d')
                header = []
                details = []
                now = {}
                qty_received = 0
                qty_shipped = 0
                # qty_reserved = 0
                item = DBSession.query(Item).filter(and_(Item.active == 0,
                    Item.item_number == kw.get('item_number', '').strip())).first()
                if item:
                    now['qty'] = item.totalAvailableQty()
                    now['date'] = today.strftime('%Y-%m-%d')
                    kw['itemID'] = item.id
                    for w in week:
                        color = '#FB8F23' if w.strftime('%Y-%m-%d') == today.strftime('%Y-%m-%d') else 'white'
                        header.append((w.strftime('%A'), w.strftime('%Y-%m-%d'), color))
                        _qty_received = self._get_qty(item.id, 'received', w)
                        _qty_shipped = self._get_qty(item.id, 'shipped', w)
                        # _qty_reserved = self._get_qty(item.id, 'reserved', w)
                        # details.append((_qty_received, _qty_reserved, _qty_shipped))
                        details.append((_qty_received, _qty_shipped))
                        qty_received += _qty_received
                        qty_shipped += _qty_shipped
                        # qty_reserved += _qty_reserved

                    return dict(result=details, values=kw,
                        search_form=search_form, header=header,
                        qty_received=qty_received, qty_shipped=qty_shipped,  # qty_reserved=qty_reserved,
                        now=now, prev_week=prev_week, next_week=next_week, this_week=this_week)
                else:
                    return dict(result=[], values=kw, search_form=search_form)
            else:
                return dict(result=[], values={}, search_form=search_form)
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    def _return_week(self, d):
        week = []
        weekdays = range(7)
        today_weekday = d.weekday()
        for w in weekdays:
            week.append(d + timedelta(days=(w - today_weekday)))
        return week

    def _get_qty(self, itemID, type, date):
        if type == 'received':
            return DBSession.query(sum(ReceiveItem.qty)).filter(and_(
                ReceiveItem.active == 0, ReceiveItem.itemID == itemID,
                ReceiveItem.createTime >= date,
                ReceiveItem.createTime < date + timedelta(days=1))).first()[0] or 0
        elif type == 'shipped':
            return DBSession.query(sum(ShipItem.qty)).filter(and_(
                ShipItem.active == 0, ShipItem.itemID == itemID,
                ShipItem.createTime >= date,
                ShipItem.createTime < date + timedelta(days=1))).first()[0] or 0
        elif type == 'reserved':
            return DBSession.query(sum(ReserveItem.qty)).filter(and_(
                ReserveItem.active == 0, ReserveItem.itemID == itemID,
                ReserveItem.createTime >= date,
                ReserveItem.createTime < date + timedelta(days=1))).first()[0] or 0
        else:
            return 0

    @expose('gapproject.templates.inventory.enquiry_history')
    @paginate('result', items_per_page=20)
    @tabFocus(tab_type="main")
    def history(self, **kw):
        try:
            if kw:
                item = getOr404(Item, int(kw.get('c', 0)))
                item_number = item.item_number if item else ''
                q = self._query_history_result(kw)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, values=kw, item_number=item_number)
            else:
                return dict(result=[], values={})
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    @expose('gapproject.templates.inventory.enquiry_received')
    @tabFocus(tab_type="main")
    def receivedDetail(self, **kw):
        item = getOr404(Item, int(kw.get('c', 0)))
        try:
            if kw:
                q = self._query_action_result(kw, ReceiveItem)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, values=kw, item=item, date=kw.get('s'))
            else:
                return dict(result=[], values={})
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    @expose('gapproject.templates.inventory.enquiry_reserved')
    @tabFocus(tab_type="main")
    def reservedDetail(self, **kw):
        item = getOr404(Item, int(kw.get('c', 0)))
        try:
            if kw:
                q = self._query_action_result(kw, ReserveItem)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, values=kw, item=item, date=kw.get('s'))
            else:
                return dict(result=[], values={})
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    @expose('gapproject.templates.inventory.enquiry_shipped')
    @tabFocus(tab_type="main")
    def shippedDetail(self, **kw):
        item = getOr404(Item, int(kw.get('c', 0)))
        try:
            if kw:
                q = self._query_action_result(kw, ShipItem)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, values=kw, item=item, date=kw.get('s'))
            else:
                return dict(result=[], values={})
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    @expose('gapproject.templates.inventory.total_ava_detail')
    @tabFocus(tab_type="main")
    def idetail(self, **kw):
        item = getOr404(Item, int(kw.get('c', 0)))
        try:
            warehouses = Warehouse.get_all()
            return dict(item=item, warehouses=warehouses, date=dt.now())
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    @expose('gapproject.templates.inventory.whdetail')
    @paginate('result', items_per_page=20)
    @tabFocus(tab_type="main")
    def whdetail(self, **kw):
        try:
            if kw:
                item = getOr404(Item, int(kw.get('itemID', 0)))
                item_number = item.item_number if item else ''
                q = self._query_result(kw)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, item_number=item_number)
            else:
                return dict(result=[], values={})
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    def _query_item(self, kw):
        try:
            conditions = []

            if kw.get("item_number", False):
                conditions.append(Item.__table__.c.item_number.op('ilike')("%%%s%%" % kw["item_number"].strip()))

            if kw.get("categoryID", False):
                conditions.append(Item.categoryID == kw["categoryID"])

            obj = DBSession.query(Item).filter(Item.active == 0)
            if len(conditions):
                for value in conditions:
                    obj = obj.filter(value)

            return obj.order_by(desc(Item.id))
        except:
            traceback.print_exc()

    def _query_result(self, kw):
        try:
            conditions = []

            if kw.get("warehouseID", False):
                conditions.append(Inventory.warehouseID == kw["warehouseID"])

            if kw.get("c", False):
                conditions.append(Inventory.itemID == kw["c"])

            if kw.get("item_number", False):
                conditions.append(Item.__table__.c.item_number.op('ilike')("%%%s%%" % kw["item_number"].strip()))

            if kw.get("categoryID", False):
                conditions.append(Item.categoryID == kw["categoryID"])

            obj = DBSession.query(Inventory).join(Item).filter(Inventory.active == 0)
            if len(conditions):
                for value in conditions:
                    obj = obj.filter(value)

            return obj.order_by(desc(Inventory.id))
        except:
            traceback.print_exc()

    def _query_history_result(self, kw):
        try:
            conditions = []

            if kw.get("warehouseID", False):
                conditions.append(WarehouseHistory.warehouseID == kw["warehouseID"])

            if kw.get("t", False):
                conditions.append(WarehouseHistory.type == kw["t"])

            if kw.get("c", False):
                conditions.append(Item.id == kw["c"].strip())

            if kw.get('action', False):
                conditions.append(WarehouseHistory.orderID != None)

            if kw.get("s", False) and kw.get("e", False):
                b_date = dt.strptime(kw.get("s", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                e_date = dt.strptime(kw.get("e", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
                conditions.append(WarehouseHistory.createTime >= b_date)
                conditions.append(WarehouseHistory.createTime <= e_date)

            obj = DBSession.query(WarehouseHistory).join(Item).filter(WarehouseHistory.active == 0)
            if len(conditions):
                for value in conditions:
                    obj = obj.filter(value)

            return obj.order_by(desc(WarehouseHistory.id))
        except:
            traceback.print_exc()

    def _query_action_result(self, kw, dbObj):
        try:
            conditions = []

            if kw.get("c", False):
                conditions.append(dbObj.itemID == kw["c"].strip())

            if kw.get("s", False) and kw.get("e", False):
                b_date = dt.strptime(kw.get("s", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                e_date = dt.strptime(kw.get("e", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
                conditions.append(dbObj.createTime >= b_date)
                conditions.append(dbObj.createTime <= e_date)

            obj = DBSession.query(dbObj).filter(dbObj.active == 0)
            if len(conditions):
                for value in conditions:
                    obj = obj.filter(value)
            return obj
        except:
            traceback.print_exc()
            
    @expose()
    def getAjaxField(self, **kw):
        try:
            fieldName = kw["fieldName"]
            value = kw["q"]
            result = []

            if fieldName == 'item_no':
                rs = DBSession.query(Item) \
                    .filter(Item.item_number.op('ILIKE')('%%%s%%'%str(value).strip())) \
                    .filter(Item.active == 0) \
                    .all()
                if str(value).strip().upper() in 'BR':
                    result = ['BR-|BR-']
                elif str(value).strip().upper() in 'ON':
                    result = ['ON-|ON-']
                elif str(value).strip().upper() in 'GAP':
                    result = ['GAP-|GAP-']
                result += ["%s|%d" % (v.item_number, v.id) for v in rs]
            else:
                result = []

            data = "\n".join(result)

            return data
        except:
            traceback.print_exc()
