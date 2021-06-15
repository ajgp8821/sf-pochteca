({
	handleProductCreate : function(component, isComponentCreated) {
		if(!isComponentCreated) {            
            var idHojaInvn = component.get("v.idInvSheet");
            var idSucursal = component.get("v.strIdSucAmp");           
			$A.createComponent(
				"c:POCH_createProduct_cmp",
				{
                    "idHojaInventario": idHojaInvn,
                    "idSucursal":       idSucursal
				},
				function(productForm, status, errorMessage){
					if (status === "SUCCESS") {
						var body = component.get("v.body");
                    	body.push(productForm);
                    	component.set("v.body", body);
						component.set('v.productIsCreating',true);
					}
					else if (status === "INCOMPLETE") {
						console.log("No response from server or client is offline.")
					}
					else if (status === "ERROR") {
						console.log("Error: " + errorMessage);
					}
				}
			);
		} else {
			alert('Componente ya creado');
		}
	},
	showToast : function(tipomsj,titlemsj,Mensaje) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": tipomsj,
            "title": titlemsj,
            "message": Mensaje
        });
        toastEvent.fire();        
    }
})