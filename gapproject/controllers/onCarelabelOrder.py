# -*- coding: utf-8 -*-
from datetime import datetime as dt

import json
import os
import random
import subprocess
import traceback
import urllib2
import zipfile
import zlib
import math
import itertools

# turbogears imports
from tg import expose, redirect, validate, flash, request, response, override_template, config
from tg.decorators import paginate

# third party imports
# from pylons.i18n import ugettext as _
from repoze.what import predicates, authorize
from repoze.what.predicates import not_anonymous, in_any_group, has_permission, \
    in_group

from sqlalchemy.sql import *
import transaction

from reportlab.pdfgen import canvas

# project specific imports
from gapproject.lib.base import BaseController

from gapproject.model import *

from gapproject.util.common import *
from gapproject.widgets import *
from gapproject.widgets.order import *
from gapproject.util.gap_const import *
from gapproject.model.size_label import OnclPrintShop, OnclDivision, \
    OnclCategory, OnclItem, OnclOrderHeader, OnclLabel
import shutil
from gapproject.util.excel_helper import ONCLReport, ONCLOrderExcel
from gapproject.util.label_pdf import gen_pdf
from gapproject.util.mako_filter import tp


class QtyExp(Exception): pass


class OldNavyCarelabelOrderController(BaseController):
    # Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose('gapproject.templates.oncl.tracking')
    @paginate("result", items_per_page = 20)
    @tabFocus(tab_type = "view")
    def tracking(self, **kw):
        cds = [OnclOrderHeader.active == 0,
               ]

        values = {
                  'no' : kw.get('no', ''),
                  'status' : kw.get('status', ''),
                  'printShopId' : kw.get('printShopId', ''),
                  'onclpo' : kw.get('onclpo', ''),
                  'vendorpo' : kw.get('vendorpo', ''),
                  'itemId' : kw.get('itemId', ''),
                  'create_time_start' : kw.get('create_time_start', ''),
                  'create_time_end' : kw.get('create_time_end', ''),
                  }

        if values['no'] : cds.append(OnclOrderHeader.no.like('%%%s%%' % values['no']))
        if values['status'] : cds.append(OnclOrderHeader.status == values['status'])
        if values['printShopId'] : cds.append(OnclOrderHeader.printShopId == values['printShopId'])
        if values['onclpo'] : cds.append(OnclOrderHeader.onclpo.like('%%%s%%' % values['onclpo']))
        if values['vendorpo'] : cds.append(OnclOrderHeader.vendorpo.like('%%%s%%' % values['vendorpo']))
        if values['itemId'] : cds.append(OnclOrderHeader.itemId == values['itemId'])
        if values['create_time_start'] :cds.append(OnclOrderHeader.createTime > values['create_time_start'])
        if values['create_time_end'] :cds.append(OnclOrderHeader.createTime < values['create_time_end'])

        result = DBSession.query(OnclOrderHeader).filter(and_(*cds)).order_by(desc(OnclOrderHeader.id))

        printshops = DBSession.query(OnclPrintShop).filter(and_(OnclPrintShop.active == 0)).order_by(OnclPrintShop.name)

        return {
                'values' : values, 'result' : result,
                'printshops' : printshops, }



    @expose('gapproject.templates.oncl.vieworder')
    @tabFocus(tab_type = "view")
    def viewOrder(self, **kw):
        hid = kw.get('id', None)
        if not hid :
            flash("No ID provides!")
            return redirect('/oncl/tracking')

        try:
            obj = DBSession.query(OnclOrderHeader).filter(and_(OnclOrderHeader.active == 0 , OnclOrderHeader.id == hid)).one()
        except:
            flash("The record does not exist!")
            return redirect('/oncl/tracking')
        else:

            clobj = obj.getLabel()
            if not clobj :
                flash('No related label found for the order!')
                return redirect('/index')

