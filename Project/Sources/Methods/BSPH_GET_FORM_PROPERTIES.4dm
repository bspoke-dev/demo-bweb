//%attributes = {"shared":true}
#DECLARE($vt_FormName : Text) : Object

var $vl_BlockMinWidth; $vl_BlockMinHeight : Integer

ARRAY TEXT:C222($at_FormsName; 0)
FORM GET NAMES:C1167($at_FormsName; $vt_FormName)
If (Size of array:C274($at_FormsName)>0)
	FORM GET PROPERTIES:C674($vt_FormName; $vl_BlockMinWidth; $vl_BlockMinHeight)  // cela va me permettre de récupérer les hauteurs necessaires à chaque ligne et la largeur de chaque block
Else 
	$vl_BlockMinWidth:=100
	$vl_BlockMinHeight:=20
End if 
return {vl_BlockMinWidth: $vl_BlockMinWidth; vl_BlockMinHeight: $vl_BlockMinHeight}