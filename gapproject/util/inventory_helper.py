# -*- coding: utf-8 -*-
from urllib2 import quote
from sqlalchemy import *
from gapproject.model import *

__all__ = ['reserveMinMax']


def reserveMinMax(orderQty, qtyReserved, availableQty):
    if availableQty < 1:
        return 0, 0
    else:
        qty = orderQty - qtyReserved
        maxQty = qty if qty <= availableQty else availableQty
        return 1, maxQty
