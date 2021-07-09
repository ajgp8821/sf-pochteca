({
    assignParentId : function(component, event, helper) {
        // var action = component.get("c.getSucursal");
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
        if(base64Context != '' && base64Context != null && base64Context != 'undefined' && base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }		
        if(base64Context) {
            var addressableContext = JSON.parse(window.atob(base64Context));   
            component.set("v.strIdAccount", addressableContext.attributes.recordId);
            if (component.get("v.strIdAccount") != null || component.get("v.strIdAccount") != '' || component.get("v.strIdAccount") != undefined) {
                this.createObjectDataCabecera(component, event);
            }
            this.getSucursal(component, event);
            this.getInfoAccount(component, event, helper);
            this.getCreditLine(component, event, helper);
            this.getConditionPago(component, event, helper);
            // action.setParams({
            //     idAccount: component.get("v.strIdAccount")
            // });
            // action.setCallback(this, function (response) {
            //     component.set("v.showSpinner", true);
            //     var state = response.getState();
            //     if (state === "SUCCESS") {
            //         let sucursal = response.getReturnValue();
            //         if(sucursal !== null && sucursal !== undefined) {
            //             component.set("v.strIdSucursal",sucursal.Id);
            //             component.set('v.blnShowButtons', false);
            //             component.set("v.organizacionVentas",sucursal.POCH_OrganizacionVentas__c);
            //         }
            //     } else {
            //         console.log("--- Algo salio mal ---");
            //     }
            //     component.set("v.showSpinner", false);
            // });
            // $A.enqueueAction(action);  
        }
    },

    getSucursal: function (component, event) {
        var action = component.get("c.getSucursal");
        if (component.get("v.strIdAccount")){
            var account = component.get("v.strIdAccount");
        }else{
            var account = component.get("v.ventasMostrador.Cliente__c");
        }
        action.setParams({
            idAccount: account
        });
        action.setCallback(this, function (response) {
            // component.set("v.showSpinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                let sucursal = response.getReturnValue();
                if(sucursal !== null && sucursal !== undefined) {
                    component.set("v.strIdSucursal",sucursal.Id);
                    component.set('v.blnShowButtons', false);
                    component.set("v.organizacionVentas",sucursal.POCH_OrganizacionVentas__c);
                    component.set("v.oficinaVentas",sucursal.POCH_OficinaVentas__c);
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
            // component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    showCabeceraVentaMostrador: function (component, event, helper) {
        var action = component.get("c.getCabeceraVentaMostrador");
        action.setParams({
            idCabeceraVentaMostrador: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            console.log("showCabeceraVentaMostrador");
            var state = response.getState();
            if (state === "SUCCESS") {
                let cabeceraVentas = response.getReturnValue();
                if(cabeceraVentas !== null && cabeceraVentas !== undefined) {
                    component.set("v.ventasMostrador",cabeceraVentas);
                    component.set("v.strIdAccount", cabeceraVentas.Cliente__c);
                    component.set("v.organizacionVentas", cabeceraVentas.OrganizacionVentas__c);
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

    validateCurrency: function(component, event) {
        var listIdProduct = new Array();
        var unidadMedidaCorrectaList = new Array();
        var lst = '<ul> Falta :';
        var msj = '';
        var strValidateUnidadM = false;
        var dataProducts =  component.get("v.ventasMostradorList");
        var idVentasMostrador =  component.get("v.recordId"); 
        // TODO: Validar dataProducts > 0
        for (var i = 0; i < dataProducts.length; i++) {
            listIdProduct.push(dataProducts[i].Product__c);
        }

        var action = component.get("c.getUnidadesMedidas");
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
                            if (dataProducts[indexVar].UnidadMedida__c != null && dataProducts[indexVar].UnidadMedida__c !=''){
                                var idProd = listResult[i].substr(0,18);
                                var medida = listResult[i].substr(18);
                                if (idProd == dataProducts[indexVar].Product__c && medida == dataProducts[indexVar].UnidadMedida__c.toUpperCase()){
                                    unidadMedidaCorrectaList[indexVar] = 1; 
                                    break;      
                                }else{
                                    unidadMedidaCorrectaList[indexVar] = 0; 
                                }
                            }     
                        }
                    }
                    
                    for (var indexVar = 0; indexVar < dataProducts.length; indexVar++) {
                        //Unidad de medida
                        if(dataProducts[indexVar].UnidadMedida__c != null && dataProducts[indexVar].UnidadMedida__c !=''){
                            if (unidadMedidaCorrectaList[indexVar] == 0){
                                msj += '<li type="disc"> Selecciona una unidad de medida válida Material: ' + dataProducts[indexVar].Material__c + ' <li/>' ;
                                strValidateUnidadM = false;
                                unidadMedidaCorrectaList[indexVar] = 0;
                            }else{
                                strValidateUnidadM = true;
                            }
                        }
                        if (dataProducts[indexVar].Precio__c == 0){
                            msj += '<li type="disc"> precio no puede ser igual a cero, material: ' + dataProducts[indexVar].Material__c + ' <li/>' ;
                            strValidateUnidadM = false;
                        }
                        if (dataProducts[indexVar].Product__c == null || dataProducts[indexVar].Product__c == '' ){
                            msj += '<li type="disc"> No puede guardar sin seleccionar un producto:  <li/>' ;
                        }
                    }
                    //lst += '</ul>';
                    if(msj == '' || msj == null || msj == undefined){

                        var StrnNameField = component.get("v.ventasMostrador.CurrencyIsoCode");
                        if (StrnNameField != "Dólar de EE.UU." && StrnNameField != "U.S. Dollar") {
                            var action = component.get("c.validarCurrency");
                            var idAccount = component.get("v.ventasMostrador.Cliente__c");
                            StrnNameField = component.get("v.ventasMostrador.CurrencyIsoCode");
                            action.setParams({
                                idAccount: idAccount,
                                moneda: StrnNameField,
                                notIsApiField: true,
                                objectType: 'Ventas_Mostrador__c',
                                selectedField: 'CurrencyIsoCode'
                            });
                            action.setCallback(this, function(response) {
                                if (response.getState() == "SUCCESS") {
                                    var StoreResponse =  response.getReturnValue();
                                    if(StoreResponse == false){
                                        msj +=' Moneda no permitida'
                                        var errores =  msj;
                                        //component.set("v.blnErrores", true);  
                                        // component.set("v.strErrores", errores); //
                                        //component.set('v.blnShowButtons',true);
                                        this.showToast('Error', 'Error!', msj);
                                        component.set("v.strErrores", null);
                                    }
                                    else {
                                        // this.sa
                                        //this.validationsSap(component, event);
                                        component.set("v.blnErrores", false);
                                        component.set("v.strErrores", null);
                                        if (idVentasMostrador != null && idVentasMostrador != "") {
                                            this.updateVentasMostrador(component, event, true);
                                        }
                                        else {
                                            this.saveVentasMostrador(component, event, true);
                                        }
                                    }
                                }
                            });
                            $A.enqueueAction(action);            
                        }
                        else {
                            this.validationsSap(component, event);
                        }
                        // Llamar al metodo de insertar o actualizar
                        //component.set("v.blnErrores", false);
                        
                    } else {
                        var errores = lst + msj + '</ul>';
                        component.set("v.blnErrores", true);  
                        component.set("v.strErrores", errores);
                    }
                    button.set('v.disabled',false);
                }
            } else{
                console.log('--- Algo salio mal ---');
                component.set("v.strErrores", "");
            }

        });
        $A.enqueueAction(action);
    },


    createObjectDataCabecera: function(component, event) {
        var RowItemList = component.get("v.ventasMostradorListTemp");
        RowItemList.unshift({    //push
            sobjectType:'Ventas_Mostrador__c', 
            Name: '',
            Cliente__c: component.get("v.strIdAccount"),
            Name_Cliente__c: '',
            Id_cliente_SAP__c: '',
            CurrencyIsoCode: '',
            Email__c: '',
            Credito_disponible__c: '',
            Digitos_tarjeta__c: '',
            Via_de_pago__c: '',
            Condicion_de_Pago__c: '',
            Metodo_de_Pago__c: '',
            Metodo_de_Pago2__c: '',
            Metodo_de_Pago3__c: '',
            Importe__c: 0,
            Importe_2__c: 0,
            Importe_3__c: 0,
            Obs_Pago__c: '',
            Obs_Pago_2__c: '',
            Obs_Pago_3__c: '',
            Valor_Neto__c: 0,
            Descuento__c: 0,
            Subtotal__c: 0,
            IVA__c: 0,
            Precio_total__c: 0,
            Id_Registro_SAP__c: '',
            Status__c: '',
            POCH_Sucursal__c: '',
            Uso_de_CFDI__c: '',
            Enviado_SAP__c: '',
            Oficina_de_Venta__c: '',
            OrganizacionVentas__c: ''
        });
        component.set("v.ventasMostrador", RowItemList[0]);
    },
    
    createObjectData: function(component, event) {
        // get the contactList from component and add(push) New Object to List  
        var RowItemList = component.get("v.ventasMostradorList");
        RowItemList.unshift({   //push
            sobjectType:'Venta_Mostrador_Detalle__c', 
            Material__c:'',
            Descto__c: 0.0,
            Precio__c: 0.0,
            Descripcion__c:'',
            POCH_Cantidad__c: 0,
            UnidadMedida__c:'',
            Sucursal__c: '',
            POCH_Centro__c: '',
            Almacen__c: '',
            Valor_neto__c: 0.0,
            IVA__c: 0.0,
            Product__c: '',
            Stock__c: 0,
            Stock_Consignacion__c: 0,
            Status__c:'Creado',
            Margen__c: 0.0
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
                    var ventaMostrador = component.get("v.ventasMostrador");
                    ventaMostrador.Name_Cliente__c = cliente.Name;
                    ventaMostrador.Id_cliente_SAP__c = cliente.POCH_IDClienteSAP__c;
                    ventaMostrador.Email__c = cliente.POCH_CorreoElectronico__c;
                    ventaMostrador.CurrencyIsoCode = cliente.CurrencyIsoCode;
                    // component.set("v.accountName", cliente.Name);
                    // component.set("v.idSap", cliente.POCH_IDClienteSAP__c);
                    // component.set("v.email", cliente.POCH_CorreoElectronico__c);
                    // component.set("v.currency", cliente.CurrencyIsoCode);
                    component.set("v.ventasMostrador", ventaMostrador);
                    if (cliente.POCH_ClasificacionFiscal__c == 0){
                        component.set("v.isExento", true);
                    }
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
                    var ventaMostrador = component.get("v.ventasMostrador");
                    ventaMostrador.Credito_disponible__c = creditLine.POCH_SaldoDisponible__c;
                    component.set("v.ventasMostrador", ventaMostrador);

                    // component.set("v.creditLine", creditLine.POCH_SaldoDisponible__c);

                }else{
                    var ventaMostrador = component.get("v.ventasMostrador");
                    ventaMostrador.Credito_disponible__c = 0;
                    component.set("v.ventasMostrador", ventaMostrador);
                    // component.set("v.creditLine", "0");
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
                    var ventasMostrador = component.get("v.ventasMostrador");
                    ventasMostrador.Condicion_de_Pago__c = conditionP;
                    component.set("v.ventasMostrador", ventaMostrador);

                    // component.set("v.conditionPago", conditionP);
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
    },

    getPicklistValuesOneLevel: function(component,StrObject,StrnNameField) {
        var isNewRecord = component.get("v.blnRecordExisteShowDetail");
        var action = component.get("c.PickListValuesIntoList");
        component.set("v.showSpinner", true);
        action.setParams({
            objectType: StrObject,
            selectedField: StrnNameField
        });
        action.setCallback(this, function(response) {
            component.set("v.showSpinner", true);
            if (response.getState() == "SUCCESS") {
                var StoreResponse =  response.getReturnValue();
                
                var listOneLevel =  [];
                var ControllerFieldOneLevel = [];
                
                for (var i = 0; i < StoreResponse.length; i++) {
                    listOneLevel.push(StoreResponse[i]);
                    if (isNewRecord == false){
                        if (StoreResponse[i] == "Por definir"){
                            component.set("v.ventasMostrador.Via_de_pago__c", StoreResponse[i]);
                        } 
                        if (StoreResponse[i] == "G01 Adquisición de mercancias"){
                            component.set("v.ventasMostrador.Uso_de_CFDI__c", StoreResponse[i]);
                        }    
                    }
                }  
            	if(StrnNameField == 'Metodo_de_Pago__c' && isNewRecord == false){
                    if (listOneLevel != undefined && listOneLevel.length > 0) {
                        ControllerFieldOneLevel.push('');        
                    }
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
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
        component.set("v.showSpinner", false);
    },

    getDescriptionPicklist: function (component, StrObject,StrnNameField) {
        var isNewRecord = component.get("v.blnRecordExisteShowDetail");
        var regCabecera = component.get("v.ventasMostrador");
        var action = component.get("c.getDescription");
        var listApiField = new Array();
        // if (isNewRecord){
            listApiField.push(regCabecera.CurrencyIsoCode);     
        // } else {
        //     listApiField.push(component.get("v.currency"));    
        // }
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
                        // if (isNewRecord){
                            regCabecera.CurrencyIsoCode = labelPicklist[index];
                            component.set("v.ventasMostrador", regCabecera);       
                        // } else {
                        //     // var ventaMostrador = component.get("v.ventasMostrador");
                        //     regCabecera.CurrencyIsoCode = labelPicklist[index];
                        //     component.set("v.ventasMostrador", regCabecera);

                        //     // component.set("v.currency", labelPicklist[index]);  
                        // }
                        
                    }
                }
            } else {
                console.log("--- Algo salio mal ---");
            }
        });
        $A.enqueueAction(action);
    },

    calcularTotales: function (component, StrObject,StrnNameField) {
        var isNewRecord = component.get("v.blnRecordExisteShowDetail");
        var detalleVentaMostrador =  component.get("v.ventasMostradorList");
        var ventaMostrador =  component.get("v.ventasMostrador");
        var sumatoriaIVA = 0;
        var sumatoriaDescuento = 0;
        var sumatoriaValorNeto = 0;
        var exento = component.get("v.isExento");   
        for (var indexVar = 0; indexVar < detalleVentaMostrador.length; indexVar++) {
            if (detalleVentaMostrador[indexVar].Descuento_Monto__c == null || detalleVentaMostrador[indexVar].Descuento_Monto__c == ""){
                detalleVentaMostrador[indexVar].Descuento_Monto__c = 0; 
            }
            sumatoriaDescuento = sumatoriaDescuento + parseFloat(detalleVentaMostrador[indexVar].Descuento_Monto__c);
            sumatoriaValorNeto = sumatoriaValorNeto + parseFloat(detalleVentaMostrador[indexVar].Valor_neto__c);
            if (exento == false){
                sumatoriaIVA = sumatoriaIVA + parseFloat(detalleVentaMostrador[indexVar].IVA__c);              
            }
        }
        /*if(isNaN(sumatoriaDescuento) || isNaN(sumatoriaDescuento) || isNaN(sumatoriaIVA)) {
            ventaMostrador.Descuento__c = 0;
            ventaMostrador.Valor_Neto__c = 0;
            ventaMostrador.Subtotal__c = 0;
            ventaMostrador.IVA__c = 0;
            ventaMostrador.Precio_total__c = 0;
        }
        else {*/
            ventaMostrador.Descuento__c = sumatoriaDescuento;
            ventaMostrador.Valor_Neto__c = sumatoriaValorNeto;
            ventaMostrador.Subtotal__c = sumatoriaValorNeto - sumatoriaDescuento;
            ventaMostrador.IVA__c = sumatoriaIVA;
            ventaMostrador.Precio_total__c = ventaMostrador.Subtotal__c + ventaMostrador.IVA__c;
            ventaMostrador.Precio_total__c = Math.round(ventaMostrador.Precio_total__c * 100) / 100;
            component.set("v.ventasMostrador", ventaMostrador);
        //}















        
        /*var currencyAux = "";
        action2.setParams({
            objectType: 'Ventas_Mostrador__c',
            selectedField: 'CurrencyIsoCode',
            apiLabel: ventaMostrador.CurrencyIsoCode
        });
        action2.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                currencyAux =  response.getReturnValue();
                action.setParams({
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        let listRates = response.getReturnValue();
                        if(listRates !== null && listRates !== undefined && listRates.length > 0) {
                            
                            for (var indexVar = 0; indexVar < detalleVentaMostrador.length; indexVar++) {
                                sumatoriaDescuento = sumatoriaDescuento + detalleVentaMostrador[indexVar].Descuento_Monto__c;
                                if (detalleVentaMostrador[indexVar].CurrencyIsoCode == currencyAux){
                                    sumatoriaValorNeto = sumatoriaValorNeto + detalleVentaMostrador[indexVar].Valor_neto__c;
                                    if (exento == false){
                                        sumatoriaIVA = sumatoriaIVA + detalleVentaMostrador[indexVar].IVA__c;              
                                    }
                                    
                                }else{
                                    for (var i = 0; i < listRates.length; i++) {
                                        var temp = listRates[i].substr(0,3);
                                        var temp2 = listRates[i].substr(3);
                                        var temp3 = detalleVentaMostrador[indexVar].CurrencyIsoCode;
                                        //if (listRates[i].substr(0,3) == detalleVentaMostrador[indexVar].CurrencyIsoCode){
                                        if (listRates[i].substr(0,3) == currencyAux){
                                            sumatoriaValorNeto = sumatoriaValorNeto + (detalleVentaMostrador[indexVar].Valor_neto__c * listRates[i].substr(3));
                                            if (exento == false){
                                                sumatoriaIVA = sumatoriaIVA + (detalleVentaMostrador[indexVar].IVA__c / listRates[i].substr(3));              
                                            }
                                        }
                                    }
                                }
                            }
                            if(isNaN(sumatoriaDescuento) || isNaN(sumatoriaDescuento) || isNaN(sumatoriaIVA)) {
                                ventaMostrador.Descuento__c = 0;
                                ventaMostrador.Valor_Neto__c = 0;
                                ventaMostrador.Subtotal__c = 0;
                                ventaMostrador.IVA__c = 0;
                                ventaMostrador.Precio_total__c = 0;
                            }
                            else {
                                ventaMostrador.Descuento__c = sumatoriaDescuento;
                                ventaMostrador.Valor_Neto__c = sumatoriaValorNeto;
                                ventaMostrador.Subtotal__c = sumatoriaValorNeto - sumatoriaDescuento;
                                ventaMostrador.IVA__c = sumatoriaIVA;
                                ventaMostrador.Precio_total__c = ventaMostrador.Subtotal__c + ventaMostrador.IVA__c;
                            }

                            component.set("v.ventasMostrador", ventaMostrador);
                        }
                    } else {
                        console.log("--- Algo salio mal ---");
                    }
                });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(action2);*/
        
    },

    getApiName: function(component,StrObject,StrnNameField, label) {
        
        var action = component.get("c.getApiName"); 
        action.setParams({
            objectType: StrObject,
            selectedField: StrnNameField,
            apiLabel: label
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var StoreResponse =  response.getReturnValue();
                var ventaMostrador =  component.get("v.ventasMostrador");
                if(StrnNameField == 'CurrencyIsoCode'){
                    this.validarCurrency(component, StoreResponse);
                    ventaMostrador.CurrencyIsoCode = StoreResponse
                }
                component.set("v.ventasMostrador", ventaMostrador)
            }
        });
        $A.enqueueAction(action);
    },

    validarCurrency: function(component,StrnNameField, notIsApiField, objectType, selectedField) {
        var action = component.get("c.validarCurrency"); 
        var msj = '';
        var lst = '<ul> Error :';
        var noNewRecord = component.get("v.blnRecordExisteShowDetail");
        //if (noNewRecord){
            var idAccount = component.get("v.ventasMostrador.Cliente__c")
            //var idAccount = aux.Cliente__c;
        //}else {
        //    var idAccount = component.get("v.strIdAccount");
        //}
        action.setParams({
            idAccount: idAccount,
            moneda: StrnNameField,
            notIsApiField: notIsApiField,
            objectType: objectType,
            selectedField: selectedField
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var StoreResponse =  response.getReturnValue();
                if(StoreResponse == false){
                    msj +=' Moneda no permitida'
                    var errores =  msj;
                    //component.set("v.blnErrores", true);  
                    //component.set("v.strErrores", errores);
                    //component.set('v.blnShowButtons',true);
                    this.showToast('Error', 'Error!', msj);
                }
                
            }
        });
        $A.enqueueAction(action);
    },

    closeFocusedTab : function(component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    cancelVentasMostrador: function(component, event) {
        component.set("v.showSpinner", true);
        let action = component.get('c.calcelVentasMostrador');
        action.setParams({
            "ventasMostrador": component.get("v.ventasMostrador")
        });
        action.setCallback(this, function(response) {
            
            if (response.getState() == "SUCCESS") {
                if (response.getReturnValue() == true){
                    this.showToast('success', 'Cancelado!', 'Se ha cancelado con éxito!')
                    $A.get('e.force:refreshView').fire();
                }
                else {
                    this.showToast('Error', 'Error!', 'Ocurrio un error al intentar cancelar');
                    console.log("--- Algo salio mal ---");
                }
            } else {
                this.showToast('Error', 'Error!', 'Ocurrio un error al intentar cancelar');
                console.log("--- Algo salio mal ---");
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },

    saveVentasMostrador: function (component, event, isSendSap) {
        component.set("v.showSpinner", true);
        let action = component.get('c.saveVentasMostrador');
        action.setParams({
            "ventasMostrador": component.get("v.ventasMostrador"),
            "ventasMostradorDetalle": component.get('v.ventasMostradorList'),
            "isSendSap": isSendSap
        });       
        action.setCallback(this, function(response) {
            component.set("v.showSpinner", true);
            if (response.getState() == "SUCCESS") {
                if (response.getReturnValue() == true){
                    this.showToast('success', 'Guardado!', 'Se ha guardado con éxito!')
                    //$A.get('e.force:refreshView').fire();
                }
                console.log(response);
                console.log(response.getState);
                component.set("v.showSpinner", false);
                this.closeFocusedTab(component, event);
                //$A.get('e.force:refreshView').fire();
            
            } else {
                this.showToast('Error', 'Error!', 'Ocurrio un error al intentar guardar');
                console.log("--- Algo salio mal ---");
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);

        var ventaMostrador =  component.get("v.ventasMostrador");
        console.log('ventaMostrador', JSON.stringify(ventaMostrador));
    },

    updateVentasMostrador: function (component, event, isSendSap) {

        let action = component.get('c.updateVentasMostrador');
        action.setParams({
            "ventasMostrador": component.get("v.ventasMostrador"),
            "ventasMostradorDetalle": component.get('v.ventasMostradorList'),
            "isSendSap": isSendSap
        });       
        action.setCallback(this, function(response) {
            component.set("v.showSpinner", true);
            if (response.getState() == "SUCCESS") {
                if (response.getReturnValue() == true){
                    this.showToast('success', 'Guardado!', 'Se ha guardado con éxito!')
                    $A.get('e.force:refreshView').fire();
                }
                console.log(response);
                console.log(response.getState);
            
            } else {
                this.showToast('Error', 'Error!', 'Ocurrio un error al intentar guardar');
                console.log("--- Algo salio mal ---");
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);

        var ventaMostrador =  component.get("v.ventasMostrador");
        console.log('ventaMostrador', JSON.stringify(ventaMostrador));
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