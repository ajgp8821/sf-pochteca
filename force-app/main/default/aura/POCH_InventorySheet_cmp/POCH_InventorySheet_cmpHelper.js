({
    getPicklistDataxObject : function(component, event) {
            var action = component.get("c.getDataPickListValues");  
            action.setParams({
                'strObject': 'POCH_FrecuenciaCotizacion__mdt'
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.listFrecuencyQuoxProfile",response.getReturnValue());
                }else{
                    console.log('--- Algo salio mal ---');
                }
            });
            $A.enqueueAction(action);   
    },
	createObjectData: function(component, event) {
        // get the contactList from component and add(push) New Object to List  
        var RowItemList = component.get("v.productList");
        RowItemList.unshift({   //push
            'sobjectType':'POCH_DetalleInventario__c',
            'POCH_Producto__c':'',
            'POCH_Sucursal__c' : '',
            'Name':'',
            'POCH_Codigo__c':'',
            'POCH_CantidadPotencial__c': '',
            'POCH_CantidadBase__c':'',
            'POCH_UnidadMedida__c':'',                                    
            'POCH_Moneda__c':'',
            'POCH_PrecioLista__c':'',
            'POCH_EsPotencial__c':'',
            'POCH_EsBase__c':'',
            'POCH_AquienCompra__c':'',
            'POCH_Estatus__c':'',
            'POCH_Notas__c':'',
            //'POCH_MonedaCompetencia__c':'',
            'POCH_CantidadCompetencia__c':'',
            'POCH_HojaInventario__c':'',
            'POCH_uma__c':'',
            'Moneda_competencia__c':''            
        });
        // set the updated list to attribute (contactList) again
        component.set("v.productList", RowItemList);
    },
    saveRecords : function(component, event, helper) {
        var isfrecuencyQuote = component.get("v.strFrecuencyQuot"); 
        var AllRowsList = component.get("v.productList");
        var IdSucursalSelected = component.get("v.selectedLookUpRecord").Poch_Sucursal__r.Id;
        var idAccount = component.get("v.strIdAccount");
        var action = component.get("c.insertValuesDetailProduct");
        action.setParams({
            'strFrecuencyQuote': isfrecuencyQuote,
            'lstproducts' : AllRowsList,
            'idBranchOffice' : IdSucursalSelected,
            'strIdAccountRelated' : idAccount,
            'blnIsUpdate' : false,
            'strIdRecordSheetInve':''
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
            let data =response.getReturnValue(); 
                if(data && data ===  'OK') {
                    this.showToast('success', 'Success!', $A.get("$Label.c.POCH_nuevaHoja"));
                    var navigateEvent = $A.get("e.force:navigateToSObject");
                    navigateEvent.setParams({ "recordId": component.get('v.strIdAccount') });
                    navigateEvent.fire();      
                } else if(data && data ===  'ERROR') {
                    this.showToast('Warning', 'Warning!', 'Ya existe un Inventario del Cliente para esta sucursal.');         
                } else {
                    alert('Error al guardar.');
                }
            }else{
                console.log('--- Algo salio mal ---');
            }
        });
        $A.enqueueAction(action); 
    },
    showDetailSheetInventory : function(component, event, helper) {
        var action = component.get("c.getDetailsInventorySheet");
        var action2 = component.get("c.getDescription");
        var listMonedas = new Array();
        
        var contador = 0;
        var contador2 = 0;
        action.setParams({
            'idSheetDetail' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                let productList = response.getReturnValue();
                if(productList !== null && productList !== undefined && productList.length > 0) {
                    //component.set("v.productList",productList); 
                    component.set("v.strIdBranch",component.get("v.simpleRecord.POCH_Sucursal__r.Name"));                               
                    component.set("v.strIdAccount",productList[0].POCH_HojaInventario__r.POCH_Cuenta__c);
                    component.set("v.listFrecuencyQuoxProfile",component.get("v.strFrecuencyQuot"));
                    for(var i = 0; i < productList.length; i++){
                        if (productList[i].Moneda_competencia__c != null){
                            listMonedas.push(productList[i].Moneda_competencia__c);
                            contador++;
                        } 
                    }
                    if (contador > 0){
                        action2.setParams({
                            objectType: "POCH_DetalleInventario__c",
                            selectedField: "Moneda_competencia__c",
                            listApiField: listMonedas
                        });
                        action2.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") { 
                                let listMonedasDescr = response.getReturnValue(); 
                                if(listMonedasDescr !== null && listMonedasDescr !== undefined && listMonedasDescr.length > 0) {
                                    for (var i = 0; i < listMonedasDescr.length; i++) {
                                        for(var j = 0; j < productList.length; j++){
                                            if (productList[j].Moneda_competencia__c == listMonedasDescr[i].substr(0,3)){
                                                productList[j].Moneda_competencia__c = listMonedasDescr[i];
                                                contador2++;
                                            } 
                                        }
                                    }
                                    if (contador2 > 0){
                                        component.set("v.productList",productList);
                                    }
                                }
                            }else{
                                console.log('--- Algo salio mal ---');
                            }

                        });
                        $A.enqueueAction(action2);
                    }else{
                        component.set("v.productList",productList); 
                    }
                }
            }else{
                console.log('--- Algo salio mal ---');
            }
        });
        $A.enqueueAction(action); 
    },
    UpdateRecords :function(component, event, helper) {
        
        var isfrecuencyQuote = component.get("v.strFrecuencyQuot"); 
        var AllRowsList = component.get("v.productList");
        var IdSucursalSelected = component.get("v.selectedLookUpRecord").Poch_Sucursal__c;
        var idAccount = component.get("v.strIdAccount");

        var action = component.get("c.insertValuesDetailProduct");
        for (var i = 0; i < AllRowsList.length; i++) {
            if (AllRowsList[i].Moneda_competencia__c == '-NA-'){
                AllRowsList[i].Moneda_competencia__c = null;    
            } else{
                var cadena = AllRowsList[i].Moneda_competencia__c.substr(0,3);
                AllRowsList[i].Moneda_competencia__c = cadena;
            }
            
            
        }
        action.setParams({
            'strFrecuencyQuote': isfrecuencyQuote,            
            'lstproducts' : AllRowsList,
            'idBranchOffice' : IdSucursalSelected,
            'strIdAccountRelated' : idAccount,
            'blnIsUpdate' :true,
            'strIdRecordSheetInve' : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let data=response.getReturnValue();
                if(data ===  'OK'){
                    this.showToast('success', 'Success!', 'Inventario guardado correctamente');    
                    
                    var navigateEvent = $A.get("e.force:navigateToURL");
                    navigateEvent.setParams({"url": "https://pochteca.lightning.force.com/lightning/r/"+ idAccount +"/related/Hojas_inventario__r/view"});
                    //navigateEvent.setParams({"url": "https://pochteca--dev.lightning.force.com/lightning/r/"+ idAccount +"/related/Hojas_inventario__r/view"});
                    navigateEvent.fire();
                } else if(data && data ===  'ERROR') {
                    this.showToast('Warning', 'Warning!', 'Ya existe un Inventario del Cliente para esta sucursal.');         
                } else {
                    alert('Error al guardar. ');
                }
            } else{
                console.log('--- Algo salio mal ---');
            }

        });
        $A.enqueueAction(action); 
    },
    assignParentId : function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
        if(base64Context != '' && base64Context != null && base64Context != 'undefined' && base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }		
        if(base64Context) {
            var addressableContext = JSON.parse(window.atob(base64Context));   
            component.set("v.strIdAccount", addressableContext.attributes.recordId);  
        }
    },
    handleQuotation: function(component, event, helper) {
        let button = event.getSource();
        button.set('v.disabled',true);
        
        let action = component.get('c.quoteCurrentSheet');
        let accountId = component.get('v.strIdAccount');
        let sheetId = component.get("v.recordId"); 
        let isBatch = "false";
        action.setParams({
            'accountId': accountId ,
            'sheetId': sheetId,
            'isBatch': isBatch
        });
        action.setCallback(this,function(response){
            let state=response.getState();
            if(state === 'SUCCESS') {
                console.log('**response.getReturnValue() '+response.getReturnValue());
                if(response.getReturnValue().includes('ERROR')) {
                    console.log("--> 1");
                    this.showToast('Error', 'Error!', response.getReturnValue().includes('activo') ? response.getReturnValue() : 'Algo ha salido mal. \n' + response.getReturnValue());
                    button.set('v.disabled',false);
                } else {
                    //let message = response.getReturnValue() === 'ERROR' ? 'Error' : 'Success';  
                    this.showToast('success', 'Success!', $A.get("$Label.c.POCH_cotizacionGenerada"));
                    if(response.getReturnValue().includes('Opportunities')) {
                        console.log("--> 2");
                        let urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({"url": response.getReturnValue()});
                        urlEvent.fire(); 
                    } else {
                        let opportunityId = response.getReturnValue();
                        if(opportunityId && opportunityId !== 'ERROR') {
                            console.log("--> 3");
                            var navigateEvent = $A.get("e.force:navigateToSObject");
                            navigateEvent.setParams({ "recordId": opportunityId });
                            navigateEvent.fire();      
                        } 
                    }                                          
                }                                
            }
            else {                
                this.showToast('Error', 'Error!', 'Algo ha salido mal.');
            }
        });
        $A.enqueueAction(action);
    },
    updatePrices_Helper : function(component, event, helper) {                
        let lstItems = component.get('v.productList');
        let strSuc   = component.get('v.strIdBranch');
        let strAcc   = component.get('v.strIdAccount');        
        for (var i = 0; i < lstItems.length; i++) {
            if (lstItems[i].Moneda_competencia__c == '-NA-'){
                lstItems[i].Moneda_competencia__c = null;
            }else{
                var cadena = lstItems[i].Moneda_competencia__c.substr(0,3);
                lstItems[i].Moneda_competencia__c = cadena;
            }
            
        }
        let action = component.get('c.actualizaPreciosItems');
        action.setParams({
            'lItems': lstItems ,
            'idSuc' : strSuc,
            'idAcc' : strAcc
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
                this.showToast('success', 'Success!', "Los precios han sido actualizados correctamente");         
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    requiereActualizacion : function(component, event, helper) {        
    	let action = component.get('c.getDataInv');
        action.setParams({
            'idInv': component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
                component.set('v.blnUpdatePrices', response.getReturnValue().RequiereActualizacion__c);     
                component.set('v.strIdAccount',    response.getReturnValue().POCH_Cuenta__c);
                component.set('v.strIdBranch',     response.getReturnValue().POCH_Sucursal__r.Name);
                
                helper.validaAutorizacion(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    validaAutorizacion : function(component, event, helper) {
        let action = component.get('c.getAutorizacion');
        var action3 = component.get("c.getAccesDetalle");
        var listIdDetalleInventario = new Array();
        action.setParams({
            'idSuc': component.get('v.strIdBranch')
        });
        action.setCallback(this,function(response) {
            if(response.getState() === 'SUCCESS') {
                component.set('v.blnShowButtons', response.getReturnValue()); 
                if(component.get('v.blnRecordExisteShowDetail') === false) {
                    if(response.getReturnValue() === true){
                        this.showToast('Warning', 'Advertencia!', "No cuenta con los permisos para agregar un Inventario en esta sucursal"); 
                    } else if(response.getReturnValue() === false) {
                        helper.UpdateRecords(component, event, helper);
                    }
                }
                let listProduct = component.get('v.productList');
                for(var i = 0; i < listProduct.length; i++){
                    listIdDetalleInventario.push(listProduct[i].Id);
                }
                action3.setParams({
                    listIdDetalleInventario : listIdDetalleInventario                    
                });
                action3.setCallback(this, function(response) {
                    var state = response.getState();
                    var state2;
                    if (state === "SUCCESS") {
                        state2 = response.getReturnValue();
                        if (state2){
                            component.set('v.blnShowButtons', true);
                        }
                    }else{
                        console.log('--- Algo salio mal ---');
                    }
                });
                $A.enqueueAction(action3);                                  
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(tipomsj,titlemsj,Mensaje) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": tipomsj,
            "title": titlemsj,
            "message": Mensaje
        });
        toastEvent.fire();        
    }
})