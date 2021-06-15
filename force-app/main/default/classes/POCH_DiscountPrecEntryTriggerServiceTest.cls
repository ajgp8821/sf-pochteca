@isTest
private  class POCH_DiscountPrecEntryTriggerServiceTest {    
    
    static testMethod void testDiscountPrecEntry() {
        
        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;
        
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        Account acc = POCH_DataCreationTest.getAccount();
        
        insert acc;
         
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal();
        suc.POCH_Sociedad__c = '400';
        insert suc;
        
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
        
        
            PricebookEntry pbelis1  = new PricebookEntry();
            pbelis1.Pricebook2Id = pb.Id;
            pbelis1.Product2Id   = prd.Id;
         
            pbelis1.Product2Id         = prd.id;
            pbelis1.Pricebook2Id       =  pb.id;
            pbelis1.UnitPrice          =   12.0;
            insert pbelis1;
        
        
        
        List<POCH_PricebookEntryTemp__c> lDTemp = new List<POCH_PricebookEntryTemp__c>();
        List<PricebookEntry> lDprecioUpdate = new List<PricebookEntry>();
        for(Integer i=1; i <= 5; i++) {
            
            POCH_PricebookEntryTemp__c pbet = new POCH_PricebookEntryTemp__c();
            pbet.CurrencyIsoCode 			= 'MXN';
            pbet.POCH_IsActive__c 			= true;
            pbet.POCH_CanalDistribucion__c 	= '12';
            pbet.POCH_CantidadBase__c 		= 1;
            pbet.POCH_FinValidez__c 		= Date.today() + 30;
            pbet.POCH_IdExterno__c 			= 'IDEXTPBET';
            pbet.POCH_InicioValidez__c 		= Date.today() - 1;
            pbet.POCH_NoRegCondicion__c 	= '181114_C';
            pbet.POCH_OrganizacionVentas__c = '0049';
            pbet.POCH_UnidadMedidaEscala__c = 'KG';
            pbet.Unidad_de_medida__c 		= 'KG';
            pbet.POCH_UnitPrice__c 			= 6; 
            
            PricebookEntry pbelis  = new PricebookEntry();
            pbelis.Pricebook2Id = pb.Id;
            pbelis.Product2Id   = prd.Id;
            pbelis.POCH_IdExterno__c =  pbet.POCH_IdExterno__c ;
            pbelis.Product2Id         = prd.id;
            pbelis.Pricebook2Id       =  pb.id;
            pbelis.UnitPrice          =   25.0;
          //[Pricebook2Id, Product2Id]: [Pricebook2Id, Product2Id]
            pbelis.POCH_NoRegCondicion__c 	   = pbet.POCH_NoRegCondicion__c;
            pbelis.POCH_OrganizacionVentas__c =  pbet.POCH_OrganizacionVentas__c;
        
            pbelis.Unidad_de_medida__c 	   =     pbet.Unidad_de_medida__c;
            pbelis.POCH_UnidadMedidaEscala__c =  pbet.POCH_UnidadMedidaEscala__c;
            lDprecioUpdate.add(pbelis); 
            lDTemp.add(pbet);
        }
        // insert pbet;
        
        
        
        POCH_OpportunityTriggerService.isInvokedByTrigger = true;
        Opportunity opp      = POCH_DataCreationTest.getOpportunity();
        opp.AccountId        = acc.Id;
        opp.POCH_Sucursal__c = suc.Id;
        opp.Pricebook2Id     = pb.Id;
        opp.StageName        = 'Closed Won';
        insert opp;
        
        POCH_UnidadMedidaProducto__c um = new POCH_UnidadMedidaProducto__c();
        um.POCH_UnidadPeso__c 			= 'KG';
        um.POCH_UMA__c        			= 'KG';
        um.POCH_Denominador__c			= 1;	
        um.POCH_Numerador__c			= 1;
        um.POCH_IdExterno__c 			= 'IDEXTUM';
        um.POCH_Producto__c = prd.id;
        insert um;
        
        
        POCH_DetalleInventario__c detalleTst = new POCH_DetalleInventario__c();
        detalleTst.POCH_Producto__c 		 = prd.id;
        detalleTst.POCH_Sucursal__c 		 = suc.id;
        //detalleTst.POCH_Codigo__c   		 = prd.ProductCode;
        detalleTst.POCH_CantidadPotencial__c = '1';
        detalleTst.POCH_CantidadBase__c      = '1';
        detalleTst.POCH_EsBase__c 			 = '12';
        detalleTst.POCH_PrecioLista__c 		 = '12';
        detalleTst.POCH_EsPotencial__c 		 = '12';
        
        detalleTst.POCH_Estatus__c 			 = System.label.POCH_activeStatus;
        detalleTst.POCH_UnidadMedida__c   = 'KG';
        insert detalleTst;
        
         SBQQ__Quote__c qt        = POCH_DataCreationTest.getQuote();
        String todate = '01/01/2021';
         Date dt = Date.parse(todate);
        qt.SBQQ__Account__c      = acc.Id;
        qt.SBQQ__Opportunity2__c = opp.Id;
        qt.SBQQ__PriceBook__c = pb.id;
        qt.SBQQ__StartDate__c = dt;
        //qt.POCH_UnidadesMedida__c = 'UM';
        insert qt;
        
        SBQQ__QuoteLine__c ql = POCH_DataCreationTest.getQuoteLine();
        ql.POCH_EstatusPartida__c = 'Solicitado Autorizado';
        ql.SBQQ__Product__c   = prd.Id;
        ql.SBQQ__Quote__c     = qt.Id;
        ql.SBQQ__CustomerPrice__c = 252;
        ql.POCH_EstatusPartida__c = 'Precio de Lista';
        ql.POCH_PrecioUnitario__c	= Decimal.valueOf(detalleTst.POCH_PrecioLista__c);
        //
        
        ql.SBQQ__PricebookEntryId__c =pb.Id;
        //
        ql.POCH_UnidadMedidaVenta__c = detalleTst.POCH_UnidadMedida__c;
        ql.POCH_CantidadVenta__c     = Decimal.valueOf(detalleTst.POCH_CantidadBase__c);
        ql.CurrencyIsoCode           = 'MXN';
        ql.POCH_IsMonthly__c			= true;
        ql.SBQQ__EndDate__c         = Date.today().AddDays(10);
        insert ql;                
        
        SBQQ__DiscountSchedule__c ds = POCH_DataCreationTest.getDiscountSchedule();
        ds.SBQQ__Product__c = prd.Id;
        ds.SBQQ__Pricebook__c = pb.Id;
        ds.SBQQ__Quote__c   = qt.id;
        ds.SBQQ__QuoteLine__c   = ql.id;
        ds.POCH_NoRegCondicion__c = '';
        insert ds;
        
        
        
        List<PricebookEntry> lDT = new List<PricebookEntry>();
        for(PricebookEntry pber : [SELECT Id,POCH_IdExterno__c,Product2Id,Pricebook2Id,UnitPrice,POCH_MargenMinVariacion__c,POCH_MargenMaxVariacion__c  FROM PricebookEntry where UnitPrice = 12 limit 1]){
            
            lDT.add(pber);
        }
        
        SBQQ__DiscountSchedule__c ds2 = POCH_DataCreationTest.getDiscountSchedule();
        ds2.SBQQ__Product__c = prd.Id;
        ds2.SBQQ__Pricebook__c = pb.Id;
        ds2.POCH_NoRegCondicion__c = 'nrc';
        ds2.POCH_IdExterno__c      = 'pix';
        insert ds2;
        
        
        Test.startTest(); 
     //public static void validateStatusQuoteLine(List<PricebookEntry> lDiscountPrecEntry, Double precio,List<PricebookEntry> lPBE_Insert,boolean activo) {
        POCH_DiscountPrecEntryTriggerService.validateStatusQuoteLine(lDT, 500, lDprecioUpdate,true);
        Test.stopTest();
    }
}