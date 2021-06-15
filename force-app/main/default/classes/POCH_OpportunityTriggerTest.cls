@isTest
public class POCH_OpportunityTriggerTest {

    public static testMethod void testOpportunity_setSucPB() {
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
        opp.POCH_Sucursal__c=suc.Id;
        insert opp;
                
        acc.POCH_TipoRegistro__c = 'Prospecto';
        update acc;
        
        User usr = [SELECT Id,POCH_OrganizacionesVentas__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        usr.POCH_OrganizacionesVentas__c = '0049;0023;0015;0019;0101';
        update usr;
        
        POCH_OpportunityTriggerService.isInvokedByTrigger = false;
        Opportunity opp2 	  = POCH_DataCreationTest.getOpportunity();
        opp2.StageName        = 'Closed Won';
        opp2.AccountId        = acc.Id;
        opp2.POCH_Sucursal__c = suc.Id;
        //opp2.Pricebook2Id     = pb.Id;        
        insert opp2;

        SBQQ__Quote__c qt2 = POCH_DataCreationTest.getQuote();
        qt2.SBQQ__Account__c = acc.Id;
        qt2.POCH_Sucursal__c = suc.Id;
        qt2.SBQQ__Opportunity2__c = opp2.Id;
        insert qt2;
		        
        opp2.StageName='Cerrada Perdida';
        opp2.POCH_MotivoPerdida__c = 'PMV Cerrada';
        opp2.Nota_de_P_rdida__c = 'PMV no facturado en el mes';
        opp2.AutomaticallyCreated__c=true;
        update opp2;
        
    }
    
}