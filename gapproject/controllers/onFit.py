# -*- coding: utf-8 -*-
'''
Created on 2013-11-25
@author: CL.lam
'''
import traceback, os, shutil, random
from datetime import datetime as dt
from gapproject.lib.base import BaseController
from tg.decorators import expose
from tg import flash, redirect, config, request
from sqlalchemy.sql.expression import and_
from tg.decorators import paginate
from repoze.what import authorize


from gapproject.model import DBSession
from gapproject.model.size_label import OnclSize, OnclDivision, OnclCategory, \
    OnclFit
from gapproject.util.common import logError, tabFocus



__all__ = ['OnclFitController', ]

class OnclFitController( BaseController ):

    allow_only = authorize.not_anonymous()

    @expose( "gapproject.templates.master.index_onclfit" )
    @paginate( "result", items_per_page = 30 )
    @tabFocus( tab_type = "master" )
    def index( self, **kw ):
        values = {
                  'division_id' : kw.get( 'division_id', None ) or None,
                  'category_id' : kw.get( 'category_id', None ) or None
                  }
        cds = [
               OnclFit.active == 0 , OnclDivision.active == 0 , OnclCategory.active == 0,
               OnclFit.category_id == OnclCategory.id, OnclCategory.division_id == OnclDivision.id,
               ]

        if values['division_id']:
            cds.append( OnclDivision.id == values['division_id'] )
            cats = DBSession.query( OnclCategory ).filter( and_( OnclCategory.active == 0,
                                                      OnclCategory.division_id == values['division_id'] ) ).order_by( OnclCategory.name )
        else:
            cats = []

        if values['category_id']:
            cds.append( OnclCategory.id == values['category_id'] )

        result = DBSession.query( OnclDivision, OnclCategory, OnclFit ).filter( and_( *cds ) ).order_by( OnclDivision.name,
                                                                                                          OnclCategory.name,
                                                                                                          OnclFit.name
                                                                                                          )
        divs = DBSession.query( OnclDivision ).filter( and_( OnclDivision.active == 0 ) ).order_by( OnclDivision.name )
        return {'result' : result, 'divs' : divs , 'cats' : cats, 'values' : values }


    @expose( "gapproject.templates.master.onclfit_form" )
    @tabFocus( tab_type = "master" )
    def add( self, **kw ):
        divs = DBSession.query( OnclDivision ).filter( and_( OnclDivision.active == 0 ) ).order_by( OnclDivision.name )
        return {'divs' : divs , 'cats' : [], 'values' : {}}


    @expose( "gapproject.templates.master.onclfit_form" )
    @tabFocus( tab_type = "master" )
    def update( self, **kw ):
        sid = kw.get( 'id', None )
        if not sid :
            flash( "No ID proficed" )
            return redirect( "index" )
        obj = DBSession.query( OnclFit ).get( sid )
        values = {}
        for f in ['id', 'category_id', 'name']: values[f] = getattr( obj, f, '' ) or ''
        values['division_id'] = obj.category.division_id if obj.category_id and obj.category.division_id else None

        divs = DBSession.query( OnclDivision ).filter( and_( OnclDivision.active == 0 ) ).order_by( OnclDivision.name )
        if values['division_id'] :
            cats = DBSession.query( OnclCategory ).filter( and_( OnclCategory.active == 0, OnclCategory.division_id == values['division_id'] ) ).order_by( OnclCategory.name )
        else: cats = []

        return {'values' : values, 'divs' : divs , 'cats' : cats, }




    @expose()
    def save( self, **kw ):
        oid = kw.get( 'id', None ) or None
        fields = ['category_id', 'name', ]
        try:
            if not oid :    # save new
                params = {}
                for f in fields : params[f] = kw.get( f, None ) or None
                DBSession.add( OnclFit( **params ) )
            else:    # it's update
                obj = DBSession.query( OnclFit ).get( oid )
                for f in fields : setattr( obj, f, kw.get( f, None ) or None )
                # update the related size as well
                DBSession.query( OnclSize ).filter( and_( OnclSize.active == 0, OnclSize.fit_id == obj.id ) ).update( {'category_id' : obj.category_id} )
        except:
            traceback.print_exc()
            flash( "Error occur when saving the data!" )
        else:
            flash( "Save successfully!" )
        return redirect( 'index' )


    @expose( 'json' )
    def ajaxDel( self, **kw ):
        try:
            sid = kw.get( 'id', None )
            if not sid :
                flash( "No ID proficed" )
                return redirect( "index" )
            obj = DBSession.query( OnclFit ).get( sid )
            obj.active = 1
            DBSession.query( OnclSize ).filter( OnclSize.fit_id == obj.id ).update( {'active' : 1} )    # delte the related size also
            return {'code' : 0 , 'msg' : 'Delete the record successfully!'}
        except:
            traceback.print_exc()
            return {'code' : 1 , 'msg' : 'Error occur on the sever side!'}

