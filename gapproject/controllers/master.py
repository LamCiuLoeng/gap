# -*- coding: utf-8 -*-

from datetime import datetime as dt

import json
import traceback

from tg import expose
from tg import flash
from tg import override_template
from tg import redirect
from tg import request
from tg.decorators import paginate

from gapproject.controllers.basicMaster import *
from gapproject.model import *
from gapproject.util.common import *
from gapproject.widgets.master import *

__all__ = ["CategoryController", "ItemController", "RegionController", "PriceController",
           "ContactController", "WarehouseController", "BillToController", "ShipToController",
           "OnclDivisionController", "OnclCategoryController",
#            "OnclSizeController",
           "CareInstructionController",
           "ChinaProductNameController", "CountryController", "FiberController", "FinishesWeaveController",
           "FitsDescriptionController", "SectionalCallOutController", "WarningController"
           ]

class CategoryController( BasicMasterController ):
    url = "category"
    template = "gapproject.templates.master.index_category"
    dbObj = Category
    searchWidget = categorySearchFormInstance
    updateWidget = categoryUpdateFormInstance
    formFields = ["name",
                  "description",
                  ]

class ItemController( BasicMasterController ):
    url = "item"
    template = "gapproject.templates.master.index_item"
    dbObj = Item
    searchWidget = itemSearchFormInstance
    updateWidget = itemUpdateFormInstance
    formFields = ["item_number",
                  "description",
                  "width",
                  "length",
                  "gusset",
                  "lip",
                  "categoryID",
                  ]

    def searchMaster( self, kw ):
        try:
            conditions = []

            if kw.get( "categoryID", False ):
                category = Category.get_category( kw.get( 'categoryID', False ) )
                conditions.append( Item.categoryID == category.id )
            if kw.get( "item_number", False ):
                conditions.append( Item.item_number.like( "%%%s%%" % kw.get( "item_number", False ).strip() ) )
            if kw.get( "description", False ):
                conditions.append( Item.description.like( "%%%s%%" % kw.get( "description", False ).strip() ) )

            if len( conditions ):
                obj = DBSession.query( Item )

                for condition in conditions:
                    obj = obj.filter( condition )

                result = obj.filter( Item.active == 0 ).all()
            else:
                result = DBSession.query( Item ).filter( Item.active == 0 ).all()

            return result
        except:
            traceback.print_exc()

    @expose( 'json' )
    def saveNew( self, ** kw ):
        try:
            self.dbObj = Item
            params = {"createTime": dt.now(),
                      "issuedBy": request.identity["user"],
                      "lastModifyBy": request.identity["user"],
                      "lastModifyTime":dt.now()
                      }

            for param in ['item_number', 'description', 'width', 'length', 'gusset', 'lip']:
                if kw.get( param, False ):
                    params[param] = kw[param]

            params = self.beforeSaveNew( kw, params )
            obj = self.dbObj( ** params )

            if kw.get( 'categoryID', False ):
                category = Category.get_category( kw.get( 'categoryID', False ) )
                obj.category = category

            DBSession.add( obj )
            DBSession.flush()
            # add to Warehouse
            # add_inventory = []
            # for w in DBSession.query(Warehouse).filter(Warehouse.active==0).all():
            #     tmp = Inventory(itemID=obj.id, warehouseID=w.id, issuedBy=request.identity["user"],
            #                     lastModifyBy=request.identity["user"])
            #     add_inventory.append(tmp)
            # if add_inventory: DBSession.add_all(add_inventory)
            flash( "Save the new master successfully!" )
        except:
            file = open( 'log.txt', 'w' )

            traceback.print_exc( None, file )
            file.close()

        redirect( "/%s/index" % self.url )

class RegionController( BasicMasterController ):
    url = "region"
    template = "gapproject.templates.master.index_region"
    dbObj = Region
    searchWidget = regionSearchFormInstance
    updateWidget = regionUpdateFormInstance
    formFields = ["name",
                  "description",
                  "regionMailAddress"
                  ]

