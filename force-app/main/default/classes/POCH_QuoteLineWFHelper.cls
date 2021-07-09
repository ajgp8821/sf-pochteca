/***************************************************************************************************************
Name:        POCH_QuoteLineWFHelper.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:     10-09-2019
Project:     Pochteca

Description: Quote Line WF Helper Class
***************************************************************************************************************/

public class POCH_QuoteLineWFHelper {
    
    public List<SBQQ__QuoteLine__c>                    lQuoteLinesCPQ           {get;set;}
    
    public Set<String>                                 setIdAccounts            {get;set;}          
    public Map<Id,List<POCH_SucursalAmpliada__c>>      mapClienteSucursales     {get;set;}
    public Map<Id,List<POCH_Excepcion__c>>             mapClienteExcepcion      {get;set;}    
    public Map<String,Decimal>                         mapPreciosEspeciales     {get;set;}
    public Map<Id,Decimal>                             mapPrecioEntradaLibro    {get;set;}
    public Map<String,Decimal>                         mapPreciosMargen         {get;set;}
    public Map<Id,Map<Id,List<SBQQ__DiscountTier__c>>> mapProductoPrecioXEscala {get;set;}
    public Map<String,Map<String,Decimal>>             mapMargenPapel           {get;set;}
    
    public POCH_WFSettings__c                          configuracionWF          {get;set;}
    public Map<String,Id>                              mapGerenteSucursal       {get;set;}
    public Map<String,Id>                              mapAprobadordeMoneda     {get;set;}
    public Map<String,Map<String,Id>>                  mapGerenteRegional       {get;set;}
    public Map<String,Map<String,Id>>                  mapGerenteLinea          {get;set;}
    public Map<String,Map<String,Id>>                  mapDirectorDivision      {get;set;}
    public Map<String,Id>                              mapDirectorEjecutivo     {get;set;}
    public Map<String,Id>                              mapDirectorEjecutivoDe   {get;set;}
    public Map<id,String>                              mapQouteFechaCancel      {get;set;}
    public Map<id,SBQQ__QuoteLine__c>                  mapQouteDivisaMoneda     {get;set;}
    public Map<String,Id>                              mapDirectorEjecutivoGS   {get;set;}
    public Map<String,POCH_MargenProductoSinPrecio__mdt>mapMargenesPolitica     {get;set;}
    public Map<Id,Map<String,POCH_ProductoSucursal__c>> mapGrupoMateriales      {get;set;}
    
    public POCH_QuoteLineWFHelper(List<SBQQ__QuoteLine__c> lCPQQuoteLines) {               
        this.lQuoteLinesCPQ           = new List<SBQQ__QuoteLine__c>();
        this.lQuoteLinesCPQ           = lCPQQuoteLines;                                                                                                              
        
        //Obtiene los Ids de los clientes de las cotizaciones procesadas en el trigger
        getIdAccounts();
        //Agrupa en un mapa las sucursales ampliadas (pre autorizadas) por cada cliente de las cotizaciones consideradas en el trigger
        getSucursalesAmpliadasCliente();                                
        //Asigna en un mapa las excepciones de cada cliente de las cotizaciones consideradas en el trigger
        getExcepciones();
        //Asigna en un mapa las de la entrada de lista de precios 
        getPrecioEntradaLibro();
        //Obtiene la lista precios especiales de las partidas
        getPreciosEspeciales();
        getPreciosMargen();
        //Obtiene un mapa con la lista de precios de escala por volumen por producto
        getPreciosXEscala();
        //Obtiene un mapa con la del aprobador ejecutivo 
        getAprobadoresWFDe();
        getAprobadoresWFGS();
        //Retorna la configuración personalizada general de los WF (Nombre del WF, Comentarios y Aprobadores de Mat. Critico y Excepciones)
        this.configuracionWF = POCH_WFSettings__c.getOrgDefaults();
        //Obtiene los grupos de materiales por sucursal 
        getGrupoMaterialesXSucursal();
        //Obtiene la Politica de Margen
        getMargenPolitica();
        //Obtiene los Aprobadores definidos en Tipos de Metadatos Personalizados getFechaCancelado
        getAprobadoresWF();
        getFechaCancelado();
        getmapQouteDivisaMoneda();
        
    } 
    
    
    //::::::::::::::::::::::::::::::::::::::::::: METODOS PARA OBTENER DATOS RELACIONADOS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::        
    
