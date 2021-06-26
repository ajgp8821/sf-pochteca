({
	doInit : function(component, event, helper) { 
		var ventasMostrador = component.get("{!v.ventasMostrador}");
		helper.getPicklistValuesOneLevel(component,'Venta_Mostrador_Detalle__c','UnidadMedida__c', null);
		helper.getDependentPicklistValues(component, 'Venta_Mostrador_Detalle__c', 'Oficina_de_Venta__c', 'POCH_Centro__c', component.get("v.VentaInstance.Oficina_de_Venta__c"), true);
		component.set("v.listControllingValuesUnidaM" ,component.get("v.VentaInstance.UnidadMedida__c"));
		component.set("v.listCentro" ,component.get("v.VentaInstance.POCH_Centro__c"));
		component.set("v.listAlmacen" ,component.get("v.VentaInstance.Almacen__c"));
		//component.set("v.listCentro" ,component.get("v.VentaInstance.POCH_Centro__c"));
		if (ventasMostrador !== null && ventasMostrador !== undefined) {
			component.set("{!v.strIdSucursalAmp}", ventasMostrador.POCH_Sucursal__c);
			if (ventasMostrador.Status__c == 'Cancelado'){
				component.set("{!v.isStatusCancel}", true);
			}
			
		}
	},
	
	// removeRow : function(component, event, helper){
	// 	helper.RemoveRecordToDetail(component, event, helper); 
	// },

	removeRow : function(component, event, helper) {
		component.getEvent("DeleteRowEvt").setParams(
				{"indexVar" : component.get("v.rowIndex") }
		).fire();

		var recalcularTotalesEvent = component.getEvent("recalcularTotales");
		var test = " test";
		recalcularTotalesEvent.setParams({testParam: test});
		recalcularTotalesEvent.fire();
},
	
	LookupProduct : function(component, event, helper){
		component.set("v.blnShowProducts", true);	 
	},

	addNewProductSelected: function(component, event, helper) {		
		var blnShowPopupProd = event.getParam("evtShowPopUpProductLookup");	
		var selectedProductFromEvent = event.getParam("recordByEvent");	
		component.set("v.VentaInstance.POCH_Producto__c" , selectedProductFromEvent.Product2.Id); 
		var productsSelected =  component.get("v.ListaVentaSelected");	
		var strlastId =  component.get("v.VentaInstance.POCH_Producto__c");
		var equalsvalues = [];

		for (var i = 0; i < productsSelected.length; i++) {
			if(productsSelected[i].POCH_Producto__c ==  strlastId){			
				equalsvalues.push(i);		
			}	
		}  

		if(equalsvalues.length > 1) {
			component.set("v.blnShowProducts" , blnShowPopupProd);
			helper.showToast(component, event, helper,'No se pueden agregar productos iguales');			
		}
		else {
			
			if(selectedProductFromEvent.Product2.ProductCode != '' && selectedProductFromEvent.Product2.ProductCode != null && selectedProductFromEvent.Product2.ProductCode != undefined ) {
				component.set("v.VentaInstance.Material__c" , selectedProductFromEvent.Product2.ProductCode.replace(/^0+/, ''));    
			}
			if(selectedProductFromEvent.Product2.Name != '' && selectedProductFromEvent.Product2.Name != null && selectedProductFromEvent.Product2.Name != undefined) {
				component.set("v.VentaInstance.Descripcion__c", selectedProductFromEvent.Product2.Name.replace(/^0+/, ''));
			}
			if(selectedProductFromEvent.POCH_UnidadMedida__c != '' && selectedProductFromEvent.POCH_UnidadMedida__c != null && selectedProductFromEvent.POCH_UnidadMedida__c != undefined) {
				component.set("v.VentaInstance.UnidadMedida__c" , selectedProductFromEvent.POCH_UnidadMedida__c);
			}
			// selectedProductFromEvent.CurrencyIsoCode
			if(selectedProductFromEvent.CurrencyIsoCode != '' && selectedProductFromEvent.CurrencyIsoCode != null && selectedProductFromEvent.CurrencyIsoCode != undefined) {
				component.set("v.VentaInstance.CurrencyIsoCode" , selectedProductFromEvent.CurrencyIsoCode);
			}
			
			component.set("v.blnShowProducts" , blnShowPopupProd);
		
		}
	},

	calcularTotales : function(component, event, helper) {
        var ventaDetalle = component.get("v.VentaInstance");
        ventaDetalle.Product__c = component.get("v.VentaInstance.Product__c");
        var temp = component.get("v.VentaInstance.POCH_Centro__c" );
        ventaDetalle.Sucursal__c = component.get("v.VentaInstance.Sucursal__c");
        ventaDetalle.Oficina_de_Venta__c = component.get("v.VentaInstance.Oficina_de_Venta__c");
        var venta = component.get("v.ventasMostrador");
        var action = component.get("c.getPrice");
        var action2 = component.get("c.getIVA");
		action.setParams({
            //product: component.get("v.VentaInstance.POCH_Producto__c"),
            product: ventaDetalle.Product__c,
            sucursal: ventaDetalle.Sucursal__c,
            //sucursal: 'a1K4P00000Ldvr8UAB',
            cantidad: ventaDetalle.POCH_Cantidad__c,
            account: component.get("{!v.ventasMostrador.Cliente__c}"),
            //account: '0014P00002lB91DQAS',
            unidadMedida: ventaDetalle.UnidadMedida__c,
            notIsApiField: true,
            objectType: 'Venta_Mostrador_Detalle__c',
            selectedField: 'UnidadMedida__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let precio = response.getReturnValue();
                ventaDetalle.Precio__c =  precio;
                ventaDetalle.Descto__c = parseFloat(ventaDetalle.Descto__c);
                ventaDetalle.Descuento_Monto__c = precio * ventaDetalle.Descto__c / 100;
                //var montoPorcentaje = precio * ventaDetalle.Descto__c;
                ventaDetalle.Valor_neto__c = (precio - ventaDetalle.Descuento_Monto__c ) * ventaDetalle.POCH_Cantidad__c;
                component.set("v.VentaInstance", ventaDetalle); 
                action2.setParams({
                    product: ventaDetalle.Product__c,
                    sucursal: ventaDetalle.Sucursal__c,
                    //sucursal: 'a1K4P00000Ldvr8UAB',
                    valorNeto: ventaDetalle.Valor_neto__c
                });
                action2.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        let ivaMonto = response.getReturnValue();
                        ventaDetalle.IVA__c;
                        component.set("v.VentaInstance", ventaDetalle); 
                        var calcularTotalesEvent = component.getEvent("calcularTotales");
                        var test = " test";
                        calcularTotalesEvent.setParams({testParam: test});
                        calcularTotalesEvent.fire();
                    }else {
                        console.log("--- Algo salio mal ---");
                    }
                });
                $A.enqueueAction(action2);
                

            }else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
    }

})