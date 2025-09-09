//%attributes = {"shared":true,"preemptive":"incapable"}
#DECLARE()->$vo_Return : Object
$vo_Return:=New object:C1471
var $dc : Object
var $vt_FieldName; $vt_ColName : Text
If (Current process name:C1392="AdminTableList")
	If (Mod:C98(FORM Event:C1606.row; 2)=0)
		$vo_Return:=New object:C1471("fill"; "#fdf8f0")
	End if 
	$dc:=This:C1470.getDataClass()
	$vo_Return.cell:=New object:C1471
	For each ($vt_FieldName; This:C1470)
		$vt_ColName:=Substring:C12(BSPK_String_To_CamelCase($vt_FieldName; False:C215; False:C215; Null:C1517); 1; 31)
		If ($dc[$vt_FieldName].kind#"storage")
			$vo_Return.cell[$vt_ColName]:=New object:C1471("fill"; "#f5f5f5")
		End if 
		If (Form:C1466.vt_FieldHighLight#Null:C1517)
			If (Form:C1466.vt_FieldHighLight=$vt_FieldName)
				$vo_Return.cell[$vt_ColName]:=New object:C1471("fill"; "yellow")
			End if 
		End if 
	End for each 
End if 