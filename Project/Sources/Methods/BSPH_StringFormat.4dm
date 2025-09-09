//%attributes = {"preemptive":"capable"}
#DECLARE($vv_TextToFormat : Variant; $vt_Format) : Text
If ($vt_Format#"|@")
	$vt_Format:="|"+$vt_Format
End if 
return String:C10($vv_TextToFormat; $vt_Format)