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
            helper.getSucursal(component, event);
            helper.showDetailVentaMostrador(component, event, helper);
        }
        
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

    sendSap: function(component, event, helper) {

        var ventaMostrador =  component.get("v.ventasMostrador");
        if (component.get("v.oficinaVentas") != '' || component.get("v.oficinaVentas") != null || component.get("v.oficinaVentas") != undefined){
            component.set("v.ventasMostrador.Oficina_de_Venta__c", component.get("v.oficinaVentas"));
        }
        if (component.get("v.strIdSucursal") != '' || component.get("v.strIdSucursal") != null || component.get("v.strIdSucursal") != undefined){
            component.set("v.ventasMostrador.POCH_Sucursal__c",component.get("v.strIdSucursal"));
        }
        if (component.get("v.organizacionVentas") != '' || component.get("v.organizacionVentas") != null || component.get("v.organizacionVentas") != undefined){
            component.set("v.ventasMostrador.OrganizacionVentas__c", component.get("v.organizacionVentas"));
        }
        var email = ventaMostrador.Email__c;
        var emailRegex = /^[-\w.%+]{1,64}@(?:[A-Z0-9-]{1,63}\.){1,125}[A-Z]{2,63}$/i;
        if(ventaMostrador.Importe__c == null){
            ventaMostrador.Importe__c = 0;
        }
        if(ventaMostrador.Importe_2__c == null){
            ventaMostrador.Importe_2__c = 0;
        }
        if(ventaMostrador.Importe_3__c == null){
            ventaMostrador.Importe_3__c = 0;
        }
        if(ventaMostrador.Metodo_de_Pago3__c != '' && ventaMostrador.Importe_3__c <= 0){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe indicar el Importe 3');
        }
        else if(ventaMostrador.Metodo_de_Pago3__c == '' && ventaMostrador.Importe_3__c > 0){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe indicar metodo de pago 3');
        }
        else if(ventaMostrador.Metodo_de_Pago2__c != '' && ventaMostrador.Importe_2__c <= 0){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe indicar el Importe 2');
        }
        else if(ventaMostrador.Metodo_de_Pago2__c == '' && ventaMostrador.Importe_2__c > 0){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe indicar metodo de pago 2');
        }
        else if(ventaMostrador.Metodo_de_Pago__c != '' && ventaMostrador.Importe__c <= 0){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe indicar el Importe');
        }
        else if(ventaMostrador.Metodo_de_Pago__c == '' && ventaMostrador.Importe__c > 0){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe indicar metodo de pago');
        }
        else if( (ventaMostrador.Importe__c + ventaMostrador.Importe_2__c + ventaMostrador.Importe_3__c == 0 )){
                helper.showToast('Warning', 'Atención!', 'Antes de guardar, los importes deben sumar el total');
        }
        else if( (ventaMostrador.Importe__c + ventaMostrador.Importe_2__c + ventaMostrador.Importe_3__c != ventaMostrador.Precio_total__c )){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, los importes deben sumar el total');
        }
        else if( (ventaMostrador.Importe__c > 0 && ventaMostrador.Importe_2__c > 0 && ventaMostrador.Importe_3__c > 0) &&
                 (ventaMostrador.Importe__c + ventaMostrador.Importe_2__c + ventaMostrador.Importe_3__c != ventaMostrador.Precio_total__c )){
                helper.showToast('Warning', 'Atención!', 'Antes de guardar, los importes deben sumar el total');
        }
        else if( (ventaMostrador.Importe_2__c > 0 && ventaMostrador.Importe_3__c > 0 && ventaMostrador.Importe__c == 0) &&
            (ventaMostrador.Importe_2__c + ventaMostrador.Importe_3__c != ventaMostrador.Precio_total__c )){
                helper.showToast('Warning', 'Atención!', 'Antes de guardar, los importes deben sumar el total');
        }
        else if( (ventaMostrador.Importe__c > 0 && ventaMostrador.Importe_3__c > 0 && ventaMostrador.Importe_2__c == 0) &&
            (ventaMostrador.Importe__c + ventaMostrador.Importe_3__c != ventaMostrador.Precio_total__c )){
                helper.showToast('Warning', 'Atención!', 'Antes de guardar, los importes deben sumar el total');
        }
        else if( (ventaMostrador.Importe__c > 0 && ventaMostrador.Importe_2__c > 0 && ventaMostrador.Importe_3__c == 0) &&
            (ventaMostrador.Importe__c + ventaMostrador.Importe_2__c != ventaMostrador.Precio_total__c )){
                helper.showToast('Warning', 'Atención!', 'Antes de guardar, los importes deben sumar el total');
        }
        else if(ventaMostrador.Via_de_pago__c == '' || ventaMostrador.Via_de_pago__c == null || ventaMostrador.Via_de_pago__c == undefined || ventaMostrador.Via_de_pago__c == '--'){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe seleccionar Vía de Pago');
        }
        else if(ventaMostrador.Uso_de_CFDI__c == '' || ventaMostrador.Uso_de_CFDI__c == null || ventaMostrador.Uso_de_CFDI__c == undefined || ventaMostrador.Uso_de_CFDI__c == '--'){
            helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe seleccionar Uso de CFDI');
        }
        //else if(ventaMostrador.Digitos_tarjeta__c.length != 4){
        //    helper.showToast('Warning', 'Atención!', 'Antes de guardar, debe completar Ultimos 4 digitos de tarjeta');
        //}
        //Se muestra un texto a modo de ejemplo, luego va a ser un icono
        else if (!emailRegex.test(email)) {
            helper.showToast('Warning', 'Atención!', 'formato de email no valido');
            // errores = true;
        }

        // Validar Moneda del detalle
        else {
            helper.validateCurrency(component, event);
        }
    },

    save: function(component, event, helper) {
        var errores = false;
        var ventaMostrador =  component.get("v.ventasMostrador");
        component.set("v.ventasMostrador.Oficina_de_Venta__c", component.get("v.oficinaVentas"));
        component.set("v.ventasMostrador.POCH_Sucursal__c",component.get("v.strIdSucursal"));
        component.set("v.ventasMostrador.OrganizacionVentas__c", component.get("v.organizacionVentas"));
        ventaMostrador.OrganizacionVentas__c = component.get("v.organizacionVentas");
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
            // console.log('test');
        } else {
            helper.showToast('Warning', 'Atención!', 'formato de email no valido');
            errores = true;
        }
        if (errores == false){
            helper.saveVentasMostrador(component, event, false); 
        }
    },

    update: function(component, event, helper) {
        var errores = false;
        var ventaMostrador =  component.get("v.ventasMostrador");
        ventaMostrador.OrganizacionVentas__c = component.get("v.organizacionVentas");
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
            // console.log('test');
        } else {
            helper.showToast('Warning', 'Atención!', 'formato de email no valido');
            errores = true;
        }
        if (errores == false){
            helper.updateVentasMostrador(component, event, false); 
        }
    },

    // TODO
    cancel: function(component, event, helper) {
        
        helper.cancelVentasMostrador(component, event);
    },

    refresh: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    validarMoneda: function(component, event, helper) { 
        var StrnNameField = component.get("v.ventasMostrador.CurrencyIsoCode");
        if (StrnNameField != "Dólar de EE.UU." && StrnNameField != "U.S. Dollar") {
            helper.validarCurrency(component, StrnNameField, true, 'Ventas_Mostrador__c', 'CurrencyIsoCode');       
        }          
    },

    calcularTotales: function(component, event, helper) {
        var blnShowPopupProd = event.getParam("testParam");
        helper.calcularTotales(component, event, helper); 
    }
    
})