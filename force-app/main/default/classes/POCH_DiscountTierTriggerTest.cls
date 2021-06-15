@isTest
private  class POCH_DiscountTierTriggerTest {    

      static testMethod void testDiscountTier() {
       
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
        
        PricebookEntry pbe  = POCH_DataCreationTest.getPBEntry();
        pbe.Pricebook2Id = pb.Id;
        pbe.Product2Id   = prd.Id;
        insert pbe;                                                             
              
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
        qt.SBQQ__PriceBook__c = pb.id;
        //qt.POCH_UnidadesMedida__c = 'UM';
        insert qt;
        
        SBQQ__QuoteLine__c ql = POCH_DataCreationTest.getQuoteLine();
        ql.POCH_EstatusPartida__c = 'Solicitado Autorizado';
        ql.SBQQ__Product__c   = prd.Id;
        ql.SBQQ__Quote__c     = qt.Id;
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
        
        List<SBQQ__DiscountTier__c> lDT = new List<SBQQ__DiscountTier__c>();
        for(Integer i=1; i <= 5; i++) {
            SBQQ__DiscountTier__c dt = POCH_DataCreationTest.getDiscountTier();
            dt.SBQQ__Number__c = dt.SBQQ__Number__c + i;
            dt.SBQQ__LowerBound__c = dt.SBQQ__LowerBound__c + i;
            dt.POCH_ImporteCondicion__c = dt.POCH_ImporteCondicion__c - i;
            dt.SBQQ__Schedule__c = ds.Id;
            dt.POCH_IdExterno__c = ds.POCH_IdExterno__c + String.valueOf(i);
            lDT.add(dt);
        }                
		
      //  dt.POCH_Pricebook__c = pbe.id;
      
          
          SBQQ__DiscountTier__c dt 	   = new SBQQ__DiscountTier__c();
        dt.Name 				 	   = 'DT TEST';
        dt.POCH_NoRegistroCondicion__c = '181114_S';
        dt.POCH_IdExterno__c 		   = 'DTEXTId';
        dt.SBQQ__Number__c 			   = 0;
        dt.SBQQ__LowerBound__c 		   = 0;
        dt.SBQQ__UpperBound__c         = 1;
        dt.POCH_ImporteCondicion__c    = 6;
        dt.SBQQ__Schedule__c = ds.Id;
        lDT.add(dt);
        insert lDT;    
        
        SBQQ__DiscountSchedule__c ds2 = POCH_DataCreationTest.getDiscountSchedule();
        ds2.SBQQ__Product__c = prd.Id;
        ds2.SBQQ__Pricebook__c = pb.Id;
        ds2.POCH_NoRegCondicion__c = 'nrc';
        ds2.POCH_IdExterno__c      = 'pix';
        insert ds2;
              Test.startTest(); 
          POCH_DiscountTierTriggerService.validateStatusQuoteLine(lDT);
              Test.stopTest();
    }
    
}