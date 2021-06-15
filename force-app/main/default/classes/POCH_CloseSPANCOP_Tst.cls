@isTest
public class POCH_CloseSPANCOP_Tst {
    
    public static testMethod void testSPANCOPBatch() {
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
        
        Opportunity opp = POCH_DataCreationTest.getOpportunity();
        opp.AccountId   = acc.Id;
        opp.StageName   = 'Closed Won';
        opp.CloseDate   = Date.today() + 3;
        opp.POCH_IniciativaComercial__c = 'ICV-0060';
        opp.POCH_Sucursal__c=suc.Id;
        insert opp;
        
        Test.startTest();
			POCH_CloseSPANCOP_Sch sch = new POCH_CloseSPANCOP_Sch();
            system.schedule('Test SChed SPANCOP', '0 0 1 * * ?', sch);                    
        Test.stopTest();
    }

}