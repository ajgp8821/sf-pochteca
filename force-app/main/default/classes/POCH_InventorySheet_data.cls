/**
* ------------------------------------------------------------------------------------------------
* @Name     POCH_InventorySheet_helper
* @Author   Mauricio Esquivel Cázares mesquivel@freewayconsulting.com
* @Date     Created: 2019-08-12
* @Group    POCH
* ------------------------------------------------------------------------------------------------
* @Controller:POCH_InventorySheet_cls
* @Helper class:POCH_InventorySheet_helper
* |2019-08-12 mesquivel@freewayconsulting.com
*             Class creation.
* -----------------------------------------------------------------------------------------------
*/
public with sharing class POCH_InventorySheet_data {

    /**
    * --------------------------------------------------------------------------------------
    * @Description returns an Opportunity . mehotd to clarify controller code.
    * --------------------------------------------------------------------------------------
    * @param id of an account related to opp
    * @return a List<Opportunity> 
    * @author: mesquivel@freewayconsulting.com -Esquivel Cázares Mauricio
    * --------------------------------------------------------------------------------------
    **/
    public static List<Opportunity> retrieveOpportunityData(string accId) {
        return [Select Id,Name FROM Opportunity where AccountId =: accId AND Account.POCH_TipoRegistro__c != 'Cliente'];
    }
    /**
    * --------------------------------------------------------------------------------------
    * @Description returns standard priceBook
    * --------------------------------------------------------------------------------------
    * @param void
    * @return standardPriceBook 
    * @author: mesquivel@freewayconsulting.com -Esquivel Cázares Mauricio
    * --------------------------------------------------------------------------------------
    **/
    public static Id retrievePriceBook(String idSuc) {
        return [Select Id FROM PriceBook2 where POCH_Sucursal__c =: idSuc AND IsActive = true LIMIT 1].Id;
    }
}