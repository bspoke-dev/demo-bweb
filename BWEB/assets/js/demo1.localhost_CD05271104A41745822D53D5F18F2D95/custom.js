$('[blocname="displayMenu"]').on('click',function(){
    if($('[blocname="Conteneur menu principal"]').is(":visible"))
        $('[blocname="Conteneur menu principal"]').hide();
    else
        $('[blocname="Conteneur menu principal"]').show();
})