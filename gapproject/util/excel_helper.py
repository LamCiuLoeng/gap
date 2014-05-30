# -*- coding: utf-8 -*-
import os, traceback, logging, datetime
import win32com.client
import pythoncom

from win32com.client import DispatchEx
from common import *

__all__ = ["ExcelBasicGenerator", 'InventoryExcel',
           'ExcelReader', 'ONCLReport', 'ONCLOrderExcel', 'ONCLSizeExcel']


XlBorderWeight = {
                  "xlHairline" : 1,
                  "xlThin" : 2,
                  "xlMedium" : 3,
                  "xlThick" : 4
                  }

XlBordersIndex = {
                  "xlDiagonalDown" : 5,
                  "xlDiagonalUp" : 6,
                  "xlEdgeBottom" : 9,
                  "xlEdgeLeft" : 7,
                  "xlEdgeRight" : 10,
                  "xlEdgeTop" : 8,
                  "xlInsideHorizontal" : 12,
                  "xlInsideVertical" : 11,
                  }



# http://msdn.microsoft.com/en-us/library/microsoft.office.interop.excel.xlhalign.aspx
XlHAlign = {
          "xlHAlignCenter" :-4108,    # Center
          "xlHAlignCenterAcrossSelection" : 7,    # Center across selection.
          "xlHAlignDistributed" :-4117,    # Distribute
          "xlHAlignFill" : 5,    # Fill
          "xlHAlignGeneral" : 1,    # Align according to data type.
          "xlHAlignJustify" :-4130,    # Justify
          "xlHAlignLeft" :-4130,    # Left
          "xlHAlignRight" :-4152,    # Right
          }


HorizontalAlignment = {
                       "xlCenter" :-4108,
                       "xlDistributed" :-4117,
                       "xlJustify" :-4130,
                       "xlLeft" :-4131,
                       "xlRight" :-4152,
                       }


XlUnderlineStyle = {
    "xlUnderlineStyleNone" :-4142,
    "xlUnderlineStyleSingle" : 2,
    "xlUnderlineStyleDouble" :-4119,
    "xlUnderlineStyleSingleAccounting" :4,
    "xlUnderlineStyleDoubleAccounting" : 5,
}


InteriorPattern = {
                   "xlSolid" : 1,
                   }


InteriorPatternColorIndex = {
                             "xlAutomatic" :-4105,
                             }

XlThemeColor = {
                "xlThemeColorAccent1" :    5,    # Accent1
                "xlThemeColorAccent2" :    6,    # Accent2
                "xlThemeColorAccent3" :    7,    # Accent3
                "xlThemeColorAccent4" :   8,    # Accent4
                "xlThemeColorAccent5" :   9,    # Accent5
                "xlThemeColorAccent6" :   10,    # Accent6
                "xlThemeColorDark1"   : 1,    # Dark1
                "xlThemeColorDark2"   : 3,    # Dark2
                "xlThemeColorFollowedHyperlink"  :  12,    # Followed hyperlink
                "xlThemeColorHyperlink" :    11,    # Hyperlink
                "xlThemeColorLight1"  :    2,    # Light1
                "xlThemeColorLight2"  : 4,    # Light2
                }

class ExcelBasicGenerator:
    def __init__( self, templatePath = None, destinationPath = None, overwritten = True ):
        # solve the problem when create the excel at second time ,the exception is occur.
        pythoncom.CoInitialize()

        self.excelObj = DispatchEx( 'Excel.Application' )
        self.excelObj.Visible = False
        self.excelObj.DisplayAlerts = False

        if templatePath and os.path.exists( templatePath ):
            self.workBook = self.excelObj.Workbooks.open( templatePath )
        else:
            self.workBook = self.excelObj.Workbooks.Add()

        self.destinationPath = os.path.normpath( destinationPath ) if destinationPath else None
        self.overwritten = overwritten

    def inputData( self ): pass

    def outputData( self ):
        try:
            if not self.destinationPath : pass
            elif os.path.exists( self.destinationPath ):
                if self.overwritten:
                    os.remove( self.destinationPath )
                    self.excelObj.ActiveWorkbook.SaveAs( self.destinationPath )
            else:
                self.excelObj.ActiveWorkbook.SaveAs( self.destinationPath )
        except:
            traceback.print_exc()
        finally:
            try:
                self.workBook.Close( SaveChanges = 0 )
            except:
                traceback.print_exc()

    def clearData( self ):
        try:
            if hasattr( self, "workBook" ): self.workBook.Close( SaveChanges = 0 )
        except:
            traceback.print_exc()

    def _drawCellLine( self, sheet, sheet_range ):
        for line in ["xlEdgeBottom", "xlEdgeLeft", "xlEdgeRight", "xlEdgeTop"]:
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).Weight = XlBorderWeight["xlMedium"]
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).LineStyle = 1
        for line in ["xlInsideHorizontal", "xlInsideVertical"]:
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).Weight = XlBorderWeight["xlThin"]
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).LineStyle = 1


