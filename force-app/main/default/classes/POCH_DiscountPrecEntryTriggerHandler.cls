/***************************************************************************************************************
Name:        POCH_DiscountPrecEntryTriggerHandler.apxc
Author:    
Created:	
Project:	 Pochteca

Description: Discount PrecEntry Trigger Handler Class
***************************************************************************************************************/

public class POCH_DiscountPrecEntryTriggerHandler {
    public static void beforeInsert(List<PricebookEntry> triggerNew) {
     //   POCH_DiscountPrecEntryTriggerService.assignDiscountCurrencyAndUpperBound(triggerNew);
    }
    public static void beforeUpdate(List<PricebookEntry> triggerNew) {
      //  POCH_DiscountPrecEntryTriggerService.assignDiscountCurrencyAndUpperBound(triggerNew);
    }
    public static void afterUpdate(List<PricebookEntry> triggerNew) {
       //POCH_DiscountPrecEntryTriggerService.validateStatusQuoteLine(triggerNew);
    }
}