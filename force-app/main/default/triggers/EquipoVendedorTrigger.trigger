/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System 
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Trigger tu grant access to Account or Opportunities, Apext Test CrearEquipoVendedoresTest
--- CreateDate: 16/04/2021 - JIRA RN-6426
--- UpdateDate: 04/05/2021 - JIRA RN-6725 - New method for update vendedor.
--- Version: 1.1
---------------------------------------------------------------------------------------------------------------*/
trigger EquipoVendedorTrigger on Equipo_Vendedores__c (before insert, before update, after insert, after update, before delete) {
    if (Trigger.isAfter){  
        if (Trigger.isInsert){
            EquipoVendedorHelper.evaluateAccess(Trigger.New);
        } 
        if (Trigger.isUpdate){
            EquipoVendedorHelper.updateEquipo(Trigger.New, Trigger.Old);
        }
    }
    if (Trigger.isBefore){ 
        if (Trigger.isInsert){
            EquipoVendedorHelper.getSucursal(Trigger.New);
        } 
        if (Trigger.isDelete){
            EquipoVendedorHelper.deleteAccess(Trigger.Old);
        }
    }
}