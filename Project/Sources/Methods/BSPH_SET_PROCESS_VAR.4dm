//%attributes = {"shared":true,"preemptive":"capable"}
#DECLARE($vt_ProcessVarName : Text; $vv_ProcessVar : Variant)
If (vv_Value#Null)
	vv_Value:={}  // on repasse par un objet vide pour permetre la mise a null sinon ça fait une erreur
	vv_Value:=Null
End if 
if($vv_ProcessVar#null)
    vv_Value:=$vv_ProcessVar
end if
EXECUTE FORMULA:C63($vt_ProcessVarName+":=vv_Value")