class InventoryExcel( ExcelBasicGenerator ):
    def inputData( self, data = [] ):
        excelSheet = self.workBook.Sheets( 1 )
        if not data:
            data = [( "", ), ]


        startRow = 2
        row = len( data )
        col = len( data[0] )
        excelSheet.Range( "A%d:%s%d" % ( startRow, number2alphabet( col ), startRow + row - 1 ) ).Value = data

#####################################################################
#    Author          : CL.Lam
#    Last modified   : 2008/10/07
#    Version         : 0.1
#    Description     : the basic class for reading the MS Excel file
#####################################################################
class ExcelReader:
    def __init__( self, sourcePath = None ):
        self.soureFile = None
        self.xls = None
        self.wb = None
        self.sheet = None
        self.setSourcePath( sourcePath )

    def setSourcePath( self, sourcePath = None ):
        if sourcePath and os.path.exists( sourcePath ) and os.path.isfile( sourcePath ):
            self._readExcel( sourcePath )
            self.soureFile = sourcePath
        else:
            self.soureFile = None

    def _readExcel( self, sourcePath ):
        if not self.xls:
            pythoncom.CoInitialize()
            self.xls = win32com.client.Dispatch( "Excel.Application" )
            self.xls.Visible = 0
            self.xls.DisplayAlerts = 0


        if self.wb:
            self.wb.Close( 0 )
        try:
            self.wb = self.xls.Workbooks.open( sourcePath )
            self.sheet = self.wb.Sheets[0]
        except:
            print "error in _readExcel"

    def setSheet( self, index = 0 ):
        if not self.soureFile:
            return
        else:
            self.sheet = self.wb.Sheets[index]

    def close( self ):
        if self.wb:
            self.wb.Close( 0 )
            del self.wb
        if self.xls:
            del self.xls


#
#
#    @param byRowOrColumn: 1 by row , 2 by column
    def getDataByRange( self, rows = [], cols = [], byRowOrColumn = 1 ):
        result = []
        if not self.soureFile:
            return result

        if len( rows ) > 1:
            rs = [self._translateHeader( r ) for r in rows]
        else:
            rs = range( 2, self.sheet.UsedRange.Rows.Count + 1 )

        if len( cols ) > 1:
            cs = [self._translateHeader( c ) for c in cols]
        else:
            cs = range( 1, self.sheet.UsedRange.Columns.Count + 1 )
        if byRowOrColumn == 1 :
            for r in rs:
                rc_item = [self.sheet.Cells( r, c ).Value and unicode( self.sheet.Cells( r, c ).Value ) or ""  for c in cs ]
                if len( set( rc_item ) ) != 1: result.append( rc_item )

        elif byRowOrColumn == 2 :
            for c in cs:
                rc_item = [defaultIfNone( unicode( self.sheet.Cells( r, c ).Value ) ) for r in rs ]
                if len( set( rc_item ) ) != 1: result.append()

        return result

    def _translateHeader( self, alphabeticHeader = "" ):
        if type( alphabeticHeader ) == int:
            return alphabeticHeader
        ah = alphabeticHeader.upper()
        import math
        result = 0
        if ah.isalpha():
            chars = list( ah )
            chars.reverse()
            for ( i, char ) in enumerate( chars ):
                result += ( ord( char ) - 64 ) * pow( 26, i )
        return result

    def getCellValue( self, row, col ):
        return self.sheet.Cells( row, col ).Value

    def totalRowsCount( self ):
        return self.sheet.UsedRange.Rows.Count

    def totalColumnsCount( self ):
        return self.sheet.UsedRange.Columns.Count





