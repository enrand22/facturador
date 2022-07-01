B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	Private TabPane1 As TabPane
	
	Private dpFecha As DatePicker
	Private cmbMetodo As ComboBox
	Private cmbForma As ComboBox
	Private cmbSerie As ComboBox
	Private txtFolio As TextField
	
	Public db_comprobante_id As String
	Public db_emisor_id As String
	Public db_receptor_id As String
	
	Public emisor_id As String
	Private lbl_emisor_razon_social As Label
	Private lbl_emisor_regimen As Label
	Private lbl_emisor_rfc As Label
	Private lbl_emisor_cp As Label
	
	Public receptor_id As String
	Private lbl_receptor_regimen As Label
	Private lbl_receptor_razon_social As Label
	Private lbl_usoCFDI As Label
	Private lbl_receptor_cp As Label
	Private lbl_receptor_rfc As Label
	
	Private tbConceptos As TableView
	
	Private CONST COLUMNAS As Int = 18
	Private CONST C_ID As Int = 0 
	Private CONST C_CONSECUTIVO As Int = 1
	Private CONST C_DESCRIPCION As Int = 2
	Private CONST C_UNIDAD As Int = 3
	Private CONST C_PU As Int = 4
	Private CONST C_CANT As Int = 5
	Private CONST C_IMPORTE As Int = 6
	Private CONST C_DESCUENTO As Int = 7
	Private CONST C_SUBTOTAL As Int = 8
	Private CONST C_PVA As Int = 9
	Private CONST C_IVA As Int = 10
	Private CONST C_PRA As Int = 11
	Private CONST C_IRA As Int = 12
	Private CONST C_PSR As Int = 13
	Private CONST C_ISR As Int = 14
	Private CONST C_NETO As Int = 15
	Private CONST C_CVE As Int = 16
	Private CONST C_CUN As Int = 17
	
	Private CONST EXPORTACION As String = "01"
	Private CONST MONEDA As String = "MXN"
	Private CONST TIPO_COMPROBANTE As String = "I"
	Private CONST C_6_DIGITS As String = "0.000000"
	Private CONST C_2_DIGITS As String = "0.00"
	
	Private txtPDescuento As TextField
	Private txtImporte As TextField
	Private txtDescuento As TextField
	Private txtSubtotal As TextField
	Private txtPiva As TextField
	Private txtPira As TextField
	Private txtPIsr As TextField
	Private txtIva As TextField
	Private txtIra As TextField
	Private txtIsr As TextField
	Private txtTotal As TextField
	
	Private txtObservaciones As TextArea
	
	Private btnTimbrar As Button
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(id As String)
	db_comprobante_id = id
	If db_comprobante_id = utils.uuid_null Then Return
	get_db_emisor
	get_db_receptor
End Sub

private Sub get_db_emisor
	db_emisor_id = utils.uuid_null	
	Dim l As List = db_get_data_from_comrpobante("db_emisor")
	If l.Size > 0 Then db_emisor_id = l.Get(0).As(db_emisor).id
End Sub

private Sub get_db_receptor
	db_receptor_id = utils.uuid_null
	Dim l As List = db_get_data_from_comrpobante("db_receptor")
	If l.Size > 0 Then db_receptor_id = l.Get(0).As(db_receptor).id
End Sub

private Sub db_get_data_from_comrpobante(model As String) As List
	Dim qb As query_builder
	qb.Initialize(model)
	qb.selected_fields(Array As String("id"))
	qb.where(CreateMap("comprobante_id":db_comprobante_id),"",False)
	Return qb.get_all(Null)
End Sub

public Sub show
	frm.Initialize("",1024,733)
	load_layout
	If db_comprobante_id <> utils.uuid_null Then load_data
	#if nomina
	If db_comprobante_id = utils.uuid_null  Then load_data_nomina
	#End If
	clean_all_txt
	disable_button_timbrado
	frm.ShowAndWait
End Sub

private Sub clean_all_txt
	clean_txt(txtTotal,C_2_DIGITS)
	clean_txt(txtIsr,C_2_DIGITS)
	clean_txt(txtIra,C_2_DIGITS)
	clean_txt(txtIva,C_2_DIGITS)
	clean_txt(txtSubtotal,C_6_DIGITS)
	clean_txt(txtDescuento,C_2_DIGITS)
	clean_txt(txtImporte,C_2_DIGITS)
	clean_txt(txtPDescuento,C_6_DIGITS)
	clean_txt(txtPiva,C_2_DIGITS)
	clean_txt(txtPira,C_2_DIGITS)
	clean_txt(txtPIsr,C_2_DIGITS)
	
	clean_all_rows
End Sub

private Sub clean_all_rows 
	For Each dr() As Object In tbConceptos.Items
		clean_row(dr)
	Next
End Sub

private Sub clean_row(dr() As Object)
	clean_txt(dr(C_IMPORTE),C_6_DIGITS)
	clean_txt(dr(C_SUBTOTAL),C_6_DIGITS)
	clean_txt(dr(C_IVA),C_6_DIGITS)
	clean_txt(dr(C_IRA),C_6_DIGITS)
	clean_txt(dr(C_ISR),C_6_DIGITS)
	clean_txt(dr(C_CANT),C_6_DIGITS)
	clean_txt(dr(C_DESCUENTO),C_6_DIGITS)
	clean_txt(dr(C_PVA),C_6_DIGITS)
	clean_txt(dr(C_PRA),C_6_DIGITS)
	clean_txt(dr(C_PSR),C_6_DIGITS)
	clean_txt(dr(C_NETO),C_6_DIGITS)
