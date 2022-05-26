B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
End Sub

public Sub seleccion(model As String) As frmSeleccion
	Dim obj As frmSeleccion
	obj.Initialize(model)
	Return obj
End Sub

public Sub constructor(id As String) As frmConstructorFactura
	Dim obj As frmConstructorFactura
	obj.Initialize(id)
	Return obj
End Sub

public Sub run_query(query As String, params() As String) As dataTable
	Dim dt As dataTable
	dt.Initialize(Main.siprovi, query, params)
	Return dt
End Sub

Public Sub bg_half_even(value As Double,digits As Int) As BigDecimal
	Dim bg As BigDecimal
	bg.Initialize2(value,digits,"HALF_EVEN")
	Return bg
End Sub

Public Sub bg_floor(value As Double,digits As Int) As BigDecimal
	Dim bg As BigDecimal
	bg.Initialize2(value,digits,"FLOOR")
	Return bg
End Sub

Public Sub to_fecha(ticks As Long) As Fecha
	Dim fecha As Fecha
	fecha.Initialize(ticks)
	Return fecha
End Sub