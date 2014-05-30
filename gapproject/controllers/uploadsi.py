# -*- coding: utf-8 -*-
import traceback
import urllib
import os
import shutil
import random
import time
from datetime import datetime as dt

import pythoncom
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


class UploadSiController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose('gapproject.templates.uploadsi.index')
    @paginate('collections', items_per_page=25)
    @tabFocus(tab_type="main")
    def index(self, **kw):
        try:
            search_form = uploadSiSearchForm

            if kw:
                result = self._query_result(kw)
                return dict(search_form=search_form, collections=result, values=kw, return_url='/')
            else:
                return dict(search_form=search_form, collections=[], values={}, return_url='/',)
        except:
            flash("The service is not avaiable now,please try it later.", status="warn")
            traceback.print_exc()
            redirect('/')

    @expose('gapproject.templates.uploadsi.view')
    @tabFocus(tab_type="main")
    def view(self, **kw):

        siHeader = getOr404(UploadSiHeader, kw.get('ushid'))
        sdetails = siHeader.details(type=0)
        fdetails = siHeader.details(type=1)
        return {"header": siHeader, "sdetails": sdetails, 'fdetails': fdetails}

    @expose('gapproject.templates.uploadsi.new')
    @tabFocus(tab_type="main")
    def new(self, **kw):
        return {}

    #  @20120620 for upload si report to create shipment
    @expose('')
    @tabFocus(tab_type="main")
    def createShip(self, **kw):
        if request.method != 'POST' or not hasattr(kw.get('sifile'), 'file'):
            redirect('/uploadsi/new')
        data = kw.get('sifile').file.read()
        if len(data) > 1048576:  # 1M
            flash("File must be less than 1MB!", "warn")
            redirect('/uploadsi/new')
        ush = DBSession.query(UploadSiHeader).filter(and_(UploadSiHeader.active == 0,
            UploadSiHeader.filename == kw.get('sifile').filename)).first()
        if ush:
            flash("This file already uploaded!", "warn")
            redirect('/uploadsi/new')

        current = dt.now()
        dateStr = current.strftime("%Y%m%d")
        timeStr = current.strftime("%Y%m%d%H%M%S")
        fileDir = os.path.join(config.get("public_dir"), "uploadsireport", dateStr)
        if not os.path.exists(fileDir):
            os.makedirs(fileDir)
        sifile = kw.get('sifile')
        filename, ext = os.path.splitext(sifile.filename)
        newFilename = '%s%s' % (timeStr, ext)
        savefile = os.path.join(fileDir, newFilename)
        with open(savefile, 'wb') as f:
            f.write(data)
        try:
            pythoncom.CoInitialize()
            xls = DispatchEx("Excel.Application")
            # print dir(xls)
            xls.Visible = 0
            xls.DisplayAlerts = 0
            wb = xls.Workbooks.open(savefile)
            sheet = wb.Sheets[0]
            rows = sheet.UsedRange.Rows

            fields = ['InvoiceNo.', 'SONo.', 'SOOtherRef', 'InvoiceIssueDate', 'DeliveryDate', 'Remark', 'ItemCode', 'InvoiceQty']
            values = ['invoiceNo', 'internalPO', 'rpacNo', 'invoiceDate', 'shipDate', 'remark', 'itemCode', 'shipQty']
            positions = {}
            fieldDict = dict(zip(fields, values))
            # print fieldDict
            siHeader = UploadSiHeader()
            siHeader.filename = '%s%s' % (filename, ext)
            siHeader.filepath = '/uploadsireport/%s/%s' % (dateStr, newFilename)
            siHeader.issuedBy = request.identity["user"]
            siHeader.lastModifyBy = request.identity["user"]
            # DBSession.add(siHeader)
            # DBSession.flush()
            for index, row in enumerate(rows):
                # print row.Value[0]
                tmpRow = [r.strip() if isinstance(r, basestring) else r for r in row.Value[0]]
                if not positions:
                    tmp = self._strFilter(tmpRow[0])
                    if tmp in fields:
                        listRow = [self._strFilter(v) for v in tmpRow]
                        for field in fields:
                            positions[fieldDict.get(field)] = listRow.index(field)
                        continue
                    else:
                        continue

                invoiceNo = tmpRow[positions.get('invoiceNo')]
                internalPO = tmpRow[positions.get('internalPO')]
                rpacNo = tmpRow[positions.get('rpacNo')]
                invoiceDate = self._time2date(tmpRow[positions.get('invoiceDate')])
                strInvoiceDate = Date2Text(invoiceDate, '%d-%m-%Y')
                # print Date2Text(dt.fromtimestamp((int(invoiceDate))), '%d-%m-%Y')
                # print strInvoiceDate
                strShipDate = tmpRow[positions.get('shipDate')] if tmpRow[positions.get('shipDate')] else ''
                shipDate = self._str2date(strShipDate.split(',')[0])
                remark = tmpRow[positions.get('remark')]
                itemCode = tmpRow[positions.get('itemCode')]
                shipQty = self._str2Int(tmpRow[positions.get('shipQty')])
                # invoiceAmount = row.Value[0][42]
                # if rpacNo == 'GAP2012052900003':
                #     print 'index', 'invoiceNo', 'internalPO', 'rpacNo', 'shipDate', 'itemCode', 'shipQty', 'invoiceAmount'
                #     print index, invoiceNo, internalPO, rpacNo, shipDate, itemCode, shipQty, invoiceAmount
                #     break
                siDetail = UploadSiDetail()
                siDetail.orderNO = rpacNo
                siDetail.itemNumber = itemCode
                siDetail.invoiceNumber = invoiceNo
                siDetail.internalPO = internalPO
                if isinstance(shipQty, int):
                    siDetail.shipQty = shipQty
                siDetail.invoiceDate = strInvoiceDate
                siDetail.deliveryDate = strShipDate
                siDetail.header = siHeader
                siDetail.issuedBy = request.identity["user"]
                siDetail.lastModifyBy = request.identity["user"]
                siDetail.type = 1

                # check duplicate
                tmpSiDetail = DBSession.query(UploadSiDetail).filter(and_(UploadSiDetail.type == 0, UploadSiDetail.active == 0,
                    UploadSiDetail.orderNO == rpacNo, UploadSiDetail.itemNumber == itemCode,
                    UploadSiDetail.invoiceNumber == invoiceNo, UploadSiDetail.internalPO == internalPO,
                    UploadSiDetail.shipQty == shipQty, UploadSiDetail.deliveryDate == strShipDate)).first()
                # print '*************** %s' % tmpSiDetail
                if tmpSiDetail or not invoiceNo or not rpacNo or not strShipDate or not itemCode \
                    or not isinstance(shipQty, int) or shipQty < 1 or not strInvoiceDate:
                    DBSession.add(siDetail)
                    DBSession.flush()
                    # print '-----------'
                    continue

                # order detail
                oDetail = OrderInfoDetail.getByItem(itemCode, rpacNo)

                if oDetail:
                    orderHeader = oDetail.header
                    warehouse = orderHeader.region.region_warehouse[0]
                    if shipQty <= (oDetail.qty - oDetail.qtyShipped) \
                        and shipQty <= oDetail.item.availableQtyByWarehouse(warehouse.id):

                        shipItem = ShipItem()
                        shipItem.qty = shipQty
                        shipItem.internalPO = internalPO
                        shipItem.item = oDetail.item
                        shipItem.warehouse = warehouse
                        shipItem.orderID = orderHeader.id
                        shipItem.orderDetail = oDetail
                        shipItem.createTime = shipDate
                        shipItem.invoiceDate = invoiceDate
                        shipItem.issuedBy = request.identity["user"]
                        shipItem.lastModifyBy = request.identity["user"]
                        # query ship header
                        shipHeader = ShipItemHeader.getBySi(invoiceNo, orderHeader.id, '%s%s' % (filename, ext))
                        if not shipHeader:
                            shipHeader = ShipItemHeader()
                            shipHeader.no = 'SHI%s' % dt.now().strftime('%Y%m%d')
                            shipHeader.invoiceNumber = invoiceNo
                            # shipHeader.remark = remark
                            shipHeader.filename = '%s%s' % (filename, ext)
                            shipHeader.filepath = '/uploadsireport/%s/%s' % (dateStr, newFilename)
                            shipHeader.warehouse = warehouse
                            shipHeader.orderHeader = orderHeader
                            shipHeader.createTime = shipDate
                            shipHeader.issuedBy = request.identity["user"]
                            shipHeader.lastModifyBy = request.identity["user"]
                            DBSession.add(shipHeader)
                            DBSession.flush()
                            shipHeader.no = '%s%05d' % (shipHeader.no, shipHeader.id)
                        # else:
                        #     shipHeader.remark = '  '.join(shipHeader.remark, remark) if shipHeader.remark else remark
                        shipHeader.remark = remark
                        shipItem.header = shipHeader
                        siDetail.type = 0
                        DBSession.add(shipItem)
                        DBSession.flush()
                        if orderHeader.is_shipped_complete:
                            orderHeader.status = SHIPPED_COMPLETE
                        else:
                            orderHeader.status = SHIPPED_PART
                DBSession.add(siDetail)
                DBSession.flush()
        except:
            transaction.doom()
            traceback.print_exc()
            flash("The service is not avaiable now!", "warn")
            redirect('/uploadsi/new')
        else:
            DBSession.flush()
            # print siHeader.id
            if siHeader.id:
                flash("Upload Successfully!")
                redirect('/uploadsi/view?ushid=%s' % siHeader.id)
            else:
                flash("The excel format is wrong!")
                redirect('/uploadsi/new')
        finally:
            if wb:
                wb.Close(SaveChanges=0)
            if xls:
                xls.Quit()

    def _str2Int(self, _str):
        try:
            _int = int(_str)
        except:
            _int = _str
        finally:
            return _int

    def _strFilter(self, _str):
        if isinstance(_str, basestring):
            return _str.strip().replace(' ', '')
        else:
            return _str

    def _str2date(self, strdate):
        newdate = None
        try:
            newdate = dt.strptime(strdate[0:10], "%d/%m/%Y")
        except:
            pass
        return newdate

    def _time2date(self, strtime):
        newdate = None
        try:
            newdate = dt.fromtimestamp((int(strtime)))
        except:
            pass
        return newdate

    def _query_result(self, kw):
        try:
            conditions = []

            if kw.get("createStartDate", False) and kw.get("createEndDate", False):
                b_date = dt.strptime(kw.get("createStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                e_date = dt.strptime(kw.get("createEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
                conditions.append(UploadSiHeader.createTime >= b_date)
                conditions.append(UploadSiHeader.createTime <= e_date)
            elif kw.get("createStartDate", False):
                b_date = dt.strptime(kw.get("createStartDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                conditions.append(UploadSiHeader.createTime >= b_date)
            elif kw.get("createEndDate", False):
                e_date = dt.strptime(kw.get("createEndDate", '2009-12-1200:00:00') + "23:59:59", "%Y-%m-%d%H:%M:%S")
                conditions.append(UploadSiHeader.createTime <= e_date)

            if len(conditions):
                uploadsi = DBSession.query(UploadSiHeader).filter(UploadSiHeader.active == 0)

                for condition in conditions:
                    uploadsi = uploadsi.filter(condition)

                result = uploadsi.order_by(desc(UploadSiHeader.id)).all()
            else:
                result = DBSession.query(UploadSiHeader).order_by(desc(UploadSiHeader.id)).all()

            return result
        except:
            traceback.print_exc()