#             cares = CareInstruction.populate( [] if not clobj.care else clobj.care.split( "|" ) )
            cares = {}
            if clobj.care:
                for k, v in json.loads(clobj.care).items():
                    cares[k] = CareInstruction.populate(v)

            warns = Warning.populate([] if not clobj.warning else clobj.warning.split("|"))

            fs = {}
            fibers = DBSession.query(Fiber).filter(and_(Fiber.active == 0))
            for f in fibers : fs[unicode(f.id)] = f

            ss = {}
            sections = DBSession.query(SectionalCallOut).filter(and_(SectionalCallOut.active == 0))
            for s in sections : ss[unicode(s.id)] = s

            coms = []
            if clobj.composition:
                for d in json.loads(clobj.composition):
                    if d['id'] :
                        part = ss[d['id']]
                        tmp = {
                               'E' : part.english_term, 'F' : part.french_canada, 'J' : part.japanese,
                               'C' : part.chinese, 'I' : part.bahasa_indonesia, 'data' : []
                               }
                    else:
                        tmp = {
                               'E' : "", 'F' : "", 'J' : "", 'C' : "", 'I' : "", 'data' : []
                               }
                    for i, p in d['component']:
                        tmp['data'].append({
                                            'E' : fs[i].english_term, 'F' : fs[i].french_canada, 'J' : fs[i].japanese,
                                            'C' : fs[i].chinese, 'I' : fs[i].bahasa_indonesia, 'PERCENTAGE' : p
                                            })
                    coms.append(tmp)

            return {'obj' : obj , 'clobj' : clobj, 'cares' : cares,
                    'warns' : warns, 'coms' : coms,
                    }



    @expose('gapproject.templates.oncl.placeorder')
    @tabFocus(tab_type = "main")
    def placeorder(self, **kw):

        items = DBSession.query(OnclItem).filter(and_(OnclItem.active == 0)).order_by(OnclItem.name)
        locations = DBSession.query(OnclPrintShop).filter(and_(OnclPrintShop.active == 0)).order_by(OnclPrintShop.name)
        divisions = DBSession.query(OnclDivision).filter(and_(OnclDivision.active == 0)).order_by(OnclDivision.name)

        address = DBSession.query(OnclAddress).filter(and_(OnclAddress.active == 0, OnclAddress.issuedById == request.identity['user'].user_id)).order_by(OnclAddress.createTime).all()
        values = {}
        if len(address) > 0 :
            for f in ['shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3',
                      'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax', 'shipEmail', 'shipRemark',
                      'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3',
                      'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax', 'billEmail', 'billRemark'] :
                values[f] = unicode(getattr(address[0], f) or '')
        cos = DBSession.query(Country).filter(and_(Country.active == 0)).order_by(Country.english_term)
        sections = DBSession.query(SectionalCallOut).filter(and_(SectionalCallOut.active == 0)).order_by(SectionalCallOut.english_term)

        return {'locations' : locations , 'divisions' : divisions,
                'items' : items, 'address' : address,
                'values' : values,
                'cos' : cos,
                'sections' : sections,
                'address' : address,
                }


    @expose()
    def saveorder(self, **kw):
        try:
            addressFields = [
                              'shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3', 'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax', 'shipEmail', 'shipRemark',
                              'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3', 'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax', 'billEmail', 'billRemark',
                             ]
            fields = [ 'onclpo', 'vendorpo', 'itemId', 'divisionId', 'categoryId', 'printShopId', 'shipInstructions']
            params = {}
            for f in addressFields: params[f] = kw.get(f, None) or None
            if kw.get('addressID', None) == 'OTHER': DBSession.add(OnclAddress(**params))
            for f in fields: params[f] = kw.get(f, None) or None

            #===================================================================
            # handle the multi size/fie/qty
            #===================================================================
            sizegrp = self._filterAndSorted('sizeId', kw)
            qtygrp = self._filterAndSorted('qty', kw)

            sizeInfo = []
            totalQty = 0
            idcounter = 10
            for (sk, sv), (qk, qv) in zip(sizegrp, qtygrp) :
                if not sv or not qv : continue
                try:
                    qty = int(qv)
                    roundqty = self._roundup(qty)
                except : continue
                totalQty += roundqty
                sizeobj = DBSession.query(OnclSize).get(sv)

                f = unicode(sizeobj.fit_id or '')
                ftext = unicode(sizeobj.fit)  if sizeobj.fit_id else ''

                acturlResult = '$'.join([ sizeobj.us_size, sizeobj.china_size, sizeobj.japan_size,
                                         sizeobj.canada_size, sizeobj.spanish_size, ])
                sizeInfo.append({'ID' : idcounter, 'S' : sv , 'Q' : qty , 'RQ' : roundqty,
                                  'F' : f , 'FIT' : ftext, 'T' : acturlResult,
                                  })
                idcounter += 1
            params['sizeFitQty'] = sizeInfo
            params['totalQty'] = totalQty

            #===================================================================
            # copy the master value into header
            #===================================================================
            if params['itemId']:
                tmp = DBSession.query(OnclItem).get(params['itemId'])
                params['itemCopy'] = ' '.join([tmp.name, tmp.desc])

            if params['divisionId'] : params['divisionCopy'] = unicode(DBSession.query(OnclDivision).get(params['divisionId']))
            if params['categoryId'] : params['categoryCopy'] = unicode(DBSession.query(OnclCategory).get(params['categoryId']))
            if params['printShopId'] : params['printShopCopy'] = unicode(DBSession.query(OnclPrintShop).get(params['printShopId']))


            hdr = OnclOrderHeader(**params)
            DBSession.add(hdr)
            DBSession.flush()
            hdr.no = 'ONCL%s%04d' % (dt.now().strftime("%Y%m%d"), hdr.id)
            hdr.status = ONCL_ORDER_PENDING_APPROVAL

            #===================================================================
            # create the layout object
            #===================================================================
            care_params = {'orderHeader' : hdr}
            care_fields = [ 'coId', 'styleNo', 'colorCode', 'styleDesc', 'ccDesc', 'vendor', 'season', 'manufacture' ]

            for f in care_fields : care_params[f] = kw.get(f, None) or None
            care = {}
            for (prefix, key) in [('care_wash_', 'wash'), ('care_bleach_', 'bleach'), ('care_dry_', 'dry'),
                                    ('care_iron_', 'iron'), ('care_dryclean_', 'dryclean'), ('care_specialcare_', 'specialcare'), ]:
                care[key] = [v for k, v in self._filterAndSorted(prefix, kw) if v and v != 'NOSELECTED']
            care_params['care'] = json.dumps(care)

            warning = self._filterAndSorted('warning', kw)
            warning = [v for k, v in warning if v and v != 'NOSELECTED']
            if not warning : care_params['warning'] = None
            else: care_params['warning'] = '|'.join(warning)

            com = []
            for ck, cv in self._filterAndSorted('com', kw):
