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
	
Function createParameter($vo_POST : Object; $Entity : Object; $vo_Session : Object; $vo_Infos : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $webDomainMenuParameter : cs:C1710.BSPK_WEB_DOMAIN_MENU_PARAMETEREntity
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	If (vo_selectedItemData#Null:C1517)
		$webDomainMenuParameter:=ds:C1482["BSPK_WEB_DOMAIN_MENU_PARAMETER"].new()
		$webDomainMenuParameter.webDomainMenuUuid:=vo_selectedItemData.vt_Id
		$webDomainMenuParameter.store()
		$vo_WebResponse.reloadBlock("listWebDomainMenuParameters")
		$vo_WebResponse.sendAlert("success"; BSPK_Translate("BSPK_succesAdd"; True:C214))
	End if 
	
Function removeParameter($vo_POST : Object; $Entity : Object; $vo_Session : Object; $vo_Infos : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $webDomainMenuParameter : cs:C1710.BSPK_WEB_DOMAIN_MENU_PARAMETEREntity
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	If (vo_selectedItemData#Null:C1517)
		$webDomainMenuParameter:=This:C1470.get($vo_POST.vt_RowPk)
		$webDomainMenuParameter.delete()
		$vo_WebResponse.reloadBlock("CA1F395EF467924A92A86C8CEDF02848"; {vo_POST: $vo_POST})
		$vo_WebResponse.sendAlert("success"; BSPK_Translate("BSPK_succesRemove"; True:C214))
	End if 
	
Function updateParameter($vo_POST : Object; $Entity : Object; $vo_Session : Object; $vo_Infos : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $webDomainMenuParameter : cs:C1710.BSPK_WEB_DOMAIN_MENU_PARAMETEREntity
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	If (vo_selectedItemData#Null:C1517)
		$vo_POST.vo_Line[$vo_POST.triggerObject.columnName]:=$vo_POST.vt_Result
		$webDomainMenuParameter:=This:C1470.get($vo_POST.vo_Line.vt_pk)
		If ($vo_POST.triggerObject.columnName="sortOrder")
			$webDomainMenuParameter[$vo_POST.columnName]:=Num:C11($vo_POST.vt_Result)
		Else 
			$webDomainMenuParameter[$vo_POST.triggerObject.columnName]:=$vo_POST.vt_Result
		End if 
		$webDomainMenuParameter[$vo_POST.triggerObject.columnName]:=$vo_POST.vt_Result
		$webDomainMenuParameter.store()
		$vo_WebResponse.updateListboxRow($vo_POST; $vo_POST.vt_BlocUuid; $webDomainMenuParameter; String:C10($vo_POST.vo_Line.vt_pk))
		$vo_WebResponse.sendAlert("success"; BSPK_Translate("BSPK_succesEdit"; True:C214))
	End if 
	
/********* YOUR CODE AFTER THIS ********/