End Sub

#region cargar_datos
private Sub load_data
	If db_comprobante_id = utils.uuid_null Then Return
	
	Dim dbc As db_comprobante = load_comprobante
	load_data_comprobante(dbc)
	
	load_data_receptor(load_receptor)
	load_data_emisor(load_emisor)
	
	Dim conceptos As List = load_conceptos
	load_data_conceptos(conceptos)
	
	get_serie_de_emisor
	set_value_to_cmb(cmbSerie, dbc.serie)
	
	load_otros(dbc)
End Sub

private Sub disable_button_timbrado
	Dim dbt As db_timbre =  obtener_xml_timbrado
	
	If dbt.uuid = DB_ORM.UUID_NULL Then
		btnTimbrar.enabled = False
	End If
End Sub

Private Sub load_otros(dbc As db_comprobante)
	txtObservaciones.Text = dbc.observaciones
	
End Sub

private Sub load_comprobante As db_comprobante
	Dim qb As query_builder
	qb.Initialize("db_comprobante")
	qb.all_fields
	Return qb.get_one(Null, db_comprobante_id)
End Sub

Private Sub load_emisor As db_emisor
	Dim qb As query_builder
	qb.Initialize("db_emisor")
	qb.all_fields
	Return qb.get_one(Null, db_emisor_id)
End Sub

Private Sub load_receptor As db_receptor
	Dim qb As query_builder
	qb.Initialize("db_receptor")
	qb.all_fields
	Return qb.get_one(Null, db_receptor_id)
End Sub

Private Sub load_data_comprobante(dbc As db_comprobante)
	dpFecha.DateTicks = dbc.fecha
	set_value_to_cmb(cmbForma, dbc.forma_pago)
	set_value_to_cmb(cmbMetodo, dbc.metodo_pago)
	txtFolio.Text = dbc.folio
	
	txtImporte.Text = dbc.importe
	txtDescuento.Text = dbc.descuento
	txtPDescuento.Text = dbc.p_descuento
	txtIva.Text = dbc.iva
	txtPiva.Text = dbc.pva
	txtIra.Text = dbc.ira
	txtPira.Text = dbc.pra
	txtIsr.Text = dbc.Isr
	txtPIsr.Text = dbc.psr
	txtSubtotal.Text = dbc.Subtotal
	txtTotal.Text = dbc.Total
End Sub

private Sub load_data_emisor(dbe As db_emisor)
	lbl_emisor_cp.Text = dbe.lugar_expedicion
	lbl_emisor_razon_social.Text = dbe.nombre
	lbl_emisor_rfc.Text = dbe.rfc
	lbl_emisor_regimen.Text = dbe.regimen
End Sub

private Sub load_data_receptor(dbr As db_receptor)
	lbl_receptor_razon_social.Text = dbr.nombre
	lbl_receptor_regimen.Text = dbr.regimen
	lbl_receptor_rfc.Text = dbr.rfc
	lbl_usoCFDI.Text = dbr.uso_cfdi
	lbl_receptor_cp.Text = dbr.codigo_postal
End Sub

private Sub load_data_conceptos(conceptos As List)
	For Each dbco As db_concepto In conceptos
		load_data_concepto(dbco)
	Next
End Sub

private Sub load_data_concepto(dbco As db_concepto)
	Dim params(COLUMNAS) As Object
	params(C_ID) 			= dbco.id
	params(C_CONSECUTIVO) 	= to_txt_str(dbco.consecutivo)

	params(C_DESCRIPCION) 	= to_txt_str(dbco.descripcion)
	params(C_UNIDAD) 		= to_txt_str(dbco.unidad)
	
	params(C_PU) 			= to_txt(dbco.pu) 'precio unitario
	params(C_CANT) 			= to_txt(dbco.cant) 'cantidad
	params(C_IMPORTE) 		= to_txt(dbco.importe) 'importe
	params(C_DESCUENTO) 	= to_txt(dbco.descuento) 'descuento
	params(C_SUBTOTAL) 		= to_txt(dbco.Subtotal) 'subtotal
	
	params(C_PVA) 			= to_txt(dbco.pva) 'p_iva
	params(C_IVA) 			= to_txt(dbco.iva) 'iva
	params(C_PRA) 			= to_txt(dbco.pra) 'p_iva
	params(C_IRA) 			= to_txt(dbco.ira) 'iva
	
	params(C_PSR) 			= to_txt(dbco.psr) 'pisr
	params(C_ISR) 			= to_txt(dbco.isr) 'isr
	
	params(C_NETO) 			= to_txt(dbco.neto) 'neto
	
	params(C_CVE) 			= to_txt_str(dbco.cve)
	params(C_CUN) 			= to_txt_str(dbco.cun)
	
	tbConceptos.Items.Add(params)
End Sub

private Sub load_conceptos As List
	Dim qb As query_builder
	qb.Initialize("db_concepto")
	qb.all_fields
	qb.where(CreateMap("comprobante_id":db_comprobante_id),"",False)
	Return qb.get_all(Null)
End Sub

Private Sub load_data_nomina
	lbl_emisor_cp.Text = "74160"
	lbl_emisor_razon_social.Text = "ENRIQUE ANDRES GONZALEZ PELAEZ"
	lbl_emisor_rfc.Text = "GOPE880629UX7"
	lbl_emisor_regimen.Text = "626"
	db_emisor_id = DB_ORM.UUID_NULL
