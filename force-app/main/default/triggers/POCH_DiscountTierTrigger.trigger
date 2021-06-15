/***************************************************************************************************************
Name:        POCH_DiscountTierTrigger.apxt
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 27-09-2019
Project:	 Pochteca

Description: Discount Tier Trigger
***************************************************************************************************************/

trigger POCH_DiscountTierTrigger on SBQQ__DiscountTier__c (before insert, before update, after update) {
    
    POCH_TriggerSettings__c activateTrigger = POCH_TriggerSettings__c.getOrgDefaults();
    if(activateTrigger.POCH_DiscountTierTrigger__c) {
        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                POCH_DiscountTierTriggerHandler.beforeInsert(Trigger.New);
            }
            if(Trigger.isUpdate) {
                POCH_DiscountTierTriggerHandler.beforeUpdate(Trigger.New);
            }
        }
        if(Trigger.isAfter) {
            if(Trigger.isUpdate) {
                POCH_DiscountTierTriggerHandler.afterUpdate(Trigger.New);
            }
        }
    }
    
}