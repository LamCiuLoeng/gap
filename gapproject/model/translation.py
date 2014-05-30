# -*- coding: utf-8 -*-
"""Sample model module."""
from datetime import datetime as dt

from tg import request

from sqlalchemy import *
from sqlalchemy.orm import mapper, relation, backref
from sqlalchemy import Table, ForeignKey, Column
from sqlalchemy.types import Integer, Unicode
# from sqlalchemy.orm import relation, backref
from sqlalchemy.sql.functions import sum, max, min

from gapproject.model import DeclarativeBase, metadata, DBSession
from gapproject.model.auth import User

from gapproject.util.gap_const import *


__all__ = ['CareInstruction', 'ChinaProductName', 'Country', 'Fiber',
            'FinishesWeave', 'FitsDescription', 'SectionalCallOut', 'Warning']

# GAP Translations

def getUserID():
    user_id = 1
    try:
         user_id = request.identity['user'].user_id
    except:
        pass
    finally:
        return user_id


# Care Instructions - Translation ---------------------------
class CareInstruction( DeclarativeBase ):
    __tablename__ = 'trans_care_instructions'

    id = Column( Integer, primary_key = True )

    trans_id = Column( Unicode( 20 ) )
    english_term = Column( Unicode( 1000 ) )
    context = Column( Unicode( 1000 ) )
    arabic = Column( Unicode( 1000 ) )
    bahasa_indonesia = Column( Unicode( 1000 ) )
    bulgarian = Column( Unicode( 1000 ) )
    chinese = Column( Unicode( 1000 ) )
    croatian = Column( Unicode( 1000 ) )
    french = Column( Unicode( 1000 ) )
    french_canada = Column( Unicode( 1000 ) )
    german = Column( Unicode( 1000 ) )
    greek = Column( Unicode( 1000 ) )
    hungarian = Column( Unicode( 1000 ) )
    italian = Column( Unicode( 1000 ) )
    japanese = Column( Unicode( 1000 ) )
    kazakh = Column( Unicode( 1000 ) )
    korean = Column( Unicode( 1000 ) )
    polish = Column( Unicode( 1000 ) )
    portuguese = Column( Unicode( 1000 ) )
    romanian = Column( Unicode( 1000 ) )
    russian = Column( Unicode( 1000 ) )
    serbian = Column( Unicode( 1000 ) )
    spanish = Column( Unicode( 1000 ) )
    turkish = Column( Unicode( 1000 ) )
    ukrainian = Column( Unicode( 1000 ) )

    symbols = Column( Unicode( 50 ), default = u'0|0' )
    subtype = Column( Text )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive



    def __unicode__( self ):
        return self.english_term

    def __str__( self ):
        return self.english_term


    @classmethod
    def populate( clz, ids ):
        enc , frc, jpc, chc, ind = [], [], [], [], []
        cinfo = {}
        for c in DBSession.query( clz ).filter( and_( clz.id.in_( ids ) ) ): cinfo[unicode( c.id )] = c
        for _id in ids:
            if _id not in cinfo : continue
            c = cinfo[_id]
            enc.append( c.english_term or '' )
            frc.append( c.french_canada or '' )
            ind.append( c.bahasa_indonesia or '' )
            jpc.append( c.japanese or '' )
            chc.append( c.chinese or '' )
#            arc.append( c.arabic or '' )
        return [enc , frc, ind, jpc, chc]




# China Product Names - Trans ---------------------------
class ChinaProductName( DeclarativeBase ):
    __tablename__ = 'trans_china_product_names'

    id = Column( Integer, primary_key = True )

    trans_id = Column( Unicode( 20 ) )
    english_term = Column( Unicode( 1000 ) )
    context = Column( Unicode( 1000 ) )
    chinese_traditional_taiwan = Column( Unicode( 1000 ) )
    hungarian = Column( Unicode( 1000 ) )
    uk_english = Column( Unicode( 1000 ) )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ):
        return self.name

    def __str__( self ):
        return self.name


# Country - Translation ---------------------------
class Country( DeclarativeBase ):
    __tablename__ = 'trans_country'

    id = Column( Integer, primary_key = True )

    trans_id = Column( Unicode( 20 ) )
    english_term = Column( Unicode( 1000 ) )
    context = Column( Unicode( 1000 ) )
    arabic = Column( Unicode( 1000 ) )
    bahasa_indonesia = Column( Unicode( 1000 ) )
    bulgarian = Column( Unicode( 1000 ) )
    chinese = Column( Unicode( 1000 ) )
    chinese_traditional_taiwan = Column( Unicode( 1000 ) )
    croatian = Column( Unicode( 1000 ) )
    french = Column( Unicode( 1000 ) )
    french_canada = Column( Unicode( 1000 ) )
    german = Column( Unicode( 1000 ) )
    greek = Column( Unicode( 1000 ) )
    hungarian = Column( Unicode( 1000 ) )
    italian = Column( Unicode( 1000 ) )
    japanese = Column( Unicode( 1000 ) )
    kazakh = Column( Unicode( 1000 ) )
    korean = Column( Unicode( 1000 ) )
    polish = Column( Unicode( 1000 ) )
    portuguese = Column( Unicode( 1000 ) )
    romanian = Column( Unicode( 1000 ) )
    russian = Column( Unicode( 1000 ) )
    serbian = Column( Unicode( 1000 ) )
    spanish = Column( Unicode( 1000 ) )
    turkish = Column( Unicode( 1000 ) )
    ukrainian = Column( Unicode( 1000 ) )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ):
        return self.english_term

    def __str__( self ):
        return self.english_term


