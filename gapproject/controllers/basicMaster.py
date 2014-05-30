# -*- coding: utf-8 -*-
from datetime import datetime as dt

import traceback

from tg import redirect, validate, flash, expose, request, override_template
from repoze.what import predicates, authorize
from repoze.what.predicates import not_anonymous, in_group, has_permission
from tg.decorators import paginate

from gapproject.lib.base import BaseController
from gapproject.model import DBSession, metadata
from gapproject.util.common import *

import gapproject

__all__ = ["BasicMasterController"]

class BasicMasterController( BaseController ):
    # Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    url = "__MUST__BE__CHANGE__"
    dbObj = None
    searchWidget = None
    updateWidget = None
    formFields = []
    template = None
    search_config = None

    @expose( 'gapproject.templates.master.index' )
    @paginate( "result", items_per_page = 20 )
    @tabFocus( tab_type = "master" )
    def index( self, **kw ):
        if self.template: override_template( self.index, ''.join( ["mako:", self.template] ) )

        if not kw:
            result = []
        else:
            result = self.searchMaster( kw )

        print type( result )

        return {"searchWidget" : self.searchWidget,
                "result" : result,
                "funcURL" :self.url,
                "values" : kw,
                }

    @expose( 'gapproject.templates.master.form' )
    @tabFocus( tab_type = "master" )
    def add( self, **kw ):
        return {"widget" : self.updateWidget,
                "values" : {},
                "saveURL" : "/%s/saveNew" % self.url,
                "funcURL" :self.url
                }

    @expose()
    def saveNew( self, **kw ):
        params = {"issuedBy": request.identity["user"],
                  "lastModifyBy": request.identity["user"],
                  "createTime": dt.now(),
                  "lastModifyTime": dt.now()
                  }

        for f in self.formFields:
            if f in kw:
                params[f] = kw[f]

        params = self.beforeSaveNew( kw, params )
        obj = self.dbObj( **params )
        obj = self.afterSaveNew( obj, kw )

        DBSession.add( obj )
        flash( "Save the new master successfully!" )
        redirect( "/%s/index" % self.url )

    @expose( 'gapproject.templates.master.form' )
    @tabFocus( tab_type = "master" )
    def update( self, **kw ):
        obj = getOr404( self.dbObj, kw["id"], "/%s/index" % self.url )
        values = {}

        for f in self.formFields :
            v = getattr( obj, f )

            if isinstance( v, basestring ):
                values[f] = str( getattr( obj, f ) )
            else:
                values[f] = v

        return {"widget" : self.updateWidget,
                "values" : values,
                "saveURL" : "/%s/saveUpdate?id=%d" % ( self.url, obj.id ),
                "funcURL" :self.url
                }

    @expose()
    def saveUpdate( self, **kw ):
        obj = getOr404( self.dbObj, kw["id"], "/%s/index" % self.url )
        params = {"lastModifyBy": request.identity["user"], "lastModifyTime": dt.now()}

        for f in self.formFields:
            if f in kw:
                params[f] = kw[f] if kw[f] else None

        params = self.beforeSaveUpdate( kw, params )

        for k in params:
            setattr( obj, k, params[k] )

        obj = self.afterSaveUpdate( obj, kw )

        flash( "Update the master successfully!" )
        redirect( "/%s/index" % self.url )

    @expose()
    def enable( self, **kw ):
        if kw.get( 'selected_ids', '' ):
            for i in kw.get( 'selected_ids', '' ).split( ',' ):
                obj = getOr404( self.dbObj, i, "/%s/index" % self.url )
                obj.lastModifyBy = request.identity["user"]
                obj.lastModifyTime = dt.now()
                obj.active = 0

        flash( "Enable the master successfully!" )
        redirect( "/%s/index" % self.url )

    @expose()
    def disable( self, **kw ):
        if kw.get( 'selected_ids', '' ):
            for i in kw.get( 'selected_ids', '' ).split( ',' ):
                obj = getOr404( self.dbObj, i, "/%s/index" % self.url )
                obj.lastModifyBy = request.identity["user"]
                obj.lastModifyTime = dt.now()
                obj.active = 1

        flash( "Disable the master successfully!" )
        redirect( "/%s/index" % self.url )

    @expose()
    def delete( self, **kw ):
        obj = getOr404( self.dbObj, kw["id"], "/%s/index" % self.url )
        obj.lastModifyBy = request.identity["user"]
        obj.lastModifyTime = dt.now()
        obj.active = 1

        flash( "Delete the master successfully!" )
        redirect( "/%s/index" % self.url )

    def searchMaster( self, kw ):
        try:
            if self.search_config :
                search_config = self.search_config
            else:
                search_config = {"description": ["description", str],
                                 "item_number": ["item_number", str],
                                 "name": ["name", str],
                                 "category": ["category", str],
                                 "category_id": ["category_id", int],
                                 "fit_id": ["fit_id", int],
                                 "division_id": ["division_id", int],
                                 "western_size": ["western_size", str],
                                 "japan_size": ["japan_size", str],
                                 "china_size": ["china_size", str],
                                 "trans_id": ["trans_id", str],
                                 }

            obj = DBSession.query( self.dbObj )

            for field, value in kw.items():
                if value:
                    if search_config[field][1] == str:
                        obj = obj.filter( getattr( self.dbObj.__table__.c, search_config.get( field, "" )[0] ).op( "ILIKE" )( "%%%s%%" % value ) )
                    elif search_config[field][1] == int:
                        obj = obj.filter( getattr( self.dbObj.__table__.c, search_config.get( field, "" )[0] ) == int( value ) )
                    else:
                        obj = obj.filter( getattr( self.dbObj.__table__.c, search_config.get( field, "" )[0] ) == value )
                else:
                    continue

            return obj.filter( self.dbObj.active == 0 ).order_by( self.dbObj.id ).all()
        except:
            file = open( 'log.txt', 'w' )
            traceback.print_exc( None, file )
            file.close()
            flash( "Error occurred at searching item!" )
            redirect( "/%s/index" % self.url )

    def beforeSaveNew( self, kw, params ):
        return params

    def afterSaveNew( self, obj, kw ):
        return obj

    def beforeSaveUpdate( self, kw, params ):
        return params

    def afterSaveUpdate( self, obj, kw ):
        return obj
