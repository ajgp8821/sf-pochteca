@RestResource(urlMapping='/integracionPrice/*')
global with sharing class Poch_Integration_SAP_Price {
    global class MyPriceClass {
        // PricebookEntriesTemp
        public String POCH_Pricebook2; 
        public String pricePOCH_IDExternoCurrency;
        public String pricePOCH_IDExterno;
        public String pricePOCHCurrency;
        public String POCH_IdProductoSAP; 
        public decimal CurrencyIsoCode; 
        public String POCH_CanalDistribucion; 
        public decimal POCH_CantidadBase;
        public date POCH_FinValidez;
        public decimal POCH_IdExterno;
        public date POCH_InicioValidez;
        public string POCH_NoRegCondicion;
        public string POCH_OrganizacionVentas;
        public string POCH_UnidadMedidaEscala;
        public decimal POCH_UnitPrice;
        public string Unidad_de_medida;     
    } 
    
    //Clase que define las variables que retornará el HTTP POST
    global class RegistrosConsulta{
        public List<POCH_PricebookEntryTemp__c> PricebookEntryTemp = new List <POCH_PricebookEntryTemp__c>();
        //public List<Stock_details__c> Detalle_Material = new List <Stock_details__c>();   
    }
    
    @HttpPost
    global static void doPost(MyPriceClass[] price) { 
        //Declaramos la variable res que será utilizada para dar repuesta al servicio
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        
        //Declaramos las variables Nuevo y Nuevos2 para retornar en caso de ser exitoso
        List<RegistrosConsulta> Nuevos2= new List<RegistrosConsulta>();
        List<POCH_PricebookEntryTemp__c> pricestop = new List<POCH_PricebookEntryTemp__c>();
        List<POCH_PricebookEntryTemp__c> pricestop2 = new List<POCH_PricebookEntryTemp__c>();
        set<String> setIdStoPrice = new set<String>();
        //set<String> setIdStoMaterial = new set<String>();
        set<Id> setIdS = new set<Id>();
        //set<Id> setIdSMaterial = new set<Id>();
        RegistrosConsulta Nuevos= new RegistrosConsulta();
        Savepoint sp = Database.setSavepoint();
        
        Date fechafin = Date.parse('31/12/2021');
        Date fecha = Date.today();
        boolean upd= false;
        
        for (MyPriceClass i : price ){ 
            
            List <POCH_PricebookEntryTemp__c> PricebookEntrylist = [SELECT Id,Name,PriceProducto__c,PriceIdExterno__c,POCH_IsActive__c,POCH_NoRegCondicion__c FROM POCH_PricebookEntryTemp__c Where POCH_IdExternoSF__c =: i.pricePOCH_IDExterno];
            system.debug(PricebookEntrylist);
            system.debug(PricebookEntrylist.size());
            
            if(PricebookEntrylist.size() > 0 ) {
                for (POCH_PricebookEntryTemp__c lstprice :  PricebookEntrylist){
                    lstprice.POCH_IsActive__c = false;
                    system.debug(lstprice);
                    update lstprice;
                }
            }
            
            List <Pricebook2> listaprecio = [SELECT Id,Name,POCH_IdExterno__c FROM Pricebook2 Where POCH_IdExterno__c  =: i.POCH_OrganizacionVentas];
            
            system.debug(listaprecio.size()); 
            system.debug(listaprecio);
            
            List <Product2 > producto = [SELECT Id, Name,POCH_IdProductoSAP__c FROM Product2  Where POCH_IdProductoSAP__c =: i.POCH_IdProductoSAP];
            system.debug(producto);
            system.debug(producto.size()); 
            
            List <POCH_PricebookEntryTemp__c> PricebookEntrylistCur = [SELECT Id,Name,PriceProducto__c,PriceIdExterno__c,POCH_IsActive__c,POCH_NoRegCondicion__c,POCH_IdExterno__c,POCH_IdExternoSF__c 
                                                                       FROM POCH_PricebookEntryTemp__c Where POCH_IdExterno__c =: i.pricePOCH_IDExternoCurrency];
            system.debug(PricebookEntrylistCur);
            system.debug(PricebookEntrylistCur.size());
            
            //si el  con lista y producto No existe
            if(PricebookEntrylistCur.size()==0 ) { 
                //Se Crea el PricebookEntryTemp
                POCH_PricebookEntryTemp__c PricebookEntry = new POCH_PricebookEntryTemp__c();
                PricebookEntry.POCH_IsActive__c = true;
                PricebookEntry.CurrencyIsoCode = i.pricePOCHCurrency;
                PricebookEntry.POCH_CanalDistribucion__c = i.POCH_CanalDistribucion;
                PricebookEntry.POCH_CantidadBase__c = i.POCH_CantidadBase;
                PricebookEntry.POCH_FinValidez__c = fechafin;
                PricebookEntry.POCH_IdExterno__c = i.pricePOCH_IDExternoCurrency;
                PricebookEntry.POCH_InicioValidez__c = i.POCH_InicioValidez;
                PricebookEntry.POCH_UnitPrice__c = i.POCH_UnitPrice;
                PricebookEntry.POCH_OrganizacionVentas__c = i.POCH_OrganizacionVentas;
                PricebookEntry.POCH_NoRegCondicion__c = i.POCH_NoRegCondicion;
                PricebookEntry.POCH_UnidadMedidaEscala__c = i.POCH_UnidadMedidaEscala;
                PricebookEntry.Unidad_de_medida__c = i.Unidad_de_medida;
                PricebookEntry.POCH_Pricebook2__c = listaprecio[0].id;
                PricebookEntry.POCH_Product2__c = producto[0].id;
                system.debug(PricebookEntry); 
                pricestop.add(PricebookEntry);
                setIdStoPrice.add(i.pricePOCH_IDExternoCurrency); 
            }else{
                PricebookEntrylistCur[0].POCH_CanalDistribucion__c = i.POCH_CanalDistribucion;
                PricebookEntrylistCur[0].POCH_IsActive__c = true;
                PricebookEntrylistCur[0].CurrencyIsoCode = i.pricePOCHCurrency;
                PricebookEntrylistCur[0].POCH_CantidadBase__c = i.POCH_CantidadBase;
                PricebookEntrylistCur[0].POCH_FinValidez__c = fechafin;
                PricebookEntrylistCur[0].POCH_IdExterno__c = i.pricePOCH_IDExternoCurrency;
                PricebookEntrylistCur[0].POCH_InicioValidez__c = i.POCH_InicioValidez;
                PricebookEntrylistCur[0].POCH_UnitPrice__c = i.POCH_UnitPrice;
                PricebookEntrylistCur[0].POCH_OrganizacionVentas__c = i.POCH_OrganizacionVentas;
                PricebookEntrylistCur[0].POCH_NoRegCondicion__c = i.POCH_NoRegCondicion;
                PricebookEntrylistCur[0].POCH_UnidadMedidaEscala__c = i.POCH_UnidadMedidaEscala;
                PricebookEntrylistCur[0].Unidad_de_medida__c = i.Unidad_de_medida;
                PricebookEntrylistCur[0].POCH_Pricebook2__c = listaprecio[0].id;
                PricebookEntrylistCur[0].POCH_Product2__c = producto[0].id;
                update PricebookEntrylistCur[0];
                upd = true;
                pricestop2.add(PricebookEntrylistCur[0]);
                system.debug(PricebookEntrylistCur[0]);
            } 
        }
        
        upsert pricestop;
        system.debug(pricestop);
        system.debug(pricestop.size());
        
        List <POCH_PricebookEntryTemp__c> PricebookEntryTemps = [SELECT Id,Name,POCH_IdExterno__c 
                                                                 FROM POCH_PricebookEntryTemp__c Where POCH_IdExterno__c in : setIdStoPrice]; 
        
        for (POCH_PricebookEntryTemp__c PricebookEntryTemps2 : [SELECT Id,Name,POCH_IdExterno__c 
                                                                FROM POCH_PricebookEntryTemp__c Where POCH_IdExterno__c in : setIdStoPrice]) {
                                                                    setIdS.add(PricebookEntryTemps2.id); 
                                                                }
        
        system.debug('==VASRIOS IDIIDIDID=='+setIdS);
        system.debug('==INSERT =='+pricestop);
        
        
        if (upd == true){
            Nuevos.PricebookEntryTemp=pricestop2;}else{
                Nuevos.PricebookEntryTemp=pricestop;}
        Nuevos2.add(Nuevos);  
        system.debug(Nuevos2.size());
        system.debug(Nuevos2);
        res.responseBody = Blob.valueOf(JSON.serialize(Nuevos2));
        res.statusCode = 200;  
    }
}