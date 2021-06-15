({
	doInit : function(component, event, helper) { 
		var ventasMostrador = component.get("{!v.VentaMostrador}");
		if (ventasMostrador !== null) {
			component.set("{!v.strIdSucursalAmp}", ventasMostrador.POCH_Sucursal__c);
		}
    var tem1 = component.get("{!v.strIdVentaMostrador}"); 
		var tem2 = component.get("{!v.isStatusCancel}");
		helper.getPicklistValuesOneLevel(component,'Stock_of_matrials__c','UnidadMedida__c', null); 
		helper.getPicklistValuesOneLevel(component,'Stock_of_matrials__c','CurrencyIsoCode', null);

		component.set("v.listControllingValuesUnidaM" ,component.get("v.VentaInstance.POCH_UnidadMedida__c")); 
		component.set("v.listMoneda" ,component.get("v.VentaInstance.CurrencyIsoCode"));
	},	 
	
    removeRow : function(component, event, helper){
        helper.RemoveRecordToDetail(component, event, helper); 
	},
    
    LookupProduct : function(component, event, helper){
		component.set("v.blnShowProducts", true);	 
	},
   
})