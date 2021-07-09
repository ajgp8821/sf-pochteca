@isTest
public class POCH_DataCreationTest {            
    
    public static testMethod Account getAccount() {
        Account acc 				   	= new Account();
        acc.Name 					   	= 'ACC TEST';
        acc.Phone						= '5536848775';
        acc.POCH_IDClienteSAP__c 	   	= '181114';
        acc.POCH_CorreoElectronico__c  	= 'test@mail.com';
        acc.POCH_TipoRegistro__c       	= 'Prospecto';
        acc.POCH_OrganizacionVentas__c 	= '0049';
        acc.CurrencyIsoCode			   	= 'MXN';
        acc.BillingStreet			   	= 'Calle';
        acc.BillingPostalCode		   	= '02400';
        acc.BillingCity				   	= 'CDMX';
        acc.BillingCountry				= 'MEXICO';
        acc.POCH_PaisFactura__c			= 'MX';
        acc.POCH_Incoterms__c		   	= 'CF';
        acc.POCH_GrupoClientes__c	   	= '01';        
        //acc.POCH_ClasificacionFiscal__c	= '0';
        acc.POCH_RFC__c 				= 'PCH910211C39';
        acc.POCH_IdentificacionOficial__c = true;
        acc.POCH_ComprobanteDomicilio__c  = true;
        acc.POCH_5Gerente__c 			= true;
        acc.POCH_10Vendedor__c 			= false;
        acc.POCH_15Sucursal__c			= false;
        return acc;
    }
    
    public static testMethod Account getAccountNoIdSAP() {
        Account acc 				   	= new Account();
        acc.Name 					   	= 'ACC TEST2';
        acc.Phone						= '5536848772';
        acc.POCH_CorreoElectronico__c  	= 'test2@mail.com';
        acc.POCH_TipoRegistro__c       	= 'Prospecto';
        acc.POCH_OrganizacionVentas__c 	= '0013';
        acc.CurrencyIsoCode			   	= 'MXN';
        acc.BillingStreet			   	= 'Calle';
        acc.BillingPostalCode		   	= '02400';
        acc.BillingCity				   	= 'CDMX';
        acc.BillingCountry				= 'MEXICO';
        acc.POCH_PaisFactura__c			= 'MX';
        acc.POCH_Incoterms__c		   	= 'CF';
        acc.POCH_GrupoClientes__c	   	= '01';        
        //acc.POCH_ClasificacionFiscal__c	= '0';
        acc.POCH_RFC__c 				= 'PCH910211C39';
        acc.POCH_IdentificacionOficial__c = true;
        acc.POCH_ComprobanteDomicilio__c  = true;
        acc.POCH_5Gerente__c 			= true;
        acc.POCH_10Vendedor__c 			= false;
        acc.POCH_15Sucursal__c			= false;
        return acc;
    }   

	public static testMethod Account getAccountIdSAPCLiente() {
        Account acc 				   	= new Account();
        acc.POCH_IDClienteSAP__c 	   	= '181114';
        acc.Name 					   	= 'ACC TEST3';
        acc.Phone						= '5536848772';
        acc.POCH_CorreoElectronico__c  	= 'test3@mail.com';
        acc.POCH_TipoRegistro__c       	= 'Cliente';
        acc.POCH_OrganizacionVentas__c 	= '0049';
        acc.CurrencyIsoCode			   	= 'MXN';
        acc.BillingStreet			   	= 'Calle';
        acc.BillingPostalCode		   	= '02400';
        acc.BillingCity				   	= 'CDMX';
        acc.BillingCountry				= 'MEXICO';
        acc.POCH_PaisFactura__c			= 'MX';
        acc.POCH_Incoterms__c		   	= 'CF';
        acc.POCH_GrupoClientes__c	   	= '01';        
        //acc.POCH_ClasificacionFiscal__c	= '0';
        acc.POCH_RFC__c 				= 'PCH910211C39';
        acc.POCH_IdentificacionOficial__c = true;
        acc.POCH_ComprobanteDomicilio__c  = true;
        acc.POCH_5Gerente__c 			= true;
        acc.POCH_10Vendedor__c 			= false;
        acc.POCH_15Sucursal__c			= false;
        acc.POCH_GrupoVendedores__c     = '974';
        acc.POCH_OficinaVentas__c       = '9130';
        acc.POCH_CentroSuministrador__c = 'GDSJ';
        return acc;
    }     
    
