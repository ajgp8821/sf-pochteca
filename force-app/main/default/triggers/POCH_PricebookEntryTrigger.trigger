trigger POCH_PricebookEntryTrigger on POCH_PricebookEntryTemp__c (after insert,after update) {

    POCH_TriggerSettings__c activateTrigger = POCH_TriggerSettings__c.getOrgDefaults();
    if(activateTrigger.POCH_PricebookEntryTrigger__c) {
        if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                POCH_PricebookEntryTriggerHandler.handlePricebookEntry(Trigger.new);
                
            }
        }
         if(Trigger.isAfter) {
            if(Trigger.isUpdate) {
               POCH_PricebookEntryTriggerHandler.handlePricebookEntry(Trigger.new);
            }
        }	
    }    
    
}