# -*- coding: utf-8 -*-
import json
import math
import traceback
from datetime import datetime as dt


__all__ = ["b", "na", "pd", "pt", "tp", "cd", "jd", "roundup250"]

b = lambda v:"&nbsp;" if not v or v == 'Null' else v
na = lambda v: 'N/A' if not v else v
pd = lambda v, len = 10:"&nbsp;" if not v else str( v )[0:len]
pt = lambda v, len = 19:"&nbsp;" if not v else str( v )[0:len]

jd = lambda v : json.dumps( v )
jl = lambda v : json.loads( v )


def tp( v ):
    if not v : return "&nbsp;"
    return "<span class='tooltip' title='%s'>%s</span>" % ( v, v )

# cound the day
def cd( v ):
    try:
        return ( dt.now() - v ).days
    except:
        traceback.print_exc()
        return ""


def roundup250( v ):
    try:
        return unicode( int( math.ceil( float( v ) / 250 ) * 250 ) )
    except:
        return ''
