/***************************************************************************************************************
Name:        POCH_DiscountScheduleTriggerServicer.apxc
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 27-09-2019
Project:	 Pochteca

Description: Discount Schedule Trigger Service Class
***************************************************************************************************************/

public class POCH_DiscountScheduleTriggerService {
    
    public static void deleteOldSchedule(List<SBQQ__DiscountSchedule__c> lDiscountSchedule) {
        System.debug('::: IN POCH_DiscountScheduleTriggerService.deleteOldSchedule(lDiscountSchedule) : ' + lDiscountSchedule);
        
        Set<String> setIdProduct = new Set<String>();
        Set<String> setPriceBook = new Set<String>();
        for(SBQQ__DiscountSchedule__c ds : lDiscountSchedule) {
            if(String.isNotBlank(ds.SBQQ__Product__c)) {
                setIdProduct.add(ds.SBQQ__Product__c);
            }
            if(String.isNotBlank(ds.SBQQ__Pricebook__c)) {
                setPriceBook.add(ds.SBQQ__Pricebook__c);
            }
        }
        
        Map<String,SBQQ__DiscountSchedule__c> mapKey_IdDS = new Map<String,SBQQ__DiscountSchedule__c>();
        for(SBQQ__DiscountSchedule__c ds : [SELECT Id,SBQQ__Product__c,SBQQ__Pricebook__c FROM SBQQ__DiscountSchedule__c 
                                            WHERE SBQQ__Product__c IN : setIdProduct AND SBQQ__Pricebook__c IN : setPriceBook ORDER BY CreatedDate DESC]) 
        {
            if(!mapKey_IdDS.containsKey(String.valueOf(ds.SBQQ__Product__c) + String.valueOf(ds.SBQQ__Pricebook__c))) { mapKey_IdDS.put(String.valueOf(ds.SBQQ__Product__c) + String.valueOf(ds.SBQQ__Pricebook__c),ds); }                
        }
        
        Set<Id> setDS = new Set<Id>();
        for(SBQQ__DiscountSchedule__c ds : lDiscountSchedule) {
            if(Trigger.IsInsert && !mapKey_IdDS.isEmpty()) {
                if(mapKey_IdDS.containsKey(String.valueOf(ds.SBQQ__Product__c) + String.valueOf(ds.SBQQ__Pricebook__c))) {                    
                	//ds.SBQQ__OriginalDiscountSchedule__c = mapKey_IdDS.get(String.valueOf(ds.SBQQ__Product__c) + String.valueOf(ds.SBQQ__Pricebook__c)).Id;    
                    setDS.add(mapKey_IdDS.get(String.valueOf(ds.SBQQ__Product__c) + String.valueOf(ds.SBQQ__Pricebook__c)).Id);
                }                    
            }
        }
        
        if(!setDS.isEmpty()) {
            deletSchedules(setDS);
        }
        
        System.debug('::: OUT POCH_DiscountScheduleTriggerService.deleteOldSchedule');
    }
    
    @future
    public static void deletSchedules(Set<Id> setDS) {
        delete [SELECT Id FROM SBQQ__DiscountSchedule__c WHERE Id IN : setDS];
    }
    
    public static void handleDiscountTiers(List<SBQQ__DiscountSchedule__c> lDiscountSchedule) {
        System.debug('::: IN POCH_DiscountScheduleTriggerService.handleDiscountTiers(lDiscountSchedule) : ' + lDiscountSchedule);
        
        Set<String> setIdDiscountSchedule = new Set<String>();
        for(SBQQ__DiscountSchedule__c ds : lDiscountSchedule) {
            if(ds.POCH_UpdateTiers__c)
                setIdDiscountSchedule.add(ds.Id);
        }
        
        Map<Id,List<SBQQ__DiscountTier__c>> mapDisSch_lDiscTier = new Map<Id,List<SBQQ__DiscountTier__c>>();
        for(SBQQ__DiscountTier__c dt : [SELECT Id,SBQQ__Schedule__c,POCH_NoRegistroCondicion__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c,Name,SBQQ__Number__c,POCH_ImporteCondicion__c,POCH_ImporteUpper__c 
                                        FROM SBQQ__DiscountTier__c WHERE SBQQ__Schedule__c IN : setIdDiscountSchedule ORDER BY SBQQ__Number__c ASC]) 
        {
            if(mapDisSch_lDiscTier.containskey(dt.SBQQ__Schedule__c))
                mapDisSch_lDiscTier.get(dt.SBQQ__Schedule__c).add(dt);
            else mapDisSch_lDiscTier.put(dt.SBQQ__Schedule__c, new List<SBQQ__DiscountTier__c>{dt});
        }
        
        List<SBQQ__DiscountTier__c> lDiscTierUpperBound_Upd = new List<SBQQ__DiscountTier__c>();
        List<SBQQ__DiscountTier__c> lDiscTierOld_Delete     = new List<SBQQ__DiscountTier__c>();
        for(SBQQ__DiscountSchedule__c ds : lDiscountSchedule) {
            if(ds.POCH_UpdateTiers__c) {
                if(mapDisSch_lDiscTier.containskey(ds.Id)) {
                    List<SBQQ__DiscountTier__c> lTiers = new List<SBQQ__DiscountTier__c>();
                    for(SBQQ__DiscountTier__c dt : mapDisSch_lDiscTier.get(ds.Id)) {
                        if(dt.POCH_NoRegistroCondicion__c <> ds.POCH_NoRegCondicion__c)
                            lDiscTierOld_Delete.add(dt);
                        else lTiers.add(dt);
                    }
                    //Asigna upper bound de proxima lower bound
                    Integer index = 1;
                    for(SBQQ__DiscountTier__c dt : lTiers) {
                        if(index >= lTiers.size())
                            break;
                        else {
                            try {
                                dt.SBQQ__UpperBound__c = lTiers[index].SBQQ__LowerBound__c;
                                dt.POCH_ImporteUpper__c= lTiers[index].POCH_ImporteCondicion__c;
                                lDiscTierUpperBound_Upd.add(dt);
                            } catch(Exception e) { System.debug('--> ERROR: ' + e.getMessage()); }
                        }                        
                        index++;
                    }
                }                
            	ds.POCH_UpdateTiers__c = false;    
            }                        
        }
		
        POCH_DiscountTierTriggerService.isInvokedByTrigger = true;                            
        if(!lDiscTierUpperBound_Upd.isEmpty()) {
            try { 
                update lDiscTierUpperBound_Upd; 
            } catch(Exception e) { System.debug('--> ERROR: ' + e.getMessage()); }
        }
        if(!lDiscTierOld_Delete.isEmpty()) {
            try {
                delete lDiscTierOld_Delete;  
            } catch(Exception e) { System.debug('--> ERROR: ' + e.getMessage()); }
        }
                
        System.debug('::: OUT POCH_DiscountScheduleTriggerService.handleDiscountTiers');
    }

}