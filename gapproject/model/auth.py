# -*- coding: utf-8 -*-
"""
Auth* related model.

This is where the models used by :mod:`repoze.who` and :mod:`repoze.what` are
defined.

It's perfectly fine to re-use this definition in the GAPProject application,
though.

"""
import os
from datetime import datetime
import sys
import random
try:
    from hashlib import sha1
except ImportError:
    sys.exit( 'ImportError: No module named hashlib\n'
             'If you are on python2.4 this library is not part of python. '
             'Please install it. Example: easy_install hashlib' )

from sqlalchemy import Table, ForeignKey, Column
from sqlalchemy.types import Unicode, Integer, DateTime, Text
from sqlalchemy.orm import relation, synonym

from gapproject.model import DeclarativeBase, metadata, DBSession

__all__ = ['User', 'Group', 'Permission']

# { Association tables

# This is the association table for the many-to-many relationship between
# groups and permissions. This is required by repoze.what.
group_permission_table = Table( 'tg_group_permission', metadata,
    Column( 'group_id', Integer, ForeignKey( 'tg_group.group_id',
        onupdate = "CASCADE", ondelete = "CASCADE" ), primary_key = True ),
    Column( 'permission_id', Integer, ForeignKey( 'tg_permission.permission_id',
        onupdate = "CASCADE", ondelete = "CASCADE" ), primary_key = True )
 )

# This is the association table for the many-to-many relationship between
# groups and members - this is, the memberships. It's required by repoze.what.
user_group_table = Table( 'tg_user_group', metadata,
    Column( 'user_id', Integer, ForeignKey( 'tg_user.user_id',
        onupdate = "CASCADE", ondelete = "CASCADE" ), primary_key = True ),
    Column( 'group_id', Integer, ForeignKey( 'tg_group.group_id',
        onupdate = "CASCADE", ondelete = "CASCADE" ), primary_key = True )
 )


def userCode():  return '%s%s' % ( datetime.now().strftime( '%Y%m%d%H%M%S' ), random.randint( 1000, 9999 ) )


# { The auth* model itself

class Group( DeclarativeBase ):
    """
    Group definition for :mod:`repoze.what`.
    Only the ``group_name`` column is required by :mod:`repoze.what`.
    """

    __tablename__ = 'tg_group'

    # { Columns

    group_id = Column( Integer, autoincrement = True, primary_key = True )
    group_name = Column( Unicode( 100 ), unique = True, nullable = False )
    display_name = Column( Unicode( 255 ) )
    active = Column( Integer, default = 0 )    # 0 is active , 1 is inactive
    created = Column( DateTime, default = datetime.now )

    # { Relations

    users = relation( 'User', secondary = user_group_table, backref = 'groups' )

    # { Special methods

    def __repr__( self ):
        return self.display_name or self.group_name

    def __unicode__( self ):
        return self.display_name or self.group_name

    # }

