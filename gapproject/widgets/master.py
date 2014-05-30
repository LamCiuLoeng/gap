# -*- coding: utf-8 -*-

from gapproject.model import *
from gapproject.widgets.components import *

__all__ = ["categorySearchFormInstance", "categoryUpdateFormInstance",
           "itemSearchFormInstance", "itemUpdateFormInstance",
           "regionSearchFormInstance", "regionUpdateFormInstance",
           "priceSearchFormInstance", "priceUpdateFormInstance",
           "contactSearchFormInstance", "contactUpdateFormInstance",
           "warehouseSearchFormInstance", "warehouseUpdateFormInstance",
           "billToSearchFormInstance", "billToUpdateFormInstance",
           "shipToSearchFormInstance", "shipToUpdateFormInstance",
           "onclDivisionSearchFormInstance", "onclDivisionUpdateFormInstance",
           "onclCategorySearchFormInstance", "onclCategoryUpdateFormInstance",
#            "onclSizeSearchFormInstance", "onclSizeUpdateFormInstance",
           "careInstructionSearchFormInstance", "careInstructionUpdateFormInstance",
           "chinaProductNameSearchFormInstance", "chinaProductNameUpdateFormInstance",
           "countrySearchFormInstance", "countryUpdateFormInstance",
           "fiberSearchFormInstance", "fiberUpdateFormInstance",
           "finishesWeaveSearchFormInstance", "finishesWeaveUpdateFormInstance",
           "fitsDescriptionSearchFormInstance", "fitsDescriptionUpdateFormInstance",
           "sectionalCallOutSearchFormInstance", "sectionalCallOutUpdateFormInstance",
           "warningSearchFormInstance", "warningUpdateFormInstance",
           ]

getOptions = lambda obj, order_by = "name": [( str( o.id ), o ) for o in DBSession.query( obj ).filter( obj.active == 0 ).order_by( getattr( obj, order_by ) )]
priceOptions = lambda obj, order_by = "item_number": [( str( o.id ), o ) for o in DBSession.query( obj ).filter( obj.active == 0 ).order_by( getattr( obj, order_by ) )]

vendors = User.get_vendors()
vendorOptions = []

for vendor in vendors:
    vendorOptions.append( ( vendor.user_id, vendor.user_name ) )
vendorOptions.append( ( '', '' ) )
vendorOptions.reverse()

class CategorySearchForm( RPACForm ):
    fields = [RPACText( "name", label_text = "Category Name" ),
              RPACTextarea( "description", label_text = "Description" ),
              ]

categorySearchFormInstance = CategorySearchForm()

class CategoryUpdateForm( RPACForm ):
    fields = [RPACText( "name", label_text = "Category Name" ),
              RPACTextarea( "description", label_text = "Description" ),
              ]

categoryUpdateFormInstance = CategoryUpdateForm()

class ItemSearchForm( RPACForm ):
    fields = [RPACText( "item_number", label_text = "Item Number" ),
              RPACTextarea( "description", label_text = "Description" ),
              RPACSelect( "categoryID", label_text = "Item Category", options = getOptions( Category ) ),
              ]

itemSearchFormInstance = ItemSearchForm()

class ItemUpdateForm( RPACForm ):
    fields = [RPACText( "item_number", label_text = "Item Number" ),
              RPACTextarea( "description", label_text = "Description" ),
              RPACText( "width", label_text = "Width" ),
              RPACText( "length", label_text = "Length" ),
              RPACText( "gusset", label_text = "Gusset" ),
              RPACText( "lip", label_text = "Lip" ),
              RPACSelect( "categoryID", label_text = "Item Category", options = getOptions( Category ) ),
              ]

itemUpdateFormInstance = ItemUpdateForm()

class RegionSearchForm( RPACForm ):
    fields = [RPACText( "name", label_text = "Region Name" ),
              RPACTextarea( "description", label_text = "Description" ),
              ]

regionSearchFormInstance = RegionSearchForm()

class RegionUpdateForm( RPACForm ):
    fields = [RPACText( "name", label_text = "Region Name" ),
              RPACTextarea( "description", label_text = "Description" ),
              RPACText( "regionMailAddress", label_text = "Region Mail" ),
              ]

