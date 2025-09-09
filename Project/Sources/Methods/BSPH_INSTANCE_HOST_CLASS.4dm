//%attributes = {"shared":true,"preemptive":"capable"}
#DECLARE($vt_ClassName : Text; $vb_Exist : Boolean) : Variant
If ($vb_Exist)
	return ($vt_ClassName#Null:C1517) && (cs:C1710[$vt_ClassName]#Null:C1517) && (ds:C1482[$vt_ClassName]=Null:C1517)
Else 
	If ($vt_ClassName#Null:C1517) && (cs:C1710[$vt_ClassName]#Null:C1517) && (ds:C1482[$vt_ClassName]=Null:C1517)
		return cs:C1710[$vt_ClassName].new()
	End if 
End if 