# Fibers - Translation ---------------------------
class Fiber( DeclarativeBase ):
    __tablename__ = 'trans_fibers'

    id = Column( Integer, primary_key = True )

    trans_id = Column( Unicode( 20 ) )
    english_term = Column( Unicode( 1000 ) )
    context = Column( Unicode( 1000 ) )
    arabic = Column( Unicode( 1000 ) )
    bahasa_indonesia = Column( Unicode( 1000 ) )
    bulgarian = Column( Unicode( 1000 ) )
    chinese = Column( Unicode( 1000 ) )
    chinese_traditional_taiwan = Column( Unicode( 1000 ) )
    croatian = Column( Unicode( 1000 ) )
    french = Column( Unicode( 1000 ) )
    french_canada = Column( Unicode( 1000 ) )
    german = Column( Unicode( 1000 ) )
    greek = Column( Unicode( 1000 ) )
    hungarian = Column( Unicode( 1000 ) )
    italian = Column( Unicode( 1000 ) )
    japanese = Column( Unicode( 1000 ) )
    kazakh = Column( Unicode( 1000 ) )
    korean = Column( Unicode( 1000 ) )
    polish = Column( Unicode( 1000 ) )
    portuguese = Column( Unicode( 1000 ) )
    romanian = Column( Unicode( 1000 ) )
    russian = Column( Unicode( 1000 ) )
    serbian = Column( Unicode( 1000 ) )
    spanish = Column( Unicode( 1000 ) )
    turkish = Column( Unicode( 1000 ) )
    uk_english = Column( Unicode( 1000 ) )
    ukrainian = Column( Unicode( 1000 ) )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ):
        return self.english_term

    def __str__( self ):
        return self.english_term


# Finishes-Weaves Translation ---------------------------
class FinishesWeave( DeclarativeBase ):
    __tablename__ = 'trans_finishes_weaves'

    id = Column( Integer, primary_key = True )

    trans_id = Column( Unicode( 20 ) )
    english_term = Column( Unicode( 1000 ) )
    context = Column( Unicode( 1000 ) )
    arabic = Column( Unicode( 1000 ) )
    bahasa_indonesia = Column( Unicode( 1000 ) )
    bulgarian = Column( Unicode( 1000 ) )
    chinese_traditional_taiwan = Column( Unicode( 1000 ) )
    croatian = Column( Unicode( 1000 ) )
    french = Column( Unicode( 1000 ) )
    french_canada = Column( Unicode( 1000 ) )
    german = Column( Unicode( 1000 ) )
    greek = Column( Unicode( 1000 ) )
    hungarian = Column( Unicode( 1000 ) )
    italian = Column( Unicode( 1000 ) )
    japanese = Column( Unicode( 1000 ) )
    kazakh = Column( Unicode( 1000 ) )
    korean = Column( Unicode( 1000 ) )
    polish = Column( Unicode( 1000 ) )
    portuguese = Column( Unicode( 1000 ) )
    romanian = Column( Unicode( 1000 ) )
    russian = Column( Unicode( 1000 ) )
    serbian = Column( Unicode( 1000 ) )
    spanish = Column( Unicode( 1000 ) )
    turkish = Column( Unicode( 1000 ) )
    uk_english = Column( Unicode( 1000 ) )
    ukrainian = Column( Unicode( 1000 ) )


    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ):
        return self.english_term

    def __str__( self ):
        return self.english_term


# Fits-Descriptions - Translation ---------------------------
class FitsDescription( DeclarativeBase ):
    __tablename__ = 'trans_fits_descriptions'

    id = Column( Integer, primary_key = True )

    trans_id = Column( Unicode( 20 ) )
    english_term = Column( Unicode( 1000 ) )
    context = Column( Unicode( 1000 ) )
    arabic = Column( Unicode( 1000 ) )
    bahasa_indonesia = Column( Unicode( 1000 ) )
    bulgarian = Column( Unicode( 1000 ) )
    chinese = Column( Unicode( 1000 ) )
    chinese_traditional_taiwan = Column( Unicode( 1000 ) )
    croatian = Column( Unicode( 1000 ) )
    french = Column( Unicode( 1000 ) )
    french_canada = Column( Unicode( 1000 ) )
    german = Column( Unicode( 1000 ) )
    greek = Column( Unicode( 1000 ) )
    hungarian = Column( Unicode( 1000 ) )
    italian = Column( Unicode( 1000 ) )
    japanese = Column( Unicode( 1000 ) )
    kazakh = Column( Unicode( 1000 ) )
    korean = Column( Unicode( 1000 ) )
    polish = Column( Unicode( 1000 ) )
    portuguese = Column( Unicode( 1000 ) )
    romanian = Column( Unicode( 1000 ) )
    russian = Column( Unicode( 1000 ) )
    serbian = Column( Unicode( 1000 ) )
    spanish = Column( Unicode( 1000 ) )
    turkish = Column( Unicode( 1000 ) )
    uk_english = Column( Unicode( 1000 ) )
    ukrainian = Column( Unicode( 1000 ) )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ):
        return self.english_term

    def __str__( self ):
        return self.english_term


