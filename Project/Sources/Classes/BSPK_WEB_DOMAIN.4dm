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
	
Function makeWebDomainLangCollection($vo_POST : Object; $Entity : cs:C1710.BSPK_WEB_DOMAINEntity; $vo_Session : Object) : Collection
	var $vc_LangsObject : Collection
	var $vt_Lang : Text
	var $ES : 4D:C1709.EntitySelection
	
	$vc_LangsObject:=[]
	If ($Entity#Null:C1517)
		For each ($vt_Lang; Storage:C1525.vo_SharedStorage.vc_Langs)
			$ES:=ds:C1482.BSPK_WEB_DOMAIN_LANG.query("lang = :1 AND webDomainUuid = :2"; $vt_Lang; $Entity.uuidKey)
			If ($Entity#Null:C1517) && ($ES.length>0)
				$vc_LangsObject.push({name: $vt_Lang; default: $ES[0].isDefault; active: True:C214})
			Else 
				$vc_LangsObject.push({name: $vt_Lang; default: False:C215; active: False:C215})
			End if 
			
		End for each 
	End if 
	return $vc_LangsObject
	
Function getTemplatesCollectionWF($vo_POST : Object)->$vo_Return : Object
	
	$vo_Return:={vt_ValueName: "vt_ValueName"; vt_KeyName: "vt_KeyName"}
	$vo_Return.vc_Values:=[{vt_KeyName: 1; vt_ValueName: BSPK_Translate("BSPK_labelTemplate1")}; {vt_KeyName: 2; vt_ValueName: BSPK_Translate("BSPK_labelTemplate2")}]
	
Function getTemplateOpionsCollectionWF($vo_POST : Object)->$vo_Return : Object
	
	$vo_Return:={vt_ValueName: "vt_ValueName"; vt_KeyName: "vt_KeyName"}
	$vo_Return.vc_Values:=[{vt_KeyName: "useHeader"; vt_ValueName: BSPK_Translate("BSPK_labelHeader")}; {vt_KeyName: "useFooter"; vt_ValueName: BSPK_Translate("BSPK_labelFooter")}; {vt_KeyName: "useSideBarLeft"; vt_ValueName: BSPK_Translate("BSPK_sideBarLeft")}; {vt_KeyName: "useSideBarRight"; vt_ValueName: BSPK_Translate("BSPK_sideBarRight")}]
	
Function getPageCollectionWF($vo_POST : Object)->$vo_Return : Object
	
	$vo_Return:={vt_ValueName: "name"; vt_KeyName: "uuidKey"}
	$vo_Return.vc_Values:=Entity.WebDomainMenus.toCollection(["uuidKey"; "name"])
	
Function createWebDomain($vo_POST : Object; $Entity : cs:C1710.BSPK_WEB_DOMAINEntity; $vo_Session : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
/* parameters
vt_BlocNameToReloadWithNewEnity:select:getBlocsNameCollection:mandatory
vt_SendAllObjectsOfBlocName:hidden:vt_BlocNameToReloadWithNewEnity
*/
	
	var $WebDomain:=cs:C1710.BSPK_WEB_DOMAINEntity
	var $WebDomainLang : cs:C1710.BSPK_WEB_DOMAIN_LANGEntity
	var $WebDomainMenu : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity
	var $Webcontent : cs:C1710.BSPK_WEB_CONTENTEntity
	
	var $vc_menuToCreate; $vc_Targets : Collection
	var $vt_ComponentName; $vt_Target; $vt_DomainName : Text
	var $cs_FolderAssets; $cs_FolderDomain : 4D:C1709.Folder
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	If ($vo_POST.vt_FieldValue=Null:C1517) || ($vo_POST.vt_FieldValue.name=Null:C1517) || ($vo_POST.vt_FieldValue.name="")
		$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: BSPK_Translate("BSPK_error"); vt_AlertMessage: BSPK_Translate("BSPK_errorDomainNameEmpy"); vt_AlertType: "error"})
		return $vo_WebResponse
	End if 
	
	If (ds:C1482.BSPK_WEB_DOMAIN.query("name = :1"; $vo_POST.vt_FieldValue.name).length>0)
		$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: BSPK_Translate("BSPK_error"); vt_AlertMessage: BSPK_Translate("BSPK_errorDomainNameAlradyExist"); vt_AlertType: "error"})
		return $vo_WebResponse
	End if 
	
	$WebDomain:=ds:C1482.BSPK_WEB_DOMAIN.new()
	$WebDomain.templateType:=1
	$WebDomain.name:=$vo_POST.vt_FieldValue.name
	$WebDomain.store()
	
	$cs_FolderAssets:=Folder:C1567(fk web root folder:K87:15).folder("assets")
	$vc_Targets:=["css"; "js"]
	$vt_DomainName:=$vo_POST.vt_FieldValue.name
	If (Position:C15(":"; $vt_DomainName)>0)
		$vt_DomainName:=Substring:C12($vt_DomainName; 1; Position:C15(":"; $vt_DomainName)-1)
	End if 
	$vt_DomainName+="_"+$WebDomain.uuidKey
	For each ($vt_Target; $vc_Targets)
		$cs_FolderDomain:=$cs_FolderAssets.folder($vt_Target).folder($vt_DomainName)
		$cs_FolderDomain.create()
		$cs_FolderDomain.file(".gitignore").create()
	End for each 
	
	$WebDomainLang:=ds:C1482.BSPK_WEB_DOMAIN_LANG.new()
	$WebDomainLang.lang:=String:C10(Storage:C1525.vo_SharedStorage.vt_InitLang)
	$WebDomainLang.name:=String:C10(Storage:C1525.vo_SharedStorage.vt_InitLang)
	$WebDomainLang.webDomainUuid:=$WebDomain.uuidKey
	$WebDomainLang.isDefault:=True:C214
	$WebDomainLang.store()
	
	$WebDomainMenu:=ds:C1482.BSPK_WEB_DOMAIN_MENU.new()
	$WebDomainMenu.name:="Home"
	$WebDomainMenu.category:="page"
	$WebDomainMenu.isHomepage:=True:C214
	$WebDomainMenu.publish:=True:C214
	$WebDomainMenu.sortOrder:=1
	$WebDomainMenu.urlParts:=1
	$WebDomainMenu.languageOptions:={}
	$WebDomainMenu.languageOptions[Storage:C1525.vo_SharedStorage.vt_InitLang]:={url: "/"; urlToSearch: "/"}
	$WebDomainMenu.webDomainUuid:=$WebDomain.uuidKey
	$WebDomainMenu.store()
	
	$Webcontent:=ds:C1482.BSPK_WEB_CONTENT.new()
	$Webcontent.blockName:="Home"
	$Webcontent.webDomainMenuUuid:=$WebDomainMenu.uuidKey
	$Webcontent.type:="text"
	//TODO: mettre le text à jour
	$Webcontent.objectProperties:={vo_Contents: {fr: "QmllbnZlbnVlIHN1ciBid2ViLg=="; en: "V2VsY29tZSB0byBid2ViLg=="}}
	$Webcontent.cssProperties:={}
	$Webcontent.blockProperties:={}
	$Webcontent.htmlProperties:={}
	$Webcontent.events:={}
	$Webcontent.store()
	
	$vc_menuToCreate:=["header"; "footer"; "sideBarLeft"; "sideBarRight"; "error"; "error403"; "error404"]
	For each ($vt_ComponentName; $vc_menuToCreate)
		$WebDomainMenu:=ds:C1482.BSPK_WEB_DOMAIN_MENU.new()
		$WebDomainMenu.name:=$vt_ComponentName
		$WebDomainMenu.category:="component"
		$WebDomainMenu.webDomainUuid:=$WebDomain.uuidKey
		$WebDomainMenu.store()
	End for each 
	
	This:C1470.updateRobotsTxt({vt_FieldValue: False:C215}; $WebDomain)
	$vo_WebResponse.vc_Action.push({vt_Action: "redirect"; vt_Url: "https://"+$WebDomain.name+"/bweb/domain?pk="+$WebDomain.uuidKey})
	
