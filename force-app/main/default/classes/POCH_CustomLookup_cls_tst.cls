@isTest
public class POCH_CustomLookup_cls_tst {
    
    public static testMethod void testCustomLookup() {
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal();
        insert suc;
        
        List<sObject> lSO = POCH_CustomLookup_cls.fetchLookUpValues('Test', 'PricebookEntry', suc.Id);
        List<sObject> lS2 = POCH_CustomLookup_cls.fetchLookUpValues('Test', 'POCH_SucursalAmpliada__c', '');
        
        System.assertEquals(true, lSO.isEmpty(), 'Empty List');
        System.assertEquals(true, lS2.isEmpty(), 'Empty List');
    }

}