({
	doInit : function(component, event, helper) { 
        var tem1 = component.get("{!v.strIdHojaInv}"); 
		helper.getPicklistValuesOneLevel(component,'POCH_DetalleInventario__c','POCH_UnidadMedida__c', null); 
		helper.getPicklistValuesOneLevel(component,'POCH_DetalleInventario__c','POCH_Estatus__c', null); 
        helper.getPicklistValuesOneLevel(component,'POCH_DetalleInventario__c','Moneda_competencia__c', null); 
		helper.getPicklistDataxObject(component, event, helper); 
  
		component.set("v.strFreQuote" ,component.get("v.ProductInstance.POCH_HojaInventario__r.POCH_FrecuenciaCotizacion__c")); 
		component.set("v.listControllingValuesUnidaM" ,component.get("v.ProductInstance.POCH_UnidadMedida__c")); 
		component.set("v.listWhoBuy" ,component.get("v.ProductInstance.POCH_AquienCompra__c")); 
		component.set("v.listControllingValuesEstatus" ,component.get("v.ProductInstance.POCH_Estatus__c"));
        component.set("v.blnProductOnlySF", component.get("v.ProductInstance.POCH_OnlyInSFDC__c"));
        component.set("v.listMonedaComp" ,component.get("v.ProductInstance.Moneda_competencia__c"));

	},	 
	
    removeRow : function(component, event, helper){
        helper.RemoveRecordToDetail(component, event, helper); 
	},
    
    LookupProduct : function(component, event, helper){
		component.set("v.blnShowProducts", true);	 
	},
    
	addNewProductSelected: function(component, event, helper){		
		var blnShowPopupProd = event.getParam("evtShowPopUpProductLookup");// quita PopUp para product2			
		var selectedProductFromEvent = event.getParam("recordByEvent");	
		component.set("v.ProductInstance.POCH_Producto__c" , selectedProductFromEvent.Product2.Id); 
		var productsSelected =  component.get("v.ListaProductsSelected");	
		var strlastId =  component.get("v.ProductInstance.POCH_Producto__c");
		var equalsvalues = [];
		for (var i = 0; i < productsSelected.length; i++) {
			if(productsSelected[i].POCH_Producto__c ==  strlastId){			
				equalsvalues.push(i);		
			}	
		}  

		if(equalsvalues.length > 1){
			component.set("v.blnShowProducts" , blnShowPopupProd);
			helper.showToast(component, event, helper,'No se pueden agregar productos iguales');			
		}else{
			component.set("v.ProductInstance.Name" , selectedProductFromEvent.Product2.Name); 				 	
			component.set("v.ProductInstance.POCH_CantidadPotencial__c" , '0'); //selectedProductFromEvent.POCH_CantidadPotencial__c
			component.set("v.ProductInstance.POCH_CantidadBase__c" , '0'); //selectedProductFromEvent.POCH_CantidadBase__c
            component.set("v.ProductInstance.POCH_EsBase__c" , '0'); 
			component.set("v.ProductInstance.POCH_EsPotencial__c" , '0');				
			component.set("v.ProductInstance.POCH_Moneda__c" , selectedProductFromEvent.CurrencyIsoCode); 		
			component.set("v.ProductInstance.POCH_PrecioLista__c",selectedProductFromEvent.UnitPrice);
			component.set("v.ProductInstance.POCH_AquienCompra__c" , ''); 
			component.set("v.ProductInstance.POCH_Estatus__c" , ''); 	
			component.set("v.ProductInstance.POCH_Notas__c" , ''); 
			//component.set("v.ProductInstance.POCH_MonedaCompetencia__c" , ''); 
			component.set("v.ProductInstance.POCH_CantidadCompetencia__c" , ''); 
            component.set("v.ProductInstance.Moneda_competencia__c" , '');
			
            if(selectedProductFromEvent.POCH_UnidadMedida__c == 'Kg' || selectedProductFromEvent.POCH_UnidadMedida__c == 'L' || selectedProductFromEvent.POCH_UnidadMedida__c == 'Lt') {
                component.set("v.ProductInstance.POCH_UnidadMedida__c" , selectedProductFromEvent.POCH_UnidadMedida__c); 
            }
            if(selectedProductFromEvent.Product2.ProductCode != '' && selectedProductFromEvent.Product2.ProductCode != null && selectedProductFromEvent.Product2.ProductCode != undefined ) {
            	component.set("v.ProductInstance.POCH_Codigo__c" , selectedProductFromEvent.Product2.ProductCode.replace(/^0+/, ''));    
            }            
            component.set("v.blnProductOnlySF", selectedProductFromEvent.Product2.onlyInSalesforce__c);
            if(selectedProductFromEvent.POCH_UnidadMedida__c != '' && selectedProductFromEvent.POCH_UnidadMedida__c != null && selectedProductFromEvent.POCH_UnidadMedida__c != undefined) {
            	component.set("v.ProductInstance.POCH_uma__c", selectedProductFromEvent.POCH_UnidadMedida__c);  
            } else {
                component.set("v.ProductInstance.POCH_uma__c", selectedProductFromEvent.Product2.QuantityUnitOfMeasure);
            }
            if(!!selectedProductFromEvent.Product2.onlyInSalesforce__c) {
                component.set("v.ProductInstance.POCH_Estatus__c" , 'Inactivo'); 
            }
			
			component.set("v.blnShowProducts" , blnShowPopupProd);
		}
	}
})