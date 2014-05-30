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
from gapproject.util.excel_helper import ONCLSizeExcel
from gapproject.util.common import logError, ReportGenerationException, \
    serveFile, tabFocus


__all__ = ['OnclSizeController', ]

class OnclSizeController( BaseController ):

    allow_only = authorize.not_anonymous()

    @expose( "gapproject.templates.master.index_onclsize" )
    @paginate( "result", items_per_page = 30 )
    @tabFocus( tab_type = "master" )
    def index( self, **kw ):
        values = {
                  'division_id' : kw.get( 'division_id', None ) or None,
                  'category_id' : kw.get( 'category_id', None ) or None
                  }
        cds = [
               OnclSize.active == 0 , OnclDivision.active == 0 , OnclCategory.active == 0,
               OnclSize.category_id == OnclCategory.id, OnclCategory.division_id == OnclDivision.id,
               ]

        if values['division_id']:
            cds.append( OnclDivision.id == values['division_id'] )
            cats = DBSession.query( OnclCategory ).filter( and_( OnclCategory.active == 0,
                                                      OnclCategory.division_id == values['division_id'] ) ).order_by( OnclCategory.name )
        else:
            cats = []

        if values['category_id']:
            cds.append( OnclCategory.id == values['category_id'] )

        result = DBSession.query( OnclDivision, OnclCategory, OnclSize ).filter( and_( *cds ) ).order_by( OnclDivision.name,
                                                                                                          OnclCategory.name,
                                                                                                          OnclSize.fit_id,
                                                                                                          OnclSize.us_size )

        divs = DBSession.query( OnclDivision ).filter( and_( OnclDivision.active == 0 ) ).order_by( OnclDivision.name )
        return {'result' : result, 'divs' : divs , 'cats' : cats, 'values' : values }


    @expose( "gapproject.templates.master.onclsize_form" )
    @tabFocus( tab_type = "master" )
    def add( self, **kw ):
        divs = DBSession.query( OnclDivision ).filter( and_( OnclDivision.active == 0 ) ).order_by( OnclDivision.name )
        return {'divs' : divs , 'cats' : [], 'fits' : [] , 'values' : {}}


    @expose( "gapproject.templates.master.onclsize_form" )
    @tabFocus( tab_type = "master" )
    def update( self, **kw ):
        sid = kw.get( 'id', None )
        if not sid :
            flash( "No ID proficed" )
            return redirect( "index" )
        obj = DBSession.query( OnclSize ).get( sid )
        values = {}
        for f in ['id', 'category_id', 'fit_id', 'us_size', 'china_size', 'japan_size', 'canada_size', 'spanish_size']: values[f] = getattr( obj, f, '' ) or ''
        if obj.category_id :
            values['division_id'] = obj.category.division_id
            cats = DBSession.query( OnclCategory ).filter( and_( OnclCategory.active == 0,
                                                          OnclCategory.division_id == obj.category.division_id ) ).order_by( OnclCategory.name )
        else:
            cats = []
        divs = DBSession.query( OnclDivision ).filter( and_( OnclDivision.active == 0 ) ).order_by( OnclDivision.name )
        fits = DBSession.query( OnclFit ).filter( and_( OnclFit.active == 0, OnclFit.category_id == obj.category_id ) ).order_by( OnclFit.name )
        return {'values' : values, 'divs' : divs , 'cats' : cats, 'fits' : fits}



    @expose()
    def save( self, **kw ):
        oid = kw.get( 'id', None ) or None
        fields = ['category_id', 'fit_id', 'us_size', 'china_size', 'japan_size', 'canada_size', 'spanish_size']
        try:
            if not oid :    # save new
                params = {}
                for f in fields : params[f] = kw.get( f, None ) or None
                DBSession.add( OnclSize( **params ) )
            else:    # it's update
                obj = DBSession.query( OnclSize ).get( oid )
                for f in fields : setattr( obj, f, kw.get( f, None ) or None )
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
            obj = DBSession.query( OnclSize ).get( sid )
            obj.active = 1
            return {'code' : 0 , 'msg' : 'Delete the record successfully!'}
        except:
            traceback.print_exc()
            return {'code' : 1 , 'msg' : 'Error occur on the sever side!'}


    @expose( 'json' )
    def ajaxdep( self, **kw ):
        try:
            division_id = kw.get( 'division_id', None )
            if not division_id: return {'code' : 0 , 'd' : [] }
            result = DBSession.query( OnclCategory ).filter( and_( OnclCategory.active == 0, OnclCategory.division_id == division_id ) ).order_by( OnclCategory.name )

            data = [( d.id, unicode( d ) ) for d in result]
            return {'code' : 0 , 'd' : data }
        except:
            return {'code' : 1 , 'd' : [], 'msg' : 'Error occur on the sever side!' }


    @expose( 'json' )
    def ajaxcat( self, **kw ):
        try:
            cat_id = kw.get( 'cat_id', None )
            if not cat_id: return {'code' : 0 , 'd' : [] }
            result = DBSession.query( OnclFit ).filter( and_( OnclFit.active == 0, OnclFit.category_id == cat_id ) ).order_by( OnclFit.name )

            data = [( d.id, unicode( d ) ) for d in result]
            return {'code' : 0 , 'd' : data }
        except:
            return {'code' : 1 , 'd' : [], 'msg' : 'Error occur on the sever side!' }


    @expose()
    def export( self, **kw ):
        values = {
                  'division_id' : kw.get( 'division_id', None ) or None,
                  'category_id' : kw.get( 'category_id', None ) or None
                  }
        cds = [
               OnclSize.active == 0 , OnclDivision.active == 0 , OnclCategory.active == 0,
               OnclSize.category_id == OnclCategory.id, OnclCategory.division_id == OnclDivision.id,
               ]

        if values['division_id']: cds.append( OnclDivision.id == values['division_id'] )

        if values['category_id']:  cds.append( OnclCategory.id == values['category_id'] )

        result = DBSession.query( OnclDivision, OnclCategory, OnclSize ).filter( and_( *cds ) ).order_by( OnclDivision.name,
                                                                                                          OnclCategory.name,
                                                                                                          OnclSize.fit_id,
                                                                                                          OnclSize.us_size )

        data = [map( unicode, ( d, c, s.fit or '', s.us_size, s.china_size, s.japan_size ) ) for ( d, c, s ) in result]

        templatePath = os.path.join( config.get( "template_dir" ), "GAP_SIZE_MASTER_TEMPLATE.xlsx" )
        current = dt.now()
        dateStr = current.strftime( "%Y%m%d" )
        fileDir = os.path.join( config.get( "public_dir" ), "excel", dateStr )
        if not os.path.exists( fileDir ): os.makedirs( fileDir )
        tempFileName = os.path.join( fileDir, "%s_%s_%d.xlsx" % ( 
                                                                 request.identity["user"].user_name,
                                                           current.strftime( "%Y%m%d%H%M%S" ), random.randint( 0, 1000 ) ) )
        realFileName = os.path.join( fileDir, "oldnavy_size_%s.xlsx" % current.strftime( "%Y%m%d%H%M%S" ) )
        shutil.copy( templatePath, tempFileName )
        try:
            sdexcel = ONCLSizeExcel( templatePath = tempFileName, destinationPath = realFileName )
            sdexcel.inputData( data )
            sdexcel.outputData()
        except Exception, e:
            traceback.print_exc()
            logError()
            if sdexcel:sdexcel.clearData()
            raise ReportGenerationException()
        else:
            return serveFile( realFileName )
