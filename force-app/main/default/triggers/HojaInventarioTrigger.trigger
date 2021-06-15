/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga
--- Author: Jesús Azuaje 
--- Update for: 
--- Description: Trigger object Inventary
--- CreateDate: 16/03/2021 - JIRA RN-6687
--- UpdateDate:  
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
trigger HojaInventarioTrigger on POCH_HojaInventario__c (after insert, after update) {
    HojaInventarioHelper.findOpportunityRelated(Trigger.New, Trigger.oldMap);

}