Function removeWebDomain($vo_POST : Object; $Entity : cs:C1710.BSPK_WEB_DOMAINEntity; $vo_Session : Object; $vo_Infos : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
/* parameters
vt_BlockName:select:getBlocsNameCollection:mandatory
*/
	var $E; $E_WebDomainMenu : 4D:C1709.Entity
	var $vt_Type; $vt_Target; $vt_DomainName : Text
	var $vc_Targets : Collection
	var $cs_FolderAssets; $cs_FolderDomain; $cs_FolderRobots : 4D:C1709.Folder
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	$vo_POST.vb_RemovePk:=True:C214
	$E:=ds:C1482.BSPK_WEB_DOMAIN.get($vo_POST.pk)
	$vt_DomainName:=$E.name
	For each ($E_WebDomainMenu; $E.WebDomainMenus)
		$vt_Type:="modules"
		If ($E_WebDomainMenu.category="component")
			$vt_Type:="subModules"
		End if 
		GG_REMOVE_TEMPLATE($E_WebDomainMenu; $vt_Type)
	End for each 
	
	$cs_FolderRobots:=Folder:C1567(fk web root folder:K87:15; *).folder("robots")
	$cs_FolderRobots.file($Entity.uuidKey+".txt").delete()
	
	$cs_FolderAssets:=Folder:C1567(fk web root folder:K87:15).folder("assets")
	$vc_Targets:=["css"; "js"]
	For each ($vt_Target; $vc_Targets)
		$cs_FolderAssets.folder($vt_Target).folder($vt_DomainName).delete(Delete with contents:K24:24)
	End for each 
	
	$E.WebDomainLang.delete()
	$E.delete()
	$vo_WebResponse.vt_Action:="redirect"
	$vo_WebResponse.vt_Url:="/bweb/dashboard"
	
Function editMetaDescriptions($vo_POST : Object; $Entity : cs:C1710.BSPK_WEB_DOMAINEntity; $vo_Session : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $vo_SelectedItem : Object
	var $WebDomainMenu : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity
	var $vc_Keys : Collection
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	If (Entity#Null:C1517)
		$vc_Keys:=["description"; "title"]
		If ($vc_Keys.indexOf($vo_POST.vt_FieldName)>-1)
			If (Entity.metaTags=Null:C1517)
				Entity.metaTags:={}
			End if 
			Entity.metaTags[$vo_POST.vt_FieldName]:=JSON Parse:C1218($vo_POST.vt_FieldValue)
			Entity.store()
			
			$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: ""; vt_AlertMessage: BSPK_Translate("BSPK_succesEdit"); vt_AlertType: "success"; vl_AlertDuration: 3})
		End if 
	End if 
	
Function updateRobotsTxt($vo_POST : Object; $Entity : cs:C1710.BSPK_WEB_DOMAINEntity; $vo_Session : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $vt_Text : Text
	var $cs_FolderRobots : 4D:C1709.Folder
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	//todo: A modifier quand il y aura le cache
	If ($vo_POST.vt_FieldValue=True:C214)
		$vt_Text:="User-agent : *\nDisallow: /"
	Else 
		$vt_Text:="User-agent : *\nAllow: /"
	End if 
	$cs_FolderRobots:=Folder:C1567(fk web root folder:K87:15; *).folder("robots")
	$cs_FolderRobots.file($Entity.uuidKey+".txt").setText($vt_Text)
	$Entity.botDisalow:=$vo_POST.vt_FieldValue
	$Entity.store()
	$vo_WebResponse.sendAlert("success"; BSPK_Translate("BSPK_succesEdit"; True:C214))
	
/********* YOUR CODE AFTER THIS ********/