global class QuoteCancelMonthEndBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       String query = 'select Id,Name,Motivos_de_Cancelaci_n__c,POCH_EstatusCotizacion__c,CreatedDate from SBQQ__Quote__c where POCH_EstatusCotizacion__c != \'Liberada para Pedido\' AND POCH_EstatusCotizacion__c != \'Cancelada\' AND CreatedDate <= THIS_MONTH ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> quoteList) {
        try{
              //  system.debug('pasasndo '+quote.POCH_EstatusCotizacion__c);a0x2i0000013wJIAAY AND CreatedDate <= THIS_MONTH  or id =\'a0x2i0000013KKBAA2\' or id =\'a0x2i0000013KL5AAM\'
            list<SBQQ__Quote__c> quoteListToBeUpdate = new list<SBQQ__Quote__c>();
            string statuss = '';
            for(SBQQ__Quote__c quote : quoteList){
               quote.Estatus_de_cotizaci_n_anterior__c = quote.POCH_EstatusCotizacion__c;
               // system.debug('pasasndo'+quote.Estatus_de_cotizaci_n_anterior__c);
                quote.POCH_EstatusCotizacion__c = 'Cancelada';
                quote.Motivos_de_Cancelaci_n__c = 'Vigencia';
                quoteListToBeUpdate.add(quote);
            }        
            if(!quoteListToBeUpdate.isEmpty()){
                Database.update(quoteListToBeUpdate);
            }
        }catch(Exception ex){
            system.debug('Error: '+ex);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}