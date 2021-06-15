({
    onInit : function(component, event, helper) {
        console.log("::: HI : "+ component.get("v.idHojaInventario"));
        console.log("::: SUC: "+ component.get("v.idSucursal"));
        let action = component.get("c.getFieldList");  
        action.setParams({
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") { 
                let mapFields = response.getReturnValue();
                let textFields = mapFields.filter(field => field.Tipo_de_campo__c !== 'PickList');
                let pickListFields = mapFields.filter(field => field.Tipo_de_campo__c === 'PickList');
                pickListFields.forEach( (field,index) => pickListFields[index].PickListValues__c = field.PickListValues__c.split(','));
                component.set('v.textFields',textFields);
                component.set('v.pickListFields',pickListFields);
            }else{
                console.log('--- Algo salio mal desde: createProduct_cmp. Status!=SUCCESS---');
            }
        });
        $A.enqueueAction(action);   
    },
    handleProductCreation : function(component, event, helper, parsedValues) {          
        let action = component.get("c.insertProduct");  
        action.setParams({
            objProdToInsert : parsedValues,
            idHI            : component.get("v.idHojaInventario"),
            idSuc			: component.get("v.idSucursal")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") { 
                let value = response.getReturnValue();
                if(value.successMessage) {
                    let evt = component.getEvent('productCreated');
                    evt.setParams({'isDeleted' : true});
                    evt.fire();
                    component.destroy();
                }
            }else{
                console.log('--- Algo salio mal desde: createProduct_cmp. Status!=SUCCESS---');
            }
        });
        $A.enqueueAction(action);   
    }
})