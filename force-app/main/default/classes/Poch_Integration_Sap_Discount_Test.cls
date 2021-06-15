@IsTest 
public class Poch_Integration_Sap_Discount_Test {
    
    static TestMethod void Poch_Integration_Sap_Discount_Test(){
        
        Date fechafin = Date.parse('31/12/2021');
        Date fecha = Date.today();
        
        List <Product2> lstProduct = new List<Product2>();
        Product2 one = new Product2(); 
        one.POCH_IdProductoSAP__c = '00001';
        one.Name = 'STRETCH MANUAL';
        one.Family='E-CAJA';
        one.POCH_Linea__c ='EMPAQUE';
        one.POCH_Division__c='MAQUINARIA / EMPAQUE / EMBALAJE';
        one.QuantityUnitOfMeasure='KG';
        one.POCH_UnidadesMedida__c='KG, PZ,';
        one.POCH_GrupoMateriales2__c = 'LINEA';
        lstProduct.add(one);
        
        Product2 two = new Product2(); 
        two.POCH_IdProductoSAP__c = '00002';
        two.Name = 'STRETCH MANUAL 222';
        two.Family='E-CAJA';
        two.POCH_Linea__c ='EMPAQUE';
        two.POCH_Division__c='MAQUINARIA / EMPAQUE / EMBALAJE';
        two.QuantityUnitOfMeasure='KG';
        two.POCH_UnidadesMedida__c='KG, PZ,';
        two.POCH_GrupoMateriales2__c = 'LINEA';
        lstProduct.add(two);
        
        insert lstProduct;
        system.debug(lstProduct);  
        //system.debug(lstProduct.size());
        
        Pricebook2 libro = new Pricebook2(); 
        libro.Name = 'Test';
        Libro.POCH_IdExterno__c = '0007';
        libro.Description = 'testdescription';
        libro.IsActive = true;
        insert libro;
        
        SBQQ__DiscountSchedule__c scheduleNuevo = new SBQQ__DiscountSchedule__c();
        scheduleNuevo.Name = '221420019';
        scheduleNuevo.POCH_NoRegCondicion__c = '51728';
        scheduleNuevo.CurrencyIsoCode = 'MXN';
        scheduleNuevo.SBQQ__DiscountUnit__c = 'Percent';
        scheduleNuevo.SBQQ__Type__c = 'Range';    
        scheduleNuevo.Unidad_Escala__c = 'Kg';
        scheduleNuevo.SBQQ__Product__c = lstProduct[0].id;
        scheduleNuevo.SBQQ__Pricebook__c = libro.id;
        insert scheduleNuevo;
        
        SBQQ__DiscountTier__c discountTier = new SBQQ__DiscountTier__c();
        discountTier.Name = '517280001';
        discountTier.CurrencyIsoCode = 'MXN';
        discountTier.POCH_ImporteCondicion__c = 1.69;
        discountTier.POCH_ImporteUpper__c = 1.69;
        discountTier.SBQQ__Discount__c = 0.0000000000;
        discountTier.SBQQ__Number__c = 1;
        discountTier.SBQQ__LowerBound__c = 186;
        discountTier.SBQQ__UpperBound__c = 190;
        discountTier.POCH_IdExterno__c = '517280001';
        discountTier.POCH_NoRegistroCondicion__c = '51728';
        discountTier.SBQQ__Schedule__c = scheduleNuevo.id;
        insert discountTier;
        
        List<SBQQ__DiscountSchedule__c> result = new list <SBQQ__DiscountSchedule__c> ();
        List<SBQQ__DiscountSchedule__c> result2 = new list <SBQQ__DiscountSchedule__c> ();
        List<Product2> result3 = new list <Product2> ();
        List<Pricebook2> result4 = new list <Pricebook2> ();
        
        result =  [SELECT Id
                   FROM SBQQ__DiscountSchedule__c Where id =: scheduleNuevo.id]; 
        system.debug(result);
        
        result2 =  [SELECT Id
                   FROM SBQQ__DiscountSchedule__c Where id =: result[0].id]; 
        system.debug(result2);
        
        result3 =  [SELECT Id,POCH_IdProductoSAP__c
                   FROM Product2 Where id =: lstProduct[0].id]; 
        system.debug(result3);
        
        result4 =  [SELECT Id,POCH_IdExterno__c
                   FROM Pricebook2 Where id =: libro.id]; 
        system.debug(result4);
        
        //String JSONMsg = '{"stock": [{"Name": "STRETCH MANUAL","stock_product_id": "00001","stock_centro": "POCHTECA MATERIAS PRIMAS TOLUCA","stock_cantidad": 0,"stock_ok": 0,"stock_no_ok":0,"cte_consigna":0,"prv_consigna":0,"stock_Almacen":"ALCR","stock_lote":"W","stock_Indicador_stock_especial":"E","stock_Indicador_bloqueo_inventario": "X","stock_numero_especial":"500","stock_Stock_valorado_libre_utilizacion":200,"stock_Control_id":"ST-GDTL00001",}]}';
        
        Poch_Integration_Sap_Discount.MyDiscuountClass discount = new Poch_Integration_Sap_Discount.MyDiscuountClass();
        Poch_Integration_Sap_Discount.MyDiscuountClass discount2 = new Poch_Integration_Sap_Discount.MyDiscuountClass();
        //POCH_Integration_SAP_Stock.MyStockClass stock3 = new POCH_Integration_SAP_Stock.MyStockClass();
        List<Poch_Integration_Sap_Discount.MyDiscuountClass> discountList = new List< Poch_Integration_Sap_Discount.MyDiscuountClass>();
        discount.discountName='221420019';
        discount.discountPOCH_IDExterno = '0007';
        discount.discountCurrency = 'MXN';
        discount.discountSIdProductoSap= '00001';
        discount.discountPOCH_NoRegCondicion= '51728';
        discount.discountUnidad_Escala='KG';
        discount.tiersName='517280001';
        discount.tiersPOCHImporteCondicion= 1.69;
        discount.tiersPOCHImporteUpper= 1.55;
        discount.tiersSBQQNumber= 1;
        discount.tiersSBQQLowerBound= 177;
        discount.tiersSBQQDiscount= 0.0000;
        discount.tiersUpperBound= 180;
        discount.tiersPOCHIdExterno= '517280001';
        discount.tiersCurrency= 'MXN';
        //discount.stock_material_id= result2[0].id;
        discount.tiersPOCHNoRegistroCondicion= '51728';
        discountList.add(discount);
        
        discount2.discountName='219340118';
        discount2.discountPOCH_IDExterno = '0007';
        discount2.discountCurrency = 'MXN';
        discount2.discountSIdProductoSap= '00002';
        discount2.discountPOCH_NoRegCondicion= '2133198111';
        discount2.discountUnidad_Escala='KG';
        discount2.tiersName='21331981110001';
        discount2.tiersPOCHImporteCondicion= 1.59;
        discount2.tiersPOCHImporteUpper= 1.55;
        discount2.tiersSBQQNumber= 1;
        discount2.tiersSBQQLowerBound= 177;
        discount2.tiersSBQQDiscount= 0.0000;
        discount2.tiersUpperBound= 180;
        discount2.tiersCurrency= 'MXN';
        discount2.tiersPOCHIdExterno= '21331981110001';
        //discount.stock_material_id= result2[0].id;
        discount2.tiersPOCHNoRegistroCondicion= '2133198111';
        discountList.add(discount2);
        
        system.debug(discountList[0]);
        //system.debug(discountList[1]);
        
        test.startTest();
        
        //POST
        String JSONMsg= JSON.serialize(discountList);
        RestRequest req = new RestRequest();
        req.requestURI = '/integracionDiscount/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        req.requestBody = Blob.valueof(JSONMsg); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        system.debug(JSONMsg);
        
        Poch_Integration_Sap_Discount.doPost(discountList);        
        Test.stopTest(); 
        
    }
}