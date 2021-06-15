/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga
--- Author: Jesús Azuaje 
--- Update for: 
--- Description: Se ajusta metodo accountRecord para realizar busqueda en el object Opportunity y verificar si existen registros
--- CreateDate: 16/03/2021 - JIRA RN-6687
--- UpdateDate:  
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
public with sharing class HojaInventarioHelper {
    
    public static void findOpportunityRelated(List<POCH_HojaInventario__c> invRecList, Map<Id,POCH_HojaInventario__c> mapOldInv){
        Id accountId, sucursalId;        
        for(POCH_HojaInventario__c invRec : invRecList){
            accountId = invRec.POCH_Cuenta__c;
			sucursalId = invRec.POCH_Sucursal__c;            
        }

        for(Opportunity spancop : [SELECT 
                                   	Id,
                                   	POCH_MaterialHojaInventario__c 
                                   FROM Opportunity
                                   WHERE AccountId =: accountId 
                                   AND POCH_Sucursal__c =: sucursalId 
                                   AND (StageName = 'Sospechoso' OR StageName = 'Prospecto')]){
            spancop.POCH_MaterialHojaInventario__c = true;
            update spancop;
        }        
    }
}