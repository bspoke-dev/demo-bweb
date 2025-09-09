Class extends EntitySelection
/*** START BSPKSELECTION ***/
local Function delete($vt_GroupUuid : Text)->$vo_Status : Object
	var $vo_Return : Object
	var $UDC : cs:C1710.bspkComponent.GG_DATACLASS
	$UDC:=cs:C1710.bspkComponent.GG_DATACLASS.new()
	If (Count parameters:C259>0)
		$vo_Status:=$UDC.deleteSelection(This:C1470; $vt_GroupUuid)
	Else 
		$vo_Status:=$UDC.deleteSelection(This:C1470)
	End if 
	
/*** END BSPKSELECTION ***/
	
Function makeCollection($vt_Reference : Text; $vt_Lang : Text)->$vc_Collection : Collection
	var $vo_List : Object
	var $vt_Value; $vt_Order : Text
	var $ParamList : cs:C1710.BSPK_PARAM_LISTEntity
	var $vb_OrderAlpha : Boolean
	
	If ($vt_Lang="")
		$vt_Lang:="fr"
	End if 
	
	If ($vt_Reference="") && (This:C1470.length>0)
		$vt_Reference:=This:C1470.first().reference
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
	
	$vc_Collection:=This:C1470.query("reference = :1"; $vt_Reference).orderBy($vt_Order).toCollection("uuidKey,value,langValue,sortOrder,masterListUuid")
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
	
Function makeCollectionListDiff($vt_Lang : Text)->$vc_Collection : Collection
	var $vo_List : Object
	var $vt_Value; $vt_Reference : Text
	var $vc_UuidKey : Collection
	
	If ($vt_Lang="")
		$vt_Lang:="fr"
	End if 
	
	$vt_Reference:=This:C1470.first().reference
	$vc_UuidKey:=This:C1470.distinct("uuidKey")
	
	$vc_Collection:=ds:C1482.BSPK_LIST.query("reference = :1 AND Not(uuidKey IN :2)"; $vt_Reference; $vc_UuidKey).orderBy("sortOrder asc, value asc").toCollection("uuidKey,value,langValue,sortOrder")
	For each ($vo_List; $vc_Collection)
		// Recup valeur de la langue
		$vt_Value:=""
		If ($vo_List.langValue#Null:C1517) && ($vo_List.langValue[$vt_Lang]#Null:C1517)
			$vt_Value:=$vo_List.langValue[$vt_Lang]
		End if 
		$vo_List.currentLangValue:=$vt_Value
	End for each 