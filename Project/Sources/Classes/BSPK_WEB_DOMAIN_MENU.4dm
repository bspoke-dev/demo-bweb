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
	
	//Queries
Function getOneByName($vt_Name : Text) : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity
	return BSPK_GET_ONE_RESULT_OR_NULL(This:C1470.query("name = :1"; $vt_Name))
	
	//WF
	
Function getWebDomainMenuCollectionWF($vo_POST : Object)->$vo_Return : Object
/* parameters
vt_WebDomainUuid:text:mandatory
*/
	var $ES : 4D:C1709.EntitySelection
	var $E : 4D:C1709.Entity
	var $vt_Key : Text
	var $vo_Object : Object
	
	$vo_Return:={vt_ValueName: "vt_ValueName"; vt_KeyName: "vt_KeyName"}
	$vo_Return.vc_Values:=[]
	Case of 
		: ($vo_POST.vt_WebDomainUuid=Null:C1517)
		Else 
			//$vc_FieldsToSend:=["uuidKey"; "name"; "publishStart"; "publishEnd"; "url"]
			$ES:=This:C1470.query("webDomainUuid = :1"; $vo_POST.vt_WebDomainUuid).orderBy("name asc")
			For each ($E; $ES)
				//A rajouter pour que le loadBlock voit que c'est rattaché à une entitté
				$vo_Object:={}
				$vo_Object.vt_Pk:=$E.uuidKey
				$vo_Object.vt_TableName:=This:C1470.getInfo().name
				BASE64 ENCODE:C895(JSON Stringify:C1217($vo_Object); $vt_Key)
				$vo_Return.vc_Values.push({vt_ValueName: $E.name; vt_KeyName: $vt_Key})
			End for each 
	End case 
	
Function getWebDomainMenuCollectionForSelectWF($vo_POST : Object)->$vo_Return : Object
/* parameters
vt_WebDomainUuid:text:mandatory
*/
	var $ES : 4D:C1709.EntitySelection
	var $E : 4D:C1709.Entity
	var $vt_Key : Text
	var $vo_Object : Object
	
	$vo_Return:={vt_ValueName: "vt_ValueName"; vt_KeyName: "vt_KeyName"}
	$vo_Return.vc_Values:=[]
	Case of 
		: ($vo_POST.vt_WebDomainUuid=Null:C1517)
		Else 
			$ES:=This:C1470.query("webDomainUuid = :1"; $vo_POST.vt_WebDomainUuid).orderBy("name asc")
			For each ($E; $ES)
				$vo_Return.vc_Values.push({vt_ValueName: BSPK_Translate($E.name; True:C214); vt_KeyName: $E.uuidKey})
			End for each 
	End case 
	
