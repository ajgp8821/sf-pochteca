/***************************************************************************************************************
Name:        POCH_QuoteTrigger.trigger
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:     02-10-2019
Project:     Pochteca

Description: Quote Trigger
***************************************************************************************************************/

trigger POCH_QuoteTrigger on SBQQ__Quote__c (before insert, before update, after update) {    
    
    POCH_TriggerSettings__c activateTrigger = POCH_TriggerSettings__c.getOrgDefaults();
    if(activateTrigger.POCH_QuoteTrigger__c) {
        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                POCH_QuoteTriggerHandler.beforeInsert(trigger.New);
            }  
            if(Trigger.isUpdate) {
                POCH_QuoteTriggerHandler.beforeUpdate(Trigger.New);
            } 
        }
        if(Trigger.isAfter) {
            if(Trigger.isUpdate) {
                POCH_QuoteTriggerHandler.afterUpdate(Trigger.New);
            }           
        }
    }
    
}