# The 'info' argument we're passing to the email_address and password columns
# contain metadata that Rum (http://python-rum.org/) can use generate an
# admin interface for your models.
class User( DeclarativeBase ):
    """
    User definition.

    This is the user definition used by :mod:`repoze.who`, which requires at
    least the ``user_name`` column.

    """
    __tablename__ = 'tg_user'

    # { Columns

    user_id = Column( Integer, autoincrement = True, primary_key = True )
    user_name = Column( Unicode( 100 ), unique = True )
    # email_address = Column(Unicode(255), unique=True, nullable=False, info={'rum': {'field':'Email'}})
    email_address = Column( Unicode( 255 ), info = {'rum': {'field':'Email'}} )
    display_name = Column( Unicode( 255 ) )
    # _password = Column('password', Unicode(80), info={'rum': {'field':'Password'}})
    password = Column( 'password', Unicode( 80 ), info = {'rum': {'field':'Password'}} )
    created = Column( DateTime, default = datetime.now )

    # added@20120411 for Vendor register
    billing_name = Column( Unicode( 500 ) )
    billing_address = Column( Unicode( 1000 ) )
    contact_name = Column( Unicode( 500 ) )
    phone_number = Column( Unicode( 255 ) )
    active = Column( Integer, default = 0 )    # 0 is active , 1 is inactive

    code = Column( Text , default = userCode, unique = True )

    # { Special methods

    def __repr__( self ):
        return '<User: email="%s", display name="%s">' % ( self.email_address, self.display_name )

    def __unicode__( self ):
        return self.display_name or self.user_name

    # { Getters and setters

    @property
    def permissions( self ):
        """Return a set of strings for the permissions granted."""
        perms = set()
        for g in self.groups:
            perms = perms | set( g.permissions )
        return perms

    @classmethod
    def by_email_address( cls, email ):
        """Return the user object whose email address is ``email``."""
        return DBSession.query( cls ).filter( cls.email_address == email ).first()

    @classmethod
    def by_user_name( cls, username ):
        """Return the user object whose user name is ``username``."""
        return DBSession.query( cls ).filter( cls.user_name == username ).first()

    @classmethod
    def get_vendors( cls ):
        return DBSession.query( cls ).filter( cls.groups.any( group_name = 'Vendor' ) ). \
            order_by( cls.user_name ). \
            all()

    # def _set_password(self, password):
    #     """Hash ``password`` on the fly and store its hashed version."""
    #     hashed_password = password

    #     if isinstance(password, unicode):
    #         password_8bit = password.encode('UTF-8')
    #     else:
    #         password_8bit = password

    #     salt = sha1()
    #     salt.update(os.urandom(60))
    #     hash = sha1()
    #     hash.update(password_8bit + salt.hexdigest())
    #     hashed_password = salt.hexdigest() + hash.hexdigest()

    #     # Make sure the hashed password is an UTF-8 object at the end of the
    #     # process because SQLAlchemy _wants_ a unicode object for Unicode
    #     # columns
    #     if not isinstance(hashed_password, unicode):
    #         hashed_password = hashed_password.decode('UTF-8')

    #     self._password = hashed_password

    # def _get_password(self):
    #     """Return the hashed version of the password."""
    #     return self._password

    # password = synonym('_password', descriptor=property(_get_password,
    #                                                     _set_password))

    @property
    def default_url( self ):
        """Return the default page after user login."""
        search_groups = set( DBSession.query( Group ).filter( Group.group_name.in_( ['BUYER', 'AE'] ) ).all() )

        if len( search_groups.intersection( set( self.groups ) ) ) > 0:
            return url( '/order/search' )
        else:
            return url( '/order/index' )

    # }

    def validate_password( self, password ):
        return self.password == password and self.active == 0

    @classmethod
    def identify( cls, value ):
        return DBSession.query( cls ).filter( cls.user_name.match( value ) ).one()

    # }


    # def validate_password(self, password):
    #     """
    #     Check the password against existing credentials.

    #     :param password: the password that was provided by the user to
    #         try and authenticate. This is the clear text version that we will
    #         need to match against the hashed one in the database.
    #     :type password: unicode object.
    #     :return: Whether the password is valid.
    #     :rtype: bool

    #     """
    #     hashed_pass = sha1()
    #     hashed_pass.update(password + self.password[:40])
    #     return self.password[40:] == hashed_pass.hexdigest()


class Permission( DeclarativeBase ):
    """
    Permission definition for :mod:`repoze.what`.

    Only the ``permission_name`` column is required by :mod:`repoze.what`.

    """

    __tablename__ = 'tg_permission'

    # { Columns

    permission_id = Column( Integer, autoincrement = True, primary_key = True )
    permission_name = Column( Text, unique = True, nullable = False )
    display_name = Column( Text )
    description = Column( Text )
    order = Column( Integer )
    # { Relations

    groups = relation( Group, secondary = group_permission_table, backref = 'permissions' )

    # { Special methods

    def __repr__( self ):
        return self.display_name or self.permission_name

    def __unicode__( self ):
        return self.display_name or self.permission_name

    # }

# }
