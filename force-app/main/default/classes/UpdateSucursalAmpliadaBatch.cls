/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Apex created records in Object Equipos_vendedores, Apext Test UpdateSucursalAmpliadaTest..
--- CreateDate: 13/04/2021 - JIRA RN-6426
--- UpdateDate: 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
global class UpdateSucursalAmpliadaBatch implements Database.Batchable<sObject>, Database.Stateful {
	public Integer recordsProcessed = 0;
    Integer i = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Sucursal_Ampliada__c, Sucursal__c, Vendedor__c FROM Equipo_Vendedores__c WHERE Sucursal__c != NULL AND Sucursal_Ampliada__c != NULL AND Vendedor__c != NULL');
    }
    
    public void execute(Database.BatchableContext bc, List<Equipo_Vendedores__c> scope){
        List<POCH_SucursalAmpliada__c> listSucursal = new List<POCH_SucursalAmpliada__c>();
        for (Equipo_Vendedores__c equipo : scope) {
            for (POCH_SucursalAmpliada__c listAmpliada : [SELECT 
                                                            Id,
                                                            Equipo_Vendedor__c
                                                          FROM POCH_SucursalAmpliada__c 
                                                          WHERE Poch_Sucursal__c =: equipo.Sucursal__c
                                                            AND Id =: equipo.Sucursal_Ampliada__c 
                                                            AND POCH_Vendedor__c =: equipo.Vendedor__c
                                                            AND Equipo_Vendedor__c = NULL]){
            	i++;
            	listAmpliada.Equipo_Vendedor__c = equipo.Id;
            	listSucursal.add(listAmpliada);
			}
        }
        
        // process each batch of records
        update listSucursal;
        recordsProcessed = recordsProcessed + 1;

    }
    
    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        //Get email user
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        // call some utility to send email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] to = new string[] {userEmail};
        email.setToAddresses(to);       
        //email.setTemplateID(et.Id); 
        email.setSubject('Culmino proceso batch update suscursal ampliada');
        email.saveAsActivity = false;
        email.setHtmlBody('Funalizó el proceso batch ->  job, recordsProcessed' + job + recordsProcessed + ' total I -> ' + i);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }
        //EmailUtils.sendMessage(job, recordsProcessed);
    }
}