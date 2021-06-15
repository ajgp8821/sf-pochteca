({
	RemoveRecordToDetail : function(component, event, helper) {
		var action = component.get("c.deleteRecordOnDetail");
        action.setParams({
            'IdRecordDetail': component.get("v.VentaInstance.Id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "title": "Eliminado!",
                        "message": "Se Elimino el Registro"
                    });
                    toastEvent.fire();
            }else{
                console.log('--- Algo salio mal ---');
            }

        });
        $A.enqueueAction(action); 
    },

    getPicklistValuesOneLevel: function(component,StrObject,StrnNameField) {
        var action = component.get("c.PickListValuesIntoList"); 
        action.setParams({
            objectType: StrObject,
            selectedField: StrnNameField
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var StoreResponse =  response.getReturnValue();
                
                var listOneLevel =  [];
                var ControllerFieldOneLevel = [];
                
                for (var i = 0; i < StoreResponse.length; i++) {
                    listOneLevel.push(StoreResponse[i]);
                }  
            	//
                if (listOneLevel != undefined && listOneLevel.length > 0) {
                    ControllerFieldOneLevel.push('-NA-');        
                }
                
                for (var i = 0; i < listOneLevel.length; i++) {
                    ControllerFieldOneLevel.push(listOneLevel[i]);
                } 
                if(StrnNameField == 'UnidadMedida__c'){
                    component.set("v.listControllingValuesUnidaM", ControllerFieldOneLevel);
                }
                if(StrnNameField == 'CurrencyIsoCode'){
                    component.set("v.listMoneda", ControllerFieldOneLevel);
                    
                }
            }
        });
        $A.enqueueAction(action);
    }
})