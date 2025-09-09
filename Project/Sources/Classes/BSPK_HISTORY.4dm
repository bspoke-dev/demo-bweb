Class extends DataClass

exposed Function fetchSync()->$EntitySelection : cs:C1710.BSPK_HISTORYSelection
	var $vc_TableNeedSync : Collection
	If (Storage:C1525.vo_Param.vc_TableNeedSync#Null:C1517)
		$vc_TableNeedSync:=Storage:C1525.vo_Param.vc_TableNeedSync.copy()
	Else 
		$vc_TableNeedSync:=New collection:C1472
	End if 
	$EntitySelection:=This:C1470.query("isSync = :1 AND recordInfos.vt_TableName IN :2"; False:C215; $vc_TableNeedSync).orderBy("codeAction asc, createdOn ASC")
	
/********* YOUR CODE AFTER THIS ********/