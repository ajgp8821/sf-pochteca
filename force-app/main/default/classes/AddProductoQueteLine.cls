public with sharing class AddProductoQueteLine {
    
    public class wrapperClass{
        @AuraEnabled public String ProductCodes;
        @AuraEnabled public Double UnitPrices;
        @AuraEnabled public String GrupodeMateriales;
        @AuraEnabled public String CurrencyIsoCodes;
        @AuraEnabled public String names;
        @AuraEnabled public String Descriptions;
        @AuraEnabled public String Familys;
        @AuraEnabled public String ids;
        
        //Product2.Name,Product2.DescriptionProduct2.Family
    }
    @AuraEnabled
    public static map<string, Object> addProductos(list<Id> lstId,string recordId) {
        Map<Id,String> mapCentros      = new Map<Id,String>();
        Map<Id,String> mapCentrosSucur = new Map<Id,String>();
        Set<String>  OrgVenc  = new Set<String>();
        Set<String>  Material = new Set<String>();
        Set<String>  Sucursal = new Set<String>();
        
        SBQQ__Quote__c[] squote =  [select id,POCH_EstatusCotizacion__c,POCH_Sucursal__c, POCH_IdOrgVentas__c,  CurrencyIsoCode,SBQQ__EndDate__c, Precio_lista__c,SBQQ__PriceBook__r.id from SBQQ__Quote__c where id =: recordId];
        map<string, Object> results = new map<string, Object>();
        List<SBQQ__QuoteLine__c> lCPQQuoteLines = new List<SBQQ__QuoteLine__c>();
         Sucursal.add(squote[0].POCH_Sucursal__c);
         OrgVenc.add(squote[0].POCH_IdOrgVentas__c);
        
        List<PricebookEntry> pb = [select id ,POCH_CantidadBase__c,UnitPrice,Product2.Family,Grupo_de_Materiales__c, Product2Id,ProductCode,Name,CurrencyIsoCode,Product2.ProductCode,Product2.Name,Product2.Description,Product2.POCH_GrupoMateriales2__c,POCH_UnidadMedidaEscala__c FROM PricebookEntry WHERE IsActive = true AND Product2.IsActive = true AND id  IN :lstId];
         
        for(POCH_Sucursal__c  sucur : [select id,POCH_Centro__c  from POCH_Sucursal__c where  id IN : Sucursal limit 1]){
            mapCentrosSucur.put(sucur.id, sucur.POCH_Centro__c);  
        }
         // System.debug('::: IN  mapCentrosSucur' + mapCentrosSucur); 
       
        
        
        if (pb.size() > 0){
            for(integer i=0; i< pb.size(); i++)
            {
                /*Material.add(pb[i].Product2Id);
                 for(CE_Suministradores__c  Sumi : [select id, Centro__c,Sucursal__c,Id_Producto_SAP__c,Material__c, Organizacion_de_ventas__c 
                                           from  CE_Suministradores__c where Material__c IN :Material and  Organizacion_de_ventas__c IN : OrgVenc and Sucursal__c IN : Sucursal limit 1]){
                                               mapCentros.put(Sumi.Material__c, sumi.Centro__c);  
                                           }
        
               */
                // mapCentros.get(pb[i].Product2Id)!=null ? mapCentros.get(pb[i].Product2Id):mapCentrosSucur.get(pb[i].Product2Id);
                SBQQ__QuoteLine__c quoteLine        = new SBQQ__QuoteLine__c();
              //  quoteLine.Centro__c = mapCentros.get(pb[i].Product2Id)!=null ? mapCentros.get(pb[i].Product2Id):mapCentrosSucur.get(pb[i].Product2Id);
              //  quoteLine.Organizaci_n_de_Ventas__c = String.valueOf(Sucursal);
                quoteLine.SBQQ__Quote__c            = recordId;
                quoteLine.SBQQ__Product__c	        = pb[i].Product2Id;
                quoteLine.SBQQ__Quantity__c	        = pb[i].POCH_CantidadBase__c;
                //quoteLine.SBQQ__CustomerPrice__c  = pb[i].UnitPrice;
                quoteLine.POCH_PrecioUnitario__c	= pb[i].UnitPrice;
                //
                quoteLine.SBQQ__PricebookEntryId__c = pb[i].Id;
                //
                quoteLine.POCH_UnidadMedidaVenta__c = pb[i].POCH_UnidadMedidaEscala__c;
                quoteLine.POCH_CantidadVenta__c     = pb[i].POCH_CantidadBase__c;
                quoteLine.CurrencyIsoCode           = squote[0].CurrencyIsoCode;
                quoteLine.POCH_IsMonthly__c			= true;
                quoteLine.EsInventario__c = false;    
                lCPQQuoteLines.add(quoteLine);
            }
        }
        Savepoint sp = Database.setSavepoint();
        
        try{
            insert lCPQQuoteLines;
            
            results.put('status', 'OK');
            results.put('msg', 'Producto selecionado.');
        }catch(Exception e){
            Database.rollback(sp);
            results.put('status', 'ERROR');
            results.put('msg', 'En Productos, ' + e.getMessage());
            results.put('error', e.getMessage());
        }
        
        return results;
        
    }
    
    @AuraEnabled
    public static List<wrapperClass>fetchPreciEntry(string recordId) {
        SBQQ__Quote__c[] squote =  [select id,POCH_EstatusCotizacion__c, CurrencyIsoCode,SBQQ__EndDate__c, Precio_lista__c,SBQQ__PriceBook__r.id from SBQQ__Quote__c where id =: recordId];
        boolean mostrarLista = true;
        date fecha = Date.today();
       
        
        if((squote[0].POCH_EstatusCotizacion__c != 'Abierta') || (squote[0].SBQQ__EndDate__c < fecha) ){
            mostrarLista = false;
        }
        
        system.debug('prueb squote[0].SBQQ__PriceBook__r.id'+squote[0].SBQQ__PriceBook__r.id);      
        List<String> idProducto = new List<String>();
        Map<Id, Id> mapIdProdSuc = new Map<Id, Id>(); // Define a new map
        List<Integer> idProdSuc = new List<Integer>();
        Integer l = 0;
        List<wrapperClass> wrapperList = new List<wrapperClass>();
        if(mostrarLista == true){
            for(PricebookEntry acc: [select id ,UnitPrice,Product2.Family,Grupo_de_Materiales__c, Product2Id,ProductCode,Name,CurrencyIsoCode,Product2.ProductCode,Product2.Name,Product2.Description,Product2.POCH_GrupoMateriales2__c, POCH_IdExterno__c FROM PricebookEntry WHERE IsActive = true AND Product2.IsActive = true AND Product2.onlyInSalesforce__c = false  AND Pricebook2Id =:squote[0].SBQQ__PriceBook__r.id AND CurrencyIsoCode=:squote[0].CurrencyIsoCode AND Grupo_de_Materiales__c <> null order by ProductCode asc   ]){
                system.debug('paso consulta'+acc.UnitPrice); 
                    system.debug('paso consulta'+acc.ProductCode);
                    system.debug('paso consulta'+acc.Product2.Description);     
                wrapperClass wc = new wrapperClass();
                wc.ids = acc.id;
                wc.ProductCodes = acc.ProductCode;
                wc.UnitPrices = acc.UnitPrice;
                wc.GrupodeMateriales = acc.Grupo_de_Materiales__c;
                wc.CurrencyIsoCodes = acc.CurrencyIsoCode;
                wc.names = acc.Product2.Name;
                wc.Descriptions = acc.Product2.Description;
                wc.Familys = acc.Product2.Family;
                wrapperList.add(wc);  
            }
            
        }
        
        //for(POCH_ProductoSucursal__c prodSucursal: [SELECT id, POCH_Producto__c FROM POCH_ProductoSucursal__c WHERE 

        return wrapperList;
        
        
    }
}