class PriceController( BasicMasterController ):
    url = "price"
    template = "gapproject.templates.master.index_price"
    dbObj = Price
    searchWidget = priceSearchFormInstance
    updateWidget = priceUpdateFormInstance
    formFields = ["price",
                  "regionID",
                  "item_no",
                  ]

    @expose( 'gapproject.templates.master.index' )
    @paginate( "result", items_per_page = 20 )
    @tabFocus( tab_type = "master" )
    def index( self, **kw ):
        if self.template:
             override_template( self.index, ''.join( ["mako:", self.template] ) )

        if not kw:
            result = []
        else:
            result = self.searchMaster( kw )

        return {"searchWidget" : self.searchWidget,
                "result" : result['result'] if result else result,
                "regions": result['regions'] if result else result,
                "funcURL" :self.url,
                "values" : kw,
                }

    def searchMaster( self, kw ):
        try:
            conditions = []
            result = []

            if kw.get( "item_no", False ):
                conditions.append( Item.item_number == kw.get( 'item_no', '' ).strip() )

            if len( conditions ):
                obj = DBSession.query( Item )

                for condition in conditions:
                    obj = obj.filter( condition )

                result = obj.filter( Item.active == 0 ).all()
            else:
                result = DBSession.query( Item ).filter( Item.active == 0 ).all()

            regions = Region.get_regions()

            return dict( result = result,
                        regions = regions,
                        )
        except:
            traceback.print_exc()

    @expose( 'gapproject.templates.master.form' )
    def update( self, ** kw ):
        obj = getOr404( self.dbObj, kw["id"], "/%s/index" % self.url )
        values = {'price': getattr( obj, 'price' )}

        return {
                "widget" : self.updateWidget,
                "values" : values,
                "saveURL" : "/%s/saveUpdate?id=%d" % ( self.url, obj.id ),
                "funcURL" :self.url
                }

    @expose( 'json' )
    def saveNew( self, ** kw ):
        try:
            self.dbObj = Price
            params = {"createTime": dt.now(),
                      "issuedBy": request.identity["user"],
                      "lastModifyBy": request.identity["user"],
                      "lastModifyTime":dt.now()
                      }

            if kw.get( 'price', False ):
                params['price'] = kw['price']

            params = self.beforeSaveNew( kw, params )
            obj = self.dbObj( ** params )

            if kw.get( 'regionID', False ):
                region = DBSession.query( Region ).get( kw.get( 'regionID', False ) )
                obj.region = region

            if kw.get( 'itemID', False ):
                item = DBSession.query( Item ).get( kw.get( 'itemID', False ) )
                obj.item = item

            DBSession.add( obj )
            DBSession.flush()

            flash( "Save the new master successfully!" )
        except:
            file = open( 'log.txt', 'w' )

            traceback.print_exc( None, file )
            file.close()

        redirect( "/%s/index" % self.url )

    @expose( 'json' )
    def saveUpdate( self, ** kw ):
        obj = getOr404( self.dbObj, kw["id"], "/%s/index" % self.url )
        params = {"lastModifyBy": request.identity["user"],
                  "lastModifyTime":dt.now()
                  }

        if kw.get( 'price', False ):
            params['price'] = kw['price'] if kw['price'] else None

        params = self.beforeSaveUpdate( kw, params )
        for k in params: setattr( obj, k, params[k] )

        if kw.get( 'regionID', False ):
            region = DBSession.query( Region ).get( kw.get( 'regionID', False ) )
            obj.region = region

        if kw.get( 'itemID', False ):
            item = DBSession.query( Item ).get( kw.get( 'itemID', False ) )
            obj.item = item

        flash( "Update the master successfully!" )
        redirect( "/%s/index" % self.url )

