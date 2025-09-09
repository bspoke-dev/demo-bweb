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
	
Function getFromReference($vt_Reference)->$ParamList : cs:C1710.BSPK_PARAM_LISTEntity
	var $ParamLists : cs:C1710.BSPK_PARAM_LISTSelection
	
	$ParamLists:=ds:C1482.BSPK_PARAM_LIST.query("referenceList = :1"; $vt_Reference)
	If ($ParamLists.length>0)
		$ParamList:=$ParamLists.first()
	End if 
	
Function makeCollectionParamList($vt_Lang)->$vc_Collection : Collection
	var $vo_ParamList : Object
	var $vt_Description; $vt_Designation : Text
	
	If ($vt_Lang=Null:C1517) || ($vt_Lang="")
		$vt_Lang:="fr"
	End if 
	
	$vc_Collection:=ds:C1482.BSPK_PARAM_LIST.all().toCollection("uuidKey, referenceList, langDescription, langDesignation, isOpen, isOrderAlpha").orderBy("designation asc")
	For each ($vo_ParamList; $vc_Collection)
		// Description
		$vt_Description:=""
		If ($vo_ParamList.langDescription#Null:C1517) && ($vo_ParamList.langDescription[$vt_Lang]#Null:C1517)
			$vt_Description:=$vo_ParamList.langDescription[$vt_Lang]
		End if 
		$vo_ParamList.description:=$vt_Description
		// Designation
		$vt_Designation:=""
		If ($vo_ParamList.langDesignation#Null:C1517) && ($vo_ParamList.langDesignation[$vt_Lang]#Null:C1517)
			$vt_Designation:=$vo_ParamList.langDesignation[$vt_Lang]
		End if 
		$vo_ParamList.designation:=$vt_Designation
	End for each 
	
Function resetSortOrder($vt_Reference : Text)
	var $Lists : cs:C1710.BSPK_LISTSelection
	var $List : cs:C1710.BSPK_LISTEntity
	var $vl_CurrentPos : Integer
	
	$vl_CurrentPos:=1
	
	$Lists:=ds:C1482.BSPK_LIST.query("reference = :1"; $vt_Reference).orderBy("sortOrder asc")
	For each ($List; $Lists)
		$List.sortOrder:=$vl_CurrentPos
		$List.save()
		
		$vl_CurrentPos+=1
	End for each 