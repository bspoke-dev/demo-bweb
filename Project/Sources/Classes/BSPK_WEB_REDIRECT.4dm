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
	
Function add($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $WebRedirect : cs:C1710.BSPK_WEB_REDIRECTEntity
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	$WebRedirect:=ds:C1482["BSPK_WEB_REDIRECT"].new()
	$WebRedirect.webDomainUuid:=$vo_POST.pk
	$WebRedirect.permanent:=False:C215
	$WebRedirect.store()
	$vo_WebResponse.sendAlert("success"; BSPK_Translate("BSPK_successAdd"); "")
	$vo_POST.vt_BlocName:="35DD46254C55C746A42E764D9112F8C7"
	$vo_WebResponse.reloadBlock("Redirections")
	
Function save($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $WebRedirect : cs:C1710.BSPK_WEB_REDIRECTEntity
	var $WebRedirects : cs:C1710.BSPK_WEB_REDIRECTSelection
	var $vb_UpdateRow : Boolean
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	$WebRedirect:=ds:C1482["BSPK_WEB_REDIRECT"].get($vo_POST.vt_RowPk)
	
	If ($WebRedirect#Null:C1517)
		Case of 
			: ($vo_POST.columnName="oldUrl")
				$WebRedirects:=ds:C1482["BSPK_WEB_REDIRECT"].query("oldUrl = :1"; $vo_POST.vt_Result)
				If ($WebRedirects.length>0)
					$vo_WebResponse.sendAlert("error"; BSPK_Translate("BSPK_urlAlreadyExists"); "")
				Else 
					$WebRedirect.oldUrl:=$vo_POST.vt_Result
					$WebRedirect.store()
					$vb_UpdateRow:=True:C214
				End if 
				
			: ($vo_POST.columnName="redirectUrl")
				If ($vo_POST.vt_Result#"")
					$WebRedirect.redirectUrl:=$vo_POST.vt_Result
					$WebRedirect.store()
					$vb_UpdateRow:=True:C214
				Else 
					$vo_WebResponse.sendAlert("error"; BSPK_Translate("BSPK_emptyValue"); "")
				End if 
			: ($vo_POST.columnName="permanent")
				If ($vo_POST.vt_Result#"")
					$WebRedirect.permanent:=Not:C34($WebRedirect.permanent)
					$WebRedirect.store()
					$vb_UpdateRow:=True:C214
				Else 
					$vo_WebResponse.sendAlert("error"; BSPK_Translate("BSPK_emptyValue"); "")
				End if 
		End case 
		
		If ($vb_UpdateRow)
			$vo_WebResponse.updateListboxRow($vo_POST; $vo_POST.vt_BlocUuid; $WebRedirect; String:C10($vo_POST.vt_RowPk))
			$vo_WebResponse.sendAlert("success"; BSPK_Translate("BSPK_succesEdit"); "")
		End if 
	End if 
	
	return $vo_WebResponse
	
Function remove($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $WebRedirect : cs:C1710.BSPK_WEB_REDIRECTEntity
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	ds:C1482.BSPK_WEB_REDIRECT.get($vo_POST.triggerObject.vt_RowPk).drop()
	$vo_WebResponse.deletedListboxRow($vo_POST)
/********* YOUR CODE AFTER THIS ********/