Function getWebDomainMenuObjectsWF($vo_POST : Object)->$vo_Return : Object
/* parameters
vt_WebDomainMenuUuid:text:mandatory
*/
	var $WebDomainMenu : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity
	var $WebContents : cs:C1710.BSPK_WEB_CONTENTSelection
	
	$vo_Return:={vt_ValueName: "vt_ValueName"; vt_KeyName: "vt_KeyName"}
	$vo_Return.vc_Values:=[]
	Case of 
		: ($vo_POST.vt_WebDomainMenuUuid=Null:C1517)
		Else 
			$WebDomainMenu:=This:C1470.get($vo_POST.vt_WebDomainMenuUuid)
			If ($WebDomainMenu#Null:C1517)
				$WebContents:=ds:C1482.BSPK_WEB_CONTENT.query("webDomainMenuUuid = :1"; $WebDomainMenu.uuidKey)
				If ($WebContents.length>0)
					$vo_Return.vc_Values:=$WebContents.extract("blockName"; "vt_ValueName"; "uuidKey"; "vt_KeyName")
				End if 
			End if 
	End case 
	
	
Function makeWebDomainMenuParametersCollection($vo_POST : Object; $Entity : Object; $vo_Session : Object) : Collection
	var $E : 4D:C1709.Entity
	var $vc_MenusObject : Collection
	var $cs_WebFormController : cs:C1710.bspkComponent.WebFormController
	var $vo_SelectedItem : Object
	var $vt_UuidWebDomainLang : Text
	var $vb_Active : Boolean
	
	$vc_MenusObject:=[]
	If (vo_selectedItemData#Null:C1517) && (vo_selectedItemData.vt_TableName#Null:C1517) && (vo_selectedItemData.vt_TableName="BSPK_WEB_DOMAIN_MENU")
		$E:=ds:C1482.BSPK_WEB_DOMAIN_MENU.get(vo_selectedItemData.vt_Id)
		For each ($vt_UuidWebDomainLang; $E.languageOptions)
			$vb_Active:=($E.languageOptions[$vt_UuidWebDomainLang].active#Null:C1517) && ($E.languageOptions[$vt_UuidWebDomainLang].active=True:C214)
			$vc_MenusObject.push({name: $vt_UuidWebDomainLang; active: $vb_Active; url: $E.languageOptions[$vt_UuidWebDomainLang].url})
		End for each 
	Else 
		$vc_MenusObject.push({name: ""; url: ""; active: ""; canonical: ""})
	End if 
	
	return $vc_MenusObject
	
Function getWebDomainMenuCategoriesCollectionWF($vo_POST : Object)->$vo_Return : Object
	$vo_Return:={vt_ValueName: "vt_ValueName"; vt_KeyName: "vt_KeyName"}
	$vo_Return.vc_Values:=[{vt_KeyName: "page"; vt_ValueName: BSPK_Translate("BSPK_labelPage"; 1)}; {vt_KeyName: "title"; vt_ValueName: BSPK_Translate("BSPK_labelTitle")}]
	
Function changeUrl($vo_POST : Object; $Entity : cs:C1710.BSPK_WEB_DOMAINEntity; $vo_Session : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $E : 4D:C1709.Entity
	var $vc_UrlDatabase : Collection
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	If (Position:C15("/bweb/"; "test"+$vo_POST.vt_Result)=0)
		$E:=This:C1470.get(vo_selectedItemData.vt_Id)
		$vc_UrlDatabase:=Split string:C1554($vo_POST.vt_Result; "/")
		$E.languageOptions[$vo_POST.vo_Line.name].url:=$vo_POST.vt_Result
		$E.languageOptions[$vo_POST.vo_Line.name].urlToSearch:=This:C1470.createUrlToSearch($vc_UrlDatabase)
		$E.urlParts:=($vc_UrlDatabase.length>1) ? $vc_UrlDatabase.length-1 : $vc_UrlDatabase.length
		$vo_POST.vo_Line.url:=$vo_POST.vt_Result
		$E.store()
		$vo_WebResponse.updateListboxRow($vo_POST; $vo_POST.triggerObject.uuid; $vo_POST.vo_Line; String:C10($vo_POST.triggerObject.vt_RowPk))
		$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: ""; vt_AlertMessage: BSPK_Translate("BSPK_succesEdit"); vt_AlertType: "success"; vl_AlertDuration: 3})
	Else 
		$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: BSPK_Translate("BSPK_error"); vt_AlertMessage: BSPK_Translate("BSPK_errorEditUrl"); vt_AlertType: "error"})
	End if 
	
	return $vo_WebResponse
	
Function editMetaDescriptions($vo_POST : Object; $Entity : cs:C1710.BSPK_WEB_DOMAINEntity; $vo_Session : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $vo_SelectedItem : Object
	var $WebDomainMenu : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity
	var $vc_Keys : Collection
	var $vt_LangFieldName; $vt_Lang : Text
	
	If ($vo_POST.vt_SelectedItem#Null:C1517)
		$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
		$vo_SelectedItem:=$vo_WebResponse.normalizeJsonStringifiedFromTpl($vo_POST.vt_SelectedItem)
		$WebDomainMenu:=This:C1470.get($vo_SelectedItem.vt_Id)
		
		$vc_Keys:=["description"; "title"]
		If ($vc_Keys.indexOf($vo_POST.vt_FieldName)>-1)
			
			$vt_LangFieldName:="lang_"+$vo_POST.vt_FieldName
			$vt_Lang:=$vo_POST[$vt_LangFieldName]
			If ($WebDomainMenu.metaTags=Null:C1517)
				$WebDomainMenu.metaTags:={}
			End if 
			$WebDomainMenu.metaTags[$vo_POST.vt_FieldName]:=JSON Parse:C1218($vo_POST.vt_FieldValue)
			$WebDomainMenu.store()
			
			$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: ""; vt_AlertMessage: BSPK_Translate("BSPK_succesEdit"); vt_AlertType: "success"; vl_AlertDuration: 3})
		End if 
	End if 
	
