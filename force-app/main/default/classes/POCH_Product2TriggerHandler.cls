/***************************************************************************************************************
Name:        POCH_Product2TriggerHandler.apxc
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 27-09-2019
Project:	 Pochteca

Description: Product2 Trigger Handler Class
***************************************************************************************************************/

public class POCH_Product2TriggerHandler {    
    public static void afterInsert(List<Product2> triggerNew) {
        POCH_Product2TriggerService.upsertProductStandardPricebook(triggerNew);           
    }
    public static void afterUpdate(List<Product2> triggerNew) {
        POCH_Product2TriggerService.upsertProductStandardPricebook(triggerNew);
    }        
}