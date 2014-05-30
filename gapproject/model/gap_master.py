# -*- coding: utf-8 -*-
"""Sample model module."""
from datetime import datetime as dt

from sqlalchemy import *
from sqlalchemy.orm import mapper, relation, backref
from sqlalchemy import Table, ForeignKey, Column
from sqlalchemy.types import Integer, Unicode
# from sqlalchemy.orm import relation, backref
from sqlalchemy.sql.functions import sum, max, min

from gapproject.model import DeclarativeBase, metadata, DBSession
from gapproject.model.auth import User

from gapproject.util.gap_const import *


__all__ = ['Category',
           'Item',
           'Region',
           'Price',
           'Contact',
           'Warehouse',
           'BillTo',
           'ShipTo',
           'Inventory',
           'WarehouseHistory',
           'OrderInfoHeader',
           'OrderInfoDetail',
           'ReceiveItemHeader',
           'ReceiveItem',
           'ShipItemHeader',
           'ShipItem',
           'StockAdjustmentHeader',
           'StockAdjustmentDetail',
           'SafetyStock',
           'ReserveItem',
           'UploadSiHeader',
           'UploadSiDetail',
           'CarelabelItem',
           'CLOrderHeader',
           'CLOrderDetail',
           ]

class Category( DeclarativeBase ):
    __tablename__ = 'gap_category'

    # { Columns

    id = Column( Integer, primary_key = True )
    name = Column( Unicode( 255 ), nullable = False )
    description = Column( Unicode( 1000 ), nullable = False )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    # }

    def __unicode__( self ):
        return self.name

    def __str__( self ):
        return self.name

    @classmethod
    def get_categorys( cls ):
        return DBSession.query( cls ).filter( cls.active == 0 ).order_by( cls.name ).all()

    @classmethod
    def get_category( cls, id ):
        return DBSession.query( cls ).get( id )

