global class deleteEquipoVendedor implements Database.Batchable<sObject>, Database.Stateful{
    public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'select Id from Equipo_Vendedores__c');
    }
    
    public void execute(Database.BatchableContext bc, List<Equipo_Vendedores__c> scope){
        List<Equipo_Vendedores__c> listEquipo = new List<Equipo_Vendedores__c>();
        List<POCH_SucursalAmpliada__c> listSucursal = new List<POCH_SucursalAmpliada__c>();
        for (Equipo_Vendedores__c equipo : scope) {
         	listEquipo.add(equipo);
        }
        
        // process each batch of records
        delete listEquipo;
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
        email.setHtmlBody('Funalizó el proceso batch ->  job, recordsProcessed' + job + recordsProcessed);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }
        //EmailUtils.sendMessage(job, recordsProcessed);
    }

}