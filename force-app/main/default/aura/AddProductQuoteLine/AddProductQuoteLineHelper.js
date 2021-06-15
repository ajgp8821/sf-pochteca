({
	 showToast: function (component, vTitle, vMessage, vType){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": vTitle,"message": vMessage,"type": vType});
        toastEvent.fire();
        return false;
    },
     ge : function(component, event, helper) {
        var recordId = component.get('v.recordId');
   
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'SBQQ__QuoteLine__c',
                recordId : recordId// change record id. 
            },
        };
      
    },
    
})