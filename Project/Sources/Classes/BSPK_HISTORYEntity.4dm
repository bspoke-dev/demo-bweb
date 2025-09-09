Class extends Entity

Function store->$vo_Status : Object
	$vo_Status:=This:C1470.save()
	
Function delete->$vo_Status : Object
	$vo_Status:=This:C1470.drop()
	
Function get NeedSync->$vb_NeedSync : Boolean
	var $vc_TableNeedSync : Collection
	If (Storage:C1525.vo_Param.vc_TableNeedSync#Null:C1517)
		$vc_TableNeedSync:=Storage:C1525.vo_Param.vc_TableNeedSync.copy()
	Else 
		$vc_TableNeedSync:=New collection:C1472
	End if 
	$vb_NeedSync:=($vc_TableNeedSync.indexOf(This:C1470.recordInfos.vt_TableName)>=0) & (This:C1470.isSync=False:C215)
	
	
Function query NeedSync($event : Object)->$result : Object
	var $vo_Formula : Object
	var $parameters : Collection
	var $vt_Query : Text
	$vo_Formula:=Formula:C1597(False:C215)
	$parameters:=New collection:C1472($vo_Formula)
	$vt_Query:=":1"
	$result:=New object:C1471("query"; $vt_Query; "parameters"; $parameters)
	
Function get tableName->$tableName : Text
	$tableName:=""
	If (This:C1470.recordInfos.vt_TableName#Null:C1517)
		$tableName:=This:C1470.recordInfos.vt_TableName
	End if 
	
Function get primaryKey->$primaryKey : Text
	$primaryKey:=""
	If (This:C1470.recordInfos.PrimaryKey#Null:C1517)
		$primaryKey:=String:C10(This:C1470.recordInfos.PrimaryKey)
	End if 
	
Function query tableName($event : Object)->$result : Object
	var $vt_Query : Text
	var $parameters : Collection
	$parameters:=New collection:C1472($event.value)
	Case of 
		: ($event.operator="==") | ($event.operator="===")
			$vt_Query:="recordInfos.vt_TableName = :1"
			
		: ($event.operator="!=")
			$vt_Query:="recordInfos.vt_TableName != :1"
	End case 
	$result:=New object:C1471("query"; $vt_Query; "parameters"; $parameters)
	
Function query primaryKey($event : Object)->$result : Object
	var $vt_Query : Text
	var $parameters : Collection
	$parameters:=New collection:C1472($event.value)
	Case of 
		: ($event.operator="==") | ($event.operator="===")
			$vt_Query:="recordInfos.PrimaryKey = :1"
			
		: ($event.operator="!=")
			$vt_Query:="recordInfos.PrimaryKey != :1"
	End case 
	$result:=New object:C1471("query"; $vt_Query; "parameters"; $parameters)
	
Function orderBy tableName($event : Object)->$result : Text
	If ($event.descending=True:C214)
		$result:="recordInfos.vt_TableName desc"
	Else 
		$result:="recordInfos.vt_TableName asc"
	End if 
	
Function orderBy primaryKey($event : Object)->$result : Text
	If ($event.descending=True:C214)
		$result:="recordInfos.PrimaryKey desc"
	Else 
		$result:="recordInfos.PrimaryKey asc"
	End if 
	
/********* YOUR CODE AFTER THIS ********/