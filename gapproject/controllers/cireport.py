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

# import transaction


# Current inventory levels
class CiReportController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose("gapproject.templates.report.cireport")
    @tabFocus(tab_type="report")
    def  index(self, **kw):
        return {"widget": ciReportSearchForm}

    @expose()
    def export(self, **kw):
        try:
            current = dt.now()
            dateStr = current.strftime("%Y%m%d")
            fileDir = os.path.join(config.get("public_dir"), "report", 'ci', dateStr)
            if not os.path.exists(fileDir):
                os.makedirs(fileDir)
            templatePath = os.path.join(config.get("public_dir"), 'TEMPLATE', "CI_TEMPLATE.xlsx")
            tempFileName = os.path.join(fileDir, "tmp_%s.xlsx" % current.strftime("%Y%m%d%H%M%S"))
            realFileName = os.path.join(fileDir, "inventory_report_%s.xlsx" % current.strftime("%Y%m%d%H%M%S"))
            shutil.copy(templatePath, tempFileName)
            report_xls = InventoryExcel(templatePath=tempFileName, destinationPath=realFileName)
            data = []
            if kw:
                data = self._query_ci_result(kw)
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
            redirect("/cireport/index")

    def _query_ci_result(self, kw):
        warehouses = []
        items = []

        if kw.get("warehouseID", False):
                warehouse = getOr404(Warehouse, kw.get("warehouseID"))
                warehouses = [warehouse]
        else:
            warehouses = Warehouse.get_all()

        if kw.get("item_number", False):
            items = DBSession.query(Item).filter(and_(Item.active == 0,
              Item.__table__.c.item_number.op('ilike')("%%%s%%" % kw["item_number"].strip()))
              ).order_by(Item.categoryID, Item.item_number).all()
        else:
            items = DBSession.query(Item).filter(Item.active == 0).order_by(Item.categoryID, Item.item_number).all()

        data = []
        for w in warehouses:
            for item in items:
                avaQty = item.availableQtyByWarehouse(w.id)
                # print avaQty, item.orderQtyByWarehouse(w.id)
                # inventoryDeficitByWarehouse
                # data.append((w.name, item.item_number, item.category.name, avaQty, avaQty - item.orderQtyByWarehouse(w.id)))
                data.append((w.name, item.item_number, item.category.name, avaQty, item.inventoryDeficitByWarehouse(w.id)))
        return data