End Sub
#end region

public Sub load_layout
	frm.RootPane.LoadLayout("layoutFacturaTab")
	TabPane1.LoadLayout("layoutDatosBasicos","Datos Basicos")
	TabPane1.LoadLayout("layoutCalculos","Calculos")
	TabPane1.LoadLayout("layoutObservaciones","Observaciones")
	
	TabPane1.SelectedIndex = 0
	frm.Title = "Constructor de Facturas"
	dpFecha.DateTicks = DateTime.Now
	dpFecha.DateFormat = "dd/MM/yyyy"
	
	get_forma_de_pago
	get_metodo_de_pago
	
	init_controls
	tvConceptos_columns_widths
End Sub

Private Sub init_controls
	txtPDescuento.Text = C_6_DIGITS
	txtPiva.text 	   = C_2_DIGITS
	txtPira.Text 	   = C_6_DIGITS
	txtPIsr.Text 	   = C_2_DIGITS
End Sub

private Sub tvConceptos_columns_widths
	Dim const DEC_WIDTH As Double = 125
	tbConceptos.SetColumnWidth(C_ID,0)
	tbConceptos.SetColumnWidth(C_CONSECUTIVO,50)
	tbConceptos.SetColumnWidth(C_DESCRIPCION,500)
	tbConceptos.SetColumnWidth(C_UNIDAD,70)
	tbConceptos.SetColumnWidth(C_PU, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_CANT, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_IMPORTE, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_DESCUENTO, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_SUBTOTAL, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_PVA, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_IVA, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_PRA, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_IRA, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_PSR, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_ISR, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_NETO, DEC_WIDTH)
	tbConceptos.SetColumnWidth(C_CVE,100)
	tbConceptos.SetColumnWidth(C_CUN,100)
End Sub

#region DatosBasicos
public Sub get_metodo_de_pago
	Dim dt As dataTable = utils_cfdi.run_query($"
		SELECT c_MetodoPago as id
		 	 , descripcion
		FROM CatalogosSAT33.dbo.c_MetodoPago	
	"$, _
	Null)
	
	fill_combobox(cmbMetodo, dt)
End Sub

public Sub get_forma_de_pago
	Dim dt As dataTable = utils_cfdi.run_query($"
		SELECT c_FormaPago as id
			 , descripcion
			FROM CatalogosSAT33.dbo.c_FormaPago
		ORDER BY c_formaPago
	"$, _
	Null)
	
	fill_combobox(cmbForma, dt)
End Sub

private Sub fill_combobox(cmb As ComboBox, dt As dataTable)
	cmb.Items.Clear
	For i = 0 To dt.RowsCount -1
		cmb.Items.Add(dt.getCellValue(i, "descripcion"))
	Next
	cmb.Tag = dt
	
	If cmb.Items.Size = 0 Then Return
	cmb.SelectedIndex = 0
End Sub

Private Sub btnReceptor_Click
	receptor_id = utils_cfdi.seleccion("receptor").dato
	get_receptor
End Sub

Private Sub btnEmisor_Click
	emisor_id = utils_cfdi.seleccion("emisor").dato
	get_emisor
End Sub

private Sub get_receptor
	Dim dt As dataTable = utils_cfdi.run_query($"
		SELECT Id_cliente as id
			, CASE WHEN pfisica = 1
				THEN concat(fact_nombre,' ',FACT_PATERNO,' ',fact_materno)
				ELSE Fact_Razon_Social
				END as razon_social
			, Fact_RFC as rfc
			, Fact_CP as cp
			, usoCFDI
			, TRIM(fact_nota) as regimen
		FROM clientes
		WHERE id_cliente = ?
	"$, _
	Array As String(receptor_id))
	If dt.RowsCount = 0 Then Return
	
	lbl_receptor_razon_social.Text = dt.getCellValue(0,"razon_social")
	lbl_receptor_regimen.Text      = dt.getCellValue(0,"regimen")
	lbl_receptor_rfc.text          = dt.getCellValue(0,"rfc")
	lbl_receptor_cp.Text		   = dt.getCellValue(0,"cp")
	lbl_usoCFDI.Text 			   = dt.getCellValue(0,"usoCFDI")
	db_receptor_id 				   = DB_ORM.UUID_NULL
End Sub

Private Sub get_emisor
	Dim dt As dataTable = utils_cfdi.run_query($"
		SELECT s.razonSocial as razon_social
			 , s.rfc
			 , sr.IdRegimen as regimen
			 , s.codigoPostal as cp
			FROM Sucursales as s
			INNER JOIN SucursalesRegimen as sr on s.id = sr.IdSucursal
		WHERE s.id = ?
	"$, _
	Array As String(emisor_id))
	If dt.RowsCount = 0 Then Return
	
	lbl_emisor_razon_social.Text = dt.getCellValue(0,"razon_social")
	lbl_emisor_regimen.Text      = dt.getCellValue(0,"regimen")
	lbl_emisor_rfc.text          = dt.getCellValue(0,"rfc")
	lbl_emisor_cp.text           = dt.getCellValue(0,"cp")
	db_emisor_id 				 = DB_ORM.UUID_NULL
	get_serie_de_emisor
End Sub

