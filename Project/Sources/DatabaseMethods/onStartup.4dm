
//BSPK_CONFIRM_STARTUP_MODE

BSPK_STARTUP

//BSPK_LOGIN_ON_STARTUP

cs:C1710.bspkComponent.ToolBar_FC.new().start()

Use (Storage:C1525)
	var $vo_storage : Object
	$vo_storage:=BSPK_Storage
	Storage:C1525.vo_Param:=OB Copy:C1225($vo_storage.vo_Param; ck shared:K85:29)
	Storage:C1525.vo_SharedStorage:=OB Copy:C1225($vo_storage.vo_SharedStorage; ck shared:K85:29)
End use 

//cs.bspkComponent.ToolBar_FC.new().start()