class ContactController( BasicMasterController ):
    url = "contact"
    template = "gapproject.templates.master.index_contact"
    dbObj = Contact
    searchWidget = contactSearchFormInstance
    updateWidget = contactUpdateFormInstance
    formFields = ["name",
                  "regionID",
                  "email",
                  "phone",
                  "address",
                  ]

    def searchMaster( self, kw ):
        try:
            conditions = []

            if kw.get( "regionID", False ):
                region = DBSession.query( Region ).get( int( kw.get( 'regionID', False ) ) )
                conditions.append( Contact.regionID == region.id )
            if kw.get( "name", False ):
                conditions.append( Contact.name.like( "%%%s%%" % kw.get( "name", False ).strip() ) )
            if kw.get( "email", False ):
                conditions.append( Contact.email.like( "%%%s%%" % kw.get( "email", False ).strip() ) )
            if kw.get( "phone", False ):
                conditions.append( Contact.email.like( "%%%s%%" % kw.get( "phone", False ).strip() ) )
            if kw.get( "address", False ):
                conditions.append( Contact.email.like( "%%%s%%" % kw.get( "address", False ).strip() ) )

            if len( conditions ):
                obj = DBSession.query( Contact )

                for condition in conditions:
                    obj = obj.filter( condition )

                result = obj.filter( Contact.active == 0 ).all()
            else:
                result = DBSession.query( Contact ).filter( Contact.active == 0 ).all()

            return result
        except:
            traceback.print_exc()

    @expose( 'gapproject.templates.master.form' )
    def update( self, ** kw ):
        obj = getOr404( self.dbObj, kw["id"], "/%s/index" % self.url )
        values = {'name': getattr( obj, 'name' ),
                'email': getattr( obj, 'email' ),
                'phone': getattr( obj, 'phone' ),
                'address': getattr( obj, 'address' )
                }

        return {
                "widget" : self.updateWidget,
                "values" : values,
                "saveURL" : "/%s/saveUpdate?id=%d" % ( self.url, obj.id ),
                "funcURL" :self.url
                }

    @expose( 'json' )
    def saveNew( self, ** kw ):
        self.dbObj = Contact
        params = {"createTime": dt.now(),
                  "issuedBy": request.identity["user"],
                  "lastModifyBy": request.identity["user"],
                  "lastModifyTime":dt.now()
                  }

        for param in ['name', 'email', 'phone', 'address']:
            if kw.get( param, False ):
                params[param] = kw[param]

        params = self.beforeSaveNew( kw, params )
        obj = self.dbObj( ** params )

        if kw.get( 'regionID', False ):
            region = DBSession.query( Region ).get( kw.get( 'regionID', False ) )
            obj.region = region

        DBSession.add( obj )
        flash( "Save the new master successfully!" )
        redirect( "/%s/index" % self.url )

    @expose( 'json' )
    def saveUpdate( self, ** kw ):
        obj = getOr404( self.dbObj, kw["id"], "/%s/index" % self.url )
        params = {"lastModifyBy": request.identity["user"],
                  "lastModifyTime":dt.now()
                  }

        for param in ['name', 'email', 'phone', 'address']:
            if kw.get( param, False ):
                params[param] = kw[param]

        params = self.beforeSaveUpdate( kw, params )
        for k in params: setattr( obj, k, params[k] )

        if kw.get( 'regionID', False ):
            region = DBSession.query( Region ).get( kw.get( 'regionID', False ) )
            obj.region = region

        flash( "Update the master successfully!" )
        redirect( "/%s/index" % self.url )