    //Obtiene un mapa con las sucursales ampliadas relacionadas al cliente de la cotización CPQ, que cuenten con Grupo de Clientes2 asignado con LIB
    private void getSucursalesAmpliadasCliente() {
        this.mapClienteSucursales = new Map<Id,List<POCH_SucursalAmpliada__c>>();
        
        for(POCH_SucursalAmpliada__c orgVentas : [SELECT Id,POCH_Cliente__c,Poch_Sucursal__c,Poch_Sucursal__r.Name,POCH_GrupoClientes2__c FROM POCH_SucursalAmpliada__c 
                                                  WHERE POCH_Cliente__c IN : this.setIdAccounts AND Poch_Sucursal__c != null]) {
                                                      if(this.mapClienteSucursales.containsKey(orgVentas.POCH_Cliente__c))
                                                          this.mapClienteSucursales.get(orgVentas.POCH_Cliente__c).add(orgVentas);
                                                      else
                                                          this.mapClienteSucursales.put(orgVentas.POCH_Cliente__c, new List<POCH_SucursalAmpliada__c>{orgVentas});
                                                  }       
    }       
    
    //Obtiene un mapa con las excepciones por cada cliente de la cotización CPQ
    private void getExcepciones() {
        this.mapClienteExcepcion = new Map<Id,List<POCH_Excepcion__c>>(); 
        this.mapMargenPapel      = new Map<String,Map<String,Decimal>>(); 
        
        for(POCH_Excepcion__c excepcion : [SELECT Id,POCH_Cliente__c,POCH_Sucursal__r.Name,POCH_Producto__c,POCH_GrupoMateriales__c,POCH_Margen__c,RecordTypeId,RecordType.Name 
                                           FROM POCH_Excepcion__c WHERE POCH_Cliente__c IN : this.setIdAccounts OR RecordType.Name = 'Margen Papel']) 
        {
            if(excepcion.RecordType.Name == 'Margen Excepcion') {
                if(this.mapClienteExcepcion.containsKey(excepcion.POCH_Cliente__c))
                    this.mapClienteExcepcion.get(excepcion.POCH_Cliente__c).add(excepcion);
                else this.mapClienteExcepcion.put(excepcion.POCH_Cliente__c, new List<POCH_Excepcion__c>{excepcion});    
            } else {
                if(this.mapMargenPapel.containsKey(excepcion.POCH_GrupoMateriales__c)) {
                    if(!this.mapMargenPapel.get(excepcion.POCH_GrupoMateriales__c).containsKey(excepcion.POCH_GrupoMateriales__c))
                        this.mapMargenPapel.get(excepcion.POCH_GrupoMateriales__c).put(excepcion.POCH_GrupoMateriales__c, excepcion.POCH_Margen__c);                    
                } else this.mapMargenPapel.put(excepcion.POCH_GrupoMateriales__c, new Map<String,Decimal>{excepcion.POCH_GrupoMateriales__c => excepcion.POCH_Margen__c});                    
            }           
        }
    }
    private void getmapQouteDivisaMoneda() {
        set<Id> setIdQoute = new set<Id>();
        this.mapQouteDivisaMoneda = new   Map<Id,SBQQ__QuoteLine__c>();     
        for(SBQQ__QuoteLine__c ql : this.lQuoteLinesCPQ) {
            if(String.isNotBlank(ql.id))
                setIdQoute.add(ql.id);
        } 
        
        for(SBQQ__QuoteLine__c  quoteLineCPQ : [select id,SBQQ__Quote__r.Moneda_documento__c,SBQQ__Quote__r.WF_Moneda__c,CurrencyIsoCode,SBQQ__EndDate__c, SBQQ__StartDate__c, POCH_WF__c from SBQQ__QuoteLine__c where 
                                                SBQQ__Quote__r.Tiempo_cancelacion__c <> null and id =: setIdQoute ]){
                                                    this.mapQouteDivisaMoneda.put(quoteLineCPQ.Id, quoteLineCPQ);  
                                                }
    }
    private void getFechaCancelado() {
        set<Id> setIdQoute = new set<Id>();
        this.mapQouteFechaCancel = new   Map<Id,String>();     
        for(SBQQ__QuoteLine__c ql : this.lQuoteLinesCPQ) {
            if(String.isNotBlank(ql.id))
                setIdQoute.add(ql.id);
        } 
        
        for(SBQQ__QuoteLine__c  quoteLineCPQ : [select id,SBQQ__Quote__r.Tiempo_cancelacion__c,SBQQ__EndDate__c, SBQQ__StartDate__c, POCH_WF__c from SBQQ__QuoteLine__c where 
                                                SBQQ__Quote__r.Tiempo_cancelacion__c <> null and id =: setIdQoute ]){
                                                    this.mapQouteFechaCancel.put(quoteLineCPQ.Id, quoteLineCPQ.SBQQ__Quote__r.Tiempo_cancelacion__c);  
                                                }
    }
    private void getPrecioEntradaLibro() {
        set<Id> setIdPrecio = new set<Id>();
        this.mapPrecioEntradaLibro = new   Map<Id,Decimal>();     
        for(SBQQ__QuoteLine__c ql : this.lQuoteLinesCPQ) {
            if(String.isNotBlank(ql.SBQQ__PricebookEntryId__c))
                setIdPrecio.add(ql.SBQQ__PricebookEntryId__c);
        } 
        
        for(PricebookEntry  pe : [SELECT id,UnitPrice  FROM PricebookEntry  where id IN : setIdPrecio]){
            this.mapPrecioEntradaLibro.put(pe.Id, pe.UnitPrice);  
            
        }
    }
    public integer getNumeroEscalaWF(string discountTier){
        integer numeroDicont=0;
        
        for(SBQQ__DiscountTier__c  pe : [select id,SBQQ__Discount__c,SBQQ__Number__c,
                                         POCH_ImporteCondicion__c, POCH_ImporteUpper__c,
                                         POCH_Producto__c,SBQQ__Schedule__c  from SBQQ__DiscountTier__c where SBQQ__Schedule__c = : discountTier order by SBQQ__Number__c]){
                                             numeroDicont++;
                                             
                                         }
        
        return   numeroDicont;  
        
    }
    //Obtiene la lista de precios especiales
    private void getPreciosEspeciales() {
        set<id> setIdProduct = new Set<id>();
        this.mapPreciosEspeciales = new Map<String,Decimal>();
        for(SBQQ__QuoteLine__c ql : this.lQuoteLinesCPQ) {
            if(String.isNotBlank(ql.SBQQ__Product__c))
                setIdProduct.add(ql.SBQQ__Product__c);
        }        
        for(SBQQ__ContractedPrice__c cp : [SELECT Id,SBQQ__Price__c FROM SBQQ__ContractedPrice__c ]){
            this.mapPreciosEspeciales.put(cp.Id, cp.SBQQ__Price__c);   
        }
    }
    //Obtiene la lista de precios especiales
    private void getPreciosMargen() {
        this.mapPreciosMargen = new Map<String,Decimal>();
        set<id> setIdProduct = new Set<id>();
        
        for(SBQQ__QuoteLine__c ql : this.lQuoteLinesCPQ) {
            
            if(String.isNotBlank(ql.SBQQ__Product__c))
                setIdProduct.add(ql.SBQQ__Product__c);
        }
        
        for(SBQQ__ContractedPrice__c cp : [SELECT Id,SBQQ__Product__c,SBQQ__Price__c,Margen__c FROM SBQQ__ContractedPrice__c])
            //this.mapPreciosEspeciales.put(cp.Id, cp.SBQQ__Price__c);
            this.mapPreciosMargen.put(cp.Id, cp.Margen__c);        
    }
    
