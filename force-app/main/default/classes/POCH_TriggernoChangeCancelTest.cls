@isTest
public class POCH_TriggernoChangeCancelTest {
public static testMethod void testPOCH_CancelaQuoteForTime() {
        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;
        
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        
        insert reg;
        
        Account acc = POCH_DataCreationTest.getAccount();
        acc.POCH_TipoRegistro__c = 'Prospecto';
        acc.POCH_Region__c = reg.Id;
        
        insert acc;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal();
        suc.POCH_Centro__c   = 'CENTRO';
        suc.POCH_Sociedad__c = '400';
        
        insert suc;
        
        POCH_precio_sugerido__c  sPsuge		   = new POCH_precio_sugerido__c ();
        sPsuge.cod_producto__c  = '181114';
        sPsuge.sucursal__c          = '0049';
        sPsuge.sociedad__c   = '63';
        insert sPsuge;
        
        POCH_precio_sugerido__c  sPsuge1		   = new POCH_precio_sugerido__c ();
        sPsuge1.cod_producto__c  = '181114';
        sPsuge1.sucursal__c          = '';
        sPsuge1.sociedad__c   = '';
        insert sPsuge1;
        
        POCH_precio_sugerido__c  sPsuge2		   = new POCH_precio_sugerido__c ();
        sPsuge2.cod_producto__c  = '181114';
        sPsuge2.sucursal__c          = '0049';
        sPsuge2.sociedad__c   = '';
        insert sPsuge2;
        /*  Equipo_Vendedores__c vend  = new Equipo_Vendedores__c();
vend.Acceso_Cliente__c  = 'Escritura';
vend.Acceso_Opportunity__c = 'Escritura';
insert vend;*/
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        // sam.Equipo_Vendedor__c= vend.id;
        insert sam;
        
        Pricebook2 pb = POCH_DataCreationTest.getCustomPricebook();
        pb.POCH_Sucursal__c = suc.Id;
        insert pb;
        
        Product2 prd = POCH_DataCreationTest.getProduct();
        insert prd; 
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prd.Id;
        pbe.Pricebook2Id = pb.Id;
        pbe.UnitPrice = 10;
        pbe.POCH_UnidadMedidaEscala__c = 'KG';  
        pbe.UnitPrice = 1;
        pbe.IsActive = true;
        insert pbe;
        System.debug('>>>>>> PBE ' + pbe);
        
        CE_Suministradores__c sumi = new CE_Suministradores__c();
        sumi.Centro__c = 'CLAR';
        sumi.Material__c = prd.Id;
        sumi.Organizacion_de_ventas__c = '0049';
        sumi.Sucursal__c = suc.id;
        
        insert sumi;
        SBQQ__DiscountSchedule__c ds = POCH_DataCreationTest.getDiscountSchedule();
        ds.SBQQ__Product__c          = prd.Id;
        ds.SBQQ__Pricebook__c        = pb.Id;
        insert ds;
        
        List<SBQQ__DiscountTier__c> lDT = new List<SBQQ__DiscountTier__c>();
        for(Integer i=1; i <= 3; i++) {
            SBQQ__DiscountTier__c dt 	= POCH_DataCreationTest.getDiscountTier();
            dt.SBQQ__Number__c          = dt.SBQQ__Number__c + i;    
            dt.SBQQ__LowerBound__c 		= dt.SBQQ__LowerBound__c + i;
            dt.POCH_ImporteCondicion__c = dt.POCH_ImporteCondicion__c - i;
            dt.SBQQ__Schedule__c 		= ds.Id;                
            dt.POCH_IdExterno__c 		= ds.POCH_IdExterno__c + String.valueOf(i);
            lDT.add(dt);
        }
        insert lDT; 
        
        lDT[0].POCH_ImporteUpper__c  = 7;
        lDT[1].POCH_ImporteUpper__c  = 7;
        lDT[2].POCH_ImporteUpper__c  = 7; 
        
        List<POCH_UnidadMedidaProducto__c> umList = new List<POCH_UnidadMedidaProducto__c>();
        POCH_UnidadMedidaProducto__c um = POCH_DataCreationTest.getUM();        
        um.POCH_Producto__c  = prd.Id;
        um.POCH_IdExterno__c += '1';
        umList.add(um);
        POCH_UnidadMedidaProducto__c um2 = POCH_DataCreationTest.getUM();
        um2.POCH_UMA__c		 = 'LT'; 
        um2.POCH_Producto__c = prd.Id;
        umList.add(um2);        
        insert umList;
        
        List<POCH_ValoracionProducto__c> vpList = new List<POCH_ValoracionProducto__c>();
        POCH_ValoracionProducto__c vp = POCH_DataCreationTest.getVP();
        vp.POCH_Producto__c = prd.Id;
        vp.POCH_IdExterno__c += '1';
        vpList.add(vp);
        POCH_ValoracionProducto__c vp2 = POCH_DataCreationTest.getVP();
        vp2.POCH_Producto__c = prd.Id;
        vpList.add(vp2);
        insert vpList;
             Test.startTest();
       try {
           
        
       
        
        SBQQ__Quote__c qt        = POCH_DataCreationTest.getQuote();
        qt.SBQQ__Account__c      = acc.Id;
        qt.POCH_Sucursal__c		 = suc.Id;
        // qt.CurrencyIsoCode      = 'USD';
        //qt.POCH_ValidaAutorizaciones__c = true;
        //qt.SBQQ__Opportunity2__c = opp.Id;
        insert qt;
        
               
        SBQQ__ContractedPrice__c cprec =  POCH_DataCreationTest.getPrecioEspecial(); 
        cprec.Margen__c = 150;  
        cprec.SBQQ__Product__c = prd.Id;
        cprec.SBQQ__Account__c = acc.id;
        insert cprec;
        
        Datetime fechaInicio = Datetime.now();
        Datetime FechaCancelacion = Datetime.now();
        
        SBQQ__QuoteLine__c ql = POCH_DataCreationTest.getQuoteLine();
        ql.fecha_inicio__c = fechaInicio;
        ql.fecha_cancelacion__c = FechaCancelacion; 
        ql.SBQQ__Product__c   = prd.Id;
        ql.SBQQ__Quote__c     = qt.Id;
        ql.Descuento__c       =  10;
        ql.POCH_PrecioUnitario__c = 0.8;
        //ql.POCH_OrgVentasQuote__c = sumi.Organizacion_de_ventas__c;
        // ql.POCH_CentroSucursal__c = suc.POCH_Centro__c;
        ql.SBQQ__ContractedPrice__c = cprec.id;
        ql.Organizaci_n_de_Ventas__c = sumi.Organizacion_de_ventas__c;
        ql.Motivo_de_cancelaci_n__c = 'FA';
        //   ql.Centro__c          = sumi.Centro__c;      
        ql.SBQQ__PricebookEntryId__c = pbe.Id;
        ql.POCH_WF__c    = 'POCH_WFEscalaVolumen';
        ql.SBQQ__DiscountSchedule__c = ds.Id;
        ql.SBQQ__DiscountTier__c     = lDT[2].Id;
        ql.POCH_UnidadMedidaVenta__c  = 'KG';
        ql.POCH_CantidadVenta__c = 1;
        
        insert ql;
        
         Test.startTest();
        Set<Id> qto = new Set<Id>();
        qt.Tiempo_cancelacion__c = '24';
        qt.POCH_EstatusCotizacion__c = 'Cancelado';
        update qt;

        
        POCH_ValoracionProducto__c val = new POCH_ValoracionProducto__c();
        val.POCH_Producto__c = prd.id;
        val.POCH_Activo__c = true;
        val.POCH_AreaValoracion__c = suc.POCH_Centro__c;
        val.POCH_IdExterno__c 		  = 'SUACAMPEXT';
        insert val;
        
        List<SBQQ__QuoteLine__c> lCPQQuoteLines = new List<SBQQ__QuoteLine__c>();
      
        
     
        SBQQ__QuoteLine__c qls = new SBQQ__QuoteLine__c();
        qls.id = ql.id;
        qls.Descuento__c = 10;
      
        qls.POCH_PrecioUnitario__c = 5;
        ql.POCH_UnidadMedidaVenta__c  = 'L';
        ql.SBQQ__CustomerPrice__c = 0.1;
        // update qls;
        //SBQQ__CustomerPrice__c < centroCPQ.SBQQ__listPrice__c
        }catch(Exception e) {
            System.assert(e.getMessage().contains('No puede cambiar el status en este estapa de cancelación'));
        }
     
        Test.stopTest();
    }
}