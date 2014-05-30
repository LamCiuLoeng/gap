# -*- coding: utf-8 -*-
import urllib
import urllib2
import json
import random

# turbogears imports
from tg import expose, redirect, validate, flash, session, request
from tg.decorators import *

# third party imports
from repoze.what import predicates, authorize
from repoze.what.predicates import not_anonymous, in_group, has_permission

# project specific imports
from gapproject.lib.base import BaseController
from gapproject.model import *


from gapproject.util.common import *
from gapproject.widgets.access import *
import traceback
from sqlalchemy.sql.expression import and_




class UserSearchForm( RPACForm ): fields = [ RPACText( "name", label_text = "User Name" ), ]
user_form = UserSearchForm()

class GroupSearchForm( RPACForm ): fields = [ RPACText( "name", label_text = "Role Name" ), ]
group_form = GroupSearchForm()


class PermissionSearchForm( RPACForm ): fields = [ RPACText( "name", label_text = "Permission Name" ), ]
permission_form = PermissionSearchForm()


class AccessController( BaseController ):
    # Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.in_group( 'Admin' )

    @expose( 'gapproject.templates.access' )
    @tabFocus( tab_type = "access" )
    def index( self, **kw ):
        return {}


    @expose( 'gapproject.templates.access.user' )
    @paginate( "result", items_per_page = 20 )
    @tabFocus( tab_type = "access" )
    def user( self, **kw ):
        if not kw.get( 'name', None ):
            result = DBSession.query( User ).filter( User.active == 0 ).order_by( User.user_name ).all()
        else:
            result = DBSession.query( User ).filter( User.__table__.c.user_name.op( "ilike" )( "%%%s%%" % kw["name"] ) ).order_by( User.user_name ).all()
        return {"widget" : user_form, "result" : result, "values" : kw}




    @expose( 'gapproject.templates.access.user_edit' )
    @tabFocus( tab_type = "access" )
    def user_add( self, **kw ):
        part1 = map( chr, random.sample( range( ord( 'a' ), ord( 'z' ) + 1 ), 2 ) )
        part2 = random.sample( range( 0, 10 ), 4 )
        part3 = random.sample( ["!", "@", "#", "$", "&", "*"], 1 )

        pw = "".join( map( unicode, part1 + part2 + part3 ) )

        groups = DBSession.query( Group ).filter( Group.active == 0 ).order_by( Group.group_name )
        return {'values' : {'ACTION':'NEW', 'password' : pw} , 'groups' : groups , 'usergroups' : [], }


    @expose( 'gapproject.templates.access.user_edit' )
    @tabFocus( tab_type = "access" )
    def user_edit( self, **kw ):
        uid = kw.get( 'id', None ) or None
        if not uid :
            flash( "No ID provided!" )
            return redirect( '/access/index' )
        values = {'id' : uid, 'ACTION' : 'UPDATE', 'brands' : []}
        user = DBSession.query( User ).get( uid )
        for f in ['user_name', 'password', 'display_name', 'email_address']:
            values[f] = getattr( user, f, '' ) or ''

        groups = DBSession.query( Group ).filter( Group.active == 0 ).order_by( Group.group_name )
        usergroups = [g.group_id for g in user.groups]
        try:
            info = DBSession.query( OnclAddress ).filter( and_( OnclAddress.active == 0 , OnclAddress.issuedById == uid ) ).one()
            for f in ["shipCompany", "shipAttn", "shipAddress", "shipAddress2", "shipAddress3", "shipCity", "shipState",
                      "shipZip", "shipCountry", "shipTel", "shipFax", "shipEmail", "shipRemark",
                      "billCompany", "billAttn", "billAddress", "billAddress2", "billAddress3", "billCity", "billState",
                      "billZip", "billCountry", "billTel", "billFax", "billEmail", "billRemark", ] :
                values[f] = getattr( info, f, '' ) or ''
        except:
            traceback.print_exc()
            pass
        return {'values' : values , 'groups' : groups , 'usergroups' : usergroups}


    @expose()
    def user_save( self, **kw ):
        action = kw.get( 'ACTION', None ) or None
        if action not in ['NEW', 'UPDATE'] :
            flash( 'No such action!' )
            return redirect( '/access/user' )

        if action == 'NEW':    # CREATE
            try:
                params = {}
                for f in ['user_name', 'password', 'display_name', 'email_address']:
                    params[f] = kw.get( f, None ) or None
                obj = User( **params )
                DBSession.add( obj )

                groups = kw.get( 'groups', [] ) or []
                if type( groups ) != list : groups = [groups, ]
                obj.groups = DBSession.query( Group ).filter( Group.group_id.in_( groups ) ).all()

                bsparams = {'issuedBy' : obj}
                for f in ["shipCompany", "shipAttn", "shipAddress", "shipAddress2", "shipAddress3", "shipCity", "shipState",
                      "shipZip", "shipCountry", "shipTel", "shipFax", "shipEmail", "shipRemark",
                      "billCompany", "billAttn", "billAddress", "billAddress2", "billAddress3", "billCity", "billState",
                      "billZip", "billCountry", "billTel", "billFax", "billEmail", "billRemark", ] :
                    bsparams[f] = kw.get( f, None ) or None
                DBSession.add( OnclAddress( **bsparams ) )

                result = self.synUser( 'add', obj )
                if not result : raise makeException( "Error when creating the user!" )
            except:
                traceback.print_exc()
                flash( "Error occur on the server side!" )
                return redirect( '/access/user' )
            else:
                flash( "Save successfully!" )
                return redirect( '/access/user' )

        else:    # UPDATE
            uid = kw.get( 'id', None ) or None
            if not uid :
                flash( 'No ID provided!' )
                return redirect( '/access/index' )
            try:
                obj = DBSession.query( User ).get( uid )
                for f in ['user_name', 'password', 'display_name', 'email_address']:
                    setattr( obj, f, kw.get( f, None ) or None )
                groups = kw.get( 'groups', [] ) or []
                if type( groups ) != list : groups = [groups, ]
                obj.groups = DBSession.query( Group ).filter( Group.group_id.in_( groups ) ).all()

                fields = ["shipCompany", "shipAttn", "shipAddress", "shipAddress2", "shipAddress3", "shipCity", "shipState",
                      "shipZip", "shipCountry", "shipTel", "shipFax", "shipEmail", "shipRemark",
                      "billCompany", "billAttn", "billAddress", "billAddress2", "billAddress3", "billCity", "billState",
                      "billZip", "billCountry", "billTel", "billFax", "billEmail", "billRemark", ]
                try:
                    info = DBSession.query( OnclAddress ).filter( and_( OnclAddress.active == 0 , OnclAddress.issuedById == obj.user_id ) ).one()
                    for f in fields : setattr( info, f, kw.get( f, None ) or None )
                except:
                    bsparams = {'issuedBy' : obj}
                    for f in fields : bsparams[f] = kw.get( f, None ) or None
                    DBSession.add( OnclAddress( **bsparams ) )


                result = self.synUser( 'update', obj )
                if not result : raise makeException( "Error when updating the user!" )

            except:
                traceback.print_exc()
                flash( "Error occur on the server side!" )
            else:
                flash( "Save successfully!" )
            return redirect( '/access/user' )



    @expose( 'gapproject.templates.access.group' )
    @paginate( "result", items_per_page = 20 )
    @tabFocus( tab_type = "access" )
    def group( self, **kw ):
        if not kw.get( 'name', None ):
            result = DBSession.query( Group ).filter( Group.active == 0 ).order_by( Group.group_name ).all()
        else:
            result = DBSession.query( Group ).filter( Group.__table__.c.group_name.op( "ilike" )( "%%%s%%" % kw["name"] ) ).order_by( Group.group_name ).all()
        return {"widget" : group_form, "result" : result, "values" : kw}


    @expose( 'gapproject.templates.access.group_manage' )
    @tabFocus( tab_type = "access" )
    def group_add( self, **kw ):
        excluded = DBSession.query( User ).order_by( User.user_name )
        lost = DBSession.query( Permission ).order_by( Permission.order )

        return {"widget" : group_update_form , "values" : { "id" : "", "group_name" : "", "display_name" : "", "ACTION" : 'NEW' },
                "included" : [] , "excluded" : excluded,
                "got" : [], "lost" : lost , 'showuser' : bool( kw.get( 'U', None ) )}



    @expose( 'gapproject.templates.access.group_manage' )
    @tabFocus( tab_type = "access" )
    def group_manage( self, **kw ):
        g = getOr404( Group, kw["id"] )
        included = g.users
        excluded = DBSession.query( User ).filter( ~User.groups.any( Group.group_id == g.group_id ) ).order_by( User.user_name )
        got = g.permissions
        lost = DBSession.query( Permission ).filter( ~Permission.groups.any( Group.group_id == g.group_id ) ).order_by( Permission.order )
        return {"widget" : group_update_form , "values" : { "id" : g.group_id, "group_name" : g.group_name , "display_name" : g.display_name, "ACTION" : "UPDATE" },
                "included" : included , "excluded" : excluded,
                "got" : got, "lost" : lost , 'showuser' : bool( kw.get( 'U', None ) )}


    @expose()
    def save_group( self, **kw ):
        gid = kw.get( 'id', None ) or None
        name = kw.get( 'group_name', None ) or None
        display_name = kw.get( 'display_name', None ) or None
        if not gid:
            g = Group( group_name = name, display_name = display_name )
            DBSession.add( g )
        else:
            g = DBSession.query( Group ).get( gid )
            g.group_name = name
            g.display_name = display_name
        uigs = kw.get( "uigs", '' )
        pigs = kw.get( "pigs", '' )

        if kw.get( 'U', None ):
            if not uigs : g.users = []
            else : g.users = DBSession.query( User ).filter( User.user_id.in_( uigs.split( "|" ) ) ).all()

        if not pigs : g.permissions = []
        else : g.permissions = DBSession.query( Permission ).filter( Permission.permission_id.in_( pigs.split( "|" ) ) ).all()

        flash( "Save the update successfully!" )
        redirect( "/access/group" )





    @expose( "gapproject.templates.access.permission" )
    @paginate( "result", items_per_page = 20 )
    @tabFocus( tab_type = "access" )
    def permission( self, **kw ):
        if not kw.get( 'name', None ):
            result = DBSession.query( Permission ).order_by( Permission.permission_name ).all()
        else:
            result = DBSession.query( Permission ).filter( Permission.__table__.c.permission_name.op( "ilike" )( "%%%s%%" % kw["name"] ) ).order_by( Permission.permission_name ).all()
        return {"widget" : permission_form, "result" : result, "values" : kw}



    @expose( 'gapproject.templates.access.permission_manage' )
    @tabFocus( tab_type = "access" )
    def permission_add( self, **kw ):
        excluded = DBSession.query( Group ).filter( Group.active == 0 ).order_by( Group.group_name )
        return {"widget" : permission_update_form,
                "values" : {"id" : '', "permission_name" : ''},
                "included" : [],
                "excluded" : excluded
                }



    @expose( "gapproject.templates.access.permission_manage" )
    @tabFocus( tab_type = "access" )
    def permission_manage( self, **kw ):
        p = getOr404( Permission, kw["id"] )

        included = p.groups
        excluded = DBSession.query( Group ).filter( ~Group.permissions.any( Permission.permission_id == p.permission_id ) ).order_by( Group.group_name )

        return {"widget" : permission_update_form,
                "values" : {"id" : p.permission_id, "permission_name" : p.permission_name},
                "included" : included,
                "excluded" : excluded
                }

    expose()
    def save_permission( self, **kw ):
        pid = kw.get( 'id', None ) or None

        if not pid :
            p = Permission( permission_name = kw.get( 'permission_name', None ) or None )
        else:
            p = DBSession.query( Permission ).get( pid )
            p.permission_name = kw["permission_name"]

        if not kw["igs"] : p.groups = []
        else : p.groups = DBSession.query( Group ).filter( Group.group_id.in_( kw["igs"].split( "|" ) ) ).all()
        flash( "Save the update successfully!" )
        redirect( "/access/index" )


    @expose( 'json' )
    def ajaxCheck( self, **kw ):
        k, v = kw.get( 'k', None ), kw.get( 'v', None )
        if k not in ['USER', 'GROUP'] : return {'code' : 1 , 'msg' : 'No such action!'}

        if k == 'USER' :
            try:
                obj = DBSession.query( User ).filter( User.user_name.op( 'ilike' )( v ) ).one()
                if kw.get( 'action', None ) == 'NEW' : return {'code' : 1, 'msg' : 'Duplicated user name!'}
                elif kw.get( 'action', None ) == 'UPDATE':
                    if unicode( obj.user_id ) == kw.get( 'id', None ) : return {'code' : 0}
                    else: return {'code' : 1, 'msg' : 'Duplicated user name!'}
                else : return {'code' : 1 , 'msg' : 'No such action!'}
            except:
                return {'code' : 0}

        elif k == 'GROUP':
            try:
                obj = DBSession.query( Group ).filter( Group.group_name.op( 'ilike' )( v ) ).one()
                if kw.get( 'action', None ) == 'NEW' : return {'code' : 1, 'msg' : 'Duplicated group name!'}
                elif kw.get( 'action', None ) == 'UPDATE':
                    if unicode( obj.group_id ) == kw.get( 'id', None ) : return {'code' : 0}
                    else: return {'code' : 1, 'msg' : 'Duplicated group name!'}
                else : return {'code' : 1 , 'msg' : 'No such action!'}

            except:
                return {'code' : 0}



    def synUser( self , action, obj ):
        url = config.get( 'price_ticket_url' )
        user_agent = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'
        values = {
                  'action' : action ,
                  'uname' : obj.user_name,
                  'pwd' : obj.password,
                  'dname' : obj.display_name,
                  'email' : obj.email_address,
                  'code' : obj.code,
                  }
        headers = { 'User-Agent' : user_agent }
        data = urllib.urlencode( values )
        req = urllib2.Request( url, data, headers )
        response = urllib2.urlopen( req )
        result = response.read()
        print '-*' * 10
        print result
        print '~*' * 10
        v = json.loads( result )
        return v.get( 'Message', None ) == 'success'



    '''
    @expose('gapproject.templates.access.index')
    @paginate("result", items_per_page=20)
    @tabFocus(tab_type="access")
    def index(self, **kw):
        if not kw:
            result = []
        else:
            result = DBSession.query(User).filter(User.__table__.c.user_name.op("ilike")("%%%s%%" % kw["user_name"])).order_by(User.user_name).all()
        return {"widget" : access_search_form, "result" : result}




    @expose()
    def save_new(self, **kw):
        if kw["type"] == "user" :
            password = kw["password"] if kw["password"] else gerRandomStr(8, allAlpha)
            u = User(user_name=kw["user_name"], display_name=kw["display_name"], email_address=kw["email_address"], password=password)
            DBSession.add(u)
            DBSession.flush()
            redirect("/access/user_manage?id=%d" % u.user_id)
        elif kw["type"] == "group" :
            g = Group(group_name=kw["group_name"])
            DBSession.add(g)
            DBSession.flush()
            redirect("/access/group_manage?id=%d" % g.group_id)
        elif kw["type"] == "permission" :
            p = Permission(permission_name=kw["permission_name"], description=kw["description"])
            ag = DBSession.query(Group).filter_by(group_name="Admin").one()
            ag.permissions.append(p)
            DBSession.add(p)
            DBSession.flush()
            redirect("/access/permission_manage?id=%d" % p.permission_id)
        else:
            flash("No such type operation!")
            redirect("/access/index")


    @expose("gapproject.templates.access.user_manage")
    def user_manage(self, **kw):
        u = getOr404(User, kw["id"])
        included = u.groups
        excluded = DBSession.query(Group).filter(~Group.users.any(User.user_id == u.user_id)).order_by(Group.group_name)
        return {
                "widget" : user_update_form,
                "values" : {"id" : u.user_id, "user_name" : u.user_name, "email_address" : u.email_address, "display_name" : u.display_name},
                "included" : included,
                "excluded" : excluded,
                }

    @expose()
    def save_user(self, **kw):
        u = getOr404(User, kw["id"])
        if kw.get("user_name", None) : u.user_name = kw["user_name"]
        if kw.get("password", None) : u.password = kw["password"]
        if kw.get("display_name", None) : u.display_name = kw["display_name"]
        if kw.get("email_address", None) : u.email_address = kw["email_address"]

        if not kw["igs"] : u.groups = []
        else : u.groups = DBSession.query(Group).filter(Group.group_id.in_(kw["igs"].split("|"))).all()
        flash("Save the update successfully!")
        redirect("/access/index")





    @

    


    @expose("gapproject.templates.access.test")
    def test(self, **kw):
        return {}
    '''