#                 if not cv : continue
                t = {'id' : cv , 'component' : []}

                fs = self._filterAndSorted('f%s_' % ck, kw)
                ps = self._filterAndSorted('p%s_' % ck, kw)

                for (fk, fv), (pk, pv) in zip(fs, ps):
                    if not fv or not pv : continue
                    t['component'].append((fv, pv))

                if not cv and not t['component'] : continue
                else : com.append(t)
            care_params['composition'] = json.dumps(com)

            if care_params['coId'] : care_params['coCopy'] = unicode(DBSession.query(Country).get(care_params['coId']))

            obj = OnclLabel(**care_params)
            DBSession.add(obj)
        except:
            transaction.doom()
            traceback.print_exc()
            flash('Error occur on the server side!')
            return redirect('/oncl/placeorder')
        else:
            return redirect('/oncl/gotoEmail?t=new&id=%s' % hdr.id)


    @expose('gapproject.templates.oncl.updateorder')
    @tabFocus(tab_type = "view")
    def updateorder(self, **kw):
        hid = kw.get('id', None)
        if not hid :
            flash('This record does not exist!')
            return redirect('/index')
        obj = DBSession.query(OnclOrderHeader).get(hid)
        if not obj :
            flash('This record does not exist!')
            return redirect('/index')

        clobj = obj.getLabel()
        if not clobj :
            flash('No related label found for the order!')
            return redirect('/index')

#         cares = CareInstruction.populate( [] if not clobj.care else clobj.care.split( "|" ) )
        cares = {}
        if clobj.care:
            for k, v in json.loads(clobj.care).items():
                cares[k] = CareInstruction.populate(v)


        warns = Warning.populate([] if not clobj.warning else clobj.warning.split("|"))

        fs = {}
        fibers = DBSession.query(Fiber).filter(and_(Fiber.active == 0))
        for f in fibers : fs[unicode(f.id)] = f

        ss = {}
        sections = DBSession.query(SectionalCallOut).filter(and_(SectionalCallOut.active == 0))
        for s in sections : ss[unicode(s.id)] = s

        coms = []
        if clobj.composition:
            for d in json.loads(clobj.composition):
                if d['id']:
                    part = ss[d['id']]
                    tmp = {
                           'E' : part.english_term, 'F' : part.french, 'J' : part.japanese,
                           'C' : part.chinese, 'I' : part.bahasa_indonesia, 'data' : []
                           }
                else : tmp = { 'E' : "", 'F' : "", 'J' : "", 'C' : "", 'I' : "", 'data' : [] }
                for i, p in d['component']:
                    tmp['data'].append({
                                        'E' : fs[i].english_term, 'F' : fs[i].french, 'J' : fs[i].japanese,
                                        'C' : fs[i].chinese, 'I' : fs[i].bahasa_indonesia, 'PERCENTAGE' : p
                                        })
                coms.append(tmp)

        #=======================================================================
        # size/fit
        #=======================================================================

        fs = DBSession.query(OnclFit).filter(and_(OnclFit.active == 0, OnclFit.category_id == obj.categoryId)).order_by(OnclFit.name)
        fits = [{'id':f.id, 'name':f.name} for f in fs]

        sizes = []

        for v in obj.sizeFitQty:
            if v['F'] :  # if there's fit
                ss = DBSession.query(OnclSize).filter(and_(OnclSize.active == 0 , OnclSize.fit_id == v['F'])).order_by(OnclSize.us_size)
            else:
                one = DBSession.query(OnclSize).get(v['S'])
                ss = DBSession.query(OnclSize).filter(and_(OnclSize.active == 0 , OnclSize.category_id == one.category_id)).order_by(OnclSize.us_size)
            v['sizerange'] = [{'id' : s.id, 'name' : unicode(s) , 'ref' : '/'.join([s.us_size, s.china_size, s.japan_size])} for s in ss]
            sizes.append(v)
        return {'obj' : obj , 'clobj' : clobj, 'cares' : cares,
                'warns' : warns, 'coms' : coms, 'fits' : fits, 'sizes' : sizes
                }


    @expose()
    def saveupdate(self, **kw):
        hid = kw.get('id', None)
        if not hid :
            flash('This record does not exist!')
            return redirect('/index')
        hdr = DBSession.query(OnclOrderHeader).get(hid)
        if not hdr :
            flash('This record does not exist!')
            return redirect('/index')

        try:
            fields = [
                      'shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3', 'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax', 'shipEmail', 'shipRemark',
                      'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3', 'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax', 'billEmail', 'billRemark',
                      'shipInstructions',
                     ]
            for f in fields : setattr(hdr, f, kw.get(f, None) or None)

            #===================================================================
            # UPDATE FIT/SIZE/QTY
            #===================================================================
            totalQty = 0
            oldsizegrp = self._filterAndSorted('oldSizeId', kw)
            oldqtygrp = self._filterAndSorted('oldQty', kw)
            newsizegrp = self._filterAndSorted('sizeId', kw)
            newqtygrp = self._filterAndSorted('qty', kw)

            sizegrp = itertools.chain(oldsizegrp, newsizegrp)
            qtygrp = itertools.chain(oldqtygrp, newqtygrp)

            sizeInfo = []
            totalQty = 0
            idcounter = 10

            for (sk, sv), (qk, qv) in zip(sizegrp, qtygrp) :
                if not sv or not qv : continue
                try:
                    qty = int(qv)
                    roundqty = self._roundup(qty)
                except : continue
                totalQty += roundqty
                sizeobj = DBSession.query(OnclSize).get(sv)

                f = sizeobj.fit_id or ''
                ftext = unicode(sizeobj.fit)  if sizeobj.fit_id else ''

                acturlResult = '$'.join([ sizeobj.us_size, sizeobj.china_size, sizeobj.japan_size,
                                          sizeobj.canada_size, sizeobj.spanish_size, ])
                sizeInfo.append({'ID' : idcounter, 'S' : sv , 'Q' : qty , 'RQ' : roundqty,
                                  'F' : f , 'FIT' : ftext, 'T' : acturlResult,
                                  })
                idcounter += 1
            hdr.sizeFitQty = sizeInfo
            hdr.totalQty = totalQty

            #===================================================================
            # create the excel and pdf for email
            #===================================================================
            xls = self._genExcel(hdr, hdr.getLabel())
            files = [xls, ]
            pdf = gen_pdf(hdr.id)
            if pdf is None : raise 'Error when creating PDF.'
            else:
                files.append(pdf)
                self._sendEmail(hdr, files)
        except QtyExp as e:
            traceback.print_exc()
            transaction.doom()
            flash('Qty is not correct ,please fill in again.')
            return redirect('/oncl/updateorder?id=%s' % hdr.id)
        except:
            traceback.print_exc()
            transaction.doom()
            flash('Error occur on the server side, please try again later or contact the system administrator.')
        else:
            flash('Update the record successfully!')
        return redirect('/oncl/viewOrder?id=%s' % hdr.id)




    @expose()
    def gotoEmail(self, **kw):
        hdrid = kw.get('id', None)
        t = kw.get('t', 'other')
        hdr = DBSession.query(OnclOrderHeader).get(hdrid)
        if not hdr :
            flash('This record does not exist!')
            return redirect('/oncl/placeorder')

        label = hdr.getLabel()
        if not label:
            flash('This related label is not exist!')
            return redirect('/oncl/placeorder')

        try:
            #===================================================================
            # create the excel and pdf for email
            #===================================================================
            xls = self._genExcel(hdr, label)
            files = [xls, ]
            pdf = gen_pdf(hdr.id)
            if pdf is None : raise 'Error when creating PDF.'
            else:
                files.append(pdf)
                self._sendEmail(hdr, files)
