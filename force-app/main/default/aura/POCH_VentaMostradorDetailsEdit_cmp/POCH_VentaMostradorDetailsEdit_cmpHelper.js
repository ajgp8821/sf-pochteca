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
                
                for (var i = 0; i < listOneLevel.length; i++) {
                    ControllerFieldOneLevel.push(listOneLevel[i]);
                }
                if(StrnNameField == 'UnidadMedida__c'){
                    component.set("v.listControllingValuesUnidaM", ControllerFieldOneLevel);
                }
                if(StrnNameField == 'POCH_Centro__c'){
                    component.set("v.listCentro", ControllerFieldOneLevel);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getDescriptionString: function(component, StrObject, StrnNameField, label) {
        
        var action = component.get("c.getDescriptionString"); 
        action.setParams({
            objectType: StrObject,
            selectedField: StrnNameField,
            apiLabel: label
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var StoreResponse =  response.getReturnValue();
                var ventaMostrador =  component.get("v.ventasMostrador");
                if(StrnNameField == 'POCH_Centro__c'){
                    component.set("v.VentaInstance.POCH_Centro__c", StoreResponse);
                }
                if(StrnNameField == 'Almacen__c'){
                    component.set("v.VentaInstance.Almacen__c", StoreResponse);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getDependentPicklistValues: function (component, objectType, firstField, selectedField, filter, isApiField) {
        var action = component.get("c.getDependentPicklistValues");
        action.setParams({
            objectType: objectType,
            firstField: firstField,
            selectedField: selectedField,
            filter: filter,
            isApiField: isApiField
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let listValues = response.getReturnValue();
                if(listValues !== null && listValues !== undefined && listValues.length > 0) {
                    if (selectedField == 'POCH_Centro__c'){
                        component.set("v.VentaInstance.POCH_Centro__c",listValues[0]);
                        var instanceVenta = component.get("v.VentaInstance");
                        instanceVenta.POCH_Centro__c = listValues[0];
                        component.set("v.listCentro", listValues);
                        var action2 = component.get("c.getDependentPicklistValues");
                        action2.setParams({
                            objectType: objectType,
                            firstField: 'POCH_Centro__c',
                            selectedField: 'Almacen__c',
                            filter: instanceVenta.POCH_Centro__c,
                            isApiField: false
                        });
                        action2.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                let listValues2 = response.getReturnValue();
                                if(listValues2 !== null && listValues2 !== undefined && listValues2.length > 0) {
                                    instanceVenta.Almacen__c = listValues2[0];
                                    component.set("v.listAlmacen", listValues2);
                                    component.set("v.VentaInstance", instanceVenta);
                                }
                            }
                        });
                        $A.enqueueAction(action2);

                    }
                    if (selectedField == 'Almacen__c'){
                        component.set("v.listAlmacen", listValues);
                    }
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function(tipomsj, titlemsj, Mensaje) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": tipomsj,
            "title": titlemsj,
            "message": Mensaje
        });
        toastEvent.fire();        
    },

    showToast2: function(tipomsj, titlemsj, Mensaje) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": tipomsj,
            "title": titlemsj,
            "message": Mensaje
        });
        toastEvent.fire();        
    },

    getStock: function (component, almacen, centro, producto, stockConsigna) {
        var action = component.get("c.getStock");
        action.setParams({
            product: producto,
            centro: centro,
            almacen: almacen,
            stockConsigna: stockConsigna
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let stock = response.getReturnValue();
                if(stock !== null && stock !== undefined) {
                    if (stockConsigna != ''){
                        component.set("v.VentaInstance.Stock_Consignacion__c",stock);
                    }else{
                        component.set("v.VentaInstance.Stock__c",stock);
                    }
                    
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
    },
})