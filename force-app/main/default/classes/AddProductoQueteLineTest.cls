@isTest
private  class AddProductoQueteLineTest {
    static testMethod void testAddProductoQueteLine() {
        
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
        prd.Family = 'PP_SBS';
        prd.Description ='amoniaco';
        prd.Name ='amoniaco';
        prd.IsActive  = true;
        prd.onlyInSalesforce__c = false;
        insert prd;   
         //UnitPrice,Product2.Family,Grupo_de_Materiales__c, Product2Id,ProductCode,Name,CurrencyIsoCode,Product2.ProductCode,Product2.Name,Product2.Description,Product2.POCH_GrupoMateriales2__c
            //IsActive = true AND Product2.IsActive = true AND Product2.onlyInSalesforce__c = false
            
            PricebookEntry pbelis  = new PricebookEntry();
            pbelis.Product2Id         = prd.id;
            pbelis.Pricebook2Id       =  pb.id;
            pbelis.IsActive           = true;
            pbelis.POCH_CanalDistribucion__c 	= '12';
            pbelis.POCH_CantidadBase__c 		= 1;
            pbelis.POCH_FinValidez__c 		= Date.today() + 30;
            pbelis.POCH_IdExterno__c 			= 'IDEXTPBET';
            pbelis.POCH_InicioValidez__c 		= Date.today() - 1;
            pbelis.POCH_NoRegCondicion__c 	= '181114_C';
            pbelis.POCH_OrganizacionVentas__c = '0049';
            pbelis.POCH_UnidadMedidaEscala__c = 'KG';
            pbelis.Unidad_de_medida__c 		= 'KG';
            pbelis.UnitPrice          =   25.0;
            pbelis.CurrencyIsoCode    =   'MXN';
            pbelis.Grupo_de_Materiales__c    =   '';
             
            insert pbelis;
        
        
        
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
        qt.SBQQ__Account__c      = acc.Id;
        qt.SBQQ__Opportunity2__c = opp.Id;
       // qt.SBQQ__PriceBook__c = pbelis.id;
        qt.SBQQ__PricebookId__c = pb.id;
        qt.SBQQ__PriceBook__c = pb.id;
        qt.CurrencyIsoCode = 'MXN';
        qt.SBQQ__EndDate__c = Date.today() + 20;
        qt.POCH_EstatusCotizacion__c = 'Abierta';
   
        insert qt;
        
        SBQQ__QuoteLine__c ql = POCH_DataCreationTest.getQuoteLine();
        ql.POCH_EstatusPartida__c = 'Solicitado Autorizado';
        ql.SBQQ__Product__c   = prd.Id;
        ql.SBQQ__Quote__c     = qt.Id;
        ql.SBQQ__CustomerPrice__c = 252;
        ql.POCH_EstatusPartida__c = 'Precio de Lista';
        ql.POCH_PrecioUnitario__c	= Decimal.valueOf(detalleTst.POCH_PrecioLista__c);
        ql.SBQQ__PricebookEntryId__c =pb.Id;
    
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
         
        List<Id> lstId = new List<Id>();
        
           for(PricebookEntry pber : [select id ,UnitPrice,Product2.Family,Grupo_de_Materiales__c, Product2Id,ProductCode,Name,CurrencyIsoCode,Product2.ProductCode,Product2.Name,Product2.Description,Product2.POCH_GrupoMateriales2__c  FROM PricebookEntry limit 1]){
            
            lstId.add(pber.id);
        }
        
        Test.startTest(); 
        
        AddProductoQueteLine.fetchPreciEntry(qt.id);
        AddProductoQueteLine.addProductos(lstId, qt.id);
        Test.stopTest();
        
    }
    
    
    
}