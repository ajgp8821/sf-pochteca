/***************************************************************************************************************
Name:        POCH_DiscountScheduleTrigger.apxt
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 27-09-2019
Project:	 Pochteca

Description: Discount Schedule Trigger
***************************************************************************************************************/

trigger POCH_DiscountScheduleTrigger on SBQQ__DiscountSchedule__c (before insert, before update) {

    POCH_TriggerSettings__c activateTrigger = POCH_TriggerSettings__c.getOrgDefaults();
    if(activateTrigger.POCH_DiscountScheduleTrigger__c) {
        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                POCH_DiscountScheduleTriggerHandler.beforeInsert(Trigger.new);
            }
            if(Trigger.isUpdate) {
                POCH_DiscountScheduleTriggerHandler.beforeUpdate(Trigger.new);
            }
        }
    }
    
}