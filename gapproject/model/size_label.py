# -*- coding: utf-8 -*-
"""Sample model module."""
from datetime import datetime as dt
import traceback
import json
from tg import request

from sqlalchemy import *
from sqlalchemy.orm import mapper, relation, backref
from sqlalchemy import Table, ForeignKey, Column
from sqlalchemy.types import Integer, Unicode
# from sqlalchemy.orm import relation, backref
from gapproject.model import DeclarativeBase, DBSession
from gapproject.model.auth import User

from gapproject.util.gap_const import *
from gapproject.model.translation import Country, FitsDescription


__all__ = [
           'ONCL_ORDER_OPEN', 'ONCL_ORDER_PENDING_APPROVAL',
           'ONCL_ORDER_PRINTING', 'ONCL_ORDER_COMPLETE',
           'OnclDivision', 'OnclCategory', 'OnclFit', 'OnclSize',
           'OnclPrintShop', 'OnclItem', 'OnclOrderHeader', 'OnclLabel', 'OnclAddress' ]

# Old Navy Care Labels

ONCL_ORDER_OPEN = 0
ONCL_ORDER_PENDING_APPROVAL = -1
ONCL_ORDER_PRINTING = 1
ONCL_ORDER_COMPLETE = 2
ONCL_ORDER_CANCEL = -2

def getUserID():
    user_id = 1
    try:
        user_id = request.identity['user'].user_id
    except:
        pass
    finally:
        return user_id


# Division ---------------------------
class OnclDivision( DeclarativeBase ):
    __tablename__ = 'oncl_division'

    id = Column( Integer, primary_key = True )
    name = Column( Unicode( 255 ), nullable = False )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ): return self.name
    def __str__( self ): return self.name



# Category ---------------------------
class OnclCategory( DeclarativeBase ):
    __tablename__ = 'oncl_category'

    id = Column( Integer, primary_key = True )
    name = Column( Unicode( 255 ), nullable = False )

    division_id = Column( Integer, ForeignKey( 'oncl_division.id' ) )
    division = relation( OnclDivision, backref = 'categories' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive


    def __unicode__( self ): return self.name
    def __str__( self ): return self.name



# Fit ---------------------------
class OnclFit( DeclarativeBase ):
    __tablename__ = 'oncl_fit'

    id = Column( Integer, primary_key = True )

    category_id = Column( Integer, ForeignKey( 'oncl_category.id' ) )
    category = relation( OnclCategory, backref = 'fits' )

    name = Column( Unicode( 255 ), nullable = False )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ): return self.name
    def __str__( self ): return self.name



# Sizes ---------------------------
class OnclSize( DeclarativeBase ):
    __tablename__ = 'oncl_size'

    id = Column( Integer, primary_key = True )

    category_id = Column( Integer, ForeignKey( 'oncl_category.id' ) )
    category = relation( OnclCategory, backref = 'sizes' )

    fit_id = Column( Integer, ForeignKey( 'oncl_fit.id' ) )
    fit = relation( OnclFit, backref = 'sizes' )

    us_size = Column( Text, nullable = False )
    china_size = Column( Text )
    japan_size = Column( Text )
    canada_size = Column( Text )
    spanish_size = Column( Text )

    order = Column( Integer, default = 100 )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ): return self.us_size
    def __str__( self ): return self.us_size



# Print shop ---------------------------
class OnclPrintShop( DeclarativeBase ):
    __tablename__ = 'oncl_print_shop'

    id = Column( Integer, primary_key = True )
    name = Column( Text, unique = True , nullable = False )
    email = Column( Text )    # multi email split with ","
    telephone = Column( Text )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive


    def __unicode__( self ): return self.name
    def __str__( self ): return self.name



# Items ---------------------------
class OnclItem( DeclarativeBase ):
    __tablename__ = 'oncl_item'

    id = Column( Integer, primary_key = True )
    name = Column( Text, unique = True , nullable = False )
    desc = Column( Text )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ): return self.name
    def __str__( self ): return self.name




