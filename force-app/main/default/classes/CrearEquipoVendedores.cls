/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Apex created records in Object Equipos_vendedores, Apext Test CrearEquipoVendedoresTest.
--- CreateDate: 13/04/2021 - JIRA RN-6426
--- UpdateDate: 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
global with sharing class CrearEquipoVendedores implements Schedulable{
    global void execute(SchedulableContext ctx) {
        CrearEquipoVendedoresBatch crearEquipoVendedores = new CrearEquipoVendedoresBatch();
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(crearEquipoVendedores,150);
    }
}