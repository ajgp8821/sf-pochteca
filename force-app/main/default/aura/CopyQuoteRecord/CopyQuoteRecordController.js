({
    doInit : function(component, event, helper) {
        var action = component.get("c.copyQuoteSobjet");
        component.set("v.showSpinner",true);
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state sucess'+state);
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                var sObjectEvent = $A.get("e.force:navigateToSObject");
                sObjectEvent.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "detail"
                });
                sObjectEvent.fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"success",
                    "message": "The record has been created successfully."
                });
                toastEvent.fire();
                
            }else if (state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "message": "Some error occured."
                });
                toastEvent.fire();
            }
            component.set("v.showSpinner",false);
            $A.get("e.force:closeQuickAction").fire();

        });
        $A.enqueueAction(action);
    },
    
})