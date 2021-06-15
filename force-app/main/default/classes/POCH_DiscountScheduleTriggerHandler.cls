/***************************************************************************************************************
Name:        POCH_DiscountScheduleTriggerHandler.apxc
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 27-09-2019
Project:	 Pochteca

Description: Discount Schedule Trigger Handler Class
***************************************************************************************************************/

public class POCH_DiscountScheduleTriggerHandler {
	
    public static void beforeInsert(List<SBQQ__DiscountSchedule__c> triggerNew) {
       POCH_DiscountScheduleTriggerService.deleteOldSchedule(triggerNew);
    }

    public static void beforeUpdate(List<SBQQ__DiscountSchedule__c> triggerNew) {
       POCH_DiscountScheduleTriggerService.handleDiscountTiers(triggerNew);
    }
    
}