# Sectional Call-Outs Trans ---------------------------
class SectionalCallOut( DeclarativeBase ):
    __tablename__ = 'trans_sectional_call_outs'

    id = Column( Integer, primary_key = True )

    trans_id = Column( Unicode( 20 ) )
    english_term = Column( Unicode( 1000 ) )
    context = Column( Unicode( 1000 ) )
    arabic = Column( Unicode( 1000 ) )
    bahasa_indonesia = Column( Unicode( 1000 ) )
    bulgarian = Column( Unicode( 1000 ) )
    chinese = Column( Unicode( 1000 ) )
    croatian = Column( Unicode( 1000 ) )
    french = Column( Unicode( 1000 ) )
    french_canada = Column( Unicode( 1000 ) )
    german = Column( Unicode( 1000 ) )
    greek = Column( Unicode( 1000 ) )
    hungarian = Column( Unicode( 1000 ) )
    italian = Column( Unicode( 1000 ) )
    japanese = Column( Unicode( 1000 ) )
    kazakh = Column( Unicode( 1000 ) )
    korean = Column( Unicode( 1000 ) )
    polish = Column( Unicode( 1000 ) )
    portuguese = Column( Unicode( 1000 ) )
    romanian = Column( Unicode( 1000 ) )
    russian = Column( Unicode( 1000 ) )
    serbian = Column( Unicode( 1000 ) )
    spanish = Column( Unicode( 1000 ) )
    turkish = Column( Unicode( 1000 ) )
    uk_english = Column( Unicode( 1000 ) )
    ukrainian = Column( Unicode( 1000 ) )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ):
        return self.english_term

    def __str__( self ):
        return self.english_term



# Warnings - Translation ---------------------------
class Warning( DeclarativeBase ):
    __tablename__ = 'trans_Warnings'

    id = Column( Integer, primary_key = True )

    trans_id = Column( Unicode( 20 ) )
    english_term = Column( Unicode( 1000 ) )
    context = Column( Unicode( 1000 ) )
    arabic = Column( Unicode( 1000 ) )
    bahasa_indonesia = Column( Unicode( 1000 ) )
    bulgarian = Column( Unicode( 1000 ) )
    chinese = Column( Unicode( 1000 ) )
    croatian = Column( Unicode( 1000 ) )
    french = Column( Unicode( 1000 ) )
    french_canada = Column( Unicode( 1000 ) )
    german = Column( Unicode( 1000 ) )
    greek = Column( Unicode( 1000 ) )
    hungarian = Column( Unicode( 1000 ) )
    italian = Column( Unicode( 1000 ) )
    japanese = Column( Unicode( 1000 ) )
    kazakh = Column( Unicode( 1000 ) )
    korean = Column( Unicode( 1000 ) )
    polish = Column( Unicode( 1000 ) )
    portuguese = Column( Unicode( 1000 ) )
    romanian = Column( Unicode( 1000 ) )
    russian = Column( Unicode( 1000 ) )
    serbian = Column( Unicode( 1000 ) )
    spanish = Column( Unicode( 1000 ) )
    turkish = Column( Unicode( 1000 ) )
    uk_english = Column( Unicode( 1000 ) )
    ukrainian = Column( Unicode( 1000 ) )

    createTime = Column( "create_time", DateTime, default = dt.now )
    lastModifyTime = Column( "last_modify_time", DateTime, default = dt.now, onupdate = dt.now )
    issuedById = Column( "issued_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID )
    issuedBy = relation( User, primaryjoin = issuedById == User.user_id )
    lastModifyById = Column( "last_modify_by_id", Integer, ForeignKey( 'tg_user.user_id' ), default = getUserID, onupdate = getUserID )
    lastModifyBy = relation( User, primaryjoin = lastModifyById == User.user_id )
    active = Column( Integer, default = 0 )    # 0: active, 1: inactive

    def __unicode__( self ):
        return self.english_term

    def __str__( self ):
        return self.english_term


    @classmethod
    def populate( clz, ids , join = True ):
        wenc , wfrc, wjpc, wchc, wind, winfo = [], [], [], [], [], {}
        for c in DBSession.query( clz ).filter( clz.id.in_( ids ) ): winfo[unicode( c.id )] = c
        for _id in ids :
            if _id not in winfo : continue
            c = winfo[_id]
            wenc.append( c.english_term or '' )
            wfrc.append( c.french_canada or '' )
            wind.append( c.bahasa_indonesia or '' )
            wjpc.append( c.japanese or '' )
            wchc.append( c.chinese or '' )
        return [wenc , wfrc, wind, wjpc, wchc, ]