Private Sub get_serie_de_emisor
	Dim dt As dataTable = utils_cfdi.run_query($"
		SELECT Serie as id
			 , Serie as descripcion
			FROM SucursalesFolios
		WHERE IdSucursal = ?
		  AND Tipo = 'FA'
	"$, _
	Array As String(emisor_id))
	
	fill_combobox(cmbSerie, dt)
End Sub
#End Region

#region conceptos
Private Sub btnConcepto_Click
	create_concepto_row
End Sub

Private Sub create_concepto_row
	Dim concepto_id As String = utils_cfdi.seleccion("concepto").dato
	If concepto_id = "" Then Return
	Dim concepto_dt As Map = get_concepto(concepto_id)
	prepare_concepto_row(concepto_dt)
End Sub

private Sub prepare_concepto_row(concepto As Map)
	Dim params(COLUMNAS) As Object
	params(C_ID) 			= utils.uuid_null 'id
	params(C_CONSECUTIVO) 	= to_txt_str(current_consecutivo + 1)

	params(C_DESCRIPCION) 	= to_txt_str(concepto.Get("descripcion"))
	params(C_UNIDAD) 		= to_txt_str(concepto.Get("unidad"))
	
	params(C_PU) 			= to_txt(C_6_DIGITS) 'precio unitario
	params(C_CANT) 			= to_txt(C_6_DIGITS) 'cantidad
	params(C_IMPORTE) 		= to_txt(C_6_DIGITS) 'importe
	params(C_DESCUENTO) 	= to_txt(C_6_DIGITS) 'descuento
	params(C_SUBTOTAL) 		= to_txt(C_6_DIGITS) 'subtotal
	
	params(C_PVA) 			= to_txt(txtPiva.text) 'p_iva
	params(C_IVA) 			= to_txt(C_6_DIGITS) 'iva
	params(C_PRA) 			= to_txt(txtPira.text) 'p_iva
	params(C_IRA) 			= to_txt(C_6_DIGITS) 'iva
	
	params(C_PSR) 			= to_txt(txtPIsr.text) 'pisr
	params(C_ISR) 			= to_txt(C_6_DIGITS) 'isr
	
	params(C_NETO) 			= to_txt(C_6_DIGITS) 'neto
	
	params(C_CVE) 			= to_txt_str(concepto.Get("IdCveProdServ"))
	params(C_CUN) 			= to_txt_str(concepto.Get("IdClaveUnidad"))
	
	tbConceptos.Items.Add(params)
End Sub

private Sub to_txt_str(v As String) As TextField
	Dim txt As TextField
	txt.Initialize("")
	txt.Tag = "str"
	
	txt.Text = v
	Return txt
End Sub

Private Sub to_txt(v As String) As TextField
	Dim txt As TextField
	If Not(IsNumber(v)) Then
		txt.Initialize("")
	Else
		txt.Initialize("value_updated")
	End If
	
	txt.Tag = "int"
	txt.Text = v
	Return txt
End Sub

Private Sub value_updated_TextChanged (Old As String, New As String)

End Sub

Private Sub value_updated_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_6_DIGITS)
End Sub

private Sub current_consecutivo As Int
	Dim index As Int = 0
	For Each dr() As Object In tbConceptos.Items
		index = Max(index,dr(1).As(Int))
	Next
	Return index
End Sub

Private Sub get_concepto(id As String) As Map
	Dim dt As dataTable = utils_cfdi.run_query($"
		SELECT p.id_producto as id
			 , p.descripcion
			 , p.IdCveProdServ
			 , p.unidad
			 , u.IdClaveUnidad
			FROM productos as p
			INNER JOIN unidades as u on p.IdUnidad = u.ID_UNIDAD
		WHERE p.id_producto = ?
	"$, _
	Array As String(id))
	
	Return dt.getRowMapValues(0)
End Sub


#end region

#Region calcular
Private Sub btnRecalcular_Click
	calcular_completo
	clean_all_txt
End Sub

Private Sub calcular_totales
	Dim importe, descuento, subtotal, iva, ira, isr, total As Double
	
	For Each dr() As Object In tbConceptos.Items
		Dim dm() As Object = convert_dr(dr)
		importe 	= importe + dm(C_IMPORTE)
		descuento 	= descuento + dm(C_DESCUENTO)
		subtotal 	= subtotal + dm(C_SUBTOTAL)
		iva 		= iva + dm(C_IVA)
		ira 		= ira + dm(C_IRA)
		isr 		= isr + dm(C_ISR)
	Next
	
	total = subtotal + iva - (ira + isr)
	
	txtTotal.Text 		= total
	txtIsr.Text 		= isr
	txtIra.Text 		= ira
	txtIva.Text 		= iva
	txtSubtotal.Text 	= subtotal
	txtDescuento.Text 	= descuento
	txtImporte.Text 	= importe
End Sub

private Sub calcular_filas
	For Each dr() As Object In tbConceptos.Items
		calcular_fila(dr)
	Next
End Sub

private Sub calcular_fila(dr() As Object)
	dr(C_IMPORTE).As(TextField).Text = to_value(dr(C_PU)) * to_value(dr(C_CANT))
	dr(C_SUBTOTAL).As(TextField).Text = to_value(dr(C_IMPORTE)) - to_value(dr(C_DESCUENTO))
	
	dr(C_IVA).As(TextField).Text = to_value(dr(C_SUBTOTAL)) * (to_value(dr(C_PVA)) / 100)
	dr(C_IRA).As(TextField).Text = to_value(dr(C_SUBTOTAL)) * (to_value(dr(C_PRA)) / 100)
	dr(C_ISR).As(TextField).Text = to_value(dr(C_SUBTOTAL)) * (to_value(dr(C_PSR)) / 100)
	
	clean_row(dr)
