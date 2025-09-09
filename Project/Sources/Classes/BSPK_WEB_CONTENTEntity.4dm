Class extends Entity
/*** START BSPKENTITY ***/
local Function storeBspk($vt_GroupUuid)->$vo_Status : Object
	var $UDC : cs:C1710.bspkComponent.GG_DATACLASS
	$UDC:=cs:C1710.bspkComponent.GG_DATACLASS.new()
	If (Count parameters:C259>0)
		$vo_Status:=$UDC.store(This:C1470; Session:C1714.storage.vo_UserInfo.code; $vt_GroupUuid)
	Else 
		$vo_Status:=$UDC.store(This:C1470)
	End if 
	$UDC.manageSuccess($vo_Status; This:C1470)
	If ($vo_Status.success)
		If (This:C1470["setIncrementalField"]#Null:C1517)
			//%W-550.2
			This:C1470.setIncrementalField()
			//%W+550.2
			// Mettre les deux lignes ci-dessous dans le set incremental spécifique
			//DELAY PROCESS(Current process; 10)
			//This.reload()
		End if 
	End if 
	
	
local Function deleteBspk($vt_GroupUuid : Text)->$vo_Status : Object
	var $UDC : cs:C1710.bspkComponent.GG_DATACLASS
	$UDC:=cs:C1710.bspkComponent.GG_DATACLASS.new()
	
	If (Count parameters:C259>0) && ($vt_GroupUuid#"")
		$vo_Status:=$UDC.delete(This:C1470; $vt_GroupUuid)
	Else 
		$vo_Status:=$UDC.delete(This:C1470)
	End if 
	$UDC.manageSuccess($vo_Status; This:C1470)
	
Function updateFromObject($vo_Object : Object)
	var $i : Integer
	var $vt_PropertyName : Text
	
	If ($vo_Object#Null:C1517)
		// Pour chaque propriété de l'objet
		OB GET PROPERTY NAMES:C1232($vo_Object; $at_PropertyName)
		For ($i; 1; Size of array:C274($at_PropertyName))
			$vt_PropertyName:=$at_PropertyName{$i}
			// Si la propriété existe dans l'Entité
			If (This:C1470.getDataClass()[$vt_PropertyName]#Null:C1517)
				If (This:C1470.getDataClass()[$vt_PropertyName].kind="storage")
					This:C1470[$vt_PropertyName]:=$vo_Object[$vt_PropertyName]
				End if 
			End if 
		End for 
		This:C1470.store()
	End if 
	
/*** /!\ function bspk store renomé en storeBspk /!\ ***/
/*** /!\ function bspk delete renomé en deleteBspk /!\ ***/
/*** END BSPKENTITY ***/
	
local Function delete($vt_GroupUuid : Text)->$vo_Status : Object
	BSPK_UPDATE_CSS_FILE_TW("remove"; This:C1470)
	If (Count parameters:C259>0) && ($vt_GroupUuid#"")
		$vo_Status:=This:C1470.deleteBspk($vt_GroupUuid)
	Else 
		$vo_Status:=This:C1470.deleteBspk()
	End if 
	BSPK_CLEAR_STORAGE_UNDOREDO(This:C1470.webDomainMenuUuid)
	
local Function store($vt_GroupUuid)->$vo_Status : Object
	var $UDC : cs:C1710.bspkComponent.GG_DATACLASS
	$UDC:=cs:C1710.bspkComponent.GG_DATACLASS.new()
	If (Count parameters:C259>0)
		$vo_Status:=$UDC.store(This:C1470; Session:C1714.storage.vo_UserInfo.code; $vt_GroupUuid)
	Else 
		$vo_Status:=$UDC.store(This:C1470)
	End if 
	$UDC.manageSuccess($vo_Status; This:C1470)
	ds:C1482.BSPK_HISTORY.query("recordInfos.vt_TableName = :1"; "BSPK_WEB_CONTENT").orderBy("createdOn desc").slice(200).drop()
	BSPK_CLEAR_STORAGE_UNDOREDO(This:C1470.webDomainMenuUuid)
	
	
/********* YOUR CODE AFTER THIS ********/
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	