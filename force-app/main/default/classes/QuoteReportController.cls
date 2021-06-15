public class QuoteReportController {
@AuraEnabled

    public static List <SBQQ__Quote__c> fetchQuotes() {

        //Qyery 10 quotes

        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, SBQQ__Account__r.Name from SBQQ__Quote__c LIMIT 10];

        //return list of quotes

        return quoteList;

    }
}