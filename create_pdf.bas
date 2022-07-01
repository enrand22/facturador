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
	Private xml As ParseXML
	
	Private sTitle As XLStyle
	Private sCenter As XLStyle
	Private sDate As XLStyle
	Private sTopJustify As XLStyle
	Private sSmall As XLStyle
	Private sTvalue As XLStyle
	Private sValue As XLStyle
	Private sCant As XLStyle
	Private sRSmall As XLStyle
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(cfdi As Comprobante, dbt As db_timbre, observaciones As String) As String
	gCfdi = cfdi
	gUUID = IIf(dbt.uuid <> "",dbt.uuid,dbt.id)
	If dbt.timbre <> ""  Then xml.Initialize(dbt.timbre)
	create_workbook
	create_styles
	
	write_emisor
	write_basicos
	write_receptor
	
	Dim row As Int = write_conceptos
	
	If observaciones <> "" Then 
	row = write_observaciones(row, observaciones)
	End If
	
	write_financieros(row)
	row = write_totales(row)
	write_timbre(row, dbt.png)
	
	Return save
End Sub

public Sub create_styles
	sTitle = wb.CreateStyle.ForegroundColor(xl.COLOR_GREY_25_PERCENT).FontBoldColor(11, xl.COLOR_WHITE).HorizontalAlignment("CENTER")
	sTvalue = wb.CreateStyle.ForegroundColor(xl.COLOR_GREY_25_PERCENT).FontBoldColor(11, xl.COLOR_WHITE).HorizontalAlignment("LEFT")
	sCenter = wb.CreateStyle.HorizontalAlignment("CENTER")
	sDate = wb.CreateStyle.DataFormat("dd/MM/yyyy")
	sTopJustify = wb.CreateStyle.HorizontalAlignment("LEFT").VerticalAlignment("TOP").WrapText(True)
	sSmall = wb.CreateStyle.Font(10)
	sRSmall = wb.CreateStyle.Font(6)
	sCant = wb.CreateStyle.DataFormat("#,##0.00").HorizontalAlignment("LEFT").VerticalAlignment("CENTER")
	sValue = wb.CreateStyle.DataFormat("$* #,##0.00").HorizontalAlignment("LEFT").VerticalAlignment("CENTER")
End Sub

public Sub create_workbook
	xl.Initialize
	wb = xl.CreateWriterBlank
	ws = wb.CreateSheetWriterByName("comprobante")
	For i = 0 To 23
		ws.PoiSheet.SetColumnWidth(i, 256 * 3.5)
	Next
End Sub

Private Sub write_receptor
	ws.putstring(merge(10,0,10,12), "RECEPTOR").AddStyle(ws.LastAccessed, sTitle)
	ws.PutString(merge(11,0,12,12), gCfdi.Receptor.Nombre).AddStyles(ws.LastAccessed,Array(sTopJustify, sSmall))
	
	ws.putstring(merge(14,0,14,4), "RFC").AddStyle(ws.LastAccessed, sTitle)
	ws.putstring(merge(14,5,14,9), "REGIMEN").AddStyle(ws.LastAccessed, sTitle)
	ws.putstring(merge(14,10,14,12), "DOMICILIO").AddStyle(ws.LastAccessed, sTitle)
	ws.putstring(merge(14,13,14,15), "USO CFDI").AddStyle(ws.LastAccessed, sTitle)
	
	ws.PutString(merge(15,0,15,4), gCfdi.Receptor.rfc).AddStyles(ws.LastAccessed,Array(sCenter, sSmall))
	ws.PutString(merge(15,5,15,9), gCfdi.Receptor.RegimenFiscalReceptor).AddStyles(ws.LastAccessed,Array(sCenter, sSmall))
	ws.PutString(merge(15,10,15,12), gCfdi.Receptor.DomicilioFiscalReceptor).AddStyles(ws.LastAccessed,Array(sCenter, sSmall))
	ws.PutString(merge(15,13,15,15), gCfdi.Receptor.UsoCFDI).AddStyles(ws.LastAccessed,Array(sCenter, sSmall))

