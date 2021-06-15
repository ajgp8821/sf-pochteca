({
	getAppComments : function(component, event, helper) {
		let action = component.get('c.getApprovalComments');
        action.setParams({
            'idPedido' : component.get('v.strIdPedido')
        });  
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {                
                if(response.getReturnValue() !== '' && response.getReturnValue() !== null && response.getReturnValue() !== undefined) {
                    component.set('v.lstPISteps', response.getReturnValue());
                    component.set('v.blnHasCmmts', true);
                } else {
                    component.set('v.strTxtInit', 'No se han encontrado comentarios.');
                }
            } else { 
                console.log('--Algo salió mal (getApprovalComments)--');
            }
        });
        $A.enqueueAction(action);        
	}
})