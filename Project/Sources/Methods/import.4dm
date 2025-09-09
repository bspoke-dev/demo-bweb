//%attributes = {}
var $vx_Response : Picture
var $vl_response : Integer

$vc_Products:=JSON Parse:C1218(Folder:C1567(fk resources folder:K87:11).file("products.json").getText())
ds:C1482.PRODUCT.all().drop()
For each ($vo_Product; $vc_Products)
	$Product:=ds:C1482.PRODUCT.new()
	$Product.name:=$vo_Product.nom
	$Product.description:=$vo_Product.description
	$Product.price:=$vo_Product.prix
	$Product.stock:=$vo_Product.stock
	$Product.category:=$vo_Product.categorie
	$Product.createdOn:=$vo_Product.date_creation+".000Z"
	Try
		$vl_response:=HTTP Get:C1157($vo_Product.image_url; $vx_Response)
		If ($vl_response=200)
			$Product.image:=$vx_Response
		End if 
	End try
	$Product.save()
End for each 