global class POCH_CancelaQuote_Bch implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC) { 
        System.debug('::: POCH_QuoteBatch.start'); 
        /*return Database.getQueryLocator([SELECT Id,CloseDate,StageName FROM Opportunity WHERE POCH_IniciativaComercial__c = 'ICV-0060' AND CloseDate <= TODAY 
                                         AND StageName <> 'Orden de Compra' AND StageName <> 'Pago' AND StageName <> 'Cerrada Ganada' AND StageName <> 'Cerrada Perdida' ORDER BY CreatedDate DESC]);*/
        return Database.getQueryLocator([SELECT Id,SBQQ__EndDate__c,POCH_EstatusCotizacion__c FROM SBQQ__Quote__c WHERE POCH_EstatusCotizacion__c <> 'Cancelada' AND  POCH_EstatusCotizacion__c <>'Liberada para Pedido']);
    }
   
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> scope) {
        System.debug('::: POCH_QuoteBatch.execute');
        for(SBQQ__Quote__c QT : scope) {
            QT.POCH_EstatusCotizacion__c = 'Cancelada';
            QT.Motivos_de_Cancelaci_n__c = 'Vigencia';
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