# Order Header ---------------------------
class OnclOrderHeader( DeclarativeBase ):
    __tablename__ = 'oncl_order_header'

    id = Column( Integer, primary_key = True )
    no = Column( "no", Text )

    shipCompany = Column( "ship_company", Text, default = None )
    shipAttn = Column( "ship_attn", Text, default = None )
    shipAddress = Column( "ship_address", Text, default = None )
    shipAddress2 = Column( "ship_address2", Text, default = None )
    shipAddress3 = Column( "ship_address3", Text, default = None )
    shipCity = Column( "ship_city", Text, default = None )
    shipState = Column( "ship_state", Text, default = None )
    shipZip = Column( "ship_zip", Text, default = None )
    shipCountry = Column( "ship_country", Text, default = None )
    shipTel = Column( "ship_tel", Text, default = None )
    shipFax = Column( "ship_fax", Text, default = None )
    shipEmail = Column( "ship_email", Text, default = None )
    shipRemark = Column( "ship_remark", Text, default = None )

    billCompany = Column( "bill_company", Text, default = None )
    billAttn = Column( "bill_attn", Text, default = None )
    billAddress = Column( "bill_address", Text, default = None )
    billAddress2 = Column( "bill_address2", Text, default = None )
    billAddress3 = Column( "bill_ddress3", Text, default = None )
    billCity = Column( "bill_city", Text, default = None )
    billState = Column( "bill_state", Text, default = None )
    billZip = Column( "bill_zip", Text, default = None )
    billCountry = Column( "bill_country", Text, default = None )
    billTel = Column( "bill_tel", Text, default = None )
    billFax = Column( "bill_fax", Text, default = None )
    billEmail = Column( "bill_email", Text, default = None )
    billRemark = Column( "bill_remark", Text, default = None )

    onclpo = Column( "onclpo", Text )
    vendorpo = Column( "vendorpo", Text )

    itemId = Column( "item_id", Integer, ForeignKey( 'oncl_item.id' ) )
    item = relation( OnclItem, primaryjoin = OnclItem.id == itemId )
    itemCopy = Column( "item_copy", Text, default = None )

    _sizeFitQty = Column( 'size_fit_qty', Text, default = None )    # json format [{'S' : XX, 'F' : XX, 'Q' : xx ,'T' : KKKK}]  xx is ID or QTY , T is tha actual result
    totalQty = Column( 'total_qty', Integer, default = 0 )

    divisionId = Column( "division_id", Integer, ForeignKey( 'oncl_division.id' ) )
    division = relation( OnclDivision, primaryjoin = OnclDivision.id == divisionId )
    divisionCopy = Column( "division_copy", Text, default = None )

    categoryId = Column( "catory_id", Integer, ForeignKey( 'oncl_category.id' ) )
    category = relation( OnclCategory, primaryjoin = OnclCategory.id == categoryId )
    categoryCopy = Column( "category_copy", Text, default = None )

    printShopId = Column( "print_shop_id", Integer, ForeignKey( 'oncl_print_shop.id' ) )
    printShop = relation( OnclPrintShop, primaryjoin = OnclPrintShop.id == printShopId )
    printShopCopy = Column( "print_shop_copy", Text, default = None )

    courier = Column( "courier", Text )
    trackingNo = Column( "tracking_no", Text )
    invoice = Column( "invoice", Text )
    completeDate = Column( "complete_date", Text )
    price = Column( 'price', Numeric( 15, 2 ), default = None )
    status = Column( "status", Integer, default = ONCL_ORDER_OPEN )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( "active", Integer, default = 0 )    # 0: active, 1: inactive


    shipInstructions = Column( "ship_instructions", Text )

    def __unicode__( self ): return self.no
    def __str__( self ): return self.no

    def showStatus( self ):
        return {
         ONCL_ORDER_OPEN : 'Open',
         ONCL_ORDER_PENDING_APPROVAL : 'Pending quote approval',
         ONCL_ORDER_PRINTING : 'Printing',
         ONCL_ORDER_COMPLETE : 'Completed',
         ONCL_ORDER_CANCEL : 'Cancelled',
         }.get( self.status, '' )


    def getLabel( self ):
        try:
            obj = DBSession.query( OnclLabel ).filter( and_( OnclLabel.active == 0 ,
                                                             OnclLabel.orderHeaderId == self.id ) ).order_by( desc( OnclLabel.id ) ).first()
        except:
            traceback.print_exc()
            obj = None
        return obj



    def getSizeFitQty( self ):
        if not self._sizeFitQty : return []
        return json.loads( self._sizeFitQty )

    def setSizeFitQty( self, v ):
        if not v : self._sizeFitQty = None
        self._sizeFitQty = json.dumps( v )

    sizeFitQty = property( fget = getSizeFitQty, fset = setSizeFitQty )


    @property
    def amount( self ):
        try:
            return '%.2f' % ( self.price * self.totalQty )
        except:
            return ''



