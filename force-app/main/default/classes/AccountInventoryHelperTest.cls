@isTest
public class AccountInventoryHelperTest {
    
    static testMethod void myUnitCaseTest() {
        Test.startTest();
        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;
        
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        Account acc = POCH_DataCreationTest.getAccount();
        acc.POCH_TipoRegistro__c = 'Prospecto';
        acc.POCH_Region__c = reg.Id;
        insert acc;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal();
        suc.POCH_Sociedad__c = '400';
        insert suc;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        
        POCH_HojaInventario__c client = new POCH_HojaInventario__c(POCH_Cuenta__c= acc.Id);
        insert client;
        
        Account accNoSAP = POCH_DataCreationTest.getAccountNoIdSAP();
        accNoSAP.POCH_TipoRegistro__c = 'Prospecto';
        accNoSAP.POCH_Region__c = reg.Id;
        insert accNoSAP;
        
        Test.stopTest();
        
    }
    
}