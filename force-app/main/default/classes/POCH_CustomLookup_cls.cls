/****************************************************************************************************
General Information
-------------------
author: Hector Diaz
email:
company: Freeway MX
Project:
Customer:
Description:  Lookup class for any object

Information about changes (versions)
-------------------------------------
Number    Dates             Author                       Description
------    --------          --------------------------   -----------
1.0       20-Junio-2019       Hector Diaz Hernandez          Creation Class
****************************************************************************************************/ 
public class POCH_CustomLookup_cls {
	 
    @AuraEnabled
	public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, String parentId) {        
		String searchKey = searchKeyWord + '%';
        List<sObject> returnList = new List <sObject>();
        String sQuery = ''; 
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        if(ObjectName == 'Pricebookentry') {     
            if(String.isNotBlank(parentId)) {
                sQuery = 'SELECT id,Name,UnitPrice,CurrencyIsoCode,Product2.Id,Product2.Name,Product2.ProductCode,PriceBook2Id,Pricebook2.Poch_Sucursal__c,Product2.onlyInSalesforce__c,POCH_UnidadMedida__c,Product2.QuantityUnitOfMeasure ' 
                    +  ' FROM '+ ObjectName 
                    +  ' WHERE (Name LIKE: searchKey OR Product2.ProductCode LIKE: searchKey) AND IsActive = TRUE ';            
                if(parentId != null && String.isNotBlank(parentId)) { sQuery +=  ' AND PriceBook2.POCH_Sucursal__c =: parentId '; }
                sQuery +=  ' ORDER BY createdDate DESC limit 3';
            }
        } else { 
            sQuery = 'SELECT POCH_Cliente__r.Name, Poch_Sucursal__r.Name , Poch_Sucursal__c, Name' 
                + ' FROM  ' + ObjectName 
                + ' WHERE Poch_Sucursal__r.Name LIKE: searchKey AND POCH_Cliente__c =: parentId ORDER BY createdDate DESC LIMIT 3';
        }
        if(String.isNotBlank(sQuery)) {
            List<sObject> lstOfRecords = Database.query(sQuery); 
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            
            if(ObjectName == 'Pricebookentry' && returnList.isEmpty()) {
                for(PricebookEntry pbe : [SELECT id,Name,UnitPrice,CurrencyIsoCode,Product2.Id,Product2.Name,Product2.ProductCode,PriceBook2Id,Pricebook2.Poch_Sucursal__c,Product2.onlyInSalesforce__c,POCH_UnidadMedida__c,Product2.QuantityUnitOfMeasure 
                                          FROM PricebookEntry WHERE Name LIKE: searchKey OR Product2.ProductCode LIKE: searchKey ORDER BY CreatedDate ASC LIMIT 1]) 
                {
                    pbe.UnitPrice = 0;  
                    returnList.add(pbe);
                }
            }
            
        }        
        return returnList;
    }
    
    
    @AuraEnabled
	public static List <sObject> fetchLookUpValuesFromVentasMostrador(String searchKeyWord, String ObjectName, String parentId, String organizacionVenta) {        
		String searchKey = searchKeyWord + '%';
        List<sObject> returnList = new List <sObject>();
        String sQuery = ''; 
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        if(ObjectName == 'Pricebookentry') {     
            if(String.isNotBlank(parentId)) {
                sQuery = 'SELECT id,Name,UnitPrice,CurrencyIsoCode,Product2.Id,Product2.Name,Product2.ProductCode,PriceBook2Id,Pricebook2.Poch_Sucursal__c,Product2.onlyInSalesforce__c,POCH_UnidadMedida__c,Product2.QuantityUnitOfMeasure ' 
                    +  ' FROM '+ ObjectName 
                    +  ' WHERE (Name LIKE: searchKey OR Product2.ProductCode LIKE: searchKey) AND IsActive = TRUE AND POCH_OrganizacionVentas__c =: organizacionVenta ';            
                if(parentId != null && String.isNotBlank(parentId)) { sQuery +=  ' AND PriceBook2.POCH_Sucursal__c =: parentId '; }
                sQuery +=  ' ORDER BY createdDate DESC limit 3';
            }
        } else { 
            sQuery = 'SELECT POCH_Cliente__r.Name, Poch_Sucursal__r.Name , Poch_Sucursal__c, Name' 
                + ' FROM  ' + ObjectName 
                + ' WHERE Poch_Sucursal__r.Name LIKE: searchKey AND POCH_Cliente__c =: parentId ORDER BY createdDate DESC LIMIT 3';
        }
        if(String.isNotBlank(sQuery)) {
            List<sObject> lstOfRecords = Database.query(sQuery); 
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            
            if(ObjectName == 'Pricebookentry' && returnList.isEmpty()) {
                for(PricebookEntry pbe : [SELECT id,Name,UnitPrice,CurrencyIsoCode,Product2.Id,Product2.Name,Product2.ProductCode,PriceBook2Id,Pricebook2.Poch_Sucursal__c,Product2.onlyInSalesforce__c,POCH_UnidadMedida__c,Product2.QuantityUnitOfMeasure 
                                          FROM PricebookEntry WHERE Name LIKE: searchKey OR Product2.ProductCode LIKE: searchKey ORDER BY CreatedDate ASC LIMIT 1]) 
                {
                    pbe.UnitPrice = 0;  
                    returnList.add(pbe);
                }
            }
            
        }        
        return returnList;
    }
}