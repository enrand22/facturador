B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private xl As XLUtils
	Private wb As XLWorkbookWriter
	Private ws As XLSheetWriter
	Private gCfdi As Comprobante
	Private gUUID As String
	
	Private sTitle As XLStyle
	Private sCenter As XLStyle
	Private sDate As XLStyle
	Private sTopJustify As XLStyle
	Private sUnderLine As XLStyle
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(cfdi As Comprobante, uuid As String)
	gCfdi = cfdi
	gUUID = uuid
	create_workbook
	create_styles
	
	write_emisor
	write_basicos
	write_receptor
	
	If gCfdi.conceptos.size = 1 Then
		write_concepto_unico
	Else
		write_conceptos
	End If
	
	save
End Sub

public Sub create_styles
	sTitle = wb.CreateStyle.ForegroundColor(xl.COLOR_GREY_25_PERCENT).FontBoldColor(12, xl.COLOR_WHITE).HorizontalAlignment("CENTER")
	sCenter = wb.CreateStyle.HorizontalAlignment("CENTER")
	sDate = wb.CreateStyle.DataFormat("dd/MM/yyyy")
	sTopJustify = wb.CreateStyle.HorizontalAlignment("LEFT").VerticalAlignment("TOP").WrapText(True)
	sUnderLine = wb.CreateStyle.BorderBottom("MEDIUM").BorderBottomColor(xl.COLOR_BLACK)

End Sub

public Sub create_workbook
	xl.Initialize
	wb = xl.CreateWriterBlank
	ws = wb.CreateSheetWriterByName("comprobante")
	For i = 0 To 23
		ws.PoiSheet.SetColumnWidth(i, 256 * 3.5)
	Next
End Sub

private Sub write_emisor
'	ws.PutString(address(2, 1), gCfdi.Emisor.Nombre)
'	ws.PutString(address(2, 1), gCfdi.Emisor.Nombre)
'	ws.PutString(address(3, 1), gCfdi.Emisor.RFC)
'	
'	ws.PutString(address(5, 1), "Regimen Fiscal")
'	ws.PutString(address(5, 2), gCfdi.Emisor.RegimenFiscal)
End Sub

Private Sub write_receptor
	ws.putstring(merge(2,1,2,13), "RECEPTOR").AddStyle(ws.LastAccessed, sTitle)
	ws.PutString(merge(3,1,4,13), gCfdi.Receptor.Nombre).AddStyles(ws.LastAccessed,Array(sTopJustify))
	
	ws.putstring(merge(6,1,6,5), "RFC").AddStyle(ws.LastAccessed, sTitle)
	ws.putstring(merge(6,6,6,10), "REGIMEN").AddStyle(ws.LastAccessed, sTitle)
	ws.putstring(merge(6,11,6,13), "USO CFDI").AddStyle(ws.LastAccessed, sTitle)
	
	ws.PutString(merge(7,1,7,5), gCfdi.Receptor.rfc).AddStyles(ws.LastAccessed,Array(sCenter))
	ws.PutString(merge(7,6,7,10), gCfdi.Receptor.RegimenFiscalReceptor).AddStyles(ws.LastAccessed,Array(sCenter))
	ws.PutString(merge(7,11,7,13), gCfdi.Receptor.UsoCFDI).AddStyles(ws.LastAccessed,Array(sCenter))
End Sub

Private Sub write_concepto_unico
	ws.putstring(merge(10,1,10,22), "CONCEPTO").AddStyle(ws.LastAccessed, sTitle)
	
	
End Sub

Private Sub write_conceptos	
	
End Sub

private Sub write_basicos
	write_fecha
	
End Sub

Private Sub write_fecha
	ws.PutString(merge(2,19,2,22),"FECHA").AddStyle(ws.LastAccessed, sTitle)
	ws.PutDate(merge(3,19,3,22),gCfdi.Fecha.Fecha).AddStyles(ws.LastAccessed,Array(sCenter,sDate))
End Sub

Private Sub save
	Dim realName As String = wb.SaveAs(File.DirTemp,gUUID & ".xlsx",True)
#if debug
	fx.ShowExternalDocument(File.GetUri(File.GetFileParent(realName),File.GetName(realName)))
#else
	xl.PowerShellConvertToPdf(realName,realName.Replace(".xlsx",".pdf"),0,True)
#End If
End Sub

Private Sub merge(x0 As Int, y0 As Int, x1 As Int, y1 As Int) As XLAddress
	ws.AddMergedRegion(xl.CreateXLRange(address(x0, y0),address(x1,y1)))
	Return address(x0, y0)
End Sub

private Sub address(x0 As Int, y0 As Int) As XLAddress
	Return xl.AddressZero(y0, x0)
End Sub