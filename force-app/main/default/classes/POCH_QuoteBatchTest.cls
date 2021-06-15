@isTest
public class POCH_QuoteBatchTest {
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
        hi.POCH_Cuenta__c = acc.Id;
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
    public static testMethod void testQuoteBatch() {
         testDataWrapper testData = new testDataWrapper();
        
       
        
        Test.startTest();
			POCH_QuoteBatch_Sch sch = new POCH_QuoteBatch_Sch();
            system.schedule('Test Territory Check', '0 0 1 * * ?', sch);        
            POCH_QuoteBatch qtBatch = new POCH_QuoteBatch();
            DataBase.executeBatch(qtBatch);             
        Test.stopTest();
    }
    
}