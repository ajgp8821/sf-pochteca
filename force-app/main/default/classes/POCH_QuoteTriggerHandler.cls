/***************************************************************************************************************
Name:        POCH_QuoteTriggerHandler.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 02-10-2019
Project:	 Pochteca

Description: Quote Trigger Handler Class
***************************************************************************************************************/

public class POCH_QuoteTriggerHandler {
    public static void beforeInsert(List<SBQQ__Quote__c> triggerNew) {
        POCH_QuoteTriggerService.setSucursalAndPricebook(triggerNew);
    }
    public static void beforeUpdate(List<SBQQ__Quote__c> triggerNew) {
       POCH_QuoteTriggerService.actualizaEstatusAprobado(triggerNew);
    }
    public static void afterUpdate(List<SBQQ__Quote__c> triggerNew) {
        POCH_QuoteTriggerService.handleQuoteLinesWF(triggerNew);
    }
}