    public static testMethod Account getAccountIdSAPSospechoso() {
        Account acc 				   	= new Account();
        acc.POCH_IDClienteSAP__c 	   	= '181114';
        acc.Name 					   	= 'ACC TEST3';
        acc.Phone						= '5536848772';
        acc.POCH_CorreoElectronico__c  	= 'test4@mail.com';
        acc.POCH_TipoRegistro__c       	= 'Sospechoso';
        acc.POCH_OrganizacionVentas__c 	= '0049';
        acc.CurrencyIsoCode			   	= 'MXN';
        acc.BillingStreet			   	= 'Calle';
        acc.BillingPostalCode		   	= '02400';
        acc.BillingCity				   	= 'CDMX';
        acc.BillingCountry				= 'MEXICO';
        acc.POCH_PaisFactura__c			= 'MX';
        acc.POCH_Incoterms__c		   	= 'CF';
        acc.POCH_GrupoClientes__c	   	= '01';        
        //acc.POCH_ClasificacionFiscal__c	= '0';
        acc.POCH_RFC__c 				= 'PCH910211C39';
        acc.POCH_IdentificacionOficial__c = true;
        acc.POCH_ComprobanteDomicilio__c  = true;
        acc.POCH_5Gerente__c 			= true;
        acc.POCH_10Vendedor__c 			= false;
        acc.POCH_15Sucursal__c			= false;
        acc.POCH_GrupoVendedores__c     = '974';
        acc.POCH_OficinaVentas__c       = '9130';
        acc.POCH_CentroSuministrador__c = 'GDSJ';
        return acc;
    }  
    
    public static testMethod POCH_Sucursal__c getSucursal() {
        POCH_Sucursal__c suc 		   = new POCH_Sucursal__c();
        suc.Name 					   = 'POCHTECA';
        suc.POCH_Centro__c 			   = 'CENTRO';
        suc.POCH_Denominacion__c 	   = 'DEN';
        suc.POCH_OficinaVentas__c 	   = '010';
        suc.POCH_OrganizacionVentas__c = '0049';
        suc.POCH_Sociedad__c 		   = '63';
        suc.CurrencyIsoCode            = 'BRL';
        return suc;
    }
    
    //POCH_precio_sugerido__C
        public static testMethod POCH_precio_sugerido__c  getPrecioSugerido() {
        POCH_precio_sugerido__c  sPsuge		   = new POCH_precio_sugerido__c ();
        //sPsuge.cod_producto__c sPsuge.Valida_Sucursal__c sPsuge.Valida_Sociedad__c sPsuge.sociedad__c sPsuge.sucursal__c sPsuge.invalido__c
        //	50391	true	false	63	0049
        sPsuge.cod_producto__c  = '181114';
       // sPsuge.Valida_Sucursal__c = true;
        //sPsuge.Valida_Sociedad__c  = '63';
        sPsuge.sucursal__c          = '0049';
        sPsuge.sociedad__c   = '63';
        return sPsuge;
    }
    
    public static testMethod POCH_Sucursal__c getSucursalMxn() {
        POCH_Sucursal__c suc 		   = new POCH_Sucursal__c();
        suc.Name 					   = 'POCHTECA';
        suc.POCH_Centro__c 			   = 'CENTRO';
        suc.POCH_Denominacion__c 	   = 'DEN';
        suc.POCH_OficinaVentas__c 	   = '010';
        suc.POCH_OrganizacionVentas__c = '0049';
        suc.POCH_Sociedad__c 		   = '63';
        suc.CurrencyIsoCode            = 'MXN';
        return suc;
    }
    
