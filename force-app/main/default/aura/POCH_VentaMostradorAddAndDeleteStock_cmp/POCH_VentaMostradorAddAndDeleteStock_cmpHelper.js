({
    showToast : function(component, event, helper, msgError) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error!",
            "message": msgError
        });
        toastEvent.fire();
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