regionUpdateFormInstance = RegionUpdateForm()

class PriceSearchForm( RPACForm ):
    fields = [RPACAjaxText( "item_no", label_text = "Bag ItemNo", attrs = {'fieldName' : 'item_no'} ),
              ]

priceSearchFormInstance = PriceSearchForm()

class PriceUpdateForm( RPACForm ):
    fields = [RPACText( "price", label_text = "Price" ),
              RPACSelect( "regionID", label_text = "Region", options = getOptions( Region ) ),
              RPACSelect( "itemID", label_text = "Item", options = priceOptions( Item ) ),
              ]

priceUpdateFormInstance = PriceUpdateForm()

class ContactSearchForm( RPACForm ):
    fields = [RPACText( "name", label_text = "Contact Name" ),
              RPACSelect( "regionID", label_text = "Region", options = getOptions( Region ) ),
              RPACText( "email", label_text = "Email Address" ),
              RPACText( "phone", label_text = "Phone" ),
              RPACText( "address", label_text = "Office Address" ),
              ]

contactSearchFormInstance = ContactSearchForm()

class ContactUpdateForm( RPACForm ):
    fields = [RPACText( "name", label_text = "Contact Name" ),
              RPACSelect( "regionID", label_text = "Region", options = getOptions( Region ) ),
              RPACText( "email", label_text = "Email Address" ),
              RPACText( "phone", label_text = "Phone" ),
              RPACText( "address", label_text = "Office Address" ),
              ]

contactUpdateFormInstance = ContactUpdateForm()

class WarehouseSearchForm( RPACForm ):
    fields = [RPACText( "name", label_text = "Warehouse Name" ),
              RPACSelect( "regionID", label_text = "Region", options = getOptions( Region ) ),
              RPACTextarea( "description", label_text = "Description" ),
              ]

warehouseSearchFormInstance = WarehouseSearchForm()

class WarehouseUpdateForm( RPACForm ):
    fields = [RPACText( "name", label_text = "Warehouse Name" ),
              RPACSelect( "regionID", label_text = "Region", options = getOptions( Region ) ),
              RPACTextarea( "description", label_text = "Description" ),
              ]

warehouseUpdateFormInstance = WarehouseUpdateForm()

class BillToSearchForm( RPACForm ):
    fields = [RPACSelect( "customerID", label_text = "Customer", options = vendorOptions ),
              RPACText( "company", label_text = "Company" ),
              RPACText( "address", label_text = "Address" ),
              RPACText( "attn", label_text = "Attn" ),
              RPACText( "tel", label_text = "Tel" ),
              RPACText( "fax", label_text = "Fax" ),
              RPACText( "email", label_text = "E-mail" ),
              ]

billToSearchFormInstance = BillToSearchForm()

class BillToUpdateForm( RPACForm ):
    fields = [RPACSelect( "customerID", label_text = "Customer", options = vendorOptions ),
              RPACText( "company", label_text = "Company" ),
              RPACText( "address", label_text = "Address" ),
              RPACText( "attn", label_text = "Attn" ),
              RPACText( "tel", label_text = "Tel" ),
              RPACText( "fax", label_text = "Fax" ),
              RPACText( "email", label_text = "E-mail" ),
              RPACSelect( "is_default", label_text = "Default", options = [( 0, 'Yes' ), ( 1, 'No' )] ),
              RPACSelect( "active", label_text = "Status", options = [( 0, 'Active' ), ( 1, 'Inactive' )] ),
              ]

billToUpdateFormInstance = BillToUpdateForm()

class ShipToSearchForm( RPACForm ):
    fields = [RPACSelect( "customerID", label_text = "Customer", options = vendorOptions ),
              RPACText( "company", label_text = "Company" ),
              RPACText( "address", label_text = "Address" ),
              RPACText( "attn", label_text = "Attn" ),
              RPACText( "tel", label_text = "Tel" ),
              RPACText( "fax", label_text = "Fax" ),
              RPACText( "email", label_text = "E-mail" )
              ]

