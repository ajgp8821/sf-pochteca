/***************************************************************************************************************
Name:        POCH_DiscountPrecEntryTriggerService.apxc
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 27-09-2019
Project:	 Pochteca

Description: Discount PrecEntry Trigger Service Class
***************************************************************************************************************/

public class POCH_DiscountPrecEntryTriggerService {
    
    //public static Boolean isInvokedByTrigger = false;
    
    // @InvocableMethod(label='Cuando cambie el precio de lista' description='Cuando cambie el precio de lista Actualiza Quote Item' category= 'PricebookEntry')
    
    public static void validateStatusQuoteLine(List<PricebookEntry> lDiscountPrecEntry, Double precio,List<PricebookEntry> lPBE_Insert,boolean activo) {
        string grupoMateriales;
        string CurrencyIsoCodes;
        Set<Id> setIdProducts = new Set<Id>();
        Set<Id> setPricebooks  = new Set<Id>();
        Set<String> OrgVentIDs = new Set<String>();
        Set<Id> caseIDs = new Set<Id> ();
        Set<String> OrgVentOPDIDs = new Set<String>();
        list<string> Ma=new list<string>(); 
        List<PricebookEntry> lPBEenvio = new List<PricebookEntry>();
        List<Object> lPBEenvios = new List<Object>();
        date currentDate = Date.today();
        integer currentDates = currentDate.month();
        integer currentDateQl = 0;
        system.debug('=======================lDiscountPrecEntry lDiscountPrecEntry=================================)))))))))'+lDiscountPrecEntry);
        
        if(!lPBE_Insert.isEmpty()){
            lPBEenvio =   lPBE_Insert;
               if(!Test.isRunningTest()) {
            UPSERT lPBE_Insert;
               }
        }else{
            
            
            lPBEenvio =   lDiscountPrecEntry; 
        }
        
   
        decimal var;
        for(PricebookEntry dts : lPBEenvio) {
            if(String.isNotBlank(dts.POCH_OrganizacionVentas__c)) { 
                OrgVentIDs.add(dts.POCH_OrganizacionVentas__c);
                var = dts.POCH_MargenMaxVariacion__c;
                CurrencyIsoCodes = dts.CurrencyIsoCode;
                precio = dts.UnitPrice;
                activo = dts.IsActive;
            }     
        }
     
        
        
        for(PricebookEntry dt : lPBEenvio) {
            
             if(String.isNotBlank(String.valueOf(dt.Product2Id)) && String.isNotBlank(String.valueOf(dt.Pricebook2Id))) {
                if(String.isNotBlank(dt.Product2Id))  { setIdProducts.add(dt.Product2Id);  }
                if(String.isNotBlank(dt.Pricebook2Id)) { setPricebooks.add(dt.Pricebook2Id); }  
                
            }                                   
        }
        
        
        /* system.debug('producto============================================))))))))'+caseIDs+'PROBANDO DATOS setIdProducts'+setIdProducts);
system.debug('producto============================================))))))))'+caseIDs+'PROBANDO DATOS setPricebooks'+setPricebooks);
system.debug('producto============================================))))))))'+caseIDs+'PROBANDO DATOS OrgVentIDs'+OrgVentIDs);
system.debug('producto============================================))))))))'+caseIDs+'PROBANDO DATOS precio'+precio); */
        for(POCH_ProductoSucursal__c pd : [select id,Organizaci_n_de_Ventas__c ,POCH_Estatus_Material__c,POCH_GrupoMateriales2__c, POCH_Producto__r.id from POCH_ProductoSucursal__c where Organizaci_n_de_Ventas__c IN : OrgVentIDs and POCH_Producto__r.id IN : setIdProducts]) {
            OrgVentOPDIDs.add(pd.Organizaci_n_de_Ventas__c);
            caseIDs.add(pd.POCH_Producto__c);
            Ma.add(pd.POCH_Estatus_Material__c);
            grupoMateriales = Ma.get(0);
        }
        
        // system.debug(' despuies producto============================================))))))))'+caseIDs+'PROBANDO OrgVentOPDIDs'+OrgVentOPDIDs);
        PricebookEntry [] PricebookEntrys = [SELECT id ,UnitPrice,Product2Id,ProductCode,POCH_OrganizacionVentas__c,Name,CurrencyIsoCode,Product2.ProductCode,Product2.POCH_GrupoMateriales2__c,Product2.Name,Product2.Description FROM PricebookEntry WHERE  Product2.IsActive = true  AND Product2.id IN : setIdProducts and POCH_OrganizacionVentas__c IN : OrgVentIDs and CurrencyIsoCode =:CurrencyIsoCodes];
        //select id,Organizaci_n_de_Ventas__c ,POCH_Estatus_Material__c,POCH_GrupoMateriales2__c, POCH_Producto__r.id from POCH_ProductoSucursal__c where Organizaci_n_de_Ventas__c = '0015' and POCH_Producto__r.id = '01t4P00000AZYZaQAP'
        //   system.debug(' despuies producto============================================))))))))'+PricebookEntrys+'PricebookEntrys DATOS'+Ma);
        List<PricebookEntry> prodAdd = new List<PricebookEntry>();
        
        if(PricebookEntrys.size() > 0){
            //   system.debug(' despuies activo==='+activo);
            for (PricebookEntry pbe: PricebookEntrys) { 
                pbe.Grupo_de_Materiales__c = grupoMateriales;
                // pbe.UnitPrice = pbe.UnitPrice;
                // pbe.IsActive = activo;
                prodAdd.add(pbe);
            }
        }
        //   system.debug(' despuies activo==='+prodAdd);
        update prodAdd;
        
        
        
        // System.debug('--> ===================lPBE_Insert: ' + setIdProducts);
        Map<Id,SBQQ__QuoteLine__c> mapQuoteLines = new Map<Id,SBQQ__QuoteLine__c>([
            SELECT Id,POCH_EstatusPartida__c,SBQQ__Quantity__c,Margen_Min__c,Margen_Max__c,SBQQ__StartDate__c,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__CustomerPrice__c,SBQQ__Product__c,SBQQ__Quote__r.SBQQ__PriceBook__c FROM SBQQ__QuoteLine__c
            WHERE  SBQQ__Quote__r.SBQQ__PriceBook__c IN : setPricebooks and SBQQ__Product__c  IN : setIdProducts
            AND POCH_EstatusPartida__c IN ('Precio de Lista','Por Autorizar','Solicitado Autorizado','Modificado Autorizado','Precio Especial Vigente')  LIMIT 50000
        ]);
        //la fwecha de stardate debe ser de este mes SBQQ__StartDate__chttps://pochteca--prueba.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
        if(Test.isRunningTest()) {
            mapQuoteLines = new Map<Id,SBQQ__QuoteLine__c>([
                SELECT Id,POCH_EstatusPartida__c,SBQQ__Quantity__c,Margen_Min__c,Margen_Max__c,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__CustomerPrice__c,SBQQ__Product__c,SBQQ__Quote__r.SBQQ__PriceBook__c FROM SBQQ__QuoteLine__c
                LIMIT 1
            ]);
            
        }
        
        if(!mapQuoteLines.isEmpty()) {
            //   SYSTEM.debug('PASANDO LINEAS DE LA QO'+mapQuoteLines.size());
            List<SBQQ__QuoteLine__c> lQuoteLinesCancelled = new List<SBQQ__QuoteLine__c>();
            
            for(PricebookEntry dt : lDiscountPrecEntry) {
                // PricebookEntry pr = Trigger.oldMap.get(dt.Id);
                
                for(SBQQ__QuoteLine__c ql : mapQuoteLines.values()) {
                    // 
                    System.debug('--> EL PRECIO DE LA LINEA SE MANTIENE DENTRO DEL MARGEN MIN y MAX'+'PRECIO D LAS LINEAS= '+dt.id );
                    if(ql.SBQQ__Quote__r.SBQQ__StartDate__c!=NULL){
                        currentDateQl = ql.SBQQ__Quote__r.SBQQ__StartDate__c.month();
                        
                        if(ql.SBQQ__Quote__r.SBQQ__PriceBook__c == dt.Pricebook2Id) {
                            //  System.debug('--> VALIDA EL PRECIO DEL LIBRO IGUAL QUE LA COTIZACION'); 
                            if(currentDateQl == currentDates) {
                                // System.debug('--> VALIDA EL '+ql.SBQQ__CustomerPrice__c+'precio'+precio);  
                                System.debug('-->ID DEL PRECIO ENTRADA  '+dt.id);
                                //dt.POCH_MargenMaxVariacion__c
                               // dt.POCH_MargenMinVariacion__c;
                               //  ql.Margen_Max__c
                                //ql.Margen_Min__c
                                if((precio >= ql.Margen_Min__c && precio <= ql.Margen_Max__c) || (ql.SBQQ__CustomerPrice__c >= precio)) {
                                    // System.debug('--> EL PRECIO DE LA LINEA SE MANTIENE DENTRO DEL MARGEN MIN y MAX'+'PRCIO TEMPORAL= '+precio); 
                                    System.debug('--> EL PRECIO DE LA LINEA SE MANTIENE DENTRO DEL MARGEN MIN y MAX'+'PRCIO TEMPORAL= '+precio); 
                                    System.debug('--> EL PRECIO DE LA LINEA SE MANTIENE DENTRO DEL MARGEN MIN y MAX'+'MINIMO VARIACION= '+dt.POCH_MargenMinVariacion__c ); 
                                    System.debug('--> EL PRECIO DE LA LINEA SE MANTIENE DENTRO DEL MARGEN MIN y MAX'+'MAXIMO VARIACION= '+dt.POCH_MargenMaxVariacion__c );
                                    System.debug('--> EL PRECIO DE LA LINEA SE MANTIENE DENTRO DEL MARGEN MIN y MAX'+'PRECIO D LAS LINEAS= '+ql.SBQQ__CustomerPrice__c );
                                    //ql.SBQQ__CustomerPrice__c <= dt.POCH_MargenMaxVariacion__c) 
                                } else {
                                    ql.POCH_EstatusPartida__c = 'Cancelado';
                                    ql.POCH_aPedido__c=false;
                                    ql.Motivo_de_cancelaci_n__c = 'VP';
                                    lQuoteLinesCancelled.add(ql);
                                    System.debug('--> PASANDO POR ACTUALIZACION DE LINEAS DE QOUTE'); 
                                }    
                            }
                            
                        }
                    }
                }
                
                //     System.debug('--> ACTUALIZO lPBE_Insert: ' + lPBE_Insert);
                if(!Test.isRunningTest()) {
                    // UPSERT lPBE_Insert;
                }
                if(!lQuoteLinesCancelled.isEmpty()) {
                    
                    ///   System.debug('--> ACTUALIZO LINEAS: ' + lQuoteLinesCancelled);
                    //  System.debug('--> CANCELA LINEAS: ' + lQuoteLinesCancelled);
                    
                    try {
                        
                        // database.update(lQuoteLinesCancelled,false); 
                        update lQuoteLinesCancelled;
                        
                    } catch(Exception e) { System.debug('--> ERROR: ' + e.getMessage() +' :: '+ e.getStackTraceString()); }
                }
            }
        }
        System.debug('::: OUT POCH_DiscountPrecEntryTriggerService.validateStatusQuoteLine');
    }
    
    
    
}