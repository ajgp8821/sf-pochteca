/***************************************************************************************************************
Name:        POCH_Product2Trigger.trigger
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 27-09-2019
Project:	 Pochteca

Description: Product2 Trigger
***************************************************************************************************************/

trigger POCH_Product2Trigger on Product2 (after insert, after update) { 
    
    POCH_TriggerSettings__c activateTrigger = POCH_TriggerSettings__c.getOrgDefaults();
    if(activateTrigger.POCH_Product2Trigger__c) {
        if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                POCH_Product2TriggerHandler.afterInsert(Trigger.New);
            }
            if(Trigger.isUpdate) {
                POCH_Product2TriggerHandler.afterUpdate(Trigger.New);
            }
        }
    }
    
}