shipToSearchFormInstance = ShipToSearchForm()

class ShipToUpdateForm( RPACForm ):
    fields = [RPACSelect( "customerID", label_text = "Customer", options = vendorOptions ),
              RPACText( "company", label_text = "Company" ),
              RPACText( "address", label_text = "Address" ),
              RPACText( "attn", label_text = "Attn" ),
              RPACText( "tel", label_text = "Tel" ),
              RPACText( "fax", label_text = "Fax" ),
              RPACText( "email", label_text = "E-mail" ),
              RPACSelect( "is_default", label_text = "Default", options = [( 0, 'Yes' ), ( 1, 'No' )] ),
              RPACSelect( "active", label_text = "Status", options = [( 0, 'Active' ), ( 1, 'Inactive' )] ),
              ]

shipToUpdateFormInstance = ShipToUpdateForm()

class OnclDivisionSearchForm( RPACForm ):
    fields = [RPACText( "name", label_text = "Department Name" )
              ]

onclDivisionSearchFormInstance = OnclDivisionSearchForm()

class OnclDivisionUpdateForm( RPACForm ):
    fields = [RPACText( "name", label_text = "Department Name" ),
              ]

onclDivisionUpdateFormInstance = OnclDivisionUpdateForm()

class OnclCategorySearchForm( RPACForm ):
    fields = [
              RPACSelect( "division_id", label_text = "Department Name", options = getOptions( OnclDivision ) ),
              RPACText( "name", label_text = "Category Name" ),
              ]

onclCategorySearchFormInstance = OnclCategorySearchForm()

class OnclCategoryUpdateForm( RPACForm ):
    fields = [
              RPACSelect( "division_id", label_text = "DepartmentName", options = getOptions( OnclDivision ) ),
              RPACText( "name", label_text = "Category Name" ),
              ]

onclCategoryUpdateFormInstance = OnclCategoryUpdateForm()

'''
class OnclSizeSearchForm( RPACForm ):
    fields = [RPACSelect( "category_id", label_text = "Category Name", options = getOptions( OnclCategory ) ),
              RPACSelect( "fit_id", label_text = "Fit Name", options = getOptions( OnclFit ) ),
              RPACText( "us_size", label_text = "US Size" ),
              RPACText( "china_size", label_text = "China Size" ),
              RPACText( "japan_size", label_text = "Japan Size" ),
              RPACText( "canada_size", label_text = "Canada Size" ),
              RPACText( "spanish_size", label_text = "Spanish Size" ),
              ]

onclSizeSearchFormInstance = OnclSizeSearchForm()

class OnclSizeUpdateForm( RPACForm ):
    fields = [RPACSelect( "category_id", label_text = "Category Name", options = getOptions( OnclCategory ) ),
              RPACSelect( "fit_id", label_text = "Fit Name", options = getOptions( OnclFit ) ),
              RPACText( "us_size", label_text = "US Size" ),
              RPACText( "china_size", label_text = "China Size" ),
              RPACText( "japan_size", label_text = "Japan Size" ),
              RPACText( "canada_size", label_text = "Canada Size" ),
              RPACText( "spanish_size", label_text = "Spanish Size" ),
              ]

onclSizeUpdateFormInstance = OnclSizeUpdateForm()
'''

class CareInstructionSearchForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              ]

careInstructionSearchFormInstance = CareInstructionSearchForm()

class CareInstructionUpdateForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              RPACText( "english_term", label_text = "English Term" ),
              RPACText( "context", label_text = "Context" ),
              RPACText( "arabic", label_text = "Arabic" ),
              RPACText( "bahasa_indonesia", label_text = "Bahasa Indonesia" ),
              RPACText( "bulgarian", label_text = "Bulgarian" ),
              RPACText( "chinese", label_text = "Chinese" ),
              RPACText( "croatian", label_text = "Croatian" ),
              RPACText( "french", label_text = "French" ),
              RPACText( "french_canada", label_text = "French Canada" ),
              RPACText( "german", label_text = "German" ),
              RPACText( "greek", label_text = "Greek" ),
              RPACText( "hungarian", label_text = "Hungarian" ),
              RPACText( "italian", label_text = "Italian" ),
              RPACText( "japanese", label_text = "Japanese" ),
              RPACText( "kazakh", label_text = "Kazakh" ),
              RPACText( "korean", label_text = "Korean" ),
              RPACText( "polish", label_text = "Polish" ),
              RPACText( "portuguese", label_text = "Portuguese" ),
              RPACText( "romanian", label_text = "Romanian" ),
              RPACText( "russian", label_text = "Russian" ),
              RPACText( "serbian", label_text = "Serbian" ),
              RPACText( "spanish", label_text = "Spanish" ),
              RPACText( "turkish", label_text = "Turkish" ),
              RPACText( "ukrainian", label_text = "Ukrainian" ),
              ]

careInstructionUpdateFormInstance = CareInstructionUpdateForm()

class ChinaProductNameSearchForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              ]

chinaProductNameSearchFormInstance = ChinaProductNameSearchForm()

class ChinaProductNameUpdateForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              RPACText( "english_term", label_text = "English Term" ),
              RPACText( "context", label_text = "Context" ),
              RPACText( "chinese_traditional_taiwan", label_text = "Chinese Traditional" ),
              RPACText( "hungarian", label_text = "Hungarian" ),
              RPACText( "uk_english", label_text = "UK English" ),
              ]

chinaProductNameUpdateFormInstance = ChinaProductNameUpdateForm()

class CountrySearchForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              ]

countrySearchFormInstance = CountrySearchForm()

class CountryUpdateForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              RPACText( "english_term", label_text = "English Term" ),
              RPACText( "context", label_text = "Context" ),
              RPACText( "arabic", label_text = "Arabic" ),
              RPACText( "bahasa_indonesia", label_text = "Bahasa Indonesia" ),
              RPACText( "bulgarian", label_text = "Bulgarian" ),
              RPACText( "chinese", label_text = "Chinese" ),
              RPACText( "chinese_traditional_taiwan", label_text = "Chinese Traditional" ),
              RPACText( "croatian", label_text = "Croatian" ),
              RPACText( "french", label_text = "French" ),
              RPACText( "french_canada", label_text = "French Canada" ),
              RPACText( "german", label_text = "German" ),
              RPACText( "greek", label_text = "Greek" ),
              RPACText( "hungarian", label_text = "Hungarian" ),
              RPACText( "italian", label_text = "Italian" ),
              RPACText( "japanese", label_text = "Japanese" ),
              RPACText( "kazakh", label_text = "Kazakh" ),
              RPACText( "korean", label_text = "Korean" ),
              RPACText( "polish", label_text = "Polish" ),
              RPACText( "portuguese", label_text = "Portuguese" ),
              RPACText( "romanian", label_text = "Romanian" ),
              RPACText( "russian", label_text = "Russian" ),
              RPACText( "serbian", label_text = "Serbian" ),
              RPACText( "spanish", label_text = "Spanish" ),
              RPACText( "turkish", label_text = "Turkish" ),
              RPACText( "ukrainian", label_text = "Ukrainian" ),
              ]

countryUpdateFormInstance = CountryUpdateForm()

class FiberSearchForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              ]

fiberSearchFormInstance = FiberSearchForm()

class FiberUpdateForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              RPACText( "english_term", label_text = "English Term" ),
              RPACText( "context", label_text = "Context" ),
              RPACText( "arabic", label_text = "Arabic" ),
              RPACText( "bahasa_indonesia", label_text = "Bahasa Indonesia" ),
              RPACText( "bulgarian", label_text = "Bulgarian" ),
              RPACText( "chinese", label_text = "Chinese" ),
              RPACText( "chinese_traditional_taiwan", label_text = "Chinese Traditional" ),
              RPACText( "croatian", label_text = "Croatian" ),
              RPACText( "french", label_text = "French" ),
              RPACText( "french_canada", label_text = "French Canada" ),
              RPACText( "german", label_text = "German" ),
              RPACText( "greek", label_text = "Greek" ),
              RPACText( "hungarian", label_text = "Hungarian" ),
              RPACText( "italian", label_text = "Italian" ),
              RPACText( "japanese", label_text = "Japanese" ),
              RPACText( "kazakh", label_text = "Kazakh" ),
              RPACText( "korean", label_text = "Korean" ),
              RPACText( "polish", label_text = "Polish" ),
              RPACText( "portuguese", label_text = "Portuguese" ),
              RPACText( "romanian", label_text = "Romanian" ),
              RPACText( "russian", label_text = "Russian" ),
              RPACText( "serbian", label_text = "Serbian" ),
              RPACText( "spanish", label_text = "Spanish" ),
              RPACText( "turkish", label_text = "Turkish" ),
              RPACText( "uk_english", label_text = "UK English" ),
              RPACText( "ukrainian", label_text = "Ukrainian" ),
              ]

fiberUpdateFormInstance = FiberUpdateForm()

class FinishesWeaveSearchForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              ]

finishesWeaveSearchFormInstance = FinishesWeaveSearchForm()

class FinishesWeaveUpdateForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              RPACText( "english_term", label_text = "English Term" ),
              RPACText( "context", label_text = "Context" ),
              RPACText( "arabic", label_text = "Arabic" ),
              RPACText( "bahasa_indonesia", label_text = "Bahasa Indonesia" ),
              RPACText( "bulgarian", label_text = "Bulgarian" ),
              RPACText( "chinese_traditional_taiwan", label_text = "Chinese Traditional" ),
              RPACText( "croatian", label_text = "Croatian" ),
              RPACText( "french", label_text = "French" ),
              RPACText( "french_canada", label_text = "French Canada" ),
              RPACText( "german", label_text = "German" ),
              RPACText( "greek", label_text = "Greek" ),
              RPACText( "hungarian", label_text = "Hungarian" ),
              RPACText( "italian", label_text = "Italian" ),
              RPACText( "japanese", label_text = "Japanese" ),
              RPACText( "kazakh", label_text = "Kazakh" ),
              RPACText( "korean", label_text = "Korean" ),
              RPACText( "polish", label_text = "Polish" ),
              RPACText( "portuguese", label_text = "Portuguese" ),
              RPACText( "romanian", label_text = "Romanian" ),
              RPACText( "russian", label_text = "Russian" ),
              RPACText( "serbian", label_text = "Serbian" ),
              RPACText( "spanish", label_text = "Spanish" ),
              RPACText( "turkish", label_text = "Turkish" ),
              RPACText( "uk_english", label_text = "UK English" ),
              RPACText( "ukrainian", label_text = "Ukrainian" ),
              ]

finishesWeaveUpdateFormInstance = FinishesWeaveUpdateForm()

class FitsDescriptionSearchForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              ]

fitsDescriptionSearchFormInstance = FitsDescriptionSearchForm()

class FitsDescriptionUpdateForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              RPACText( "english_term", label_text = "English Term" ),
              RPACText( "context", label_text = "Context" ),
              RPACText( "arabic", label_text = "Arabic" ),
              RPACText( "bahasa_indonesia", label_text = "Bahasa Indonesia" ),
              RPACText( "bulgarian", label_text = "Bulgarian" ),
              RPACText( "chinese", label_text = "Chinese" ),
              RPACText( "chinese_traditional_taiwan", label_text = "Chinese Traditional" ),
              RPACText( "croatian", label_text = "Croatian" ),
              RPACText( "french", label_text = "French" ),
              RPACText( "french_canada", label_text = "French Canada" ),
              RPACText( "german", label_text = "German" ),
              RPACText( "greek", label_text = "Greek" ),
              RPACText( "hungarian", label_text = "Hungarian" ),
              RPACText( "italian", label_text = "Italian" ),
              RPACText( "japanese", label_text = "Japanese" ),
              RPACText( "kazakh", label_text = "Kazakh" ),
              RPACText( "korean", label_text = "Korean" ),
              RPACText( "polish", label_text = "Polish" ),
              RPACText( "portuguese", label_text = "Portuguese" ),
              RPACText( "romanian", label_text = "Romanian" ),
              RPACText( "russian", label_text = "Russian" ),
              RPACText( "serbian", label_text = "Serbian" ),
              RPACText( "spanish", label_text = "Spanish" ),
              RPACText( "turkish", label_text = "Turkish" ),
              RPACText( "uk_english", label_text = "UK English" ),
              RPACText( "ukrainian", label_text = "Ukrainian" ),
              ]

