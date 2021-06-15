@IsTest
public class POCH_QuoteLineTest {
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
        
        SBQQ__Quote__c qt        = POCH_DataCreationTest.getQuote();
        qt.SBQQ__Account__c      = acc.Id;
        //qt.SBQQ__Opportunity2__c = opp.Id;
        qt.SBQQ__PriceBook__c    = pb.Id;
        qt.POCH_Sucursal__c      = suc.Id;
        insert qt;
    }   
    
    class testDataWrapper {
        public Account 					 mainAccount	  {get;set;}
        public Product2 				 mainProducts	  {get;set;}
        public POCH_Sucursal__c          mainBranchOffice {get;set;}        
        public POCH_DetalleInventario__c mainDetailSheet  {get;set;}
        public POCH_HojaInventario__c	 mainInvSheet	  {get;set;}
        public SBQQ__Quote__c			qt  {get;set;}
        
        
        public testDataWrapper() {
            this.mainAccount      = [Select Id FROM Account LIMIT 1];
            this.mainProducts     = [Select Id,ProductCode,Name FROM Product2 LIMIT 1];
            this.mainBranchOffice = [Select Id,Name FROM POCH_Sucursal__c LIMIT 1];
            this.mainInvSheet     = [Select Id FROM POCH_HojaInventario__c LIMIT 1];
            this.qt  = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];   
            
            POCH_DetalleInventario__c detalleTst = new POCH_DetalleInventario__c();
            detalleTst.POCH_Producto__c 		 = this.mainProducts.id;
            detalleTst.POCH_Sucursal__c 		 = this.mainBranchOffice.id;
            detalleTst.POCH_Codigo__c   		 = this.mainProducts.ProductCode;
            detalleTst.POCH_CantidadPotencial__c = '1';
            detalleTst.POCH_CantidadBase__c      = '1';
            detalleTst.POCH_EsBase__c 			 = '12';
            detalleTst.POCH_UnidadMedida__c      = '12';
            detalleTst.POCH_PrecioLista__c 		 = '12';
            detalleTst.POCH_EsPotencial__c 		 = '12';
           // detalleTst.POCH_IsMonthly__c 	     = true;
            detalleTst.POCH_Moneda__c 	         = 'MXN';
            detalleTst.POCH_Estatus__c 			 = System.label.POCH_activeStatus;
            this.mainDetailSheet 			     = detalleTst;
            
            /* quoteLine.POCH_IsMonthly__c			= true;
        quoteLine.EsInventario__c = true;
        this.innerQuoteLine = quoteLine;*/
        }
    }
    
    @IsTest
    static void testCreateQuoteProducts(){
        Test.startTest();
        testDataWrapper testData = new testDataWrapper();
        Map<Id,Id>     mapPrdPBE = new Map<Id,String>();
        POCH_Quote Qoute = new POCH_Quote();
      
        for(PricebookEntry pbe : [SELECT Id,Product2Id,CurrencyIsoCode FROM PricebookEntry WHERE Product2Id  =: testData.mainProducts.Id ]) 
        {
            mapPrdPBE.put(pbe.Product2Id, pbe.Id);                             
        }
        String testResult = POCH_InventorySheet_cls.insertValuesDetailProduct('30',New list<sObject>{testData.mainDetailSheet},testData.mainBranchOffice.Id,testData.mainAccount.Id,false,testData.mainInvSheet.Id);
        List<POCH_DetalleInventario__c> detallesInventario = POCH_InventorySheet_cls.getDetailsInventorySheet(testData.mainDetailSheet.POCH_HojaInventario__c);
        POCH_DetalleInventario__c[] di = [SELECT Id,POCH_Producto__c FROM POCH_DetalleInventario__c LIMIT 1];
      
        SBQQ__Quote__c qo  = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];   
        Product2 p     = [Select Id,ProductCode,Name FROM Product2 LIMIT 1];
        POCH_DetalleInventario__c din = [SELECT Id,  POCH_Producto__c,POCH_Sucursal__c,POCH_Codigo__c,POCH_UnidadMedida__c, POCH_Moneda__c,POCH_CantidadPotencial__c,POCH_CantidadBase__c,POCH_EsBase__c,POCH_PrecioLista__c,POCH_EsPotencial__c,POCH_Estatus__c FROM POCH_DetalleInventario__c LIMIT 1];
        PricebookEntry precioBook = [SELECT Id FROM PricebookEntry LIMIT 1];
        string precioBooks = precioBook.id;
        
        POCH_QuoteLine qln = new POCH_QuoteLine(qo,din,precioBooks);
        
        system.AssertEquals(Label.POCH_ok, testResult , 'Expected: '+ Label.POCH_ok + ' Received : ' + testResult);
        system.AssertEquals(true,detallesInventario.size() > 0 ,'Expected size > 0, returned: ' + detallesInventario.size());
        Test.stopTest();
    }
    
}