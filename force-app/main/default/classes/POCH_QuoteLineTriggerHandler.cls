/***************************************************************************************************************
Name:        POCH_QuoteLineTriggerHandler.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 22-07-2019
Project:	 Pochteca
Quote
Description: Quote Line Trigger Handler Class
***************************************************************************************************************/

public class POCH_QuoteLineTriggerHandler {
    
    public static void beforeInsert(List<SBQQ__QuoteLine__c> triggerNew) {
        POCH_QuoteLineTriggerService.handleAlternateUniteMeasurement(triggerNew);
        POCH_QuoteLineTriggerService.calculateUnitPrice(triggerNew);
        POCH_QuoteLineTriggerService.calculateUtilityMargin(triggerNew);
        POCH_QuoteLineTriggerService.actualizacionCentros(triggerNew);
        
        // POCH_QuoteLineTriggerService.updateQLStatus(triggerNew);
    }    
    public static void beforeUpdate(List<SBQQ__QuoteLine__c> triggerNew) {
         set<String> quoteIds = new set<String>();
         Boolean procede = false;
        for(SBQQ__QuoteLine__c handleCPQ : triggerNew) {
            quoteIds.add(handleCPQ.POCH_Estatus__c);
        }
        if(quoteIds.contains('Por Autorizar')){procede=true;}
     
        if(!procede){POCH_QuoteLineTriggerService.handleAlternateUniteMeasurement(triggerNew);}
        POCH_QuoteLineTriggerService.calculateUnitPrice(triggerNew);
        POCH_QuoteLineTriggerService.calculateUtilityMargin(triggerNew);
        //if(!procede){ POCH_QuoteLineTriggerService.handleWFQuoteLinesAutorizadas(triggerNew);}
        POCH_QuoteLineTriggerService.handleQuoteLinesApprovers(triggerNew);
        if(!procede){POCH_QuoteLineTriggerService.handleQuoteLinesComments(triggerNew);}
        if(!procede){POCH_QuoteLineTriggerService.preventFieldsToEdit(triggerNew);}
        if(!procede){POCH_QuoteLineTriggerService.handlePrecioEspecialDisable(triggerNew);}
        if(!procede){POCH_QuoteLineTriggerService.actualizacionCentros(triggerNew);}
        
       //noChangeStatusAfterCancel POCH_QuoteLineWF.handleApprovalQuoteLine(triggerNew);        
    }
    public static void afterUpdate(List<SBQQ__QuoteLine__c> triggerNew) {
        POCH_QuoteLineTriggerService.noChangeStatusAfterCancel(triggerNew);
        POCH_QuoteLineTriggerService.handleQuoteLinesWF(triggerNew);
		
		
      }
 }