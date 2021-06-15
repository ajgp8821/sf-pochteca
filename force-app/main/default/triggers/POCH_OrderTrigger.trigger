/***************************************************************************************************************
Name:        POCH_OrderTrigger.trigger
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 12-08-2019
Project:	 Pochteca

Description: Order Trigger
***************************************************************************************************************/

trigger POCH_OrderTrigger on Order (after insert, after update, before delete) {
    
    POCH_TriggerSettings__c activateTrigger = POCH_TriggerSettings__c.getOrgDefaults();
    if(activateTrigger.POCH_OrderTrigger__c) {
         if(Trigger.isBefore) {
            if(Trigger.isDelete) {
                POCH_OrderTriggerHandler.beforeDelete(Trigger.old);
            }
      
        }
        if(Trigger.isAfter) {
            if(Trigger.isUpdate) {
                POCH_OrderTriggerHandler.afterUpdate(Trigger.new);
            }
            if(Trigger.isInsert) {
                POCH_OrderTriggerHandler.afterInsert(Trigger.new);
            }
        }
       
    }    
        
}