#             self._sendEmail( hdr, files )
        except:
            traceback.print_exc()
            flash('Error occur on the server side!')
            if t == 'new' : hdr.active = 1
            return redirect('/oncl/placeorder')
        else:
            flash('Save the order succesfully!')
            return redirect('/oncl/viewOrder?id=%s' % hdr.id)


    @expose('json')
    def ajaxCategory(self, **kw):
        did = kw.get('did', None)
        if not did : return {'flag' : 0 , 'data' : []}
        try:
            result = DBSession.query(OnclCategory).filter(and_(OnclCategory.active == 0 , OnclCategory.division_id == did)).order_by(OnclCategory.name)
            return {'flag' : 0 , 'data' : [(r.id, unicode(r)) for r in result]}
        except:
            traceback.print_exc()
            return {'flag' : 1 , 'data' : [], 'msg' : 'Error occur on the server side!'}



    def _filterAndSorted(self, prefix, kw):
        return sorted(filter(lambda (k, v): k.startswith(prefix), kw.iteritems()), cmp = lambda x, y:cmp(x[0], y[0]))


    @expose()
    def export(self, **kw):
        cds = [OnclOrderHeader.active == 0,
               ]

        values = {
                  'no' : kw.get('no', ''),
                  'status' : kw.get('status', ''),
                  'printShopId' : kw.get('printShopId', ''),
                  'onclpo' : kw.get('onclpo', ''),
                  'vendorpo' : kw.get('vendorpo', ''),
                  'itemId' : kw.get('itemId', ''),
                  'create_time_start' : kw.get('create_time_start', ''),
                  'create_time_end' : kw.get('create_time_end', ''),
                  }

        if values['no'] : cds.append(OnclOrderHeader.no.like('%%%s%%' % values['no']))
        if values['status'] : cds.append(OnclOrderHeader.status == values['status'])
        if values['printShopId'] : cds.append(OnclOrderHeader.printShopId == values['printShopId'])
        if values['onclpo'] : cds.append(OnclOrderHeader.onclpo.like('%%%s%%' % values['onclpo']))
        if values['vendorpo'] : cds.append(OnclOrderHeader.vendorpo.like('%%%s%%' % values['vendorpo']))
        if values['itemId'] : cds.append(OnclOrderHeader.itemId == values['itemId'])
        if values['create_time_start'] :cds.append(OnclOrderHeader.createTime > values['create_time_start'])
        if values['create_time_end'] :cds.append(OnclOrderHeader.createTime < values['create_time_end'])

        data, isAdminAE = [], in_any_group('Admin', 'AE')
        for h in DBSession.query(OnclOrderHeader).filter(and_(*cds)).order_by(desc(OnclOrderHeader.id)):
            t = [
             h.no, h.onclpo, h.vendorpo, h.item, h.createTime.strftime("%Y-%m-%d"), h.issuedBy,
             h.totalQty, h.printShop, h.showStatus(), h.completeDate, h.courier, h.trackingNo, h.invoice
             ]

            if isAdminAE : t.append(h.amount)
            data.append(map(lambda v : unicode(v or ''), t))
        try:
            templatePath = os.path.join(config.get("public_dir"), "TEMPLATE", "ONCL_REPORT_TEMPLATE.xlsx")
            tempFileName, realFileName = self._getReportFilePath(templatePath)
            sdexcel = ONCLReport(templatePath = tempFileName, destinationPath = realFileName)
            sdexcel.inputData(data , isAdminAE)
            sdexcel.outputData()
        except:
            traceback.print_exc()
            logError()
            if sdexcel:sdexcel.clearData()
            raise ReportGenerationException()
        else:
            return serveFile(realFileName)




    def _getReportFilePath(self, templatePath):
        current = dt.now()
        dateStr = current.strftime("%Y%m%d")
        fileDir = os.path.join(config.get("download_dir"), "oncl", dateStr)
        if not os.path.exists(fileDir): os.makedirs(fileDir)
        tempFileName = os.path.join(fileDir, "%s_%s_%d.xlsx" % (request.identity["user"].user_name,
                                                           current.strftime("%Y%m%d%H%M%S"), random.randint(0, 1000)))
        realFileName = os.path.join(fileDir, "%s_%s.xlsx" % (request.identity["user"].user_name, current.strftime("%Y%m%d%H%M%S")))
        shutil.copy(templatePath, tempFileName)
        return tempFileName, realFileName


    @expose('json')
    def ajaxAction(self, **kw):
        id = kw.get('id', None)
        status = kw.get('status', None)
        if not id or not status :
            return {'code' : 1, 'msg' : 'Not all parameters are provided!'}
        try:
            hdr = DBSession.query(OnclOrderHeader).get(id)
            hdr.status = status
            if status == '2':  # it's complete
                for f in ['courier', 'trackingNo', 'invoice', ]:
                    setattr(hdr, f, kw.get(f, None))
                hdr.completeDate = dt.now().strftime("%Y-%m-%d")
            if status == '0' :  # it's new
                try:
                    price = float(kw.get('price', None))
                except:
                    return {'code' : 2 , 'msg' : 'The parameter(s) are not correct!'}
                else:
                    hdr.price = price
            return {'code' : 0 , 'msg' : 'OK'}
        except:
            traceback.print_exc()
            return {'code' : 1 , 'msg' : 'Error occur on the server side ,please try again.'}



    def _sendEmail(self, hdr , files):
        if not hdr.issuedById : return
        if not hdr.issuedBy.email_address : return

        #=======================================================================
        # 1. send to the user who order the order
        #=======================================================================
        send_from = "r-track@r-pac.com.hk"
        sendTo = hdr.issuedBy.email_address.split(";")
        ccto1 = config.get("oncl_user_cc", '').split(";")
        subject = "JOB NO : %s ,Old Navy PO Number : %s ,%s" % (hdr.no, hdr.onclpo, hdr.createTime.strftime("%Y-%m-%d"))
        if config.get('oncl_is_test', False) :    subject = '[TESTING]' + subject

        templatePath = os.path.join(config.get("public_dir", ''), 'TEMPLATE', "ONCL_EMAIL_TEMPLATE.html")
        template = open(templatePath)
        html = "".join(template.readlines())
        template.close()

        url = '/'.join([config.get('website_url', ''), 'oncl', 'viewOrder?id=%s' % hdr.id ])
        warngmsg = '<p><strong>This order is pending for your approval.</strong></p>'
        content1 = html % (url, hdr.no, hdr.onclpo, hdr.vendorpo, warngmsg)
        advancedSendMail(send_from, sendTo, subject, None, content1, ccto1, files[1:])

        #=======================================================================
        # 2. send to the related print shop
        #=======================================================================
        if hdr.printShopId and hdr.printShop.email:
            sendTo2 = hdr.printShop.email.split(";")
        else:
            sendTo2 = config.get("oncl_printshop_cc", '').split(";")
        ccto2 = config.get("oncl_printshop_cc", '').split(";")

        templatePath2 = os.path.join(config.get("public_dir", ''), 'TEMPLATE', "ONCL_EMAIL_PRINTSHOP_TEMPLATE.html")
        template2 = open(templatePath2)
        html2 = "".join(template2.readlines())
        template2.close()

        content2 = html2 % (url, hdr.no, hdr.onclpo, hdr.vendorpo, '')
        advancedSendMail(send_from, sendTo2, subject, None, content2, ccto2, files)



    def _genExcel(self, hdr, label):
        templatePath = os.path.join(config.get("template_dir"), "GAP_DETAIL_TEMPLATE.xlsx")

        current = dt.now()
        dateStr = current.strftime("%Y%m%d")
        fileDir = os.path.join(config.get("public_dir"), "excel", dateStr)
        if not os.path.exists(fileDir): os.makedirs(fileDir)
        tempFileName = os.path.join(fileDir, "%s_%s_%d.xlsx" % (
                                                                 request.identity["user"].user_name,
                                                           current.strftime("%Y%m%d%H%M%S"), random.randint(0, 1000)))
        realFileName = os.path.join(fileDir, "%s_%s.xlsx" % (hdr.no, current.strftime("%Y%m%d%H%M%S")))
        shutil.copy(templatePath, tempFileName)

        data = { 'createTime' : hdr.createTime.strftime("%Y-%m-%d %H:%M") }
        for f in [ 'no', 'shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3',
                   'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax',
                   'shipEmail', 'shipRemark',
                   'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3',
                   'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax',
                   'billEmail', 'billRemark',
                   'onclpo', 'vendorpo', 'itemCopy', 'printShopCopy', 'divisionCopy', 'categoryCopy', 'shipInstructions' ]:
            data[f] = unicode(getattr(hdr, f) or '')
        data['item'] = "%s (%s)" % (hdr.item, hdr.item.desc) if hdr.itemId else ''

        for f in ['coCopy', 'styleNo', 'colorCode', 'styleDesc', 'ccDesc', 'manufacture', 'season', 'vendor', ]:
            data[f] = unicode(getattr(label, f) or '')

        data['sizeInfo'] = [(v['FIT'], ','.join(v['T'].split("$")), v['RQ']) for v in hdr.sizeFitQty]
        data['sizeInfo'].append(['', 'Total Qty : ', unicode(hdr.totalQty)])

        if label.composition :
            fs = {}
            fibers = DBSession.query(Fiber).filter(and_(Fiber.active == 0))
            for f in fibers : fs[unicode(f.id)] = f

            tmp = []
            com = json.loads(label.composition)
            for index1, _v in enumerate(com) :
                if _v['id'] :
                    term = DBSession.query(SectionalCallOut).get(_v['id'])
                    tmp.append('Garment Part %s  :  %s' % (index1 + 1, "/".join(map(lambda v : v or '', [term.english_term, term.french_canada, term.bahasa_indonesia, term.japanese, term.chinese]))))
                else:
                    tmp.append('Garment Part %s : NONE' % (index1 + 1))
                for index2, (fid, p) in enumerate(_v['component']) :
                    f = fs[fid]
                    tmp.append('    Content %s_%s  :  %s%% - %s' % (index1 + 1 , index2 + 1, p, "/".join(map(lambda v : v or '', [f.english_term, f.french_canada, f.bahasa_indonesia, f.japanese, f.chinese]))))
            data['com'] = '\n'.join(tmp)
        else : data['com'] = ''


        if label.care :
            _c = json.loads(label.care)
            ids = list(itertools.chain(*[_c[f] for f in ['wash', 'bleach', 'dry', 'iron', 'dryclean', 'specialcare']]))

            cinfo = {}
            enc , frc, jpc, chc, ind = [], [], [], [], []
            for c in DBSession.query(CareInstruction).filter(CareInstruction.id.in_(ids)) : cinfo[unicode(c.id)] = c
            for _id in ids :
                c = cinfo[_id]
                if c.english_term : enc.append(c.english_term)
                if c.french_canada : frc.append(c.french_canada)
                if c.bahasa_indonesia : ind.append(c.bahasa_indonesia)
                cn, jp = c.symbols.split("|")
                if cn != '1' and c.chinese : chc.append(c.chinese)

                if c.id == 236 and c.japanese: jpc.append(c.japanese)
                elif jp != '1' and c.japanese : jpc.append(c.japanese)

            data['care'] = '\n'.join(map(lambda l : ' '.join(l), [enc, frc, ind, jpc, chc]))
        else : data['care'] = ''

        if label.warning : data['warn'] = '\n'.join(map(lambda l : ' '.join(l), Warning.populate(label.warning.split('|'))))
        else : data['warn'] = ''

        try:
            sdexcel = ONCLOrderExcel(templatePath = tempFileName, destinationPath = realFileName)
            sdexcel.inputData(data)
            sdexcel.outputData()
            return realFileName
        except Exception, e:
            traceback.print_exc()
            raise e


    @expose()
    def getexcel(self, **kw):
        hid = kw.get('id', None)
        if not hid :
            flash("No ID provided!")
            return redirect('/index')

        hdr = DBSession.query(OnclOrderHeader).get(hid)
        label = hdr.getLabel()
        xls = self._genExcel(hdr, label)
        return serveFile(unicode(xls))



    @expose('json')
    def ajaxLayoutInfo(self, **kw):
        ids, ids2, enc , frc, jpc, chc, ind , cnimgs, jpimgs = [], [], [], [], [], [], [], [], []
        for k in ["care_wash", "care_bleach", "care_dry", "care_iron", "care_dryclean", "care_specialcare"]:
            v = kw.get(k, None)
            if not v : continue
            ids.extend(filter(lambda s: s != 'NOSELECTED', v.split('|')))

        cinfo = {}
        for c in DBSession.query(CareInstruction).filter(and_(CareInstruction.id.in_(ids))): cinfo[unicode(c.id)] = c
        for _id in ids :
            if _id not in cinfo : continue
            c = cinfo[_id]
            enc.append(c.english_term or '')
            frc.append(c.french_canada or '')
            ind.append(c.bahasa_indonesia or '')

            cn, jp = c.symbols.split("|")
            if cn == '1':
                cnimgs.append('%s_ch.jpg' % c.trans_id)
            else:
                chc.append(c.chinese or '')

        #=======================================================================
        # special order for JP symbols
        #=======================================================================
        for k in ["care_wash", "care_bleach", "care_iron", "care_dryclean", "care_dry", "care_specialcare" ]:
            v = kw.get(k, None)
            if not v : continue
            ids2.extend(filter(lambda s: s != 'NOSELECTED', v.split('|')))

        cinfo = {}
        for c in DBSession.query(CareInstruction).filter(and_(CareInstruction.id.in_(ids2))): cinfo[unicode(c.id)] = c
        for _id in ids2 :
            if _id not in cinfo : continue

            if unicode(_id) == '236':
                c = cinfo[_id]
                jpc.append(c.japanese or '')
                c2 = DBSession.query(CareInstruction).get(164)  # special handle
                _, jp = c2.symbols.split("|")
                if jp == '1' : jpimgs.append('164_jp.jpg')
            else:
                c = cinfo[_id]
                cn, jp = c.symbols.split("|")
                if jp == '1':
                    jpimgs.append('%s_jp.jpg' % c.trans_id)
                else:
                    jpc.append(c.japanese or '')

        cares = "<br />".join([" ".join(enc), " ".join(frc), " ".join(ind), " ".join(jpc), " ".join(chc), ])


        wids = kw.get('wids', None)
        wenc , wfrc, wjpc, wchc, wind = [], [], [], [], []
        if wids :
            winfo = {}
            for w in DBSession.query(Warning).filter(and_(Warning.id.in_(wids.split('|')))): winfo[unicode(w.id)] = w

            for _id in wids.split('|'):
                if _id not in winfo : continue
                c = winfo[_id]
                wenc.append(c.english_term or '')
                wfrc.append(c.french_canada or '')
                wind.append(c.bahasa_indonesia or '')
                wjpc.append(c.japanese or '')
                wchc.append(c.chinese or '')
        warngs = "<br />".join([" ".join(wenc), " ".join(wfrc), " ".join(wind), " ".join(wjpc), " ".join(wchc), ])


        coms = kw.get('coms', '')
        composition = []
        if coms:
            for index, com in enumerate(coms.split("|")):
                tmp = []
                ids = com.split(",")
                if ids[0]:
                    term = DBSession.query(SectionalCallOut).get(ids[0])
                    tmp.append('Garment Part %s  :  %s' % (index + 1, "/".join(map(lambda v : v or '', [term.english_term, term.french_canada, term.bahasa_indonesia, term.japanese, term.chinese]))))
                else:
                    tmp.append('Garment Part %s  :  %s' % (index + 1, ''))
                fs = {}
                fibers = DBSession.query(Fiber).filter(and_(Fiber.id.in_(ids[1:])))
                for f in fibers : fs[unicode(f.id)] = f

                _index = 0
                for i in ids[1:]:
                    if i not in fs : continue
                    f = fs[i]
                    tmp.append('Content” %s_%s  :  %s' % (index + 1 , _index + 1, "/".join(map(lambda v : v or '', [f.english_term, f.french_canada, f.bahasa_indonesia, f.japanese, f.chinese]))))
                    _index += 1
                tmp.append('')
                composition.append('<br />'.join(tmp))
        return {'code' : 0 , 'cares' :
                cares, 'warngs' : warngs,
                'composition' : '<br />'.join(composition),
                'cnimgs' : cnimgs, 'jpimgs' : jpimgs,
                }




    @expose('json')
    def ajaxAddress(self, **kw):
        aid = kw.get('addressID', None)
        if not aid : return {'code' : 1 , 'msg' : 'No ID provided!'}

        obj = DBSession.query(OnclAddress).get(aid)
        if not obj : return {'code' : 1 , 'msg' : 'The record does not exist!'}

        result = {'code' : 0}
        for f in ["shipCompany", "shipAttn", "shipAddress", "shipAddress2", "shipAddress3", "shipCity", "shipState",
                  "shipZip", "shipCountry", "shipTel", "shipFax", "shipEmail", "shipRemark",
                  "billCompany", "billAttn", "billAddress", "billAddress2", "billAddress3", "billCity", "billState",
                  "billZip", "billCountry", "billTel", "billFax", "billEmail", "billRemark", ] :
            result[f] = unicode(getattr(obj, f) or '')
        return result



    @expose('json')
    def ajaxSize(self, **kw):
        categoryId = kw.get('categoryId', None)
        if not categoryId : return {'flag' : 1 , 'msg' : 'No catetory ID provided!'}

        fs = DBSession.query(OnclFit).filter(and_(OnclFit.active == 0 , OnclFit.category_id == categoryId)).order_by(OnclFit.name)
        fits = [{'id' : f.id, 'name' : f.name } for f in fs]
        sizes = []
        if len(fits) < 1:
            for s in DBSession.query(OnclSize).filter(and_(OnclSize.active == 0 , OnclSize.category_id == categoryId)).order_by(OnclSize.us_size):
                tmp = {
                       'id' : s.id, 'name' : unicode(s),
                       'ref' : '|'.join(map(unicode, [s.us_size, s.china_size, s.japan_size]))
                       }
                sizes.append(tmp)
        return {'flag' : 0 , 'fits' : fits, 'sizes' : sizes}


    @expose('json')
    def ajaxFit(self, **kw):
        fitId = kw.get('fitId', None)
        if not fitId : return {'flag' : 1 , 'msg' : 'No catetory ID provided!'}
        sizes = []
        ss = DBSession.query(OnclSize).filter(and_(OnclSize.active == 0 , OnclSize.fit_id == fitId)).order_by(OnclSize.us_size)
        for s in ss :
            tmp = {
                       'id' : s.id, 'name' : unicode(s),
                       'ref' : '|'.join(map(unicode, [s.us_size, s.china_size, s.japan_size]))
                       }
            sizes.append(tmp)
        return {'flag' : 0 , 'sizes' : sizes}


    @expose('gapproject.templates.oncl.manage_address')
    @paginate("result", items_per_page = 20)
    @tabFocus(tab_type = "manage_ship_info")
    def manageAddress(self, **kw):
        result = DBSession.query(OnclAddress).filter(and_(OnclAddress.active == 0, OnclAddress.issuedById == request.identity['user'].user_id)).order_by(desc(OnclAddress.createTime))
        return {'result' : result}



    @expose('gapproject.templates.oncl.edit_address')
    @tabFocus(tab_type = "address")
    @tabFocus(tab_type = "manage_ship_info")
    def editAddress(self, **kw):
        _id = kw.get('id', None)
        if not _id :
            flash('No id provided!')
            return redirect('/index')

        obj = DBSession.query(OnclAddress).get(_id)
        values = {'id' : obj.id}
        for f in ['shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3',
                  'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax', 'shipEmail', 'shipRemark',
                  'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3',
                  'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax', 'billEmail', 'billRemark'] :
            values[f] = unicode(getattr(obj, f) or '')
        return {'values' : values}



    @expose()
    def saveAddress(self, **kw):
        _id = kw.get('id', None)
        if not _id :
            flash('No id provided!')
            return redirect('/index')

        fields = ['shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3',
                  'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax', 'shipEmail', 'shipRemark',
                  'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3',
                  'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax', 'billEmail', 'billRemark']

        try:
            obj = DBSession.query(OnclAddress).get(_id)
            for f in fields : setattr(obj, f, kw.get(f, None) or None)

            flash('Save the record successfully!')
        except:
            flash('Error occur on the server side!')
        return redirect('/oncl/manageAddress')


    @expose()
    def delAddress(self, **kw):
        oid = kw.get('id', None)
        if not oid :
            flash('No id provided!')
            return redirect('/index')

        obj = DBSession.query(OnclAddress).get(oid)
        if not obj :
            flash('The record does not exist!')
            return redirect('/index')

        obj.active = 1
        flash('Update the record successfully!')
        return redirect('/oncl/manageAddress')



    def _roundup(self, v):
