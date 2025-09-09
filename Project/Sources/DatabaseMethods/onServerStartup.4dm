
//BSPK_CONFIRM_STARTUP_MODE

BSPK_STARTUP

//BSPK_LOGIN_ON_STARTUP

//cs.bspkComponent.ToolBar_FC.new().start()

Use (Storage)
var $vo_storage : Object
$vo_storage:=BSPK_Storage
Storage.vo_Param:=OB Copy($vo_storage.vo_Param; ck shared)
Storage.vo_SharedStorage:=OB Copy($vo_storage.vo_SharedStorage; ck shared)
End use 
