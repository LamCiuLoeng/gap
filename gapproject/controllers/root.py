# -*- coding: utf-8 -*-
import re
import traceback
import logging

from datetime import datetime as dt
import random, traceback, transaction
from tg import expose, flash, require, url, request, redirect, config
from repoze.what import predicates
from repoze.what.predicates import not_anonymous, in_group

from gapproject.lib.base import BaseController
from gapproject.model import DBSession, metadata
from gapproject import model
from gapproject.util.common import *
from gapproject.controllers import *

from gapproject.controllers.access import *
from gapproject.controllers.master import *
from gapproject.controllers.order import *
from gapproject.controllers.importOrder import *
from gapproject.controllers.inventory import *
from gapproject.controllers.enquiry import *

# for new design
from gapproject.controllers.receive import *
from gapproject.controllers.ship import *
from gapproject.controllers.stock_adjustment import *
from gapproject.controllers.uploadsi import *
from gapproject.controllers.cireport import *
from gapproject.controllers.voreport import *
from gapproject.controllers.irreport import *
from gapproject.controllers.carelabelOrder import *
from gapproject.controllers.onCarelabelOrder import *
from gapproject.controllers.onSize import OnclSizeController
from gapproject.controllers.onFit import OnclFitController


# pdf label
from gapproject.controllers.pdf import *

logger = logging.getLogger( __name__ )

__all__ = ['RootController']

import thread
myLock = thread.allocate_lock()


class RootController( BaseController ):

    access = AccessController()
    category = CategoryController()
    item = ItemController()
    region = RegionController()
    price = PriceController()
    contact = ContactController()
    warehouse = WarehouseController()
    order = OrderController()
    importOrder = ImportOrderController()

    inventory = InventoryController()
    enquiry = EnquiryController()
    # for new design
    receive = ReceiveController()
    ship = ShipController()
    stockAdjustment = StockAdjustmentController()
    uploadsi = UploadSiController()

    billto = BillToController()
    shipto = ShipToController()
    viewOrder = OrderViewController()

    cireport = CiReportController()
    voreport = VoReportController()
    irreport = IrreportController()
    carelabel = CarelabelOrderController()
    oncl = OldNavyCarelabelOrderController()

    # RFID
    oncldivision = OnclDivisionController()
    onclcategory = OnclCategoryController()
#     onclsize = OnclSizeController()
    onclsize = OnclSizeController()
    onclfit = OnclFitController()
    careinstruction = CareInstructionController()
    chinaproductname = ChinaProductNameController()
    country = CountryController()
    fiber = FiberController()
    finishesweave = FinishesWeaveController()
    fitsdescription = FitsDescriptionController()
    sectionalcallout = SectionalCallOutController()
    warning = WarningController()


    # pdf label
    getpdf = PDFController()
    pdflayout = PDFLayoutController()



    @require( not_anonymous() )
    @expose( 'gapproject.templates.index' )
    @tabFocus( tab_type = "main" )
    def index( self ):
        return dict( page = 'index' )

    @require( not_anonymous() )
    @expose( 'gapproject.templates.tracking' )
    @tabFocus( tab_type = "view" )
    def tracking( self ):
        return {}

    @require( not_anonymous() )
    @expose( 'gapproject.templates.report' )
    @tabFocus( tab_type = "report" )
    def report( self ):
        return {}

    @expose( 'gapproject.templates.login' )
    def login( self, came_from = url( '/' ) ):
        """Start the user login."""
        if request.identity: redirect( came_from )

        login_counter = request.environ['repoze.who.logins']
        if login_counter > 0:
            flash( 'Wrong credentials', 'warning' )
        return dict( page = 'login', login_counter = str( login_counter ), came_from = came_from )

    @expose()
    def post_login( self, came_from = url( '/' ) ):
        if not request.identity:
            login_counter = request.environ['repoze.who.logins'] + 1
            redirect( url( '/login', came_from = came_from, __logins = login_counter ) )
        userid = request.identity['repoze.who.userid']
#        flash('Welcome back, %s!' % userid)
        redirect( came_from )

    @expose()
    def post_logout( self, came_from = url( '/' ) ):
