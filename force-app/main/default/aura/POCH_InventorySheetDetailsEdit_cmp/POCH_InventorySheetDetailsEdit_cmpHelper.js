({
	RemoveRecordToDetail : function(component, event, helper) {
		var action = component.get("c.deleteRecordOnDetail");
        action.setParams({
            'IdRecordDetail': component.get("v.ProductInstance.Id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "title": "Eliminado!",
                        "message": "Se Elimino el Registro"
                    });
                    toastEvent.fire();
            }else{
                console.log('--- Algo salio mal ---');
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
                if(StrnNameField == 'POCH_UnidadMedida__c'){
                    component.set("v.listControllingValuesUnidaM", ControllerFieldOneLevel);
                }
                if(StrnNameField == 'POCH_Estatus__c'){
                    component.set("v.listControllingValuesEstatus", ControllerFieldOneLevel);
                }
                if(StrnNameField == 'Moneda_competencia__c'){
                    component.set("v.listMonedaComp", ControllerFieldOneLevel);
                    
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getPicklistDataxObject : function(component, event) {
        var action = component.get("c.getDataPickListValues");
        action.setParams({
            'strObject': 'POCH_Competencia__c',
            'idHojaInventario': component.get("{!v.strIdHojaInv}")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") { 
                component.set("v.listWhoBuy",response.getReturnValue());
            }else{
                console.log('--- Algo salio mal ---');
            }
            
        });
        $A.enqueueAction(action);    
    },
    
    getPriceList : function(component, event, helper) {   	        
        var strIdProduct = component.get("v.ProductInstance.POCH_Producto__c");	   
        var strIdSucAmp  = component.get("v.strIdSucursalAmp");		        
        var strIdAccount = component.get("v.strIdAcc");
        if(strIdAccount == '' || strIdAccount == null || strIdAccount == undefined) {
        	strIdAccount = component.get("v.ProductInstance.POCH_HojaInventario__r.POCH_Cuenta__c");
        }
        var intCantBase = component.get("v.ProductInstance.POCH_CantidadBase__c");
        var intCantPotn = component.get("v.ProductInstance.POCH_CantidadPotencial__c");
        var strUniMedida = component.get("v.ProductInstance.POCH_UnidadMedida__c");

		if(   strIdProduct != ''        && strIdSucAmp != ''        && strIdAccount != ''                                    && strUniMedida != ''
           && strIdProduct != null      && strIdSucAmp != null      && strIdAccount != null      && intCantBase != null      && strUniMedida != null
           && strIdProduct != undefined && strIdSucAmp != undefined && strIdAccount != undefined && intCantBase != undefined && strUniMedida != undefined)
        {
            var action = component.get("c.getSpecialOrListPrice");    
            action.setParams({
                "idProd" : strIdProduct,
                "idSuc"  : strIdSucAmp,
                "idAcc"  : strIdAccount,
                "qty"    : intCantBase,
                "um"     : strUniMedida
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS") {
                    var res = response.getReturnValue();                    
                    if(res.precio != 0 && res.precio != null && res.precio != undefined) { component.set("v.ProductInstance.POCH_PrecioLista__c", res.precio); }
                    if(res.moneda !='' && res.moneda != null && res.moneda != undefined) { component.set("v.ProductInstance.POCH_Moneda__c", res.moneda); }
                    if(res.medida !='' && res.medida != null && res.medida != undefined) { component.set("v.ProductInstance.POCH_uma__c", res.medida); }  
                    
                    component.set("v.ProductInstance.POCH_EsPotencial__c", parseFloat(intCantPotn) * parseFloat(res.preQty)); 
                    component.set("v.ProductInstance.POCH_EsBase__c",      parseFloat(intCantBase) * parseFloat(res.preQty));

                    if(parseFloat(component.get("v.ProductInstance.POCH_EsPotencial__c"))  <  parseFloat(component.get("v.ProductInstance.POCH_EsBase__c"))) {
                        helper.showToast(component, event, helper,'Escenario potencial no debe ser menos al Escenario base');
                        component.set("v.ProductInstance.POCH_EsPotencial__c", ''); 
                        component.set("v.ProductInstance.POCH_EsBase__c", '');
                        component.set("v.ProductInstance.POCH_CantidadBase__c", '');
                    } 
                } else { console.log('--- Algo salio mal UM ---'); }                                           
            });
            $A.enqueueAction(action);  
        }                                              
    },        
    
    showToast : function(component, event, helper, msgError) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error!",
            "message": msgError
        });
        toastEvent.fire();
    },

    getPicklistValuesOneLevelMap: function(component,StrObject,StrnNameField) {
        var action = component.get("c.PickListValuesIntoMap"); 
        action.setParams({
            objectType: StrObject,
            selectedField: StrnNameField
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var StoreResponse =  response.getReturnValue();
                var listOneLevel =  [];
                var miMapa = new Map();
                miMapa = response.getReturnValue();
                var ControllerFieldOneLevel = [];
                
                console.log(StoreResponse);
                miMapa.forEach(function(valor, clave) {
                    console.log(clave + ' = ' + valor);
                });
                for (var i = 0; i < miMapa.length; i++) {
                    listOneLevel.push(miMapa[i].get);
                    //console.log(miMapa[i].(key));
                }  
            	//
                if (listOneLevel != undefined && listOneLevel.length > 0) {
                    ControllerFieldOneLevel.push('-NA-');        
                }
                
                for (var i = 0; i < listOneLevel.length; i++) {
                    ControllerFieldOneLevel.push(listOneLevel[i]);
                } 
                if(StrnNameField == 'Pais__c'){
                    component.set("v.MapControllingValuesPais", ControllerFieldOneLevel);
                }
            }
        });
        $A.enqueueAction(action);
    }
})