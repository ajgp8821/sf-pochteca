@isTest
public class CopySingleRecord_test {
    
    @isTest
    public static void testgetStocks() {
        
        Test.startTest();
        System.debug('-----> Inicio');
        String detInvTest = '';
        Profile p = [SELECT Id FROM Profile WHERE Name='POCH-Ventas Mostrador'];
        User user = POCH_DataCreationTest.getUser();
        user.ProfileId = p.Id;
        user.POCH_OrganizacionesVentas__c = '0049';
        insert user;
        System.debug('-----> Insert User');
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal2();
        suc.POCH_OrganizacionVentas__c = '0049';
        insert suc;
        System.debug('-----> Insert Sucursal');
        
        SBQQ__Quote__c quote = POCH_DataCreationTest.getQuote();
        quote.POCH_Sucursal__c = suc.id;
        // quote.Moneda_documento__c = ;
        // quote.POCH_IdOrgVentas__c = ;
        // quote.POCH_IdOrgVentas__c = ;
        insert quote;
        System.debug('-----> Insert Quote');
        
        System.runAs(user) {
            System.debug('-----> Run init');
            detInvTest = CopySingleRecord.copyQuoteSobjet(quote.id);
            System.debug('-----> Run ');
        }
        Test.stopTest();
        system.assert(detInvTest != null);
    }
}
