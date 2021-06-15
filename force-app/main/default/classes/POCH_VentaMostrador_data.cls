public with sharing class POCH_VentaMostrador_data {

    public static List<Opportunity> retrieveOpportunityData(string accId) {
        return [Select Id,Name FROM Opportunity where AccountId =: accId AND Account.POCH_TipoRegistro__c != 'Cliente'];
    }
    public static Id retrievePriceBook(String idSuc) {
        return [Select Id FROM PriceBook2 where POCH_Sucursal__c =: idSuc AND IsActive = true LIMIT 1].Id;
    }
}