/***************************************************************************************************************
Name:        POCH_QuoteLineTrigger.trigger
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:     22-07-2019
Project:     Pochteca

Description: Quote Line Trigger
***************************************************************************************************************/

trigger POCH_QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update, after update, after insert) {
    
    POCH_TriggerSettings__c activateTrigger = POCH_TriggerSettings__c.getOrgDefaults();
    if(activateTrigger.POCH_QuoteLineTrigger__c) {
        if(Trigger.isBefore && Trigger.isInsert) {
         
                POCH_QuoteLineTriggerHandler.beforeInsert(Trigger.new); 
         }
          if(Trigger.isBefore && Trigger.isUpdate) {
                POCH_QuoteLineTriggerHandler.beforeUpdate(Trigger.new);    
          }
        
        if(Trigger.isAfter && Trigger.isUpdate) {
            POCH_QuoteLineTriggerHandler.afterUpdate(Trigger.new);
       
        }       
    }
    
}