# -*- coding: utf-8 -*-

from gapproject.model import *

__all__ = ["getCutNo"]

def getCutNo():
    headers = DBSession.query(TRBHeaderPO).all()
    
    return headers