    //Obtiene la lista de precios de escala por volumen por producto
    private void getPreciosXEscala() {
        this.mapProductoPrecioXEscala = new Map<Id,Map<Id,List<SBQQ__DiscountTier__c>>>();
        
        Set<String> setIdProducts  = new Set<String>();
        Set<String> setDiscSched   = new Set<String>();
        Set<String> setIdPriceBook = new Set<String>();
        for(SBQQ__QuoteLine__c ql : this.lQuoteLinesCPQ) {            
            setIdProducts.add(ql.SBQQ__Product__c);            
            if(String.isNotBlank(ql.SBQQ__DiscountSchedule__c))
                setDiscSched.add(ql.SBQQ__DiscountSchedule__c);
            if(String.isNotBlank(ql.POCH_QuotePricebook__c))
                setIdPriceBook.add(ql.POCH_QuotePricebook__c);
        }
        
        for(SBQQ__DiscountTier__c precioXEscala : [SELECT Id,SBQQ__Schedule__c,SBQQ__Schedule__r.SBQQ__Product__c,SBQQ__Schedule__r.SBQQ__Pricebook__c,CurrencyIsoCode,POCH_NoRegistroCondicion__c,SBQQ__Number__c,
                                                   SBQQ__LowerBound__c,SBQQ__UpperBound__c,SBQQ__Discount__c,SBQQ__DiscountAmount__c,SBQQ__Price__c,POCH_ImporteCondicion__c,POCH_ImporteUpper__c 
                                                   FROM SBQQ__DiscountTier__c WHERE SBQQ__Schedule__r.SBQQ__Product__c IN : setIdProducts 
                                                   AND (SBQQ__Schedule__c IN : setDiscSched OR SBQQ__Schedule__r.SBQQ__Pricebook__c IN : setIdPriceBook) ORDER BY CreatedDate DESC, SBQQ__Number__c ASC]) 
        { 
            if(this.mapProductoPrecioXEscala.containsKey(precioXEscala.SBQQ__Schedule__r.SBQQ__Product__c)) {
                if(this.mapProductoPrecioXEscala.get(precioXEscala.SBQQ__Schedule__r.SBQQ__Product__c).containsKey(precioXEscala.SBQQ__Schedule__c)) {
                    this.mapProductoPrecioXEscala.get(precioXEscala.SBQQ__Schedule__r.SBQQ__Product__c).get(precioXEscala.SBQQ__Schedule__c).add(precioXEscala);
                } else this.mapProductoPrecioXEscala.get(precioXEscala.SBQQ__Schedule__r.SBQQ__Product__c).put(precioXEscala.SBQQ__Schedule__c, new List<SBQQ__DiscountTier__c>{precioXEscala});
            } else this.mapProductoPrecioXEscala.put(precioXEscala.SBQQ__Schedule__r.SBQQ__Product__c, 
                                                     new Map<Id,List<SBQQ__DiscountTier__c>>{precioXEscala.SBQQ__Schedule__c => new List<SBQQ__DiscountTier__c>{precioXEscala}});
        }
    }        
    