class WarehouseController( BasicMasterController ):
    """Warehouse Master"""
    url = "warehouse"
    template = "gapproject.templates.master.index_warehouse"
    dbObj = Warehouse
    searchWidget = warehouseSearchFormInstance
    updateWidget = warehouseUpdateFormInstance
    formFields = ["name",
                  "regionID",
                  "description",
                  ]

    def searchMaster( self, kw ):
        try:
            conditions = []

            if kw.get( "regionID", False ):
                region = DBSession.query( Region ).get( int( kw.get( 'regionID', False ) ) )
                conditions.append( Warehouse.regionID == region.id )
            if kw.get( "name", False ):
                conditions.append( Warehouse.name.like( "%%%s%%" % kw.get( "name", False ) ) )
            if kw.get( "description", False ):
                conditions.append( Warehouse.description.like( "%%%s%%" % kw.get( "description", False ) ) )

            if len( conditions ):
                obj = DBSession.query( Warehouse )

                for condition in conditions:
                    obj = obj.filter( condition )

                result = obj.filter( Warehouse.active == 0 ).all()
            else:
                result = DBSession.query( Warehouse ).filter( Warehouse.active == 0 ).all()

            return result
        except:
            traceback.print_exc()

    @expose( 'gapproject.templates.master.form' )
    def update( self, ** kw ):
        obj = getOr404( self.dbObj, kw["id"], "/%s/index" % self.url )
        values = {'name': getattr( obj, 'name' ),
                'description': getattr( obj, 'description' )}

        return {
                "widget" : self.updateWidget,
                "values" : values,
                "saveURL" : "/%s/saveUpdate?id=%d" % ( self.url, obj.id ),
                "funcURL" :self.url
                }

    @expose( 'json' )
    def saveNew( self, ** kw ):
        self.dbObj = Warehouse
        params = {"createTime": dt.now(),
                  "issuedBy": request.identity["user"],
                  "lastModifyBy": request.identity["user"],
                  "lastModifyTime":dt.now()
                  }

        for param in ['name', 'description']:
            if kw.get( param, False ):
                params[param] = kw[param]
        print params
        params = self.beforeSaveNew( kw, params )
        obj = self.dbObj( ** params )

        if kw.get( 'regionID', False ):
            region = DBSession.query( Region ).get( kw.get( 'regionID', False ) )
            obj.region = region

        DBSession.add( obj )
        flash( "Save the new master successfully!" )
        redirect( "/%s/index" % self.url )

    @expose( 'json' )
    def saveUpdate( self, ** kw ):
        obj = getOr404( self.dbObj, kw["id"], "/%s/index" % self.url )
        params = {"lastModifyBy": request.identity["user"],
                  "lastModifyTime":dt.now()
                  }

        for param in ['name', 'description']:
            if kw.get( param, False ):
                params[param] = kw[param]

        params = self.beforeSaveUpdate( kw, params )
        for k in params: setattr( obj, k, params[k] )

        if kw.get( 'regionID', False ):
            region = DBSession.query( Region ).get( kw.get( 'regionID', False ) )
            obj.region = region

        flash( "Update the master successfully!" )
        redirect( "/%s/index" % self.url )

class BillToController( BasicMasterController ):
    url = "billto"
    dbObj = BillTo
    template = "gapproject.templates.master.index_billto"
    searchWidget = billToSearchFormInstance
    updateWidget = billToUpdateFormInstance
    formFields = ["customerID",
                  "company",
                  "address",
                  "attn",
                  "tel",
                  "fax",
                  "email",
                  "is_default",
                  "active"
                  ]

#    def beforeSaveNew(self, kw, params):
#        params['is_default'] = 1
#        return params

class ShipToController( BasicMasterController ):
    url = "shipto"
    dbObj = ShipTo
    template = "gapproject.templates.master.index_shipto"
    searchWidget = shipToSearchFormInstance
    updateWidget = shipToUpdateFormInstance
    formFields = ["customerID",
                  "company",
                  "address",
                  "attn",
                  "tel",
                  "fax",
                  "email",
                  "is_default",
                  "active"
                  ]

#    def beforeSaveNew(self, kw, params):
#        params['is_default'] = 1
#        return params

###########new masters for RFID
###########Titainium.Deng
class OnclDivisionController( BasicMasterController ):
    url = "oncldivision"
    dbObj = OnclDivision
    template = "gapproject.templates.master.index_oncldivision"
    searchWidget = onclDivisionSearchFormInstance
    updateWidget = onclDivisionUpdateFormInstance
    formFields = ["name"
                  ]

class OnclCategoryController( BasicMasterController ):
    url = "onclcategory"
    dbObj = OnclCategory
    template = "gapproject.templates.master.index_onclcategory"
    searchWidget = onclCategorySearchFormInstance
    updateWidget = onclCategoryUpdateFormInstance
    formFields = ["name",
                  "division_id"
                  ]



