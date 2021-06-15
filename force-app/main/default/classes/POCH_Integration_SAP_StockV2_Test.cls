@IsTest 
public class POCH_Integration_SAP_StockV2_Test {
    
    static TestMethod void POCH_Integration_SAP_StockV2_Test(){
        
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
        
        List <Stock_of_matrials__c> lstmaterial = new List<Stock_of_matrials__c>();
        Stock_of_matrials__c material = new Stock_of_matrials__c(); 
        material.Product__c = one.id;
        material.Name = 'STRETCH MANUAL';
        material.POCH_Centro__c='GDTL';
        material.stock_ok__c =0;
        material.stock_no_ok__c=0;
        material.Cte_Consigna__c=0;
        material.Prv_Consigna__c=0;
        material.POCH_Cantidad__c = 0;
        lstmaterial.add(material);
        
        Stock_of_matrials__c material2 = new Stock_of_matrials__c(); 
        material2.Product__c = one.id;
        material2.Name = 'STRETCH MANUAL Post';
        material2.POCH_Centro__c='GDSJ';
        material2.stock_ok__c =1;
        material2.stock_no_ok__c=1;
        material2.Cte_Consigna__c=1;
        material2.Prv_Consigna__c=1;
        material2.POCH_Cantidad__c = 1;
        lstmaterial.add(material2);
        insert lstmaterial;
        system.debug(lstmaterial); 
        
        List <Stock_details__c> lstdetalle = new List<Stock_details__c>();
        Stock_details__c detalle = new Stock_details__c(); 
        detalle.Stock_of_matrials__c = material.id;
        detalle.POCH_Almacen__c = 'ALCR';
        detalle.POCH_Lote__c='W';
        detalle.POCH_Indicador_stock_especial__c = 'E';
        detalle.POCH_Numero_stock_especial__c ='500';
        detalle.POCH_Indicador_bloqueo_inventario__c = 'X';
        detalle.POCH_Stock_valorado_libre_utilizacion__c=200;
        
        lstdetalle.add(detalle);
        
       /* Stock_details__c detalle2 = new Stock_details__c(); 
        detalle2.Stock_of_matrials__c = material2.id;
        detalle2.POCH_Almacen__c = 'ALPT';
        detalle2.POCH_Lote__c='W';
        detalle2.POCH_Indicador_stock_especial__c = 'E';
        detalle2.POCH_Numero_stock_especial__c ='500';
        detalle2.POCH_Indicador_bloqueo_inventario__c = 'X';
        detalle2.POCH_Stock_valorado_libre_utilizacion__c=200;
        
        lstdetalle.add(detalle2);*/
        
        insert lstdetalle;
        system.debug(lstdetalle); 
        
        List<Stock_of_matrials__c> result = new list <Stock_of_matrials__c> ();
        List<Stock_of_matrials__c> result2 = new list <Stock_of_matrials__c> ();
        List<Product2> result3 = new list <Product2> ();
        
        result =  [SELECT Id, Name,POCH_Cantidad__c,POCH_Centro__c,Product__c,
                   POCH_Stock_valorado_libre_utilizacion__c,POCH_Stock_disponible__c,Control_Id_SF__c,Id_Producto_SAP__c,
                   stock_ok__c,stock_no_ok__c,Cte_Consigna__c,Prv_Consigna__c
                   FROM Stock_of_matrials__c Where id =: material.id]; 
        system.debug(result);
        
        result2 =  [SELECT Id, Name,POCH_Cantidad__c,POCH_Centro__c,Product__c,
                    POCH_Stock_valorado_libre_utilizacion__c,POCH_Stock_disponible__c,Control_Id_SF__c,Id_Producto_SAP__c,
                    stock_ok__c,stock_no_ok__c,Cte_Consigna__c,Prv_Consigna__c
                    FROM Stock_of_matrials__c Where Control_Id_SF__c  =: result[0].Control_Id_SF__c];
        system.debug(result2); 
        
        result3 =  [SELECT Id, Name,POCH_IdProductoSAP__c FROM Product2  Where POCH_IdProductoSAP__c =: lstProduct[0].POCH_IdProductoSAP__c];
                   system.debug(result3);
  
        //String JSONMsg = '{"stock": [{"Name": "STRETCH MANUAL","stock_product_id": "00001","stock_centro": "POCHTECA MATERIAS PRIMAS TOLUCA","stock_cantidad": 0,"stock_ok": 0,"stock_no_ok":0,"cte_consigna":0,"prv_consigna":0,"stock_Almacen":"ALCR","stock_lote":"W","stock_Indicador_stock_especial":"E","stock_Indicador_bloqueo_inventario": "X","stock_numero_especial":"500","stock_Stock_valorado_libre_utilizacion":200,"stock_Control_id":"ST-GDTL00001",}]}';
        
        POCH_Integration_SAP_Stock2.MyStockClass stock = new POCH_Integration_SAP_Stock2.MyStockClass();
        POCH_Integration_SAP_Stock2.MyStockClass stock2 = new POCH_Integration_SAP_Stock2.MyStockClass();
        POCH_Integration_SAP_Stock2.MyStockClass stock3 = new POCH_Integration_SAP_Stock2.MyStockClass();
        List< POCH_Integration_SAP_Stock2.MyStockClass> Stocklist = new List< POCH_Integration_SAP_Stock2.MyStockClass>();
        stock.Name='STRETCH MANUAL';
        stock.stock_product_id = '00001';
        stock.stock_centro='GDTL';
        stock.stock_cantidad=0; 
        stock.stock_ok=0;
        stock.stock_no_ok=0;
        stock.cte_consigna= 0;
        stock.stock_Indicador_bloqueo_inventario= 'X';
        stock.stock_Indicador_stock_especial= 'X';
        stock.prv_consigna= 0;
        stock.stock_Almacen= 'ALCR';
        stock.stock_lote= 'W';
        stock.stock_numero_especial= '500';
        stock.stock_material_id= result2[0].id;
        stock.stock_Stock_valorado_libre_utilizacion= 200;
        stock.stock_Control_id= 'ST-GDTL00001';
        Stocklist.add(stock);
        
        stock2.Name='STRETCH MANUAL';
        stock2.stock_product_id = '00001';
        stock2.stock_centro='GDTL';
        stock2.stock_cantidad=0;
        stock2.stock_ok=0;
        stock2.stock_no_ok=0;
        stock2.cte_consigna= 0;
        stock2.stock_Indicador_bloqueo_inventario= 'X';
        stock2.stock_Indicador_stock_especial= 'X';
        stock2.prv_consigna= 0;
        stock2.stock_Almacen= 'ALPT';
        stock2.stock_lote= 'WE';
        stock2.stock_numero_especial= '500';
        stock2.stock_material_id= result2[0].id;
        stock2.stock_Stock_valorado_libre_utilizacion= 200;
        stock2.stock_Control_id= 'ST-GDTL00001'; 
        Stocklist.add(stock2);
        
        /*stock3.Name='STRETCH MANUAL';
        stock3.stock_product_id = '00001';
        stock3.stock_centro='GDTL';
        stock3.stock_cantidad=0; 
        stock3.stock_ok=0;
        stock3.stock_no_ok=0;
        stock3.cte_consigna= 0;
        stock3.stock_Indicador_bloqueo_inventario= 'X';
        stock3.stock_Indicador_stock_especial= 'X';
        stock3.prv_consigna= 0;
        stock3.stock_Almacen= 'ALCR';
        stock3.stock_lote= 'WE';
        stock3.stock_numero_especial= '5000';
        stock3.stock_material_id= result2[0].id;
        stock3.stock_Stock_valorado_libre_utilizacion= 2000;
        stock3.stock_Control_id= 'ST-GDTL00001';
        Stocklist.add(stock3);*/
        
		system.debug(Stocklist[0]);
        //system.debug(Stocklist[1]);
        
        test.startTest();
        
        //POST
        String JSONMsg= JSON.serialize(Stocklist);
        RestRequest req = new RestRequest();
        req.requestURI = '/integracionStockV2/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        req.requestBody = Blob.valueof(JSONMsg); 
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
        system.debug(JSONMsg);
        
        POCH_Integration_SAP_Stock2.doPost(Stocklist);        
        Test.stopTest();
        
    }
}