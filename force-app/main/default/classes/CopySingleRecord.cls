public class CopySingleRecord {
    @AuraEnabled
    public static String copyQuoteSobjet(String recordId){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name,SBQQ__Account__c,SBQQ__EndDate__c,POCH_Sucursal__c,CurrencyIsoCode,
                                          SBQQ__PrimaryContact__c,POCH_EstatusCotizacion__c,SBQQ__SalesRep__c,Condici_n_de_Pago__c,
                                          Asunto__c,SBQQ__Notes__c,Canal_de_Distribuci_n__c,Terminos_y_condiciones__c
                                          FROM SBQQ__Quote__c where id =:recordId];
        SBQQ__Quote__c clondedParentRecordID = null;
         Date firstDayOfMonth = Date.today().toStartOfMonth();
        System.debug('firstDayOfMonth: '+firstDayOfMonth);
        Date firstDayofNextMonth=firstDayOfMonth.addMonths(1);
        Date lastDayofMonth = Date.today().toStartOfMonth();
        System.debug('firstDayofNextMonth: '+firstDayofNextMonth);
        Date day=Date.today().toStartOfMonth();
        if(day.month()==1||day.month()==3||day.month()==5||day.month()==7||day.month()==8||day.month()==10||day.month()==12){
            lastDayofMonth=day.addDays(30);}
        else if(day.month()==4||day.month()==6||day.month()==9||day.month()==11){
            lastDayofMonth=day.addDays(29);}
        else if((math.mod(day.year(),400)==400)&&((math.mod(day.year(),4)==0)||(math.mod(day.year(),100)!=0))){
            lastDayofMonth=day.addDays(28);}
        else {lastDayofMonth=day.addDays(27);}
        for(SBQQ__Quote__c qa:quoteList){
            clondedParentRecordID = qa.clone();
            clondedParentRecordID.SBQQ__EndDate__c =lastDayofMonth;
            clondedParentRecordID.SBQQ__ExpirationDate__c=lastDayofMonth;
            clondedParentRecordID.SBQQ__Primary__c = false;
            clondedParentRecordID.SBQQ__PrimaryContact__c = qa.SBQQ__PrimaryContact__c;   
            clondedParentRecordID.POCH_EstatusCotizacion__c = 'Abierta';
            clondedParentRecordID.POCH_ValidaAutorizaciones__c = true;
            clondedParentRecordID.SBQQ__SalesRep__c=qa.SBQQ__SalesRep__c;
            clondedParentRecordID.OwnerId = qa.SBQQ__SalesRep__c;
            clondedParentRecordID.Condici_n_de_Pago__c=qa.Condici_n_de_Pago__c;
            clondedParentRecordID.Asunto__c=qa.Asunto__c;
            clondedParentRecordID.SBQQ__Notes__c=qa.SBQQ__Notes__c;
            clondedParentRecordID.Terminos_y_condiciones__c=qa.Terminos_y_condiciones__c;
            
        }        
        insert clondedParentRecordID;    
        return clondedParentRecordID.Id;
    }   
}