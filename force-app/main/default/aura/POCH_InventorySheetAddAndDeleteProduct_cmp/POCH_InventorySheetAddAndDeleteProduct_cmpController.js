({
	doInit : function(component, event, helper) { 
       // alert('probando');
		helper.getPicklistValuesOneLevel(component,'POCH_DetalleInventario__c','POCH_UnidadMedida__c'); 
		helper.getPicklistValuesOneLevel(component,'POCH_DetalleInventario__c','POCH_Estatus__c'); 
		helper.getPicklistValuesOneLevel(component,'POCH_DetalleInventario__c','Moneda_competencia__c'); 
        helper.getPicklistDataxObject(component, event, helper); 
	},	
	
    removeRow : function(component, event, helper) {
        component.getEvent("DeleteRowEvt").setParams(
            {"indexVar" : component.get("v.rowIndex") }
        ).fire();
    }, 
    
	LookupProduct : function(component, event, helper) {
		component.set("v.blnShowProducts", true);	 
	},
    
	addNewProductSelected: function(component, event, helper) {		
		var blnShowPopupProd = event.getParam("evtShowPopUpProductLookup");	
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

		if(equalsvalues.length > 1) {
			component.set("v.blnShowProducts" , blnShowPopupProd);
			helper.showToast(component, event, helper,'No se pueden agregar productos iguales');			
		} else {
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
            component.set("v.ProductInstance.Moneda_competencia__c" , '');
			component.set("v.ProductInstance.POCH_CantidadCompetencia__c" , '');
            console.log("-- UM " + selectedProductFromEvent.POCH_UnidadMedida__c);
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
	},

    validateUM : function(component, event, helper) {
        var strIdProduct = component.get("v.ProductInstance.POCH_Producto__c");	   
        var strUniMedida = component.get("v.ProductInstance.POCH_UnidadMedida__c");	
        var strIdSucAmp  = component.get("v.strIdSucursalAmp");

        var action = component.get("c.getUMP");
        action.setParams({ 
            "idProd" : strIdProduct,
            "idSuc"  : strIdSucAmp
        });            
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS") {
                component.set("v.ProductInstance.POCH_uma__c", response.getReturnValue());	
                if(strIdProduct !== '' && strIdProduct !== null && strIdProduct !== undefined
                   && strUniMedida == 'Kg' || strUniMedida == 'Lt' || strUniMedida == 'L') 
                {
                    helper.validateUM_Helper(component, event, helper, response.getReturnValue());
                }
            } else { console.log('--- Algo salio mal UM ---'); }                                           
        });
        $A.enqueueAction(action);          
    }

})