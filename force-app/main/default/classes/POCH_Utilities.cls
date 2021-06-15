/**
* ------------------------------------------------------------------------------------------------
* @Name     POCH_Utilities
* @Author   Mauricio Esquivel Cázares mesquivel@freewayconsulting.com
* @Date     Created: 2019-08-21
* @Group    POCH
* ------------------------------------------------------------------------------------------------
* 
*
* |2019-08-12 mesquivel@freewayconsulting.com
*             Class creation.
* -----------------------------------------------------------------------------------------------
*/
public with sharing class POCH_Utilities {

    //retrieve the custom fields from an object
    public static List<Object> getcustomFields(String objectType) {
        return [SELECT MasterLabel,PickListValues__c,Nombre_del_campo__c , Objeto__c ,Tipo_de_campo__c FROM Product_Setting__mdt Order by MasterLabel ASC];
    }
}