End Sub

private Sub calcular_completo
	calcular_filas
	calcular_totales
End Sub

private Sub change_ps(v As String, constant As Int)
	For Each dr() As Object In tbConceptos.Items
		dr(constant) = v
	Next
End Sub

Private Sub txtPIsr_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_2_DIGITS)
	change_ps(txt.Text,C_PSR)
End Sub

Private Sub txtPira_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_6_DIGITS)
	change_ps(txt.Text,C_PRA)
End Sub

Private Sub txtPiva_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_2_DIGITS)
	change_ps(txt.Text,C_PVA)
End Sub

Private Sub txtPDescuento_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_6_DIGITS)
	descontar
End Sub

Private Sub descontar
	For Each dr() As Object In tbConceptos.Items
		Dim txtDescontar As TextField = dr(C_DESCUENTO)
		txtDescontar.text = dr(C_IMPORTE).As(TextField).text.As(Double) * txtPDescuento.Text.As(Double) / 100
	Next
End Sub

Private Sub txtTotal_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_2_DIGITS)
End Sub

Private Sub txtIsr_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_2_DIGITS)
End Sub

Private Sub txtIra_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_2_DIGITS)
End Sub

Private Sub txtIva_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_2_DIGITS)
End Sub

Private Sub txtDescuento_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_2_DIGITS)
End Sub

Private Sub txtSubtotal_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_2_DIGITS)
End Sub

Private Sub txtImporte_FocusChanged (HasFocus As Boolean)
	Dim txt As TextField = Sender
	If HasFocus Then Return
	clean_txt(txt,C_2_DIGITS)
End Sub
#End Region

#region input_helpers
private Sub clean_txt(txt As TextField, digits As String)
	Dim new As String = txt.text
	
	If Not(IsNumber(new)) Then
		txt.Text = digits
		Return
	End If
	
	If new.Length = 0 Then
		txt.text = digits
		Return
	End If
	
	Dim dot As Int = new.IndexOf(".")
	If dot = -1 Then
		txt.text = new & digits.SubString(dot + 2)
		Return
	End If
	
	txt.Text = pad_zero(new, digits.SubString(2).Length)
	txt.Text = rm_zero(txt.Text, digits.SubString(2).Length)
End Sub

Private Sub pad_zero(v As String, digits As Int) As String
	Dim dot As Int = v.IndexOf(".")
	Dim decimals As String = v.SubString(dot)
	If decimals.Length - 1 < digits Then
		Return pad_zero(v & "0", digits)
	Else
		Return v
	End If
End Sub

Private Sub rm_zero(v As String, digits As Int) As String
	Dim dot As Int = v.IndexOf(".")
	Dim decimals As String = v.SubString(dot + 1)
	If decimals.Length > digits Then
		Return rm_zero(v.SubString2(0,v.Length - 1), digits)
	Else
		Return v
	End If
End Sub

private Sub convert_dr(dr() As Object) As Object()
	Dim dm(dr.Length) As Object
	For i = 0 To dr.Length -1
		If dr(i) Is TextField Then
			If dr(i).As(TextField).Tag.As(String) = "int" Then
				dm(i) = to_value(dr(i))
			Else
				dm(i) = dr(i).As(TextField).Text
			End If
		Else
			dm(i) = dr(i)
		End If
	Next
	Return dm
End Sub

private Sub to_value(txt As TextField) As Double
	Return txt.Text
End Sub
#end region

Private Sub btnImprimir_Click
	imprimir
End Sub

Private Sub btnTimbrar_Click
	guardar
	timbrar
End Sub

Private Sub timbrar
	Dim xml As String = build_cfdi.toPrettyXML
#if debug
	File.Writestring(File.dirapp,"factura.xml", xml)
#End If
	Dim xrs As ResumableSub = CFDI_Helper.timbrar_mf(xml,lbl_emisor_rfc.text)
	
	wait for (xrs) complete (response As Map)
	Dim cfdi As String = response.Get("cfdi")
	If cfdi <> "" Then
		guardar_timbre(xml, response)
		fx.Msgbox(frm,"Timbrado correcto","")
		imprimir
	Else
		Dim error As String = response.Get("codigo_mf_texto")
		guardar_error(xml, error)
		fx.Msgbox(frm,error,"Error de timbrado")
	End If
End Sub

private Sub imprimir
	Dim timbre As db_timbre = obtener_xml_timbrado
	Dim cp As create_pdf
	Dim name As String = cp.Initialize(build_cfdi, timbre, txtObservaciones.text)
	name = name.SubString2(0,name.LastIndexOf(".")) & ".xml"
	File.WriteString(utils.FindUserDocumentsFolder,File.GetName(name),timbre.timbre)
'	fx.ShowExternalDocument(File.GetFileParent(name))
End Sub

private Sub obtener_xml_timbrado As db_timbre
	Dim qb As query_builder
	qb.Initialize("db_timbre")
	qb.all_fields
	qb.where(CreateMap("comprobante_id":db_comprobante_id,"timbrado":1),"AND",False)
	
	Dim dbt As List = qb.get_all(Null)
	If dbt.Size = 0 Then Return empty_timbre
	Return dbt.Get(0)
End Sub

private Sub empty_timbre As db_timbre
	Return DB_ORM.create_empty_model("db_timbre")
