/***************************************************************************************************************
Name:        POCH_Product2TriggerService.apxc
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 27-09-2019
Project:	 Pochteca

Description: Product2 Trigger Service Class
***************************************************************************************************************/

public class POCH_Product2TriggerService {
    
    public static void upsertProductStandardPricebook(List<Product2> lProductos) {
        System.debug('::: IN POCH_Product2TriggerService.upsertProductStandardPricebook : lProductos ' + lProductos);
        
        Set<Id> setIdProd = new set<Id>();
        for(Product2 prd : lProductos)
            setIdProd.add(prd.Id);
        
        Map<Id,Set<String>> mapProd_setCurrency = new Map<Id,Set<String>>();
        for(PricebookEntry pbe : [SELECT CurrencyIsoCode,Product2Id FROM PricebookEntry WHERE Product2Id IN : setIdProd AND PriceBook2.IsStandard = TRUE]) {
            if(mapProd_setCurrency.containsKey(pbe.Product2Id))
               mapProd_setCurrency.get(pbe.Product2Id).add(pbe.CurrencyIsoCode);
            else mapProd_setCurrency.put(pbe.Product2Id, new Set<String>{pbe.CurrencyIsoCode}); 
        }
        
        Id idStandardPricebook = getIdStdPricebook();
        
        List<PricebookEntry> lPBEStd = new List<PricebookEntry>();
        for(Product2 producto : lProductos) {                        
            for(String moneda : getCurrencies()) {
                Boolean isNewPBE = true;                
                if(mapProd_setCurrency.containsKey(producto.Id)) {
                    if(mapProd_setCurrency.get(producto.Id).contains(producto.CurrencyIsoCode)) 
                    	isNewPBE = false;                        
                }
                if(isNewPBE) {
                    PricebookEntry pbe 	  = new PricebookEntry();
                    pbe.Product2Id   	  = producto.Id;
                    pbe.Pricebook2Id 	  = idStandardPricebook;
                    pbe.IsActive     	  = true;
                    pbe.UnitPrice    	  = 0;
                    pbe.CurrencyIsoCode	  = moneda;
                    pbe.POCH_IdExterno__c = String.valueOf(producto.Id) + 'STD' + moneda;
                    lPBEStd.add(pbe);     
                }                   
            }            
        }
        
        if(!lPBEStd.isEmpty()) {
            try {
                upsert lPBEStd POCH_IdExterno__c;
            } catch(DMLException e) { System.debug('--> ERROR: ' + e.getMessage()); }
        }

        System.debug('::: OUT POCH_Product2TriggerService.upsertProductStandardPricebook');
    }
    
    public static List<String> getCurrencies() {
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = PricebookEntry.CurrencyIsoCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple)
            pickListValuesList.add(pickListVal.getValue());        
        return pickListValuesList;
    }
    
    public static Id getIdStdPricebook() {
        if(!Test.isRunningTest())
            return [SELECT Id FROM Pricebook2 WHERE IsStandard = true limit 1].Id;
        else return Test.getStandardPricebookId();
    }

}