class Item( DeclarativeBase ):
    __tablename__ = 'gap_item'

    # { Columns

    id = Column( Integer, primary_key = True )
    item_number = Column( Unicode( 255 ), nullable = False )
    description = Column( Unicode( 1000 ), nullable = False )
    width = Column( Unicode( 50 ) )
    length = Column( Unicode( 50 ) )
    gusset = Column( Unicode( 50 ) )
    lip = Column( Unicode( 50 ) )
    categoryID = Column( "category_id", Integer, ForeignKey( 'gap_category.id' ) )
    category = relation( Category, backref = 'category_items' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    # }

    def __unicode__( self ):
        return self.item_number

    @classmethod
    def get_items( cls ):
        return DBSession.query( cls ).filter( cls.active == 0 ).order_by( cls.item_number ).all()

    @classmethod
    def get_item( cls, id ):
        return DBSession.query( cls ).get( id )

    @classmethod
    def get_item_by_name( cls, item_no ):
        return DBSession.query( cls ).filter( cls.item_number == item_no ).first()

    @property
    def inventoryQty( self ):
        return DBSession.query( sum( Inventory.qty ) ).filter( and_( 
            Inventory.active == 0, Inventory.itemID == self.id ) ).first()[0] or 0

    @property
    def shippedQty( self ):
        return DBSession.query( sum( WarehouseHistory.qty ) ).filter( and_( 
            WarehouseHistory.active == 0, WarehouseHistory.type == 'shipped',
            WarehouseHistory.itemID == self.id ) ).first()[0] or 0

    # for new design ---------------------------------------------------
    def reservedQtyByWarehouse( self, warehouseID, date = None ):

        obj = DBSession.query( sum( ReserveItem.qty ) ).filter( and_( 
            ReserveItem.active == 0, ReserveItem.itemID == self.id,
            ReserveItem.warehouseID == warehouseID ) )
        if date:
            obj = obj.filter( ReserveItem.createTime <= date )
        return obj.first()[0] or 0

    def shippedQtyByWarehouse( self, warehouseID, date = None ):
        obj = DBSession.query( sum( ShipItem.qty ) ).filter( and_( 
            ShipItem.active == 0, ShipItem.itemID == self.id,
            ShipItem.warehouseID == warehouseID ) )
        if date:
            obj = obj.filter( ShipItem.createTime <= date )
        return obj.first()[0] or 0

    def receivedQtyByWarehouse( self, warehouseID, date = None ):
        obj = DBSession.query( sum( ReceiveItem.qty ) ).filter( and_( 
            ReceiveItem.active == 0, ReceiveItem.itemID == self.id,
            ReceiveItem.warehouseID == warehouseID ) )
        if date:
            obj = obj.filter( ReceiveItem.createTime <= date )
        return obj.first()[0] or 0

    def stockAdjustmentByWarehouse( self, warehouseID, date = None ):
        addQty = self._adjQty( warehouseID, 'ADD', date )
        lessQty = self._adjQty( warehouseID, 'LESS', date )
        return addQty - lessQty

    def _adjQty( self, warehouseID, type, date = None ):
        obj = DBSession.query( sum( StockAdjustmentDetail.qty ) ).filter( and_( 
            StockAdjustmentDetail.active == 0, StockAdjustmentDetail.itemID == self.id,
            StockAdjustmentDetail.warehouseID == warehouseID, StockAdjustmentDetail.type == type.upper(),
            StockAdjustmentDetail.status == 'approved'.upper() ) )
        if date:
            obj = obj.filter( StockAdjustmentDetail.createTime <= date )
        return obj.first()[0] or 0

    def onHandQtyByWarehouse( self, warehouseID, date = None ):
        return self.receivedQtyByWarehouse( warehouseID, date ) + self.stockAdjustmentByWarehouse( warehouseID, date )

    def availableQtyByWarehouse( self, warehouseID, date = None ):
        # return self.onHandQtyByWarehouse(warehouseID, date) - self.reservedQtyByWarehouse(warehouseID, date)
        # @20120718
        return self.onHandQtyByWarehouse( warehouseID, date ) - self.shippedQtyByWarehouse( warehouseID, date )

    def orderQtyByWarehouse( self, warehouseID, date = None ):
        warehouse = DBSession.query( Warehouse ).get( warehouseID )
        region = warehouse.region
        obj = DBSession.query( sum( OrderInfoDetail.qty ) ).join( OrderInfoHeader ).filter( and_( 
            OrderInfoHeader.regionID == region.id, OrderInfoHeader.status > CANCEL,
            OrderInfoDetail.itemID == self.id ) )
        if date:
            obj = obj.filter( OrderInfoHeader.orderDate <= date )
        return obj.first()[0] or 0

    def inventoryDeficitByWarehouse( self, warehouseID, date = None ):
        return self.onHandQtyByWarehouse( warehouseID, date ) - self.orderQtyByWarehouse( warehouseID, date )

    def totalReceivedQty( self ):
        return DBSession.query( sum( ReceiveItem.qty ) ).filter( and_( 
            ReceiveItem.active == 0, ReceiveItem.itemID == self.id ) ).first()[0] or 0

    def totalStockAdjustment( self ):
        addQty = DBSession.query( sum( StockAdjustmentDetail.qty ) ).filter( and_( 
            StockAdjustmentDetail.active == 0, StockAdjustmentDetail.itemID == self.id,
            StockAdjustmentDetail.type == 'ADD', StockAdjustmentDetail.status == 'approved'.upper() ) ).first()[0] or 0
        lessQty = DBSession.query( sum( StockAdjustmentDetail.qty ) ).filter( and_( 
            StockAdjustmentDetail.active == 0, StockAdjustmentDetail.itemID == self.id,
            StockAdjustmentDetail.type == 'LESS', StockAdjustmentDetail.status == 'approved'.upper() ) ).first()[0] or 0
        return addQty - lessQty

    def totalReservedQty( self ):
        return DBSession.query( sum( ReserveItem.qty ) ).filter( and_( 
            ReserveItem.active == 0, ReserveItem.itemID == self.id ) ).first()[0] or 0

    def totalShippedQty( self ):
        return DBSession.query( sum( ShipItem.qty ) ).filter( and_( 
            ShipItem.active == 0, ShipItem.itemID == self.id ) ).first()[0] or 0

    def totalOnHandQty( self ):
        return self.totalReceivedQty() + self.totalStockAdjustment()

    def totalAvailableQty( self ):
        # return self.totalOnHandQty() - self.totalReservedQty()
        return self.totalOnHandQty() - self.totalShippedQty()

    def getPrice( self, regionID ):
        return Price.get_price( regionID, self.id ).price



class Region( DeclarativeBase ):
    __tablename__ = 'gap_region'

    # { Columns

    id = Column( Integer, primary_key = True )
    name = Column( Unicode( 255 ), nullable = False )
    description = Column( Unicode( 1000 ), nullable = False )
    regionMailAddress = Column( "region_mail_address", Unicode( 1000 ) )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    # }

    def __unicode__( self ):
        return self.name

    @classmethod
    def get_region( cls, id ):
        return DBSession.query( cls ).get( id )

    @classmethod
    def get_regions( cls ):
        return DBSession.query( cls ).filter( cls.active == 0 ).order_by( cls.id ).all()

class Price( DeclarativeBase ):
    __tablename__ = 'gap_price'

    # { Columns

    id = Column( Integer, primary_key = True )
    price = Column( Float, nullable = False )
    regionID = Column( "region_id", Integer, ForeignKey( 'gap_region.id' ) )
    region = relation( Region, backref = "region_price" )
    itemID = Column( "item_id", Integer, ForeignKey( 'gap_item.id' ) )
    item = relation( Item, backref = 'item_price' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    # }

    def __unicode__( self ):
        return str( self.price )

    @classmethod
    def get_price( cls, regionID, itemID ):
        return DBSession.query( cls ).filter( cls.regionID == regionID ).filter( 
            cls.itemID == itemID ).filter( cls.active == 0 ).first()

class Contact( DeclarativeBase ):
    __tablename__ = "gap_contact"

   # { Columns

    id = Column( Integer, primary_key = True )
    regionID = Column( "region_id", Integer, ForeignKey( "gap_region.id" ) )
    region = relation( Region, backref = "region_contacts" )
    name = Column( "name", Unicode( 50 ) )
    email = Column( "email", Unicode( 100 ) )
    phone = Column( "phone", Unicode( 50 ) )
    address = Column( "address", Unicode( 1000 ) )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    # }

    def __unicode__( self ): return self.name

    @classmethod
    def get_contacts_by_region( cls, regionID ):
        return DBSession.query( cls ).filter( cls.regionID == regionID ).order_by( cls.name ).all()

    @classmethod
    def get_contact( cls, id ):
        return DBSession.query( cls ).get( id )

    def is_active( self ):
        if self.active == 0:
            return True
        else:
            return False

class Warehouse( DeclarativeBase ):
    __tablename__ = "gap_warehouse"

    id = Column( Integer, primary_key = True )
    name = Column( Unicode( 255 ), nullable = False )
    description = Column( Unicode( 1000 ), nullable = False )
    regionID = Column( "region_id", Integer, ForeignKey( "gap_region.id" ) )
    region = relation( Region, backref = "region_warehouse" )

    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )

    def __unicode__( self ): return self.name

    def __str__( self ): return self.name

    @classmethod
    def get_all( cls ):
        return DBSession.query( cls ).filter( cls.active == 0 ).order_by( cls.name ).all()


class BillTo( DeclarativeBase ):
    __tablename__ = "gap_bill_to"

    id = Column( Integer, primary_key = True )
    customerID = Column( "customer_id", Integer, ForeignKey( "tg_user.user_id" ) )
    customer = relation( User, primaryjoin = customerID == User.user_id, backref = "user_billtos" )
    company = Column( "company", Unicode( 100 ) )
    address = Column( "address", Unicode( 200 ) )
    attn = Column( "attn", Unicode( 50 ) )
    tel = Column( "tel", Unicode( 50 ) )
    fax = Column( "fax", Unicode( 50 ) )
    email = Column( "email", Unicode( 100 ) )
    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive
    is_default = Column( "is_default", Integer, default = 0 )

    def __unicode__( self ):
        return self.company

    @classmethod
    def default_billto( cls, customerID ):
        return DBSession.query( cls ). \
            filter( cls.customerID == customerID ). \
            filter( cls.active == 0 ). \
            filter( cls.is_default == 0 ). \
            first()

class ShipTo( DeclarativeBase ):
    __tablename__ = "gap_ship_to"

    id = Column( Integer, primary_key = True )
    customerID = Column( "customer_id", Integer, ForeignKey( "tg_user.user_id" ) )
    customer = relation( User, primaryjoin = customerID == User.user_id, backref = "user_shiptos" )
    company = Column( "company", Unicode( 100 ) )
    address = Column( "address", Unicode( 200 ) )
    attn = Column( "attn", Unicode( 50 ) )
    tel = Column( "tel", Unicode( 50 ) )
    fax = Column( "fax", Unicode( 50 ) )
    email = Column( "email", Unicode( 100 ) )
    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive
    is_default = Column( "is_default", Integer, default = 0 )

    def __unicode__( self ):
        return self.company

    @classmethod
    def default_shipto( cls, customerID ):
        return DBSession.query( cls ). \
            filter( cls.customerID == customerID ). \
            filter( cls.active == 0 ). \
            filter( cls.is_default == 0 ). \
            first()


# for order
class OrderInfoHeader( DeclarativeBase ):
    __tablename__ = 'gap_order_header'

    # { Columns

    id = Column( Integer, primary_key = True )
    orderNO = Column( "order_no", Unicode( 50 ) )
    orderDate = Column( "order_date", DateTime, default = dt.now )
    buyerPO = Column( "buyer_po", Unicode( 50 ) )
    vendorPO = Column( "vendor_po", Unicode( 50 ) )
    billCompany = Column( "bill_company", Unicode( 100 ) )
    billAddress = Column( "bill_address", Unicode( 200 ) )
    billAttn = Column( "bill_attn", Unicode( 50 ) )
    billTel = Column( "bill_tel", Unicode( 50 ) )
    billFax = Column( "bill_fax", Unicode( 50 ) )
    billEmail = Column( "bill_email", Unicode( 50 ) )
    shipCompany = Column( "ship_company", Unicode( 100 ) )
    shipAddress = Column( "ship_address", Unicode( 200 ) )
    shipAttn = Column( "ship_attn", Unicode( 50 ) )
    shipTel = Column( "ship_tel", Unicode( 50 ) )
    shipFax = Column( "ship_fax", Unicode( 50 ) )
    shipEmail = Column( "ship_email", Unicode( 50 ) )
    remark = Column( Unicode( 1000 ) )
    shippedDate = Column( "shipped_date", DateTime )
    contactID = Column( "contact_id", Integer, ForeignKey( 'gap_contact.id' ) )
    contact = relation( Contact, backref = 'order_contact' )
    regionID = Column( "region_id", Integer, ForeignKey( 'gap_region.id' ) )
    region = relation( Region, backref = 'order_region' )
    invoiceNO = Column( "invoice_no", Unicode( 50 ) )
    invoiceTotal = Column( "invoice_total", Float )
    dailySequence = Column( "daily_sequence", Integer )
    shipInstruction = Column( "ship_instruction", Unicode( 1000 ) )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    issuedDate = Column( "issued_date", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )

    status = Column( "status", Integer, default = 1 )    # util/gap_const.py

    # }

    def __unicode__( self ):
        return self.orderNO

    def total_qty( self ):
        return DBSession.query( sum( OrderInfoDetail.qty ) ).\
                filter( OrderInfoDetail.id.in_( [item.id for item in self.order_details] ) ).first()[0]

    @classmethod
    def latest_order( cls ):
        return DBSession.query( cls ).filter( cls.id == DBSession.query( max( cls.id ) ).first()[0] ).first()

    @classmethod
    def get_order( cls, id ):
        return DBSession.query( cls ).get( id )

    @classmethod
    def first_order( cls, user_id ):
        return DBSession.query( cls ).filter( cls.id == DBSession.query( max( cls.id ) ).filter( cls.issuedById == user_id ).first()[0] ).first()

    @property
    def is_all_reserve_success( self ):
        is_all_success = True
        for d in self.order_details:
            if d.qty != d.qtyReserved:
                is_all_success = False
                break
        return is_all_success

    @property
    def is_reserve_fail( self ):
        fail = True
        for d in self.order_details:
            if d.qtyReserved > 0:
                fail = False
                break
        return fail

    @property
    def is_shipped_complete( self ):
        is_complete = True
        for d in self.order_details:
            if d.qty != d.qtyShipped:
                is_complete = False
                break
        return is_complete


class OrderInfoDetail( DeclarativeBase ):
    __tablename__ = 'gap_order_detail'

    # { Columns

    id = Column( Integer, primary_key = True )
    headerID = Column( "header_id", Integer, ForeignKey( 'gap_order_header.id' ) )
    header = relation( OrderInfoHeader, backref = backref( 'order_details', order_by = id ) )
    itemID = Column( "item_id", Integer, ForeignKey( 'gap_item.id' ) )
    item = relation( Item, backref = 'order_item' )
    priceID = Column( "price_id", Integer, ForeignKey( 'gap_price.id' ) )
    price = relation( Price, backref = 'order_price' )
    qty = Column( Integer, nullable = False )

    # }

    def __unicode__( self ):
        return self.qty

    @classmethod
    def get_detail( cls, id ):
        return DBSession.query( cls ).get( id )

    @classmethod
    def getByItem( cls, itemNumber, orderNO ):
        return DBSession.query( cls ).join( OrderInfoHeader, Item ).filter( and_( Item.item_number == itemNumber,
            OrderInfoHeader.orderNO == orderNO ) ).first()

    @classmethod
    def get_item( cls, itemNumber ):
        return DBSession.query( cls ).join( Item ).filter( Item.item_number == itemNumber ).first()

    @property
    def qtyShipped( self ):
        return DBSession.query( sum( ShipItem.qty ) ).filter( and_( ShipItem.orderDetailID == self.id,
            ShipItem.active == 0 ) ).first()[0] or 0

    @property
    def qtyReserved( self ):
        return DBSession.query( sum( ReserveItem.qty ) ).filter( and_( ReserveItem.orderDetailID == self.id,
            ReserveItem.active == 0 ) ).first()[0] or 0

    @property
    def is_shipped_complete( self ):
        is_complete = True
        if self.qty != self.qtyShipped:
            is_complete = False
        return is_complete


# for inventory
class Inventory( DeclarativeBase ):
    __tablename__ = 'gap_inventory'

    # { Columns

    id = Column( Integer, primary_key = True )
    qty = Column( Integer, default = 0 )
    warning_qty = Column( Integer, default = 0 )    # send email when qty < warning_qty
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    warehouseID = Column( "warehouse_id", Integer, ForeignKey( 'gap_warehouse.id' ) )
    warehouse = relation( Warehouse, backref = "warehouse_inventory" )
    itemID = Column( "item_id", Integer, ForeignKey( 'gap_item.id' ) )
    item = relation( Item, backref = 'item_inventory' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )

    @property
    def shippedQty( self ):
        return DBSession.query( sum( WarehouseHistory.qty ) ).filter( and_( 
            WarehouseHistory.active == 0, WarehouseHistory.type == 'shipped',
            WarehouseHistory.warehouseID == self.warehouseID, WarehouseHistory.itemID == self.itemID ) ).first()[0] or 0

    # }


class WarehouseHistory( DeclarativeBase ):
    __tablename__ = 'gap_warehouse_history'

    # { Columns

    id = Column( Integer, primary_key = True )
    qty = Column( Integer, nullable = False, default = 0 )
    before_qty = Column( Integer, nullable = False, default = 0 )
    after_qty = Column( Integer, nullable = False, default = 0 )
    type = Column( Unicode( 30 ), nullable = False )    # received  or shipped
    remark = Column( Unicode( 1000 ) )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    warehouseID = Column( "warehouse_id", Integer, ForeignKey( 'gap_warehouse.id' ) )
    warehouse = relation( Warehouse, backref = 'warehouse_history' )
    itemID = Column( "item_id", Integer, ForeignKey( 'gap_item.id' ) )
    item = relation( Item, backref = 'item_warehouse_history' )
    orderID = Column( "order_id", Integer, ForeignKey( 'gap_order_header.id' ) )
    orderHeader = relation( OrderInfoHeader, backref = 'order_warehouse_history' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )

    internalPO = Column( "internal_po", Unicode( 200 ) )

    # }

    def get_shipped_date( self, orderID ):
        return DBSession.query( max( WarehouseHistory.createTime ) ). \
                filter( WarehouseHistory.orderID == orderID ). \
                filter( WarehouseHistory.type == 'shipped' ).first()[0] or None


#  new design@20120516 ----------------------------------------------------------------------
class ReceiveItemHeader( DeclarativeBase ):
    __tablename__ = 'gap_receive_item_header'

    id = Column( Integer, primary_key = True )
    no = Column( "no", Unicode( 200 ) )
    remark = Column( Unicode( 1000 ) )

    warehouseID = Column( "warehouse_id", Integer, ForeignKey( 'gap_warehouse.id' ) )
    warehouse = relation( Warehouse, backref = 'warehouse_receive_item_header' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive


class ReceiveItem( DeclarativeBase ):
    __tablename__ = 'gap_receive_item'

    id = Column( Integer, primary_key = True )
    qty = Column( Integer, nullable = False, default = 0 )
    internalPO = Column( "internal_po", Unicode( 200 ) )

    headerID = Column( "header_id", Integer, ForeignKey( 'gap_receive_item_header.id' ) )
    header = relation( ReceiveItemHeader, backref = 'receive_item_details' )
    itemID = Column( "item_id", Integer, ForeignKey( 'gap_item.id' ) )
    item = relation( Item, backref = 'item_receive_item' )
    warehouseID = Column( "warehouse_id", Integer, ForeignKey( 'gap_warehouse.id' ) )
    warehouse = relation( Warehouse, backref = 'warehouse_receive_item' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive


class ShipItemHeader( DeclarativeBase ):
    __tablename__ = 'gap_ship_item_header'

    id = Column( Integer, primary_key = True )
    no = Column( "no", Unicode( 200 ) )
    invoiceNumber = Column( "invoice_number", Unicode( 200 ) )
    invoice = Column( "invoice", Float )    # 自动计算
    otherInvoice = Column( "other_invoice", Float )
    remark = Column( Unicode( 1000 ) )
    # 20120622
    filename = Column( Unicode( 200 ) )
    filepath = Column( Unicode( 200 ) )

    warehouseID = Column( "warehouse_id", Integer, ForeignKey( 'gap_warehouse.id' ) )
    warehouse = relation( Warehouse, backref = 'warehouse_ship_item_header' )
    orderID = Column( "order_id", Integer, ForeignKey( 'gap_order_header.id' ) )
    orderHeader = relation( OrderInfoHeader, backref = backref( 'order_ship_item_header', order_by = id ) )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    @classmethod
    def getBySi( cls, invoiceNumber, orderID, filename ):
        return DBSession.query( cls ).filter( and_( cls.active == 0,
            cls.invoiceNumber == invoiceNumber,
            cls.orderID == orderID, cls.filename == filename ) ).first()


class ShipItem( DeclarativeBase ):
    __tablename__ = 'gap_ship_item'

    id = Column( Integer, primary_key = True )
    qty = Column( Integer, nullable = False, default = 0 )
    internalPO = Column( "internal_po", Unicode( 200 ) )

    headerID = Column( "header_id", Integer, ForeignKey( 'gap_ship_item_header.id' ) )
    header = relation( ShipItemHeader, backref = backref( 'ship_item_details', order_by = id ) )
    itemID = Column( "item_id", Integer, ForeignKey( 'gap_item.id' ) )
    item = relation( Item, backref = 'item_ship_item' )
    warehouseID = Column( "warehouse_id", Integer, ForeignKey( 'gap_warehouse.id' ) )
    warehouse = relation( Warehouse, backref = 'warehouse_ship_item' )
    orderID = Column( "order_id", Integer, ForeignKey( 'gap_order_header.id' ) )
    orderHeader = relation( OrderInfoHeader, backref = 'order_ship_item' )
    orderDetailID = Column( "order_detail_id", Integer, ForeignKey( 'gap_order_detail.id' ) )
    orderDetail = relation( OrderInfoDetail, backref = 'order_detail_ship_item' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    invoiceDate = Column( "invoice_date", DateTime )


class SafetyStock( DeclarativeBase ):
    __tablename__ = 'gap_safety_stock'

    id = Column( Integer, primary_key = True )
    qty = Column( Integer, nullable = False, default = 0 )

    itemID = Column( "item_id", Integer, ForeignKey( 'gap_item.id' ) )
    item = relation( Item, backref = 'item_safety_stock' )
    warehouseID = Column( "warehouse_id", Integer, ForeignKey( 'gap_warehouse.id' ) )
    warehouse = relation( Warehouse, backref = 'warehouse_safety_stock' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive


class ReserveItem( DeclarativeBase ):
    __tablename__ = 'gap_reserve_item'

    id = Column( Integer, primary_key = True )
    qty = Column( Integer, nullable = False, default = 0 )

    itemID = Column( "item_id", Integer, ForeignKey( 'gap_item.id' ) )
    item = relation( Item, backref = 'item_reserve_item' )
    warehouseID = Column( "warehouse_id", Integer, ForeignKey( 'gap_warehouse.id' ) )
    warehouse = relation( Warehouse, backref = 'warehouse_reserve_item' )
    orderID = Column( "order_id", Integer, ForeignKey( 'gap_order_header.id' ) )
    orderHeader = relation( OrderInfoHeader, backref = 'order_reserve_item' )
    orderDetailID = Column( "order_detail_id", Integer, ForeignKey( 'gap_order_detail.id' ) )
    orderDetail = relation( OrderInfoDetail, backref = 'order_detail_reserve_item' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive


class StockAdjustmentHeader( DeclarativeBase ):
    __tablename__ = 'gap_stock_adjustment_header'

    id = Column( Integer, primary_key = True )
    no = Column( Unicode( 50 ), nullable = False )
    status = Column( Unicode( 50 ) )    # confirmed.upper(), approved.upper()
    remark = Column( Unicode( 1000 ) )
    warehouseID = Column( "warehouse_id", Integer, ForeignKey( 'gap_warehouse.id' ) )
    warehouse = relation( Warehouse, backref = 'warehouse_stock_adjustment_header' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    approvedDate = Column( "approved_date", DateTime )
    approvedById = Column( "approved_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    approvedBy = relation( User, primaryjoin = approvedById == User.user_id )


class StockAdjustmentDetail( DeclarativeBase ):
    __tablename__ = 'gap_stock_adjustment_detail'

    id = Column( Integer, primary_key = True )
    qty = Column( Integer, nullable = False, default = 0 )
    onHandQty = Column( 'on_hand_qty', Integer, nullable = False )
    reservedQty = Column( 'reserved_qty', Integer, nullable = False, default = 0 )
    availableQty = Column( 'available_qty', Integer, nullable = False )
    type = Column( Unicode( 10 ) )    # Add: ADD = +, Less: LESS = -
    status = Column( Unicode( 50 ) )    # confirmed.upper(), approved.upper()

    headerID = Column( "header_id", Integer, ForeignKey( 'gap_stock_adjustment_header.id' ) )
    header = relation( StockAdjustmentHeader, backref = 'stock_adjustment_details' )
    itemID = Column( "item_id", Integer, ForeignKey( 'gap_item.id' ) )
    item = relation( Item, backref = 'item_stock_adjustment_detail' )
    warehouseID = Column( "warehouse_id", Integer, ForeignKey( 'gap_warehouse.id' ) )
    warehouse = relation( Warehouse, backref = 'warehouse_stock_adjustment_detail' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive


class UploadSiHeader( DeclarativeBase ):
    __tablename__ = 'gap_uploadsi_header'

    id = Column( Integer, primary_key = True )
    filename = Column( Unicode( 200 ) )
    filepath = Column( Unicode( 200 ) )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def details( self, type = 0 ):
        return DBSession.query( UploadSiDetail ).filter( and_( UploadSiDetail.active == 0,
            UploadSiDetail.headerID == self.id, UploadSiDetail.type == type ) ).all()


class UploadSiDetail( DeclarativeBase ):
    __tablename__ = 'gap_uploadsi_detail'

    id = Column( Integer, primary_key = True )
    orderNO = Column( "order_no", Unicode( 200 ) )
    itemNumber = Column( "item_number", Unicode( 255 ) )
    invoiceNumber = Column( "invoice_number", Unicode( 200 ) )
    internalPO = Column( "internal_po", Unicode( 200 ) )
    shipQty = Column( "ship_qty", Integer )
    deliveryDate = Column( "delivery_date", Unicode( 200 ) )
    invoiceDate = Column( "invoice_date", Unicode( 100 ) )

    type = Column( Integer, default = 0 )    # 0: can create shipment, 1: can not create shipment

    headerID = Column( "header_id", Integer, ForeignKey( 'gap_uploadsi_header.id' ) )
    header = relation( UploadSiHeader, backref = 'uploadsi_details' )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

##################
# add for care label order sample project Deng Chao
##################
class CarelabelItem( DeclarativeBase ):
    __tablename__ = 'gap_carelabel_item'

    # { Columns

    id = Column( Integer, primary_key = True )
    item_number = Column( Unicode( 255 ), nullable = False )
    description = Column( Unicode( 1000 ), nullable = False )
#    size = Column(Unicode(50))
#    articleDesc = Column('article_desc', Unicode(50))
    price = Column( Float, nullable = False )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    # }

    def __unicode__( self ):
        return self.item_number

    @classmethod
    def get_items( cls ):
        return DBSession.query( cls ).filter( cls.active == 0 ).order_by( cls.item_number ).all()

    @classmethod
    def get_item( cls, id ):
        return DBSession.query( cls ).get( id )

    @classmethod
    def get_item_by_name( cls, item_no ):
        return DBSession.query( cls ).filter( cls.item_number == item_no ).first()

    def getPrice( self, regionID ):
        return Price.get_price( regionID, self.id ).price

class CLOrderHeader( DeclarativeBase ):
    __tablename__ = 'gap_cl_order_header'

    # { Columns

    id = Column( Integer, primary_key = True )
    orderNO = Column( "order_no", Unicode( 50 ) )
    orderDate = Column( "order_date", DateTime, default = dt.now )
    buyerPO = Column( "buyer_po", Unicode( 50 ) )
    vendorPO = Column( "vendor_po", Unicode( 50 ) )
    billCompany = Column( "bill_company", Unicode( 100 ) )
    billAddress = Column( "bill_address", Unicode( 200 ) )
    billAttn = Column( "bill_attn", Unicode( 50 ) )
    billTel = Column( "bill_tel", Unicode( 50 ) )
    billFax = Column( "bill_fax", Unicode( 50 ) )
    billEmail = Column( "bill_email", Unicode( 50 ) )
    shipCompany = Column( "ship_company", Unicode( 100 ) )
    shipAddress = Column( "ship_address", Unicode( 200 ) )
    shipAttn = Column( "ship_attn", Unicode( 50 ) )
    shipTel = Column( "ship_tel", Unicode( 50 ) )
    shipFax = Column( "ship_fax", Unicode( 50 ) )
    shipEmail = Column( "ship_email", Unicode( 50 ) )
    remark = Column( Unicode( 1000 ) )
    shippedDate = Column( "shipped_date", DateTime )
    contactID = Column( "contact_id", Integer, ForeignKey( 'gap_contact.id' ) )
    contact = relation( Contact, backref = 'clorder_contact' )
    styleNo = Column( "style_no", Unicode( 50 ) )
    styleName = Column( "style_name", Unicode( 50 ) )
    division = Column( Unicode( 50 ) )
    countryOfOrigin = Column( 'coo', Unicode( 50 ) )
    invoiceNO = Column( "invoice_no", Unicode( 50 ) )
    invoiceTotal = Column( "invoice_total", Float )
    dailySequence = Column( "daily_sequence", Integer )
    shipInstruction = Column( "ship_instruction", Unicode( 1000 ) )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    issuedDate = Column( "issued_date", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ) )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )

    status = Column( "status", Integer, default = 1 )    # util/gap_const.py

    # }

    def __unicode__( self ):
        return self.orderNO

    def total_qty( self ):
        return DBSession.query( sum( CLOrderDetail.qty ) ).\
                filter( CLOrderDetail.id.in_( [item.id for item in self.order_details] ) ).first()[0]

    @classmethod
    def latest_order( cls ):
        return DBSession.query( cls ).filter( cls.id == DBSession.query( max( cls.id ) ).first()[0] ).first()

    @classmethod
    def get_order( cls, id ):
        return DBSession.query( cls ).get( id )

    @classmethod
    def first_order( cls, user_id ):
        return DBSession.query( cls ).filter( cls.id == DBSession.query( max( cls.id ) ).filter( cls.issuedById == user_id ).first()[0] ).first()


class CLOrderDetail( DeclarativeBase ):
    __tablename__ = 'gap_cl_order_detail'

    # { Columns

    id = Column( Integer, primary_key = True )
    headerID = Column( "header_id", Integer, ForeignKey( 'gap_cl_order_header.id' ) )
    header = relation( CLOrderHeader, backref = backref( 'order_details', order_by = id ) )
    itemID = Column( "item_id", Integer, ForeignKey( 'gap_carelabel_item.id' ) )
    item = relation( CarelabelItem, backref = 'clorder_item' )
    size = Column( Unicode( 50 ) )
    articleDesc = Column( "article_desc", Unicode( 100 ) )
    qty = Column( Integer, nullable = False )

    # }

    def __unicode__( self ):
        return self.qty

    @classmethod
    def get_detail( cls, id ):
        return DBSession.query( cls ).get( id )

    @classmethod
    def getByItem( cls, itemNumber, orderNO ):
        return DBSession.query( cls ).join( CLOrderHeader, CarelabelItem ).filter( and_( CarelabelItem.item_number == itemNumber,
            CLOrderHeader.orderNO == orderNO ) ).first()

    @classmethod
    def get_item( cls, itemNumber ):
        return DBSession.query( cls ).join( CarelabelItem ).filter( CarelabelItem.item_number == itemNumber ).first()