End Sub

Private Sub guardar_timbre(xml As String, response As Map)
	Dim dbt As db_timbre = DB_ORM.create_empty_model("db_timbre")
	dbt.basico = xml
	dbt.timbre = response.Get("cfdi")
	dbt.comprobante.id = db_comprobante_id
	dbt.hora = DateTime.Now
	dbt.timbrado = True
	dbt.png = response.Get("png")
	dbt.uuid = response.Get("uuid")
	
#if debug
	File.Writestring(File.DirApp,"factura.xml", dbt.timbre)
#End If

	DB_ORM.save(dbt, Null)
End Sub

Private Sub guardar_error(xml As String, error As String)
	Dim dbt As db_timbre = DB_ORM.create_empty_model("db_timbre")
	dbt.basico = xml
	dbt.comprobante.id = db_comprobante_id
	dbt.hora = DateTime.Now
	dbt.timbrado = False
	dbt.error = error
	dbt.uuid = DB_ORM.UUID_NULL
	
	DB_ORM.save(dbt, Null)
End Sub

Private Sub btnRevisar_Click
	guardar
'	revisar
End Sub

'private Sub revisar
'	Dim xml As String = build_cfdi.toPrettyXML
'	File.Writestring(File.DirApp,"factura.xml", xml)
'	fx.ShowExternalDocument(File.GetUri(File.DirApp,"factura.xml"))
'End Sub

Private Sub btnGuardar_Click
	guardar
End Sub

#region createComprobante
Private Sub build_cfdi As Comprobante
	Dim comprobante As Comprobante
	comprobante.Initialize

	add_basicos(comprobante)
	comprobante.Emisor = build_emisor
	comprobante.Receptor = build_receptor
	comprobante.conceptos.addall(build_conceptos)

	build_traslados_iva(comprobante)
	build_retenciones(comprobante)
	
	add_totales(comprobante)
	comprobante.build
	
	CFDI_Helper.certificar(comprobante,File.Combine(File.DirApp,$"SAT\${lbl_emisor_rfc.text}"$),$"cer.cer"$)
	CFDI_Helper.firmar(comprobante,File.Combine(File.DirApp,$"SAT\${lbl_emisor_rfc.text}"$),$"key.key"$,emisor_key)
	
	Return comprobante
End Sub

Private Sub emisor_key As String
	#if nomina
	Return "^vLU!S&ktdt0"
	#else
	Return Main.siprovi.ExecQuerySingleResult2($"
		Select KeyPassword
			FROM sucursales
		WHERE id = ?
	"$, _
	Array As String(emisor_id))
	#End If
End Sub

private Sub add_totales(comprobante As Comprobante)
	comprobante.Total = utils_cfdi.bg_half_even(txtTotal.Text, 2)
	comprobante.Subtotal = utils_cfdi.bg_half_even(txtSubtotal.Text, 2)
	If txtDescuento.Text.As(Double) > 0 Then comprobante.Descuento = utils_cfdi.bg_half_even(txtDescuento.Text, 2)
End Sub

Private Sub add_basicos(comprobante As Comprobante)
	comprobante.Fecha  = utils_cfdi.to_fecha(dpFecha.DateTicks)
	comprobante.MetodoPago = get_value_from_cmb(cmbMetodo)
	comprobante.FormaPago = get_value_from_cmb(cmbForma)

	If cmbSerie.SelectedIndex > -1 Then comprobante.Serie = get_value_from_cmb(cmbSerie)
	If txtFolio.Text <> "" Then comprobante.Folio = txtFolio.text
	
	comprobante.LugarExpedicion = lbl_emisor_cp.text
	comprobante.Moneda = MONEDA
	comprobante.TipoDeComprobante = TIPO_COMPROBANTE
	comprobante.Exportacion = EXPORTACION
End Sub

Private Sub get_value_from_cmb(cmb As ComboBox) As String
	Dim dt As dataTable = cmb.Tag
	Return dt.getCellValue(cmb.SelectedIndex, "id")
End Sub

Private Sub set_value_to_cmb(cmb As ComboBox, value As String)
	Dim dt As dataTable = cmb.Tag
	For i = 0 To dt.RowsCount -1
		If value = dt.getCellValue(i,"id") Then
			cmb.SelectedIndex = i
			Return
		End If
	Next
End Sub

Private Sub build_traslados_iva(comprobante As Comprobante)
	Dim m As Map
	m.Initialize

	For Each concepto As Concepto In comprobante.conceptos
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
	
	If m.Size = 0 Then Return
	
	Dim total As Double
	For Each tasa In m.Keys
		Dim traslado As Traslado
		traslado.Initialize
		Dim valores() As Double = m.Get(tasa)
		
		traslado.Base = utils_cfdi.bg_floor(valores(0),2)
		traslado.importe = utils_cfdi.bg_floor(valores(1),2)
		traslado.TasaOCuota = tasa
		traslado.TipoFactor = "TASA"
		traslado.Impuesto = "002"
		
		comprobante.traslados.Add(traslado)
		total = total + valores(1)
	Next
	comprobante.TotalImpuestosTrasladados = utils_cfdi.bg_floor(total, 2)
End Sub

private Sub build_retenciones(comprobante As Comprobante)
	Dim ira As Double = build_retencion_ira(comprobante)
	Dim isr As Double = build_retencion_isr(comprobante)
	
	If ira + isr = 0 Then Return
	comprobante.TotalImpuestosRetenidos = utils_cfdi.bg_half_even(ira + isr, 2)
