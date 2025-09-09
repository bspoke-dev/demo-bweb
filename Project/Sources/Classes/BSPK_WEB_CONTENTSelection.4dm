Class extends EntitySelection
/*** START BSPKSELECTION ***/
local Function deleteBspk($vt_GroupUuid : Text)->$vo_Status : Object
	var $vo_Return : Object
	var $UDC : cs:C1710.bspkComponent.GG_DATACLASS
	$UDC:=cs:C1710.bspkComponent.GG_DATACLASS.new()
	If (Count parameters:C259>0)
		$vo_Status:=$UDC.deleteSelection(This:C1470; $vt_GroupUuid)
	Else 
		$vo_Status:=$UDC.deleteSelection(This:C1470)
	End if 
	
/*** /!\ function bspk delete renomé en deleteBspk /!\ ***/
/*** END BSPKSELECTION ***/
	
local Function delete($vt_GroupUuid : Text)->$vo_Status : Object
	BSPK_UPDATE_CSS_FILE_TW("remove"; This:C1470)
	$vo_Status:=This:C1470.deleteBspk($vt_GroupUuid)
	
/********* YOUR CODE AFTER THIS ********/