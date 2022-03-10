({
	helperMethod : function() {
		
	},

	showToast: function(tipomsj, titlemsj, Mensaje) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
				"type": tipomsj,
				"title": titlemsj,
				"message": Mensaje
		});
		toastEvent.fire();        
	},

})