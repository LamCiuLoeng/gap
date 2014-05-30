# -*- coding: utf-8 -*-
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
from gapproject.widgets.new_inventory import *

import transaction


class StockAdjustmentController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose('gapproject.templates.stock_adjustment.index')
    @paginate('result', items_per_page=10)
    @tabFocus(tab_type="main")
    def index(self, **kw):
        try:
            search_form = stockAdjustmentSearchForm
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
            itemIDs = kw.get('itemIDs').split('|')
            warehouseID = kw.get('warehouseID')
            remark = kw.get('remark')
            saHeader = StockAdjustmentHeader()
            saHeader.no = 'ADJ%s' % dt.now().strftime('%Y%m%d')
            saHeader.status = 'confirmed'.upper()
            saHeader.remark = remark
            saHeader.warehouseID = warehouseID
            saHeader.issuedBy = request.identity["user"]
            saHeader.lastModifyBy = request.identity["user"]
            adItems = []
            for itemID in itemIDs:
                saDetail = StockAdjustmentDetail()
                saDetail.qty = int(kw.get('adjustmentQty-%s' % itemID))
                saDetail.type = kw.get('type-%s' % itemID)
                saDetail.status = 'confirmed'.upper()
                saDetail.onHandQty = int(kw.get('onHandQty-%s' % itemID))
                # saDetail.reservedQty = int(kw.get('reservedQty-%s' % itemID))
                saDetail.availableQty = int(kw.get('availableQty-%s' % itemID))
                saDetail.header = saHeader
                saDetail.itemID = itemID
                saDetail.warehouseID = warehouseID
                saDetail.issuedBy = request.identity["user"]
                saDetail.lastModifyBy = request.identity["user"]
                adItems.append(saDetail)
            DBSession.add_all(adItems)
            DBSession.flush()
            saHeader.no = '%s%05d' % (saHeader.no, saHeader.id)
        except:
            transaction.doom()
            traceback.print_exc()
            flash("The service is not avaiable now!", "warn")
        else:
            flash("Confirmed successfully!")
            redirect("/stockAdjustment/view?sadid=%s" % saHeader.id)

    @expose('gapproject.templates.stock_adjustment.view')
    @tabFocus(tab_type="main")
    def view(self, **kw):

        saHeader = getOr404(StockAdjustmentHeader, kw.get('sadid'))

        if len(saHeader.stock_adjustment_details) < 1:
            flash("There's no details related to this!", "warn")
            redirect('/stockAdjustment//index')

        return {"header": saHeader,
                "details": saHeader.stock_adjustment_details}

    @expose('')
    @tabFocus(tab_type="main")
    def approve(self, **kw):
        saHeader = getOr404(StockAdjustmentHeader, kw.get('sadid'))
        if len(saHeader.stock_adjustment_details) < 1:
            flash("There's no details related to this!", "warn")
            redirect('/stockAdjustment/index')
        try:
            saHeader.status = 'approved'.upper()
            saHeader.approvedDate = dt.now()
            saHeader.approvedBy = request.identity["user"]
            DBSession.query(StockAdjustmentDetail).filter(and_(StockAdjustmentDetail.headerID == saHeader.id,
                StockAdjustmentDetail.active == 0)).update({StockAdjustmentDetail.status: 'approved'.upper()})
        except:
            transaction.doom()
            traceback.print_exc()
            flash("The service is not avaiable now!", "warn")
        else:
            flash("Approved successfully!")
        redirect("/stockAdjustment/view?sadid=%s" % saHeader.id)

    @expose('gapproject.templates.stock_adjustment.new')
    @paginate('result', items_per_page=10000)
    def new(self, **kw):
        try:
            if kw and kw.get('warehouseID', False):
                warehouse = getOr404(Warehouse, kw.get('warehouseID'))
                q = self._query_item(kw)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, values=kw, warehouse=warehouse)
            else:
                return dict(result=[], values={}, warehouse=None)
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    @expose('gapproject.templates.stock_adjustment.new_form')
    @paginate('result', items_per_page=10000)
    @tabFocus(tab_type="main")
    def new_form(self, **kw):
        # print kw
        try:
            if kw and kw.get('warehouseID', False):
                warehouse = getOr404(Warehouse, kw.get('warehouseID'))
                q = self._query_item(kw)
                if (not q) or q.count() < 1:
                    result = []
                else:
                    result = q.all()
                return dict(result=result, values=kw, warehouse=warehouse)
            else:
                warehouses = Warehouse.get_all()
                return dict(result=[], values={}, warehouses=warehouses)
        except:
            flash("There service is not avaiable now, please try it later.", status="warn")
            traceback.print_exc()

    def _query_result(self, kw):
        try:
            conditions = []

            if kw.get("warehouseID", False):
                conditions.append(StockAdjustmentHeader.warehouseID == kw["warehouseID"])

            if kw.get("item_number", False):
                conditions.append(Item.__table__.c.item_number.op('ilike')("%%%s%%" % kw["item_number"].strip()))
            if kw.get("itemID", False):
                conditions.append(Item.id == kw["itemID"])

            obj = DBSession.query(StockAdjustmentHeader).join(StockAdjustmentDetail, Item).filter(and_(
                StockAdjustmentHeader.active == 0, StockAdjustmentDetail.active == 0))
            if len(conditions):
                for value in conditions:
                    obj = obj.filter(value)

            return obj.order_by(desc(StockAdjustmentHeader.id))
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
