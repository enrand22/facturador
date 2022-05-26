B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private frm As Form
	
	Public dato As String
	Private gModelo As String
	Private txtBuscar As TextField
	Private tbDatos As TableView
	Private lblTitulo As Label
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(modelo As String)
	frm.Initialize("",450,300)
	frm.RootPane.LoadLayout("layoutSeleccion")
	gModelo = modelo
	dato = ""
	clear_table
	write_titulo
	CallSubDelayed(Me,"focus_text")
	frm.ShowAndWait
End Sub

private Sub write_titulo
	frm.Title = gModelo.ToUpperCase
	lblTitulo.Text = $"Busca a un ${gModelo}"$
End Sub

private Sub focus_text
	txtBuscar.RequestFocus
End Sub

private Sub select_data
	If txtBuscar.Text.Length < 3 Then
		Return
	End If
	
	Dim query As String = get_query
	Dim params() As Object = get_params(query)
	Dim dt As dataTable = pull_data(query, params)
	fill_table(dt)
End Sub

private Sub clear_table
	tbDatos.Items.Clear
	tbDatos.ClearSelection
	table_visibility
End Sub

private Sub fill_table(dt As dataTable)
	clear_table
	tbDatos.SetColumns(dt.Columns)
	tbDatos.Items.AddAll(dt.Data)
	table_visibility
End Sub

private Sub table_visibility
	tbDatos.Visible = tbDatos.Items.Size > 0
End Sub

private Sub pull_data(query As String, params() As String) As dataTable
	Dim dt As dataTable
	dt.Initialize(Main.siprovi, query, params)
	Return dt
End Sub

Private Sub get_query As String
	Dim query As String
	Select gModelo
		Case "receptor"
			query = get_receptores
		Case "emisor"
			query = get_emisores
		Case "concepto"
			query = get_conceptos
	End Select
	Return query
End Sub

private Sub get_params(query As String) As String()
	Dim counter As Int = query.Length - query.Replace("?","").Length
	Dim params(counter) As String
	For i = 0 To counter -1
		params(i) = $"%${txtBuscar.Text}%"$
	Next	
	Return params
End Sub

public Sub get_receptores As String
	Return $"
		SELECT id
			 , razon_social
			FROM (
				SELECT Id_cliente as id
					 , CASE WHEN pfisica = 1
							THEN concat(fact_nombre,' ',FACT_PATERNO,' ',fact_materno)
							ELSE Fact_Razon_Social
							END as razon_social
					 , Fact_RFC as rfc
					FROM clientes
					WHERE fact_razon_social like ?
					  OR fact_nombre like ?
					  OR fact_paterno like ?
					  OR fact_materno like ?
			) as x
		WHERE TRIM(razon_social) <> ''
		ORDER BY razon_social ASC
	"$
End Sub

public Sub get_emisores As String
	Return $"
		 SELECT id
			 , RazonSocial as razon_social
			 , rfc
			FROM Sucursales
		WHERE rfc like ?
		   OR razonSocial like ?
		ORDER BY razon_social
	"$
End Sub

public Sub get_conceptos As String
	Return $"
		SELECT id_producto as id
			 , p.descripcion
			 , p.unidad
			FROM productos as p
				INNER JOIN unidades as u on p.IdUnidad = u.ID_UNIDAD
		WHERE p.activo = 1
		  AND p.descripcion like ?
		  AND u.IdClaveUnidad is not null
		  AND p.IdCveProdServ <> ''
		ORDER BY p.descripcion
	"$
End Sub

Private Sub txtBuscar_Action
	select_data
End Sub

Private Sub txtBuscar_TextChanged (Old As String, New As String)
	select_data
End Sub

Private Sub btnSeleccionar_Click
	If selected Then 
		dato = tbDatos.SelectedRowValues(0)
		frm.Close
	End If
End Sub

private Sub selected As Boolean
	Return tbDatos.SelectedRow > -1
End Sub