    public static testMethod POCH_Sucursal__c getSucursal2() {
        POCH_Sucursal__c suc 		   = new POCH_Sucursal__c();
       suc.Name 					   = 'POCHTECA';
        suc.POCH_Centro__c 			   = 'CENTRO';
        suc.POCH_Denominacion__c 	   = 'DEN';
        suc.POCH_OficinaVentas__c 	   = '010';
        suc.POCH_OrganizacionVentas__c = '0049';
        suc.POCH_Sociedad__c 		   = '412';
        suc.CurrencyIsoCode            = 'BRL';
        return suc;
    }
    
    public static testMethod POCH_Sucursal__c getSucursalSinOrgVenta() {
        POCH_Sucursal__c suc 		   = new POCH_Sucursal__c();
        suc.Name 					   = 'POCHTECA2';
        suc.POCH_Centro__c 			   = 'CENTRO2';
        suc.POCH_Denominacion__c 	   = 'DEN';
        suc.POCH_OficinaVentas__c 	   = '010';
        suc.POCH_Sociedad__c 		   = '63';                
        return suc;
    }
    
    public static testMethod POCH_SucursalAmpliada__c getSucursalAmp() {
        POCH_SucursalAmpliada__c sa   = new POCH_SucursalAmpliada__c();
        sa.POCH_10Vendedor__c 		  = false;
        sa.POCH_15Sucursal__c 		  = false;
        sa.POCH_5Gerente__c 		  = true;
        sa.POCH_CorreoElectronico1__c = 'test@mail.com';
        sa.POCH_CorreoElectronico2__c = 'test@mail.com';
        sa.POCH_CorreoElectronico3__c = 'test@mail.com';
        sa.POCH_CorreoElectronico4__c = 'test@mail.com';
        sa.POCH_CorreoElectronico5__c = 'test@mail.com';
        sa.POCH_GrupoClientes__c 	  = '01';
        sa.POCH_GrupoClientes2__c 	  = 'LIB';
        sa.POCH_IdExterno__c 		  = 'SUACAMPEXT';
        sa.POCH_ZonaVentas__c 		  = '913012';
        return sa;
    }
    
    public static testMethod Product2 getProduct() {
        Product2 producto 					= new Product2();
        producto.name 						= 'Material';
        producto.CurrencyIsoCode 			= 'MXN';
        producto.onlyInSalesforce__c 		= false;
        producto.POCH_Critico__c 			= true;
        producto.POCH_IdProductoSAP__c      = '181114';
        producto.POCH_MargenMaxVariacion__c = 10;
        producto.POCH_MargenMinVariacion__c = 5;
        producto.POCH_UnidadVenta__c 		= 'KG';
        producto.ProductCode 				= '181114';
        producto.QuantityUnitOfMeasure 		= 'KG';
        producto.StockKeepingUnit 			= '181114';
        return producto;
    } 
    
    public static testMethod POCH_UnidadMedidaProducto__c getUM() {
        POCH_UnidadMedidaProducto__c um = new POCH_UnidadMedidaProducto__c();
        um.POCH_UnidadPeso__c 			= 'KG';
        um.POCH_UMA__c        			= 'KG';
        um.POCH_Denominador__c			= 1;	
        um.POCH_Numerador__c			= 1;
        um.POCH_IdExterno__c 			= 'IDEXTUM';
        return um;
    }
    