class ONCLReport( ExcelBasicGenerator ):
    def _drawCellLine( self, sheet, sheet_range ):
        for line in ["xlEdgeBottom", "xlEdgeLeft", "xlEdgeRight", "xlEdgeTop"]:
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).Weight = XlBorderWeight["xlMedium"]
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).LineStyle = 1
        for line in ["xlInsideHorizontal", "xlInsideVertical"]:
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).Weight = XlBorderWeight["xlThin"]
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).LineStyle = 1

    def inputData( self, data = [], isAdminAE = True ):
        excelSheet = self.workBook.Sheets( 1 )
        if not data:
            data = [( "", ), ]

        startRow = 2
        row = len( data )
        col = len( data[0] )
        _range = "A%d:%s%d" % ( startRow, number2alphabet( col ), startRow + row - 1 )
        excelSheet.Range( _range ).Value = data

        if not isAdminAE :
            excelSheet.Columns( 'N:N' ).Select()
            self.excelObj.Selection.Delete( -4159 )    # xlToLeft == -4159
            excelSheet.Columns( 'A:A' ).Select()
        self._drawCellLine( excelSheet, _range )
        excelSheet.Columns( "A:AZ" ).EntireColumn.AutoFit()



class ONCLOrderExcel( ExcelBasicGenerator ):
    def _drawCellLine( self, sheet, sheet_range ):
        for line in ["xlEdgeBottom", "xlEdgeLeft", "xlEdgeRight", "xlEdgeTop"]:
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).Weight = XlBorderWeight["xlMedium"]
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).LineStyle = 1
        for line in ["xlInsideHorizontal", "xlInsideVertical"]:
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).Weight = XlBorderWeight["xlThin"]
            sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).LineStyle = 1

    def inputData( self, data = {} ):
        mapping = {
                   'no' : 'B1', 'createTime' : 'F1',
                   'shipCompany' : 'F5', 'shipAttn' : 'F6', 'shipAddress' : 'F7', 'shipAddress2' : 'F8', 'shipAddress3' : 'F9',
                   'shipCity' : 'F10', 'shipState' : 'F11', 'shipZip' : 'F12', 'shipCountry' : 'F13', 'shipTel' : 'F14', 'shipFax' : 'F15',
                   'shipEmail' : 'F16', 'shipRemark' : 'F17',
                   'billCompany' : 'B5', 'billAttn' : 'B6', 'billAddress' : 'B7', 'billAddress2' : 'B8', 'billAddress3' : 'B9',
                   'billCity' : 'B10', 'billState' : 'B11', 'billZip' : 'B12', 'billCountry' : 'B13', 'billTel' : 'B14', 'billFax' : 'B15',
                   'billEmail' : 'B16', 'billRemark' : 'B17',
                   'onclpo' : 'B23', 'vendorpo' : 'B24', 'itemCopy' : 'B25', 'printShopCopy' : 'B26', 'divisionCopy' : 'B27', 'categoryCopy' : 'B28',
                   'com' : 'B36', 'care' : 'B37', 'warn' : 'B39', 'shipInstructions' : 'F18',
                   'coCopy' : 'B38', 'styleNo' : 'B44', 'colorCode' : 'B45', 'styleDesc' : 'B46', 'ccDesc' : 'B47',
                   'season' : 'B49', 'vendor' : 'B48', 'manufacture' : 'B50',
                   }
        excelSheet = self.workBook.Sheets( 1 )

        for k, v in mapping.items():
            excelSheet.Range( v ).Value = data.get( k, '' ) or ''

        sizeInfo = data['sizeInfo']
        if sizeInfo :
            _range = "A55:C%s" % ( 55 + len( sizeInfo ) - 1 )
            excelSheet.Range( _range ).Value = sizeInfo
            self._drawCellLine( excelSheet, _range )




class ONCLSizeExcel( ExcelBasicGenerator ):
    def inputData( self, data = [] ):
        excelSheet = self.workBook.Sheets( 1 )
        _range = "A2:F%s" % ( len( data ) + 1 )
        excelSheet.Range( _range ).Value = data
        self._drawCellLine( excelSheet, _range )
