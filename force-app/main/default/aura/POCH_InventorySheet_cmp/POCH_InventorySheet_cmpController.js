({
    doInit : function(component, event, helper) {
        var idInventorySheet =  component.get("v.recordId"); 
        component.set("v.recordId",idInventorySheet);  
        
        //var idInventorySheet = 'a1Z2i0000017NoUEAU';
        helper.getPicklistDataxObject(component, event, helper); 
        helper.assignParentId(component, event, helper);        
        //Valida si el ID de la hoja de inventario 
        if(idInventorySheet != null && idInventorySheet != '' ){
            component.set("v.blnRecordExisteShowDetail",true);  
            helper.showDetailSheetInventory(component, event, helper);    
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
        var AllRowsList = component.get("v.productList");
        AllRowsList.splice(index, 1);
        // set the contactList after remove selected row element  
        component.set("v.productList", AllRowsList);
    },
    Save: function(component, event, helper) {
        var listIdProduct = new Array();
        var listMedidasRtn = new Array();
        var action = component.get("c.getUnidadesMedidas");
        //helper.getMedidasProduct(component, event, helper);
        var listaMedidas =  component.get("v.listUnidadesMedidas");
        let button = event.getSource();
        button.set('v.disabled',true);
        
        var strsuc =  component.get("v.selectedLookUpRecord").Name;
        component.set('v.strIdBranch', strsuc);
        
        var dataProducts =  component.get("v.productList");
        var lst = '<ul> Falta :';
        var msj = '';
        
        var strNA= '-NA-';
        var strValidateSuc = false;
        var strValidateDescrip = false;
        var strValidateCantPot = false;
        var strValidateMonedaCompt = false;
        var strValidateCantBase = false;
        var strValidateUnidadM = false;
        var strAQuienCompra = false;
        var strEstaus = false;
        var unidadMedidaCorrectaList = new Array();
        for (var i = 0; i < dataProducts.length; i++) {
            listIdProduct.push(dataProducts[i].POCH_Producto__c);
        }
        action.setParams({
            listIdProducto: listIdProduct
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let listResult = response.getReturnValue();
                if(listResult !== null && listResult !== undefined && listResult.length > 0){
                    for (var indexVar = 0; indexVar < dataProducts.length; indexVar++) {
                        for (var i = 0; i < listResult.length; i++) {
                            if (dataProducts[indexVar].UnidadMedida__c != null && dataProducts[indexVar].UnidadMedida__c !='' && dataProducts[indexVar].UnidadMedida__c != strNA){
                                var idProd = listResult[i].substr(0,18);
                                var medida = listResult[i].substr(18);
                                if (idProd == dataProducts[indexVar].POCH_Producto__c && medida == dataProducts[indexVar].UnidadMedida__c.toUpperCase()){
                                    unidadMedidaCorrectaList[indexVar] = 1; 
                                    break;      
                                }else{
                                    unidadMedidaCorrectaList[indexVar] = 0; 
                                }
                            }     
                        }
                    }
                    if(strsuc) {
                        component.set("v.blnBorderColorSuc", true);
                        strValidateSuc = true;
                    }else{
                        component.set("v.blnBorderColorSuc", false);
                        msj +='<li type="disc" > Sucursal </li>  '  
                        strValidateSuc = false;
                    }
                    for (var indexVar = 0; indexVar < dataProducts.length; indexVar++) {
                        if(dataProducts[indexVar].Name != null && dataProducts[indexVar].Name !=''){
                            strValidateDescrip = true;
                        }else{
                            msj +='<li type="disc">Descripcion de producto </li>'  ;
                            strValidateDescrip = false;
                        }
                        if(dataProducts[indexVar].POCH_CantidadBase__c > 0  && dataProducts[indexVar].POCH_Estatus__c =='Inactivo'){
                            strValidateCantBase = false;
                            msj +='<li type="disc" > Si  Cantidad Base es  mayor a  cero(0) no puede estar Inactivo </li>  '  
                        }
                        if(dataProducts[indexVar].POCH_CantidadBase__c == 0  && dataProducts[indexVar].POCH_Estatus__c =='Activo'){
                            strValidateCantBase = false;
                            msj +='<li type="disc" > Si  Cantidad Base es cero(0) no puede estar Activo </li>  '  
                        }
                        //Cantidad potencial
                        if(dataProducts[indexVar].POCH_CantidadPotencial__c !== null && dataProducts[indexVar].POCH_CantidadPotencial__c !== '' 
                           && dataProducts[indexVar].POCH_CantidadPotencial__c !== undefined)
                        {
                            strValidateCantPot = true;
                        }else{
                            msj +='<li type="disc"> Cantidad potencial </li>' ;
                            strValidateCantPot = false;
                        }
                        //Cantidad Base
                        if(dataProducts[indexVar].POCH_CantidadBase__c !== null && dataProducts[indexVar].POCH_CantidadBase__c !== '' 
                           && dataProducts[indexVar].POCH_CantidadBase__c !== undefined)
                        {
                            strValidateCantBase = true;
                        }else{
                            msj +='<li type="disc"> Cantidad Base </li>' ;
                            strValidateCantBase = false;
                        }
                        //Unidad de medida
                        if(dataProducts[indexVar].POCH_UnidadMedida__c != null && dataProducts[indexVar].POCH_UnidadMedida__c !='' && dataProducts[indexVar].POCH_UnidadMedida__c != strNA){
                            if (unidadMedidaCorrectaList[indexVar] == 0){
                                msj += '<li type="disc"> Selecciona una unidad de medida válida código: ' + dataProducts[indexVar].POCH_Codigo__c + ' <li/>' ;
                                strValidateUnidadM = false;
                                unidadMedidaCorrectaList[indexVar] = 0;
                            }else{
                                strValidateUnidadM = true;
                            }
                        }else{
                            msj +='<li type="disc"> Unidad de Medida o Diferente de -NA- <li/>' ;
                            strValidateUnidadM = false;
                        }
                        //Unidad de medida
                        if(dataProducts[indexVar].POCH_Estatus__c != null && dataProducts[indexVar].POCH_Estatus__c !='' && dataProducts[indexVar].POCH_Estatus__c != strNA){
                            strEstaus = true;
                        }else{
                            msj +='<li type="disc"> Estatus o Diferente de -NA- <li/>' ;
                            strEstaus = false;
                        }
                    }
                    //lst += '</ul>';
                    if(msj == '' || msj == null || msj == undefined /*strValidateDescrip && strValidateCantPot && strValidateCantBase && strValidateUnidadM  && strEstaus*/){
                        //helper.UpdateRecords(component, event, helper); 
                        helper.validaAutorizacion(component, event, helper);
                        component.set("v.blnErrores", false);  
                    } else {
                        var errores = lst + msj + '</ul>';
                        component.set("v.blnErrores", true);  
                        component.set("v.strErrores", errores); 
                    }
                    button.set('v.disabled',false);
                }
            } else{
                console.log('--- Algo salio mal ---');
            }

        });
        $A.enqueueAction(action);        
    },
    Update: function(component, event, helper) {
        //helper.UpdateRecords(component, event, helper);
        var listIdProduct = new Array();
        var listMedidasRtn = new Array();
        var action = component.get("c.getUnidadesMedidas");
        let button = event.getSource();
        button.set('v.disabled',true);
      // alert('accion save u');
        var strsuc =  component.get("v.selectedLookUpRecord").Name;
        var dataProducts =  component.get("v.productList");
        var lst = '<ul> Falta :';
        var msj = '';
        var strNA= '-NA-';
        var strValidateDescrip = false;
        var strValidateCantPot = false;
        var strValidateCantBase = false;
        var strValidateUnidadM = false;
        var strAQuienCompra = false;
        var strEstaus = false;  
        var unidadMedidaCorrectaList = new Array();
        var numIteracion = 0;
        for (var i = 0; i < dataProducts.length; i++) {
            listIdProduct.push(dataProducts[i].POCH_Producto__c);
        }
        action.setParams({
            listIdProducto: listIdProduct
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let listResult = response.getReturnValue();
                if(listResult !== null && listResult !== undefined && listResult.length > 0){
                    for (var indexVar = 0; indexVar < dataProducts.length; indexVar++) {
                        for (i = 0; i < listResult.length; i++) {
                            if (dataProducts[indexVar].UnidadMedida__c != null && dataProducts[indexVar].UnidadMedida__c !='' && dataProducts[indexVar].UnidadMedida__c != strNA){
                                var idProd = listResult[i].substr(0,18);
                                var medida = listResult[i].substr(18);
                                if (idProd == dataProducts[indexVar].POCH_Producto__c && medida == dataProducts[indexVar].UnidadMedida__c.toUpperCase()){
                                    unidadMedidaCorrectaList[indexVar] = 1; 
                                    break; 
                                }else{
                                    unidadMedidaCorrectaList[indexVar] = 0; 
                                }
                            }
                        }
                    }
                    for (var indexVar = 0; indexVar < dataProducts.length; indexVar++) {
                        if(dataProducts[indexVar].Name != null && dataProducts[indexVar].Name !=''){
                            strValidateDescrip = true;
                        }else{
                            msj +='<li type="disc">Descripcion de producto </li>'  ;
                            strValidateDescrip = false;
                        }
                        if(dataProducts[indexVar].POCH_CantidadBase__c > 0  && dataProducts[indexVar].POCH_Estatus__c =='Inactivo'){
                            strValidateCantBase = false;
                            msj +='<li type="disc" > Si  Cantidad Base es  mayor a  cero(0) no puede estar Inactivo </li>  '  
                        }
                        if(dataProducts[indexVar].POCH_CantidadBase__c == 0  && dataProducts[indexVar].POCH_Estatus__c =='Activo'){
                            strValidateCantBase = false;
                            msj +='<li type="disc" > Si  Cantidad Base es cero(0) no puede estar Activo </li>  '  
                        }
                        //Cantidad potencial
                        if(dataProducts[indexVar].POCH_CantidadPotencial__c !== null && dataProducts[indexVar].POCH_CantidadPotencial__c !== '' 
                           && dataProducts[indexVar].POCH_CantidadPotencial__c !== undefined)
                        {
                            strValidateCantPot = true;
                        }else{
                            msj +='<li type="disc"> Cantidad potencial </li>' ;
                            strValidateCantPot = false;
                        }
                        //Cantidad Base
                        if(dataProducts[indexVar].POCH_CantidadBase__c !== null && dataProducts[indexVar].POCH_CantidadBase__c !== '' 
                           && dataProducts[indexVar].POCH_CantidadBase__c !== undefined)
                        {
                            strValidateCantBase = true;
                        }else{
                            msj +='<li type="disc"> Cantidad Base </li>' ;
                            strValidateCantBase = false;
                        }
                        //Unidad de medida
                        if(dataProducts[indexVar].POCH_UnidadMedida__c != null && dataProducts[indexVar].POCH_UnidadMedida__c !='' && dataProducts[indexVar].POCH_UnidadMedida__c != strNA){
                            if (unidadMedidaCorrectaList[indexVar] == 0){
                                msj += '<li type="disc"> Selecciona una unidad de medida válida código: ' + dataProducts[indexVar].POCH_Codigo__c + ' <li/>' ;
                                strValidateUnidadM = false;
                                unidadMedidaCorrectaList[indexVar] = 0;
                            }else{
                                strValidateUnidadM = true;
                            }
                        }else{
                            msj +='<li type="disc"> Unidad de Medida o Diferente de -NA- <li/>' ;
                            strValidateUnidadM = false;
                        }
                        //Unidad de medida
                        if(dataProducts[indexVar].POCH_Estatus__c != null && dataProducts[indexVar].POCH_Estatus__c !='' && dataProducts[indexVar].POCH_Estatus__c != strNA){
                            strEstaus = true;
                        }else{
                            msj +='<li type="disc"> Estatus o Diferente de -NA- <li/>' ;
                            strEstaus = false;
                        }
                    }
                    //lst += '</ul>';
                    if(msj == '' || msj == null || msj == undefined /*strValidateDescrip && strValidateCantPot && strValidateCantBase && strValidateUnidadM  && strEstaus*/){
                        helper.UpdateRecords(component, event, helper); 
                        component.set("v.blnErrores", false);  
                    }else{
                        var errores = lst + msj + '</ul>';
                        component.set("v.blnErrores", true);  
                        component.set("v.strErrores", errores); 
                    }
                    button.set('v.disabled',false);
                }
            } else{
                console.log('--- Algo salio mal ---');
            }

        });
        $A.enqueueAction(action); 

        
    },
    
    PicklistValuesReload: function(component, event, helper) {
        var listFrequency    = component.get("v.listFrecuencyQuoxProfile");
        var idInventorySheet = component.get("v.recordId");         
        var sizelist         = listFrequency.length;
        
        if(idInventorySheet != null && idInventorySheet != ''  && sizelist == '1') {
            helper.getPicklistDataxObject(component, event, helper); 
        }
        
    },
    quotationProcess : function(component, event, helper) { 
      //   alert('accion cotizar');
        if(!component.get("v.blnUpdatePrices")) {
            helper.handleQuotation(component, event, helper);    
        } else {
            helper.showToast('Warning', 'Atención!', 'Antes de generar una cotización, debe Actualizar los Precios');
        }        
    },
    updatePrices : function(component, event, helper) {
        //helper.getMedidasProduct(component, event, helper);
        var listaMedidas =  component.get("v.listUnidadesMedidas");        		                        
        helper.updatePrices_Helper(component, event, helper);
    }
    
})