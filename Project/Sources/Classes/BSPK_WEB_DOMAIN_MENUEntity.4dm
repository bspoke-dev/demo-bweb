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
	
local Function store->$vo_Status : Object
	var $UDC : cs:C1710.bspkComponent.GG_DATACLASS
	$UDC:=cs:C1710.bspkComponent.GG_DATACLASS.new()
	$vo_Status:=$UDC.store(This:C1470)
	$UDC.manageSuccess($vo_Status; This:C1470)
	If ($vo_Status.success)
		This:C1470.clearStorageRedo()
	End if 
	ds:C1482.BSPK_HISTORY.query("recordInfos.PrimaryKey = :1"; This:C1470.uuidKey).orderBy("createdOn desc").slice(100).drop()
	
	
local Function delete->$vo_Status : Object
	var $UDC : cs:C1710.bspkComponent.GG_DATACLASS
	$UDC:=cs:C1710.bspkComponent.GG_DATACLASS.new()
	$vo_Status:=$UDC.delete(This:C1470)
	$UDC.manageSuccess($vo_Status; This:C1470)
	If ($vo_Status.success)
		This:C1470.clearStorageRedo()
	End if 
	
Function clearStorageRedo()
	Use (Storage:C1525)
		If (Storage:C1525.vo_Redo#Null:C1517)
			Use (Storage:C1525.vo_Redo)
				If (Storage:C1525.vo_Redo[This:C1470.uuidKey]#Null:C1517)
					Storage:C1525.vo_Redo[This:C1470.uuidKey]:=New shared collection:C1527
				End if 
			End use 
		End if 
	End use 
	
Function get isDynamic() : Boolean
	return (This:C1470.WebDomainMenuParameters.length>0)
	
Function getAllParametersForUrl()->$vc_Parameters : Collection
	var $WebDomainMenuParameter : cs:C1710.BSPK_WEB_DOMAIN_MENU_PARAMETEREntity
	var $WebDomainMenuParent : 4D:C1709.Entity
	$vc_Parameters:=[]
	$WebDomainMenuParent:=This:C1470
	While ($WebDomainMenuParent#Null:C1517)
		If ($WebDomainMenuParent.WebDomainMenuParameters.length>0)
			For each ($WebDomainMenuParameter; $WebDomainMenuParent.WebDomainMenuParameters)
				$vc_Parameters.push($WebDomainMenuParameter)
			End for each 
		End if 
		$WebDomainMenuParent:=$WebDomainMenuParent.Parent
	End while 
	
Function isVisible($user : cs:C1710.BSPK_USER) : Boolean
	var $vb_visible; $vb_Published; $vb_HasAccess : Boolean
	
	$vb_Published:=(This:C1470.publish#Null:C1517) && (This:C1470.publish)
	$vb_HasAccess:=(This:C1470.UserRight=Null:C1517) || (($user#Null:C1517) && ($user.checkRight(This:C1470.UserRight.ref)))
	
	Case of 
		: (Session:C1714.storage.vo_UserInfo#Null:C1517) && (Session:C1714.storage.vo_UserInfo.code#Null:C1517) && (Session:C1714.storage.vo_UserInfo.code="DEV")
			$vb_visible:=True:C214
			
		: ($vb_Published) && ($vb_HasAccess) && (This:C1470.publishStart#Null:C1517) && (This:C1470.publishStart#!00-00-00!) && (This:C1470.publishStart<=Current date:C33) && (This:C1470.publishEnd#Null:C1517) && (This:C1470.publishEnd#!00-00-00!) && (This:C1470.publishEnd>=Current date:C33)
			//Date de début + date de Fin
			$vb_visible:=True:C214
			
		: ($vb_Published) && ($vb_HasAccess) && (This:C1470.publishStart#Null:C1517) && (This:C1470.publishStart#Null:C1517) && (This:C1470.publishStart#!00-00-00!) && (This:C1470.publishStart<=Current date:C33) && ((This:C1470.publishEnd=!00-00-00!) || (This:C1470.publishEnd=Null:C1517))
			//Date de début
			$vb_visible:=True:C214
			
		: ($vb_Published) && ($vb_HasAccess) && (This:C1470.publishEnd#Null:C1517) && (This:C1470.publishEnd#Null:C1517) && (This:C1470.publishEnd#!00-00-00!) && (This:C1470.publishEnd>=Current date:C33) && ((This:C1470.publishStart=!00-00-00!) || (This:C1470.publishStart=Null:C1517))
			//Date de fin
			$vb_visible:=True:C214
			
		: ($vb_Published) && ($vb_HasAccess) && ((This:C1470.publishStart=!00-00-00!) || (This:C1470.publishStart=Null:C1517)) && ((This:C1470.publishEnd=!00-00-00!) || (This:C1470.publishEnd=Null:C1517))
			//Publier sans dates
			$vb_visible:=True:C214
			
		: ($vb_Published) && ($vb_HasAccess)
			$vb_visible:=True:C214
			
	End case 
	
	return $vb_visible
	
Function getUrl($vt_Lang : Text) : Text
	return This:C1470.languageOptions[$vt_Lang].url
	
Function getLangs() : Collection
	var $vt_Lang : Text
	var $vc_Langs : Collection
	
	$vc_Langs:=[]
	For each ($vt_Lang; Storage:C1525.vo_SharedStorage.vc_Langs)
		If (This:C1470.languageOptions#Null:C1517) && (This:C1470.languageOptions[$vt_Lang]#Null:C1517) && (This:C1470.languageOptions[$vt_Lang].url#Null:C1517) && (This:C1470.languageOptions[$vt_Lang].url#"")
			$vc_Langs.push($vt_Lang)
		End if 
	End for each 
	
	return $vc_Langs
	
Function isUrlActive($vt_Lang : Text)->$vb_IsActive : Boolean
	return (This:C1470.languageOptions[$vt_Lang]#Null:C1517) && (This:C1470.languageOptions[$vt_Lang].active#Null:C1517) && (This:C1470.languageOptions[$vt_Lang].active=True:C214)
	
Function getParents() : Collection
	var $vc_Parents : Collection
	var $Parent : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity
	
	$vc_Parents:=[]  // Initialize an empty collection
	$Parent:=This:C1470.Parent  // Start with the immediate parent
	
	While ($Parent#Null:C1517)
		$vc_Parents.unshift($Parent.uuidKey)  // Add the parent to the beginning of the collection
		$Parent:=$Parent.Parent  // Move to the next parent in the hierarchy
	End while 
	
	
	return $vc_Parents
	
Function getClosestParentDisplayedInMenu()->$vt_ParentUuid : Text
	var $Parent : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity
	
	$Parent:=This:C1470.Parent  // Start with the immediate parent
	
	While ($Parent#Null:C1517) && ($vt_ParentUuid="")
		If ($Parent.displayInMenu=True:C214)
			$vt_ParentUuid:=$Parent.uuidKey
		End if 
		$Parent:=$Parent.Parent  // Move to the next parent in the hierarchy
	End while 
/********* YOUR CODE AFTER THIS ********/