End Sub

Private Sub write_emisor
	ws.putstring(merge(2,0,2,12), "EMISOR").AddStyle(ws.LastAccessed, sTitle)
	ws.PutString(merge(3,0,4,12), gCfdi.Emisor.Nombre).AddStyles(ws.LastAccessed,Array(sTopJustify, sSmall))
	
	ws.putstring(merge(6,0,6,4), "RFC").AddStyle(ws.LastAccessed, sTitle)
	ws.putstring(merge(6,5,6,9), "REGIMEN").AddStyle(ws.LastAccessed, sTitle)
	ws.putstring(merge(6,10,6,12), "DOMICILIO").AddStyle(ws.LastAccessed, sTitle)
	
	ws.PutString(merge(7,0,7,4), gCfdi.Emisor.rfc).AddStyles(ws.LastAccessed,Array(sCenter, sSmall))
	ws.PutString(merge(7,5,7,9), gCfdi.Emisor.RegimenFiscal).AddStyles(ws.LastAccessed,Array(sCenter, sSmall))
	ws.PutString(merge(7,10,7,12), gCfdi.LugarExpedicion).AddStyles(ws.LastAccessed,Array(sCenter, sSmall))
End Sub

Private Sub write_conceptos	As Int
	ws.PutString(merge(18,0,18,23),"CONCEPTOS").AddStyle(ws.LastAccessed, sTitle)
	ws.PutString(merge(19,0,19,13),"DESCRIPCION").AddStyle(ws.LastAccessed, sTitle)
	ws.PutString(merge(19,14,19,15),"CANT").AddStyle(ws.LastAccessed, sTitle)
	ws.PutString(merge(19,16,19,19),"PU").AddStyle(ws.LastAccessed, sTitle)
	ws.PutString(merge(19,20,19,23),"IMPORTE").AddStyle(ws.LastAccessed, sTitle)
	
	Dim row As Int = 20
	For Each concepto As Concepto In gCfdi.conceptos
		Dim increase As Int = concepto.Descripcion.Length - concepto.Descripcion.Replace(CRLF, "").Length
		increase = increase + (concepto.Descripcion.Length / 54)
		
		Dim tecnicos As String = $"Clave: ${concepto.ClaveProdServ}, Unidad: ${concepto.Unidad} ${concepto.ClaveUnidad}"$
		
		ws.PutString(merge(row,0 ,row + increase,13),concepto.Descripcion).AddStyles(ws.LastAccessed,Array(sSmall,sTopJustify))
		ws.PutString(merge(row + increase + 1 ,0,row + 1 + increase,13),tecnicos).AddStyles(ws.LastAccessed,Array(sRSmall,sTopJustify))
		
		ws.PutNumber(merge(row,14,row + 1 + increase,15),concepto.Cantidad.Value).AddStyles(ws.LastAccessed,Array(sSmall,sCant))
		ws.PutNumber(merge(row,16,row + 1 + increase,19),concepto.ValorUnitario.Value).AddStyles(ws.LastAccessed,Array(sSmall,sValue))
		ws.PutNumber(merge(row,20,row + 1 + increase,23),concepto.importe.Value).AddStyles(ws.LastAccessed,Array(sSmall,sValue))
		
		row = row + 2 + increase
	Next
	
	Return row
End Sub

Private Sub write_totales(row As Int) As Int
	row = importe_y_descuento(row)
	
	If gCfdi.Descuento.isInitialized Then
		row = row + 1
		ws.PutString(merge(row,17,row,19),"SUBTOTAL").AddStyle(ws.LastAccessed, sTitle)
		ws.PutNumber(merge(row,20,row,23),gCfdi.Subtotal.Value).AddStyles(ws.LastAccessed,Array(sSmall,sValue))
	End If

	row = write_iva(row)
	row = write_ira(row)
	row = write_isr(row)
	
	row = row + 1
	ws.PutString(merge(row,17,row,19),"TOTAL").AddStyle(ws.LastAccessed, sTvalue)
	ws.PutNumber(merge(row,20,row,23),gCfdi.Total.value).AddStyles(ws.LastAccessed,Array(sSmall,sValue))
	
	Return row 
