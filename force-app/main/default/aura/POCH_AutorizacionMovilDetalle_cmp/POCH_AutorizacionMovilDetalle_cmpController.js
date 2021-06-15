({
	init : function(component, event, helper) {		        
        helper.getDetallesPedido(component, event, helper);
        helper.getIdApprovalReq(component, event, helper);                        
	},
    aprobar : function(component, event, helper) {
        helper.resolucionPedido(component, event, helper, 'Approve');
    },
    rechazar : function(component, event, helper) {
        helper.resolucionPedido(component, event, helper, 'Reject');
    },
    reasignar : function(component, event, helper) {
        helper.showToast('Warning', 'Advertencia!', "No puede reasignar la aprobación de este pedido");
    },
    comentarios : function(component, event, helper) {
        helper.showApprComments(component, event, helper);
    }   
})