End Sub

Private Sub build_retencion_ira(comprobante As Comprobante) As Double
	Return build_impuestos_retenciones(comprobante, "002")
End Sub

private Sub build_retencion_isr(comprobante As Comprobante) As Double
	Return build_impuestos_retenciones(comprobante, "001")
End Sub

Private Sub build_impuestos_retenciones(comprobante As Comprobante, impuesto As String) As Double
	Dim importe As Double = 0
	For Each concepto As Concepto In comprobante.conceptos
		For Each concepto_retencion As ConceptoRetencion In concepto.retenciones
			If concepto_retencion.Impuesto = impuesto Then
				importe = importe + concepto_retencion.Importe.Value
			End If
		Next
	Next
	
	If importe = 0 Then Return 0

	Dim retencion As Retencion
	retencion.Initialize
	retencion.Importe = utils_cfdi.bg_half_even(importe, 2)
	retencion.Impuesto = impuesto

	comprobante.retenciones.Add(retencion)
	Return importe
End Sub

PRivate Sub build_emisor As Emisor
	Dim emisor As Emisor
	emisor.Initialize
	

	emisor.RFC 				= lbl_emisor_rfc.Text
	emisor.Nombre 			= lbl_emisor_razon_social.text
	emisor.RegimenFiscal 	= lbl_emisor_regimen.Text
	
	Return emisor
End Sub

Private Sub build_receptor As Receptor
	Dim receptor As Receptor
	receptor.Initialize
	
	receptor.RFC 						= lbl_receptor_rfc.Text
	receptor.Nombre 					= lbl_receptor_razon_social.Text
	receptor.RegimenFiscalReceptor 		= lbl_receptor_regimen.Text
	receptor.DomicilioFiscalReceptor 	= lbl_receptor_cp.text
	receptor.UsoCFDI 				    = lbl_usoCFDI.Text

	Return receptor
End Sub

Private Sub build_conceptos As List
	Dim conceptos As List
	conceptos.Initialize
		
	For Each dr() As Object In tbConceptos.Items
		Dim dm() As Object = convert_dr(dr)
		conceptos.Add(build_concepto(dm))
	Next

	Return conceptos
End Sub

Private Sub build_concepto(dr() As Object) As Concepto
	Dim concepto As Concepto
	concepto.Initialize
	
	concepto.Descripcion 	= dr(C_DESCRIPCION)
	concepto.Unidad 		= dr(C_UNIDAD)
	concepto.ClaveUnidad 	= dr(C_CUN)
	concepto.ClaveProdServ 	= dr(C_CVE)
	
	concepto.Cantidad 		= utils_cfdi.bg_half_even(dr(C_CANT), 6)
	concepto.ValorUnitario 	= utils_cfdi.bg_half_even(dr(C_PU), 6)
	concepto.Importe 		= utils_cfdi.bg_half_even(dr(C_IMPORTE), 6)
	
	If dr(C_DESCUENTO) > 0 Then
		concepto.Descuento 	= utils_cfdi.bg_half_even(dr(C_DESCUENTO), 6)
	End If
	
	If dr(C_PVA) > 0 Then
		concepto.traslados.Add(build_concepto_iva(dr))
	End If
	
	If dr(C_PRA) > 0 Then
		concepto.retenciones.Add(build_concepto_ira(dr))
	End If
	
	If dr(C_PSR) > 0 Then
		concepto.retenciones.Add(build_concepto_isr(dr))
	End If
	
	If concepto.traslados.Size > 0 Or concepto.retenciones.Size > 0 Then
		concepto.ObjetoImp = "02"
	End If
	
	Return concepto
End Sub

Private Sub build_concepto_iva(dr() As Object) As ConceptoTraslado
	Dim traslado As ConceptoTraslado
	traslado.Initialize
	
	traslado.Base 			= utils_cfdi.bg_half_even(dr(C_SUBTOTAL), 6)
	traslado.Impuesto 		= "002"
	traslado.TasaOCuota 	= utils_cfdi.bg_half_even(dr(C_PVA) / 100, 6)
	traslado.TipoFactor 	= "TASA"
	traslado.Importe 		= utils_cfdi.bg_half_even(dr(C_IVA), 6)
	
	Return traslado
End Sub

Private Sub build_concepto_ira(dr() As Object) As ConceptoRetencion
	Dim retencion As ConceptoRetencion
	retencion.Initialize
	
	retencion.Base 			= utils_cfdi.bg_half_even(dr(C_SUBTOTAL), 2)
	retencion.Impuesto 		= "002"
	retencion.TasaOCuota 	= utils_cfdi.bg_half_even(dr(C_PRA) / 100, 6)
	retencion.TipoFactor 	= "TASA"
	retencion.Importe 		= utils_cfdi.bg_half_even(dr(C_IRA), 6)
	
	Return retencion
End Sub

Private Sub build_concepto_isr(dr() As Object) As ConceptoRetencion
	Dim retencion As ConceptoRetencion
	retencion.Initialize
	
	retencion.Base 			= utils_cfdi.bg_half_even(dr(C_SUBTOTAL), 2)
	retencion.Impuesto 		= "001"
	retencion.TasaOCuota 	= utils_cfdi.bg_half_even(dr(C_PSR) / 100, 6)
	retencion.TipoFactor 	= "TASA"
	retencion.Importe 		= utils_cfdi.bg_half_even(dr(C_ISR), 6)
	
	Return retencion
