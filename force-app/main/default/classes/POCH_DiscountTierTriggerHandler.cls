/***************************************************************************************************************
Name:        POCH_DiscountTierTriggerHandler.apxc
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 27-09-2019
Project:	 Pochteca

Description: Discount Tier Trigger Handler Class
***************************************************************************************************************/

public class POCH_DiscountTierTriggerHandler {
    public static void beforeInsert(List<SBQQ__DiscountTier__c> triggerNew) {
        POCH_DiscountTierTriggerService.assignDiscountCurrencyAndUpperBound(triggerNew);
    }
    public static void beforeUpdate(List<SBQQ__DiscountTier__c> triggerNew) {
       POCH_DiscountTierTriggerService.assignDiscountCurrencyAndUpperBound(triggerNew);
    }
    public static void afterUpdate(List<SBQQ__DiscountTier__c> triggerNew) {
       // POCH_DiscountTierTriggerService.validateStatusQuoteLine(triggerNew);
    }
}