({
	doInit : function(component, event, helper) { 
		var ventasMostrador = component.get("{!v.ventasMostrador}");
		if (ventasMostrador !== null && ventasMostrador !== undefined) {
			component.set("{!v.strIdSucursalAmp}", ventasMostrador.POCH_Sucursal__c);
			if (ventasMostrador.Status__c == 'Cancelado'){
				component.set("{!v.isStatusCancel}", true);
			}
			
		}
    var tem1 = component.get("{!v.strIdVentaMostrador}"); 
		var tem2 = component.get("{!v.isStatusCancel}");
		helper.getPicklistValuesOneLevel(component,'Stock_of_matrials__c','UnidadMedida__c', null); 
		helper.getPicklistValuesOneLevel(component,'Stock_of_matrials__c','CurrencyIsoCode', null);

		component.set("v.listControllingValuesUnidaM" ,component.get("v.VentaInstance.POCH_UnidadMedida__c")); 
		component.set("v.listMoneda" ,component.get("v.VentaInstance.CurrencyIsoCode"));
	},
	
	// removeRow : function(component, event, helper){
	// 	helper.RemoveRecordToDetail(component, event, helper); 
	// },

	removeRow : function(component, event, helper) {
		component.getEvent("DeleteRowEvt").setParams(
				{"indexVar" : component.get("v.rowIndex") }
		).fire();
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

})