Function generateUrlListbox($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $vt_Lang; $vt_LangToGenerate; $vt_Line; $vt_AlertTitle; $vt_Lang; $vt_Id : Text
	var $WebDomainMenu; $WebDomainMenuParent : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity
	var $vo_ObjectTree; $vo_Line; $vo_LanguageOptions; $vo_Tree; $vo_UrlsParent; $vo_Options : Object
	var $WebDomainMenus : cs:C1710.BSPK_WEB_DOMAIN_MENUSelection
	var $WebDomain : cs:C1710.BSPK_WEB_DOMAINEntity
	var $WebDomainLang : cs:C1710.BSPK_WEB_DOMAIN_LANGEntity
	var $vb_Continue : Boolean
	
	$vb_Continue:=True:C214
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	$WebDomainMenu:=This:C1470.get(vo_SelectedItemData.vt_Id)
	$WebDomainMenus:=ds:C1482.BSPK_WEB_DOMAIN_MENU.newSelection()
	$WebDomainMenus.add($WebDomainMenu)
	$WebDomain:=$WebDomainMenu.WebDomain
	$vo_Options:={webDomain: $WebDomain; vc_Langs: []}
	
	If ($vo_POST.vt_Line#Null:C1517)
		BASE64 DECODE:C896($vo_POST.vt_Line; $vt_Line)
		$vo_Line:=JSON Parse:C1218($vt_Line)
		$vt_LangToGenerate:=$vo_Line.name
	End if 
	
	$vo_UrlsParent:={}
	$WebDomainMenuParent:=$WebDomainMenu.Parent
	If ($vt_LangToGenerate#"")
		$vb_Continue:=$WebDomainMenu.isUrlActive($vt_LangToGenerate)
		If ($vb_Continue)
			$vo_Options.vc_Langs.push($vt_LangToGenerate)
			$vo_UrlsParent[$vt_LangToGenerate]:=""
			If ($WebDomainMenuParent#Null:C1517)
				$vo_UrlsParent[$vt_LangToGenerate]+=$WebDomainMenuParent.languageOptions[$vt_LangToGenerate].url
			End if 
			$vo_ObjectTree:=($vo_POST.column=4) ? {vl_Depth: 0} : Null:C1517
			$vo_Tree:=$vo_WebResponse.getMenuTree($WebDomainMenus; 0; $vo_ObjectTree)
		End if 
	Else 
		For each ($WebDomainLang; $WebDomain.WebDomainLang)
			$vt_Lang:=$WebDomainLang.lang
			$vo_Options.vc_Langs.push($vt_Lang)
			$vo_UrlsParent[$vt_Lang]:=""
			If ($WebDomainMenuParent#Null:C1517)
				$vo_UrlsParent[$vt_Lang]+=$WebDomainMenuParent.languageOptions[$vt_Lang].url
			End if 
		End for each 
		$vo_Tree:=$vo_WebResponse.getMenuTree($WebDomainMenus; 0)
	End if 
	
	If ($vb_Continue)
		For each ($vt_Id; $vo_Tree)
			This:C1470.updateChildrenUrl($vo_POST; $vo_Tree[$vt_Id]; $vo_UrlsParent; $vo_Options)
		End for each 
		
		$vo_WebResponse.reloadBlock("641F2FBAD071C24F8B7D0C092E2ABCC9"; $vo_POST)
		$vt_AlertTitle:=BSPK_Translate("BSPK_urlModified")
		$vo_WebResponse.sendAlert("success"; $vt_AlertTitle)
	End if 
	
Function generateUrls($WebDomainMenu : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity; $vt_Lang : Text; $vo_UrlsParent : Object)
	var $vt_Url; $vt_UrlToSearch : Text
	var $vc_UrlDatabase : Collection
	var $WebDomainMenuParameter; $WebDomainMenuParameterNew; $PageParameter : cs:C1710.BSPK_WEB_DOMAIN_MENU_PARAMETEREntity
	var $WebDomainMenuParametersTmp; $PageParametersOptionnal : cs:C1710.BSPK_WEB_DOMAIN_MENU_PARAMETERSelection
	
	If ($WebDomainMenu.isHomepage#Null:C1517) && ($WebDomainMenu.isHomepage)
		$vt_Url:="/"
	Else 
		$vt_Url:=$vo_UrlsParent[$vt_Lang]+"/"
		If ($WebDomainMenu.useName=True:C214)
			$vt_Url:=$vt_Url+BSPK_String_To_URL(BSPK_Translate($WebDomainMenu.name; {vt_Lang: $vt_Lang; vb_ReturnOrignialStringIfEmpty: True:C214}))
		End if 
		
		//Pour url dynamique
		If ($WebDomainMenu.WebDomainMenuParameters.length>0)
			For each ($WebDomainMenuParameter; $WebDomainMenu.WebDomainMenuParameters.orderBy("sortOrder"))
				If (Position:C15("{"+$WebDomainMenuParameter.name+"}"; $vt_Url)=0)
					$vt_Url+="/{"+$WebDomainMenuParameter.name+"}"
				End if 
			End for each 
		End if 
		$vt_Url:=Replace string:C233($vt_Url; "//"; "/")
	End if 
	
	$vc_UrlDatabase:=Split string:C1554($vt_Url; "/")
	$WebDomainMenu.languageOptions[$vt_Lang].url:=$vt_Url
	$WebDomainMenu.languageOptions[$vt_Lang].urlToSearch:=This:C1470.createUrlToSearch($vc_UrlDatabase)
	$WebDomainMenu.urlParts:=($vc_UrlDatabase.length>1) ? $vc_UrlDatabase.length-1 : $vc_UrlDatabase.length
	
Function toogleActiveUrl($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $vt_Lang; $vt_Lang : Text
	var $WebDomainMenu : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity
	var $vo_Line : Object
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	$WebDomainMenu:=This:C1470.get(vo_SelectedItemData.vt_Id)
	$vo_Line:=Session:C1714.storage.vo_SelectInCurse[$vo_POST.vt_ListboxTmpUuid][Num:C11($vo_POST.triggerObject.vt_RowPk)]
	$vt_Lang:=$vo_Line.name
	$WebDomainMenu.languageOptions[$vt_Lang].active:=Not:C34($WebDomainMenu.isUrlActive($vt_Lang))
	$WebDomainMenu.store()
	$vo_WebResponse.reloadBlock("641F2FBAD071C24F8B7D0C092E2ABCC9"; $vo_POST)
	$vo_WebResponse.sendAlert("success"; BSPK_Translate("BSPK_urlModified"; True:C214))
	
Function updateChildrenUrl($vo_POST : Object; $vo_Tree : Object; $vo_UrlsParent : Object; $vo_Options : Object)
	var $vt_NewUrl; $vt_UrlPart; $vt_Lang; $vt_ChildTree : Text
	var $vo_UrlInfos : Object
	var $vb_autoUpdate : Boolean
	
	//Créer la nouvelle URL
	For each ($vt_Lang; $vo_Options.vc_Langs)
		$vb_autoUpdate:=(($vo_Tree.entity.autoUpdate#Null:C1517) && ($vo_Tree.entity.autoUpdate))
		If ($vb_autoUpdate) && (($vo_Tree.entity.isUrlActive($vt_Lang) || ($vo_Tree.entity.category="title")))
			This:C1470.generateUrls($vo_Tree.entity; $vt_Lang; $vo_UrlsParent)
		End if 
		
		$vo_UrlsParent[$vt_Lang]:=$vo_Tree.entity.languageOptions[$vt_Lang].url
		If ($vo_Tree.vo_Children#Null:C1517) && ((($vo_POST.vb_Answer#Null:C1517) && ($vo_POST.vb_Answer)) || (($vo_POST.column#Null:C1517) && ($vo_POST.column=6)))
			For each ($vt_ChildTree; $vo_Tree.vo_Children)
				This:C1470.updateChildrenUrl($vo_POST; $vo_Tree.vo_Children[$vt_ChildTree]; OB Copy:C1225($vo_UrlsParent); $vo_Options)
			End for each 
		End if 
	End for each 
	
	If ($vb_autoUpdate)
		$vo_Tree.entity.store()
	End if 
	
Function savePropertyAndReloadMenu($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
/* parameters
vt_BlocName:select:getBlocsNameCollection:mandatory
*/
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	$vo_WebResponse.save($vo_POST)
	$vo_POST.webDomainUuid:=$vo_POST.pk
	$vo_WebResponse.updateMenu($vo_POST)
	
Function createUrlToSearch($vc_UrlDatabase : Collection) : Text
	var $vl_Index : Integer
	var $vt_UrlPart : Text
	
	$vl_Index:=0
	For each ($vt_UrlPart; $vc_UrlDatabase)
		If (Position:C15("{"; "test"+$vt_UrlPart)>0)
			$vc_UrlDatabase[$vl_Index]:="@"
		End if 
		$vl_Index+=1
	End for each 
	
	return $vc_UrlDatabase.join("/")
	
Function getUrl($WebDomainMenu : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity; $vt_Lang : Text; $vo_Parameters : Object; $vb_WithDomain : Boolean) : Text
	var $vt_Url; $vt_FinalUrl; $vt_TmpUrl; $vt_urlPart; $vt_ParameterName : Text
	var $vl_Index : Integer
	var $vc_Url : Collection
	
	If ($vo_Parameters#Null:C1517) && (OB Is empty:C1297($vo_Parameters)=False:C215)
		$vt_TmpUrl:=$WebDomainMenu.languageOptions[$vt_Lang].url
		$vc_Url:=Split string:C1554($vt_TmpUrl; "/")
		If ($vc_Url.length>0)
			$vl_Index:=0
			For each ($vt_urlPart; $vc_Url)
				If (This:C1470.isParameter($vt_urlPart))
					$vt_ParameterName:=This:C1470.getParameter($vt_urlPart)
					If ($vo_Parameters[$vt_ParameterName]#Null:C1517)
						$vc_Url[$vl_Index]:=$vo_Parameters[$vt_ParameterName]
					End if 
				End if 
				$vl_Index+=1
			End for each 
		End if 
		$vt_FinalUrl:=$vc_Url.join("/")
	Else 
		$vt_FinalUrl:=$WebDomainMenu.languageOptions[$vt_Lang].url
	End if 
	
	If ($vt_FinalUrl#"") && (Storage:C1525.vo_SharedStorage.vc_Langs.length>1) && ($vt_Lang#$WebDomainMenu.WebDomain.defaultLang)
		$vt_FinalUrl:="/"+$vt_Lang+$vt_FinalUrl
	End if 
	If ($vb_WithDomain)
		$vt_FinalUrl:="https://"+$WebDomainMenu.WebDomain.name+$vt_FinalUrl
	End if 
	
	return $vt_FinalUrl
	
Function getUrlFromuUuid($vt_UuidKey : Text; $vt_Lang : Text; $vt_Parameters : Text) : Text
	var $Page : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity
	var $vo_Parameters : Object
	var $vt_ParametersDecoded : Text
	
	$Page:=This:C1470.get($vt_UuidKey)
	If ($vt_Parameters#"")
		BASE64 DECODE:C896($vt_Parameters; $vt_ParametersDecoded)
		$vo_Parameters:=JSON Parse:C1218($vt_ParametersDecoded)
	Else 
		$vo_Parameters:={}
	End if 
	return This:C1470.getUrl($Page; $vt_Lang; $vo_Parameters)
	
Function getParametersFromUrl($WebDomainMenu : cs:C1710.BSPK_WEB_DOMAIN_MENUEntity; $vt_Lang : Text; $vt_Url : Text) : Object
	var $vo_Parameters : Object
	var $vc_Url; $vc_UrlDatabase : Collection
	var $vl_Indice : Integer
	var $vt_UrlPart : Text
	
	$vo_Parameters:={}
	$vc_Url:=Split string:C1554($vt_Url; "/")
	If ($vc_Url.length>0)
		$vc_UrlDatabase:=Split string:C1554($WebDomainMenu.languageOptions[$vt_Lang].url; "/")
		$vl_Indice:=0
		For each ($vt_UrlPart; $vc_UrlDatabase)
			If (This:C1470.isParameter($vt_UrlPart))
				$vo_Parameters[This:C1470.getParameter($vt_UrlPart)]:=$vc_Url[$vl_Indice]
			End if 
			$vl_Indice+=1
		End for each 
	End if 
	
	return $vo_Parameters
	
Function isParameter($vt_String : Text) : Boolean
	return (Position:C15("{"; "test"+$vt_String)>0)
	
Function getParameter($vt_String : Text) : Text
	return Replace string:C233(Replace string:C233($vt_String; "{"; ""); "}"; "")
	
Function getParameters($vt_Url) : Collection
	var $vc_Url; $vc_Results : Collection
	var $vt_UrlPart : Text
	
	$vc_Results:=[]
	$vc_Url:=Split string:C1554($vt_Url; "/")
	If ($vc_Url.length>0)
		For each ($vt_UrlPart; $vc_Url)
			If (This:C1470.isParameter($vt_UrlPart))
				$vc_Results.push(This:C1470.getParameter($vt_UrlPart))
			End if 
		End for each 
	End if 
	
	return $vc_Results
	
/********* YOUR CODE AFTER THIS ********/