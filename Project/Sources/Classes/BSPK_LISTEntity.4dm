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
	
	
local Function delete($vt_GroupUuid : Text)->$vo_Status : Object
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
	
/*** END BSPKENTITY ***/
	
Function updateSortOrder($vl_Pos : Integer)
	var $vl_CurrentPos : Integer
	var $Lists : cs:C1710.BSPK_LISTSelection
	var $List : cs:C1710.BSPK_LISTEntity
	
	$vl_CurrentPos:=1
	
	$Lists:=ds:C1482.BSPK_LIST.query("reference = :1 AND uuidKey # :2"; This:C1470.reference; This:C1470.uuidKey).orderBy("sortOrder asc")
	For each ($List; $Lists)
		// Saute la valeur voulu pour notre List
		If ($vl_CurrentPos=$vl_Pos)
			$vl_CurrentPos+=1
		End if 
		$List.sortOrder:=$vl_CurrentPos
		$List.store()
		
		$vl_CurrentPos+=1
	End for each 
	// Verif si Position voulu supérieur à la position max
	If ($vl_Pos>$vl_CurrentPos)
		$vl_Pos:=$vl_CurrentPos
	End if 
	This:C1470.sortOrder:=$vl_Pos
	This:C1470.store()
	
Function makeCollectionListDiff($vt_Lang : Text)->$vc_Collection : Collection
	var $vo_List : Object
	var $vt_Value : Text
	
	If ($vt_Lang="")
		$vt_Lang:="fr"
	End if 
	
	$vc_Collection:=ds:C1482.BSPK_LIST.query("reference = :1 AND uuidKey # :2"; This:C1470.reference; This:C1470.uuidKey).orderBy("sortOrder asc, value asc").toCollection("uuidKey,value,langValue,sortOrder")
	For each ($vo_List; $vc_Collection)
		// Recup valeur de la langue
		$vt_Value:=""
		If ($vo_List.langValue#Null:C1517) && ($vo_List.langValue[$vt_Lang]#Null:C1517)
			$vt_Value:=$vo_List.langValue[$vt_Lang]
		End if 
		$vo_List.currentLangValue:=$vt_Value
	End for each 
	
Function updateFieldsValue($vt_OldValue : Text; $vt_Lang : Text)->$vo_Return : Object
	var $ParamList : cs:C1710.BSPK_PARAM_LISTEntity
	var $vt_Value : Text
	var $vo_Link; $EntityToUpdate; $SelectionToUpdate : Object
	
	$vo_Return:=New object:C1471
	$vo_Return.vl_NumberUpdate:=0
	
	$ParamList:=ds:C1482.BSPK_PARAM_LIST.getFromReference(This:C1470.reference)
	
	// Vérification prérequis
	If ($ParamList#Null:C1517) && ($ParamList.isOpen) && ($vt_OldValue#"") && ($ParamList.linkedFields#Null:C1517) && ($ParamList.linkedFields.vc_Links#Null:C1517)
		If ($vt_Lang="")
			$vt_Lang:="fr"
		End if 
		
		// Recup valeur de la langue
		$vt_Value:=""
		If (This:C1470.langValue#Null:C1517) && (This:C1470.langValue[$vt_Lang]#Null:C1517)
			$vt_Value:=This:C1470.langValue[$vt_Lang]
		End if 
		
		// Si non vide et changement valeur
		If ($vt_Value#"") && ($vt_Value#$vt_OldValue)
			// Pour chaque champ à mettre à jour
			For each ($vo_Link; $ParamList.linkedFields.vc_Links)
				// Vérif présence Table et Champ et table existante
				If ($vo_Link.Table#Null:C1517) && ($vo_Link.Field) && (ds:C1482[$vo_Link.Table]#Null:C1517)
					// Recup selection des valeurs à modifier
					$SelectionToUpdate:=ds:C1482[$vo_Link.Table].query(":1 = :2"; $vo_Link.Field; $vt_OldValue)
					If ($SelectionToUpdate#Null:C1517) && ($SelectionToUpdate.length>0)
						// Pour chaque Entité avec l'ancienne valeur
						For each ($EntityToUpdate; $SelectionToUpdate)
							$EntityToUpdate[$vo_Link.Field]:=$vt_Value
							$EntityToUpdate.store()
							$vo_Return.vl_NumberUpdate+=1
						End for each 
					End if 
				End if 
			End for each 
		End if 
	End if 