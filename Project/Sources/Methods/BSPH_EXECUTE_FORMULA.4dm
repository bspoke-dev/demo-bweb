//%attributes = {"shared":true,"preemptive":"capable"}
// BSPH_EXECUTE_FORMULA
// Don't modify this method

#DECLARE($vt_Action : Text)
var $vt_error_called : Text
var $vo_Param : Object

Try
	EXECUTE FORMULA:C63($vo_Param.action)
End try
