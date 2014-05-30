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

# turbogears imports
from tg import expose, redirect, validate, flash, request, response, override_template, config
from tg.decorators import paginate

# third party imports
#from pylons.i18n import ugettext as _
from repoze.what import predicates, authorize
from repoze.what.predicates import not_anonymous, in_group, has_permission

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


#class OrderViewController(BaseController):
#    
#    @expose('gapproject.templates.order.order_form_view_export')
#    @tabFocus(tab_type="main")
#    def view(self, **kw):
#        (flag, id)=rpacDecrypt(kw.get("code", ""))
#
#        if not flag:
#            flash("Please don't access the resource illegally!")
#            redirect('/order/index')
#
#        order_header=getOr404(OrderInfoHeader, id)
#        duration = dt.now() - order_header.orderDate
#        
#        def got_value(order_detail):
#            return order_detail.price.price * order_detail.qty
#        
#        total_value = reduce(lambda x, y: x + y, map(got_value, order_header.order_details))
#        
#        if duration.days > 1:
#            can_update = False
#        else:
#            can_update = True
#
#        if len(order_header.order_details)<1 :
#            flash("There's no order related to this PO!", "warn")
#            redirect('/order/index')
#
#        return {"order_header": order_header,
#                "order_details": order_header.order_details,
#                'total_value': total_value,
#                "can_update": can_update,
#                'return_url': '/',
#                }

class CarelabelOrderController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose('gapproject.templates.carelabel.order_form')
    @tabFocus(tab_type="main")
    def index(self, **kw):
        try:
            billtos = DBSession.query(BillTo).all()
            shiptos = DBSession.query(ShipTo).all()
