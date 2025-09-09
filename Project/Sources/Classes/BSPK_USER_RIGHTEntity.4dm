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
	
	
local Function delete($vt_GroupUuid : Text)->$vo_Status : Object
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
/*** END BSPKENTITY ***/
	
local Function store->$vo_Status : Object
	$vo_Status:=This:C1470.storeBspk()
	
	This:C1470.checkExistanceOfRight()
	
Function checkExistanceOfRight
	var $UsersRight; $UsersRights; $UserRight : Object
	var $pos : Integer
	var $vt_PropertyName; $vt_Right : Text
	
	// vérification des droits minimal
	
	// on vérifie que le droit principale existe
	$pos:=Position:C15("_"; This:C1470.ref)
	If ($pos>0)
		$vt_Right:=Substring:C12(This:C1470.ref; 1; $pos-1)
		If (ds:C1482.BSPK_USER_RIGHT.query("ref= :1"; $vt_Right).length=0)
			$UserRight:=ds:C1482.BSPK_USER_RIGHT.new()
			$UserRight.ref:=$vt_Right
			If (This:C1470.langName#Null:C1517)
				$UserRight.langName:=This:C1470.langName
			Else 
				$UserRight.langName:=New object:C1471("fr"; $vt_Right; "en"; $vt_Right)
			End if 
			$UserRight.store()
		End if 
	Else 
		$vt_Right:=This:C1470.ref
	End if 
	
	If ($vt_Right#"") && ($vt_Right#"PLUGIN")
		// on vérifie que les droits principaux existe
		If (ds:C1482.BSPK_USER_RIGHT.query("ref= :1"; $vt_Right+"_CREATE").length=0)
			$UserRight:=ds:C1482.BSPK_USER_RIGHT.new()
			$UserRight.ref:=$vt_Right+"_CREATE"
			$UserRight.langName:=New object:C1471("fr"; "Créer"; "en"; "Create")
			$UserRight.store()
		End if 
		If (ds:C1482.BSPK_USER_RIGHT.query("ref= :1"; $vt_Right+"_UPDATE").length=0)
			$UserRight:=ds:C1482.BSPK_USER_RIGHT.new()
			$UserRight.ref:=$vt_Right+"_UPDATE"
			$UserRight.langName:=New object:C1471("fr"; "Modifier"; "en"; "Update")
			$UserRight.store()
		End if 
		If (ds:C1482.BSPK_USER_RIGHT.query("ref= :1"; $vt_Right+"_DELETE").length=0)
			$UserRight:=ds:C1482.BSPK_USER_RIGHT.new()
			$UserRight.ref:=$vt_Right+"_DELETE"
			$UserRight.langName:=New object:C1471("fr"; "Supprimer"; "en"; "Delete")
			$UserRight.store()
		End if 
		If (ds:C1482.BSPK_USER_RIGHT.query("ref= :1"; $vt_Right+"_PRINT").length=0)
			$UserRight:=ds:C1482.BSPK_USER_RIGHT.new()
			$UserRight.ref:=$vt_Right+"_PRINT"
			$UserRight.langName:=New object:C1471("fr"; "Imprimer"; "en"; "Print")
			$UserRight.store()
		End if 
		If (ds:C1482.BSPK_USER_RIGHT.query("ref= :1"; $vt_Right+"_EXPORT").length=0)
			$UserRight:=ds:C1482.BSPK_USER_RIGHT.new()
			$UserRight.ref:=$vt_Right+"_EXPORT"
			$UserRight.langName:=New object:C1471("fr"; "Exporter"; "en"; "Export")
			$UserRight.store()
		End if 
		
		// on vérifie que le droit de base commence par un espace
		$UserRight:=ds:C1482.BSPK_USER_RIGHT.query("ref= :1"; $vt_Right).first()
		If ($UserRight.langName#Null:C1517)
			For each ($vt_PropertyName; $UserRight.langName)
				If ($UserRight.langName[$vt_PropertyName]#" @")
					$UserRight.langName[$vt_PropertyName]:=" "+$UserRight.langName[$vt_PropertyName]
				End if 
			End for each 
			If ($UserRight.touched())
				$UserRight.store()
			End if 
		End if 
	End if 
	
Function getRightRulesByGroup($vv_Group : Variant)->$UserRightRules : Object
	If (Asserted:C1132(Count parameters:C259=1; "un paramètre obligatoire"))
		If (Value type:C1509($vv_Group)=Is text:K8:3)
			$UserRightRules:=ds:C1482.BSPK_USER_RIGHT_RULE.query("userRightUuid = :1 AND userGroupUuid = :2"; This:C1470.uuidKey; $vv_Group)
		Else 
			$UserRightRules:=ds:C1482.BSPK_USER_RIGHT_RULE.query("userRightUuid = :1 AND userGroupUuid = :2"; This:C1470.uuidKey; $vv_Group.uuidKey)
		End if 
	End if 
	
Function isInUserGroup($vt_NameOrUuid : Text) : Boolean
	return This:C1470.UserRightRules.UserGroup.query("uuidKey = :1 OR name = :1"; $vt_NameOrUuid).length>0
	
Function addUserRight($vt_GroupUuid : Text)
	var $UserRightRule : cs:C1710.BSPK_USER_RIGHT_RULEEntity
	
	If (ds:C1482.BSPK_USER_GROUP.get($vt_GroupUuid)#Null:C1517)
		$UserRightRule:=ds:C1482.BSPK_USER_RIGHT_RULE.new()
		$UserRightRule.userRightUuid:=This:C1470.uuidKey
		$UserRightRule.userGroupUuid:=$vt_GroupUuid
		$UserRightRule.store()
	End if 
	
Function removeUserRight($vt_GroupUuid : Text)
	var $UserRightRule : cs:C1710.BSPK_USER_RIGHT_RULEEntity
	var $UserRightRules : cs:C1710.BSPK_USER_RIGHT_RULESelection
	
	$UserRightRules:=This:C1470.UserRightRules.query("userGroupUuid = :1"; $vt_GroupUuid)
	If ($UserRightRules.length>0)
		$UserRightRule:=$UserRightRules.first()
		$UserRightRule.delete()
	End if 
	
Function CheckRight() : Boolean
	var $vo_POST : Object
	ARRAY TEXT:C222($at_POST_Name; 0)
	ARRAY TEXT:C222($at_POST_Value; 0)
	WEB GET VARIABLES:C683($at_POST_Name; $at_POST_Value)
	
	Try
		$vo_POST:=JSON Parse:C1218($at_POST_Value{1})
		If ($vo_POST.vo_searchfields#Null:C1517) && ($vo_POST.vo_searchfields.vt_GroupSelected#Null:C1517)
			If (This:C1470.UserRightRules.length>0) && (This:C1470.UserRightRules.query("userGroupUuid = :1"; $vo_POST.vo_searchfields.vt_GroupSelected).length>0)
				return True:C214
			End if 
		End if 
	End try
	return False:C215
	
/********* YOUR CODE AFTER THIS ********/