#        flash('We hope to see you soon!')
        redirect( url( "/" ) )

    @require( not_anonymous() )
    @expose( 'gapproject.templates.page_master' )
    @tabFocus( tab_type = "master" )
    def master( self ):
        """Handle the front-page."""
        return {}


    @expose( "gapproject.templates.register" )
    def register( self, **kw ):
        return {}


    @expose()
    def save_register( self, **kw ):
        errMsg = []
        emailReg = "^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"

        if not kw.get( "email_address", False ):
            errMsg.append( "E-mail address can't be blank!" )
        elif not re.search( emailReg, kw["email_address"] ):
            errMsg.append( "E-mail address is in a wrong format!" )

        if not kw.get( "billing_name", False ):
            errMsg.append( "Billing Name can't be blank" )

        if not kw.get( "billing_address", False ):
            errMsg.append( "Billing Address can't be blank" )

        if not kw.get( "contact_name", False ):
            errMsg.append( "Contact Name can't be blank" )

        if not kw.get( "phone_number", False ):
            errMsg.append( "Phone Number can't be blank" )

        if errMsg:
            msg = "<ul>"
            for m in errMsg: msg += "<li>" + m + "</li>"
            msg += "</ul>"

            flash( msg, "warn" )
            redirect( "/register" )

        try:
            g = DBSession.query( Group ).filter_by( group_name = "Customer" ).one()
        except:
            g = Group( group_name = "Customer" )
            DBSession.add( g )

        u = User( 
            # user_name=kw["user_name"].strip(),
            email_address = kw["email_address"].strip(),
            # password=kw["password"].strip(),
            billing_name = kw["billing_name"].strip(),
            billing_address = kw["billing_address"].strip(),
            contact_name = kw["contact_name"].strip(),
            phone_number = kw["phone_number"].strip(),
            # display_name=kw["billing_name"].strip(),
            # active=1
            )

        try:
            g.users.append( u )
            DBSession.add( u )
            DBSession.flush()
        except:
            traceback.print_exc()
            flash( "There service is not avaiable now, please try it later.", status = "warn" )
            redirect( "/register" )
        else:
            # send email to Jeremy / Maureen / Agnis / Cheryl
            send_from = "r-pac-GAP-ordering-system"
            send_to = config.get( "registration_email_to", "" ).split( ";" )
            cc_to = config.get( "registration_email_cc", "" ).split( ";" )
            subject = "Registration"
            text = ["Hi all:\n",
                    "Please confirm GAP vendor registration info!",
                    "\nHere's vendor registration info:",
                    "\nVendor Billing Name:  %s" % kw["billing_name"],
                    "\nVendor Billing Address:  %s" % kw["billing_address"],
                    "\nVendor Contact Name:  %s" % kw["contact_name"],
                    "\nVendor email address:  %s" % kw["email_address"],
                    "\nVendor Phone Number:  %s" % kw["phone_number"],
                    "\n\n*****Please do not reply this email.*********"
                    ]
            sendEmail( send_from, send_to, subject, "\n".join( text ), cc_to )
            # send email to vendor
            send_from = "r-pac-GAP-ordering-system"
            send_to = [kw["email_address"], ]
            subject = "Registration"
            text = ["Dear Customer:\n",
                    "Congratulation.",
                    "Your registration on the r-pac GAP ordering system have completed successfully.",
                    "If validated, you would receive an email with your login & password.",
                    "\nThanks.",
                    "r-pac International Corp."
                    "\n\n*****Please do not reply this email.*********"
                    ]

            sendEmail( send_from, send_to, subject, "\n".join( text ) )

            flash( "Thank you for your registration! If validated, you would receive an email with your login & password." )
            redirect( "/login" )



    @require( not_anonymous() )
    @expose( 'gapproject.templates.help' )
    @tabFocus( tab_type = "help" )
    def help( self, **kw ):
        shops = DBSession.query( OnclPrintShop ).filter( and_( OnclPrintShop.active == 0 ) ).order_by( OnclPrintShop.id )
        return {'shops' : shops}
