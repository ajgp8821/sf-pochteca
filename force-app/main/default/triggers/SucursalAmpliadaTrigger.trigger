/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System 
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Trigger tu create record in Equipo vendedores, Apext Test CrearEquipoVendedoresTest
--- CreateDate: 14/04/2021 - JIRA RN-6426
--- UpdateDate: 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
trigger SucursalAmpliadaTrigger on POCH_SucursalAmpliada__c (after insert, after update, before update, before insert) {
   
    if (Trigger.isAfter){  
        if (Trigger.isInsert){
            SucursalAmpliadaHelper.insertEquipoVendedor(Trigger.New);
        } 
    } 
    if (Trigger.isBefore){  
        if (Trigger.isUpdate){
            SucursalAmpliadaHelper.updateVendedor(Trigger.New, Trigger.Old);
        } 
    } 
}