    //Obtiene las grupos de materi ales
    public void getGrupoMaterialesXSucursal() { 
        this.mapGrupoMateriales = new Map<Id,Map<String,POCH_ProductoSucursal__c>>();
        
        Set<Id> setIdSucursales = new Set<Id>();
        Set<Id> setIdProducts   = new Set<Id>();
        for(SBQQ__QuoteLine__c ql : this.lQuoteLinesCPQ) {
            setIdProducts.add(ql.SBQQ__Product__c);
            if(String.isNotBlank(ql.POCH_SucursalQuote__c))
                setIdSucursales.add(ql.POCH_SucursalQuote__c);
        }                
        for(POCH_ProductoSucursal__c ps : [SELECT Id, POCH_Activo__c, POCH_Producto__c, POCH_Sucursal__c, POCH_CanalDistribucion__c, POCH_GrpMat__c, POCH_GrupoMateriales1__c, 
                                           POCH_GrupoMateriales2__c, POCH_GrupoMateriales3__c, POCH_GrupoMateriales4__c, POCH_GrupoMateriales5__c FROM POCH_ProductoSucursal__c
                                           WHERE POCH_Producto__c IN : setIdProducts AND POCH_Sucursal__c IN : setIdSucursales AND POCH_Activo__c = TRUE]) 
        {
            if(this.mapGrupoMateriales.containsKey(ps.POCH_Producto__c)) {
                if(!this.mapGrupoMateriales.get(ps.POCH_Producto__c).containsKey(ps.POCH_CanalDistribucion__c)) {
                    this.mapGrupoMateriales.get(ps.POCH_Producto__c).put(ps.POCH_CanalDistribucion__c, ps);
                }
            } else {
                this.mapGrupoMateriales.put(ps.POCH_Producto__c, new Map<String,POCH_ProductoSucursal__c>{ps.POCH_CanalDistribucion__c => ps});
            }
        }
    } 
    
