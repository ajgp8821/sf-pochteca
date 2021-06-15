/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga
--- Author: 
--- Update for: Jesús Azuaje
--- Description: 
--- CreateDate: 
--- UpdateDate: 16/03/2021 - JIRA RN-6503 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
public with sharing class UpdateMeterialOpp {

    @InvocableMethod
    public static void updateMaterialOpp(List<Id> inventarioId){
        POCH_HojaInventario__c hojaInventario = [SELECT Id, POCH_Cuenta__c FROM POCH_HojaInventario__c WHERE Id =: inventarioId[0]];
    }  
}