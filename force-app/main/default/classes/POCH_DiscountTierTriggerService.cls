/***************************************************************************************************************
Name:        POCH_DiscountTierTriggerService.apxc
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 27-09-2019
Project:	 Pochteca

Description: Discount Tier Trigger Service Class
***************************************************************************************************************/

public class POCH_DiscountTierTriggerService {
    
    public static Boolean isInvokedByTrigger = false;
    
    public static void assignDiscountCurrencyAndUpperBound(List<SBQQ__DiscountTier__c> lDiscountTier) {
        System.debug('::: IN POCH_DiscountTierTriggerService.assignDiscountCurrencyAndUpperBound(lDiscountTier) : ' + lDiscountTier);
        
        if(isInvokedByTrigger)
            return;
        else isInvokedByTrigger = false;
        
        Set<String> setNumRegistroCondicion = new set<String>();
        Set<String> setDiscountSchedule     = new Set<String>();
        for(SBQQ__DiscountTier__c discountTier : lDiscountTier) {
            if(String.isNotBlank(discountTier.POCH_NoRegistroCondicion__c))
                setNumRegistroCondicion.add(discountTier.POCH_NoRegistroCondicion__c);
            setDiscountSchedule.add(discountTier.SBQQ__Schedule__c);
        }
        
        Map<String,PricebookEntry> mapNumRegCon_PBE = new Map<String,PricebookEntry>();
        for(PricebookEntry pbe : [SELECT Id,POCH_NoRegCondicion__c,UnitPrice,CurrencyIsoCode FROM PricebookEntry WHERE POCH_NoRegCondicion__c IN : setNumRegistroCondicion])
            mapNumRegCon_PBE.put(pbe.POCH_NoRegCondicion__c, pbe);
        
        for(SBQQ__DiscountTier__c discountTier : lDiscountTier) {
            if(String.isNotBlank(discountTier.POCH_NoRegistroCondicion__c) && mapNumRegCon_PBE.containsKey(discountTier.POCH_NoRegistroCondicion__c)) {
                 System.debug('::: IN VALIDO QUE EXISTE discountTier.POCH_NoRegistroCondicion__c: '+discountTier.POCH_NoRegistroCondicion__c);
                PricebookEntry pbe = mapNumRegCon_PBE.get(discountTier.POCH_NoRegistroCondicion__c);
                discountTier.CurrencyIsoCode = pbe.CurrencyIsoCode;
                if(pbe.UnitPrice <> 0 && discountTier.POCH_ImporteCondicion__c <> null)
                    discountTier.SBQQ__Discount__c = 100 * (1 - (discountTier.POCH_ImporteCondicion__c / pbe.UnitPrice));
                system.debug('HOLA');
            }
        }        
        if(!setDiscountSchedule.isEmpty()) 
            updateDiscountSchedule(setDiscountSchedule);
        
        System.debug('::: OUT POCH_DiscountTierTriggerService.assignDiscountCurrencyAndUpperBound');
    }
    
    @future
    public static void updateDiscountSchedule(set<String> setDiscountSchedule) {
        System.debug('--> setDiscountSchedule : ' + setDiscountSchedule);
        List<SBQQ__DiscountSchedule__c> lDiscSch = new List<SBQQ__DiscountSchedule__c>();
        for(SBQQ__DiscountSchedule__c de : [SELECT Id FROM SBQQ__DiscountSchedule__c WHERE Id IN : setDiscountSchedule]) {
            de.POCH_UpdateTiers__c = true;
            lDiscSch.add(de);
        }
        if(!lDiscSch.isEmpty())
            update lDiscSch;
    }
    