    //Obtiene las listas de aprobadores
    private void getMargenPolitica() {
        this.mapMargenesPolitica   = new Map<String,POCH_MargenProductoSinPrecio__mdt>();
        
        for(POCH_MargenProductoSinPrecio__mdt MPP : [SELECT Id,DeveloperName,POCH_MargenGS__c,POCH_MargenGR__c,POCH_MargenGL__c,POCH_MargenDD__c,POCH_MargenDE__c FROM POCH_MargenProductoSinPrecio__mdt])
            this.mapMargenesPolitica.put(MPP.DeveloperName, MPP);            
    }
    
    private void getAprobadoresWFDe() {
        Set<String> setIdOrVenta = new Set<String>();
        Set<Boolean> setIdCuentaClave = new Set<Boolean>();
        string orvent = '';
        for(SBQQ__QuoteLine__c ql : this.lQuoteLinesCPQ) {
            
            if(String.isNotBlank(ql.POCH_OrgVentasQuote__c)){
                setIdOrVenta.add(ql.POCH_OrgVentasQuote__c);
                //  setIdCuentaClave.add(ql.SBQQ__Quote__r.SBQQ__Account__r.POCH_CuentaClave__c);
                orvent = ql.POCH_OrgVentasQuote__c;
            }   
        }
        
        this.mapDirectorEjecutivoDe  = new Map<String,Id>();        
        List<POCH_WFAprobador__c> allWfaProb = new List<POCH_WFAprobador__c>();
        //if(setIdCuentaClave.contains(true)){
        
        //    allWfaProb = [SELECT id, RecordType.Name, POCH_OrganizacionVentas__c, POCH_Aprobador__c, POCH_Sociedad__c, POCH_GrupoMateriales__c FROM POCH_WFAprobador__c where POCH_OrganizacionVentas__c IN : setIdOrVenta and Cuenta_Clave__c =: true LIMIT 50000];
        // }else{
        allWfaProb = [SELECT id, RecordType.Name, POCH_OrganizacionVentas__c, POCH_Aprobador__c, POCH_Sociedad__c, POCH_GrupoMateriales__c FROM POCH_WFAprobador__c where POCH_OrganizacionVentas__c IN : setIdOrVenta  LIMIT 50000];
        
        //}
        for(POCH_WFAprobador__c aprobadorWF : allWfaProb) {
            
            if(aprobadorWF.RecordType.Name == 'Aprobador Director Ejecutivo') {
                this.mapDirectorEjecutivoDe.put(aprobadorWF.POCH_Sociedad__c, aprobadorWF.POCH_Aprobador__c);
            }
        }            
        //getAprobadoresWFGS  
    }
    
