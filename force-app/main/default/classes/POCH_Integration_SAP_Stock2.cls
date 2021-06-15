@RestResource(urlMapping='/integracionStockV2/*')
global with sharing class POCH_Integration_SAP_Stock2 {
    global class MyStockClass {
        //MATERIAL
        public String Name;
        public String stock_product_id; 
        public decimal stock_cantidad;
        public String stock_centro;
        public decimal stock_ok;
        public decimal stock_no_ok;
        public decimal cte_consigna;
        public decimal prv_consigna;
        //DETALLE
        public String stock_Almacen;
        public String stock_lote;
        public String stock_Indicador_stock_especial;
        public String stock_numero_especial;
        public string stock_Indicador_bloqueo_inventario;
        public decimal stock_Stock_valorado_libre_utilizacion;
        public string stock_material_id; 
        public string stock_Control_id; 
    } 
    
    //Clase que define las variables que retornará el HTTP POST
    global class RegistrosConsulta{
        public List<Stock_of_matrials__c> Material = new List <Stock_of_matrials__c>();
        public List<Stock_details__c> Detalle_Material = new List <Stock_details__c>();   
    }
    
    @HttpPost
    global static void doPost(MyStockClass[] stock) { 
        //Declaramos la variable res que será utilizada para dar repuesta al servicio
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        
        //Declaramos las variables Nuevo y Nuevos2 para retornar en caso de ser exitoso
        List<RegistrosConsulta> Nuevos2= new List<RegistrosConsulta>();
        List<Stock_of_matrials__c> stopMaterial = new List<Stock_of_matrials__c>();
        List<Stock_details__c> stopLote = new List<Stock_details__c>();
        List<Stock_of_matrials__c> materialUpd = new List<Stock_of_matrials__c>();
        List<Stock_details__c> loteUpd = new List<Stock_details__c>();
        RegistrosConsulta Nuevos= new RegistrosConsulta();
        set<String> setIdStoDetail = new set<String>();
        set<String> setIdStoMaterial = new set<String>();
        set<Id> setIdS = new set<Id>();
        set<Id> setIdSMaterial = new set<Id>();
        boolean Data = false;
        
        Savepoint sp = Database.setSavepoint();
        
        for (MyStockClass i : stock ){ 
            
            //Encontramos el producto segun el ID de SAP
            List <Product2 > producto = [SELECT Id, Name,POCH_IdProductoSAP__c FROM Product2  Where POCH_IdProductoSAP__c =: i.stock_product_id];
            system.debug(producto);
            
            List <Stock_of_matrials__c> material = [SELECT Id, Name,POCH_Cantidad__c,POCH_Centro__c,Product__c,POCH_Control_id__c,
                                                    POCH_Stock_valorado_libre_utilizacion__c,POCH_Stock_disponible__c,Control_Id_SF__c,Id_Producto_SAP__c,
                                                    stock_ok__c,stock_no_ok__c,Cte_Consigna__c,Prv_Consigna__c
                                                    FROM Stock_of_matrials__c Where Control_Id_SF__c  =: i.stock_Control_id];
            
            system.debug(material.size());
            system.debug(material);	
            
            if(material.size() > 0 ) {
                for (Stock_of_matrials__c materialLst :  material){
                    materialLst.Name = i.Name; 
                    materialLst.POCH_Centro__c = i.stock_centro;
                    materialLst.stock_ok__c = i.stock_ok;
                    materialLst.stock_no_ok__c = i.stock_no_ok;
                    materialLst.Cte_Consigna__c = i.cte_consigna;
                    materialLst.Prv_Consigna__c = i.prv_consigna;
                    materialLst.POCH_Cantidad__c = i.stock_cantidad;
                    update materialLst;
                    system.debug(materialLst + 'Se actualizo material');
                }      
            }else{ 
                Stock_of_matrials__c Stocknuevo = new Stock_of_matrials__c();
                Stocknuevo.Name = i.Name;
                Stocknuevo.POCH_Cantidad__c = i.stock_cantidad;
                Stocknuevo.POCH_Centro__c = i.stock_centro;
                Stocknuevo.stock_ok__c = i.stock_ok;
                Stocknuevo.stock_no_ok__c = i.stock_no_ok;
                Stocknuevo.Cte_Consigna__c = i.cte_consigna;
                Stocknuevo.Prv_Consigna__c = i.prv_consigna;
                Stocknuevo.Product__c = producto[0].id;
                insert Stocknuevo;
                system.debug(Stocknuevo + 'insert de stock nuevo');
                if(i.stock_Stock_valorado_libre_utilizacion > 0){ 
                    Stock_details__c Stockdetail = new Stock_details__c();
                    Stockdetail.POCH_Almacen__c = i.stock_Almacen;
                    Stockdetail.POCH_Lote__c = i.stock_lote;
                    Stockdetail.POCH_Numero_stock_especial__c = i.stock_numero_especial;
                    Stockdetail.POCH_Indicador_stock_especial__c = i.stock_Indicador_stock_especial;
                    Stockdetail.POCH_Indicador_bloqueo_inventario__c = i.stock_Indicador_bloqueo_inventario;
                    Stockdetail.POCH_Stock_valorado_libre_utilizacion__c = i.stock_Stock_valorado_libre_utilizacion;
                    Stockdetail.Stock_of_matrials__c = Stocknuevo.id;
                    insert Stockdetail;
                    //stopLote.add(Stockdetail);
                    //system.debug(Stocknuevo + 'insert de stock nuevo y lote' + stopLote);    
                }
            } 
            
            List <Stock_of_matrials__c> materiales = [SELECT Id, Name,POCH_Cantidad__c,POCH_Centro__c,Product__c,POCH_Control_id__c,
                                                    POCH_Stock_valorado_libre_utilizacion__c,POCH_Stock_disponible__c,Control_Id_SF__c,Id_Producto_SAP__c,
                                                    stock_ok__c,stock_no_ok__c,Cte_Consigna__c,Prv_Consigna__c
                                                    FROM Stock_of_matrials__c Where Control_Id_SF__c  =: i.stock_Control_id];
            
            system.debug(materiales);
            
            
            List <Stock_details__c> Detalle = [SELECT Id, Stock_of_matrials__c,Name,POCH_Almacen__c,POCH_Lote__c,POCH_Indicador_stock_especial__c,POCH_Indicador_bloqueo_inventario__c,POCH_Stock_valorado_libre_utilizacion__c,Stock_of_matrials__r.Control_Id_SF__c
                                               FROM Stock_details__c Where Stock_of_matrials__r.id =: materiales[0].id AND POCH_Lote__c =: i.stock_lote AND POCH_Almacen__c =: i.stock_Almacen];
            system.debug(Detalle + 'detalle actualizar');
            system.debug(Detalle.size());
            
            if(Detalle.size() > 0 ) {
                //for (Stock_details__c loteLst :  Detalle){
                system.debug('---------Lote se actualiza---------');
                //if(i.stock_Stock_valorado_libre_utilizacion > 0){
                Detalle[0].POCH_Almacen__c = i.stock_Almacen;
                Detalle[0].POCH_Lote__c = i.stock_lote;
                Detalle[0].POCH_Numero_stock_especial__c = i.stock_numero_especial;
                Detalle[0].POCH_Indicador_stock_especial__c = i.stock_Indicador_stock_especial;
                Detalle[0].POCH_Indicador_bloqueo_inventario__c = i.stock_Indicador_bloqueo_inventario;
                Detalle[0].POCH_Stock_valorado_libre_utilizacion__c = i.stock_Stock_valorado_libre_utilizacion;
                update Detalle[0];
                system.debug(Detalle);
                system.debug(Detalle.size());
                system.debug(Detalle[0].POCH_Stock_valorado_libre_utilizacion__c + 'Cantidad libre Utiliza');
                system.debug(Detalle[0].POCH_Lote__c + 'Lote');
                system.debug(Detalle[0].POCH_Almacen__c + 'Almacen'); 
                setIdStoDetail.add(i.stock_Control_id);
                //}
                //}      
            }else{
                system.debug('------Se crea lote-------');
                if(i.stock_Stock_valorado_libre_utilizacion > 0){ 
                    Stock_details__c Stockdetail = new Stock_details__c();
                    Stockdetail.POCH_Almacen__c = i.stock_Almacen;
                    Stockdetail.POCH_Lote__c = i.stock_lote;
                    Stockdetail.POCH_Numero_stock_especial__c = i.stock_numero_especial;
                    Stockdetail.POCH_Indicador_stock_especial__c = i.stock_Indicador_stock_especial;
                    Stockdetail.POCH_Indicador_bloqueo_inventario__c = i.stock_Indicador_bloqueo_inventario;
                    Stockdetail.POCH_Stock_valorado_libre_utilizacion__c = i.stock_Stock_valorado_libre_utilizacion;
                    Stockdetail.Stock_of_matrials__c = material[0].id;
                    stopLote.add(Stockdetail);
                    system.debug(stopLote +'lote creado'); 
                    system.debug(stopLote[0].POCH_Stock_valorado_libre_utilizacion__c);
                }
            }
        }
        //update loteUpd;
        //update materialUpd;
        //upsert stopMaterial;
        upsert stopLote;
        system.debug(stopLote.size());
        system.debug(stopmaterial.size());
        system.debug(stopLote);
        system.debug(stopMaterial);
        
        List <Stock_details__c> DetalleZero = [SELECT Id, Stock_of_matrials__c,Name,POCH_Almacen__c,POCH_Lote__c,POCH_Indicador_stock_especial__c,POCH_Indicador_bloqueo_inventario__c,POCH_Stock_valorado_libre_utilizacion__c,Stock_of_matrials__r.Control_Id_SF__c
                                               FROM Stock_details__c Where Control__c in : setIdStoDetail AND POCH_Stock_valorado_libre_utilizacion__c = 0];
        
        system.debug(DetalleZero);
        system.debug(DetalleZero.size());
        
        delete DetalleZero;
        
        
        List <Stock_of_matrials__c> materialste = [SELECT Id, Name,POCH_Cantidad__c,POCH_Centro__c,Product__c,POCH_Control_id__c,
                                                   POCH_Stock_valorado_libre_utilizacion__c,POCH_Stock_disponible__c,Control_Id_SF__c,Id_Producto_SAP__c,
                                                   stock_ok__c,stock_no_ok__c,Cte_Consigna__c,Prv_Consigna__c
                                                   FROM Stock_of_matrials__c Where Control_Id_SF__c  in : setIdStoDetail]; 
        
        for (Stock_of_matrials__c materials : [SELECT Id, Name,POCH_Cantidad__c,POCH_Centro__c,Product__c,POCH_Control_id__c,
                                               POCH_Stock_valorado_libre_utilizacion__c,POCH_Stock_disponible__c,Control_Id_SF__c,Id_Producto_SAP__c,
                                               stock_ok__c,stock_no_ok__c,Cte_Consigna__c,Prv_Consigna__c
                                               FROM Stock_of_matrials__c Where Control_Id_SF__c  in : setIdStoDetail]) {
                                                   setIdS.add(materials.id); 
                                               }
        
        system.debug('====================VASRIOS IDIIDIDID==================='+setIdS);
        system.debug('====================INSERT ==================='+stopLote);
        
        List <Stock_of_matrials__c> one = [SELECT Id, Name,POCH_Cantidad__c,POCH_Centro__c,Product__c,POCH_Control_id__c,
                                           POCH_Stock_valorado_libre_utilizacion__c,POCH_Stock_disponible__c,Control_Id_SF__c,Id_Producto_SAP__c,
                                           stock_ok__c,stock_no_ok__c,Cte_Consigna__c,Prv_Consigna__c
                                           FROM Stock_of_matrials__c Where Control_Id_SF__c  in :setIdS]; 
        
        List <Stock_details__c> two = [SELECT Id, Stock_of_matrials__c,Name,POCH_Almacen__c,POCH_Lote__c,POCH_Indicador_stock_especial__c,POCH_Indicador_bloqueo_inventario__c,POCH_Stock_valorado_libre_utilizacion__c,
                                       Stock_of_matrials__r.Control_Id_SF__c, Stock_of_matrials__r.Id_Producto_SAP__c 
                                       FROM Stock_details__c Where Stock_of_matrials__c IN : setIdS];
        
        
        system.debug('====================LOPPP DE BUSQUEDA==================='+two);
        
        Nuevos.Material=one;
        Nuevos.Detalle_Material=two;
        Nuevos2.add(Nuevos);  
        system.debug(Nuevos2.size());
        res.responseBody = Blob.valueOf(JSON.serialize(Nuevos2));
        res.statusCode = 200;       
    }
}