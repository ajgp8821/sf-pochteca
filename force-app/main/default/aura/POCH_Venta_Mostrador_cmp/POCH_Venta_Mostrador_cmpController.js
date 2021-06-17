({
    doInit : function(component, event, helper) {
       
        var idVentasMostrador =  component.get("v.recordId"); 
        component.set("v.recordId",idVentasMostrador);
        component.set("v.strTest",'prueba');
        
        helper.getPicklistValuesOneLevel(component,'Ventas_Mostrador__c','Via_de_pago__c', null); 
        helper.getPicklistValuesOneLevel(component,'Ventas_Mostrador__c','Metodo_de_Pago__c', null);
        helper.getPicklistValuesOneLevel(component,'Ventas_Mostrador__c','CurrencyIsoCode', null);
        helper.getPicklistValuesOneLevel(component,'Ventas_Mostrador__c','Uso_de_CFDI__c', null);
        helper.assignParentId(component, event, helper);
        if (idVentasMostrador != null && idVentasMostrador != "") {
            component.set("v.blnRecordExisteShowDetail", true);
            helper.showCabeceraVentaMostrador(component, event, helper);
            helper.showDetailVentaMostrador(component, event, helper);
            helper.requiereActualizacion(component, event, helper);
        }
        helper.createObjectData(component, event);
        
    },

    addNewRow: function(component, event, helper) {  
        helper.createObjectData(component, event);
    },

    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        // get the all List (contactList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.ventasMostradorList");
        AllRowsList.splice(index, 1);
        // set the contactList after remove selected row element  
        component.set("v.ventasMostradorList", AllRowsList);
    },

    Save: function(component, event, helper) {
        let button = event.getSource();
        button.set('v.disabled',true);
        var strsuc =  component.get("v.selectedLookUpRecord").Name;
        component.set('v.strIdBranch', strsuc);
        var dataProducts =  component.get("v.ventasMostradorList");        
        helper.validaAutorizacion(component, event, helper);
        component.set("v.blnErrores", false);  
        button.set('v.disabled',false);
    },

    Update: function(component, event, helper) {
        button.set('v.disabled',true);
        helper.UpdateRecords(component, event, helper); 
    },

    refresh: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    validarMoneda: function(component, event, helper) { 
        var indutry = component.get("v.currency");
        var test = indutry;     
    }
})