/***************************************************************************************************************
Name:        POCH_OpportunityTrigger.trigger
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 18-09-2019
Project:	 Pochteca

Description: Opportunity Trigger
***************************************************************************************************************/

trigger POCH_OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
    POCH_TriggerSettings__c activateTrigger = POCH_TriggerSettings__c.getOrgDefaults();
    /*if(activateTrigger.POCH_OpportunityTrigger__c) {
        if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                POCH_OpportunityTriggerHandler.afterInsert(Trigger.New);                
            }
            if(Trigger.isUpdate) {
                POCH_OpportunityTriggerHandler.afterUpdate(Trigger.New, Trigger.oldMap);
            }
        }
        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                POCH_OpportunityTriggerHandler.beforeInsert(Trigger.New);                
            }
            if(Trigger.isUpdate) {
                POCH_OpportunityTriggerHandler.beforeUpdate(trigger.New);
            }        
        }  
    }*/
    
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {  
            POCH_OpportunityTriggerService.validateAccountWithOpp(trigger.New);
        }
        if(Trigger.isUpdate) {
            POCH_OpportunityTriggerService.closeOppsQuotes(trigger.New,trigger.OldMap);
        }
    }
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            POCH_OpportunityTriggerService.setSucursalAndPricebook(Trigger.New);                
        }
        if(Trigger.isUpdate) {
            POCH_OpportunityTriggerService.setSucursalAndPricebook(trigger.New);
        }        
    }  
    
}