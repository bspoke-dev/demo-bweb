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
	
Function getListItemByValue($vt_Value : Text) : cs:C1710.BSPK_LISTSelection
	return ds:C1482.BSPK_LIST.query("value = :1"; $vt_Value)
	
Function getInitLangValueObject()->$vo_NewObject : Object
	var $vt_Lang : Text
	$vo_NewObject:={}
	For each ($vt_Lang; E_WebDomain.getLangs())
		$vo_NewObject[$vt_Lang]:=""
	End for each 
	
Function getListItemByValueAndRef($vt_Value : Text; $vt_Ref : Text) : cs:C1710.BSPK_LISTEntity
	var $BspkLists : cs:C1710.BSPK_LISTSelection
	$BspkLists:=ds:C1482.BSPK_LIST.query("value = :1 AND reference = :2"; $vt_Value; $vt_Ref)
	return ($BspkLists.length>0) ? $BspkLists.first() : Null:C1517
	
Function getListItemByLangValueAndRef($vt_Value : Text; $vt_Ref : Text; $vt_Lang : Text) : cs:C1710.BSPK_LISTEntity
	var $BspkLists : cs:C1710.BSPK_LISTSelection
	$BspkLists:=ds:C1482.BSPK_LIST.query("langValue."+$vt_Lang+" = :1 AND reference = :2"; $vt_Value; $vt_Ref)
	return ($BspkLists.length>0) ? $BspkLists.first() : Null:C1517
	