    private void getAprobadoresWFGS() {
        Set<String> setIdOrVenta = new Set<String>();
        Set<Boolean> setIdCuentaClaveTV = new Set<Boolean>();
        Set<Boolean> setIdGteCom1 = new Set<Boolean>();
        string orvent = ''; 
        string qt;
        
        for(SBQQ__QuoteLine__c ql : this.lQuoteLinesCPQ) {
            qt = ql.SBQQ__Quote__c;
            setIdOrVenta.add(ql.POCH_OrgVentasQuote__c);
            orvent = ql.POCH_OrgVentasQuote__c;
            
        }  
        SBQQ__Quote__c qts = [select id,SBQQ__Account__c from  SBQQ__Quote__c where id = :qt ]; 
        Account acc = [select id,TV__c,Gte_Com1__c ,name from  Account where id = :qts.SBQQ__Account__c]; 
        setIdCuentaClaveTV.add(acc.TV__c);
        setIdGteCom1.add(acc.Gte_Com1__c);        
        this.mapDirectorEjecutivoGS  = new Map<String,Id>();        
        List<POCH_WFAprobador__c> allWfaProb = new List<POCH_WFAprobador__c>();
        if(setIdCuentaClaveTV.contains(true) && setIdGteCom1.contains(false)){
            
            allWfaProb = [SELECT id, RecordType.Name, POCH_OrganizacionVentas__c,TV__c, POCH_Aprobador__c, POCH_Sociedad__c, POCH_GrupoMateriales__c FROM POCH_WFAprobador__c where POCH_OrganizacionVentas__c IN : setIdOrVenta and TV__c =: true LIMIT 50000];
            if(allWfaProb.size()==0){
                allWfaProb = [SELECT id, RecordType.Name, POCH_OrganizacionVentas__c,TV__c, POCH_Aprobador__c, POCH_Sociedad__c, POCH_GrupoMateriales__c FROM POCH_WFAprobador__c where POCH_OrganizacionVentas__c IN : setIdOrVenta and TV__c =: false and Gte_Com1__c =:false LIMIT 50000];   
            }
        }else if(setIdCuentaClaveTV.contains(false) && setIdGteCom1.contains(true)){
            
            allWfaProb = [SELECT id, RecordType.Name, Gte_Com1__c,POCH_OrganizacionVentas__c,TV__c, POCH_Aprobador__c, POCH_Sociedad__c, POCH_GrupoMateriales__c FROM POCH_WFAprobador__c where POCH_OrganizacionVentas__c IN : setIdOrVenta and Gte_Com1__c =: true LIMIT 50000];
            if(allWfaProb.size()==0){
                allWfaProb = [SELECT id, RecordType.Name, POCH_OrganizacionVentas__c,TV__c, POCH_Aprobador__c, POCH_Sociedad__c, POCH_GrupoMateriales__c FROM POCH_WFAprobador__c where POCH_OrganizacionVentas__c IN : setIdOrVenta and TV__c =: false and Gte_Com1__c =:false LIMIT 50000];   
            }
            
        }else{
            allWfaProb = [SELECT id, RecordType.Name, POCH_OrganizacionVentas__c, POCH_Aprobador__c, POCH_Sociedad__c, POCH_GrupoMateriales__c FROM POCH_WFAprobador__c where POCH_OrganizacionVentas__c IN : setIdOrVenta  LIMIT 50000];
            
        }
        for(POCH_WFAprobador__c aprobadorWF : allWfaProb) {
            
            if(aprobadorWF.RecordType.Name == 'Aprobador Gerente Sucursal') {
                this.mapDirectorEjecutivoGS.put(aprobadorWF.POCH_OrganizacionVentas__c, aprobadorWF.POCH_Aprobador__c);
            }
        }            
        
    }
    
    
    //Obtiene las listas de aprobadores
    private void getAprobadoresWF() {
        this.mapAprobadordeMoneda  = new Map<String,Id>();        
        this.mapGerenteRegional    = new Map<String,Map<String,Id>>();
        this.mapGerenteLinea       = new Map<String,Map<String,Id>>();
        this.mapDirectorDivision   = new Map<String,Map<String,Id>>();
        // this.mapDirectorEjecutivoDE  = new Map<String,Id>();        
        
        for(POCH_WFAprobador__c aprobadorWF : [SELECT RecordType.Name, POCH_OrganizacionVentas__c, POCH_Aprobador__c, POCH_Sociedad__c, POCH_GrupoMateriales__c FROM POCH_WFAprobador__c LIMIT 50000]) {
            /* if(aprobadorWF.RecordType.Name == 'Aprobador Gerente Sucursal') {
this.mapGerenteSucursal.put(aprobadorWF.POCH_OrganizacionVentas__c, aprobadorWF.POCH_Aprobador__c);   mapAprobadordeMoneda         
}*/
            if(aprobadorWF.RecordType.Name == 'Aprobador Gerente Regional') {
                if(this.mapGerenteRegional.containsKey(aprobadorWF.POCH_Sociedad__c))
                    this.mapGerenteRegional.get(aprobadorWF.POCH_Sociedad__c).put(aprobadorWF.POCH_GrupoMateriales__c,aprobadorWF.POCH_Aprobador__c);
                else this.mapGerenteRegional.put(aprobadorWF.POCH_Sociedad__c, new Map<String,Id>{aprobadorWF.POCH_GrupoMateriales__c => aprobadorWF.POCH_Aprobador__c});
            }
            if(aprobadorWF.RecordType.Name == 'Aprobador Gerente Linea') {
                if(this.mapGerenteLinea.containsKey(aprobadorWF.POCH_Sociedad__c))
                    this.mapGerenteLinea.get(aprobadorWF.POCH_Sociedad__c).put(aprobadorWF.POCH_GrupoMateriales__c,aprobadorWF.POCH_Aprobador__c);
                else this.mapGerenteLinea.put(aprobadorWF.POCH_Sociedad__c, new Map<String,Id>{aprobadorWF.POCH_GrupoMateriales__c => aprobadorWF.POCH_Aprobador__c});
            }
            if(aprobadorWF.RecordType.Name == 'Aprobador Director Division') {
                if(this.mapDirectorDivision.containsKey(aprobadorWF.POCH_Sociedad__c))
                    this.mapDirectorDivision.get(aprobadorWF.POCH_Sociedad__c).put(aprobadorWF.POCH_GrupoMateriales__c,aprobadorWF.POCH_Aprobador__c);
                else this.mapDirectorDivision.put(aprobadorWF.POCH_Sociedad__c, new Map<String,Id>{aprobadorWF.POCH_GrupoMateriales__c => aprobadorWF.POCH_Aprobador__c});
            }
           
            if(aprobadorWF.RecordType.Name == 'Aprobador Moneda') {
                this.mapAprobadordeMoneda.put(aprobadorWF.POCH_Sociedad__c, aprobadorWF.POCH_Aprobador__c);
            }
        }                              
    }
    
    
    //::::::::::::::::::::::::::::::::::::::::::: METODOS HELPER :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
    
