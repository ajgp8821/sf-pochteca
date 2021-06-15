/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System 
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Test class for create records test
--- CreateDate: 24/03/2021 - JIRA RN6520
--- UpdateDate:  - JIRA
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class POCH_OpportunityTriggerServiceTest {
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
        
        POCH_HojaInventario__c hi = POCH_DataCreationTest.getInventario();
        hi.POCH_Cuenta__c = acc.Id;
        hi.POCH_Sucursal__c = suc.Id;
        insert hi;

        POCH_DetalleInventario__c hiDetalle = POCH_DataCreationTest.getDetalleInventario();
        hiDetalle.POCH_Sucursal__c 		 = suc.id;
        hiDetalle.POCH_HojaInventario__c = hi.Id;
        insert hiDetalle;
	        
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
        Test.stopTest();  
    }
    
    @isTest
    private static void OppValidarCredFalse(){
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
        
        POCH_HojaInventario__c hi = POCH_DataCreationTest.getInventario();
        hi.POCH_Cuenta__c = acc.Id;
        hi.POCH_Sucursal__c = suc.Id;
        insert hi;

        POCH_DetalleInventario__c hiDetalle = POCH_DataCreationTest.getDetalleInventario();
        hiDetalle.POCH_Sucursal__c 		 = suc.id;
        hiDetalle.POCH_HojaInventario__c = hi.Id;
        insert hiDetalle;
	        
        POCH_OpportunityTriggerService.isInvokedByTrigger = false;
        List<Opportunity> listOpp = new List<Opportunity>();
       
        Opportunity opp      = POCH_DataCreationTest.getOpportunity(); 
        opp.AccountId        = acc.Id;
        opp.POCH_Sucursal__c = suc.Id;
        opp.Pricebook2Id     = pb.Id;
        opp.POCH_SucursalAmpliada__c = sam.Id;
        opp.StageName        = 'Prospecto';
        opp.POCH_IsMonthly__c = false;
        opp.POCH_CreditoDisponible__c   = 1;
        opp.POCH_CreditoTotal__c        = 1;
        opp.OwnerId = UserInfo.getUserId();
        opp.POCH_ValidarCredito__c = true;
        listOpp.add(opp);
        insert opp;
        Test.stopTest();  
    }   
    
    @isTest
    private static void OppSudamericaFailSucVacia(){
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
        
        Contact contact =  POCH_DataCreationTest.getContact();
        contact.AccountId = acc.Id;
        insert contact;
        
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

        POCH_HojaInventario__c hi = POCH_DataCreationTest.getInventario();
        hi.POCH_Cuenta__c = acc.Id;
        hi.POCH_Sucursal__c = suc.Id;
        insert hi;

        POCH_DetalleInventario__c hiDetalle = POCH_DataCreationTest.getDetalleInventario();
        hiDetalle.POCH_Sucursal__c 		 = suc.id;
        hiDetalle.POCH_HojaInventario__c = hi.Id;
        insert hiDetalle;
	        
        POCH_OpportunityTriggerService.isInvokedByTrigger = false;
        List<Opportunity> listOpp = new List<Opportunity>();
       
        Opportunity opp      = POCH_DataCreationTest.getOpportunity(); 
        opp.AccountId        = acc.Id;
        opp.Pricebook2Id     = pb.Id;
        opp.Description = '222';
        opp.POCH_SucursalAmpliada__c = sam.Id;
        opp.StageName        = 'Negociación';
        opp.POCH_IsMonthly__c = false;
        opp.POCH_CreditoDisponible__c   = 1;
        opp.POCH_CreditoTotal__c        = 1;
        opp.OwnerId = UserInfo.getUserId();
        opp.POCH_ValidarCredito__c = true;
        opp.Numero_de_factura__c = '444';
        opp.POCH_RequiereVisitaTecnica__c = 'No';
        opp.POCH_VisitaTecnicaMuestraRealizada__c = false;
        opp.Type = 'Cierre Inmediato';
        opp.POCH_IniciativaComercial__c = 'IC-00008';
        opp.POCH_Contacto__c = contact.Id; 
        opp.Estado_temporal__c = true;
        opp.Estatus__c = 'Ganado';
        opp.POCH_Analisis__c = true;
        listOpp.add(opp);
        try{
         	insert opp;   
        }catch (DmlException e) {

        }
        Test.stopTest();  
    }
    
    @isTest
    private static void OppCerrada(){
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
            //System.debug('---- print --> ' + pickListVal.getValue());
        }
       
        insert acc;
        
        Contact contact =  POCH_DataCreationTest.getContact();
        contact.AccountId = acc.Id;
        insert contact;
        
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

        POCH_HojaInventario__c hi = POCH_DataCreationTest.getInventario();
        hi.POCH_Cuenta__c = acc.Id;
        hi.POCH_Sucursal__c = suc.Id;
        insert hi;

        POCH_DetalleInventario__c hiDetalle = POCH_DataCreationTest.getDetalleInventario();
        hiDetalle.POCH_Sucursal__c 		 = suc.id;
        hiDetalle.POCH_HojaInventario__c = hi.Id;
        insert hiDetalle;
	        
        POCH_OpportunityTriggerService.isInvokedByTrigger = false;
        List<Opportunity> listOpp = new List<Opportunity>();
       
        Opportunity opp      = POCH_DataCreationTest.getOpportunity(); 
        opp.AccountId        = acc.Id;
        opp.POCH_Sucursal__c = suc.Id;
        opp.Description = '222';
        opp.POCH_SucursalAmpliada__c = sam.Id;
        opp.StageName        = 'Prospecto';
        opp.POCH_IsMonthly__c = false;
        opp.POCH_CreditoDisponible__c   = 1;
        opp.POCH_CreditoTotal__c        = 1;
        opp.OwnerId = UserInfo.getUserId();
        opp.POCH_ValidarCredito__c = true;
        opp.Numero_de_factura__c = '444';
        opp.POCH_RequiereVisitaTecnica__c = 'No';
        opp.POCH_VisitaTecnicaMuestraRealizada__c = false;
        opp.Type = 'Cierre Inmediato';
        opp.POCH_IniciativaComercial__c = 'IC-00008';
        opp.POCH_Contacto__c = contact.Id; 
        opp.Estado_temporal__c = true;
        opp.POCH_Analisis__c = true;
        listOpp.add(opp);
        try{
         	insert opp;   
        }catch (DmlException e) {

        }
        Test.stopTest();  
    }

}