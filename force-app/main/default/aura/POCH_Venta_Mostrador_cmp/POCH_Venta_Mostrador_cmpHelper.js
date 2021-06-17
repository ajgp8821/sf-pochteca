({
    assignParentId : function(component, event, helper) {
        var action = component.get("c.getSucursal");
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
        if(base64Context != '' && base64Context != null && base64Context != 'undefined' && base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }		
        if(base64Context) {
            var addressableContext = JSON.parse(window.atob(base64Context));   
            component.set("v.strIdAccount", addressableContext.attributes.recordId);
            this.getInfoAccount(component, event, helper);
            this.getCreditLine(component, event, helper);
            this.getConditionPago(component, event, helper);
            //this.createObjectCabecera(component, event);
            action.setParams({
                idAccount: component.get("v.strIdAccount")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    let sucursalId = response.getReturnValue();
                    if(sucursalId !== null && sucursalId !== undefined) {
                        component.set("v.strIdSucursal",sucursalId);
                        component.set('v.blnShowButtons', false);
                    }
                } else {
                    console.log("--- Algo salio mal ---");
                }
            });
            $A.enqueueAction(action);  
        }
    },
    
    showCabeceraVentaMostrador: function (component, event, helper) {
        var action = component.get("c.getCabeceraVentaMostrador");
        action.setParams({
            idCabeceraVentaMostrador: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let cabeceraVentas = response.getReturnValue();
                if(cabeceraVentas !== null && cabeceraVentas !== undefined) {
                    component.set("v.ventasMostrador",cabeceraVentas);
                    if (cabeceraVentas.Status__c == 'Cancelado' || cabeceraVentas.Enviado_SAP__c == true){
                        component.set('v.isStatusCancel', true);
                    }
                    this.getDescriptionPicklist(component, 'Ventas_Mostrador__c','CurrencyIsoCode');
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
    },
    
    showDetailVentaMostrador: function (component, event, helper) {
        var action = component.get("c.getDetailsVentaMostrador");
        action.setParams({
            idVentaMostrador: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let detalleVentastList = response.getReturnValue();
                if(detalleVentastList !== null && detalleVentastList !== undefined && detalleVentastList.length > 0) {
                    component.set("v.ventasMostradorList",detalleVentastList);
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
    },
    
    createObjectData: function(component, event) {
        // get the contactList from component and add(push) New Object to List  
        var RowItemList = component.get("v.ventasMostradorList");
        RowItemList.unshift({   //push
            sobjectType:'Venta_Mostrador_Detalle__c', 
            Material__c:'',
            Descto__c:'',
            Precio__c:'',
            Descripcion__c:'',
            POCH_Cantidad__c:'',
            UnidadMedida__c:'',
            Sucursal__c: ''
        });
        // set the updated list to attribute (contactList) again
        component.set("v.ventasMostradorList", RowItemList);
    },

    requiereActualizacion : function(component, event, helper) {        
    	let action = component.get('c.getDataInv');
            console.log(action); 
        action.setParams({
            'idInv': component.get('v.recordId')
        });
        action.setCallback(this,function(response){
                        console.log(response);
            if(response.getState() === 'SUCCESS') {
                //component.set('v.blnUpdatePrices', response.getReturnValue().RequiereActualizacion__c);     
                component.set('v.strIdAccount',    response.getReturnValue().POCH_Cuenta__c);
                component.set('v.strIdBranch',     response.getReturnValue().POCH_Sucursal__r.Name);
                console.log(action);
                
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
                        this.showToast('Warning', 'Advertencia!', "No cuenta con los permisos para agregar una venta en esta sucursal"); 
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

    getInfoAccount: function (component, event, helper) {
        var action = component.get("c.getAccount");
        action.setParams({
            idAccount: component.get("v.strIdAccount")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let cliente = response.getReturnValue();
                if(cliente !== null && cliente !== undefined) {
                    component.set("v.accountName", cliente.Name);
                    component.set("v.idSap", cliente.POCH_IDClienteSAP__c);
                    component.set("v.email", cliente.POCH_CorreoElectronico__c);
                    component.set("v.currency", cliente.CurrencyIsoCode);
                    this.getDescriptionPicklist(component, 'Accouunt','CurrencyIsoCode');
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
    },

    getCreditLine: function (component, event, helper) {
        var action = component.get("c.getCreditLine");
        action.setParams({
            idAccount: component.get("v.strIdAccount")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let creditLine = response.getReturnValue();
                if(creditLine !== null && creditLine !== undefined) {
                    component.set("v.creditLine", creditLine.POCH_SaldoDisponible__c);
                }else{
                    component.set("v.creditLine", "0");
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
    },

    getConditionPago: function (component, event, helper) {
        var action = component.get("c.getConditionPago");
        action.setParams({
            idAccount: component.get("v.strIdAccount")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let conditionP = response.getReturnValue();
                if(conditionP !== null && conditionP !== undefined) {
                    component.set("v.conditionPago", conditionP);
                }
            } else {
                console.log("--- Algo salio mal ---");
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
            	//
                if (listOneLevel != undefined && listOneLevel.length > 0) {
                    ControllerFieldOneLevel.push('-NA-');        
                }
                
                for (var i = 0; i < listOneLevel.length; i++) {
                    ControllerFieldOneLevel.push(listOneLevel[i]);
                } 
                if(StrnNameField == 'Via_de_pago__c'){
                    component.set("v.listViaPago", ControllerFieldOneLevel);
                }
                if(StrnNameField == 'Metodo_de_Pago__c'){
                    component.set("v.listMetPago", ControllerFieldOneLevel);
                }
                if(StrnNameField == 'CurrencyIsoCode'){
                    component.set("v.listMoneda", ControllerFieldOneLevel);
                    
                }
                if(StrnNameField == 'Uso_de_CFDI__c'){
                    component.set("v.listCFDI", ControllerFieldOneLevel);
                    
                }
                
            }
        });
        $A.enqueueAction(action);
    },

    getDescriptionPicklist: function (component, StrObject,StrnNameField) {
        var isNewRecord = component.get("v.blnRecordExisteShowDetail");
        var regCabecera = component.get("v.ventasMostrador");
        var action = component.get("c.getDescription");
        var listApiField = new Array();
        if (isNewRecord){
            listApiField.push(regCabecera.CurrencyIsoCode);     
        } else {
            listApiField.push(component.get("v.currency"));    
        }
        listApiField.push(component.get("v.currency"));
        action.setParams({
            objectType: 'Ventas_Mostrador__c',
            selectedField: 'CurrencyIsoCode',
            listApiField: listApiField
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let labelPicklist = response.getReturnValue();
                if(labelPicklist !== null && labelPicklist !== undefined && labelPicklist.length > 0) {
                    for (let index = 0; index < labelPicklist.length; index++) {
                        if (isNewRecord){
                            regCabecera.CurrencyIsoCode = labelPicklist[index];
                            component.set("v.ventasMostrador", regCabecera);       
                        } else {
                            component.set("v.currency", labelPicklist[index]);  
                        }
                        
                    }
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
    },

    calcularTotales: function (component, StrObject,StrnNameField) {
        var action = component.get("c.getRates");
        var detalleVentaMostrador =  component.get("v.ventasMostradorList");
        var ventaMostrador =  component.get("v.ventasMostrador");
        var sumatoriaDescuento = 0;
        var sumatoriaValorNeto = 0;
        var subTotal = 0;
        action.setParams({

        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let listRates = response.getReturnValue();
                if(listRates !== null && listRates !== undefined && listRates.length > 0) {
                    sumatoriaDescuento = sumatoriaDescuento + detalleVentaMostrador.Descuento_Monto__c;
                    for (var indexVar = 0; indexVar < detalleVentaMostrador.length; indexVar++) {
                        if (detalleVentaMostrador.CurrencyIsoCode == ventaMostrador.CurrencyIsoCode){
                            sumatoriaValorNeto = sumatoriaValorNeto + detalleVentaMostrador.Descuento_Monto__c;
                        }else{
                            for (var i = 0; i < listRates.length; i++) {
                                if (listRates[i].substr(0,2) == detalleVentaMostrador[indexVar]){
                                    sumatoriaValorNeto = sumatoriaValorNeto + (detalleVentaMostrador.Descuento_Monto__c / listRates[i].substr(3));
                                }
                            }
                        }
                    }
                    ventaMostrador.Descuento__c = sumatoriaDescuento;
                    ventaMostrador.Valor_Neto__c = sumatoriaValorNeto;
                    subTotal = sumatoriaValorNeto - sumatoriaDescuento;
                    ventaMostrador.Subtotal__c = subTotal;
                    component.set("v.ventasMostrador", ventaMostrador);
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
        
    }
})