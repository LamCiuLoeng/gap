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
class IrreportController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose("gapproject.templates.report.irreport")
    @tabFocus(tab_type="report")
    def index(self, **kw):
        return {"widget": irReportSearchForm}

    @expose()
    def export(self, **kw):
        try:
            current = dt.now()
            dateStr = current.strftime("%Y%m%d")
            fileDir = os.path.join(config.get("public_dir"), "report", 'ir', dateStr)
            if not os.path.exists(fileDir):
                os.makedirs(fileDir)
            templatePath = os.path.join(config.get("public_dir"), 'TEMPLATE', "IR_TEMPLATE.xlsx")
            tempFileName = os.path.join(fileDir, "tmp_%s.xlsx" % current.strftime("%Y%m%d%H%M%S"))
            realFileName = os.path.join(fileDir, "item_received_report_%s.xlsx" % current.strftime("%Y%m%d%H%M%S"))
            shutil.copy(templatePath, tempFileName)
            report_xls = InventoryExcel(templatePath=tempFileName, destinationPath=realFileName)
            data = []
            if kw:
                rItems = self._query_ir_result(kw)
                for rItem in rItems:
                    data.append((rItem.warehouse.name, rItem.createTime, rItem.item.item_number, rItem.qty, rItem.issuedBy.__unicode__()))
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
            redirect("/irreport/index")

    def _query_ir_result(self, kw):
        conditions = []

        if kw.get("warehouseID", False):
            conditions.append(ReceiveItem.warehouseID == int(kw.get("warehouseID")))
        else:
            conditions.append(ReceiveItem.warehouseID.in_([w.id for w in Warehouse.get_all()]))

        if kw.get("item_number", False):
            conditions.append(Item.__table__.c.item_number.op('ilike')("%%%s%%" % kw["item_number"].strip()))

        obj = DBSession.query(ReceiveItem).join(Item).filter(ReceiveItem.active == 0)
        if len(conditions):
            for value in conditions:
                obj = obj.filter(value)

        return obj.order_by(ReceiveItem.warehouseID, ReceiveItem.itemID, ReceiveItem.createTime).all()