#            categorys = Category.get_categorys()
            first_order = CLOrderHeader.first_order(request.identity["user"].user_id)
            
            return {'first_order': first_order,
                    'billTos': billtos,
                    'shipTos': shiptos,
                    "return_url": '/',
                   }
        except:
            file=open('log.txt', 'w')
            traceback.print_exc(None, file)
            file.close()
            flash("The service is not avaiable now!", "warn")
            redirect('/')
    
    @expose()
    def save(self, **kw):
        order_detail_inputs = {}
        new_orders = []

        for k in kw:
            if k.endswith("_ext"):
                name, index, ext = k.split("_")
                    
                if index not in order_detail_inputs:
                    if kw[k] and len(kw[k]) > 0:
                        order_detail_inputs[index] = {name: kw[k]}
                    else:
                        flash("the order information is not complete!", "warn")
                        redirect("/order/index")
                else:
                    if kw[k] and len(kw[k]) > 0:
                        order_detail_inputs[index][name] = kw[k]
                    else:
                        flash("the order infromation is not complete!", "warn")
                        redirect("/order/index")
        
        try:    
            latest_order = CLOrderHeader.latest_order()
            today = dt.today()
            
            if latest_order is not None and latest_order.issuedDate.month == today.month and latest_order.issuedDate.day == today.day:
                dailySequence = latest_order.dailySequence + 1
            else:
                dailySequence = 1
            
            if 'x' in order_detail_inputs.keys():
                order_detail_inputs.pop('x')
            
            order_header_params = {'orderNO': ''.join(['GAP',
                                                       dt.now().strftime("%Y%m%d"),
                                                       '%05d' % dailySequence
                                                       ]),
                                   'buyerPO': None,
                                   'vendorPO': None,
                                   #'billCompany': None,
                                   'billAddress': None,
                                   'billAttn': None,
                                   'billTel': None,
                                   'billFax': None,
                                   'billEmail': None,
                                   #'shipCompany': None,
                                   'shipAddress': None,
                                   'shipAttn': None,
                                   'shipTel': None,
                                   'shipFax': None,
                                   'shipEmail': None,
                                   'contact': None,
                                   'remark': None,
                                   'dailySequence': dailySequence,
                                   'shipInstruction': None,
                                   'orderDate': None,
                                   'styleNo': None,
                                   'styleName': None,
                                   'division': None,
                                   'countryOfOrigin': None,
                                   'issuedDate': dt.now(),
                                   'issuedBy': request.identity["user"],
                                   'lastModifyTime': dt.now(),
                                   'lastModifyBy': request.identity['user'],
                                   }
            
            for key in order_header_params.iterkeys():
                if key in kw and kw[key]:
                    order_header_params[key] = kw[key]
            
            if 'shipCompany' in kw.keys() and kw['shipCompany']:
                shipto = DBSession.query(ShipTo).get(kw['shipCompany'])
                order_header_params['shipCompany'] = shipto.company
            
            if 'billCompany' in kw.keys() and kw['billCompany']:
                billto = DBSession.query(BillTo).get(kw['billCompany'])
                order_header_params['billCompany'] = billto.company
            
            if 'otherInstruction' in kw and kw['otherInstruction']:
                order_header_params['shipInstruction'] = kw['otherInstruction']
            
            order_header = CLOrderHeader(**order_header_params)
            
            new_orders.append(order_header)
            
            str_order_details = sorted(order_detail_inputs.items(), key = lambda x: x[0])
            for str_order_detail in str_order_details:
                item_no = str_order_detail[1]['clitem']
                item = CarelabelItem.get_item(item_no)
                order_detail = CLOrderDetail(header = order_header,
                                             item = item,
                                             size = str_order_detail[1]['clsize'],
#                                             articleDesc = str_order_detail[1]['artdesc'],
                                             qty = int(str_order_detail[1]['quantity'])
                                             )

                new_orders.append(order_detail)

            DBSession.add_all(new_orders)
            DBSession.flush()

            sendTo = [request.identity["user"].email_address]
            ccTo = config.gap_email_cc.split(";")

            self._sendNotifyEmail(sendTo, ccTo, order_header.orderNO, order_header.id)
        except:
            transaction.doom()
            file = open('log.txt', 'w')
            traceback.print_exc(None, file)
            file.close()
            flash("The service is not avaiable now!", "warn")
            redirect('/carelabel/index')

        redirect("/carelabel/view?code=%s"%(rpacEncrypt(order_header.id)))
    
    def _sendNotifyEmail(self, sendTo, ccTo, customerPO, hederID, content=None, attach=[], title=None):
        sendFrom="r-pac-GAP-ordering-system"
        if title:
            subject=title
        else:
            subject="Order[%s] has been confirmed successfully!"%customerPO
        if content :
            text=content
        else:
            text="\n".join([
                    "Thank you for your confirmation!", "You could view the order's detail information via the link below:",
                    "%s/carelabel/view?code=%s"%(config.website_url, rpacEncrypt(hederID)),
                    "\n\n************************************************************************************",
                    "This e-mail is sent by the r-pac GAP ordering system automatically.",
                    "Please don't reply this e-mail directly!",
                    "************************************************************************************"
                    ])

        sendEmail(sendFrom, sendTo, subject, text, ccTo, attach)
    
    @expose('gapproject.templates.carelabel.order_form_view')
    @tabFocus(tab_type="main")
    def view(self, **kw):
        (flag, id)=rpacDecrypt(kw.get("code", ""))

        if not flag:
            flash("Please don't access the resource illegally!")
            redirect('/carelabel/index')
            
        try:
            order_header=getOr404(CLOrderHeader, id)
            duration = dt.now() - order_header.orderDate
            
            def got_value(order_detail):
                return 0.3 * order_detail.qty
            
            total_value = reduce(lambda x, y: x + y, map(got_value, order_header.order_details))
            
            if duration.days > 1:
                can_update = False
            else:
                can_update = True
    
            if len(order_header.order_details)<1 :
                flash("There's no order related to this PO!", "warn")
                redirect('/order/index')
            
            return {"order_header": order_header,
                    "order_details": order_header.order_details,
                    "can_update": can_update,
                    "total_value": int(total_value),
                    'return_url': '/',
                    }
        except:
            file = open('log.txt', 'w')
            traceback.print_exc(None, file)
            file.close()
            flash("The order could not view!", "warn")
            redirect('/carelabel/index')
    
    @expose('gapproject.templates.order.search')
    @paginate('collections', items_per_page=25)
    @tabFocus(tab_type="view")
    def search(self, **kw):
        try:
            search_form = orderSearchFormInstance

            if kw:
                result = self._query_result(kw)

                return dict(search_form = search_form,
                            collections = result,
                            values = kw,
                            return_url = '/',
                            )
            else:
                return dict(search_form = search_form,
                            collections = [],
                            values = {},
                            return_url = '/',
                            )
        except:
            flash("The service is not avaiable now,please try it later.", status="warn")
            traceback.print_exc()
            redirect('/')

    def _query_result(self, kw):
        try:
            conditions = []

            if kw.get("orderNO", False):
                conditions.append(OrderInfoHeader.orderNO == kw.get("orderNO", ""))
                
            if kw.get("orderDate", False):
                b_date = dt.strptime(kw.get("orderDate", '2009-12-1200:00:00') + "00:00:00", "%Y-%m-%d%H:%M:%S")
                
                conditions.append(OrderInfoHeader.orderDate >= b_date)
            
            if kw.get("vendorPO", False):
                conditions.append(OrderInfoHeader.vendorPO.op("ILIKE")("%%%s%%" % kw.get("vendorPO", "").strip()))
            
            if kw.get("item_no", False):
                item = DBSession.query(Item)\
                                .filter(Item.item_number == kw.get("item_no", "").strip())\
                                .first()
                dtlHeaderIDs = DBSession.query(OrderInfoDetail.headerID).filter(OrderInfoDetail.itemID == item.id).all()
                conditions.append(OrderInfoHeader.id.in_([id[0] for id in dtlHeaderIDs]))

            if len(conditions):
                order = DBSession.query(OrderInfoHeader).filter(OrderInfoHeader.status != 0)

                for condition in conditions:
                    order = order.filter(condition)

                if in_group("AE") or in_group("Admin"):
                    result = order.order_by(desc(OrderInfoHeader.orderDate)).all()
                else:
                    result = order.filter(OrderInfoHeader.issuedBy == request.identity['user'])\
                                    .order_by(desc(OrderInfoHeader.orderDate)).all()
            else:
                if in_group("AE") or in_group("Admin"):
                    result=DBSession.query(OrderInfoHeader)\
                                    .filter(OrderInfoHeader.status != 0)\
                                    .order_by(desc(OrderInfoHeader.orderDate))\
                                    .all()
                else:
                    result=DBSession.query(OrderInfoHeader)\
                                    .filter(OrderInfoHeader.status != 0)\
                                    .filter(OrderInfoHeader.issuedBy == request.identity['user'])\
                                    .order_by(desc(OrderInfoHeader.orderDate))\
                                    .all()

            return result
        except:
            traceback.print_exc()
    
    @expose('gapproject.templates.order.order_form_update')
    @tabFocus(tab_type="main")
    def updateOrder(self, **kw):
        (flag, id)=rpacDecrypt(kw.get("code", ""))

        if not flag:
            flash("Please don't access the resource illegally!")
            redirect('/')

        order = getOr404(OrderInfoHeader, id)

        if len(order.order_details) < 1:
            flash("There's no order related to this PO!", "warn")
            redirect('/')

        return {"order_header": order,
                "order_details": order.order_details,
                'return_url': '/',
                }
    
    @expose()
    def saveUpdate(self, **kw):
        DBSession.begin(subtransactions=True)
        
        try:
            new_orders = []
            order = DBSession.query(OrderInfoHeader).get(kw['order_id'])
            order_header_fields = ['invoiceNO',
                                   'invoiceTotal',
                                   'shippedDate',
                                   ]
            order_header_params = {'lastModifyTime': dt.now(),
                                   'lastModifyBy': request.identity['user'],
                                   'status': 1 # order updated
                                   }
            
            for key in order_header_fields:
                if key in kw and kw[key]:
                    order_header_params[key] = kw[key]
            
            for key, val in order_header_params.iteritems():
                if key in dir(order):
                    setattr(order, key, val)
            
            if order.invoiceNO is not None and len(order.invoiceNO) > 0:
                order.status = 2 # order completed
            
            DBSession.add(order)
            
            sendTo = [request.identity["user"].email_address, order.region.regionMailAddress]
            ccTo = config.gap_email_cc.split(";")
            
            for contact in order.region.region_contacts:
                ccTo.append(contact.email)
            self._sendNotifyEmail(sendTo, ccTo, order.orderNO, order.id, title = "Order[%s] has been completed successfully!" % order.orderNO)

            DBSession.commit()
        except:
            DBSession.rollback()
            file = open('log.txt', 'w')
            traceback.print_exc(None, file)
            file.close()
            flash("The service is not avaiable now!", "warn")
            raise
        else:
            flash("The manual order has been confirmed successfully!")
        redirect("/order/view?code=%s"%(rpacEncrypt(order.id)))

    @expose('gapproject.templates.order.order_form_update_vendor')
    @tabFocus(tab_type="main")
    def vendorUpdate(self, **kw):
        (flag, id)=rpacDecrypt(kw.get("code", ""))

        if not flag:
            flash("Please don't access the resource illegally!")
            redirect('/')

        order = getOr404(OrderInfoHeader, id)
        duration = dt.now() - order.orderDate

        if order.status >= SHIPPED_PART:  # @20120528
            flash("The order is shipping!")
            redirect('/')

        if duration.days > 1:
            flash("The order was created more than 24 hours and can not be modified!")
            redirect('/')

        if len(order.order_details) < 1:
            flash("There's no order related to this PO!", "warn")
            redirect('/')

        return {"order": order,
                "order_details": order.order_details,
                'return_url': '/',
                }
    
    @expose()
    def saveVendorUpdate(self, **kw):
        DBSession.begin(subtransactions=True)
        
        try:
            new_orders = []
            order_detail_inputs = {}
            order = DBSession.query(OrderInfoHeader).get(kw['order_id'])
            order_header_params = {'buyerPO': None,
                                   'vendorPO': None,
                                   'billCompany': None,
                                   'billAddress': None,
                                   'billAttn': None,
                                   'billTel': None,
                                   'billFax': None,
                                   'billEmail': None,
                                   'shipCompany': None,
                                   'shipAddress': None,
                                   'shipAttn': None,
                                   'shipTel': None,
                                   'shipFax': None,
                                   'shipEmail': None,
                                   'contact': None,
                                   'remark': None,
                                   'shipInstruction': None,
                                   'orderDate': None,
                                   'lastModifyTime': dt.now(),
                                   'lastModifyBy': request.identity['user'],
                                   }
            
            for key in order_header_params.iterkeys():
                if key in kw and kw[key]:
                    order_header_params[key] = kw[key]
            
            if 'otherInstruction' in kw and kw['otherInstruction']:
                order_header_params['shipInstruction'] = kw['otherInstruction']
            
            for key, val in order_header_params.iteritems():
                if key in dir(order):
                    setattr(order, key, val)
            
            new_orders.append(order)
            
            for k in kw:
                if k.startswith("quantity_"):
                    order_detail = OrderInfoDetail.get_detail(int(k.split("_")[1]))
                    
                    if order_detail.qty != int(kw[k]):
                        order_detail.qty = int(kw[k])
                        new_orders.append(order_detail)
            
            for k in kw:
                if k.endswith("_ext"):
                    name, index, ext = k.split("_")
                        
                    if index not in order_detail_inputs:
                        if kw[k] and len(kw[k]) > 0:
                            order_detail_inputs[index] = {name: kw[k]}
                        else:
                            flash("the order information is not complete!", "warn")
                            raise redirect("/order/index")
                    else:
                        if kw[k] and len(kw[k]) > 0:
                            order_detail_inputs[index][name] = kw[k]
                        else:
                            flash("the order infromation is not complete!", "warn")
                            raise redirect("/order/index")
            
            for detail in order.order_details:
                if str(detail.id) in order_detail_inputs.keys():
                    if detail.item.item_number == order_detail_inputs[str(detail.id)]['item']:
                        if str(detail.qty) != order_detail_inputs[str(detail.id)]['quantity']:
                            detail.qty = int(order_detail_inputs[str(detail.id)]['quantity'])
                            
                            new_orders.append(detail)
                    else:
                        detail.item = OrderInfoDetail.get_item(order_detail_inputs[str(detail.id)]['item'])
                        detail.price = Price.get_price(oder.region.id, detail.item.id)
                        
                        new_orders.append(detail)
            
