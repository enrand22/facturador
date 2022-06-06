B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private node As XmlNode
	Private complemento As XmlNode	
	
	Public uuid As String
	Public selloSat As String
	Public SelloCFD As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(xml As String)
	get_node(xml)
	obtener_impuestos
	obtener_timbrado
End Sub

Private Sub get_node(xml As String)
	Dim sxw As SimpleXMLWrapper
	sxw.Initialize3(xml)
	node = sxw.RootNode
	If node.haschild("cfdi:Complemento") Then complemento = node.getChild("cfdi:Complemento")
End Sub

private Sub obtener_impuestos
	Dim iva As Double = 0
	Dim isr As Double = 0
	Dim ieps As Double = 0
	Dim ivaret As Double = 0
	Dim isrret As Double = 0
		
	If node.haschild("cfdi:Impuestos") Then
		Dim impuestos As XmlNode = node.getChild("cfdi:Impuestos")
		If impuestos.hasChild("cfdi:Traslados") Then
			Dim ptraslados As XmlNode = impuestos.getChild("cfdi:Traslados")
			Dim traslados As List = ptraslados.As(JavaObject).RunMethod("getChildren",Null)
					
			For Each traslado As XmlNode In traslados
				If Not(traslado.hasAttribute("Importe")) Then
					Continue
				End If
						
				Dim tipo As String = traslado.GetAttribute("Impuesto")
				Dim Importe As Double = traslado.GetAttribute("Importe")
			
				Select tipo
					Case "002"
						iva = iva + Importe
					Case "003"
						ieps = ieps + Importe
					Case "001"
						isr = isr + Importe
				End Select
			Next
		End If

		If impuestos.hasChild("cfdi:Retenciones") Then
			Dim pretenidos As XmlNode = impuestos.getChild("cfdi:Retenciones")
			Dim retenidos As List = pretenidos.As(JavaObject).RunMethod("getChildren",Null)
			
			For Each retenido As XmlNode In retenidos
				Dim tipo As String = retenido.GetAttribute("Impuesto")
				Dim Importe As Double = retenido.GetAttribute("Importe")
			
				Select tipo
					Case "002"
						ivaret = ivaret + Importe
					Case "001"
						isrret = isrret + Importe
				End Select
			Next
		End If
	End If
			
'	Dim locTras As Double = 0
'	Dim locRet As Double = 0
	
'	If complemento.IsInitialized Then
'		If complemento.hasChild("implocal:ImpuestosLocales") Then
'			Dim impLocales As XmlNode = complemento.getChild("implocal:ImpuestosLocales")
'				
'			If impLocales.hasAttribute("TotaldeTraslados") Then
'				locTras = impLocales.GetAttribute("TotaldeTraslados")
'			End If
'				
'			If impLocales.hasAttribute("TotaldeRetenciones") Then
'				locRet = impLocales.GetAttribute("TotaldeRetenciones")
'			End If
'		End If
'	End If
End Sub

Private Sub obtener_timbrado
	If Not(complemento.IsInitialized) Then Return
	Dim timbre As XmlNode = complemento.getChild("tfd:TimbreFiscalDigital")
	
	uuid = timbre.GetAttribute("UUID")
	selloSat = timbre.GetAttribute("SelloSAT")
	SelloCFD = timbre.GetAttribute("SelloCFD")
End Sub