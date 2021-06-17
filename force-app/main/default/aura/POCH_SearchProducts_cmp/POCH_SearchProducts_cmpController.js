({
	closeModel : function(component, event, helper) {
		component.set("v.isOpen", false);	 
	},
	createProductComponent: function(component, event, helper) {
		let isComponentCreated = component.get('v.productIsCreating');
		helper.handleProductCreate(component, isComponentCreated);
	},
	handleComponentEvent : function(component, event, helper) {
		let isComponentDeleted = event.getParam('isDeleted');
		if(isComponentDeleted) {
			helper.showToast('Success','Success!',$A.get('$Label.c.POCH_productCreated'));
			component.set('v.productIsCreating',false);
            
            let idHi = component.get("v.idInvSheet");
            if(idHi !== null && idHi !== "" && idHi !== undefined) {
                $A.get('e.force:refreshView').fire();
            }
		} else {
			component.set('v.productIsCreating',false);
		}
	},

	handleComponentEvent2 : function(component, event, helper) {
		let isComponentDeleted = event.getParam('isDeleted');
		if(isComponentDeleted) {
			helper.showToast('Success','Success!',$A.get('$Label.c.POCH_productCreated'));
			component.set('v.productIsCreating',false);
            
            let idHi = component.get("v.idInvSheet");
            if(idHi !== null && idHi !== "" && idHi !== undefined) {
                $A.get('e.force:refreshView').fire();
            }
		} else {
			component.set('v.productIsCreating',false);
		}
	}
})