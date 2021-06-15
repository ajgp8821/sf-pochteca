public class POCH_PricebookEntryTriggerHandler {
    
    public static void handlePricebookEntry(List<POCH_PricebookEntryTemp__c> lPBE_Temp) {
        
        Set<String> setIdExterno = new Set<String>();
        Set<String> setIdPBETemp = new Set<String>();
        Set<String> setIdPBErReal = new Set<String>();
         Double precio;
         boolean activo;
        Set<Id> setIdProducts = new Set<Id>();
        List<PricebookEntry> allUpdate = new List<PricebookEntry> ();
        List<ID> recordIds = new List<ID>();
        for(POCH_PricebookEntryTemp__c pbe_temp : lPBE_Temp) {
            setIdPBETemp.add(pbe_temp.Id);
            recordIds.add(pbe_temp.Id);
            setIdPBErReal.add(pbe_temp.POCH_Pricebook2__c); 
            setIdExterno.add(pbe_temp.POCH_IdExterno__c); 
            setIdProducts.add(pbe_temp.POCH_Product2__c);
            precio = pbe_temp.POCH_UnitPrice__c;
            activo = pbe_temp.POCH_IsActive__c;
        }
       // System.debug('--> ===================LISTA DE lPBE_Temp: '+activo );
        /*System.debug('--> ===================LISTA DE lPBE_Temp: '+lPBE_Temp );
        System.debug('--> ================CODIGO DEL PRODUCTO===setIdProducts: ' + setIdPBErReal);
        System.debug('--> ================CODIGO DEL PRODUCTO===setIdProducts: ' + setIdProducts);
        system.debug('PRECIO DEL LIBRO TEMPORAL======================= '+precio);*/
        Map<String,Id> mapPBE_existentes = new Map<String,Id>();
        Map<Id,Decimal> mapPBE_variacion = new Map<Id,Decimal>();
        Decimal minimoVariacion;
        Decimal maximoVariacion;
        for(PricebookEntry pbe : [SELECT Id,POCH_IdExterno__c,POCH_OrganizacionVentas__c,Product2Id,Pricebook2Id,UnitPrice,POCH_MargenMinVariacion__c,POCH_MargenMaxVariacion__c FROM PricebookEntry WHERE POCH_IdExterno__c IN : setIdExterno]){
            
        mapPBE_existentes.put(pbe.POCH_IdExterno__c, pbe.Id); 
        minimoVariacion = pbe.POCH_MargenMinVariacion__c; 
        maximoVariacion = pbe.POCH_MargenMaxVariacion__c; 
        }
        List<PricebookEntry> lPBE_Insert = new List<PricebookEntry>();
        List<PricebookEntry> lPBE_Update = new List<PricebookEntry>();
        for(POCH_PricebookEntryTemp__c pbe_temp : lPBE_Temp) {
            
            
            PricebookEntry pbe             = new PricebookEntry(); 
            pbe.IsActive 			       = pbe_temp.POCH_IsActive__c;
           
            pbe.CurrencyIsoCode            = pbe_temp.CurrencyIsoCode;
            pbe.POCH_CanalDistribucion__c  = pbe_temp.POCH_CanalDistribucion__c;
            pbe.POCH_CantidadBase__c 	   = pbe_temp.POCH_CantidadBase__c;
            pbe.POCH_FinValidez__c 		   = pbe_temp.POCH_FinValidez__c;
            pbe.POCH_IdExterno__c 		   = pbe_temp.POCH_IdExterno__c;
            pbe.POCH_InicioValidez__c 	   = pbe_temp.POCH_InicioValidez__c;
            pbe.UnitPrice 				   = pbe_temp.POCH_UnitPrice__c;
            pbe.POCH_NoRegCondicion__c 	   = pbe_temp.POCH_NoRegCondicion__c;
            pbe.POCH_OrganizacionVentas__c = pbe_temp.POCH_OrganizacionVentas__c;
            pbe.Pricebook2Id 			   = pbe_temp.POCH_Pricebook2__c;
            pbe.Product2Id 				   = pbe_temp.POCH_Product2__c;
            pbe.Unidad_de_medida__c 	   = pbe_temp.Unidad_de_medida__c;
            pbe.POCH_UnidadMedidaEscala__c = pbe_temp.POCH_UnidadMedidaEscala__c;
            pbe.UseStandardPrice 		   = false;
            
         
            if(mapPBE_existentes.containsKey(pbe_temp.POCH_IdExterno__c)) {
                pbe.Id = mapPBE_existentes.get(pbe_temp.POCH_IdExterno__c);
                lPBE_Insert.add(pbe);
            } else {
                pbe.CurrencyIsoCode = pbe_temp.CurrencyIsoCode;
                lPBE_Insert.add(pbe);
            }		            
        }
          //  System.debug('--> ===========if(!lPBE_Insert.isEmpty())========lPBE_Insert: ' + lPBE_Insert);
            
        try {
            
           handlePricebookEntryUpdate(recordIds,precio,lPBE_Insert,activo);
           
          if(!lPBE_Insert.isEmpty())
          system.debug('pas');                 
           // deletePBETemp(setIdPBETemp);
        } catch(DMLException e) { System.debug('--> ERROR: ' + e.getMessage() +' - '+ e.getStackTraceString()); }
    }

    public static void handlePricebookEntryUpdate(List<ID> recordIds, Double precio,List<PricebookEntry> lPBE_Insert,boolean activo) {
       // system.debug('pasasndio por aqui =recordIds 76====================== '+lPBE_Insert);
        
        
        Set<String> setIdExterno = new Set<String>();
        List<PricebookEntry> lPBE_update = new List<PricebookEntry>(); 
        Set<String> setIdPBETemp = new Set<String>(); 
        Set<String> setIdPBEPrioceEntry = new Set<String>();
        
        
        
        for(POCH_PricebookEntryTemp__c pbe_temp : [select id,POCH_OrganizacionVentas__c,POCH_IdExterno__c, POCH_Pricebook2__c from  POCH_PricebookEntryTemp__c  WHERE id IN : recordIds]) {
            setIdPBETemp.add(pbe_temp.Id);
            setIdExterno.add(pbe_temp.POCH_IdExterno__c);
            setIdPBEPrioceEntry.add(pbe_temp.POCH_Pricebook2__c);
        }
      //  system.debug('pasando por POCH_IdExterno__c===(()) '+setIdExterno);
        /*  if(String.isNotBlank(dt.Product2Id))  { setIdProducts.add(dt.Product2Id);  }
if(String.isNotBlank(dt.Pricebook2Id)) { setPricebooks.add(dt.Pricebook2Id); }     */
        Map<String,Id> mapPBE_existentes = new Map<String,Id>();
        for(PricebookEntry pbe : [SELECT Id,POCH_IdExterno__c,Product2Id,POCH_OrganizacionVentas__c,Pricebook2Id,UnitPrice,POCH_MargenMinVariacion__c,POCH_MargenMaxVariacion__c  FROM PricebookEntry WHERE POCH_IdExterno__c IN : setIdExterno]){
            
            lPBE_update.add(pbe);
        }
        if(lPBE_update.size() ==0){
             // UPSERT lPBE_Insert;
        }
        
        //system.debug('pasando por pbe===(()) lPBE_update 99'+lPBE_update);
          // system.debug('pasando por pbe===(()) lPBE_Insert 99'+lPBE_Insert);
       POCH_DiscountPrecEntryTriggerService.validateStatusQuoteLine(lPBE_update,precio,lPBE_Insert,activo);
       
    }
    
  /*  @future
    private static void deletePBETemp(Set<String> setIdPBETemp) {
        
     //   system.debug('pasando por future===(()) '+setIdPBETemp);
      //  delete [SELECT Id FROM POCH_PricebookEntryTemp__c WHERE Id IN : setIdPBETemp];
    }*/
    
}