/****************************************************************************************************
General Information
-------------------
author: Hector Diaz
email:
company: Freeway MX 
Project:
Customer:
Description:  Test Controller APEX component POCH_InventorySheet_cmp
@Helper class : POCH_InventorySheet_helper
Information about changes (versions)
-------------------------------------
Number    Dates             Author                       Description
------    --------          --------------------------   -----------
1.0       20-Junio-2019       Hector Diaz Hernandez      Creation Class
1.1       12-agosto-2019      Esquivel Cázares Mauricio  Refactorization->SOC MODEL
1.2       10-Febrero-2021     Jesús Azuaje               test methos getDescription, getCountryFrecuencia, getCountryCompetencia
****************************************************************************************************/
@IsTest
public with sharing class POCH_InventorySheet_cls_tst {
    
    @TestSetup
    static void makeData() {
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
        
        Product2 prd = POCH_DataCreationTest.getProduct();
        insert prd; 
        
        POCH_UnidadMedidaProducto__c um = POCH_DataCreationTest.getUM();
        um.POCH_Producto__c  = prd.Id;
        insert um;
        
        PricebookEntry pbEntry   = new PricebookEntry();
        pbEntry.Product2Id       = prd.id;
        pbEntry.Pricebook2Id     = pb.id;
        pbEntry.isActive         = true;
        pbEntry.unitPrice        = 1234;
        pbEntry.UseStandardPrice = false;
        insert pbEntry;
        
        POCH_HojaInventario__c hi = new POCH_HojaInventario__c();
        hi.Name = 'HI';
        hi.POCH_FechaUltimaCotizacion__c = Date.today().addMonths(-1);
        hi.POCH_FrecuenciaCotizacion__c  = '1';
        insert hi;
        
        POCH_OpportunityTriggerService.isInvokedByTrigger = true;
        Opportunity opp      = POCH_DataCreationTest.getOpportunity();
        opp.AccountId        = acc.Id;
        opp.POCH_Sucursal__c = suc.Id;
        opp.Pricebook2Id     = pb.Id;
        opp.StageName        = 'Closed Won';
        insert opp;
    }   
    
    class testDataWrapper {
        public Account 					 mainAccount	  {get;set;}
        public Product2 				 mainProducts	  {get;set;}
        public POCH_Sucursal__c          mainBranchOffice {get;set;}        
        public POCH_DetalleInventario__c mainDetailSheet  {get;set;}
        public POCH_HojaInventario__c	 mainInvSheet	  {get;set;}
        
        public testDataWrapper() {
            this.mainAccount      = [Select Id FROM Account LIMIT 1];
            this.mainProducts     = [Select Id,ProductCode,Name FROM Product2 LIMIT 1];
            this.mainBranchOffice = [Select Id,Name FROM POCH_Sucursal__c LIMIT 1];
            this.mainInvSheet     = [Select Id FROM POCH_HojaInventario__c LIMIT 1];
            
            POCH_DetalleInventario__c detalleTst = new POCH_DetalleInventario__c();
            detalleTst.POCH_Producto__c 		 = this.mainProducts.id;
            detalleTst.POCH_Sucursal__c 		 = this.mainBranchOffice.id;
            detalleTst.POCH_Codigo__c   		 = this.mainProducts.ProductCode;
            detalleTst.POCH_CantidadPotencial__c = '1';
            detalleTst.POCH_CantidadBase__c      = '1';
            detalleTst.POCH_EsBase__c 			 = '12';
            detalleTst.POCH_PrecioLista__c 		 = '12';
            detalleTst.POCH_EsPotencial__c 		 = '12';
            detalleTst.POCH_Estatus__c 			 = System.label.POCH_activeStatus;
            this.mainDetailSheet 			     = detalleTst;
        }
    }

    @IsTest
    static void testNewSheetAndDeleteSuccess(){
        Test.startTest();
            testDataWrapper testData = new testDataWrapper();
            String testResult = POCH_InventorySheet_cls.insertValuesDetailProduct('30',New list<sObject>{testData.mainDetailSheet},testData.mainBranchOffice.Id,testData.mainAccount.Id,false,testData.mainInvSheet.Id);
            List<POCH_DetalleInventario__c> detallesInventario = POCH_InventorySheet_cls.getDetailsInventorySheet(testData.mainDetailSheet.POCH_HojaInventario__c);
        	POCH_DetalleInventario__c di = [SELECT Id FROM POCH_DetalleInventario__c LIMIT 1];
        	POCH_InventorySheet_cls.deleteRecordOnDetail(di.Id);
            system.AssertEquals(Label.POCH_ok, testResult , 'Expected: '+ Label.POCH_ok + ' Received : ' + testResult);
            system.AssertEquals(true,detallesInventario.size() > 0 ,'Expected size > 0, returned: ' + detallesInventario.size());
        Test.stopTest();
    }

    @IsTest
    static void testNewSheetFail(){
        Test.startTest();
            testDataWrapper testData = new testDataWrapper();
            POCH_InventorySheet_cls.insertValuesDetailProduct('30',New list<sObject>{testData.mainDetailSheet},testData.mainBranchOffice.Id,testData.mainAccount.Id,false,'');
            String testResult = POCH_InventorySheet_cls.insertValuesDetailProduct('30',New list<sObject>{testData.mainDetailSheet},testData.mainBranchOffice.Id,testData.mainAccount.Id,false,'');
            system.AssertEquals(label.POCH_Error, testResult,  'Expected: '+ Label.POCH_Error + ' Received : ' + testResult);
        Test.stopTest();
    }

    @IsTest
    static void testMetadataValuesFrequence(){
        Test.startTest();
            List<String> frequences = POCH_InventorySheet_cls.getDataPickListValues('POCH_FrecuenciaCotizacion__mdt', null);
            system.AssertEquals(true,frequences.size() > 0,'Expected list size > 0');
        Test.stopTest();
    }

    @IsTest
    static void testCompetitionValues(){
        Test.startTest();
            POCH_Competencia__c competencia = new POCH_Competencia__c(Activa__c = true , name = 'testCompetition', Sociedad__c = '63');
            insert competencia;
            List<String> lstCompetencia = POCH_InventorySheet_cls.getDataPickListValues('POCH_Competencia__c', null);
            system.AssertEquals(true,lstCompetencia.size() > 0,'Expected list size > 0');
        Test.stopTest();
    }

    @IsTest
    static void testProductFieldsCmp(){
        Test.startTest();
        	POCH_InventorySheet_cls.PickListValuesIntoList('Opportunity','StageName');
            List<Object> fieldResult = POCH_InventorySheet_cls.getFieldList();        	
            system.AssertEquals(true,fieldResult.size() > 0,'Expected list size > 0');
        Test.stopTest();
    }
    
    @IsTest
    static void testQuoteSheetSuccess() {
        Test.startTest();
            testDataWrapper testData = new testDataWrapper();
            POCH_InventorySheet_cls.insertValuesDetailProduct('30',New list<sObject>{testData.mainDetailSheet},testData.mainBranchOffice.Id,testData.mainAccount.Id,false,'');
            String testResult = POCH_InventorySheet_cls.quoteCurrentSheet(testData.mainAccount.Id, testData.mainDetailSheet.POCH_HojaInventario__c, false);
        Test.stopTest();
    }
     @IsTest
    static void testQuoteSheetSuccessBacth() {
        Test.startTest();
            testDataWrapper testData = new testDataWrapper();
            POCH_InventorySheet_cls.insertValuesDetailProduct('30',New list<sObject>{testData.mainDetailSheet},testData.mainBranchOffice.Id,testData.mainAccount.Id,false,'');
            List<SBQQ__QuoteLine__c> testResult = POCH_InventorySheet_cls.quoteCurrentSheetBacht(testData.mainAccount.Id, testData.mainDetailSheet.POCH_HojaInventario__c, false);
        Test.stopTest();
    }
    @IsTest
    static void testInsertProduct() {
        Test.startTest();
            String jsonText = '[{"field":"Name","inputValue":"LPQH","tobject":"Product2"},'
                              +'{"field":"POCH_PrecioLista__c","inputValue":"1","tobject":"POCH_DetalleInventario__c"},'
                              +'{"field":"POCH_Moneda__c","inputValue":"MXN","tobject":"POCH_DetalleInventario__c"},'
                              +'{"field":"POCH_UnidadMedida__c","inputValue":"KG"},'
                              +'{"field":"ProductCode","inputValue":"1118","tobject":"Product2"}]';
            testDataWrapper testData = new testDataWrapper();
            POCH_InventorySheet_cls.insertProduct(jsonText, testData.mainInvSheet.Id, testData.mainBranchOffice.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testUM() {
        Test.startTest();
            testDataWrapper testData = new testDataWrapper();
            Decimal res = POCH_InventorySheet_cls.getUnitOfMeasureConversion(testData.mainProducts.Id, 'KG', 'KG');            
            System.assertEquals(1,res,'Factor Conversion = 1');
        Test.stopTest();
    }
    
    @IsTest
    static void testPriceInv() {
        Test.startTest();
            testDataWrapper testData = new testDataWrapper();
            POCH_InventorySheet_cls.getSpecialOrListPrice(testData.mainProducts.Id, testData.mainBranchOffice.Id, testData.mainAccount.Id, 500, 'KG'); 
        Test.stopTest();
    }
    
    @IsTest
    static void testUMP() {
        Test.startTest();
            testDataWrapper testData = new testDataWrapper();
            POCH_InventorySheet_cls.getUMP(testData.mainProducts.Id, testData.mainBranchOffice.Id); 
        Test.stopTest();
    }
    
    @IsTest
    static void testPriceUpdate() {
        Test.startTest();
            testDataWrapper testData = new testDataWrapper();
        	sObject[] arrSObj = new List<POCH_DetalleInventario__c>{testData.mainDetailSheet};
            POCH_InventorySheet_cls.actualizaPreciosItems(arrSObj, testData.mainBranchOffice.Name, testData.mainAccount.Id); 
        Test.stopTest();
    }
    
    @IsTest
    static void testDeleteSObject() {
        Test.startTest();
        	testDataWrapper testData = new testDataWrapper();
        	POCH_InventorySheet_helper.dmlOpportunity('delete',new List<sObject>{testData.mainInvSheet});
        Test.stopTest();
    }
    
    @IsTest
    static void testOppWithQuote() {
        Test.startTest();
        	Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        	POCH_OpportunityWithQuote owq = new POCH_OpportunityWithQuote();
        	owq.getOpportunity('');  
        	owq.getOpportunity(opp.Id);        	
        	owq.updateOppValues(new Map<String,String>{'Name' => 'Test'});
        Test.stopTest();
    }
    
    @IsTest
    static void testShowButtons() {
        Test.startTest();
            testDataWrapper testData = new testDataWrapper();
            POCH_InventorySheet_cls.getAutorizacion(testData.mainBranchOffice.Id); 
        Test.stopTest();
    }

    @IsTest
    static void testGetDescription() {
        Test.startTest();
        String objectType = 'POCH_DetalleInventario__c';
        String selectedField = 'Moneda_competencia__c';
        List<String> listApiField = new List<String>();
        listApiField.add('EUR');
        testDataWrapper testData = new testDataWrapper();
        POCH_InventorySheet_cls.getDescription(objectType, selectedField, listApiField); 
        Test.stopTest();
    }

    @IsTest
    static void testGetCountryFrecuencia() {
        Test.startTest();
        String strObject = 'POCH_FrecuenciaCotizacion__mdt';
        testDataWrapper testData = new testDataWrapper();
        POCH_InventorySheet_cls.getCountryListValues(strObject); 
        Test.stopTest();
    }

    @IsTest
    static void testGetCountryCompetencia() {
        Test.startTest();
        String strObject = 'POCH_Competencia__c';
        testDataWrapper testData = new testDataWrapper();
        POCH_InventorySheet_cls.getCountryListValues(strObject); 
        Test.stopTest();
    }
    
    /*@IsTest
    static void testGetUnidadesMedidas() {
        Test.startTest();       
        //String idProduct = prd.Id;
        List<String> listProducto = new List<String>();
		listProducto.add('');
        testDataWrapper testData = new testDataWrapper();
        POCH_InventorySheet_cls.getUnidadesMedidas(listProducto); 
        Test.stopTest();
    }
	*/
}