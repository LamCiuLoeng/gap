# -*- coding: utf-8 -*-
from datetime import datetime as dt

import json
import os
import random
import subprocess
import time
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

from gapproject.util.excel_helper import *
from gapproject.util.common import *
from gapproject.widgets import *
from gapproject.widgets.order import *
from gapproject.util.gap_const import *

class ImportOrderController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()
    
    @expose('gapproject.templates.importOrder.index')
    @tabFocus(tab_type="main")
    def index(self, **kw):
        vendors = User.get_vendors()
        
        return dict(vendors = vendors)

    @expose('gapproject.templates.importOrder.index')
    @tabFocus(tab_type="main")
    def handleImport(self, **kw):
        result=[]
        try:
            def is_number(s):
                try:
                    float(s)
                except ValueError:
                    return False
                
                return True
            
            if kw.has_key("filePath"):
                excelFile=kw["filePath"]
                data=excelFile.file.read()
                targetDir=os.path.join(os.path.abspath(os.path.curdir), "Excel_upload/%s"%request.identity["user"].user_name)
                if not os.path.exists(targetDir):
                    os.makedirs(targetDir)
    
                targetFileName=os.path.join(targetDir,
                                                "%s_%s.xls"%(request.identity["user"].user_name, Date2Text(dateTimeFormat="%Y%m%d%H%M%S" , defaultNow=True)))
    
                f=open(targetFileName, 'wb')
                f.write(data)
                f.close()
    
                er=ExcelReader(targetFileName)
                try:
                    er.setSheet(0)
                    data=er.getDataByRange()
                except:
                    traceback.print_exc()
                finally:
                    er.close()
                
                import_datas = []
                region = None
                region_name = data[1][0].strip()
                bill_company = data[3][0].strip()
                ship_company = data[3][6].strip()
                index_offset = 0
                bill_address = data[4][0].strip()
                ship_address = data[4][6].strip()
                
                for cust_index in range(5, 11, 1):
                    if len(data[cust_index][0]) > 0:
                        bill_address += '\n' + data[cust_index][0].strip()
                    else:
                        index_offset = cust_index
                    
                    if len(data[cust_index][6]) > 0:
                        ship_address += '\n' + data[cust_index][6].strip()
                    else:
                        index_offset = cust_index
                
                order_date_list = data[index_offset][8].strip().split("-")
                
#                print '*' * 20, '\n', order_date_list

#                order_date = dt.now() #'-'.join([order_date_list[2], order_date_list[0], order_date_list[1]])#time.strptime(data[index_offset][8], '%m/%d/%Y')
                bill_attn = data[index_offset + 1][3].strip()
                vendor_po = int(float(data[index_offset + 1][8].strip())) if is_number(data[index_offset + 1][8].strip()) else data[index_offset + 1][8].strip()
                bill_tel = int(float(data[index_offset + 2][3].strip())) if is_number(data[index_offset + 2][3].strip()) else data[index_offset + 2][3].strip()
                ship_attn = data[index_offset + 2][8].strip()
                bill_fax = int(float(data[index_offset + 3][3].strip())) if is_number(data[index_offset + 3][3].strip()) else data[index_offset + 3][3].strip()
                bill_email = data[index_offset + 3][8].strip()
                issued_by = data[index_offset + 4][3].strip()
                ship_email = data[index_offset + 4][8].strip()
    #            pvdn = data[index_offset + 5][3]
                ship_tel = int(float(data[index_offset + 5][8].strip())) if is_number(data[index_offset + 5][8].strip()) else data[index_offset + 5][8].strip()
                ship_fax = int(float(data[index_offset + 6][8].strip())) if is_number(data[index_offset + 6][8].strip()) else data[index_offset + 6][8].strip()
                
                latest_order = OrderInfoHeader.latest_order()
                today = dt.today()
                dailySequence = 1
                
                if latest_order is not None and \
                   latest_order.issuedDate.month == today.month and \
                   latest_order.issuedDate.day == today.day:
                    dailySequence = latest_order.dailySequence + 1
                
                for region_idx in ['CHINA', 'KOREA', 'INDIA', 'USA']:
                    if region_idx in region_name.upper():
                        region = DBSession.query(Region).filter(Region.name.op('ILIKE')("%%%s%%" % region_idx)).first()
                
                order_hdr = OrderInfoHeader(orderNO = ''.join(['GAP',
                                                               dt.now().strftime("%Y%m%d"),
                                                               '%05d' % dailySequence
                                                               ]),
                                            orderDate = dt.now(),
                                            vendorPO = vendor_po,
                                            billCompany = bill_company,
                                            billAddress = bill_address,
                                            billAttn = bill_attn,
                                            billTel = bill_tel,
                                            billFax = bill_fax,
                                            billEmail = bill_email,
                                            shipCompany = ship_company,
                                            shipAddress = ship_address,
                                            shipAttn = ship_attn,
                                            shipTel = ship_tel,
                                            shipFax = ship_fax,
                                            shipEmail = ship_email,
                                            shippedDate = dt.now(),
                                            region = region,
                                            issuedDate = dt.now(),
                                            dailySequence = dailySequence,
                                            issuedBy=DBSession.query(User).get(kw['vendor']) if 'vendor' in kw.keys() and kw['vendor'] else None,
                                            lastModifyTime = dt.now())
                
                import_datas.append(order_hdr)
                
                integer_flag = True
                
                for item_idx in range(index_offset + 9, len(data) - 1):
                    if int(float(data[item_idx][0].strip())) % 250 != 0:
                        integer_flag = False
                        break
                    else:
                        item = Item.get_item_by_name(data[item_idx][1].strip())
                        price = Price.get_price(region.id, item.id)
                        
                        order_dtl = OrderInfoDetail(header = order_hdr,
                                                    item = item,
                                                    price = price,
                                                    qty = int(float(data[item_idx][0].strip())))
                        
                        import_datas.append(order_dtl)
    
                if integer_flag:
                    DBSession.begin(subtransactions=True)
                    try:
                        DBSession.add_all(import_datas)
                        DBSession.commit()
                        
                        result.append(order_hdr)
                        
                        flash("The order has been import!")
                    except:
                        DBSession.rollback()
                        file = open('log.txt', 'w')
                        traceback.print_exc(None, file)
                        file.close()
                        flash("There are some errors occurred during importing data!")
                else:
                    flash("There are some quantity errors in template file, please update it and import again!")
        except:
            file = open('log.txt', 'w')
            traceback.print_exc(None, file)
            file.close()
            flash("Some errors occurred when importing data!")
        return dict(
                    import_result = result,
                    vendors= User.get_vendors()
                    )
