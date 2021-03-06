({
    doInit : function(component, event, helper) {
        helper.getPicklistValuesOneLevel(component,'Venta_Mostrador_Detalle__c','UnidadMedida__c', null);
        //helper.getPicklistValuesOneLevel(component,'Venta_Mostrador_Detalle__c','POCH_Centro__c', null);
        //helper.getPicklistValuesOneLevel(component,'Venta_Mostrador_Detalle__c','Almacen__c', null);
        helper.getDependentPicklistValues(component, 'Venta_Mostrador_Detalle__c', 'Oficina_de_Venta__c', 'POCH_Centro__c', component.get("v.oficinaVentas"), true);
        // helper.getPicklistValuesOneLevel(component,'Venta_Mostrador_Detalle__c','CurrencyIsoCode', null);
    },
    
    removeRow : function(component, event, helper) {
        
        component.getEvent("DeleteRowEvt").setParams(
            {"indexVar" : component.get("v.rowIndex") }
        ).fire();

        var recalcularTotalesEvent = component.getEvent("recalcularTotales");
		var test = " test";
		recalcularTotalesEvent.setParams({testParam: test});
		recalcularTotalesEvent.fire();
    },
    
    LookupProduct : function(component, event, helper) {
        component.set("v.blnShowProducts", true);
    },
    
    addNewProductSelected: function(component, event, helper) {
        component.set("v.VentaInstance.POCH_Cantidad__c", 0);
        component.set("v.VentaInstance.Precio__c", 0);
        component.set("v.VentaInstance.CurrencyIsoCode", '');
        var blnShowPopupProd = event.getParam("evtShowPopUpProductLookup");
        var selectedProductFromEvent = event.getParam("recordByEvent");
        component.set("v.VentaInstance.Product__c" , selectedProductFromEvent.Product2.Id);
        var productsSelected =  component.get("v.ListaVentaSelected");
        var strlastId =  component.get("v.VentaInstance.Product__c");
        var equalsvalues = [];
        
        for (var i = 0; i < productsSelected.length; i++) {
            if(productsSelected[i].Product__c ==  strlastId){
                equalsvalues.push(i);
            }
        }
        
        // if(equalsvalues.length > 1) {
            // component.set("v.blnShowProducts" , blnShowPopupProd);
            // helper.showToast(component, event, helper,'No se pueden agregar productos iguales');
        // }
        // else {
            
            if(selectedProductFromEvent.Product2.ProductCode != '' && selectedProductFromEvent.Product2.ProductCode != null && selectedProductFromEvent.Product2.ProductCode != undefined ) {
                component.set("v.VentaInstance.Material__c" , selectedProductFromEvent.Product2.ProductCode.replace(/^0+/, ''));
            }
            if(selectedProductFromEvent.Product2.Name != '' && selectedProductFromEvent.Product2.Name != null && selectedProductFromEvent.Product2.Name != undefined) {
                component.set("v.VentaInstance.Descripcion__c", selectedProductFromEvent.Product2.Name.replace(/^0+/, ''));
            }
            if(selectedProductFromEvent.POCH_UnidadMedida__c != '' && selectedProductFromEvent.POCH_UnidadMedida__c != null && selectedProductFromEvent.POCH_UnidadMedida__c != undefined) {
                component.set("v.VentaInstance.UnidadMedida__c" , selectedProductFromEvent.POCH_UnidadMedida__c);
            }
            // selectedProductFromEvent.CurrencyIsoCode
            /*if(selectedProductFromEvent.CurrencyIsoCode != '' && selectedProductFromEvent.CurrencyIsoCode != null && selectedProductFromEvent.CurrencyIsoCode != undefined) {
                component.set("v.VentaInstance.CurrencyIsoCode" , selectedProductFromEvent.CurrencyIsoCode);
            }*/
            component.set("v.blnShowProducts" , blnShowPopupProd);
        // }
    },
    
    /*validateUM : function(component, event, helper) {
        var strIdProduct = component.get("v.VentaInstance.Product__c");
        var strUniMedida = component.get("v.VentaInstance.POCH_UnidadMedida__c");
        var strIdSucAmp  = component.get("v.strIdSucursalAmp");
        
        var action = component.get("c.getUMP");
        action.setParams({
            "idProd" : strIdProduct,
            "idSuc"  : strIdSucAmp
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.VentaInstance.POCH_uma__c", response.getReturnValue());
                if(strIdProduct !== '' && strIdProduct !== null && strIdProduct !== undefined
                    && strUniMedida == 'Kg' || strUniMedida == 'Lt' || strUniMedida == 'L')
                {
                    helper.validateUM_Helper(component, event, helper, response.getReturnValue());
                }
            } else { console.log('--- Algo salio mal UM ---'); }
        });
        $A.enqueueAction(action);
    },*/

    calcularTotales: function(component, event, helper) {
        var ventaDetalle = component.get("v.VentaInstance");
        ventaDetalle.Product__c = component.get("v.VentaInstance.Product__c");
        var temp = component.get("v.VentaInstance.POCH_Centro__c" );
        ventaDetalle.Sucursal__c = component.get("v.strIdSucursalAmp");
        ventaDetalle.Oficina_de_Venta__c = component.get("v.oficinaVentas");
        var venta = component.get("v.ventasMostrador");
        var action = component.get("c.getPrice");
        var action2 = component.get("c.getIVA");
        var action3 = component.get("c.getMargen");
        var action4 = component.get("c.getRates");
        var action5 = component.get("c.getApiName");
        var currencyAux = "";
        if (ventaDetalle.Descto__c == null || ventaDetalle.Descto__c == ""){
            ventaDetalle.Descto__c = 0; 
        }
        if (ventaDetalle.POCH_Cantidad__c == null || ventaDetalle.POCH_Cantidad__c == ""){
            ventaDetalle.POCH_Cantidad__c = 0; 
        }
        if (ventaDetalle.Descto__c > 10 || ventaDetalle.Descto__c < 0){
            component.set("v.VentaInstance.Descto__c", 0);
			helper.showToast2('warning', '', 'Descuento M??ximo 10%');
		}
		else {
            action.setParams({
                //product: component.get("v.VentaInstance.POCH_Producto__c"),
                product: ventaDetalle.Product__c,
                sucursal: component.get("v.strIdSucursalAmp"),
                //sucursal: 'a1K4P00000Ldvr8UAB',
                cantidad: parseFloat(ventaDetalle.POCH_Cantidad__c),
                account: venta.Cliente__c,
                //account: '0014P00002lB91DQAS',
                unidadMedida: ventaDetalle.UnidadMedida__c,
                notIsApiField: true,
                objectType: 'Venta_Mostrador_Detalle__c',
                selectedField: 'UnidadMedida__c',
                organizacionVenta: component.get('v.organizacionVentas')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    let precioTemp = response.getReturnValue();
                    ventaDetalle.CurrencyIsoCode = precioTemp.substr(0,3);
                    let errorCantidad = precioTemp.substr(3,2);
                    if (errorCantidad == 'si'){
                        helper.showToast2('Warning', 'Atenci??n!', 'Cantidad minima del producto incorrecta');  
                    }
                    let precio = precioTemp.substr(5)
                    precio =  parseFloat(precio);
                    ventaDetalle.Precio__c =  parseFloat(precio);
                    //var montoPorcentaje = precio * ventaDetalle.Descto__c;
                    //ventaDetalle.Valor_neto__c = (precio - ventaDetalle.Descuento_Monto__c ) * ventaDetalle.POCH_Cantidad__c; // se actualiza calculo
                    action5.setParams({
                        objectType: 'Ventas_Mostrador__c',
                        selectedField: 'CurrencyIsoCode',
                        apiLabel: component.get("v.ventasMostrador.CurrencyIsoCode")
                    });
                    action5.setCallback(this, function(response) {
                        if (response.getState() == "SUCCESS") {
                            currencyAux =  response.getReturnValue();
                            action4.setParams({
                            });
                            action4.setCallback(this, function (response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    let listRates = response.getReturnValue();
                                    if(listRates !== null && listRates !== undefined && listRates.length > 0) {
                                        if (component.get("v.VentaInstance.CurrencyIsoCode") == currencyAux){
                                            ventaDetalle.Valor_neto__c = precio  * parseFloat(ventaDetalle.POCH_Cantidad__c);
                                            ventaDetalle.Descto__c = parseFloat(ventaDetalle.Descto__c);
                                            ventaDetalle.Descuento_Monto__c = ventaDetalle.Valor_neto__c * ventaDetalle.Descto__c / 100;
                                            component.set("v.VentaInstance", ventaDetalle); 
                                            var almacen = component.get("v.VentaInstance.Almacen__c");
                                            var centro = component.get("v.VentaInstance.POCH_Centro__c");
                                            var producto = component.get("v.VentaInstance.Product__c");
                                            helper.getStock(component, almacen, centro, producto, '');
                                            helper.getStock(component, almacen, centro, producto, 'k');
                                        }else{
                                            for (var i = 0; i < listRates.length; i++) {
                                                var temp = listRates[i].substr(0,3);
                                                var temp2 = listRates[i].substr(3);
                                                //var temp3 = detalleVentaMostrador[indexVar].CurrencyIsoCode;
                                                //if (listRates[i].substr(0,3) == detalleVentaMostrador[indexVar].CurrencyIsoCode){
                                                if (listRates[i].substr(0,3) == component.get("v.VentaInstance.CurrencyIsoCode")){
                                                    ventaDetalle.Valor_neto__c = precio  / listRates[i].substr(3);
                                                    ventaDetalle.Valor_neto__c = ventaDetalle.Valor_neto__c * parseFloat(ventaDetalle.POCH_Cantidad__c);
                                                    ventaDetalle.Descto__c = parseFloat(ventaDetalle.Descto__c);
                                                    ventaDetalle.Descuento_Monto__c = ventaDetalle.Valor_neto__c * ventaDetalle.Descto__c / 100;
                                                    component.set("v.VentaInstance", ventaDetalle); 
                                                    var almacen = component.get("v.VentaInstance.Almacen__c");
                                                    var centro = component.get("v.VentaInstance.POCH_Centro__c");
                                                    var producto = component.get("v.VentaInstance.Product__c");
                                                    helper.getStock(component, almacen, centro, producto, '');
                                                    helper.getStock(component, almacen, centro, producto, 'k');
                                                }
                                            }
                                        }
                                    }
                                    action2.setParams({
                                        product: component.get("v.VentaInstance.Product__c"),
                                        sucursal: component.get("v.strIdSucursalAmp"),
                                        //sucursal: 'a1K4P00000Ldvr8UAB',
                                        valorNeto: ventaDetalle.Valor_neto__c - ventaDetalle.Descuento_Monto__c
                                    });
                                    action2.setCallback(this, function (response) {
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            let ivaMonto = response.getReturnValue();
                                            ventaDetalle.IVA__c = ivaMonto;
                                            component.set("v.VentaInstance", ventaDetalle);
                                            action3.setParams({
                                                //product: component.get("v.VentaInstance.POCH_Producto__c"),
                                                product: ventaDetalle.Product__c,
                                                unidadMedida: ventaDetalle.UnidadMedida__c,
                                                notIsApiField: true,
                                                objectType: 'Venta_Mostrador_Detalle__c',
                                                selectedField: 'UnidadMedida__c',
                                                precio: ventaDetalle.Precio__c,
                                                porcentajeDescuento: ventaDetalle.Descto__c,
                                                centro: ventaDetalle.POCH_Centro__c,
                                                selectedField2: 'POCH_Centro__c',
                                                moneda: ventaDetalle.CurrencyIsoCode,
                                                selectedField3: 'Almacen__c'
                                            });
                                            action3.setCallback(this, function (response) {
                                                var state = response.getState();
                                                if (state === "SUCCESS") {
                                                    let margen = response.getReturnValue();
                                                    ventaDetalle.Margen__c = margen;
                                                    //component.set("v.VentaInstance.Margen__c");
                                                    component.set("v.VentaInstance", ventaDetalle);
                                                    var calcularTotalesEvent = component.getEvent("calcularTotales");
                                                    var test = " test";
                                                    calcularTotalesEvent.setParams({testParam: test});
                                                    calcularTotalesEvent.fire();
                                                }else{
                                                    console.log("--- Algo salio mal ---");
                                                }
                                            });
                                            $A.enqueueAction(action3);
                                            
                                        }else {
                                            console.log("--- Algo salio mal ---");
                                        }
                                    });
                                    $A.enqueueAction(action2);
                                }else {
                                    console.log("--- Algo salio mal ---");
                                }
                            });
                            $A.enqueueAction(action4);
                        }

                    });
                    $A.enqueueAction(action5);
                }else {
                    helper.showToast('Warning', 'Atenci??n!', 'Unidad de medida no valida para este producto');
                    console.log("--- Algo salio mal ---");
                }
            });
            $A.enqueueAction(action);
        }
        
    },

    buscarStock : function(component, event, helper) {
        //alert(event.getParam('v.value'));
        var almacen = component.get("v.VentaInstance.Almacen__c");
        var centro = component.get("v.VentaInstance.POCH_Centro__c");
        var producto = component.get("v.VentaInstance.Product__c");
        helper.getStock(component, almacen, centro, producto, '');
        helper.getStock(component, almacen, centro, producto, 'k');
    },

    getAlmacen : function(component, event, helper) {
        var filter = component.get("v.VentaInstance.POCH_Centro__c");
        helper.getDependentPicklistValues(component, 'Venta_Mostrador_Detalle__c', 'POCH_Centro__c', 'Almacen__c', filter, false);
    }
})