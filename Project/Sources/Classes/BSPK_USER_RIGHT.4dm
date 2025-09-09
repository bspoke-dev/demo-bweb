Class extends DataClass

/*** START BSPK ***/
Function getFieldList->$vc_FieldsName : Collection
	ARRAY TEXT:C222($at_FieldsName; 0)
	OB GET PROPERTY NAMES:C1232(This:C1470; $at_FieldsName)
	SORT ARRAY:C229($at_FieldsName; >)
	$vc_FieldsName:=New collection:C1472
	ARRAY TO COLLECTION:C1563($vc_FieldsName; $at_FieldsName)
	$vc_FieldsName:=$vc_FieldsName.sort()
	
	
Function getFieldVisibleInList->$vc_FieldsName : Collection
	$vc_FieldsName:=This:C1470.getFieldList()
	
Function getOrdaContext->$vo_Settings : Object
	$vo_Settings:=New object:C1471("context"; Generate UUID:C1066)
	$vo_Settings.queryPath:=(Bool:C1537(Storage:C1525.vo_Param.vb_UseOrdaWatcher))
	$vo_Settings.queryPlan:=(Bool:C1537(Storage:C1525.vo_Param.vb_UseOrdaWatcher))
	
/* Permet de créer ou modifier une entité a partir d'une objet */
Function setEntityFromObject($vo_Object : Object; $vv_PrimaryKeyValue : Variant; $vb_CannotCreate : Boolean)
	var $i : Integer
	var $vt_PropertyName; $vt_PrimaryKeyFieldName : Text
	var $Entity : Object
	
	$vt_PrimaryKeyFieldName:=This:C1470.getInfo().primaryKey
	
	If (Count parameters:C259=2)
		// Récupére l'entité depuis sa clé primaire si celle-ci est précisé
		If ($vv_PrimaryKeyValue#Null:C1517)
			$Entity:=This:C1470.get($vv_PrimaryKeyValue)
			If ($Entity=Null:C1517)
				$vb_CannotCreate:=True:C214
			End if 
		End if 
	End if 
	
	If ($vo_Object#Null:C1517)
		// Récupére l'entité depuis sa clé primaire si présente dans l'objet
		If ($vo_Object[$vt_PrimaryKeyFieldName]#Null:C1517) & ($Entity=Null:C1517)
			If ($vo_Object[$vt_PrimaryKeyFieldName]#Null:C1517)
				$Entity:=This:C1470.get($vo_Object[$vt_PrimaryKeyFieldName])
			End if 
		End if 
		
		// Créer l'entité si non éxistante
		If ($Entity=Null:C1517) & ($vb_CannotCreate=False:C215)
			$Entity:=This:C1470.new()
		End if 
		
		If ($Entity#Null:C1517)
			// Pour chaque propriété de l'objet
			OB GET PROPERTY NAMES:C1232($vo_Object; $at_PropertyName)
			For ($i; 1; Size of array:C274($at_PropertyName))
				$vt_PropertyName:=$at_PropertyName{$i}
				// Si la propriété existe dans l'Entité
				If ($Entity.getDataClass()[$vt_PropertyName]#Null:C1517)
					If ($Entity.getDataClass()[$vt_PropertyName].kind="storage")
						$Entity[$vt_PropertyName]:=$vo_Object[$vt_PropertyName]
					End if 
				End if 
			End for 
			$Entity.store()
		End if 
	End if 
	
Function checkReadEntity($user : cs:C1710.BSPK_USEREntity; $vv_Pk : Variant)->$vb_HasAccess : Boolean
	$vb_HasAccess:=True:C214
	
/*** END BSPK ***/
	
Function makeCollectionWF($vo_POST : Object)->$vo_Return : Object
	$vo_Return:={vt_ValueName: "ref"; vt_KeyName: "uuidKey"}
	$vo_Return.vc_Values:=This:C1470.all().toCollection("uuidKey,ref")
	
Function getByRef($vt_Ref : Text)->$Entity : Object
	var $Selection : Object
	
	$Selection:=This:C1470.query("ref = :1"; $vt_Ref)
	If ($Selection.length>0)
		$Entity:=$Selection.first()
	End if 
	
Function searchInRight($Selection : cs:C1710.BSPK_USERSelection; $vo_POST : Object) : cs:C1710.BSPK_USERSelection
	var $vt_Request; $vt_Param; $vt_userGroupName; $vt_Type : Text
	
	If ($vo_POST.vo_searchfields#Null:C1517) && (Not:C34(OB Is empty:C1297($vo_POST.vo_searchfields)))
		If ($Selection.length>0)
			$vt_Request:=""
			$vt_Param:=""
			
			If ($vo_POST.vo_searchfields.searchRight#Null:C1517) && ($vo_POST.vo_searchfields.searchRight#"")
				$vt_Request+="ref = :1"
				$vt_Param:=$vo_POST.vo_searchfields.searchRight
			End if 
			
			If ($vt_Request#"")
				If ($vt_Param#"")
					$Selection:=$Selection.query($vt_Request; $vt_Param)
				Else 
					$Selection:=$Selection.query($vt_Request)
				End if 
			End if 
		End if 
	End if 
	
	return $Selection
	
Function isNewNameValid($vt_Name) : Boolean
	return ($vt_Name#"") && (ds:C1482.BSPK_USER_RIGHT.query("ref = :1"; $vt_Name).length=0)
	
Function createRight($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
/* parameters
vt_BlocNameWithFields:select:getBlocsNameCollection:mandatory:tomSelect
vt_SendAllObjectsOfBlocName:hidden:vt_BlocNameWithFields
*/
	var $Right : cs:C1710.BSPK_USER_RIGHTEntity
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	
	If (This:C1470.isNewNameValid($vo_POST.vt_Result)) && ($vo_POST.vt_Result#Null:C1517) && ($vo_POST.vt_Result#"")
		$Right:=ds:C1482.BSPK_USER_RIGHT.new()
		$Right.ref:=$vo_POST.vt_Result
		$Right.langName:=New object:C1471
		$Right.store()
	Else 
		$vo_WebResponse.sendAlert("error"; BSPK_Translate("Toast_errorNameAlredyUsed"; True:C214))
	End if 
	
Function deleteRight($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $Right : cs:C1710.BSPK_USER_RIGHTEntity
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	
	If ($vo_POST.triggerObject.vt_RowPk#Null:C1517) && ($vo_POST.triggerObject.vt_RowPk#Null:C1517)
		$Right:=ds:C1482.BSPK_USER_RIGHT.get($vo_POST.triggerObject.vt_RowPk)
		If ($Right#Null:C1517)
			$Right.delete()
			$vo_WebResponse.sendAlert("success"; BSPK_Translate("Toast_succesRemove"))
		End if 
	End if 
	
Function toggleHasRight($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
/* parameters
vt_BlocNameToSend:select:getBlocsNameCollection:mandatory:tomSelect
vt_SendAllObjectsOfBlocName:hidden:vt_BlocNameToSend
*/
	var $UserRightRules : cs:C1710.BSPK_USER_RIGHT_RULESelection
	var $UserRightRule; $UserRightRuleToDelete : cs:C1710.BSPK_USER_RIGHT_RULEEntity
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	
	If ($vo_POST.vt_FieldValue#Null:C1517) && ($vo_POST.vt_FieldValue.vt_GroupSelected#Null:C1517) && ($vo_POST.vt_FieldValue.vt_GroupSelected#"") && ($vo_POST.vt_RowPk#Null:C1517) && ($vo_POST.vt_RowPk#"")
		
		$UserRightRules:=ds:C1482.BSPK_USER_RIGHT_RULE.query("userGroupUuid = :1 AND userRightUuid = :2"; $vo_POST.vt_FieldValue.vt_GroupSelected; $vo_POST.vt_RowPk)
		If ($UserRightRules.length=0)
			$UserRightRule:=ds:C1482.BSPK_USER_RIGHT_RULE.new()
			$UserRightRule.userRightUuid:=$vo_POST.vt_RowPk
			$UserRightRule.userGroupUuid:=$vo_POST.vt_FieldValue.vt_GroupSelected
			$UserRightRule.store()
		Else 
			For each ($UserRightRuleToDelete; $UserRightRules)
				$UserRightRuleToDelete.delete()
			End for each 
		End if 
	End if 
	
	$vo_WebResponse.reloadBlock($vo_POST.triggerObject.uuid)
	
/********* YOUR CODE AFTER THIS ********/