Function getLangValueCollection($vt_Value : Text; $vt_Type : Text) : Collection
	var $ListItems : cs:C1710.BSPK_LISTSelection
	var $vt_Lang : Text
	var $vc_LangValues : Collection
	var $vo_NewObject : Object
	
	$vc_LangValues:=[]
	If ($vt_Type#"") && ($vt_Type="id")
		$ListItems:=ds:C1482.BSPK_LIST.newSelection()
		$ListItems:=$ListItems.add(ds:C1482.BSPK_LIST.get($vt_Value))
	Else 
		$ListItems:=This:C1470.getListItemByValue($vt_Value)
	End if 
	
	If ($ListItems.length>0)
		For each ($vt_Lang; E_WebDomain.getLangs())
			$vo_NewObject:={}
			$vo_NewObject.lang:=$vt_Lang
			If ($ListItems[0].langValue#Null:C1517) && ($ListItems[0].langValue[$vt_Lang]#Null:C1517)
				$vo_NewObject.value:=$ListItems[0].langValue[$vt_Lang]
			Else 
				$vo_NewObject.value:=""
			End if 
			$vc_LangValues.push($vo_NewObject)
		End for each 
	End if 
	
	return $vc_LangValues
	
Function getCollectionWF($vo_POST : Object)->$vo_Return : Object
/* parameters
vt_Reference:text:mandatory
vt_Lang:hidden:session.storage.vo_UserInfo.lang:WEB_vt_Iso_Code
*/
	$vo_Return:={vt_ValueName: "value"; vt_KeyName: "uuidKey"}
	Case of 
		: ($vo_POST.vt_Reference=Null:C1517)
		: ($vo_POST.vt_Lang=Null:C1517)
		Else 
			$vo_Return.vc_Values:=This:C1470.getLangCollection($vo_POST.vt_Reference; ($vo_POST.vt_Lang#"") ? $vo_POST.vt_Lang : WEB_vt_Iso_Code)
	End case 
	
Function getCollection($vt_Reference : Text)->$vc_Collection : Collection
	$vc_Collection:=ds:C1482.BSPK_LIST.query("reference = :1"; $vt_Reference).orderBy("sortOrder asc, value asc").toCollection("uuidKey,value,sortOrder")
	
Function addToCollection($vt_Ref : Text; $vt_value : Text)->$ListItem : Object
	$ListItem:=This:C1470.new()
	$ListItem.reference:=$vt_Ref
	$ListItem.value:=$vt_value
	//@TODO voir pour géré les tries et les masterUuid si besoin
	$ListItem.store()
	
Function getLangCollection($vt_Reference : Text; $vt_Lang : Text)->$vc_Collection : Collection
	var $vo_Item : Object
	$vc_Collection:=This:C1470.query("reference = :1"; $vt_Reference).orderBy("sortOrder asc, value asc").toCollection("uuidKey,value,langValue,sortOrder")
	For each ($vo_Item; $vc_Collection)
		If ($vo_Item.langValue#Null:C1517) && ($vt_Lang#"") && ($vo_Item.langValue[$vt_Lang]#Null:C1517)
			$vo_Item.value:=$vo_Item.langValue[$vt_Lang]
		End if 
	End for each 
	$vc_Collection:=$vc_Collection.orderBy("value asc")
	
Function getValue($vt_Reference : Text)->$vt_Value : Text
	var $vc_Lists : Collection
	$vc_Lists:=ds:C1482.BSPK_LIST.getCollection($vt_Reference)
	
	$vt_Value:=""
	If ($vc_Lists.length>0)
		$vt_Value:=$vc_Lists[0].value
	End if 
	
Function setValue($vt_Reference : Text; $vt_Value : Text; $vt_Lang : Text)
	var $Lists : cs:C1710.BSPK_LISTSelection
	var $List : cs:C1710.BSPK_LISTEntity
	
	$Lists:=ds:C1482.BSPK_LIST.query("reference = :1"; $vt_Reference)
	If ($Lists.length>0)
		For each ($List; $Lists)
			If ($vt_Lang#"")
				If ($List.langValue=Null:C1517)
					$List.langValue:=New object:C1471
				End if 
				$List.langValue[$vt_Lang]:=$vt_Value
			Else 
				$List.value:=$vt_Value
			End if 
			$List.store()
		End for each 
	End if 
	
Function getAllTablesWF($vo_POST : Object)->$vo_Return : Object
	var $vt_TableName : Text
	
	$vo_Return:={vt_ValueName: "value"; vt_KeyName: "key"}
	$vo_Return.vc_Values:=New collection:C1472
	For each ($vt_TableName; ds:C1482)
		$vo_Return.vc_Values.push({key: $vt_TableName; value: $vt_TableName})
	End for each 
	
Function makeCollectionList($vt_Reference : Text; $vt_Lang : Text)->$vc_Collection : Collection
	var $vo_List : Object
	var $vt_Value; $vt_Order : Text
	var $ParamList : cs:C1710.BSPK_PARAM_LISTEntity
	var $vb_OrderAlpha : Boolean
	
	If ($vt_Lang="")
		$vt_Lang:="fr"
	End if 
	
	$ParamList:=ds:C1482.BSPK_PARAM_LIST.getFromReference($vt_Reference)
	$vb_OrderAlpha:=False:C215
	If ($ParamList#Null:C1517)
		$vb_OrderAlpha:=$ParamList.isOrderAlpha
	End if 
	// Order à utiliser
	If ($vb_OrderAlpha)
		$vt_Order:="langValue."+$vt_Lang+" asc"
	Else 
		$vt_Order:="sortOrder asc"
	End if 
	
	$vc_Collection:=ds:C1482.BSPK_LIST.query("reference = :1"; $vt_Reference).orderBy($vt_Order).toCollection("uuidKey,value,langValue,sortOrder,masterListUuid")
	For each ($vo_List; $vc_Collection)
		// Recup valeur de la langue
		$vt_Value:=""
		If ($vo_List.langValue=Null:C1517)
			$vo_List.langValue:=New object:C1471
		End if 
		If ($vo_List.langValue[$vt_Lang]#Null:C1517)
			$vt_Value:=$vo_List.langValue[$vt_Lang]
		End if 
		$vo_List.currentLangValue:=$vt_Value
	End for each 
	
Function retrieveUuid($vt_Reference : Text; $vt_Value : Text) : Variant
	var $Lists : cs:C1710.BSPK_LISTSelection
	
	$Lists:=ds:C1482.BSPK_LIST.query("reference = :1 AND value = :2"; $vt_Reference; $vt_Value)
	If ($Lists.length>0)
		return $Lists.first().uuidKey
	End if 
	
/********* YOUR CODE AFTER THIS ********/
	