    public static testMethod POCH_ProductoSucursal__c getPS() {
        POCH_ProductoSucursal__c ps  = new POCH_ProductoSucursal__c();
        ps.POCH_Activo__c 			 = true;
        ps.POCH_CanalDistribucion__c = '12';
        ps.POCH_GrpMat__c 	         = '11';
        ps.POCH_GrupoMateriales__c   = '11';
        ps.POCH_GrupoMateriales1__c  = '11';
        ps.POCH_GrupoMateriales2__c  = '11';
        ps.POCH_GrupoMateriales3__c  = '11';
        ps.POCH_GrupoMateriales4__c  = '11';
        ps.POCH_GrupoMateriales5__c  = '11';        
        ps.POCH_GTPos__c			 = '11';
        ps.POCH_JerarquiaProductos__c= 'JP';
        ps.POCH_UnidadMedidaVenta__c = 'KG';
        ps.POCH_Vavme__c			 = 'ND';
        ps.POCH_Descuento__c		 = true;
        ps.POCH_IdExterno__c		 = 'IDEXTPS';        
        return ps;
    }        
    public static testMethod POCH_ProductoSucursal__c getPSPapel() {
        POCH_ProductoSucursal__c psP  = new POCH_ProductoSucursal__c();
        psP.POCH_Activo__c 			 = true;
        psP.POCH_CanalDistribucion__c = '12';
        psP.POCH_GrpMat__c 	         = '11';
        psP.POCH_GrupoMateriales__c   = '11';
        psP.POCH_GrupoMateriales1__c  = '11';
        psP.POCH_GrupoMateriales2__c  = '11';
        psP.POCH_GrupoMateriales3__c  = '11';
        psP.POCH_GrupoMateriales4__c  = '11';
        psP.POCH_GrupoMateriales5__c  = '11';        
        psP.POCH_GTPos__c			 = '11';
        psP.POCH_JerarquiaProductos__c= 'JP';
        psP.POCH_UnidadMedidaVenta__c = 'KG';
        psP.POCH_Vavme__c			 = 'ND';
        psP.POCH_Descuento__c		 = true;
        psP.POCH_IdExterno__c		 = 'IDEXTPS';        
        return psP;
    }   
    public static testMethod POCH_ValoracionProducto__c getVP() {
        POCH_ValoracionProducto__c vp = new POCH_ValoracionProducto__c();
        vp.POCH_Activo__c 			  = true;
        vp.POCH_AreaValoracion__c 	  = 'CENTRO';
        vp.POCH_IdExterno__c 		  = 'IDEXTVP';
        vp.POCH_CostoFactInterna__c   = 5.6;    
        return vp;
    }
    
    public static testMethod Pricebook2 getCustomPricebook() {
        Pricebook2 pb 		 = new Pricebook2();
        pb.IsActive 		 = true;
        pb.Name 			 = 'TEST';
        pb.POCH_IdExterno__c = '0049';
        return pb;
    }
    
    public static testMethod PricebookEntry getPBEntry() {
        PricebookEntry pbe 			   = new PricebookEntry();
        pbe.IsActive 			 	   = true;
        pbe.POCH_CanalDistribucion__c  = '12';
        pbe.POCH_CantidadBase__c 	   = 1;
        pbe.CurrencyIsoCode 		   = 'MXN';
        pbe.POCH_FinValidez__c 		   = Date.today() + 30;
        pbe.POCH_IdExterno__c 		   = 'IDEXTPBE';
        pbe.POCH_InicioValidez__c 	   = Date.today() - 1;
        pbe.UnitPrice 			  	   = 6;
        pbe.POCH_NoRegCondicion__c 	   = '181114_S';
        pbe.POCH_OrganizacionVentas__c = '0049';
        pbe.Unidad_de_medida__c 	   = 'KG';
        pbe.POCH_UnidadMedidaEscala__c = 'KG';
        return pbe;
    }
    public static testMethod POCH_WFAprobador__c getApro() {
        POCH_WFAprobador__c apr = new POCH_WFAprobador__c();
        apr.CurrencyIsoCode = 'MXN';
        apr.POCH_GrupoMateriales__c = '11';
        return  apr;
    }
    
    public static testMethod POCH_PricebookEntryTemp__c getPBETemp() {
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
        return pbet;
    }
    
