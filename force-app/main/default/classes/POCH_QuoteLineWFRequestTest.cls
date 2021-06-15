@IsTest
public class POCH_QuoteLineWFRequestTest {

    @TestSetup static void createdDateWF() {
        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;
        
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        Account acc = POCH_DataCreationTest.getAccount();
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
        
        POCH_ValoracionProducto__c vp = POCH_DataCreationTest.getVP();
        vp.POCH_Producto__c = prd.Id;
        insert vp;          
        
        POCH_OpportunityTriggerService.isInvokedByTrigger = true;
        Opportunity opp      = POCH_DataCreationTest.getOpportunity();
        opp.AccountId        = acc.Id;
        opp.POCH_Sucursal__c = suc.Id;
        opp.Pricebook2Id     = pb.Id;
        insert opp;
        
        SBQQ__Quote__c qt        = POCH_DataCreationTest.getQuote();
        qt.SBQQ__Account__c      = acc.Id;
        qt.SBQQ__Opportunity2__c = opp.Id;
        qt.SBQQ__PriceBook__c    = pb.Id;
        qt.POCH_Sucursal__c      = suc.Id;
        insert qt;
        
        POCH_WFSettings__c wfs = POCH_DataCreationTest.getSettings();
        insert wfs;
        
        POCH_ProductoSucursal__c ps = POCH_DataCreationTest.getPS();
        ps.POCH_Producto__c         = prd.Id;
        ps.POCH_Sucursal__c			= suc.Id;
        insert ps;
        
        List<POCH_WFAprobador__c> lWFa = new List<POCH_WFAprobador__c>();
        POCH_WFAprobador__c ap1 = POCH_DataCreationTest.getAprobador();
        POCH_WFAprobador__c ap2 = POCH_DataCreationTest.getAprobador();
        POCH_WFAprobador__c ap3 = POCH_DataCreationTest.getAprobador();
        POCH_WFAprobador__c ap4 = POCH_DataCreationTest.getAprobador();
        POCH_WFAprobador__c ap5 = POCH_DataCreationTest.getAprobador();
        ap1.RecordTypeId        = Schema.SObjectType.POCH_WFAprobador__c.getRecordTypeInfosByName().get('Aprobador Gerente Sucursal').getRecordTypeId(); 
        ap2.RecordTypeId        = Schema.SObjectType.POCH_WFAprobador__c.getRecordTypeInfosByName().get('Aprobador Gerente Regional').getRecordTypeId();
        ap3.RecordTypeId        = Schema.SObjectType.POCH_WFAprobador__c.getRecordTypeInfosByName().get('Aprobador Gerente Linea').getRecordTypeId();
        ap4.RecordTypeId        = Schema.SObjectType.POCH_WFAprobador__c.getRecordTypeInfosByName().get('Aprobador Director Division').getRecordTypeId();
        ap5.RecordTypeId        = Schema.SObjectType.POCH_WFAprobador__c.getRecordTypeInfosByName().get('Aprobador Director Ejecutivo').getRecordTypeId();
        insert new List<POCH_WFAprobador__c>{ap1,ap2,ap3,ap4,ap5};
        
        SBQQ__QuoteLine__c ql = POCH_DataCreationTest.getQuoteLine();
        ql.SBQQ__Product__c   = prd.Id;
        ql.SBQQ__Quote__c     = qt.Id;
        insert ql;
    }
    
    class WFData {
        public Account					acc {get;set;}
        public POCH_Sucursal__c			suc {get;set;}
        public POCH_SucursalAmpliada__c sam {get;set;}
        public Product2					prd {get;Set;}
        public Pricebook2				pb	{get;set;}
        public SBQQ__Quote__c			qt  {get;set;}
        public SBQQ__QuoteLine__c		ql  {get;set;}
        