    public static void validateStatusQuoteLine(List<SBQQ__DiscountTier__c> lDiscountTier) {
        System.debug(':::=================SE INVALIDA TRIGGER ');
        
     /*   Set<Id> setIdProducts = new Set<Id>();
        Set<Id> setPricebooks  = new Set<Id>();
        for(SBQQ__DiscountTier__c dt : lDiscountTier) {
            
            system.debug('========================================================)))))))))'+dt.SBQQ__UpperBound__c+'otrooo==='+dt.POCH_ImporteCondicion__c);
            
            if(String.isNotBlank(String.valueOf(dt.SBQQ__UpperBound__c)) && String.isNotBlank(String.valueOf(dt.POCH_ImporteCondicion__c))) {
                if(String.isNotBlank(dt.POCH_Producto__c))  { setIdProducts.add(dt.POCH_Producto__c);  }
                if(String.isNotBlank(dt.POCH_Pricebook__c)) { setPricebooks.add(dt.POCH_Pricebook__c); }     
            }                                   
        }
        
        Map<Id,SBQQ__QuoteLine__c> mapQuoteLines = new Map<Id,SBQQ__QuoteLine__c>([
            SELECT Id,POCH_EstatusPartida__c,SBQQ__Quantity__c,SBQQ__CustomerPrice__c,SBQQ__Product__c,SBQQ__Quote__r.SBQQ__PriceBook__c FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Product__c IN : setIdProducts AND SBQQ__Quote__r.SBQQ__PriceBook__c IN : setPricebooks AND SBQQ__Quote__r.SBQQ__EndDate__c >= TODAY
            AND POCH_EstatusPartida__c IN ('Precio de Lista','Solicitado Autorizado','Modificado Autorizado','Precio Especial Vigente') LIMIT 50000
        ]);
        
        if(Test.isRunningTest()) {
            mapQuoteLines = new Map<Id,SBQQ__QuoteLine__c>([
                SELECT Id,POCH_EstatusPartida__c,SBQQ__Quantity__c,SBQQ__CustomerPrice__c,SBQQ__Product__c,SBQQ__Quote__r.SBQQ__PriceBook__c FROM SBQQ__QuoteLine__c
                LIMIT 1
            ]);
            
        }
        
        
        system.debug('========================================================)))))))))'+mapQuoteLines);
        if(!mapQuoteLines.isEmpty()) {
            
            List<SBQQ__QuoteLine__c> lQuoteLinesCancelled = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__DiscountTier__c dt : lDiscountTier) {
                for(SBQQ__QuoteLine__c ql : mapQuoteLines.values()) {
                    
                    
                    if(ql.SBQQ__Product__c == dt.POCH_Producto__c && ql.SBQQ__Quote__r.SBQQ__PriceBook__c == dt.POCH_Pricebook__c) {
                        if(ql.SBQQ__Quantity__c >= dt.SBQQ__LowerBound__c && ql.SBQQ__Quantity__c <= dt.SBQQ__UpperBound__c - 0.0001) {
                            if(ql.SBQQ__CustomerPrice__c >= dt.POCH_MargenMinVariacion__c && ql.SBQQ__CustomerPrice__c <= dt.POCH_MargenMaxVariacion__c) {
                                System.debug('--> EL PRECIO DE LA LINEA SE MANTIENE DENTRO DEL MARGEN MIN y MAX'); 
                                
                            } else {
                                ql.POCH_EstatusPartida__c = 'Cancelado por Variación de Precio';
                                ql.POCH_aPedido__c=false;
                                lQuoteLinesCancelled.add(ql);
                            }    
                            
                        }
                    }
                }
                
                if(!lQuoteLinesCancelled.isEmpty()) {
                    System.debug('--> CANCELA LINEAS: ' + lQuoteLinesCancelled);
                    try {
                        
                        update lQuoteLinesCancelled;
                    } catch(Exception e) { System.debug('--> ERROR: ' + e.getMessage() +' :: '+ e.getStackTraceString()); }
                }
            }
        }
        System.debug('::: OUT POCH_DiscountTierTriggerService.validateStatusQuoteLine');
   */
    }

    
}