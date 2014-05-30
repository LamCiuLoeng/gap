# -*- coding: utf-8 -*-
# from __future__ import division
import traceback
import urllib
import os
import shutil
import random
import re
import json
import subprocess
import zipfile
import zlib
import pywintypes
from datetime import datetime as dt
from math import modf

# from collections import OrderedDict


# turbogears imports
from tg import expose
from tg import redirect, validate, flash, request, config
from tg.decorators import *

# third party imports
#from pylons.i18n import ugettext as _
from repoze.what import predicates, authorize
from repoze.what.predicates import not_anonymous, in_group, has_permission

from sqlalchemy.sql import *

# project specific imports
from gapproject.lib.base import BaseController

from gapproject.model import *

from gapproject.util.common import *
from gapproject.util.excel_helper import *
from gapproject.widgets import *
from gapproject.widgets.report import *

from gapproject.util.gap_const import *
from gapproject.util.label_pdf import *

# import transaction
__all__ = ['PDFController', 'PDFLayoutController']

# Current inventory levels
class PDFController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    allow_only = authorize.not_anonymous()

    @expose()
    def index(self, **kw):

        hid = kw.get('id', None)

        pd_zip_file = gen_pdf(hid)

        return serveFile(unicode(pd_zip_file))


class PDFLayoutController(BaseController):
    #Uncomment this line if your controller requires an authenticated user
    # allow_only = authorize.not_anonymous()

    @expose('gapproject.templates.pdf.short')
    def index(self, **kw):
        try:
            # layout_type = 'short'
            hid = kw.get('id', None)
            # print hid

            # "{"dry": ["161", "160"], "wash": ["157"], "dryclean": ["160"], "iron": ["159"], "bleach": ["159"]}"
            CARE_CATS = ['wash', 'bleach', 'dry', 'iron', 'dryclean', 'specialcare']

            # for jp
            CARE_CATS_JP = ['wash', 'bleach', 'iron', 'dryclean', 'dry', 'specialcare']

            new_sizes = []
            coo = ''
            care_instructions = {'en': '', 'ca': '', 'id': '', 'jp': '', 'ch': '', 'uae': ''}
            fibers = []
            traceability = {}
            care_symbols = {'ch': [], 'jp': []}

            # jp, "Only Non-chlorine Bleach When Needed" (trans_id, 872)
            # show "Do Not Bleach" (trans_id, 573) symbol, and show jp text
            BLEACH_SPECIAL_TRANS_ID = 872

            # sizes: en/ca fr, cn
            # coo: en
            # Fabric Terms: en, ca fr, ja, cn, arabic
            # fiber content: en, ca fr, ja, cn, arabic
            # care instructions: en, ca fr, Indonesia, ja, cn, UAE
            # layout: short, medium, long
            # short: fibers: 1, medium: 3, long: 4...

            # label object
            label = DBSession.query(OnclLabel).filter(and_(
                OnclLabel.orderHeaderId == hid, OnclLabel.active == 0)).first()


            if label:
                # print label

                get_obj = lambda cls, id: DBSession.query(cls).filter(and_(cls.active == 0,
                    cls.id == id)).first()

                sizes = label.orderHeader.sizeFitQty

                def get_ca_size(id):
                    ca_size = ''
                    size = get_obj(OnclSize, int(id))
                    if size and size.canada_size:
                        canada_size = ''.join(size.canada_size.split())
                        if canada_size and 'n/a' not in canada_size:
                            ca_size = canada_size
                    return ca_size


                # print sizes
                new_sizes = [{'en': s['T'].split('$')[0], 'ca': get_ca_size(s['S']), 'cn': s['T'].split('$')[1]} for s in sizes]

                coo = label.co.english_term.upper() if label.co else ''

                # care, care symbols
                # cares = [get_obj(CareInstruction, c) for c in label.care.split('|') if c]
                care_dict = json.loads(label.care)
                care_ids = reduce(lambda x, y: x+y, [care_dict.get(c, []) for c in CARE_CATS])
                care_jp_ids = reduce(lambda x, y: x+y, [care_dict.get(c, []) for c in CARE_CATS_JP])

                cares = [get_obj(CareInstruction, int(id)) for id in care_ids if id]

                cares_jp = [get_obj(CareInstruction, int(id)) for id in care_jp_ids if id]

                get_cares = lambda cs, attr, x: x.join([getattr(c, attr).upper() for c in cs if c and getattr(c, attr)])

                care_instructions['en'] = get_cares(cares, 'english_term', '/')
                care_instructions['ca'] = get_cares(cares, 'french_canada', '/')
                care_instructions['id'] = get_cares(cares, 'bahasa_indonesia', '/')

                care_instructions['jp'] = ''
                care_instructions['ch'] = ''


                care_instructions['uae'] = ''  # get_cares(cares, 'arabic', '  ')



                get_symbols = lambda cs, sym, ext: [''.join(['/images/caresymbols/', str(c.trans_id), ext]) for c in cs if c and c.symbols[sym] == '1']

                # care_symbols['ch'] = [''.join(['/images/caresymbols/', str(c.id), '_ch.jpg']) for c in cares if c and c.symbols[0] == '1']
                # care_symbols['jp'] = [''.join(['/images/caresymbols/', str(c.id), '_jp.jpg']) for c in cares_jp if c and c.symbols[2] == '1']

                care_symbols['ch'] = get_symbols(cares, 0, '_ch.jpg')

                care_symbols['jp'] = get_symbols(cares, 2, '_jp.jpg')

                # for cj in cares_jp:
                #     if cj:
                #         if cj.id == SPECIAL_CARE_ID:
                #             care_symbols['jp'].append(''.join(['/images/caresymbols/', str(SPECIAL_CARE_SHOW_SYMBOL_ID), '_jp.jpg']))
                #         elif cj.symbols[2] == '1':
                #             care_symbols['jp'].append(''.join(['/images/caresymbols/', str(cj.trans_id), '_jp.jpg']))


                _tmp_jp_cares = [c for c in cares_jp if c and (c.trans_id == BLEACH_SPECIAL_TRANS_ID or c.symbols[2] == '0')]
                _tmp_ch_cares = [c for c in cares if c and c.symbols[0] == '0']

                if _tmp_jp_cares:
                    care_instructions['jp'] = get_cares(_tmp_jp_cares, 'japanese', ' ')


                if _tmp_ch_cares:
                    care_instructions['ch'] = get_cares(_tmp_ch_cares, 'chinese', '，')


                # print label.id
                # print care_symbols

                # Fabric Terms, fiber content
                # short: fibers: 1, medium: 3, long: 4...
                composition = label.composition
                compositions = json.loads(composition)
                # print compositions
                compositions_len = len(compositions)


                if compositions_len > 1 and compositions_len <= 3:
                    # medium
                    # layout_type = 'medium'
                    override_template(self.index, 'mako:gapproject.templates.pdf.medium')
                elif compositions_len > 3:
                    # long
                    # layout_type = 'long'
                    override_template(self.index, 'mako:gapproject.templates.pdf.long')

                for cop in compositions:
                    if cop['id']:
                        term = get_obj(SectionalCallOut, cop['id'])
                        term_name = '/'.join([t.upper() for t in [term.english_term, term.french_canada,
                            term.japanese, term.chinese, term.arabic] if t])
                    else:
                        term_name = ''

                    # en, ca,
                    # jp, ch, uae
                    fib_en = []
                    fib_ca = []
                    fib_jp = []
                    fib_ch = []
                    fib_uae = []

                    for cc in cop['component']:
                        # print cc[0]
                        fib = get_obj(Fiber, cc[0])
                        fib_en.append('%s%% %s' % (cc[1], fib.english_term.upper()))
                        fib_ca.append('%s%% %s' % (cc[1], fib.french_canada.upper()))

                        fib_jp.append({'percent': '%s%%' % cc[1], 'pname': fib.japanese})

                        fib_ch.append({'percent': '%s%%' % cc[1], 'pname': fib.chinese})
                        # fib_uae.append({'percent': '%s%%' % cc[1], 'pname': fib.arabic})


                    # print ', '.join(fib_en)
                    fibers.append({'tname': term_name, 'en': ', '.join(fib_en),
                        'ca': ', '.join(fib_ca), 'jp': fib_jp,
                        'ch': fib_ch, 'uae': fib_uae})

                # print fibers

                traceability['style'] = label.styleNo.upper() if label.styleNo else ''
                traceability['color_code'] = label.colorCode.upper() if label.colorCode else ''
                traceability['style_desc'] = label.styleDesc.upper() if label.styleDesc else ''
                traceability['cc_desc'] = label.ccDesc.upper() if label.ccDesc else ''
                traceability['manufacture'] = label.manufacture.upper() if label.manufacture else ''
                traceability['season'] = label.season.upper() if label.season else ''
                traceability['vendor'] = label.vendor.upper() if label.vendor else ''




        except:
            traceback.print_exc()
        finally:
            return {'traceability': traceability, 'sizes': new_sizes, 'coo': coo, 'care': care_instructions,
                'fibers': fibers, 'care_symbols': care_symbols}




    # @expose()
    # def updatedb(self, **kw):

    #     def update_sizes(sizes):
    #         if len(sizes) == 1:
    #             return json.dumps(sizes[0])
    #         else:
    #             fits = ['Regular', 'Slim', 'Husky', 'Plus']
    #             new_sizes = {}
    #             for s in sizes:
    #                 for f in fits:
    #                     keys = ''.join(s.keys())
    #                     keys = keys.lower()
    #                     if f.lower() in keys:
    #                         new_sizes['%s %s' % (f, 'Fit')] = ''.join(s.values())
    #                         break
    #             print new_sizes
    #             return json.dumps(new_sizes)


    #     sizes = DBSession.query(OnclSize).all()

    #     for s in sizes:
    #         china_size = json.loads(s.china_size)
    #         japan_size = json.loads(s.japan_size)
    #         s.china_size = update_sizes(china_size)
    #         s.japan_size = update_sizes(japan_size)


    # @expose()
    # def updatedb2(self, **kw):
    #     def _update(sizes):
    #         new_sizes = OrderedDict()
    #         fits = ['Regular Fit', 'Slim Fit', 'Husky Fit', 'Plus Fit']

    #         for f in fits:
    #             if f in sizes:
    #                 new_sizes[f] = sizes.get(f)
    #         return json.dumps(new_sizes)


    #     sizes = DBSession.query(OnclSize).all()

    #     for s in sizes:
    #         china_size = json.loads(s.china_size)
    #         japan_size = json.loads(s.japan_size)

    #         if len(china_size.items()) > 1:
    #             s.china_size = _update(china_size)


    #         if len(japan_size.items()) > 1:
    #             s.japan_size = _update(japan_size)