    //Obtiene los Ids de las cuentas para posteriores consultas
    private void getIdAccounts() {
        this.setIdAccounts = new Set<String>(); 
        for(SBQQ__QuoteLine__c ql : this.lQuoteLinesCPQ)
            this.setIdAccounts.add(ql.POCH_AccountQuote__c);
    }
    
    //Obtiene el Discount Schedule de cada linea
    public String getDiscountSchedule(SBQQ__QuoteLine__c quoteLineCPQ) {
        String discountSchedule = '';
        if(String.isNotBlank(quoteLineCPQ.SBQQ__DiscountSchedule__c)) 
            discountSchedule = quoteLineCPQ.SBQQ__DiscountSchedule__c;
        else {                        
            for(String ds : this.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).keySet()) {
                discountSchedule = ds;
                break;
            }
        }
        return discountSchedule;
    }
    
    //Obtiene el Discount Schedule de cada linea
    public String getDiscountTier(SBQQ__QuoteLine__c quoteLineCPQ, String discountSchedule) {
        String discountTier = '';
        if(String.isNotBlank(quoteLineCPQ.SBQQ__DiscountTier__c)) 
            discountTier = quoteLineCPQ.SBQQ__DiscountTier__c;
        else {          
            for(SBQQ__DiscountTier__c dt : this.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).get(discountSchedule)) {
                if(quoteLineCPQ.SBQQ__Quantity__c >= dt.SBQQ__LowerBound__c && (quoteLineCPQ.SBQQ__Quantity__c <= dt.SBQQ__UpperBound__c || dt.SBQQ__UpperBound__c == NULL)) {  //quoteLineCPQ.SBQQ__Quantity__c <= dt.SBQQ__UpperBound__c - 0.00001
                    discountTier = dt.Id;
                    break;
                }
            }
        }
        return discountTier;
    }
    
    //Obtiene el grupo de materiales del aprobador
    public String getAprobadorFuncion(SBQQ__QuoteLine__c quoteLineCPQ, String funcion) {
        String grupoMateriales = '';
        String aprobadorWF     = '';
        
        if(funcion == 'GS') {
            if(this.mapDirectorEjecutivoGS.containsKey(quoteLineCPQ.POCH_OrgVentasQuote__c)) { 
                aprobadorWF = this.mapDirectorEjecutivoGS.get(quoteLineCPQ.POCH_OrgVentasQuote__c);
            }                                                              
        } else if(funcion == 'MO') {
            if(this.mapAprobadordeMoneda.containsKey(quoteLineCPQ.POCH_QuoteSociedad__c)) { aprobadorWF = this.mapAprobadordeMoneda.get(quoteLineCPQ.POCH_QuoteSociedad__c); }
        }else if(funcion == 'DE') {
            if(this.mapDirectorEjecutivoDE.containsKey(quoteLineCPQ.POCH_QuoteSociedad__c)) { aprobadorWF = this.mapDirectorEjecutivoDE.get(quoteLineCPQ.POCH_QuoteSociedad__c); }
        } else if(this.mapGrupoMateriales.containsKey(quoteLineCPQ.SBQQ__Product__c)) {
            if(this.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).containsKey(quoteLineCPQ.POCH_CanalDistribucion__c)) {
                if(funcion == 'GR') { 
                    grupoMateriales = String.isBlank(this.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrupoMateriales3__c) 
                        ? 'ND' : this.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrupoMateriales3__c;                                
                    if(this.mapGerenteRegional.containsKey(quoteLineCPQ.POCH_QuoteSociedad__c)) {
                        if(this.mapGerenteRegional.get(quoteLineCPQ.POCH_QuoteSociedad__c).containsKey(grupoMateriales))
                            aprobadorWF = this.mapGerenteRegional.get(quoteLineCPQ.POCH_QuoteSociedad__c).get(grupoMateriales);                                    
                    }                    
                }                
                if(funcion == 'GL') { 
                    grupoMateriales = String.isBlank(this.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrpMat__c) 
                        ? 'ND' : this.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrpMat__c;                                
                    if(this.mapGerenteLinea.containsKey(quoteLineCPQ.POCH_QuoteSociedad__c)) {
                        if(this.mapGerenteLinea.get(quoteLineCPQ.POCH_QuoteSociedad__c).containsKey(grupoMateriales))
                            aprobadorWF = this.mapGerenteLinea.get(quoteLineCPQ.POCH_QuoteSociedad__c).get(grupoMateriales);                                    
                    }   
                }                
                if(funcion == 'DD') { 
                    grupoMateriales = String.isBlank(this.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrupoMateriales1__c)
                        ? 'ND' : this.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrupoMateriales1__c;                                
                    if(this.mapDirectorDivision.containsKey(quoteLineCPQ.POCH_QuoteSociedad__c)) {
                        if(this.mapDirectorDivision.get(quoteLineCPQ.POCH_QuoteSociedad__c).containsKey(grupoMateriales))
                            aprobadorWF = this.mapDirectorDivision.get(quoteLineCPQ.POCH_QuoteSociedad__c).get(grupoMateriales);                                    
                    } 
                }    
            }                            
        }
        return aprobadorWF;
    }
    
}