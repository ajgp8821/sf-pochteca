({
	init : function(component, event, helper) {
		var pageReference = component.get('v.pageReference');        
        component.set('v.strIdPedido', pageReference.state.c__strIdPedido);
        
        helper.getAppComments(component, event, helper);
	},
    regresarDetalles : function(component, event, helper) {
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__POCH_AutorizacionMovilDetalle_cmp',
            },
            state: {
                'c__strIdPedido': component.get('v.strIdPedido')
            }
        };        
        var navComponent = component.find('navComponent');
        event.preventDefault();
        navComponent.navigate(pageReference);
    }
})