#        return int( math.ceil( float( v ) / 250 ) * 250 )
        return int(math.ceil(float(v) / 50) * 50)



    def _getDefaultBillShip(self):
        obj = DBSession.query(OnclAddress).filter(and_(OnclAddress.active == 0,
                                                           OnclAddress.issuedById == request.identity['user'].user_id)).first()
        values = {}
        fields = ['shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3',
                  'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax', 'shipEmail', 'shipRemark',
                  'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3',
                  'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax', 'billEmail', 'billRemark']
        for f in fields : values[f] = getattr(obj, f, None) or None
        return values


    @expose("json")
    def ajaxCare(self, **kw):
        try:
            data = {
                    "WASH" : [], "DRY" : [], "IRON" : [], "DRYCLEAN" : [], "SPECIALCARE" : [{'id' : 'NOSELECTED', 'value' : 'NONE'}, ], "BLEACH" : [],
                    }
            cs = DBSession.query(CareInstruction).filter(and_(CareInstruction.active == 0)).order_by(CareInstruction.english_term)
            for c in cs:
                if c.subtype in data: data[c.subtype].append({'id' : c.id, 'value' : unicode(c)})

#            data = [{'id' : c.id, 'value' : unicode( c )} for c in cs]
            return {'code' : 0 , 'data' : data}
        except:
            traceback.print_exc()
            return {'code' : 1}


    @expose("json")
    def ajaxWarn(self, **kw):
        try:
            ws = DBSession.query(Warning).filter(and_(Warning.active == 0)).order_by(Warning.english_term)
            data = [{'id' : c.id, 'value' : unicode(c)} for c in ws]
            return {'code' : 0 , 'data' : data}
        except:
            traceback.print_exc()
            return {'code' : 1}


    @expose("json")
    def ajaxContent(self, **kw):
        try:
            fibers = DBSession.query(Fiber).filter(and_(Fiber.active == 0)).order_by(Fiber.english_term)
            data = [{'id' : c.id, 'value' : unicode(c)} for c in fibers]
            return {'code' : 0 , 'data' : data}
        except:
            traceback.print_exc()
            return {'code' : 1}
