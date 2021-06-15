/***************************************************************************************************************
Name:        POCH_QuoteBatch.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 20-08-2019
Project:	 Pochteca

Description: Batch process for automatic quote creation based on frequency of Inventory Sheet
***************************************************************************************************************/

global class POCH_QuoteBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
      //  System.debug('::: POCH_QuoteBatch.start'); //test      
        return Database.getQueryLocator([
            SELECT Id,POCH_Sucursal__c,POCH_Sucursal__r.Name,POCH_Cuenta__c,POCH_FechaUltimaCotizacion__c,POCH_FechaSiguienteCotizacion__c,FechaActualizacionPrecios__c
            FROM POCH_HojaInventario__c   limit 1000
            
        ]);
    }
    //WHERE POCH_FechaSiguienteCotizacion__c = TODAY   where id = 'a1Z4P00000CcvFbUAJ' WHERE POCH_FechaSiguienteCotizacion__c = TODAY
    global void execute(Database.BatchableContext BC, List<POCH_HojaInventario__c> scope){
        //System.debug('::: POCH_QuoteBatch.execute'+scope);
        String res = Test.isRunningTest() ? 'TEST' : 'ERROR';
        Set<Id> setIdHojaInventario = new Set<Id>(); 
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        List<POCH_HojaInventario__c> lHojasInventarioUpd = new List<POCH_HojaInventario__c>();
        for(POCH_HojaInventario__c hi : scope) {
            if(!hi.Detalles_Inventario__r.isEmpty()) {                
                // POCH_InventorySheet_cls.actualizaPreciosItems(hi.Detalles_Inventario__r, hi.POCH_Sucursal__r.Name, hi.POCH_Cuenta__c);                
                setIdHojaInventario.add(hi.id);
            }
            hi.POCH_FechaUltimaCotizacion__c = Date.today();
            lHojasInventarioUpd.add(hi);
        }
        
        if(!lHojasInventarioUpd.isEmpty()) {
            try {
                update lHojasInventarioUpd;     
            } catch(DMLException e) { System.debug('--> ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString()); }
            
            for(POCH_HojaInventario__c hi : lHojasInventarioUpd) {
              //  System.debug('====> SBQQ.TriggerControl.isEnabled() ' + SBQQ.TriggerControl.isEnabled());   
                SBQQ.TriggerControl.disable();
                if(!test.isRunningTest()){
                    
                    quoteLines = POCH_InventorySheet_cls.quoteCurrentSheetBacht(hi.POCH_Cuenta__c, hi.Id, true);
                    
                }
                //
                SBQQ.TriggerControl.enable();
            }
            
            insert quoteLines;
            
            POCH_DetalleInventario__c[] detaInven = [SELECT Id,POCH_HojaInventario__r.POCH_Cuenta__c,  OwnerId, Name, CurrencyIsoCode, POCH_Producto__c, POCH_Sucursal__c, POCH_CantidadPotencial__c, POCH_CantidadBase__c, 
                                                     POCH_Notas__c, POCH_Sucursal__r.name,POCH_PrecioLista__c, POCH_EsPotencial__c, POCH_EsBase__c, POCH_AquienCompra__c, POCH_Moneda__c, POCH_Codigo__c,
                                                     POCH_Estatus__c, POCH_UnidadMedida__c, POCH_MonedaCompetencia__c, POCH_CantidadCompetencia__c, POCH_HojaInventario__c, POCH_uma__c,
                                                     POCH_Cliente__c, Propietario_POCH__c, POCH_UMAS__c, POCH_FactorConversion__c, POCH_UMB__c, POCH_OnlyInSFDC__c, POCH_IdExterno__c 
                                                     from POCH_DetalleInventario__c where POCH_HojaInventario__r.id  IN : setIdHojaInventario ];
            
            for(POCH_DetalleInventario__c di : detaInven) {
                POCH_InventorySheet_cls.actualizaPreciosItems(detaInven, di.POCH_Sucursal__r.Name,di.POCH_HojaInventario__r.POCH_Cuenta__c);             
                
            }
           // System.debug('====> LINEAS DE QOUT ' + quoteLines);   
            //  Database.insert(quoteLines,false);
            
            //    thisReservationItem =   (List<SBQQ__QuoteLine__c >)System.JSON.deserialize(quoteLines, List<SBQQ__QuoteLine__c>.class);
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('::: POCH_QuoteBatch.finish');
    }
    
}