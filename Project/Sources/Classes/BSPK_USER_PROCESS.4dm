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
	
Function purge
	This:C1470.all().drop()
	
Function removeMine($vt_registerClientName : Text; $vl_Process : Integer; $vl_Window : Integer)
	var $Entity : Object
	var $vo_Param : Object
	
	$Entity:=This:C1470.retrieve($vt_registerClientName; $vl_Process; $vl_Window)
	$vo_Param:=New object:C1471
	$vo_Param.process:=$vl_Process
	$vo_Param.window:=$vl_Window
	$vo_Param.action:="updateViewers"
	If ($Entity.info.primaryKey#Null:C1517)
		$vo_Param.primaryKey:=$Entity.info.primaryKey
	End if 
	$Entity.drop()
	
	If ($vo_Param.primaryKey#Null:C1517)
		CALL WORKER:C1389("USERS_PROCESS_W"; "USERS_PROCESS_W"; $vo_Param)
	End if 
	
Function retrieve($vt_registerClientName : Text; $vl_Process : Integer; $vl_Window : Integer)->$Entity : cs:C1710.BSPK_USER_PROCESSEntity
	var $Selection : cs:C1710.BSPK_USER_PROCESSSelection
	$Selection:=This:C1470.query("registerClientName = :1 AND process = :2 AND window = :3"; $vt_registerClientName; $vl_Process; $vl_Window)
	Case of 
		: ($Selection.length=0)
			
			$Entity:=This:C1470.new()
			$Entity.process:=$vl_Process
			$Entity.window:=$vl_Window
			$Entity.registerClientName:=$vt_registerClientName
			$Entity.info:=New object:C1471
			$Entity.save()
			
		: ($Selection.length=1)
			$Entity:=$Selection.first()
			
		Else 
			$Entity:=$Selection.first()
			$Selection:=$Selection.minus($Entity)
			$Selection.drop()
			
	End case 
	
Function updateInfo($vt_registerClientName : Text; $vl_Process : Integer; $vl_Window : Integer; $vo_Info : Object)
	
	var $Entity : cs:C1710.BSPK_USER_PROCESSEntity
	var $Selection : cs:C1710.BSPK_USER_PROCESSSelection
	var $vo_Param : Object
	
	$Entity:=This:C1470.retrieve($vt_registerClientName; $vl_Process; $vl_Window)
	$Entity.info:=$vo_Info
	$Entity.save()
	$vo_Param:=New object:C1471("vt_UserProcessUuid"; $Entity.uuidKey)
	If ($vo_Info.action#Null:C1517)
		$vo_Param.action:=$vo_Info.action
	End if 
	CALL WORKER:C1389("USERS_PROCESS_W"; "USERS_PROCESS_W"; $vo_Param)
	
Function quit($vt_registerClientName : Text)
	var $UserProcess : cs:C1710.BSPK_USER_PROCESSEntity
	var $UserProcesses : cs:C1710.BSPK_USER_PROCESSSelection
	
	$UserProcesses:=This:C1470.query("registerClientName = :1"; $vt_registerClientName)
	For each ($UserProcess; $UserProcesses)
		CALL WORKER:C1389("USERS_PROCESS_W"; "USERS_PROCESS_W"; New object:C1471("action"; "closeWindow"; "vt_UserProcessUuid"; $UserProcess.uuidKey))
	End for each 
	
/********* YOUR CODE AFTER THIS ********/