'''
class OnclSizeController(BasicMasterController):
    url = "onclsize"
    dbObj = OnclSize
    template = "gapproject.templates.master.index_onclsize"
    searchWidget = onclSizeSearchFormInstance
    updateWidget = onclSizeUpdateFormInstance
    formFields = ["category_id",
                  "fit_id",
                  "us_size",
                  "china_size",
                  "japan_size",
                  "canada_size",
                  "spanish_size",
                  ]
    
#    @expose('gapproject.templates.master.onclsize_form')
#    @tabFocus(tab_type = "master")
#    def add(self, **kw):
#        return {"widget" : self.updateWidget,
#                "values" : {},
#                "saveURL" : "/%s/saveNew" % self.url,
#                "funcURL" :self.url
#                }
    
#    @expose('json')
#    def saveNew(self, **kw):
#        self.dbObj = OnclSize
#        params = {"createTime": dt.now(),
#                  "issuedBy": request.identity["user"],
#                  "lastModifyBy": request.identity["user"],
#                  "lastModifyTime":dt.now()
#                  }
#
#        params = self.beforeSaveNew(kw, params)
#        obj = self.dbObj(** params)
#        
#        if kw.get('category_id', False):
#            category = DBSession.query(OnclCategory).get(kw.get('category_id', False))
#            obj.category = category
#        
#        DBSession.add(obj)
#        flash("Save the new master successfully!")
#        redirect("/%s/index" % self.url)
    
    def beforeSaveNew(self, kw, params):
#        category = DBSession.query(OnclCategory).get(kw.get("category_id", False))
        sequence = DBSession.query(self.dbObj.order).filter(self.dbObj.category_id == kw.get("category_id", False)).all()
        
        if len(sequence) > 0:
            max_sequence = int(max(sequence)[0]) + 1
        else:
            max_sequence = 1
        
        params['order'] = max_sequence
             
        return params
    
#    @expose('gapproject.templates.master.size_form')
#    @tabFocus(tab_type = "master")
#    def update(self, **kw):
#        obj = getOr404(self.dbObj, kw["id"], "/%s/index" % self.url)
#        china_values = {}
#        japan_values = {}
#        values = {}
#        categories = DBSession.query(OnclCategory).all()
#        
#        for f in self.formFields :
#            v = getattr(obj, f)
#            
#            if f == 'japan_size':
#                v = json.loads(v)
#
#                for key, val in v.items():
#                    japan_values[key] = val
#            elif f == 'china_size':
#                v = json.loads(v)
#
#                for key, val in v.items():
#                    china_values[key] = val
#            else:
#                if isinstance(v, basestring):
#                    values[f] = str(getattr(obj, f))
#                else:
#                    values[f] = v
#        
#        return {"widget" : self.updateWidget,
#                "values" : china_values,
#                "size": obj,
#                "categories": categories,
#                "china_values": china_values,
#                "japan_values": japan_values,
#                "saveURL" : "/%s/saveUpdate?id=%d" % (self.url, obj.id),
#                "funcURL" :self.url
#                }
        
#    @expose('json')
#    def saveUpdate(self, ** kw):
#        obj = getOr404(self.dbObj, kw["id"], "/%s/index" % self.url)
#        params = {"lastModifyBy": request.identity["user"],
#                  "lastModifyTime":dt.now()
#                  }
#        
#        for param in ['western_size']:
#            if kw.get(param, False):
#                params[param] = kw[param]
#
#        params = self.beforeSaveUpdate(kw, params)
#        for k in params: setattr(obj, k, params[k])
#        
#        if kw.get('category_id', False):
#            category = DBSession.query(OnclCategory).get(kw.get('category_id', False))
#            obj.category = category
#            
#        flash("Update the master successfully!")
#        redirect("/%s/index" % self.url)
    
#    def beforeSaveUpdate(self, kw, params):
#        max_sequence = DBSession.query(max(OnclSize.order)).filter(OnclSize.category.id == kw.get('category_id', False)).all()
#        
#        if len(max_sequence) > 0:
#            params['order'] = int(max_sequence) + 1
#        else:
#            params['order'] = 1
#             
#        return params
'''


class CareInstructionController( BasicMasterController ):
    url = "careinstruction"
    dbObj = CareInstruction
    template = "gapproject.templates.master.index_careinstruction"
    searchWidget = careInstructionSearchFormInstance
    updateWidget = careInstructionUpdateFormInstance
    formFields = ["trans_id", "english_term", "context", "arabic",
                  "bahasa_indonesia", "bulgarian", "chinese", "croatian",
                  "french", "french_canada", "german", "greek",
                  "hungarian", "italian", "japanese", "kazakh",
                  "korean", "polish", "portuguese", "romanian",
                  "russian", "serbian", "spanish", "turkish",
                  "ukrainian",
                  ]

class ChinaProductNameController( BasicMasterController ):
    url = "chinaproductname"
    dbObj = ChinaProductName
    template = "gapproject.templates.master.index_chinaproductname"
    searchWidget = chinaProductNameSearchFormInstance
    updateWidget = chinaProductNameUpdateFormInstance
    formFields = ["trans_id", "english_term", "context", "chinese_traditional_taiwan",
                  "hungarian", "uk_english",
                  ]