        public WFData() {
            this.acc = [SELECT Id FROM Account LIMIT 1];
            this.suc = [SELECT Id FROM POCH_Sucursal__c LIMIT 1];
            this.sam = [SELECT Id,POCH_GrupoClientes2__c FROM POCH_SucursalAmpliada__c LIMIT 1];
            this.prd = [SELECT Id FROM Product2 LIMIT 1];
            this.pb  = [SELECT Id FROM Pricebook2 WHERE IsStandard = FALSE LIMIT 1 ];
            this.qt  = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];   
            this.ql  = [SELECT Id, CurrencyIsoCode, SBQQ__Quote__c, SBQQ__AdditionalDiscountAmount__c, SBQQ__AdditionalDiscount__c, SBQQ__AdditionalQuantity__c, SBQQ__AllowAssetRefund__c, SBQQ__BatchQuantity__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c,
                        SBQQ__BlockPrice__c, SBQQ__Bundle__c, SBQQ__BundledQuantity__c, SBQQ__Bundled__c, SBQQ__CarryoverLine__c, SBQQ__ChargeType__c, SBQQ__ComponentCost__c, SBQQ__ComponentDiscountedByPackage__c, SBQQ__ComponentListTotal__c, SBQQ__ComponentSubscriptionScope__c,
                        SBQQ__ComponentTotal__c, SBQQ__ComponentUpliftedByPackage__c, SBQQ__ComponentVisibility__c, SBQQ__CompoundDiscountRate__c, SBQQ__ConfigurationRequired__c, SBQQ__ContractedPrice__c, SBQQ__CostEditable__c, SBQQ__Cost__c, SBQQ__CustomerPrice__c, SBQQ__CustomerTotal__c,
                        SBQQ__DefaultSubscriptionTerm__c, SBQQ__Description__c, SBQQ__Dimension__c, SBQQ__DiscountScheduleType__c, SBQQ__DiscountSchedule__c, SBQQ__DiscountTier__c, SBQQ__Discount__c, SBQQ__DistributorDiscount__c, SBQQ__DynamicOptionId__c, SBQQ__EffectiveEndDate__c,
                        SBQQ__EffectiveQuantity__c, SBQQ__EffectiveStartDate__c, SBQQ__EndDate__c, SBQQ__Existing__c, SBQQ__Favorite__c, SBQQ__GenerateContractedPrice__c, SBQQ__GrossProfit__c, SBQQ__Group__c, SBQQ__HasConsumptionSchedule__c, SBQQ__Hidden__c, SBQQ__Incomplete__c,
                        SBQQ__ListPrice__c, SBQQ__ListTotal__c, SBQQ__MarkupAmount__c, SBQQ__MarkupRate__c, SBQQ__Markup__c, SBQQ__MaximumPrice__c, SBQQ__MinimumPrice__c, SBQQ__NetPrice__c, SBQQ__NetTotal__c, SBQQ__NonDiscountable__c, SBQQ__NonPartnerDiscountable__c, SBQQ__Number__c,
                        SBQQ__OptionDiscountAmount__c, SBQQ__OptionDiscount__c, SBQQ__OptionLevel__c, SBQQ__OptionType__c, SBQQ__Optional__c, SBQQ__OriginalPrice__c, SBQQ__OriginalQuoteLineId__c, SBQQ__OriginalUnitCost__c, SBQQ__PackageCost__c, SBQQ__PackageListTotal__c,
                        SBQQ__PackageProductCode__c, SBQQ__PackageProductDescription__c, SBQQ__PackageTotal__c, SBQQ__PartnerDiscount__c, SBQQ__PartnerPrice__c, SBQQ__PartnerTotal__c, SBQQ__PreviousSegmentPrice__c, SBQQ__PreviousSegmentUplift__c, SBQQ__PriceEditable__c,
                        SBQQ__PricebookEntryId__c, SBQQ__PricingMethodEditable__c, SBQQ__PricingMethod__c, SBQQ__PriorQuantity__c, SBQQ__ProductCode__c, SBQQ__ProductFamily__c, SBQQ__ProductName__c, SBQQ__ProductOption__c, SBQQ__ProductSubscriptionType__c, SBQQ__Product__c,
                        SBQQ__ProrateMultiplier__c, SBQQ__ProratedListPrice__c, SBQQ__ProratedPrice__c, SBQQ__Quantity__c, SBQQ__RegularPrice__c, SBQQ__RegularTotal__c, SBQQ__Renewal__c, SBQQ__RenewedAsset__c, SBQQ__RenewedSubscription__c, SBQQ__RequiredBy__c, SBQQ__SegmentIndex__c,
                        SBQQ__SegmentKey__c, SBQQ__SegmentLabel__c, SBQQ__Source__c, SBQQ__SpecialPriceDescription__c, SBQQ__SpecialPriceType__c, SBQQ__SpecialPrice__c, SBQQ__StartDate__c, SBQQ__SubscribedAssetIds__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionCategory__c,
                        SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionScope__c, SBQQ__SubscriptionTargetPrice__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionType__c, SBQQ__TaxCode__c, SBQQ__Taxable__c, SBQQ__TermDiscountSchedule__c, SBQQ__TermDiscountTier__c,
                        SBQQ__TermDiscount__c, SBQQ__TotalDiscountAmount__c, SBQQ__TotalDiscountRate__c, SBQQ__UnitCost__c, SBQQ__UnproratedNetPrice__c, SBQQ__UpgradedAsset__c, SBQQ__UpgradedQuantity__c, SBQQ__UpgradedSubscription__c, SBQQ__UpliftAmount__c, SBQQ__Uplift__c, SBQQ__VolumeDiscount__c,
                        POCH_UnidadesMedida__c, POCH_ShippingHandling__c, POCH_AccountNameQuote__c, POCH_AccountPaymentTerms__c, POCH_PrecioVenta__c, POCH_EstatusPartida__c, POCH_UMSelected__c, POCH_GrandTotal__c, POCH_PEVCheck__c, POCH_aPedido__c, POCH_WFAprobador1Name__c, POCH_Critico__c,
                        POCH_AccountCurrency__c, POCH_ProductCurrency__c, POCH_QuotePricebook__c, POCH_PrecioModificadoPorAprobador__c, POCH_MargenUtilidad__c, POCH_WFMaterialCriticoAprobado__c, POCH_WF_ExcepcionAprobado__c, POCH_WFPrecioMenorAprobado__c, POCH_WFMargenAprobado__c, POCH_SKU__c,
                        POCH_CentroSucursal__c, POCH_SucursalQuote__c, POCH_ClasePedido__c, POCH_UnidadMedidaVenta__c, POCH_CantidadVenta__c, POCH_HideLineCheck__c, POCH_OrgVentasQuote__c, POCH_UnidadMedidaBase__c, POCH_CanalDistribucion__c, POCH_WFAprobador2Name__c, POCH_AccountQuote__c,
                        POCH_SucursalQuoteName__c, POCH_EstatusCotizacion__c, POCH_UltimaModificacionPorFuncion__c, POCH_Tax__c, POCH_ReenviarAutorizacion__c, POCH_WFAprobador1__c, POCH_WFAprobador2__c, POCH_WFAprobador3__c, POCH_WFAprobador4__c, POCH_WFAprobador5__c, POCH_EnviarAprobacion__c, POCH_WF__c,
                        POCH_WFComentarios__c, POCH_QuoteSociedad__c, POCH_WFAprobador3Name__c, POCH_WFAprobador4Name__c, POCH_WFAprobador5Name__c, POCH_Estatus__c, POCH_Escala__c 
                        FROM SBQQ__QuoteLine__c LIMIT 1];
        }
    }
    
    public static testMethod void testSendApprovalRequest() {
        Test.startTest();
        WFData wfd              = new WFData(); 
        SBQQ__QuoteLine__c ql   = wfd.ql;
        ql.POCH_WF__c			= 'POCH_WFEscalaVolumen';
        ql.POCH_WFAprobador1__c = UserInfo.getUserId();
        ql.POCH_WFAprobador2__c = UserInfo.getUserId();
        ql.POCH_WFAprobador3__c = UserInfo.getUserId();
        ql.POCH_WFAprobador4__c = UserInfo.getUserId();
        ql.POCH_WFAprobador5__c = UserInfo.getUserId();
        POCH_QuoteLineWFRequest.submitWFApprovalRequest(new List<SBQQ__QuoteLine__c>{ql});
        
        ql.POCH_ReenviarAutorizacion__c = true;
        POCH_QuoteLineWFRequest.submitWFApprovalRequest(new List<SBQQ__QuoteLine__c>{ql});
        Test.stopTest();
    }
    
}