    public static testMethod SBQQ__DiscountSchedule__c getDiscountSchedule() {
        SBQQ__DiscountSchedule__c ds = new SBQQ__DiscountSchedule__c();
        ds.Name                      = 'DS TEST';
        ds.SBQQ__Type__c 			 = 'Range';
        ds.SBQQ__DiscountUnit__c 	 = 'Percent';
        ds.CurrencyIsoCode 			 = 'MXN';
        ds.POCH_IdExterno__c 		 = 'IDEXTPBE';
        ds.POCH_NoRegCondicion__c 	 = '181114_S';
        return ds;
    }
    
    public static testMethod SBQQ__DiscountTier__c getDiscountTier() {
        SBQQ__DiscountTier__c dt 	   = new SBQQ__DiscountTier__c();
        dt.Name 				 	   = 'DT TEST';
        dt.POCH_NoRegistroCondicion__c = '181114_S';
        dt.POCH_IdExterno__c 		   = 'DTEXTId';
        dt.SBQQ__Number__c 			   = 0;
        dt.SBQQ__LowerBound__c 		   = 0;
        dt.SBQQ__UpperBound__c         = 1;
        dt.POCH_ImporteCondicion__c    = 6;
        return dt;
    }
    
    public static testMethod POCH_Excepcion__c getExcepcion() {
        POCH_Excepcion__c ex 	   = new POCH_Excepcion__c();
        ex.POCH_GrupoMateriales__c = '11';        
        ex.POCH_Margen__c		   = 80;
        ex.RecordTypeId			   = Schema.SObjectType.POCH_Excepcion__c.getRecordTypeInfosByName().get('Margen Excepcion').getRecordTypeId();
        return ex;
    }
    
    public static testMethod SBQQ__ContractedPrice__c getPrecioEspecial(){
        SBQQ__ContractedPrice__c cp = new SBQQ__ContractedPrice__c();
        cp.SBQQ__Price__c			= 0.5;
        cp.CurrencyIsoCode			= 'MXN';
        cp.SBQQ__EffectiveDate__c   = Date.today();
        cp.SBQQ__ExpirationDate__c  = Date.today() + 30;        
        return cp;
    }
    
    public static testMethod Opportunity getOpportunity() {
        Opportunity opp = new Opportunity();
        // opp.POCH_IdOrgVentas__c = '0018';
        opp.Name 		= 'OPP TEST';
        opp.CloseDate 	= Date.today() + 30;
        opp.Amount 		= 1000;        
        opp.POCH_ValidarCredito__c = false;
        return opp;
    }  
    
    public static testMethod SBQQ__Quote__c getQuote() {
        SBQQ__Quote__c quote 			= new SBQQ__Quote__c();
        quote.CurrencyIsoCode 			= 'MXN';
        quote.SBQQ__Type__c 			= 'Quote';
        quote.POCH_EstatusCotizacion__c = 'Abierta';
        quote.SBQQ__EndDate__c 			= Date.today() + 30;
        quote.SBQQ__ExpirationDate__c 	= Date.today() + 30;
        return quote;
    }
    
    public static testMethod SBQQ__Quote__c getQuoteP() {
        SBQQ__Quote__c quote 			= new SBQQ__Quote__c();
        quote.CurrencyIsoCode 			= 'MXN';
        quote.SBQQ__Type__c 			= 'Quote';
        quote.POCH_EstatusCotizacion__c = 'Abierta';
        quote.SBQQ__EndDate__c 			= Date.today() + 30;
        quote.SBQQ__ExpirationDate__c 	= Date.today() + 30;
        return quote;
    }

    
    public static testMethod SBQQ__QuoteLine__c getQuoteLine() {
        SBQQ__QuoteLine__c ql 		 = new SBQQ__QuoteLine__c();
        ql.SBQQ__PricingMethod__c 	 = 'Custom';
        ql.SBQQ__PriceEditable__c 	 = true;
        ql.SBQQ__Description__c   	 = 'TEST';
        ql.POCH_EstatusPartida__c 	 = 'Abierta';
        ql.CurrencyIsoCode        	 = 'USD';        
        ql.SBQQ__Number__c		  	 = 1;    
        ql.POCH_Tax__c    		  	 = 0.65;
        ql.POCH_UnidadMedidaVenta__c = 'KG';
        ql.POCH_CantidadVenta__c     = 2;
        ql.SBQQ__Quantity__c         = 2;
        ql.POCH_ClasePedido__c 		 = 'PEPB';
        ql.SBQQ__ListPrice__c		 = 0;
        ql.SBQQ__CustomerPrice__c	 = 1;
        ql.SBQQ__NetPrice__c		 = 1;
        ql.SBQQ__SpecialPrice__c	 = 0;
        ql.SBQQ__RegularPrice__c	 = 0;
        ql.SBQQ__UnitCost__c		 = 0;        
        ql.SBQQ__SubscriptionBase__c = 'List';
        ql.SBQQ__SubscriptionScope__c= 'Quote';
        ql.POCH_ReenviarAutorizacion__c=false;
        return ql;
    }
    
    /**********************************************************************************************************************/
    
    /***********************************************************************************************************************/
    
    public static testMethod Order getOrder() {
        Order ord  		  = new Order();
        ord.Status 		  = 'Alta';
        ord.Name   		  = 'ORD TEST';   
        ord.EffectiveDate = Date.today() + 15;
        return ord;
    }
    
    public static testMethod OrderItem getOrderItem() {
        OrderItem oi = new OrderItem();
        oi.Quantity  = 1;
        oi.UnitPrice = 10;
        return oi;
    }
    
    public static testMethod POCH_WFAprobador__c getAprobador() {
        POCH_WFAprobador__c apr 	   = new POCH_WFAprobador__c();
        apr.POCH_OrganizacionVentas__c = '0049';
        apr.POCH_Aprobador__c 		   = UserInfo.getUserId();
        apr.POCH_Sociedad__c  		   = '63';
        //apr.Cuenta_Clave__c            = true;
        apr.POCH_GrupoMateriales__c    = '11';
        return apr;
    }
    
    public static testMethod POCH_Region__c getRegion() {
        POCH_Region__c reg = new POCH_Region__c();
        reg.Name        = 'REG TEST';
        reg.POCH_Region__c = 'REG';
        reg.POCH_Pais__c   = 'MX';
        return reg;
    }
    
    public static testMethod Stock_of_matrials__c getStockMatrial() {
        Stock_of_matrials__c Matrial = new Stock_of_matrials__c();
        Matrial.POCH_Centro__c = 'GDCO';
        Matrial.POCH_Cantidad__c = 12;
        //Matrial.Product__c = prd.Id;
        return Matrial;
    }
    
    public static testMethod Stock_details__c getStockDetail() {
        Stock_details__c stock = new Stock_details__c();
        stock.POCH_Almacen__c = 'ALPT';
        stock.POCH_Lote__c = '123312';
        stock.POCH_Stock_valorado_libre_utilizacion__c = 100;
        return stock;
    }
    
    public static testMethod POCH_WFSettings__c getSettings() {
        POCH_WFSettings__c wfs = new POCH_WFSettings__c();
        wfs.POCH_WFEscalaVolumen__c = 'POCH_WFEscalaVolumen';
        wfs.POCH_WFExcepciones__c   = 'POCH_WFExcepcion';
        wfs.POCH_WFMatCriticos__c   = 'POCH_WFMaterialCritico';
        wfs.POCH_WFPapel__c			= 'POCH_WFPapel';
        wfs.POCH_WFPolitica__c 		= 'POCH_WFPolitica';
        wfs.POCH_ComentariosWFEscalaVolumen__c = 'Test';
        wfs.POCH_ComentariosWFExcepciones__c   = 'Test';
        wfs.POCH_ComentariosWFMatCritico__c	   = 'Test';
        wfs.POCH_ComentariosWFPapel__c		   = 'Test';
        wfs.POCH_ComentariosWFPolitica__c	   = 'Test';
        return wfS;
    }
    
