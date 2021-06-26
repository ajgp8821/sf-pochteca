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
        // helper.createObjectData(component, event);
        
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

    update: function(component, event, helper) {

        var ventaMostrador =  component.get("v.ventasMostrador");

        if(ventaMostrador.Via_de_pago__c == '' || ventaMostrador.Via_de_pago__c == null || ventaMostrador.Via_de_pago__c == undefined || ventaMostrador.Via_de_pago__c == '--'){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe seleccionar Vía de Pago');
        }
        else if(ventaMostrador.CurrencyIsoCode == '' || ventaMostrador.CurrencyIsoCode == null || ventaMostrador.CurrencyIsoCode == undefined || ventaMostrador.CurrencyIsoCode == '--'){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe seleccionar Moneda del pedido');
        }
        else if(ventaMostrador.Uso_de_CFDI__c == '' || ventaMostrador.Uso_de_CFDI__c == null || ventaMostrador.Uso_de_CFDI__c == undefined || ventaMostrador.Uso_de_CFDI__c == '--'){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe seleccionar Uso de CFDI');
        }
        else if((ventaMostrador.Metodo_de_Pago3__c != '' || ventaMostrador.Metodo_de_Pago3__c != ' ') && (ventaMostrador.Importe_3__c == 0 || ventaMostrador.Importe_3__c == null)){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe indicar el Importe 3');
        }
        else if(ventaMostrador.Metodo_de_Pago__c == '' || ventaMostrador.Metodo_de_Pago__c == null || ventaMostrador.Metodo_de_Pago__c == undefined || ventaMostrador.Metodo_de_Pago__c == '--'){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe seleccionar Métodos de Pago');
        }
        else if(ventaMostrador.Metodo_de_Pago2__c == '' || ventaMostrador.Metodo_de_Pago2__c == null || ventaMostrador.Metodo_de_Pago2__c == undefined || ventaMostrador.Metodo_de_Pago2__c == '--'){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe seleccionar Métodos de Pago 2');
        }
        else if(ventaMostrador.Digitos_tarjeta__c == '' || ventaMostrador.Digitos_tarjeta__c == null || ventaMostrador.Digitos_tarjeta__c == undefined){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe completar Ultimos 4 digitos de tarjeta');
        }
        // else if(ventaMostrador.Importe__c)
        // TODO: Validar moneda
        else{
            var isNewRecord = component.get("v.blnRecordExisteShowDetail");
            var detalleVentaMostrador =  component.get("v.ventasMostradorList");
    
            console.log('ventaMostrador', JSON.stringify(ventaMostrador));
            // helper.saveVentasMostrador(component, event);
        }
        // Metodo_de_Pago__c
        // Metodo_de_Pago2__c
        // Metodo_de_Pago3__c
        // Importe__c
        // Importe_2__c
        // Importe_3__c
    },

    save: function(component, event, helper) {
        var errores = false;
        var ventaMostrador =  component.get("v.ventasMostrador");
        var detalleVentaMostrador =  component.get("v.ventasMostradorList");
        for (var indexVar = 0; indexVar < detalleVentaMostrador.length; indexVar++) {
            if (detalleVentaMostrador[indexVar].Product__c == null || detalleVentaMostrador[indexVar].Product__c == '' ){
                helper.showToast('Warning', 'Atención!', 'No puede guardar sin seleccionar un producto');
                errores = true;
                break;
            }
            
        }
        var email = ventaMostrador.Email__c;
        var emailRegex = /^[-\w.%+]{1,64}@(?:[A-Z0-9-]{1,63}\.){1,125}[A-Z]{2,63}$/i;
        //Se muestra un texto a modo de ejemplo, luego va a ser un icono
        if (emailRegex.test(email)) {
            console.log('test');
        } else {
            helper.showToast('Warning', 'Atención!', 'formato de email no valido');
            errores = true;
        }
        if (errores == false){
            helper.saveVentasMostrador(component, event); 
        }
        
        //button.set('v.disabled',true);
        
    },

    refresh: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    validarMoneda: function(component, event, helper) { 
        var StrnNameField = component.get("v.ventasMostrador.CurrencyIsoCode");
        if (StrnNameField != "Dólar de EE.UU.") {
            helper.validarCurrency(component, StrnNameField, true, 'Ventas_Mostrador__c', 'CurrencyIsoCode');
            //helper.getApiName(component,'Ventas_Mostrador__c','CurrencyIsoCode', label);            
        }            
    },

    calcularTotales: function(component, event, helper) {
        var blnShowPopupProd = event.getParam("testParam");
        //var selectedProductFromEvent = event.getParam("recordByEvent");
        helper.calcularTotales(component, event, helper); 
    }

    
})