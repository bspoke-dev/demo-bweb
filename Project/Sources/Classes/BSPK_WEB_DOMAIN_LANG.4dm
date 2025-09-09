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
	
Function toggleLang($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $E; $EDefault; $E_Menu : 4D:C1709.Entity
	var $vo_ObjectToChange : Object
	var $vt_ObjectToChange; $vt_ErrorTitle; $vt_AlertMessage; $vt_ErrorMessage : Text
	var $ES; $ES2; $ES_Menu : 4D:C1709.EntitySelection
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	$vo_ObjectToChange:=OB Copy:C1225(Session:C1714.storage.vo_SelectInCurse[$vo_POST.vt_ListboxTmpUuid][Num:C11($vo_POST.triggerObject.vt_RowPk)])
	$ES:=ds:C1482.BSPK_WEB_DOMAIN_LANG.query("lang = :1 AND webDomainUuid = :2"; $vo_ObjectToChange.name; $vo_POST.pk)
	If ($ES.length>0)
		$E:=$ES[0]
	End if 
	
	$ES2:=ds:C1482.BSPK_WEB_DOMAIN_LANG.query("isDefault = :1 AND webDomainUuid = :2"; True:C214; $vo_POST.pk)
	If ($ES2.length>0)
		$EDefault:=$ES2[0]
	End if 
	
	If ($E#Null:C1517) && ($EDefault#Null:C1517) && ($EDefault.uuidKey=$E.uuidKey)
		$vt_ErrorTitle:=BSPK_Translate("BSPK_errorWarning")
		$vt_ErrorMessage:=BSPK_Translate("BSPK_errorCantRemoveDefault")
		$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: $vt_ErrorTitle; vt_AlertMessage: $vt_ErrorMessage; vt_AlertType: "warning"; vl_AlertDuration: 3})
		return $vo_WebResponse
	End if 
	
	$ES:=ds:C1482.BSPK_WEB_DOMAIN_LANG.query("lang = :1 AND webDomainUuid = :2"; $vo_ObjectToChange.name; $vo_POST.pk)
	If ($ES.length>0)
		$ES[0].drop()
		$vt_AlertMessage:="Langue désactivé"
		$vo_ObjectToChange.active:=False:C215
	Else 
		$E:=ds:C1482.BSPK_WEB_DOMAIN_LANG.new()
		$E.lang:=$vo_ObjectToChange.name
		$E.webDomainUuid:=$vo_POST.pk
		$E.isDefault:=False:C215
		$E.store()
		$vt_AlertMessage:="Langue activé"
		$vo_ObjectToChange.active:=True:C214
	End if 
	$vo_WebResponse.updateListboxRow($vo_POST; $vo_POST.triggerObject.uuid; $vo_ObjectToChange; String:C10($vo_POST.vt_RowPk))
	
	//Modifier les pages en conséquences
	$ES_Menu:=ds:C1482.BSPK_WEB_DOMAIN_MENU.query("webDomainUuid = :1 AND category # component"; $vo_POST.pk)
	For each ($E_Menu; $ES_Menu)
		If ($vo_ObjectToChange.active=True:C214)
			$E_Menu.languageOptions[$E.lang]:={}
		Else 
			OB REMOVE:C1226($E_Menu.languageOptions; $E.lang)
		End if 
		$E_Menu.store()
	End for each 
	$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: ""; vt_AlertMessage: $vt_AlertMessage; vt_AlertType: "success"; vl_AlertDuration: 3})
	
	return $vo_WebResponse
	
Function toogleDefault($vo_POST : Object; $Entity : cs:C1710.BSPK_WEB_DOMAINEntity; $vo_Session : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $vo_ObjectToChange; $vo_OldLang : Object
	var $ES; $ES2 : 4D:C1709.EntitySelection
	var $E; $EOld : 4D:C1709.Entity
	var $vt_ErrorTitle; $vt_ObjectToChange : Text
	var $vt_ErrorMessage : Text
	var $vc_Collection; $vc_Indices : Collection
	var $vl_Index : Integer
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	$vo_ObjectToChange:=OB Copy:C1225(Session:C1714.storage.vo_SelectInCurse[$vo_POST.vt_ListboxTmpUuid][Num:C11($vo_POST.triggerObject.vt_RowPk)])
	$ES:=ds:C1482.BSPK_WEB_DOMAIN_LANG.query("lang = :1 AND webDomainUuid = :2"; $vo_ObjectToChange.name; $vo_POST.pk)
	If ($ES.length>0)
		$E:=$ES[0]
	End if 
	$ES2:=ds:C1482.BSPK_WEB_DOMAIN_LANG.query("isDefault = :1 AND webDomainUuid = :2"; True:C214; $vo_POST.pk)
	If ($ES2.length>0)
		$EOld:=$ES2[0]
	End if 
	
	If ($E#Null:C1517) && ($EOld#Null:C1517) && ($EOld.uuidKey=$E.uuidKey)
		$vt_ErrorTitle:=BSPK_Translate("BSPK_errorWarning")
		$vt_ErrorMessage:=BSPK_Translate("BSPK_errorCantRemoveDefault")
		$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: $vt_ErrorTitle; vt_AlertMessage: $vt_ErrorMessage; vt_AlertType: "warning"; vl_AlertDuration: 3})
		return $vo_WebResponse
	Else 
		//Désactiver le par défaut sur l'ancienne langue
		$vc_Collection:=ds:C1482.BSPK_WEB_DOMAIN.makeWebDomainLangCollection({}; $Entity)
		$vc_Indices:=$vc_Collection.indices("default = :1 "; True:C214)
		If ($vc_Indices.length>0)
			$vl_Index:=$vc_Indices[0]
			$vo_OldLang:=$vc_Collection[$vl_Index]
			
			$EOld.isDefault:=False:C215
			$EOld.store()
			
			$vo_OldLang.default:=False:C215
			$vo_POST.row:=$vl_Index
			$vo_WebResponse.updateListboxRow($vo_POST; $vo_POST.triggerObject.uuid; $vo_OldLang; String:C10($vl_Index))
		End if 
		//Activer le par défaut sur la nouvelle langue
		If ($ES.length>0)
			$E:=$ES[0]
		Else 
			$E:=ds:C1482.BSPK_WEB_DOMAIN_LANG.new()
			$E.lang:=$vo_ObjectToChange.name
			$E.webDomainUuid:=$vo_POST.pk
		End if 
		$E.isDefault:=True:C214
		$E.store()
		$vo_ObjectToChange.active:=True:C214
		$vo_ObjectToChange.default:=True:C214
	End if 
	$vo_POST.row:=$vc_Collection.indices("name = :1 "; $E.lang)[0]
	$vo_WebResponse.updateListboxRow($vo_POST; $vo_POST.triggerObject.uuid; $vo_ObjectToChange; String:C10($vo_POST.vt_RowPk))
	$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: ""; vt_AlertMessage: BSPK_Translate("BSPK_labelNewLangSelected"); vt_AlertType: "success"; vl_AlertDuration: 3})
	
	return $vo_WebResponse
	
/********* YOUR CODE AFTER THIS ********/