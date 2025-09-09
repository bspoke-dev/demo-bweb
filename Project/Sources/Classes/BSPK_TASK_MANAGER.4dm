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
	
Function start()
	var $vl_Process : Integer
	$vl_Process:=New process:C317("BSPK_TASK_MANAGER"; 0; "BSPK_TASK_MANAGER"; *)
	
Function fetchExecuteOnServer()->$Selection : cs:C1710.BSPK_TASK_MANAGERSelection
	$Selection:=This:C1470.query("actif = :1 AND executeOnStartup = :1"; True:C214)
	
Function fetchActif()->$Selection : cs:C1710.BSPK_TASK_MANAGERSelection
	If (Storage:C1525.vo_Param.vt_applicationMode="DEV")
		$Selection:=This:C1470.query("actif = :1 and executeOnDev = :1"; True:C214)
	Else 
		$Selection:=This:C1470.query("actif = :1"; True:C214)
	End if 
	
Function updateFromProcess($vl_CurrentProcess : Integer; $vb_LastExecutionStatus : Boolean)
	var $TaskManagers : cs:C1710.BSPK_TASK_MANAGERSelection
	var $TaskManager : cs:C1710.BSPK_TASK_MANAGEREntity
	_O_PROCESS PROPERTIES:C336($vl_CurrentProcess; $vt_procName; $vl_procStatut; $vl_procTemps; $vl_procMode; $vl_uniqueID; $vl_origine)
	If ($vl_origine=Worker process:K36:32)
		$TaskManagers:=This:C1470.query("name = :1"; $vt_procName)
		If ($TaskManagers.length>0)
			$TaskManager:=$TaskManagers.first()
			$TaskManager.lastExecutionStatus:=$vb_LastExecutionStatus
			$TaskManager.save()
		End if 
	End if 
	
/********* YOUR CODE AFTER THIS ********/