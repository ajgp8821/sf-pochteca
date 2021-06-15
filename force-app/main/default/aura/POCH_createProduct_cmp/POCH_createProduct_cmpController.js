({
    doInit : function(component, event, helper) {
        helper.onInit(component, event, helper);
    },
    createProduct : function(component, event, helper) {
        let values = component.find('productValue');
        let mapValues= [];
        values.forEach(element => {
            let mapValue ={};
            mapValue.field = element.get('v.name');
            mapValue.inputValue = element.get('v.value');
            mapValue.tobject = element.get('v.class');
            mapValues.push(mapValue);
        });
        mapValues = JSON.stringify(mapValues);
        helper.handleProductCreation(component,event,helper,mapValues);
    },
    closeModel : function(component, event, helper) {
        let evt = component.getEvent('productCreated');
        evt.setParams({'isDeleted' : false});
        evt.fire();
        component.destroy();
    }
})