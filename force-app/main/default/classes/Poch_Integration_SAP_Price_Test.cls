@IsTest 
public class Poch_Integration_SAP_Price_Test {
    
    static TestMethod void Poch_Integration_SAP_Price_Test(){
        
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
        
        POCH_PricebookEntryTemp__c PricebookEntry = new POCH_PricebookEntryTemp__c();
        PricebookEntry.POCH_IsActive__c = true;
        PricebookEntry.POCH_CanalDistribucion__c = '12';
        PricebookEntry.POCH_CantidadBase__c = 186;
        PricebookEntry.CurrencyIsoCode = 'USD';
        PricebookEntry.POCH_FinValidez__c = fechafin;
        PricebookEntry.POCH_IdExterno__c = '221420019USD';
        PricebookEntry.POCH_InicioValidez__c = fecha;
        PricebookEntry.POCH_UnitPrice__c = 160;
        PricebookEntry.POCH_OrganizacionVentas__c = '2214';
        PricebookEntry.POCH_NoRegCondicion__c = '51728';
        PricebookEntry.POCH_UnidadMedidaEscala__c = 'kg'; 
        PricebookEntry.Unidad_de_medida__c = 'kg';
        PricebookEntry.POCH_Pricebook2__c = libro.id;
        PricebookEntry.POCH_Product2__c = lstProduct[0].id;
        
        insert PricebookEntry;
        system.debug(PricebookEntry); 
                
        //String JSONMsg = '{"stock": [{"Name": "STRETCH MANUAL","stock_product_id": "00001","stock_centro": "POCHTECA MATERIAS PRIMAS TOLUCA","stock_cantidad": 0,"stock_ok": 0,"stock_no_ok":0,"cte_consigna":0,"prv_consigna":0,"stock_Almacen":"ALCR","stock_lote":"W","stock_Indicador_stock_especial":"E","stock_Indicador_bloqueo_inventario": "X","stock_numero_especial":"500","stock_Stock_valorado_libre_utilizacion":200,"stock_Control_id":"ST-GDTL00001",}]}';
        
        Poch_Integration_SAP_Price.MyPriceClass price = new Poch_Integration_SAP_Price.MyPriceClass();
        Poch_Integration_SAP_Price.MyPriceClass price2 = new Poch_Integration_SAP_Price.MyPriceClass();
        //POCH_Integration_SAP_Stock.MyStockClass stock3 = new POCH_Integration_SAP_Stock.MyStockClass();
        List< Poch_Integration_SAP_Price.MyPriceClass> priceList = new List< Poch_Integration_SAP_Price.MyPriceClass>();
        price.POCH_IdProductoSAP='00001';
        price.pricePOCH_IDExterno = '0007';
        price.pricePOCH_IDExternoCurrency = '0007USD';
        price.pricePOCHCurrency = 'USD';
        price.POCH_CanalDistribucion= '12';
        price.POCH_CantidadBase=10.00;
        price.POCH_InicioValidez=fecha;
        price.POCH_UnitPrice=1.83;
        price.POCH_OrganizacionVentas= '0007';
        price.POCH_NoRegCondicion= 'abc';
        price.POCH_UnidadMedidaEscala= '1';
        price.Unidad_de_medida=  '1';
        priceList.add(price);
        
        price2.POCH_IdProductoSAP='00001';
        price2.pricePOCH_IDExterno = '221420019';
        price2.POCH_CanalDistribucion= '12';
        price2.pricePOCH_IDExternoCurrency = '221420019USD';
        price2.pricePOCHCurrency = 'USD';
        price2.POCH_CantidadBase=10.00;
        price2.POCH_InicioValidez=fecha;
        price2.POCH_UnitPrice=1.83;
        price2.POCH_OrganizacionVentas= '0007';
        price2.POCH_NoRegCondicion= 'abc';
        price2.POCH_UnidadMedidaEscala= '1';
        price2.Unidad_de_medida=  '1';
        priceList.add(price2);
        
        system.debug(priceList[0]);
        system.debug(priceList[1]);
        
        test.startTest();
        
        //POST
        String JSONMsg= JSON.serialize(priceList);
        RestRequest req = new RestRequest();
        req.requestURI = '/integracionPrice/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        req.requestBody = Blob.valueof(JSONMsg); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        system.debug(JSONMsg);
        
        Poch_Integration_SAP_Price.doPost(priceList);        
        Test.stopTest();
        
    }
}