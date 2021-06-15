/***************************************************************************************************************
Name:        POCH_OpportunityTriggerHandler.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 18-09-2019
Project:	 Pochteca

Description: Opportunity Trigger Handler Class
***************************************************************************************************************/

public class POCH_OpportunityTriggerHandler {

    public static void beforeInsert(List<Opportunity> triggerNew) {   
        POCH_OpportunityTriggerService.setSucursalAndPricebook(triggerNew);
        //POCH_OpportunityTriggerService.validateAccountWithOpp(triggerNew);
    }
    public static void beforeUpdate(List<Opportunity> triggerNew) {        
        POCH_OpportunityTriggerService.setSucursalAndPricebook(triggerNew);
    }
    public static void afterInsert(List<Opportunity> triggerNew) {
        POCH_OpportunityTriggerService.validateAccountWithOpp(triggerNew);
    }
    public static void afterUpdate(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap) {
        POCH_OpportunityTriggerService.closeOppsQuotes(triggerNew,triggerOldMap);
    }    
}