# label fiber and component ---------------------------
class OnclLabel( DeclarativeBase ):
    __tablename__ = 'oncl_label'

    id = Column( Integer, primary_key = True )
    orderHeaderId = Column( "order_header_id", Integer, ForeignKey( 'oncl_order_header.id' ) )
    orderHeader = relation( OnclOrderHeader, primaryjoin = orderHeaderId == OnclOrderHeader.id )

    composition = Column( "composition", Text, default = None )    # it's a json text ,[{'id' : XXX, 'component' : [(xx,40),(xx,60)]},]
    care = Column( "care", Text, default = None )    # ids seperated by '|'
#     co = Column( Text, default = None )

    coId = Column( "co_id", Integer, ForeignKey( 'trans_country.id' ) )
    co = relation( Country, primaryjoin = coId == Country.id )
    coCopy = Column( "co_copy", Text, default = None )

    warning = Column( "warning", Text, default = None )    # ids seperated by '|'

    styleNo = Column( "style_no", Text, default = None )
    colorCode = Column( "color_code", Text, default = None )
    styleDesc = Column( "style_desc", Text, default = None )
    ccDesc = Column( "cc_desc", Text, default = None )
    manufacture = Column( "manufacture", Text, default = None )
    season = Column( "season", Text, default = None )
    vendor = Column( "vendor", Text, default = None )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( "active", Integer, default = 0 )    # 0: active, 1: inactive



class OnclAddress( DeclarativeBase ):
    __tablename__ = 'oncl_address'

    id = Column( Integer, primary_key = True )
    shipCompany = Column( "ship_company", Text, default = None )
    shipAttn = Column( "ship_attn", Text, default = None )
    shipAddress = Column( "ship_address", Text, default = None )
    shipAddress2 = Column( "ship_address2", Text, default = None )
    shipAddress3 = Column( "ship_address3", Text, default = None )
    shipCity = Column( "ship_city", Text, default = None )
    shipState = Column( "ship_state", Text, default = None )
    shipZip = Column( "ship_zip", Text, default = None )
    shipCountry = Column( "ship_country", Text, default = None )
    shipTel = Column( "ship_tel", Text, default = None )
    shipFax = Column( "ship_fax", Text, default = None )
    shipEmail = Column( "ship_email", Text, default = None )
    shipRemark = Column( "ship_remark", Text, default = None )

    billCompany = Column( "bill_company", Text, default = None )
    billAttn = Column( "bill_attn", Text, default = None )
    billAddress = Column( "bill_address", Text, default = None )
    billAddress2 = Column( "bill_address2", Text, default = None )
    billAddress3 = Column( "bill_ddress3", Text, default = None )
    billCity = Column( "bill_city", Text, default = None )
    billState = Column( "bill_state", Text, default = None )
    billZip = Column( "bill_zip", Text, default = None )
    billCountry = Column( "bill_country", Text, default = None )
    billTel = Column( "bill_tel", Text, default = None )
    billFax = Column( "bill_fax", Text, default = None )
    billEmail = Column( "bill_email", Text, default = None )
    billRemark = Column( "bill_remark", Text, default = None )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive
