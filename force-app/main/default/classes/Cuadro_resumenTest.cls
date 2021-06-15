@isTest 
public class Cuadro_resumenTest {
    static TestMethod void Cuadro_resumenTest(){ 
        
        Product2 prd = POCH_DataCreationTest.getProduct();
        prd.IsActive = true;
        prd.CurrencyIsoCode = 'USD';
        insert prd;
        system.debug(prd); 
        
        // Get standard price book ID.
        Id pricebookId = Test.getStandardPricebookId();
        system.debug(pricebookId);
        
        //insert pricebookentry for eacy currency
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prd.Id,
            UnitPrice = 0.0, IsActive = true);
        insert standardPrice;
        
        List<Pricebook2> standardPB = [select id from Pricebook2 where isStandard=true];
        System.debug(standardPB);
        System.debug(standardPB.size() > 0); // false 
        
        // Create a custom price book 
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        insert customPB;
        system.debug(customPB);
        
        PricebookEntry elderPBE = new PricebookEntry(
            Pricebook2Id = customPB.Id,
            Product2Id = prd.Id,
            UnitPrice = 0,
            IsActive = true
        );
        insert elderPBE;
        system.debug(elderPBE);
        
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        system.debug(reg);
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal();
        insert suc;
        system.debug(suc);
        
        Pricebook2 pb = POCH_DataCreationTest.getCustomPricebook();
        pb.POCH_Sucursal__c = suc.Id;
        pb.IsActive = true;
        insert pb;
        system.debug(pb);
        
        Account acc = POCH_DataCreationTest.getAccount();
        acc.POCH_TipoRegistro__c = 'Prospecto';
        acc.POCH_Region__c = reg.Id;
        insert acc;
        system.debug(acc);
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        system.debug(sam);
        
        SBQQ__Quote__c qt = POCH_DataCreationTest.getQuote();
        qt.SBQQ__Account__c = acc.Id;
        qt.POCH_Sucursal__c = suc.Id;
        qt.SBQQ__PriceBook__c = pb.Id;
        insert qt;
        system.debug(qt);
        
        User usr = [SELECT Id,POCH_OrganizacionesVentas__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        usr.POCH_OrganizacionesVentas__c = '0049;0023;0015;0019;0101';
        update usr;
        
        SBQQ__QuoteLine__c qt2 = POCH_DataCreationTest.getQuoteLine();
        qt2.SBQQ__Product__c = prd.Id;
        qt2.SBQQ__Quote__c = qt.Id;
        insert qt2;
        system.debug(qt2);
        
        Order ord = POCH_DataCreationTest.getOrder();
        ord.AccountId = acc.Id;
        ord.POCH_Quote__c = qt.Id;
        ord.Pricebook2Id = customPB.Id;
        insert ord;
        system.debug(ord);
        
        OrderItem ordItem = POCH_DataCreationTest.getOrderItem();
        ordItem.OrderId = ord.Id;
        ordItem.PricebookEntryId = elderPBE.id;
        ordItem.Codigo_de_producto__c = '181114';
        ordItem.POCH_Centro_list__c = 'GDCO';
        //ordItem.POCH_Almacen__c = 'ALPT';
        insert ordItem;
        system.debug(ord);
        
        Stock_of_matrials__c info = POCH_DataCreationTest.getStockMatrial();
        info.Product__c = prd.Id;
        insert info;
        
        Stock_details__c stock = POCH_DataCreationTest.getStockDetail();
        stock.Stock_of_matrials__c = info.Id;
        insert stock;  
        
        ordItem.POCH_Almacen__c = 'ALPT';
        update ordItem;
        
        Test.startTest();      
        PageReference pageRef = Page.cuadro_resumen_view;
        //pageRef.getParameters().put('id',ord.id);
        pageRef.getParameters().put('id',ordItem.id);
        pageRef.getParameters().put('id',info.id);
        pageRef.getParameters().put('id',stock.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ordItem);
        Cuadro_resumen mc = new Cuadro_resumen(sc);
        
        Test.stopTest();
        
    }  
}