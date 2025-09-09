Class extends Entity

/*** START BSPKENTITY ***/
local Function store($vt_GroupUuid)->$vo_Status : Object
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
	
/*** END BSPKENTITY ***/
	
Function copyRights($vt_UserGroupUuid)
	var $vc_CurrentRights; $vc_ToCopyRights : Collection
	var $UserGroupCopy : cs:C1710.BSPK_USER_GROUPEntity
	var $UserRightRule; $UserRightRulesRemove : cs:C1710.BSPK_USER_RIGHT_RULEEntity
	var $UserRightRulesRemoves : cs:C1710.BSPK_USER_RIGHT_RULESelection
	var $vt_CurrentRightUuid; $vt_ToCopyRightUuid : Text
	var $vl_IndexRight : Integer
	
	$UserGroupCopy:=ds:C1482.BSPK_USER_GROUP.get($vt_UserGroupUuid)
	If ($UserGroupCopy#Null:C1517)
		$vc_CurrentRights:=This:C1470.UserRightRules.distinct("userRightUuid")
		
		$vc_ToCopyRights:=$UserGroupCopy.UserRightRules.distinct("userRightUuid")
		// Pour chaque droit actuel
		For each ($vt_CurrentRightUuid; $vc_CurrentRights)
			// Vérif si dans les droits à copier
			$vl_IndexRight:=$vc_ToCopyRights.indexOf($vt_CurrentRightUuid)
			If ($vl_IndexRight>=0)
				$vc_ToCopyRights.remove($vl_IndexRight)
			Else 
				// Retirer le droit en trop
				$UserRightRulesRemoves:=This:C1470.UserRightRules.query("userRightUuid = :1"; $vt_CurrentRightUuid)
				If ($UserRightRulesRemoves.length>0)
					$UserRightRulesRemove:=$UserRightRulesRemoves.first()
					$UserRightRulesRemove.delete()
				End if 
			End if 
		End for each 
		
		// Pour chaque droit à copier
		For each ($vt_ToCopyRightUuid; $vc_ToCopyRights)
			$UserRightRule:=ds:C1482.BSPK_USER_RIGHT_RULE.new()
			$UserRightRule.userRightUuid:=$vt_ToCopyRightUuid
			$UserRightRule.userGroupUuid:=This:C1470.uuidKey
			$UserRightRule.store()
		End for each 
	End if 
	
Function hasUserRight($vt_RefOrUuid : Text) : Boolean
	return This:C1470.UserRightRules.UserRight.query("uuidKey = :1 OR ref = :1"; $vt_RefOrUuid).length>0
	
Function hasUser($vt_UserUuid : Text) : Boolean
	return This:C1470.UsersMembership.query("userUuid = :1"; $vt_UserUuid).length>0 ? True:C214 : False:C215
	
Function addMembership($vt_UserUuid : Text)
	var $UserMembership : cs:C1710.BSPK_USER_MEMBERSHIPEntity
	
	If (ds:C1482.BSPK_USER.get($vt_UserUuid)#Null:C1517)
		$UserMembership:=ds:C1482.BSPK_USER_MEMBERSHIP.new()
		$UserMembership.userUuid:=$vt_UserUuid
		$UserMembership.groupUuid:=This:C1470.uuidKey
		$UserMembership.store()
	End if 
	
Function removeMembership($vt_UserUuid : Text)
	var $UserMembership : cs:C1710.BSPK_USER_MEMBERSHIPEntity
	var $UserMemberships : cs:C1710.BSPK_USER_MEMBERSHIPSelection
	
	$UserMemberships:=This:C1470.UsersMembership.query("userUuid = :1"; $vt_UserUuid)
	If ($UserMemberships.length>0)
		$UserMembership:=$UserMemberships.first()
		$UserMembership.delete()
	End if 
	
Function addUserRight($vt_RightUuid : Text)
	var $UserRightRule : cs:C1710.BSPK_USER_RIGHT_RULEEntity
	
	If (ds:C1482.BSPK_USER_RIGHT.get($vt_RightUuid)#Null:C1517)
		$UserRightRule:=ds:C1482.BSPK_USER_RIGHT_RULE.new()
		$UserRightRule.userRightUuid:=$vt_RightUuid
		$UserRightRule.userGroupUuid:=This:C1470.uuidKey
		$UserRightRule.store()
	End if 
	
Function removeUserRight($vt_RightUuid : Text)
	var $UserRightRule : cs:C1710.BSPK_USER_RIGHT_RULEEntity
	var $UserRightRules : cs:C1710.BSPK_USER_RIGHT_RULESelection
	
	$UserRightRules:=This:C1470.UserRightRules.query("userRightUuid = :1"; $vt_RightUuid)
	If ($UserRightRules.length>0)
		$UserRightRule:=$UserRightRules.first()
		$UserRightRule.delete()
	End if 
	
Function CheckGroup() : Boolean
	var $vo_POST : Object
	
	ARRAY TEXT:C222($at_POST_Name; 0)
	ARRAY TEXT:C222($at_POST_Value; 0)
	WEB GET VARIABLES:C683($at_POST_Name; $at_POST_Value)
	
	Try
		$vo_POST:=JSON Parse:C1218($at_POST_Value{1})
		If ($vo_POST.vo_searchfields#Null:C1517) && ($vo_POST.vo_searchfields.vt_UserSelected#Null:C1517)
			If (This:C1470.UsersMembership.length>0) && (This:C1470.UsersMembership.User.query("uuidKey = :1"; $vo_POST.vo_searchfields.vt_UserSelected).length>0)
				return True:C214
			End if 
		End if 
	End try
	return False:C215
	
/********* YOUR CODE AFTER THIS ********/