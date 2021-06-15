global class POCH_CancelaQuoteForTime_Bch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        System.debug('::: POCH_CancelaQuoteForTime_Bch.start'); 
       Date startOfMonth = Date.today().toStartOfMonth();
       Date startOfNextDays = startOfMonth.addDays(30);
        /*return Database.getQueryLocator([SELECT Id,CloseDate,StageName FROM Opportunity WHERE POCH_IniciativaComercial__c = 'ICV-0060' AND CloseDate <= TODAY 
AND StageName <> 'Orden de Compra' AND StageName <> 'Pago' AND StageName <> 'Cerrada Ganada' AND StageName <> 'Cerrada Perdida' ORDER BY CreatedDate DESC]);*/
        return Database.getQueryLocator([SELECT Id,SBQQ__EndDate__c,POCH_EstatusCotizacion__c,SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE (POCH_EstatusCotizacion__c <> 'Abierta' or POCH_EstatusCotizacion__c <> 'Cancelada') and SBQQ__EndDate__c <> null and (SBQQ__StartDate__c >= :startOfMonth and SBQQ__StartDate__c <= :startOfNextDays) ]);
        // return Database.getQueryLocator([SELECT Id,SBQQ__EndDate__c,POCH_EstatusCotizacion__c FROM SBQQ__Quote__c WHERE (POCH_EstatusCotizacion__c <> 'Abierta' or POCH_EstatusCotizacion__c <> 'Cancelado') ]);
    }
    
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> scope) {
        System.debug('::: POCH_QuoteBatch.execute');
        set<Id> quoteIds = new set<Id>();
        dateTime fecha =  Datetime.now();
        set<Id> quoteIdAC = new set<Id>();
        List<SBQQ__QuoteLine__c> lQuoteLinesWF = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> lQuoteLinesAC = new List<SBQQ__QuoteLine__c>();
        system.debug('pasasndo por fecha'+fecha);
        for(SBQQ__Quote__c QT : scope) {
            // QT.POCH_EstatusCotizacion__c = 'Cancelada';a0x2i0000015848AAA
            //QT.Motivos_de_Cancelaci_n__c = 'Vigencia';
            quoteIds.add(QT.id);
        }system.debug('pasasndo por quoteIds'+quoteIds);
       
        for(SBQQ__QuoteLine__c  quoteLineCPQ : [select id,fecha_inicio__c,SBQQ__Quote__r.id,fecha_cancelacion__c,SBQQ__Quote__r.Tiempo_cancelacion__c,WF_Total_Paso__c,SBQQ__EndDate__c, SBQQ__StartDate__c, POCH_WF__c from SBQQ__QuoteLine__c where SBQQ__Quote__c  IN : quoteIds 
                                                and SBQQ__Quote__r.Tiempo_cancelacion__c <> null and  POCH_EstatusCotizacion__c = 'Por Autorizar' and fecha_inicio__c <> null and fecha_cancelacion__c <> null limit 100]){
                                                    SBQQ__QuoteLine__c  quoteLineC  = new SBQQ__QuoteLine__c();
                                                    quoteLineC.id = quoteLineCPQ.id;
                                                    quoteLineC.fecha_inicio__c = fecha;
                                                    quoteIdAC.add(quoteLineCPQ.SBQQ__Quote__r.id);                 
                                                    quoteLineC.fecha_cancelacion__c  =  quoteLineCPQ.fecha_cancelacion__c;                                                   
                                                    lQuoteLinesWF.add(quoteLineC);
                                                    
                                                }
        system.debug('LINEAS CONSULTADAS CON FECHA lQuoteLinesWF'+lQuoteLinesWF);
        update lQuoteLinesWF;
        for(SBQQ__QuoteLine__c  lQuoteLinesW : lQuoteLinesWF){
            SBQQ__QuoteLine__c  quoteLineAC  = new SBQQ__QuoteLine__c();
            system.debug('pasasndo por fecha_inicio__c'+lQuoteLinesW.fecha_inicio__c);
            system.debug('pasasndo por fecha_cancelacion__c'+lQuoteLinesW.fecha_cancelacion__c);
            if(lQuoteLinesW.fecha_inicio__c >= lQuoteLinesW.fecha_cancelacion__c){
                system.debug('pasasndo por fecha_cancelacion__c despues de la comparacion'+lQuoteLinesW.fecha_cancelacion__c);
                quoteLineAC.id  = lQuoteLinesW.id;
                quoteLineAC.POCH_EstatusPartida__c = 'Cancelado';
                quoteLineAC.Motivo_de_cancelaci_n__c = 'FA';
                lQuoteLinesAC.add(quoteLineAC);                //
            }
        }
      
     
        SBQQ.TriggerControl.disable();
            update lQuoteLinesAC;
        POCH_OpportunityTriggerService.isInvokedByTrigger = false;
        POCH_QuoteLineTriggerService.isInvokedByTrigger = false;
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