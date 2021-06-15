@isTest
private class QuoteCancelMonthEndBatchTest {
    
    static testMethod void myUnitTest(){
        
        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;
        
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        Account acc = POCH_DataCreationTest.getAccount();
        acc.POCH_TipoRegistro__c = 'Prospecto';
        acc.POCH_Region__c = reg.Id;
        insert acc;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal();
        insert suc;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        
        Pricebook2 pb = POCH_DataCreationTest.getCustomPricebook();
        pb.POCH_Sucursal__c = suc.Id;
        insert pb;
        
        SBQQ__Quote__c qt = POCH_DataCreationTest.getQuote();
        qt.SBQQ__Account__c = acc.Id;
        qt.POCH_Sucursal__c = suc.Id;
        qt.POCH_EstatusCotizacion__c = 'Abierta';
        insert qt;
        
        Test.startTest();        
        Database.executeBatch(new QuoteCancelMonthEndBatch());
        QuoteCancelMonthEndScheduler sh1 = new QuoteCancelMonthEndScheduler();        
        String sch = '00 00 00 * * ?'; 
        system.schedule('Test Schedule', sch, sh1);                      
        Test.stopTest();
        
    } 
}