    public static testMethod POCH_TriggerSettings__c getTrgSettings() {
        POCH_TriggerSettings__c ts 		   = new POCH_TriggerSettings__c();
        ts.POCH_DiscountScheduleTrigger__c = true;
        ts.POCH_DiscountTierTrigger__c 	   = true;
        ts.POCH_PricebookEntryTrigger__c   = true;
        ts.POCH_Product2Trigger__c 		   = true;
        ts.POCH_OrderTrigger__c 		   = true;
        ts.POCH_OpportunityTrigger__c 	   = true;
        ts.POCH_QuoteLineTrigger__c 	   = true;
        ts.POCH_QuoteTrigger__c 		   = true;
        return ts;
    }
    
    public static testMethod POCH_DetalleInventario__c getDetalleInventario() {
        POCH_DetalleInventario__c detalleTst = new POCH_DetalleInventario__c();
        detalleTst.POCH_CantidadPotencial__c = '1';
        detalleTst.POCH_CantidadBase__c      = '1';
        detalleTst.POCH_EsBase__c 			 = '12';
        detalleTst.POCH_PrecioLista__c 		 = '12';
        detalleTst.POCH_EsPotencial__c 		 = '12';
        detalleTst.POCH_Estatus__c 			 = System.label.POCH_activeStatus;
        return detalleTst;
    }  
    
    public static testMethod POCH_HojaInventario__c getInventario() {
        POCH_HojaInventario__c hi = new POCH_HojaInventario__c();
        hi.Name = 'HI';
        hi.POCH_FechaUltimaCotizacion__c = Date.today().addMonths(-1);
        hi.POCH_FrecuenciaCotizacion__c  = '1';
        return hi;
    }  
    
    public static testMethod Case getCase() {
        Case caseAux 		      = new Case();
        caseAux.Subject           = 'test';
        caseAux.Type              = 'INCIDENCIA QUE AFECTA E AL CLIENTE';
        caseAux.Motivo__c         = 'CALIDAD';
        caseAux.Origin            = 'Web';
        caseAux.POCH_Submotivo__c = 'CALIDAD DEL PRODUCTO (CADUCO)';
        caseAux.Priority          = 'Medium';
        caseAux.POCH_NoFactura__c = '999';
        caseAux.CurrencyIsoCode   = 'MXN';
        caseAux.Status            = 'Abierto';
        return caseAux;
    }
    
    public static testMethod Contact getContact(){
        Contact contact = new Contact();
        contact.LastName = 'test';
        contact.Email = 'test@test.com';
        contact.Phone = '5555555';
        contact.POCH_Departamento__c = '0011';
        contact.MobilePhone = '3333'; 
        contact.POCH_Funcion__c = '16';        
        return contact;
    }
    
    public static testMethod Equipo_Vendedores__c getEquipoVendedor(){
        Equipo_Vendedores__c equipo_Vendedor = new Equipo_Vendedores__c();
                
        return equipo_Vendedor;
    }
    
    public static testMethod User getUser(){
        User usuario = new User();
        usuario.Alias = 'standt';
		usuario.Email='standarduser@testorg.com'; 
        usuario.EmailEncodingKey='UTF-8';
        usuario.LastName='Testing';
        usuario.LanguageLocaleKey='en_US'; 
        usuario.LocaleSidKey='en_US';
        usuario.FirstName = 'first';
        usuario.CommunityNickname = 'testUser123';
        usuario.Department = 'Desarrollo';
        usuario.TimeZoneSidKey='America/Los_Angeles';
        usuario.UserName='standardusertt@testorg.com';
        usuario.IsActive = true;
        return usuario;
    }
   
}