/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Apex update records in Object Sucursal ampliada, Apext Test UpdateSucursalAmpliadaTest..
--- CreateDate: 13/04/2021 - JIRA RN-6426
--- UpdateDate: 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
global with sharing class UpdateSucursalAmpliada implements Schedulable{
    global void execute(SchedulableContext ctx) {
        UpdateSucursalAmpliadaBatch updateSucursal = new UpdateSucursalAmpliadaBatch();
        //Parameters of ExecuteBatch(context,BatchSize) 
        database.executebatch(updateSucursal,150); 
    }

}