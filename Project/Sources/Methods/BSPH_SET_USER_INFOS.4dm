//%attributes = {"shared":true,"preemptive":"capable"}
/*
	Permets de changer d'utilisateur 4d afin de pouvoir gérer qui a le droit d'accès au dev 4d
*/
#DECLARE($vt_UserCode : Text)

/* exemple de code utilisable 
	Case of 
	: ($vt_UserCode="DEV")
	
	CHANGE CURRENT USER(1; "xxx")
	
	Else 
	CHANGE CURRENT USER("USER"; "")
	
	End case 
*/
