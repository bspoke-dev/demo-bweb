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
	
Function addFile($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $vx_Blob : Blob
	var $vo_Values; $vo_OtherData; $vo_InfoImage : Object
	var $vt_FileName; $vt_ErrorMessage; $vt_ErrorTitle; $vt_Value : Text
	var $Entity : 4D:C1709.Entity
	var $vc_fileNameSplit : Collection
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	If ($vo_POST.vt_FieldValue=Null:C1517) || ($vo_POST.vt_FieldValue="")
		$vo_WebResponse.sendAlert("error"; "BSPK_errorImportFile")
		return 
	End if 
	
	$vo_Values:=JSON Parse:C1218($vo_POST.vt_FieldValue)
	For each ($vt_FileName; $vo_Values)
		$Entity:=This:C1470.new()
		$vt_Value:=$vo_Values[$vt_FileName]
		$vt_Value:=Substring:C12($vt_Value; Position:C15("base64,"; $vt_Value)+7)
		BASE64 DECODE:C896($vt_Value; $vx_Blob)
		
		$vo_OtherData:=JSON Parse:C1218($vo_POST.vo_Param.vt_OtherData)
		$vc_fileNameSplit:=Split string:C1554($vt_FileName; ".")
		If ($vc_fileNameSplit.length>1)
			$Entity.docType:=$vc_fileNameSplit.pop()
		End if 
		If ($Entity.docType#Null:C1517) && ((Storage:C1525.vo_SharedStorage.vo_Doctypes.vc_DocumentType.indexOf($Entity.docType)>-1) | (Storage:C1525.vo_SharedStorage.vo_Doctypes.vc_ImageType.indexOf($Entity.docType)>-1))
			$Entity.title:=$vc_fileNameSplit.join(".")
			$Entity.folderPath:=$vo_OtherData.folderPath
			$Entity.originalBlob:=$vx_Blob
			$Entity.realSize:=BLOB size:C605($vx_Blob)
			
			If (Storage:C1525.vo_SharedStorage.vo_Doctypes.vc_ImageType.indexOf($Entity.docType)>-1) || ($Entity.docType="pdf")
				$vo_InfoImage:=BSPK_GetThumbnail($vx_Blob; $Entity.docType)
				$Entity.thumbnail:=$vo_InfoImage.vx_thumbnail
				If ($Entity.docType#"pdf")
					$Entity.originalSizeFormat:=String:C10($vo_InfoImage.vl_Width)+"x"+String:C10($vo_InfoImage.vl_Height)+"px"
				End if 
			End if 
		Else 
			$vt_ErrorTitle:=BSPK_Translate("BSPK_error")
			$vt_ErrorMessage:=BSPK_Translate("BSPK_erroFileTypeNotAllowed")
			This:C1470.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: $vt_ErrorTitle; vt_AlertMessage: $vt_ErrorMessage; vt_AlertType: "error"})
			return This:C1470
		End if 
		$Entity.store()
	End for each 
	
	
	$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: ""; vt_AlertMessage: BSPK_Translate("BSPK_succesAddingFile"); vt_AlertType: "success"; vl_AlertDuration: 3})
	$vo_WebResponse.getFiles({folderPath: $Entity.folderPath})
	
	
Function removeFile($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $Entity : 4D:C1709.Entity
	var $vt_FolderPath : Text
	var $Entity : 4D:C1709.Entity
	
	$Entity:=This:C1470.get($vo_POST.vo_Param.vt_pk)
	$Entity.drop()
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: ""; vt_AlertMessage: BSPK_Translate("BSPK_succesRemoveFile"); vt_AlertType: "success"; vl_AlertDuration: 3})
	$vo_WebResponse.getFileDetails({})
	
Function removeFiles($vo_POST : Object)->$vo_WebResponse : cs:C1710.bspkComponent.WebFormController
	var $Entity : 4D:C1709.Entity
	var $vt_FolderPath; $vt_FileUuid : Text
	var $Entity : 4D:C1709.Entity
	
	$vo_WebResponse:=cs:C1710.bspkComponent.WebFormController.new()
	For each ($vt_FileUuid; $vo_POST.vt_FieldValue.vc_FilesToRemove)
		$Entity:=This:C1470.get($vt_FileUuid)
		$Entity.drop()
		$vo_WebResponse.vc_Action.push({vt_Action: "replaceHtml"; vt_Html: ""; vt_Selector: "[data-uuid="+$vt_FileUuid+"]"})
	End for each 
	
	
	$vo_WebResponse.vc_Action.push({vt_Action: "openAlert"; vt_AlertTitle: ""; vt_AlertMessage: BSPK_Translate("BSPK_successRemoveManyFiles"; $vo_POST.vt_FieldValue.vc_FilesToRemove.length; String:C10($vo_POST.vt_FieldValue.vc_FilesToRemove.length)); vt_AlertType: "success"; vl_AlertDuration: 3})
	$vo_WebResponse.getFileDetails({})
	
/********* YOUR CODE AFTER THIS ********/