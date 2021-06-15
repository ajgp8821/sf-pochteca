/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System 
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Test class for create records test
--- CreateDate: 19/04/2021 - JIRA RN-6687
--- UpdateDate:  - JIRA
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
@isTest
public class AccountTeamTriggerHandlerTest {
    
    @isTest
    private static void OppConHojaInvClientSAP(){
        Test.startTest();
        
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal2();
        insert suc;
        
        Account acc = POCH_DataCreationTest.getAccountIdSAPCLiente();
        acc.POCH_Sucursal__c = suc.Id;
        acc.POCH_Region__c = reg.Id;
        
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get('POCH_GrupoVendedores__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
        }
       
        insert acc;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        
        Pricebook2 pb = POCH_DataCreationTest.getCustomPricebook();
        pb.POCH_Sucursal__c = suc.Id;
        insert pb;   
        
        Product2 prd = POCH_DataCreationTest.getProduct();
        prd.POCH_UnidadesMedida__c =  'KG';
        insert prd; 
        
        POCH_UnidadMedidaProducto__c um = POCH_DataCreationTest.getUM();
        um.POCH_Producto__c  = prd.Id;
        insert um;
	        
        POCH_OpportunityTriggerService.isInvokedByTrigger = false;
        List<Opportunity> listOpp = new List<Opportunity>();
       
        Opportunity opp      = POCH_DataCreationTest.getOpportunity(); 
        opp.AccountId        = acc.Id;
        opp.POCH_Sucursal__c = suc.Id;
        opp.Pricebook2Id     = pb.Id;
        opp.POCH_SucursalAmpliada__c = sam.Id;
        opp.StageName        = 'Sospechoso';
        opp.POCH_IsMonthly__c = false;
        opp.POCH_CreditoDisponible__c   = 1;
        opp.POCH_CreditoTotal__c        = 1;
        opp.OwnerId = UserInfo.getUserId();
        listOpp.add(opp);
        insert opp;
        
        POCH_HojaInventario__c hi = POCH_DataCreationTest.getInventario();
        hi.POCH_Cuenta__c = acc.Id;
        hi.POCH_Sucursal__c = suc.Id;
        insert hi;
        
        POCH_DetalleInventario__c hiDetalle = POCH_DataCreationTest.getDetalleInventario();
        hiDetalle.POCH_Sucursal__c 		 = suc.id;
        hiDetalle.POCH_HojaInventario__c = hi.Id;
        insert hiDetalle;
        
        Test.stopTest();  
    }
    

}