# -*- coding: utf-8 -*-
import traceback
import os
import random
import json
import subprocess
import zipfile
import zlib

from datetime import datetime as dt

from tg import request, config

from PyPDF2 import PdfFileReader
from PyPDF2 import PdfFileWriter

from gapproject.model import *


__all__ = ['gen_pdf']


PASSWORD = 'rpac'


def encrypt( sourcepath, destpath, pw ):
    input = PdfFileReader( open( sourcepath, "rb" ) )
    output = PdfFileWriter()

    for i in range( input.getNumPages() ):
        output.addPage( input.getPage( i ) )

    output.encrypt( pw )
    output.write( file( destpath, "wb" ) )
    # print 'OK'


def gen_pdf( hid ):
    try:
        public_dir = config.get( 'public_dir' )
        download_dir = os.path.join( public_dir, 'label_pdf' )
        if not os.path.exists( download_dir ):
            os.makedirs( download_dir )

        _name = '%s_%s%d' % ( hid, dt.now().strftime( "%Y%m%d%H%M%S" ), random.randint( 1, 1000 ) )
        pdf_file = os.path.join( download_dir, '%s.pdf' % _name )
        pdf_encrypted_file = os.path.join( download_dir, 'encrypted_%s.pdf' % _name )

        phantomjs = os.path.join( public_dir, 'phantomjs', 'phantomjs.exe' )
        labeljs = os.path.join( public_dir, 'phantomjs', 'label.js' )
        http_url = 'http://%s/pdflayout/index?id=%s' % ( request.headers.get( 'Host' ), hid )
        cmd = '%s %s %s %s' % ( phantomjs, labeljs, http_url, pdf_file )

        sp = subprocess.Popen( cmd, stdout = subprocess.PIPE, stderr = subprocess.STDOUT )

        while 1:
            if sp.poll() is not None:
                #print 'exec command completed.'
                break
            # else:
            #     line = sp.stdout.readline().strip()

        # encrypt(pdf_file, pdf_encrypted_file, PASSWORD)

        # pdftk
        encrypt_cmd = 'pdftk %s output %s owner_pw %s' % ( pdf_file, pdf_encrypted_file, PASSWORD );

        encrypt_sp = subprocess.Popen( encrypt_cmd, stdout = subprocess.PIPE, stderr = subprocess.STDOUT )

        while 1:
            if encrypt_sp.poll() is not None:
                #print 'exec command completed.'
                break

        pd_zip_file = os.path.join( download_dir, "label_%s%d.zip" % ( dt.now().strftime( "%Y%m%d%H%M%S" ), random.randint( 1, 1000 ) ) )
        out_zip_file = zipfile.ZipFile( pd_zip_file, "w", zlib.DEFLATED )

        out_zip_file.write( os.path.abspath( pdf_encrypted_file ), os.path.basename( pdf_encrypted_file ) )
        out_zip_file.close()

        try:
            os.remove( pdf_file )
            os.remove( pdf_encrypted_file )
        except:
            pass

        return pd_zip_file
    except:
        traceback.print_exc()
        return None

