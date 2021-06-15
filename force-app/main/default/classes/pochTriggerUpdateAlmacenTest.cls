@IsTest
public class pochTriggerUpdateAlmacenTest {
    static TestMethod void pochTriggerUpdateAlmacenTest(){ 
        
        Test.startTest(); 
        
        date mydate = date.parse('1/12/2021');
        
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
        ordItem.Codigo_de_producto__c = '21936';
        //ordItem.POCH_Almacen__c = 'ALPT';
        insert ordItem;
        system.debug(ord);
        
        ordItem.POCH_Almacen__c = 'ALPT';
        update ordItem;
        
        Test.stopTest();
    } 
}

/*PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
insert standardPrice;*/

/*PricebookEntry prc = POCH_DataCreationTest.getPBEntry();
prc.Product2Id = prd.Id;
prc.Pricebook2Id = pb.Id;
prc.IsActive = true;
prc.UnitPrice = 33;
prc.UseStandardPrice = false;
insert prc;
system.debug(prc);*/


/*Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
system.debug(standardPB);*/

/*Product2 producto = new Product2();
producto.Name = 'ACETATO';
producto.POCH_IdProductoSAP__c = '2193666';
insert producto; 
system.debug(producto);*/


//create custom Price book for each currency
/*PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd.Id,CurrencyIsoCode ='USD',
UnitPrice = 0.0, IsActive = true);

insert customPrice1;
system.debug(customPrice1);*/