fitsDescriptionUpdateFormInstance = FitsDescriptionUpdateForm()

class SectionalCallOutSearchForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              ]

sectionalCallOutSearchFormInstance = SectionalCallOutSearchForm()

class SectionalCallOutUpdateForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              RPACText( "english_term", label_text = "English Term" ),
              RPACText( "context", label_text = "Context" ),
              RPACText( "arabic", label_text = "Arabic" ),
              RPACText( "bahasa_indonesia", label_text = "Bahasa Indonesia" ),
              RPACText( "bulgarian", label_text = "Bulgarian" ),
              RPACText( "chinese", label_text = "Chinese" ),
              RPACText( "croatian", label_text = "Croatian" ),
              RPACText( "french", label_text = "French" ),
              RPACText( "french_canada", label_text = "French Canada" ),
              RPACText( "german", label_text = "German" ),
              RPACText( "greek", label_text = "Greek" ),
              RPACText( "hungarian", label_text = "Hungarian" ),
              RPACText( "italian", label_text = "Italian" ),
              RPACText( "japanese", label_text = "Japanese" ),
              RPACText( "kazakh", label_text = "Kazakh" ),
              RPACText( "korean", label_text = "Korean" ),
              RPACText( "polish", label_text = "Polish" ),
              RPACText( "portuguese", label_text = "Portuguese" ),
              RPACText( "romanian", label_text = "Romanian" ),
              RPACText( "russian", label_text = "Russian" ),
              RPACText( "serbian", label_text = "Serbian" ),
              RPACText( "spanish", label_text = "Spanish" ),
              RPACText( "turkish", label_text = "Turkish" ),
              RPACText( "uk_english", label_text = "UK English" ),
              RPACText( "ukrainian", label_text = "Ukrainian" ),
              ]

sectionalCallOutUpdateFormInstance = SectionalCallOutUpdateForm()

class WarningSearchForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              ]

warningSearchFormInstance = WarningSearchForm()

class WarningUpdateForm( RPACForm ):
    fields = [RPACText( "trans_id", label_text = "ID" ),
              RPACText( "english_term", label_text = "English Term" ),
              RPACText( "context", label_text = "Context" ),
              RPACText( "arabic", label_text = "Arabic" ),
              RPACText( "bahasa_indonesia", label_text = "Bahasa Indonesia" ),
              RPACText( "bulgarian", label_text = "Bulgarian" ),
              RPACText( "chinese", label_text = "Chinese" ),
              RPACText( "croatian", label_text = "Croatian" ),
              RPACText( "french", label_text = "French" ),
              RPACText( "french_canada", label_text = "French Canada" ),
              RPACText( "german", label_text = "German" ),
              RPACText( "greek", label_text = "Greek" ),
              RPACText( "hungarian", label_text = "Hungarian" ),
              RPACText( "italian", label_text = "Italian" ),
              RPACText( "japanese", label_text = "Japanese" ),
              RPACText( "kazakh", label_text = "Kazakh" ),
              RPACText( "korean", label_text = "Korean" ),
              RPACText( "polish", label_text = "Polish" ),
              RPACText( "portuguese", label_text = "Portuguese" ),
              RPACText( "romanian", label_text = "Romanian" ),
              RPACText( "russian", label_text = "Russian" ),
              RPACText( "serbian", label_text = "Serbian" ),
              RPACText( "spanish", label_text = "Spanish" ),
              RPACText( "turkish", label_text = "Turkish" ),
              RPACText( "uk_english", label_text = "UK English" ),
              RPACText( "ukrainian", label_text = "Ukrainian" ),
              ]

warningUpdateFormInstance = WarningUpdateForm()