End Sub

private Sub write_timbre(row As Int, png As String)
	row = next_page_end(row) - 10
	
	ws.PutString(merge(row    , 9,row    , 23), "SELLO CFDI").AddStyle(ws.LastAccessed, sTitle)
	ws.PutString(merge(row + 1, 9,row + 3, 23), xml.SelloCFD).AddStyles(ws.LastAccessed,Array(sTopJustify, sRSmall))
	
	ws.PutString(merge(row + 5, 9,row + 5, 23), "SELLO SAT").AddStyle(ws.LastAccessed, sTitle)
	ws.PutString(merge(row + 6, 9,row + 8, 23), xml.selloSat).AddStyles(ws.LastAccessed,Array(sTopJustify, sRSmall))
		
	ws.PoiSheet.SetImage(add_png(png), 1, row + 1, 8, row + 9)	
		
End Sub

private Sub write_observaciones(row As Int, observaciones As String) As Int
	Dim increase As Int = observaciones.Length - observaciones.Replace(CRLF, "").Length
	increase = increase + (observaciones.Length / 54)
	
	ws.PutString(merge(row + 1, 0 ,row + increase,13),observaciones).AddStyles(ws.LastAccessed,Array(sSmall,sTopJustify))
	Return row + 1 + increase
End Sub

Private Sub add_png(png As String) As Int
	Dim name As String = utils.createRandomUUID  & ".png"
	Dim su As StringUtils
	File.WriteBytes(File.DirTemp, name, su.DecodeBase64(png))
	Return wb.PoiWorkbook.addimage(File.DirTemp, name)
End Sub

private Sub next_page_end(row As Int) As Int
	Do Until row Mod 50 = 0
		row = row +1
	Loop
	Return row
End Sub

Private Sub write_iva(row As Int) As Int
	Dim m As Map
	m.Initialize
	For Each concepto As Concepto In gCfdi.conceptos
		For Each concepto_traslado As ConceptoTraslado In concepto.traslados
			Dim valores(2) As Double
			If m.ContainsKey(concepto_traslado.TasaOCuota) Then
				valores = m.Get(concepto_traslado.TasaOCuota)
			Else
				valores(0) = 0
				valores(1) = 0
				m.Put(concepto_traslado.TasaOCuota,valores)
			End If
			valores(0) = valores(0) + concepto_traslado.Base.Value
			valores(1) = valores(1) + concepto_traslado.importe.Value
		Next
	Next
	
	If m.Size = 0 Then Return row
	
	For Each tasa As BigDecimal In m.Keys
		Dim valores() As Double = m.Get(tasa)
		utils_cfdi.bg_floor(valores(1),2)

		row = row + 1
		ws.PutString(merge(row,17,row,19),$"IVA ($1.2{tasa.Value * 100})"$).AddStyle(ws.LastAccessed, sTvalue)
		ws.PutNumber(merge(row,20,row,23),valores(1)).AddStyles(ws.LastAccessed,Array(sSmall,sValue))
	Next
	
	Return row
End Sub

private Sub write_ira(row As Int) As Int
	Dim ira As Double = build_impuestos_retenciones("002")
	If ira = 0 Then Return row
	
	row = row + 1
	ws.PutString(merge(row,17,row,19),$"IVA RET"$).AddStyle(ws.LastAccessed, sTvalue)
	ws.PutNumber(merge(row,20,row,23),ira).AddStyles(ws.LastAccessed,Array(sSmall,sValue))
	
	Return row
End Sub

private Sub write_isr(row As Int) As Int
	Dim ira As Double = build_impuestos_retenciones("001")
	If ira = 0 Then Return row
	
	row = row + 1
	ws.PutString(merge(row,17,row,19),$"ISR"$).AddStyle(ws.LastAccessed, sTvalue)
	ws.PutNumber(merge(row,20,row,23),ira).AddStyles(ws.LastAccessed,Array(sSmall,sValue))
	
	Return row
