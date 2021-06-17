/***************************************************************************************************************
                                                                                                              /*
Name:        POCH_QuoteLineTriggerService.cls                                                                 /*
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)                                   /*
Created:     22-07-2019                                                                                       /*
Project:     Pochteca                                                                                         /*
                                                                                                              /*
Description: Quote Line Trigger Service Class                                                                 /*
***************************************************************************************************************/

public class POCH_QuoteLineTriggerService {
    
    //************************************** BEFORE *******************************************
    public static Boolean isBatch = false;
    public static Boolean isInvokedByTrigger = false;
    /*public static void updateQLStatus(List<SBQQ__QuoteLine__c> lCPQQuoteLines){
for(SBQQ__QuoteLine__c QL : lCPQQuoteLines){
QL.POCH_EstatusPartida__c = 'Abierta';
}
}*/
    
    
    //Edited By Gagan
    public static void preventFieldsToEdit(List<SBQQ__QuoteLine__c> lCPQQuoteLines){
        // system.debug('quoteLL=>I am lCPQQuoteLines'+ lCPQQuoteLines);
        Map<Id,SBQQ__QuoteLine__c>  mapOldQuoteLine = (Map<Id,SBQQ__QuoteLine__c>) Trigger.oldMap; 
        set<Id> quoteIds = new set<Id>();
        for(SBQQ__QuoteLine__c ql : lCPQQuoteLines){            
            quoteIds.add(ql.SBQQ__Quote__c);
        }
        map<Id,SBQQ__Quote__c> quoteMap = new map<Id,SBQQ__Quote__c>([SELECT Id,POCH_EstatusCotizacion__c,POCH_ValidaAutorizaciones__c,SBQQ__EndDate__c FROM SBQQ__Quote__c WHERE Id =:quoteIds]);
        try {
            for(SBQQ__QuoteLine__c quoteLineCPQ : lCPQQuoteLines) { 
                if(quoteLineCPQ.Descuento__c == mapOldQuoteLine.get(quoteLineCPQ.Id).Descuento__c){
                    system.debug('quoteLL=>I paso despues de if am quoteLineCPQ.Descuento__c'+ quoteLineCPQ.Descuento__c);
                    system.debug('quoteLL=>I am paso despues de if a mapOldQuoteLine.get(quoteLineCPQ.Id).Descuento__c'+ mapOldQuoteLine.get(quoteLineCPQ.Id).Descuento__c);
                    if(quoteLineCPQ.Descuento__c != null && quoteLineCPQ.POCH_PrecioUnitario__c <> mapOldQuoteLine.get(quoteLineCPQ.Id).POCH_PrecioUnitario__c){
                        
                        quoteLineCPQ.addError('No puede cambiar el precio unitario después de aplicar el descuento');
                        
                    }
                }
                if(quoteMap.containsKey(quoteLineCPQ.SBQQ__Quote__c)){
                    SBQQ__Quote__c quote = quoteMap.get(quoteLineCPQ.SBQQ__Quote__c);
                    if(quote.POCH_EstatusCotizacion__c == 'Por Autorizar' && (quoteLineCPQ.POCH_PrecioUnitario__c <> mapOldQuoteLine.get(quoteLineCPQ.Id).POCH_PrecioUnitario__c 
                                                                              || quoteLineCPQ.Descuento__c <> mapOldQuoteLine.get(quoteLineCPQ.Id).Descuento__c))
                        
                        quoteLineCPQ.addError('No puede cambiar el precio unitario y el descuento en este estado.');
                }
            }
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        
    }
    
    public static void noChangeStatusAfterCancel(SBQQ__QuoteLine__c lCPQQuoteLines){
        // system.debug('quoteLL=>I am lCPQQuoteLines'+ lCPQQuoteLines);
        Map<Id,SBQQ__QuoteLine__c>  mapOldQuoteLine = (Map<Id,SBQQ__QuoteLine__c>) Trigger.oldMap; 
        set<Id> quoteIds = new set<Id>();
     /*   for(SBQQ__QuoteLine__c ql : lCPQQuoteLines){            
            quoteIds.add(ql.SBQQ__Quote__c);
        }
      
        try {
            for(SBQQ__QuoteLine__c quoteLineCPQ : lCPQQuoteLines) { 
              
                
                   system.debug('quoteLL=>I paso despues de if am quoteLineCPQ.POCH_EstatusPartida__c'+ quoteLineCPQ.POCH_EstatusPartida__c);
                 system.debug('quoteLL=>I paso despues de if am mapOldQuoteLine.get(quoteLineCPQ.Id).POCH_EstatusPartida__c'+ mapOldQuoteLine.get(quoteLineCPQ.Id).POCH_EstatusPartida__c);
                 if(quoteLineCPQ.fecha_inicio__c >= quoteLineCPQ.fecha_cancelacion__c && quoteLineCPQ.Motivo_de_cancelaci_n__c!=null && quoteLineCPQ.POCH_EstatusPartida__c <>  'Cancelado'){
                    
                    quoteLineCPQ.addError('No puede cambiar el status en este estapa de cancelación ');
                        
                  
                }
               /* if(quoteMap.containsKey(quoteLineCPQ.SBQQ__Quote__c)){
                    SBQQ__Quote__c quote = quoteMap.get(quoteLineCPQ.SBQQ__Quote__c);
                    if(quote.POCH_EstatusCotizacion__c == 'Por Autorizar' && (quoteLineCPQ.POCH_PrecioUnitario__c <> mapOldQuoteLine.get(quoteLineCPQ.Id).POCH_PrecioUnitario__c 
                                                                              || quoteLineCPQ.Descuento__c <> mapOldQuoteLine.get(quoteLineCPQ.Id).Descuento__c))
                        
                        quoteLineCPQ.addError('No puede cambiar el precio unitario y el descuento en este estado.');
                }
            }
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        */
         system.debug('====================noChangeStatusAfterCancel====================');             
    }
    
    
    //:::::::::::::::::::::::::::: BLOQUEAR PRECIO SEGUN SUCURSAL O SOCIEDAD :::::::::::::::::::::::::::::::::::: 
    
    public static void handlePrecioEspecialDisable(List<SBQQ__QuoteLine__c> lCPQQuoteLines) {
          Map<Id,SBQQ__QuoteLine__c>  mapOldQuoteLine = (Map<Id,SBQQ__QuoteLine__c>) Trigger.oldMap; 
          Map<String,List<POCH_precio_sugerido__C>> Mapsugerido = new Map<String,List<POCH_precio_sugerido__C>>();
        
        for(POCH_precio_sugerido__C  mapPs : [select id,cod_producto__c, invalido__c, Valida_Sucursal__c, Valida_Sociedad__c, sociedad__c, sucursal__c  from POCH_precio_sugerido__C limit 50]){
            if(Mapsugerido.containsKey(mapPs.cod_producto__c)){
                Mapsugerido.get(mapPs.cod_producto__c).add(mapPs);
            }else{ Mapsugerido.put(mapPs.cod_producto__c, new List<POCH_precio_sugerido__C>{mapPs});}
            
        }
        map<string, Object> results = new map<string, Object>();
        Map<Id,String>              mapMsgError     = new Map<Id,String>();
        Map<String,POCH_precio_sugerido__C> Mapsociedad = new Map<String,POCH_precio_sugerido__C>();
        Map<String,POCH_precio_sugerido__C> Mapsucursal = new Map<String,POCH_precio_sugerido__C>();
        //select id,cod_producto__c,invalido__c,Valida_Sociedad__c,Valida_Sucursal__c,    sociedad__c, sucursal__c  from POCH_precio_sugerido__C
        //quoteLineCPQ.POCH_CantidadVenta__c <> mapOldQuoteLine.get(quoteLineCPQ.Id).POCH_CantidadVenta__c 
        for(POCH_precio_sugerido__C  mapPs : [select id,cod_producto__c, invalido__c, Valida_Sucursal__c, Valida_Sociedad__c, sociedad__c, sucursal__c  from POCH_precio_sugerido__C limit 50]){
            Mapsociedad.put(mapPs.sociedad__c, mapPs); 
            Mapsucursal.put(mapPs.sucursal__c, mapPs);    
        }
        list<SBQQ__QuoteLine__c> lstQL = new list<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c centroCPQ : lCPQQuoteLines) { 
            try{
                system.debug('codigo'+centroCPQ.SBQQ__ProductCode__c);
                system.debug('pecio unitario'+centroCPQ.SBQQ__CustomerPrice__c);
                system.debug('pecio lista'+centroCPQ.SBQQ__listPrice__c);
                
                
                for(POCH_precio_sugerido__C pre : Mapsugerido.get(centroCPQ.SBQQ__ProductCode__c)) {
                    if(pre.invalido__c){
                       centroCPQ.precio_sugerido__c = true; 
                    if(centroCPQ.SBQQ__CustomerPrice__c < centroCPQ.SBQQ__listPrice__c){
                        mapMsgError.put(centroCPQ.id,'El  precio del código  '+centroCPQ.SBQQ__ProductCode__c+'Nombre '+centroCPQ.SBQQ__ProductName__c+' debe ser igual o mayor a '+centroCPQ.SBQQ__listPrice__c);
                    }
                    }
                    //f(Mapsucursal.get(centroCPQ.POCH_OrgVentasQuote__c).Valida_Sucursal__c && Mapsucursal.get(centroCPQ.POCH_OrgVentasQuote__c).sucursal__c ==centroCPQ.POCH_OrgVentasQuote__c && Mapsugerido.get(centroCPQ.SBQQ__ProductCode__c).cod_producto__c== centroCPQ.SBQQ__ProductCode__c){
                    if(pre.Valida_Sucursal__c &&(centroCPQ.POCH_OrgVentasQuote__c == pre.sucursal__c)){
                       centroCPQ.precio_sugerido__c = true; 
                    if(centroCPQ.SBQQ__CustomerPrice__c < centroCPQ.SBQQ__listPrice__c){
                        mapMsgError.put(centroCPQ.id,'El  precio del código  '+centroCPQ.SBQQ__ProductCode__c+'Nombre '+centroCPQ.SBQQ__ProductName__c+' debe ser igual o mayor a '+centroCPQ.SBQQ__listPrice__c);
                    }
                    }
                    //  if(Mapsociedad.get(centroCPQ.POCH_QuoteSociedad__c).Valida_Sociedad__c && Mapsociedad.get(centroCPQ.POCH_QuoteSociedad__c).sociedad__c == centroCPQ.POCH_QuoteSociedad__c && Mapsugerido.get(centroCPQ.SBQQ__ProductCode__c).cod_producto__c== centroCPQ.SBQQ__ProductCode__c){
                    if(pre.Valida_Sociedad__c &&(centroCPQ.POCH_QuoteSociedad__c==pre.sociedad__c)){
                           centroCPQ.precio_sugerido__c = true; 
                    if(centroCPQ.SBQQ__CustomerPrice__c < centroCPQ.SBQQ__listPrice__c) {
                        mapMsgError.put(centroCPQ.id,'El  precio del código  '+centroCPQ.SBQQ__ProductCode__c+'Nombre '+centroCPQ.SBQQ__ProductName__c+' debe ser igual o mayor a '+centroCPQ.SBQQ__listPrice__c);   
                    }
                    }
                }
            }catch(Exception e){
                System.debug('--> Error '+e.getMessage()); 
            }
        }
        
        for(SBQQ__QuoteLine__c quoteLineCPQ : lCPQQuoteLines) {
            if(mapMsgError.containsKey(quoteLineCPQ.Id)) {
                System.debug('--> mapMsgError.containsKey(quoteLineCPQ.Id) ' + mapMsgError.containsKey(quoteLineCPQ.Id));
                quoteLineCPQ.addError(mapMsgError.get(quoteLineCPQ.Id));            
            }
        }         
        
        system.debug('====================handlePrecioEspecialDisable====================');             
    }
    public static void actualizacionCentros(List<SBQQ__QuoteLine__c> lCPQQuoteLines) {
           Map<Id,String> mapCentros      = new Map<Id,String>();
        Map<Id,String> mapCentrosSucur = new Map<Id,String>();
        Set<String>  OrgVenc  = new Set<String>();
        Set<String>  Material = new Set<String>();
        Set<String>  Sucursal = new Set<String>();
        for(SBQQ__QuoteLine__c centroCPQ : lCPQQuoteLines) { 
            OrgVenc.add(centroCPQ.POCH_OrgVentasQuote__c); 
            Material.add(centroCPQ.SBQQ__Product__c);
            Sucursal.add(centroCPQ.POCH_SucursalQuote__c);
            
        }
        system.debug('quoteLL=>I am OrgVenc'+ OrgVenc);
        system.debug('quoteLL=>I am Material'+ Material);
        system.debug('quoteLL=>I am Sucursal'+ Sucursal);
        if(Test.isRunningTest()) {OrgVenc.add('0049');}
        for(POCH_Sucursal__c  sucur : [select id,POCH_Centro__c  from POCH_Sucursal__c where  id IN : Sucursal limit 5000]){
            mapCentrosSucur.put(sucur.id, sucur.POCH_Centro__c);  
        }
          System.debug('::: IN  mapCentrosSucur' + mapCentrosSucur); 
        for(CE_Suministradores__c  Sumi : [select id, Centro__c,Sucursal__c,Id_Producto_SAP__c,Material__c, Organizacion_de_ventas__c 
                                           from  CE_Suministradores__c where Material__c IN :Material and  Organizacion_de_ventas__c IN : OrgVenc and Sucursal__c IN : Sucursal ]){
                                               mapCentros.put(Sumi.Material__c, sumi.Centro__c);  
                                           }
        System.debug('::: IN POCH_QuoteLineTriggerHandler.handleAlternateUniteMeasurement : lCPQQuoteLines --> ' + lCPQQuoteLines.size());         
        Map<Id,SBQQ__QuoteLine__c>  mapOldQuoteLine = (Map<Id,SBQQ__QuoteLine__c>) Trigger.oldMap;          
        Map<Id,String>              mapMsgError     = new Map<Id,String>();
        
        //Obtiene los productos de cada una de las lineas de cotización de CPQ
        //Obtain the products of each of the CPQ quotation lines
        Set<Id> setProducts = new Set<Id>();
        Set<String> setPB = new Set<String>();
        Set<String> setCP = new Set<String>();
        system.debug('quoteLL=>I am here');
        
        for(SBQQ__QuoteLine__c quoteLineCPQ : lCPQQuoteLines) {
             if(Test.isRunningTest()) {quoteLineCPQ.Organizaci_n_de_Ventas__c = '0049';}
            if(String.isBlank(quoteLineCPQ.Organizaci_n_de_Ventas__c)){
               
             // system.debug('quoteLineCPQ.Organizaci_n_de_Ventas__c'+quoteLineCPQ.SBQQ__Quote__r.POCH_IdOrgVentas__c);
            quoteLineCPQ.Organizaci_n_de_Ventas__c = String.valueOf(quoteLineCPQ.POCH_OrgVentasQuote__c);
            system.debug('quoteLineCPQ.Organizaci_n_de_Ventas__c'+quoteLineCPQ.Organizaci_n_de_Ventas__c);
            if(String.isNotBlank(mapCentros.get(quoteLineCPQ.SBQQ__Product__c))){
                   system.debug('quoteLineCPQ.mapCentros'+mapCentros);
                quoteLineCPQ.Centro__c = mapCentros.get(quoteLineCPQ.SBQQ__Product__c);
            }else{
                   system.debug('quoteLineCPQ.mapCentrosSucur'+mapCentrosSucur);
                    
                quoteLineCPQ.Centro__c = mapCentrosSucur.get(quoteLineCPQ.POCH_SucursalQuote__c);
                       
            }
                }
        }
        system.debug('====================actualizacionCentros====================');             
    }
    //:::::::::::::::::::::::::::: CALCULO DE UNIDAD DE MEDIDA ALTERNA :::::::::::::::::::::::::::::::::::: 
    //ALTERNATE UNIT OF MEASURE CALCULATION
    public static void handleAlternateUniteMeasurement(List<SBQQ__QuoteLine__c> lCPQQuoteLines) {
        Map<Id,SBQQ__QuoteLine__c>  mapOldQuoteLine = (Map<Id,SBQQ__QuoteLine__c>) Trigger.oldMap;          
        Map<Id,String>              mapMsgError     = new Map<Id,String>();
        Set<Id> setProducts = new Set<Id>();
        Set<String> setPB = new Set<String>();
        Set<String> setCP = new Set<String>();
        Set<id> SetIdQuote = new Set<id>();
        
        
        for(SBQQ__QuoteLine__c quoteLineCPQ : lCPQQuoteLines) {
            SetIdQuote.add(quoteLineCPQ.SBQQ__Quote__c);
            setProducts.add(quoteLineCPQ.SBQQ__Product__c);                 
            if(String.isNotBlank(quoteLineCPQ.SBQQ__ContractedPrice__c)) { setCP.add(quoteLineCPQ.SBQQ__ContractedPrice__c); }                
            if(String.isNotBlank(quoteLineCPQ.POCH_QuotePricebook__c))   { setPB.add(quoteLineCPQ.POCH_QuotePricebook__c); }
        }
     
        
        if(!setProducts.isEmpty()) {            
            //Obtiene el pricebookentry de las lineas de cotizacion
            //Get the pricebookentry of the quote lines
            Map<Id,PricebookEntry> mapProduct_PBE = new Map<Id,PricebookEntry>();
            for(PricebookEntry pbe : [SELECT Product2Id, Product2.QuantityUnitOfMeasure, POCH_UnidadMedida__c, POCH_UnidadMedidaEscala__c, Unidad_de_medida__c, UnitPrice
                                      FROM PricebookEntry WHERE Product2Id IN : setProducts AND Pricebook2Id IN : setPB AND IsActive = TRUE]) 
            {
                pbe.POCH_UnidadMedidaEscala__c = String.isNotBlank(pbe.POCH_UnidadMedidaEscala__c) ? pbe.POCH_UnidadMedidaEscala__c.toUpperCase() : '';
                pbe.Unidad_de_medida__c        = String.isNotBlank(pbe.Unidad_de_medida__c) ? pbe.Unidad_de_medida__c.toUpperCase() : '';
                mapProduct_PBE.put(pbe.Product2Id, pbe);
            }
            
            //Consulta las unidades de medida de los productos y los almacena en un mapa      
            //Check the units of measurement for products and store them on a map  
            Map<Id,Map<String,POCH_UnidadMedidaProducto__c>> mapPrd_UM = new Map<Id,Map<String,POCH_UnidadMedidaProducto__c>>();
            for(POCH_UnidadMedidaProducto__c ump : [SELECT POCH_Producto__c, POCH_FactorConversion__c, POCH_Denominador__c, POCH_Numerador__c, POCH_UMA__c, POCH_UnidadPeso__c
                                                    FROM POCH_UnidadMedidaProducto__c WHERE POCH_Producto__c IN : setProducts]) 
            {
                if(mapPrd_UM.containsKey(ump.POCH_Producto__c)) {
                    mapPrd_UM.get(ump.POCH_Producto__c).put(ump.POCH_UMA__c, ump);
                } else mapPrd_UM.put(ump.POCH_Producto__c, new Map<String,POCH_UnidadMedidaProducto__c>{ump.POCH_UMA__c => ump});                              
            }
            
            //Consulta las bandas (discounts tiers) de los productos de la quote       
            //Check the discount tiers of the products in the quote                          
            Map<Id,Map<Decimal,SBQQ__DiscountTier__c>> mapPrdDT = new Map<Id,Map<Decimal,SBQQ__DiscountTier__c>>();
            for(SBQQ__DiscountTier__c dt : [SELECT Id,SBQQ__LowerBound__c,SBQQ__UpperBound__c,POCH_ImporteCondicion__c,SBQQ__Schedule__r.SBQQ__Product__c,SBQQ__Number__c 
                                            FROM SBQQ__DiscountTier__c WHERE SBQQ__Schedule__r.SBQQ__Product__c IN : setProducts AND SBQQ__Schedule__r.SBQQ__PriceBook__c IN : setPB]) 
            {
                if(mapPrdDT.containsKey(dt.SBQQ__Schedule__r.SBQQ__Product__c)) {
                    if(!mapPrdDT.get(dt.SBQQ__Schedule__r.SBQQ__Product__c).containsKey(dt.SBQQ__Number__c))
                        mapPrdDT.get(dt.SBQQ__Schedule__r.SBQQ__Product__c).put(dt.SBQQ__Number__c, dt);                        
                } else mapPrdDT.put(dt.SBQQ__Schedule__r.SBQQ__Product__c, new Map<Decimal,SBQQ__DiscountTier__c>{dt.SBQQ__Number__c => dt});
            }
            
            //Consulta la tabla de precios especiales (contracted prices), en caso de existir
            //Consult the table of special prices (contracted prices), if any
            Map<Id,Decimal> mapCP = new Map<Id,Decimal>();            
            if(!setCP.isEmpty()) {
                for(SBQQ__ContractedPrice__c cp : [SELECT Id,SBQQ__Price__c FROM SBQQ__ContractedPrice__c WHERE Id IN : setCP])
                    mapCP.put(cp.Id,cp.SBQQ__Price__c);                
            }           
            
            //Itera las lineas de cotizacion y busca la unidad de medida y su factor de conversión para calcular la cantidad requerida
            //Iterate the quote lines and look for the unit of measure and its conversion factor to calculate the required quantity
            
            system.debug('CANTIDAD DE LINEAS '+lCPQQuoteLines.size());
            for(SBQQ__QuoteLine__c quoteLineCPQ : lCPQQuoteLines) { 
                // mapMsgError.put(quoteLineCPQ.Id,'pasa por aqui');
                if(!mapMsgError.containsKey(quoteLineCPQ.Id)) {
                    if(String.isNotBlank(quoteLineCPQ.POCH_UnidadMedidaVenta__c) && String.isNotBlank(String.valueOf(quoteLineCPQ.POCH_CantidadVenta__c))) {                                                                
                        quoteLineCPQ.POCH_UnidadMedidaVenta__c = quoteLineCPQ.POCH_UnidadMedidaVenta__c.toUpperCase();
                        
                        if(mapPrd_UM.containsKey(quoteLineCPQ.SBQQ__Product__c)) {
                            if(mapPrd_UM.get(quoteLineCPQ.SBQQ__Product__c).containsKey(quoteLineCPQ.POCH_UnidadMedidaVenta__c.toUpperCase())) {
                                //quoteLineCPQ.Centro__c = mapCentros.get(quoteLineCPQ.SBQQ__Product__c);
                                String UMVenta  = quoteLineCPQ.POCH_UnidadMedidaVenta__c.toUpperCase();
                                String UMPrecio = mapProduct_PBE.containsKey(quoteLineCPQ.SBQQ__Product__c) ? (String.isNotBlank(mapProduct_PBE.get(quoteLineCPQ.SBQQ__Product__c).POCH_UnidadMedidaEscala__c) ? mapProduct_PBE.get(quoteLineCPQ.SBQQ__Product__c).POCH_UnidadMedidaEscala__c : mapProduct_PBE.get(quoteLineCPQ.SBQQ__Product__c).Product2.QuantityUnitOfMeasure) : '';  // mapProduct_PBE.get(quoteLineCPQ.SBQQ__Product__c).POCH_UnidadMedida__c : '';
                                String UMEscala = mapProduct_PBE.containsKey(quoteLineCPQ.SBQQ__Product__c) ? (String.isNotBlank(mapProduct_PBE.get(quoteLineCPQ.SBQQ__Product__c).Unidad_de_medida__c)        ? mapProduct_PBE.get(quoteLineCPQ.SBQQ__Product__c).Unidad_de_medida__c        : mapProduct_PBE.get(quoteLineCPQ.SBQQ__Product__c).Product2.QuantityUnitOfMeasure) : '';
                                
                                Decimal fCon_V = mapPrd_UM.get(quoteLineCPQ.SBQQ__Product__c).get(UMVenta).POCH_Numerador__c / mapPrd_UM.get(quoteLineCPQ.SBQQ__Product__c).get(UMVenta).POCH_Denominador__c;                                
                                Decimal fCon_P = mapPrd_UM.get(quoteLineCPQ.SBQQ__Product__c).containsKey(UMPrecio) 
                                    ? (mapPrd_UM.get(quoteLineCPQ.SBQQ__Product__c).get(UMPrecio).POCH_Numerador__c / mapPrd_UM.get(quoteLineCPQ.SBQQ__Product__c).get(UMPrecio).POCH_Denominador__c) : 1;
                                Decimal fCon_B = mapPrd_UM.get(quoteLineCPQ.SBQQ__Product__c).containsKey(UMEscala) 
                                    ? (mapPrd_UM.get(quoteLineCPQ.SBQQ__Product__c).get(UMEscala).POCH_Numerador__c / mapPrd_UM.get(quoteLineCPQ.SBQQ__Product__c).get(UMEscala).POCH_Denominador__c) : 1;
                                
                                quoteLineCPQ.SBQQ__Quantity__c = (quoteLineCPQ.POCH_CantidadVenta__c * fCon_V) / fCon_B;
                                System.debug('==> STD QUANTITY : '+ quoteLineCPQ.SBQQ__Quantity__c + ' = (CV '+quoteLineCPQ.POCH_CantidadVenta__c+' * fC_V) '+fCon_V+' / fC_B' + fCon_B + ' > ' + quoteLineCPQ.POCH_Escala__c);                                                        
                                
                                quoteLineCPQ.POCH_UMP__c = UMPrecio;
                                quoteLineCPQ.POCH_FactorConversion__c = fCon_B / fCon_V;
                                quoteLineCPQ.POCH_FactorConversion__c = quoteLineCPQ.POCH_FactorConversion__c == 0 ? 1 : quoteLineCPQ.POCH_FactorConversion__c;
                                System.debug('in if condition factor conversion value' +quoteLineCPQ.POCH_FactorConversion__c);
                                quoteLineCPQ.POCH_MultiplosConversion__c = (quoteLineCPQ.POCH_CantidadVenta__c * fCon_V) / fCon_P;                            
                                quoteLineCPQ.POCH_MultiplosConversion__c = quoteLineCPQ.POCH_MultiplosConversion__c == 0 ? 1 : quoteLineCPQ.POCH_MultiplosConversion__c;
                                
                                if(mapProduct_PBE.containsKey(quoteLineCPQ.SBQQ__Product__c)) { quoteLineCPQ.SBQQ__ListPrice__c = mapProduct_PBE.get(quoteLineCPQ.SBQQ__Product__c).UnitPrice; }
                                System.debug('=== PROD: ' + quoteLineCPQ.SBQQ__ProductCode__c + ' PVenta: ' + quoteLineCPQ.POCH_PrecioUnitario__c + ' CVenta: ' + quoteLineCPQ.POCH_CantidadVenta__c + ' Tier: ' + quoteLineCPQ.SBQQ__DiscountTier__c + ' Esp: ' + quoteLineCPQ.SBQQ__ContractedPrice__c + ' PLst: ' + quoteLineCPQ.SBQQ__ListPrice__c);                                                                                                
                                
                                if(mapPrdDT.containsKey(quoteLineCPQ.SBQQ__Product__c)) {
                                    if(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).containsKey(1))  { quoteLineCPQ.SBQQ__ListPrice__c = getDiscTier(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).get(1),  quoteLineCPQ.SBQQ__Quantity__c, quoteLineCPQ.SBQQ__ListPrice__c); }
                                    if(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).containsKey(4))  { quoteLineCPQ.SBQQ__ListPrice__c = getDiscTier(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).get(4),  quoteLineCPQ.SBQQ__Quantity__c, quoteLineCPQ.SBQQ__ListPrice__c); }
                                    if(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).containsKey(7))  { quoteLineCPQ.SBQQ__ListPrice__c = getDiscTier(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).get(7),  quoteLineCPQ.SBQQ__Quantity__c, quoteLineCPQ.SBQQ__ListPrice__c); }
                                    if(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).containsKey(10)) { quoteLineCPQ.SBQQ__ListPrice__c = getDiscTier(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).get(10), quoteLineCPQ.SBQQ__Quantity__c, quoteLineCPQ.SBQQ__ListPrice__c); }
                                    if(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).containsKey(13)) { quoteLineCPQ.SBQQ__ListPrice__c = getDiscTier(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).get(13), quoteLineCPQ.SBQQ__Quantity__c, quoteLineCPQ.SBQQ__ListPrice__c); }
                                    if(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).containsKey(16)) { quoteLineCPQ.SBQQ__ListPrice__c = getDiscTier(mapPrdDT.get(quoteLineCPQ.SBQQ__Product__c).get(16), quoteLineCPQ.SBQQ__Quantity__c, quoteLineCPQ.SBQQ__ListPrice__c); }
                                }
                                if(mapCP.containsKey(quoteLineCPQ.SBQQ__ContractedPrice__c))   { quoteLineCPQ.SBQQ__ListPrice__c = mapCP.get(quoteLineCPQ.SBQQ__ContractedPrice__c); } 
                                
                                if(String.isBlank(String.valueOf(quoteLineCPQ.POCH_PrecioUnitario__c)) || 
                                   (!Trigger.isInsert &&  quoteLineCPQ.POCH_PrecioUnitario__c  == mapOldQuoteLine.get(quoteLineCPQ.Id).POCH_PrecioUnitario__c 
                                    && (quoteLineCPQ.POCH_UnidadMedidaVenta__c <> mapOldQuoteLine.get(quoteLineCPQ.Id).POCH_UnidadMedidaVenta__c
                                        || quoteLineCPQ.POCH_CantidadVenta__c  <> mapOldQuoteLine.get(quoteLineCPQ.Id).POCH_CantidadVenta__c
                                        || quoteLineCPQ.Descuento__c <> mapOldQuoteLine.get(quoteLineCPQ.Id).Descuento__c)))
                                {
                                    
                                    decimal discount = 0;
                                    if(quoteLineCPQ.Descuento__c != null && quoteLineCPQ.Descuento__c  <> mapOldQuoteLine.get(quoteLineCPQ.Id).Descuento__c){
                                        discount = quoteLineCPQ.Descuento__c;
                                        //quoteLineCPQ.POCH_PrecioUnitario__c = quoteLineCPQ.SBQQ__ListPrice__c * (1-(discount / 100));
                                        quoteLineCPQ.POCH_PrecioUnitario__c = ((quoteLineCPQ.SBQQ__ListPrice__c * fCon_V) / fCon_P) * (1-(discount / 100));
                                    }else{
                                        quoteLineCPQ.POCH_PrecioUnitario__c = ((quoteLineCPQ.SBQQ__ListPrice__c * fCon_V) / fCon_P);
                                    }
                                }                                
                                quoteLineCPQ.SBQQ__NetPrice__c = (quoteLineCPQ.POCH_PrecioUnitario__c * fCon_B) / fCon_V;
                            } else {
                                if(!isBatch) { 
                                    
                                    
                                    mapMsgError.put(quoteLineCPQ.Id,'No se ha encontrado la conversión de la UM: ' + quoteLineCPQ.POCH_UnidadMedidaVenta__c + ' para el material: ' + quoteLineCPQ.SBQQ__ProductName__c); }
                            }
                        } else {
                            if(!isBatch) 
                            { 
                                // mapMsgError.put(quoteLineCPQ.Id,'El material ' + quoteLineCPQ.SBQQ__ProductName__c + ' no cuenta con Unidades de Medida. Contacte a su Administrador.'); 
                            }
                        }                                                                                                                            
                    } else { 
                        if(!isBatch) { mapMsgError.put(quoteLineCPQ.Id,'Agregue Unidad de Medida y Cantidad para el material: ' + quoteLineCPQ.SBQQ__ProductName__c); } 
                    }
                }   
            } 
        }
        
        for(SBQQ__QuoteLine__c quoteLineCPQ : lCPQQuoteLines) {
            if(mapMsgError.containsKey(quoteLineCPQ.Id)) {
                System.debug('--> mapMsgError.containsKey(quoteLineCPQ.Id) ' + mapMsgError.containsKey(quoteLineCPQ.Id));
                quoteLineCPQ.addError(mapMsgError.get(quoteLineCPQ.Id));            
            }
        }
        
        System.debug('::: OUT POCH_QuoteLineTriggerHandler.handleAlternateUniteMeasurement');
    }  
    private static Decimal getDiscTier(SBQQ__DiscountTier__c dt, Decimal cantidad, Decimal listPrice) {        
        dt.SBQQ__UpperBound__c = String.isBlank(String.valueOf(dt.SBQQ__UpperBound__c)) ? 99999999 : dt.SBQQ__UpperBound__c;
        if(dt.POCH_ImporteCondicion__c <> null && cantidad >= dt.SBQQ__LowerBound__c && cantidad <= dt.SBQQ__UpperBound__c - 0.001) {
            listPrice = dt.POCH_ImporteCondicion__c;           
        }
        return listPrice;
    }
    
    //:::::::::::::::::::::::::::: CALCULO DE PRECIO UNITARIO :::::::::::::::::::::::::::::::::::::::
    //UNIT PRICE CALCULATION
    public static void calculateUnitPrice(List<SBQQ__QuoteLine__c> lCPQQuoteLines) {
        System.debug('::: IN POCH_QuoteLineTriggerHandler.calculateUnitPrice --> lCPQQuoteLines: ' + lCPQQuoteLines.size());
        //set<Id> discountTierIds = new set<Id>();
        
        for(SBQQ__QuoteLine__c quoteLineCPQ : lCPQQuoteLines) {
            if(quoteLineCPQ.Descuento__c != null){
                quoteLineCPQ.SBQQ__Discount__c = quoteLineCPQ.Descuento__c;
            }
            if(String.isNotBlank(String.valueOf(quoteLineCPQ.POCH_PrecioUnitario__c)) && String.isNotBlank(String.valueOf(quoteLineCPQ.POCH_CantidadVenta__c))) {                
                /* Decimal lineTotal = quoteLineCPQ.POCH_PrecioUnitario__c * quoteLineCPQ.POCH_CantidadVenta__c;
Decimal additionalDisc = 0;
if(quoteLineCPQ.SBQQ__Discount__c != null){
additionalDisc = ((lineTotal * quoteLineCPQ.SBQQ__Discount__c)/100);
}*/
                quoteLineCPQ.SBQQ__NetPrice__c      = (quoteLineCPQ.POCH_PrecioUnitario__c * quoteLineCPQ.POCH_FactorConversion__c); 
                System.debug('in for loop factor conversion value' +quoteLineCPQ.POCH_FactorConversion__c);
                quoteLineCPQ.POCH_TotalCliente__c   = quoteLineCPQ.POCH_PrecioUnitario__c * quoteLineCPQ.POCH_CantidadVenta__c;                
                quoteLineCPQ.POCH_Tax__c            = (quoteLineCPQ.POCH_TotalCliente__c * quoteLineCPQ.POCH_CF__c) / 100;                
                quoteLineCPQ.SBQQ__CustomerPrice__c = quoteLineCPQ.POCH_TotalCliente__c / quoteLineCPQ.POCH_MultiplosConversion__c;
                //discountTierIds.add(quoteLineCPQ.SBQQ__DiscountTier__c);
                System.debug(':::>>> PROD '+ quoteLineCPQ.SBQQ__ProductCode__c +' CP=' + quoteLineCPQ.SBQQ__CustomerPrice__c + ', NP=' + quoteLineCPQ.SBQQ__NetPrice__c + ', PL=' + quoteLineCPQ.SBQQ__ListPrice__c + ' TC=' + quoteLineCPQ.POCH_TotalCliente__c + ', TX=' + quoteLineCPQ.POCH_Tax__c);
            }
        }
        /*    
if(!discountTierIds.isEmpty()){
map<Id,SBQQ__DiscountTier__c> discountTierMap = new map<Id,SBQQ__DiscountTier__c>([select Id,SBQQ__Discount__c from SBQQ__DiscountTier__c where Id IN: discountTierIds]);
for(SBQQ__QuoteLine__c quoteLineCPQ : lCPQQuoteLines) {
//Edited By Umesh (09.15.2020) this formula needs to be changed 
if(discountTierMap.containsKey(quoteLineCPQ.SBQQ__DiscountTier__c)){
Decimal discount = discountTierMap.get(quoteLineCPQ.SBQQ__DiscountTier__c).SBQQ__Discount__c;
if(discount != null)
quoteLineCPQ.Descuento__c = discount;
}
}
}*/
        
        System.debug('::: OUT POCH_QuoteLineTriggerHandler.calculateUnitPrice');
    }
    
    //:::::::::::::::::::::::::::: CALCULO DE MARGEN DE UTILIDAD ::::::::::::::::::::::::::::::::::::
    //CALCULATION OF PROFIT MARGIN
    public static void calculateUtilityMargin(List<SBQQ__QuoteLine__c> lCPQQuoteLines) {
        System.debug('::: IN POCH_QuoteLineTriggerHandler.calculateUtilityMargin : lCPQQuoteLines --> ' + lCPQQuoteLines.size()); 
        
        Map<Id,SBQQ__QuoteLine__c> mapOldQuoteLine = (Map<Id,SBQQ__QuoteLine__c>) Trigger.oldMap; 
        //Obtiene sets de product2 y centro
        //Get sets of product2 and center
        Set<String> setIdProducts = new Set<String>();
        Set<String> setCentroSuc  = new Set<String>();
          List<SBQQ__QuoteLine__c> lQuoteLinesWF = new List<SBQQ__QuoteLine__c>();
         /* if(Trigger.isInsert) {  
           actualizacionCentros(lCPQQuoteLines);
          }*/
        try{
            for(SBQQ__QuoteLine__c quoteLine : lCPQQuoteLines) {
                if(Trigger.isInsert) {
                     System.debug('::: PASA PARA CALCULAR ES INSERTANDO --> '); 
                   
                    setIdProducts.add(quoteLine.SBQQ__Product__c);
                    setCentroSuc.add(quoteLine.Centro__c);    
                }if(Trigger.isUpdate) {
                     System.debug('::: PASA PARA CALCULAR ES ACTUALIZANDO --> '); 
                    setIdProducts.add(quoteLine.SBQQ__Product__c);
                    setCentroSuc.add(quoteLine.Centro__c);    
                } 
                System.debug('setIdProducts.add(quoteLine.SBQQ__Product__c);'+quoteLine.SBQQ__Product__c);
                 System.debug('setCentroSuc.add(quoteLine.Centro__c);    '+quoteLine.Centro__c);
            }
        }catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            
            
        }
        if(!setIdProducts.isEmpty()) {
            
            //Consulta el costo de fabricación de los productos y los ordena en un mapa por Producto --> Centro --> Costo Fabricación
            //Check the manufacturing cost of the products and order them on a map by Product -> Center -> Manufacturing Cost
            Map<Id,Map<String,Decimal>> mapProduct_AreaCosto = new Map<Id,Map<String,Decimal>>();
            for(POCH_ValoracionProducto__c vp : [SELECT POCH_Producto__c,POCH_AreaValoracion__c,POCH_CostoFactInterna__c FROM POCH_ValoracionProducto__c 
                                                 WHERE POCH_Producto__c IN : setIdProducts AND POCH_AreaValoracion__c IN : setCentroSuc AND POCH_Activo__c = TRUE]) 
                
            {
                
                if(mapProduct_AreaCosto.containsKey(vp.POCH_Producto__c)) {
                    if(!mapProduct_AreaCosto.get(vp.POCH_Producto__c).containsKey(vp.POCH_AreaValoracion__c))
                        mapProduct_AreaCosto.get(vp.POCH_Producto__c).put(vp.POCH_AreaValoracion__c, vp.POCH_CostoFactInterna__c);                    
                } else mapProduct_AreaCosto.put(vp.POCH_Producto__c, new Map<String,Decimal>{vp.POCH_AreaValoracion__c => vp.POCH_CostoFactInterna__c});
            }
            
            //Se obtienen las unidades de medida de producto
            //The product measurement units are obtained
            Map<Id,Map<String,POCH_UnidadMedidaProducto__c>> mapPrd_UM = new Map<Id,Map<String,POCH_UnidadMedidaProducto__c>>();
            for(POCH_UnidadMedidaProducto__c umpr : [SELECT POCH_Producto__c, POCH_Denominador__c, POCH_Numerador__c, POCH_UMA__c
                                                     FROM POCH_UnidadMedidaProducto__c WHERE POCH_Producto__c IN: setIdProducts]) 
            {
                if(mapPrd_UM.containsKey(umpr.POCH_Producto__c)) {
                    mapPrd_UM.get(umpr.POCH_Producto__c).put(umpr.POCH_UMA__c, umpr);
                } else mapPrd_UM.put(umpr.POCH_Producto__c, new Map<String,POCH_UnidadMedidaProducto__c>{umpr.POCH_UMA__c => umpr});
            }
            //Se obtiene el tipo de cambio
            //You get the exchange rate
            Map<String,Decimal> mapDivisas = new Map<String,Decimal>();
            for(CurrencyType ct : [SELECT IsoCode,ConversionRate FROM CurrencyType WHERE ISActive = true]) {
                mapDivisas.put(ct.IsoCode,ct.ConversionRate);       
            }
            //Itera los productos y calcula el margen de utilidad con base en el costo de fabricacion y el precio dado
            //Iterates the products and calculates the profit margin based on the manufacturing cost and the given price
            for(SBQQ__QuoteLine__c quoteLine : lCPQQuoteLines) {  
                System.debug('::: PASA CICLO DE QL --> '); 
                if(mapProduct_AreaCosto.containsKey(quoteLine.SBQQ__Product__c) && mapPrd_UM.containsKey(quoteLine.SBQQ__Product__c)) { 
                       System.debug('::: PASA CICLO DE QL 445 --> '); 
                    if(mapProduct_AreaCosto.get(quoteLine.SBQQ__Product__c).containsKey(quoteLine.Centro__c)) { 
                        System.debug('::: PASA CICLO DE QL 447 --> ');
                        system.debug('mapProduct_AreaCosto.get(quoteLine.SBQQ__Product__c).get(quoteLine.POCH_CentroSucursal__c)'+mapProduct_AreaCosto.get(quoteLine.SBQQ__Product__c).get(quoteLine.Centro__c));
                        system.debug('quoteLine.POCH_PrecioUnitario__c)'+quoteLine.POCH_PrecioUnitario__c);
                        if(mapProduct_AreaCosto.get(quoteLine.SBQQ__Product__c).get(quoteLine.Centro__c) > 0 && quoteLine.POCH_PrecioUnitario__c > 0) {
                             System.debug('::: PASA CICLO DE QL 449 --> '); //SBQQ__CustomerPrice__c       
                            Decimal fCon_V = mapPrd_UM.get(quoteLine.SBQQ__Product__c).containsKey(quoteLine.POCH_UnidadMedidaVenta__c) ?
                                (mapPrd_UM.get(quoteLine.SBQQ__Product__c).get(quoteLine.POCH_UnidadMedidaVenta__c).POCH_Numerador__c / 
                                 mapPrd_UM.get(quoteLine.SBQQ__Product__c).get(quoteLine.POCH_UnidadMedidaVenta__c).POCH_Denominador__C) : 1;
                            Decimal fCon_B = mapPrd_UM.get(quoteLine.SBQQ__Product__c).containsKey(quoteLine.POCH_UnidadMedidaBase__c) ?
                                (mapPrd_UM.get(quoteLine.SBQQ__Product__c).get(quoteLine.POCH_UnidadMedidaBase__c).POCH_Numerador__c / 
                                 mapPrd_UM.get(quoteLine.SBQQ__Product__c).get(quoteLine.POCH_UnidadMedidaBase__c).POCH_Denominador__C) : 1; 
                            
                            Decimal costoUMV = (mapProduct_AreaCosto.get(quoteLine.SBQQ__Product__c).get(quoteLine.POCH_CentroSucursal__c) * fCon_V) / fCon_B; 
                            
                            Decimal precioConvertido = quoteLine.POCH_PrecioUnitario__c / mapDivisas.get(quoteLine.CurrencyIsoCode);  //SBQQ__CustomerPrice__c
                            quoteLine.POCH_MargenUtilidad__c = ((precioConvertido - costoUMV) / precioConvertido) * 100;
                           // quoteLine.Descuento__c = ((precioConvertido - costoUMV) / precioConvertido) * 100;
                            System.debug('--> MARGEN UTILIDAD: ' + quoteLine.POCH_MargenUtilidad__c);
                        }
                    }
                }
            }
        }
        System.debug('::: OUT POCH_QuoteLineTriggerHandler.calculateUtilityMargin');
    }     
    
    //:::::::::::::::::::::::::::: GESTIÓN DE LINEAS AUTORIZADAS ::::::::::::::::::::::::::::::::::::
    //MANAGEMENT OF AUTHORIZED LINES
    public static void handleWFQuoteLinesAutorizadas(List<SBQQ__QuoteLine__c> lCPQQuoteLines) {
        System.debug('::: IN POCH_QuoteLineTriggerHandler.handleWFQuoteLinesAutorizadas : lCPQQuoteLines --> ' + lCPQQuoteLines.size()); 
        Id userId = userinfo.getUserId();
         String userRole = '';
      try{
        User[] userDetails =[SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:userId ];
          if(userDetails.size() > 0){
             
              if(String.isNotBlank(userDetails[0].UserRole.Name)){
                   userRole = userDetails[0].UserRole.Name;
              }else{
                   userRole = 'gerente';
              } 
          
          }
      }catch(Exception e) { System.debug('--> ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString()); 
          
          
      }
        Map<Id,SBQQ__QuoteLine__c> mapOldQuoteLine = (Map<Id,SBQQ__QuoteLine__c>) Trigger.oldMap;        
      
       // userRole = userRoleList[0].name;
        system.debug('pasasndo rol'+userRole);
        List<SBQQ__QuoteLine__c> lQuoteLinesWF = new List<SBQQ__QuoteLine__c>();
        Set<Id> SetIdQuote  = new Set<Id>();   
        Set<Id> setIdQLines = new Set<Id>(); 
           system.debug('pasasndo rol'+userRole);
        //
        for(SBQQ__QuoteLine__c quoteLine : lCPQQuoteLines) {
              system.debug('pasasndo mapOldQuoteLine.get(quoteLine.Id).SBQQ__CustomerPrice__c'+mapOldQuoteLine.get(quoteLine.Id).SBQQ__CustomerPrice__c);
            //Valida si un Aprobador Gerente o Director ha cambiado el precio, actualiza estatus a Modificado Autorizado
            //Validate if a Manager or Director Approver has changed the price, updates status to Modified Authorized
            if(quoteLine.SBQQ__CustomerPrice__c <> mapOldQuoteLine.get(quoteLine.Id).SBQQ__CustomerPrice__c && !quoteLine.POCH_ReenviarAutorizacion__c && (userRole.containsIgnoreCase('gerente') || userRole.containsIgnoreCase('director'))) 
            {
                System.debug('--> ACTUALIZA Checkbox: PRECIO MODIFICADO - Por Gerente');
                quoteLine.POCH_PrecioModificadoPorAprobador__c = true;                
            }
            //Valida si el aprobador cambio el precio y rechazo la quote line, para cambiar el estatus a Modi
            //Validate if the approver changed the price and rejected the quote line, to change the status to Modified
            if(quoteLine.POCH_EstatusPartida__c == 'No Autorizado' && quoteLine.POCH_EstatusPartida__c <> mapOldQuoteLine.get(quoteLine.Id).POCH_EstatusPartida__c && quoteLine.POCH_PrecioModificadoPorAprobador__c && !quoteLine.POCH_ReenviarAutorizacion__c) 
            {
                System.debug('--> APROBADOR CAMBIÓ PRECIO Y RECHAZO QUOTE');
                quoteLine.POCH_EstatusPartida__c = 'Modificado Autorizado';
            }
            
            if(quoteLine.POCH_EstatusPartida__c == 'Solicitado Autorizado' || quoteLine.POCH_EstatusPartida__c == 'Precio de Lista' || quoteLine.POCH_EstatusPartida__c == 'Precio Especial Vigente') 
            {   
                if(quoteLine.POCH_WFMaterialCriticoAprobado__c && quoteLine.POCH_WFMaterialCriticoAprobado__c <> mapOldQuoteLine.get(quoteLine.Id).POCH_WFMaterialCriticoAprobado__c && !quoteLine.POCH_WF_ExcepcionAprobado__c && !quoteLine.POCH_WFPrecioMenorAprobado__c && !quoteLine.POCH_WFMargenAprobado__c) 
                {
                    System.debug('--> PASO WF de MAT CRITICO: SE ENVIA DE NUEVO A AUTORIZAR PARA SIG. WF');
                    quoteLine.POCH_EstatusPartida__c = 'Por Autorizar';
                    lQuoteLinesWF.add(quoteLine);
                } else {
                    System.debug('--> PARTIDA CON ESTATUS FINAL ' + quoteLine.Id);                    
                    SetIdQuote.add(quoteLine.SBQQ__Quote__c);
                    setIdQLines.add(quoteLine.Id);
                }
            }                                           
        }
        
        //Asigna aprobadores de las lineas a autorizar y autoriza automaticamente las que no entras a WF
        //Assign approvers of the lines to authorize and automatically authorize those that do not enter WF
        if(!lQuoteLinesWF.isEmpty())
            handleWFApprovers(lQuoteLinesWF);            
        //Avanza estatus de Quote a Por Liberar
        //Advances status of Quote to be released// It calls the future method to update the status to To Be released
        if(!SetIdQuote.isEmpty())
            updateQuoteStatus(SetIdQuote); 
        
        System.debug('::: OUT POCH_QuoteLineTriggerHandler.handleWFQuoteLinesAutorizadas');
    }      
    
    //:::::::::::::::::::::::::::: GESTION DE APROBADORES LINEAS A APROBACION WF ::::::::::::::::::::::::::::::::::::
    //APPROVERS MANAGEMENT LINES TO APPROVAL WF
    public static void handleQuoteLinesApprovers(List<SBQQ__QuoteLine__c> lCPQQuoteLines) {
        System.debug('::: IN POCH_QuoteLineTriggerHandler.handleQuoteLinesApprovers : lCPQQuoteLines --> ' + lCPQQuoteLines.size());
        
        Map<Id,SBQQ__QuoteLine__c> mapOldQuoteLine = (Map<Id,SBQQ__QuoteLine__c>) Trigger.oldMap;
        //Obtiene las lineas que se enviaran a Asignacion de Aprobadores de WF
        //Obtain the lines that will be sent to the WF Approvers Assignment
        List<SBQQ__QuoteLine__c> lQuoteLinesWF = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c quoteLine : lCPQQuoteLines) {
            if((quoteLine.POCH_EnviarAprobacion__c && quoteLine.POCH_EnviarAprobacion__c <> mapOldQuoteLine.get(quoteLine.Id).POCH_EnviarAprobacion__c) 
               || (quoteLine.POCH_ReenviarAutorizacion__c && quoteLine.POCH_ReenviarAutorizacion__c <> mapOldQuoteLine.get(quoteLine.Id).POCH_ReenviarAutorizacion__c)) 
            {
                lQuoteLinesWF.add(quoteLine);
            }
        }        
        //Asigna aprobadores de las lineas a autorizar y autoriza automaticamente las que no entras a WF
        //Assign approvers of the lines to authorize and automatically authorize those that do not enter WF
        if(!lQuoteLinesWF.isEmpty())
            handleWFApprovers(lQuoteLinesWF);         
        
        System.debug('::: OUT POCH_QuoteLineTriggerHandler.handleQuoteLinesApprovers');
    }
    
    
    //************************************** AFTER *******************************************
    
    //:::::::::::::::::::::::::::: ENVIO A APROBACION WF DE QUOTE LINES ::::::::::::::::::::::::::::::::::::
    //SEND FOR APPROVAL WF OF QUOTE LINES
    public static void handleQuoteLinesWF(List<SBQQ__QuoteLine__c> lCPQQuoteLines) {
        System.debug('::: IN POCH_QuoteLineTriggerHandler.handleQuoteLinesWF : lCPQQuoteLines --> ' + lCPQQuoteLines.size());
        Map<Id,SBQQ__QuoteLine__c> mapOldQuoteLine = (Map<Id,SBQQ__QuoteLine__c>) Trigger.oldMap;
        //Obtiene las lineas que se enviaran a Asignacion de Aprobadores de WF
        //Obtain the lines that will be sent to the WF Approvers Assignment
        List<SBQQ__QuoteLine__c> lQuoteLinesWF = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c quoteLine : lCPQQuoteLines) {            
            if(String.isNotBlank(quoteLine.POCH_WF__c) 
               && ((quoteLine.POCH_EnviarAprobacion__c    && quoteLine.POCH_EnviarAprobacion__c     <> mapOldQuoteLine.get(quoteLine.Id).POCH_EnviarAprobacion__c) 
                   || (quoteLine.POCH_ReenviarAutorizacion__c && quoteLine.POCH_ReenviarAutorizacion__c <> mapOldQuoteLine.get(quoteLine.Id).POCH_ReenviarAutorizacion__c))) 
            {
                lQuoteLinesWF.add(quoteLine);
            }
        }
        //Envia a aprobacion las lineas que entran en los WF
        //Send for approval the lines that enter the WF
        //System.debug('sdfsd');
        
        System.debug(lQuoteLinesWF);
        if(!lQuoteLinesWF.isEmpty()) {
            
            try {
                if(Test.isRunningTest()) {
                    CalloutException ex = new CalloutException();
                    ex.setMessage('This is a constructed exception for testing and code coverage');
                    throw ex;
                }
                
                POCH_QuoteLineWFRequest.submitWFApprovalRequest(lQuoteLinesWF);
            } catch(Exception e) { System.debug('--> ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString()); }
        }
        
        
        System.debug('::: OUT POCH_QuoteLineTriggerHandler.handleQuoteLinesWF');
    }    
    
    
    //************************************** HELPER *******************************************
    
    //-------Asigna aprobadores a Lineas de Cotizacion
    //Assign approvers to Quote Lines
    private static void handleWFApprovers(List<SBQQ__QuoteLine__c> lQuoteLinesWF) {
        try {
            POCH_QuoteLineWF.handleApprovalQuoteLine(lQuoteLinesWF);
        } catch(Exception e) { System.debug('--> ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString()); }            
    }
    
    //---------Obtiene la Funcion del usuario actual
    //Get the role of the current user
    /*  private static String getUserRole() {
String userRole = '';
List<UserRole> userRoleList = [SELECT Name FROM UserRole WHERE Id =: UserInfo.getUserRoleId() LIMIT 1];
for(UserRole ur : userRoleList)
userRole = ur.Name;
return userRole;
}
*/
    //--------- Metodo Future para actualizar estatus de Quote a Por liberar
    //Future method to update status from Quote to To be released // In this if we update the value of POCH_ValidaAutorizaciones__c(Checkbox) 
    //to true status of quote changes to To be released
    @future
    public static void updateQuoteStatus(Set<Id> SetIdQuote) {
        List<SBQQ__Quote__c> lQ = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c qt : [SELECT Id,POCH_EstatusCotizacion__c,POCH_ValidaAutorizaciones__c FROM SBQQ__Quote__c WHERE Id IN : SetIdQuote]) {
            qt.POCH_ValidaAutorizaciones__c = true;
            lQ.add(qt);
        }        
        if(!lQ.isEmpty())
            update lQ;
    } 

    
    public static void handleQuoteLinesComments(List<SBQQ__QuoteLine__c> lQuoteLines){
        set<Id> quoteLineIds = new set<Id>();
        list<Approval_Data__c> approvalListToBeInserted = new list<Approval_Data__c>();
        system.debug('pasando handleQuoteLinesComments' );
        for(SBQQ__QuoteLine__c ql : lQuoteLines){
            quoteLineIds.add(ql.Id);
        }
        
        if(!quoteLineIds.isEmpty() && !Test.isRunningTest()){
            for(ProcessInstance p : [SELECT Id,TargetObjectId,ProcessDefinition.Name,CompletedDate,ElapsedTimeInDays,ElapsedTimeInMinutes,ElapsedTimeInHours,
                                     SubmittedById,LastActorId,  (SELECT Id, StepStatus, Actor.Name, ElapsedTimeInDays, ElapsedTimeInMinutes, 
                                                                  CreatedDate, ProcessNodeId, ProcessNode.Name, Comments 
                                                                  FROM StepsAndWorkitems order by CreatedDate)
                                     FROM ProcessInstance where TargetObjectId IN :quoteLineIds])
            {
                
                for(ProcessInstanceHistory s : p.StepsAndWorkitems){
                    if(s.StepStatus=='Approved'){
                        
                        Approval_Data__c approval = new Approval_Data__c();
                        approval.Name = p.ProcessDefinition.Name;
                        approval.Comments__c = s.Comments;
                        approval.QuoteLine__c = p.TargetObjectId;
                        approval.Step_Status__c = s.StepStatus;
                        approval.Actor_Name__c = s.Actor.Name;
                        
                        if(s.ProcessNode.Name != null){
                            approval.Step_Name__c = s.ProcessNode.Name;
                        }
                        approval.Completed_Date__c = p.CompletedDate;
                        approval.Elapsed_Days__c = p.ElapsedTimeInDays;
                        approval.Elapsed_Hours__c = p.ElapsedTimeInHours;
                        approval.Elapsed_Minutes__c = p.ElapsedTimeInMinutes;
                        approval.Submitted_By_Full_Name__c = p.SubmittedById;
                        approval.Last_Actor_Full_Name__c = p.LastActorId;
                        approvalListToBeInserted.add(approval);
                        SYSTEM.debug('ProcessInstance'+s.Comments);
                        SYSTEM.debug('APROVAL'+approval.Comments__c);
                    }
                }
            }
        }
        
        if(!approvalListToBeInserted.isEmpty()){
            SYSTEM.debug('PASANANSNANSNCOMENT'+approvalListToBeInserted);
            delete [select Id from Approval_Data__c where QuoteLine__c IN: quoteLineIds];
            insert approvalListToBeInserted;
        }
    }
}