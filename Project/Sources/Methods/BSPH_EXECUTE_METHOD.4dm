//%attributes = {"shared":true,"preemptive":"capable"}
#DECLARE($vt_MethodName : Text; $vb_ExecuteonServeur : Boolean)
var $vl_ServerProcess : Integer
If (Bool:C1537($vb_ExecuteonServeur)) && (Application type:C494#4D Server:K5:6)
	//%T-
	$vl_ServerProcess:=Execute on server:C373($vt_MethodName; 0)
	//%T+
Else 
	EXECUTE METHOD:C1007($vt_MethodName)
End if 