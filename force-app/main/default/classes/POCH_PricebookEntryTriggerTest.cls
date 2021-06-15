@isTest
public class POCH_PricebookEntryTriggerTest {
    
    public static testMethod void testPBETemp() {
        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;
        
        Pricebook2 pb = POCH_DataCreationTest.getCustomPricebook();
        insert pb;
        
        Product2 prd = POCH_DataCreationTest.getProduct();
        insert prd;
        
        POCH_PricebookEntryTemp__c pbet = POCH_DataCreationTest.getPBETemp();
        pbet.POCH_Pricebook2__c = pb.Id;
        pbet.POCH_Product2__c   = prd.Id;
        insert pbet;   
        
        PricebookEntry pbe  = POCH_DataCreationTest.getPBEntry();
        pbe.CurrencyIsoCode = 'USD';
        pbe.Pricebook2Id = pb.Id;
        pbe.Product2Id   = prd.Id;
        insert pbe;
        
        POCH_PricebookEntryTemp__c pbetx = POCH_DataCreationTest.getPBETemp();
        pbetx.POCH_Pricebook2__c = pb.Id;
        pbetx.POCH_Product2__c   = prd.Id;
        pbetx.POCH_IdExterno__c  = 'IDEXTPBE';
        insert pbetx;
    }

}