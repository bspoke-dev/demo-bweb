//%attributes = {"shared":true,"preemptive":"incapable"}
//BSPH_VERSION_UPDATES
// Gestion du n° de version et des updates de données
// Les méthodes Updates doivent être nommées UTIL_UPDATE_X_X_X et retourner vrai en cas d'erreur ou faux si pas de problème
// En cas d'erreur une assertion est déclenchée ce qui évite de devoir gérer les erreurs dans les méthodes UPDATE
var $vc_Updates : Collection
var $vl_4DVersion; $vl_DeliveryVersion; $vl_InternalVersion : Integer

/************ NUMEROTATION VERSION COURANTE **************/

$vl_4DVersion:=20
$vl_DeliveryVersion:=1
$vl_InternalVersion:=0
// last UPDATE 2024-06-24

/************ DEFINITION DES UPDATES **************/

$vc_Updates:=New collection:C1472

// exemple d'appel d'update Method : UTIL_UPDATE_20_2_0
//$vc_Updates.push("20.2.0")  //15/11/2024

//Ajouter à la suite les versions nécessitant un update avec date et éventuellement commentaire


BSPK_DATA_UPDATE("HOTE"; $vl_4DVersion; $vl_DeliveryVersion; $vl_InternalVersion; $vc_Updates)