End Sub

Private Sub build_impuestos_retenciones(impuesto As String) As Double
	Dim importe As Double = 0
	For Each concepto As Concepto In gCfdi.conceptos
		For Each concepto_retencion As ConceptoRetencion In concepto.retenciones
			If concepto_retencion.Impuesto = impuesto Then
				importe = importe + concepto_retencion.Importe.Value
			End If
		Next
	Next
	
	Return importe
End Sub

Private Sub importe_y_descuento(row As Int) As Int
	Dim importe As Double = 0
	Dim descuento As Double = 0
	
	For Each concepto As Concepto In gCfdi.conceptos
		importe = importe + concepto.Importe.Value
		If concepto.Descuento.isInitialized Then
			descuento = descuento + concepto.Descuento.Value
		End If
	Next
	
	row = row + 1
	ws.PutString(merge(row,17,row,19),"IMPORTE").AddStyle(ws.LastAccessed, sTvalue)
	ws.PutNumber(merge(row,20,row,23),importe).AddStyles(ws.LastAccessed,Array(sSmall,sValue))
	
	If descuento > 0.00 Then
		row = row + 1
		ws.PutString(merge(row,17,row,19),"DESCUENTO").AddStyle(ws.LastAccessed, sTvalue)
		ws.PutNumber(merge(row,20,row,23),descuento).AddStyles(ws.LastAccessed,Array(sSmall,sValue))
	End If
	Return row
End Sub

private Sub write_basicos
	write_fecha
	
End Sub

private Sub write_financieros(row As Int)
	ws.PutString(merge(row + 1, 0,row + 1, 4),"FORMA PAGO").AddStyle(ws.LastAccessed, sTvalue)
	ws.PutString(merge(row + 2, 0,row + 2, 4),"METODO PAGO").AddStyle(ws.LastAccessed, sTvalue)
	ws.PutString(merge(row + 3, 0,row + 3, 4),"MONEDA").AddStyle(ws.LastAccessed, sTvalue)
	
	Dim sRight As XLStyle = wb.CreateStyle.HorizontalAlignment("RIGHT")
	ws.PutString(merge(row + 1, 5,row + 1, 6),gCfdi.FormaPago).AddStyles(ws.LastAccessed,Array(sSmall,sRight))
	ws.PutString(merge(row + 2, 5,row + 2, 6),gCfdi.MetodoPago).AddStyles(ws.LastAccessed,Array(sSmall,sRight))
	ws.PutString(merge(row + 3, 5,row + 3, 6),gCfdi.Moneda).AddStyles(ws.LastAccessed,Array(sSmall,sRight))
End Sub

Private Sub write_fecha
	ws.PutString(merge(2,20,2,23),"FECHA").AddStyle(ws.LastAccessed, sTitle)
	ws.PutDate(merge(3,20,3,23),gCfdi.Fecha.Fecha).AddStyles(ws.LastAccessed,Array(sCenter,sDate))
End Sub

Private Sub save As String
	Dim realName As String = wb.SaveAs(utils.FindUserDocumentsFolder,gUUID & ".xlsx",True)
#if debug
	fx.ShowExternalDocument(File.GetUri(File.GetFileParent(realName),File.GetName(realName)))
#else
	Dim pdfName As String = realName.Replace(".xlsx",".pdf")
	xl.PowerShellConvertToPdf(realName,pdfName,0,True)
	realName = pdfName
#End If
	Return realName
End Sub

Private Sub merge(x0 As Int, y0 As Int, x1 As Int, y1 As Int) As XLAddress
	ws.AddMergedRegion(xl.CreateXLRange(address(x0, y0),address(x1,y1)))
	Return address(x0, y0)
End Sub

private Sub address(x0 As Int, y0 As Int) As XLAddress
	Return xl.AddressZero(y0, x0)
End Sub