class CountryController( BasicMasterController ):
    url = "country"
    dbObj = Country
    template = "gapproject.templates.master.index_country"
    searchWidget = countrySearchFormInstance
    updateWidget = countryUpdateFormInstance
    formFields = ["trans_id", "english_term", "context", "arabic",
                  "bahasa_indonesia", "bulgarian", "chinese", "chinese_traditional_taiwan",
                  "croatian", "french", "french_canada", "german",
                  "greek", "hungarian", "italian", "japanese",
                  "kazakh", "korean", "polish", "portuguese",
                  "romanian", "russian", "serbian", "spanish",
                  "turkish", "ukrainian",
                  ]

class FiberController( BasicMasterController ):
    url = "fiber"
    dbObj = Fiber
    template = "gapproject.templates.master.index_fiber"
    searchWidget = fiberSearchFormInstance
    updateWidget = fiberUpdateFormInstance
    formFields = ["trans_id", "english_term", "context", "arabic",
                  "bahasa_indonesia", "bulgarian", "chinese", "chinese_traditional_taiwan",
                  "croatian", "french", "french_canada", "german",
                  "greek", "hungarian", "italian", "japanese",
                  "kazakh", "korean", "polish", "portuguese",
                  "romanian", "russian", "serbian", "spanish",
                  "turkish", "uk_english", "ukrainian",
                  ]

class FinishesWeaveController( BasicMasterController ):
    url = "finishesweave"
    dbObj = FinishesWeave
    template = "gapproject.templates.master.index_finishesweave"
    searchWidget = finishesWeaveSearchFormInstance
    updateWidget = finishesWeaveUpdateFormInstance
    formFields = ["trans_id", "english_term", "context", "arabic",
                  "bahasa_indonesia", "bulgarian", "chinese_traditional_taiwan",
                  "croatian", "french", "french_canada", "german",
                  "greek", "hungarian", "italian", "japanese",
                  "kazakh", "korean", "polish", "portuguese",
                  "romanian", "russian", "serbian", "spanish",
                  "turkish", "uk_english", "ukrainian",
                  ]

class FitsDescriptionController( BasicMasterController ):
    url = "fitsdescription"
    dbObj = FitsDescription
    template = "gapproject.templates.master.index_fitsdescription"
    searchWidget = fitsDescriptionSearchFormInstance
    updateWidget = fitsDescriptionUpdateFormInstance
    formFields = ["trans_id", "english_term", "context", "arabic",
                  "bahasa_indonesia", "bulgarian", "chinese", "chinese_traditional_taiwan",
                  "croatian", "french", "french_canada", "german",
                  "greek", "hungarian", "italian", "japanese",
                  "kazakh", "korean", "polish", "portuguese",
                  "romanian", "russian", "serbian", "spanish",
                  "turkish", "uk_english", "ukrainian",
                  ]

class SectionalCallOutController( BasicMasterController ):
    url = "sectionalcallout"
    dbObj = SectionalCallOut
    template = "gapproject.templates.master.index_sectionalcallout"
    searchWidget = sectionalCallOutSearchFormInstance
    updateWidget = sectionalCallOutUpdateFormInstance
    formFields = ["trans_id", "english_term", "context", "arabic",
                  "bahasa_indonesia", "bulgarian", "chinese",
                  "croatian", "french", "french_canada", "german",
                  "greek", "hungarian", "italian", "japanese",
                  "kazakh", "korean", "polish", "portuguese",
                  "romanian", "russian", "serbian", "spanish",
                  "turkish", "uk_english", "ukrainian",
                  ]

class WarningController( BasicMasterController ):
    url = "warning"
    dbObj = Warning
    template = "gapproject.templates.master.index_warning"
    searchWidget = warningSearchFormInstance
    updateWidget = warningUpdateFormInstance
    formFields = ["trans_id", "english_term", "context", "arabic",
                  "bahasa_indonesia", "bulgarian", "chinese",
                  "croatian", "french", "french_canada", "german",
                  "greek", "hungarian", "italian", "japanese",
                  "kazakh", "korean", "polish", "portuguese",
                  "romanian", "russian", "serbian", "spanish",
                  "turkish", "uk_english", "ukrainian",
                  ]
