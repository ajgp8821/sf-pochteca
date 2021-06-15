@isTest
public class POCH_QuoteTriggerTest {
	
    public static testMethod void testQuote_SucPB() {        
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
        insert qt;
        
        User usr = [SELECT Id,POCH_OrganizacionesVentas__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        usr.POCH_OrganizacionesVentas__c = '0049;0023;0015;0019;0101';
        update usr;
        
        SBQQ__Quote__c qt2 = POCH_DataCreationTest.getQuote();
        qt2.SBQQ__Account__c = acc.Id;
        qt2.POCH_Sucursal__c = suc.Id;
        insert qt2;
    }
    
}