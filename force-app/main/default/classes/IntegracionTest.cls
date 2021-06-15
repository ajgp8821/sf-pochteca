@IsTest (SeeAllData = true)
public class IntegracionTest {
    
    static TestMethod void IntegracionTest(){       
        String JSONMsg = '{"stock": [{"Name": "STRETCH MANUAL","stock_product_id": "0001","stock_centro": "POCHTECA MATERIAS PRIMAS TOLUCA","stock_cantidad": 0,"stock_ok": 0,"stock_no_ok":0,"cte_consigna":0,"prv_consigna":0,"stock_Almacen":"ALCR","stock_lote":"W","stock_Indicador_stock_especial":"E","stock_Indicador_bloqueo_inventario": "X","stock_numero_especial":"500","stock_Stock_valorado_libre_utilizacion":200,"stock_Control_id":"ST-GDTL0001",}]}';
        
        POCH_Integration_SAP_Stock.MyStockClass stock = new POCH_Integration_SAP_Stock.MyStockClass();
        List< POCH_Integration_SAP_Stock.MyStockClass> Stocklist = new List< POCH_Integration_SAP_Stock.MyStockClass>();
        stock.Name='STRETCH MANUAL';
        stock.stock_product_id='00001'; 
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
        //stock.stock_material_id= result2[0].id;
        stock.stock_Stock_valorado_libre_utilizacion= 200;
        stock.stock_Control_id= 'ST-GDTL0001';
        Stocklist.add(stock);
        system.debug(Stocklist);
        
        List<Stock_of_matrials__c> result = new list <Stock_of_matrials__c> ();
        List<Stock_of_matrials__c> result2 = new list <Stock_of_matrials__c> ();
 
        test.startTest();
        
        //POST
        RestResponse respuesta2 = new RestResponse();
        RestRequest request2 = new RestRequest();
        request2.requestURI = '/integracionStock/';
        request2.httpMethod = 'POST';
        respuesta2.addHeader('Content-Type','application/json');
        system.debug(JSONMsg);
        
        POCH_Integration_SAP_Stock.doPost(Stocklist);
        Test.stopTest();
        
    }
}