#            for key_val in order_detail_inputs.keys():
#                if int(key_val) not in [detail.id for detail in order.order_details]:
#                    print '*' * 20, '\n', key_val
#                    item = OrderInfoDetail.get_item(order_detail_inputs[key_val]['item'])
#                    price = Price.get_price(order.region.id,
#                                            OrderInfoDetail.get_item(order_detail_inputs[key_val]['item']).id)
#                    detail = OrderInfoDetail(header = order,
#                                             item = item,
#                                             price = price,
#                                             qty = int(order_detail_inputs[key_val]['quantity'])
#                                             )
#                    
#                    new_orders.append(detail)
            
            DBSession.add_all(new_orders)
            
            sendTo = [request.identity["user"].email_address, order.region.regionMailAddress]
            ccTo = config.gap_email_cc.split(";")
            
            for contact in order.region.region_contacts:
                ccTo.append(contact.email)
            self._sendNotifyEmail(sendTo, ccTo, order.orderNO, order.id, title = "Order[%s] has been revised successfully!" % order.orderNO)

            DBSession.commit()
        except:
            DBSession.rollback()
            file = open('log.txt', 'w')
            traceback.print_exc(None, file)
            file.close()
            flash("The service is not avaiable now!", "warn")
            raise
        # else:
        #     # Reserve Item
        #     DBSession.flush()
        #     try:
        #         warehouse = order.region.region_warehouse[0]
        #         reserveItemQty = 0
        #         details = order.order_details
        #         for d in details:
        #             availableQty = d.item.availableQtyByWarehouse(warehouse.id)
        #             DBSession.query(ReserveItem).filter(and_(ReserveItem.orderDetailID == d.id,
        #                 ReserveItem.active == 0)).update({ReserveItem.active: 1})
        #             DBSession.flush()
        #             if availableQty >= d.qty:
        #                 reserveItem = ReserveItem()
        #                 reserveItem.qty = d.qty
        #                 reserveItem.item = d.item
        #                 reserveItem.warehouse = warehouse
        #                 reserveItem.orderID = order.id
        #                 reserveItem.orderDetail = d
        #                 reserveItem.issuedBy = request.identity["user"]
        #                 reserveItem.lastModifyBy = request.identity["user"]
        #                 DBSession.add(reserveItem)
        #                 DBSession.flush()
        #                 reserveItemQty += 1
        #         if reserveItemQty <= 0:
        #             order.status = RESERVED_FAIL
        #         elif reserveItemQty > 0 and reserveItemQty < len(details):
        #             order.status = PARTIAL_RESERVED_SUCCESS
        #         elif reserveItemQty > 0 and reserveItemQty == len(details):
        #             order.status = ALL_RESERVED_SUCCESS
        #     except:
        #         transaction.doom()
        #         traceback.print_exc()
        flash("The manual order has been confirmed successfully!")
        redirect("/order/view?code=%s"%(rpacEncrypt(order.id)))

    @expose()
    def getAjaxField(self, **kw):
        try:
            fieldName = kw["fieldName"]
            value = kw["q"]
            result = []

            if fieldName == 'clitem_detail':
                rs = DBSession.query(CarelabelItem) \
                    .filter(CarelabelItem.item_number.op('ILIKE')('%%%s%%'%str(value).strip())) \
                    .filter(CarelabelItem.active == 0) \
                    .all()
                
                result = ["%s|%.2f" % (i.item_number, i.price * 1000) for i in rs]
            else:
                result = []

            data = "\n".join(result)

            return data
        except:
            traceback.print_exc()

    @expose('json')
    def ajaxItemInfo(self, **kw):
        try:
            item_no = kw.get("item_no", False)
            item = DBSession.query(Item) \
                    .filter(Item.item_number == item_no.strip()) \
                    .filter(Item.active == 0) \
                    .first()
            price = DBSession.query(Price) \
                    .filter(Price.itemID == item.id) \
                    .filter(Price.regionID == int(kw.get("region_id", False))) \
                    .first()
                    
            result = {'width': item.width if len(item.width) > 0 else '',
                                 'length': item.length if len(item.length) > 0 else '',
                                 'gusset': item.gusset if len(item.gusset) > 0 else '',
                                 'lip': item.lip if len(item.lip) > 0 else '',
                                 'price': price.price
                                 }
            
            return result
        except:
            traceback.print_exc()
    
    @expose()
    @tabFocus(tab_type="main")
    def cancel(self, **kw):
        (flag, id) = rpacDecrypt(kw.get("code", ""))
        
        if not flag:
            flash("Please don't access the resource illegally!")
            redirect('/')

        ph = getOr404(OrderInfoHeader, id)

        if len(ph.order_details) < 1:
            flash("There's no order related to this PO!", "warn")
            redirect('/')

        try:
            ph.status = 0

            DBSession.add(ph)
            # if ph.order_reserve_item:
            #     DBSession.query(ReserveItem).filter(and_(ReserveItem.id.in_([r.id for r in ph.order_reserve_item]),
            #             ReserveItem.active == 0)).update({ReserveItem.active: 1})
            flash("The order has been canceled successfully!")
        except:
            traceback.print_exc()
            flash("There's an error occured during cancel this order!")
        redirect('/')
    
    @expose()
    def exportPDFFile(self, **kw):
        
        try:
            order = OrderInfoHeader.get_order(kw['id'])
            pdf_file = os.path.join(config.download_dir, '%s.pdf' % order.orderNO)
            phantomjs = os.path.join(config.public_dir, 'phantomjs', 'phantomjs.exe')
            rasterize = os.path.join(config.public_dir, 'phantomjs', 'rasterize.js')
            http_url = 'http://%s/viewOrder/view?code=%s' % (request.headers.get('Host'), rpacEncrypt(order.id))
            print '*'*20, '\n', phantomjs, '\n', rasterize, '\n', http_url, '\n', pdf_file
            cmd = '%s %s %s %s' % (phantomjs, rasterize, http_url, pdf_file)
            sp = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            
            while 1:
                if sp.poll() is not None:
                    #print 'exec command completed.'
                    break
                else:
                    line = sp.stdout.readline().strip() 
            
            pd_zip_file = os.path.join(config.download_dir, "gap_%s%d.zip" % (dt.now().strftime("%Y%m%d%H%M%S"), random.randint(1, 1000)))
            out_zip_file = zipfile.ZipFile(pd_zip_file, "w", zlib.DEFLATED)
            
            out_zip_file.write(os.path.abspath(os.path.join(config.download_dir, '%s.pdf' % order.orderNO)), os.path.basename(os.path.join(config.download_dir, '%s.pdf' % order.orderNO)))
            out_zip_file.close()
            
#            try:
#                os.remove(pdf_file)
#            except:
#                pass
            
            return (serveFile(unicode(pd_zip_file)), pd_zip_file)
        except:
            file = open('log.txt', 'w')
            traceback.print_exc(None, file)
            file.close()