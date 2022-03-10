({
    doInit : function(component, event, helper) {
        var action = component.get("c.copyQuoteSobjet");
        component.set("v.showSpinner",true);
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state sucess ', state);
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                
                console.log('result', result);
                //debugger;
                if (result === 'errorUser'){
                    helper.showToast('error', 'Error!', 'El usuario no tiene permisos para crear documentos de esta sucursal');
                }
                else if (result !== "error") {
                    helper.showToast('success', '', 'Cotización copiada correctamente');
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": response.getReturnValue(),
                        "slideDevName": "detail"
                    });
                    sObjectEvent.fire();
                }
                else {
                    helper.showToast('error', 'Error!', 'Error al copiar, favor de informar al Administrador');
                }
                
            }else if (state === "ERROR"){
                helper.showToast('error', 'Error!', 'Error al copiar, favor de informar al Administrador');
            }
            component.set("v.showSpinner",false);
            $A.get("e.force:closeQuickAction").fire();

        });
        $A.enqueueAction(action);
    },
    
})