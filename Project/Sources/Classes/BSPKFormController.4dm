// BSPKFormController

Function onLoad
	If (This:C1470.wc=Null:C1517) && (Form:C1466.vc_Controller#Null:C1517) && (Form:C1466.vc_Controller.length>0)
		This:C1470.wc:=Form:C1466.vc_Controller[0]
		
		This:C1470.wc.onLoad()
	End if 
	If (This:C1470.wc.getMainForm().Entity#Null:C1517)
		Form:C1466.Entity:=This:C1470.wc.getMainForm().Entity
	End if 