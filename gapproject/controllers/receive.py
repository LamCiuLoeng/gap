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

# project specific imports
from gapproject.lib.base import BaseController

from gapproject.model import *

from gapproject.util.common import *
from gapproject.util.excel_helper import *
from gapproject.widgets import *
from gapproject.widgets.new_inventory import *

import transaction


class ReceiveController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose('gapproject.templates.receive.index')
    @paginate('result', items_per_page=10)
    @tabFocus(tab_type="main")
    def index(self, **kw):
        try:
            search_form = receiveSearchForm
            if kw:
                q = self._query_result(kw)
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

    @expose()
    def save(self, **kw):
        try:
            save_items = []
            itemIDs = kw.get('itemIDs').split('|')
            reHeader = ReceiveItemHeader()
            reHeader.no = 'REC%s' % dt.now().strftime('%Y%m%d')
            reHeader.remark = kw.get('remark', '')
            reHeader.warehouseID = kw.get('warehouseID')
            reHeader.issuedBy = request.identity["user"]
            reHeader.lastModifyBy = request.identity["user"]
            reHeader.createTime = kw.get('receivedDate', dt.now())
            for itemID in itemIDs:
                _r = ReceiveItem()
                _r.qty = int(kw.get('qty-%s' % itemID))
                _r.internalPO = kw.get('internalPO-%s' % itemID)
                _r.header = reHeader
                _r.itemID = itemID
                _r.warehouseID = int(kw.get('warehouseID'))
                _r.issuedBy = request.identity["user"]
                _r.lastModifyBy = request.identity["user"]
                _r.createTime = reHeader.createTime
                save_items.append(_r)

            DBSession.add_all(save_items)
            DBSession.flush()
            reHeader.no = '%s%05d' % (reHeader.no, reHeader.id)
        except:
            transaction.doom()
            traceback.print_exc()
            flash("The service is not avaiable now!", "warn")
        else:
            flash("Confirmed successfully!")
            redirect("/receive/view?recid=%s" % reHeader.id)

    @expose('gapproject.templates.receive.view')
    @tabFocus(tab_type="main")
    def view(self, **kw):

        reHeader = getOr404(ReceiveItemHeader, kw.get('recid'))

        if len(reHeader.receive_item_details) < 1:
            flash("There's no details related to this!", "warn")
            redirect('/receive/index')

        return {"header": reHeader,
                "details": reHeader.receive_item_details}

    @expose()
    def tocancel(self, **kw):
        headerID = kw.get('headerID')
        reHeader = getOr404(ReceiveItemHeader, headerID)
        twenty_minutes = timedelta(minutes=20)
        if dt.now() > reHeader.createTime + twenty_minutes and not in_group('Admin'):
            flash("More than twenty minutes, So can not cancel!", "warn")
            redirect('/receive/view?recid=%s' % headerID)
        try:
            reHeader.active = 1
            reHeader.remark += '    Cancel'
            reHeader.lastModifyTime = dt.now()
            reHeader.lastModifyBy = request.identity["user"]
            DBSession.query(ReceiveItem).filter(and_(ReceiveItem.headerID == reHeader.id,
                ReceiveItem.active == 0)).update({ReceiveItem.active: 1,
                                                    ReceiveItem.lastModifyTime: dt.now(),
                                                    ReceiveItem.lastModifyById: request.identity["user"].user_id})
        except:
            transaction.doom()
            traceback.print_exc()
            flash("The service is not avaiable now!", "warn")
            redirect('/receive/view?recid=%s' % headerID)
        else:
            flash("Cancel successfully!")
            redirect('/receive/index')

    @expose('gapproject.templates.receive.new')
    @paginate('result', items_per_page=10000)
    @tabFocus(tab_type="main")
    def new(self, **kw):
        try:
            if kw and kw.get('warehouseID', False):
                warehouse = getOr404(Warehouse, kw.get('warehouseID'))
                q = self._query_item(kw)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, values=kw, warehouse=warehouse, receivedDate=kw.get('receivedDate', ''))
            else:
                warehouses = Warehouse.get_all()
                return dict(result=[], values={}, warehouses=warehouses, receivedDate=kw.get('receivedDate', ''))
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    @expose('gapproject.templates.receive.new_sub')
    @paginate('result', items_per_page=10000)
    def newSub(self, **kw):
        try:
            if kw and kw.get('warehouseID', False):
                warehouse = getOr404(Warehouse, kw.get('warehouseID'))
                q = self._query_item(kw)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, values=kw, warehouse=warehouse, receivedDate=kw.get('receivedDate', ''))
            else:
                return dict(result=[], values={}, warehouse=None, receivedDate='')
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    def _query_result(self, kw):
        try:
            conditions = []

            if kw.get("warehouseID", False):
                conditions.append(ReceiveItemHeader.warehouseID == kw["warehouseID"])

            if kw.get("item_number", False):
                conditions.append(Item.__table__.c.item_number.op('ilike')("%%%s%%" % kw["item_number"].strip()))
            if kw.get("itemID", False):
                conditions.append(Item.id == kw["itemID"])

            if kw.get("no", False):
                conditions.append(ReceiveItemHeader.no == kw["no"].strip())

            obj = DBSession.query(ReceiveItemHeader).join(ReceiveItem, Item).filter(and_(ReceiveItemHeader.active == 0,
                Item.active == 0))
            if len(conditions):
                for value in conditions:
                    obj = obj.filter(value)

            return obj.order_by(desc(ReceiveItemHeader.id))
        except:
            traceback.print_exc()

    def _query_item(self, kw):
        try:
            conditions = []

            if kw.get("item_number", False):
                conditions.append(Item.__table__.c.item_number.op('ilike')("%%%s%%" % kw["item_number"].strip()))
            if kw.get("notInItemID", False):
                conditions.append(~Item.id.in_(kw["notInItemID"].split('|')))
            if kw.get("itemIDs", False):
                conditions.append(Item.id.in_(kw["itemIDs"].split('|')))

            obj = DBSession.query(Item).filter(Item.active == 0)
            if len(conditions):
                for value in conditions:
                    obj = obj.filter(value)

            return obj.order_by(Item.id)
        except:
            traceback.print_exc()
