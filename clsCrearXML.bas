B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private gConceptos As List
	Private gTotales As Map
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(conceptos As List, totales As Map)
	gConceptos = conceptos
	gTotales = totales
End Sub

Private Sub build_factura As 
