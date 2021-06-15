({
    getDetallesPedido : function(component, event, helper) {
        let pageReference = component.get('v.pageReference');
        
        let action = component.get('c.getDetallesPedido');
        action.setParams({
            'idPedido': pageReference.state.c__strIdPedido
        });  
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                let oPedido = response.getReturnValue();
                if(oPedido !== null && oPedido !== undefined) {
                    component.set('v.objPedido', oPedido);    
                    if(oPedido.Detalles_de_autorizaciones__r !== null && oPedido.Detalles_de_autorizaciones__r !== undefined && oPedido.Detalles_de_autorizaciones__r.length !== 0) {
                        component.set('v.blnHasDetls', true);
                        
                        let detalles = component.get('v.lstActSctns');
                        for(var index = 0; index < oPedido.Detalles_de_autorizaciones__r.length; index++) { 
                            detalles.push(oPedido.Detalles_de_autorizaciones__r[index].Id);
                        }                        
                        component.set('v.lstActSctns', detalles);
                    } else {
                        component.set('v.strNoDetail', 'No se han encontrado detalles del pedido, intente más tarde.');
                    }
                }                
            } else { 
                console.log('--Algo salió mal (getPedido)--');
            }
        });
        $A.enqueueAction(action);        
    },
    
    getIdApprovalReq : function(component,event,helper) {
        let pageReference = component.get('v.pageReference');
        let action = component.get('c.getIdApprovalRequest');
        action.setParams({
            'idPedido': pageReference.state.c__strIdPedido
        });  
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                component.set('v.strIdAprReq', response.getReturnValue());
                if(response.getReturnValue() === '' || response.getReturnValue() === null || response.getReturnValue() === undefined) {
                    component.set('v.strResultPd', 'El Pedido ya ha sido resuelto.');
                    //document.getElementById('acp').style.visibility='hidden';  //.remove();
                    //document.getElementById('rcz').style.visibility='hidden';  //.remove();                    
                    //document.getElementById('rsg').className = "slds-size--1-of-2 slds-truncate";
                    //document.getElementById('cmt').className = "slds-size--1-of-2 slds-truncate";
                }
            } else { 
                console.log('--Algo salió mal (getIdApprovalRequest)--');
            }
        });
        $A.enqueueAction(action); 
    },
    
    resolucionPedido : function(component,event,helper,rslt) {        
    	var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__POCH_ResolucionPedido_cmp',
            },
            state: {
                'c__strIdPedido': component.get('v.objPedido.Id'),
                'c__strIdAprReq': component.get('v.strIdAprReq'),
                'c__strDecision': rslt
            }
        };        
        var cmpResolution = component.find('cmpResolution');
        event.preventDefault();
        cmpResolution.navigate(pageReference);
    },
    
    showApprComments : function(component,event,helper) {
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__POCH_AutorizacionComentarios_cmp',
            },
            state: {
                'c__strIdPedido': component.get('v.objPedido.Id')
            }
        };        
        var cmpResolution = component.find('cmpResolution');
        event.preventDefault();
        cmpResolution.navigate(pageReference);
    },
    
    showToast : function(tipomsj,titlemsj,Mensaje) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'type'   : tipomsj,
            'title'  : titlemsj,
            'message': Mensaje
        });
        toastEvent.fire();        
    }
})