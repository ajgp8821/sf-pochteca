/***************************************************************************************************************
Name:        POCH_CloseSPANCOP_Bch.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:     01-03-2020
Project:     Pochteca

Description: Batch process for automatic PMV's opportunities close

Change Log
26/05/2020 - Miriam Teloxa - Se modifican condiciones en StageName y se agrega Nota de SPANCOP

***************************************************************************************************************/

global class POCH_CloseSPANCOP_Bch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        System.debug('::: POCH_QuoteBatch.start'); 
        /*return Database.getQueryLocator([SELECT Id,CloseDate,StageName FROM Opportunity WHERE POCH_IniciativaComercial__c = 'ICV-0060' AND CloseDate <= TODAY 
                                         AND StageName <> 'Orden de Compra' AND StageName <> 'Pago' AND StageName <> 'Cerrada Ganada' AND StageName <> 'Cerrada Perdida' ORDER BY CreatedDate DESC]);*/
        return Database.getQueryLocator([SELECT Id,CloseDate,StageName FROM Opportunity WHERE POCH_IniciativaComercial__c = 'ICV-0060' 
                                         AND StageName <> 'Cerrado Pagado' AND StageName <> 'Cerrado Facturado' AND StageName <> 'Cerrada Perdida' ORDER BY CreatedDate DESC]);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        System.debug('::: POCH_QuoteBatch.execute');
        for(Opportunity opp : scope) {
            opp.StageName             = 'Cerrada Perdida';
            opp.POCH_MotivoPerdida__c = 'PMV Cerrada';
            opp.Nota_de_P_rdida__c = 'PMV no facturado en el mes';
        }
        
        SBQQ.TriggerControl.disable();
            POCH_OpportunityTriggerService.isInvokedByTrigger = true;
            Database.SaveResult[] lSR = Database.update(scope, false);
        SBQQ.TriggerControl.enable();        
        
        for(Database.SaveResult sr : lSR) {
            if(!sr.isSuccess())
                for(Database.Error error : sr.getErrors()) { System.debug('--> ERROR (' + sr.getId() +') : ' + error.getMessage()); }
            else System.debug('--> OK : ' + sr.getId());            
        }        
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('::: POCH_QuoteBatch.finish');
    }

}