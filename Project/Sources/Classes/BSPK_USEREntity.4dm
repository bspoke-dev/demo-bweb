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
	
/*** /!\ function bspk delete renomé en deleteBspk /!\ ***/
/*** END BSPKENTITY ***/
	
local Function delete($vt_GroupUuid : Text)->$vo_Status : Object
	var $UserMembership : cs:C1710.BSPK_USER_MEMBERSHIPEntity
	For each ($UserMembership; This:C1470.UsersMembership)
		$UserMembership.delete()
	End for each 
	If (Count parameters:C259>0)
		This:C1470.deleteBspk($vt_GroupUuid)
	Else 
		This:C1470.deleteBspk()
	End if 
	
	
Function get userFullName->$vt_FullName : Text
	$vt_FullName:=This:C1470.firstName+" "+Uppercase:C13(This:C1470.lastName)
	
Function query userFullName($event : Object)->$result : Object
	var $vt_Query; $vt_Search : Text
	var $parameters : Collection
	var $vo_Formula : Object
	var $Contacts : cs:C1710.BSPK_USERSelection
	var $vt_Word : Text
	
	$parameters:=New collection:C1472($vt_Search)  // two items collection
	
	
	
	
	
	$vt_Query:="firstName "+$event.operator+" :1 or lastName "+$event.operator+" :1"
	
	
	
	
	$Contacts:=ds:C1482.BSPK_USER.query($vt_Query; $event.value)
	
	$parameters:=New collection:C1472($Contacts.distinct("uuidKey"))
	$vt_Query:="uuidKey in :1"
	$result:=New object:C1471("query"; $vt_Query; "parameters"; $parameters)
	
Function checkRight($vt_Ref : Text)->$vb_Can : Boolean
	var $UserRight; $groups; $group : Object
	$vb_Can:=False:C215
	Case of 
		: (This:C1470.code="DEV")
			$vb_Can:=True:C214
		Else 
			$UserRight:=ds:C1482.BSPK_USER_RIGHT.getByRef($vt_Ref)
			If ($UserRight#Null:C1517)
				If (This:C1470.UsersMembership.length>0)
					If (This:C1470.UsersMembership.UserGroup#Null:C1517)
						If (This:C1470.UsersMembership.UserGroup.length>0)
							$groups:=This:C1470.UsersMembership.UserGroup
							For each ($group; $groups) While (Not:C34($vb_Can))
								$vb_Can:=($UserRight.getRightRulesByGroup($group).length>0)
							End for each 
						End if 
					End if 
				End if 
			End if 
	End case 
	
Function hasUserGroup($vt_NameOrUuid : Text)->$vb_Can : Boolean
	return This:C1470.UsersMembership.query("groupUuid = :1 OR UserGroup.name = :1"; $vt_NameOrUuid).length>0
	
Function addMembership($vt_GroupUuid : Text)
	var $UserMembership : cs:C1710.BSPK_USER_MEMBERSHIPEntity
	
	If (ds:C1482.BSPK_USER_GROUP.get($vt_GroupUuid)#Null:C1517)
		$UserMembership:=ds:C1482.BSPK_USER_MEMBERSHIP.new()
		$UserMembership.userUuid:=This:C1470.uuidKey
		$UserMembership.groupUuid:=$vt_GroupUuid
		$UserMembership.store()
	End if 
	
Function removeMembership($vt_GroupUuid : Text)
	var $UserMembership : cs:C1710.BSPK_USER_MEMBERSHIPEntity
	var $UserMemberships : cs:C1710.BSPK_USER_MEMBERSHIPSelection
	
	$UserMemberships:=This:C1470.UsersMembership.query("groupUuid = :1"; $vt_GroupUuid)
	If ($UserMemberships.length>0)
		$UserMembership:=$UserMemberships.first()
		$UserMembership.delete()
	End if 
	
	
Function CheckUser() : Boolean
	var $vo_POST : Object
	ARRAY TEXT:C222($at_POST_Name; 0)
	ARRAY TEXT:C222($at_POST_Value; 0)
	WEB GET VARIABLES:C683($at_POST_Name; $at_POST_Value)
	
	Try
		$vo_POST:=JSON Parse:C1218($at_POST_Value{1})
		If ($vo_POST.vo_searchfields#Null:C1517) && ($vo_POST.vo_searchfields.vt_GroupSelected#Null:C1517)
			If (This:C1470.UsersMembership.length>0) && (This:C1470.UsersMembership.UserGroup.query("uuidKey = :1"; $vo_POST.vo_searchfields.vt_GroupSelected).length>0)
				return True:C214
			End if 
		End if 
	End try
	return False:C215
	
/********* YOUR CODE AFTER THIS ********/
	
	