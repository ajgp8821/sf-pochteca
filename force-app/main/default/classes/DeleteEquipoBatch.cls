global with sharing class DeleteEquipoBatch implements Schedulable{
    global void execute(SchedulableContext ctx) {
        deleteEquipoVendedor updateSucursal = new deleteEquipoVendedor();
        //Parameters of ExecuteBatch(context,BatchSize) 
        database.executebatch(updateSucursal,150); 
    }

}