End Sub
#end region

#region guardar
private Sub guardar
	Dim dbc As db_comprobante = prepare_db_comprobante
	Dim dbe As db_emisor = prepare_db_emisor
	Dim dbr As db_receptor = prepare_db_receptor
	Dim conceptos As List = prepare_db_conceptos
	
	
	Dim sql As SQL = utils.getConnection("")
	Try
		DB_ORM.save(dbc, sql)
		
		dbe.comprobante.id = dbc.id
		DB_ORM.save(dbe, sql)
		
		dbr.comprobante.id = dbc.id
		DB_ORM.save(dbr, sql)
		
		For Each dbco As db_concepto In conceptos
			dbco.comprobante.id = dbc.id
			DB_ORM.save(dbco,sql)
		Next
		
		db_comprobante_id = dbc.id
		db_emisor_id 	  = dbe.id
		db_receptor_id 	  = dbr.id
	Catch
		Log(LastException)
	End Try
	sql.Close
End Sub

private Sub prepare_db_comprobante As db_comprobante
	Dim dbc As db_comprobante = DB_ORM.create_empty_model("db_comprobante")
	dbc.id 					= db_comprobante_id
	dbc.fecha 				= dpFecha.DateTicks
	dbc.forma_pago 			= get_value_from_cmb(cmbForma)
	dbc.metodo_pago 		= get_value_from_cmb(cmbMetodo)
	dbc.exportacion 		= EXPORTACION
	dbc.moneda 				= MONEDA
	dbc.tipo_de_comprobante = TIPO_COMPROBANTE
	dbc.folio 				= txtFolio.Text
	
	If cmbSerie.SelectedIndex > -1 Then dbc.serie = get_value_from_cmb(cmbSerie)
	
	dbc.importe 	= text_to_value(txtImporte.Text)
	dbc.descuento 	= text_to_value(txtDescuento.Text)
	dbc.p_descuento = text_to_value(txtPDescuento.Text)
	dbc.iva 		= text_to_value(txtIva.Text)
	dbc.pva 		= text_to_value(txtPiva.Text)
	dbc.ira 		= text_to_value(txtIra.Text)
	dbc.pra 		= text_to_value(txtPira.Text)
	dbc.Isr 		= text_to_value(txtIsr.Text)
	dbc.psr 		= text_to_value(txtPIsr.Text)
	dbc.Subtotal 	= text_to_value(txtSubtotal.Text)
	dbc.Total 		= text_to_value(txtTotal.Text)
	
	dbc.observaciones = txtObservaciones.text
	
	Return dbc
End Sub

Private Sub text_to_value(text As String) As Double
	Return IIf(IsNumber(text),text,0)
End Sub

Private Sub prepare_db_emisor As db_emisor
	Dim dbe As db_emisor = DB_ORM.create_empty_model("db_emisor")
	dbe.id 				 = db_emisor_id
	dbe.lugar_expedicion = lbl_emisor_cp.Text
	dbe.nombre 			 = lbl_emisor_razon_social.Text
	dbe.rfc 			 = lbl_emisor_rfc.Text
	dbe.regimen 		 = lbl_emisor_regimen.Text
	
	Return dbe
End Sub

Private Sub prepare_db_receptor As db_receptor
	Dim dbr As db_receptor = DB_ORM.create_empty_model("db_receptor")
	dbr.id			  = db_receptor_id
	dbr.nombre 		  = lbl_receptor_razon_social.Text
	dbr.regimen 	  = lbl_receptor_regimen.Text
	dbr.rfc 		  = lbl_receptor_rfc.Text
	dbr.uso_cfdi 	  = lbl_usoCFDI.Text
	dbr.codigo_postal = lbl_receptor_cp.Text
	
	Return dbr
End Sub

private Sub prepare_db_conceptos As List
	Dim l As List
	l.Initialize
	For Each dr() As Object In tbConceptos.Items
		Dim dm() As Object = convert_dr(dr)
		l.Add(prepare_db_concepto(dm))
	Next
	Return l
End Sub

private Sub prepare_db_concepto(dm() As Object) As db_concepto
	Dim db_concepto As db_concepto = DB_ORM.create_empty_model("db_concepto")
	db_concepto.id 			= dm(C_ID)
	db_concepto.descripcion = dm(C_DESCRIPCION)
	db_concepto.unidad 	  	= dm(C_UNIDAD)
	db_concepto.cun  	  	= dm(C_CUN)
	db_concepto.cve  	  	= dm(C_CVE)
	
	db_concepto.cant 	  = text_to_value(dm(C_CANT))
	db_concepto.pu 		  = text_to_value(dm(C_PU))
	db_concepto.importe   = text_to_value(dm(C_IMPORTE))
	db_concepto.descuento = text_to_value(dm(C_DESCUENTO))
	db_concepto.Subtotal  = text_to_value(dm(C_SUBTOTAL))
	db_concepto.iva 	  = text_to_value(dm(C_IVA))
	db_concepto.pva 	  = text_to_value(dm(C_PVA))
	db_concepto.ira 	  = text_to_value(dm(C_IRA))
	db_concepto.pra 	  = text_to_value(dm(C_PRA))
	db_concepto.isr 	  = text_to_value(dm(C_ISR))
	db_concepto.psr 	  = text_to_value(dm(C_PSR))
	db_concepto.neto 	  = text_to_value(dm(C_NETO))

	Return db_concepto
End Sub

#end region
