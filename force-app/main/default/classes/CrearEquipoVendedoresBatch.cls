/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Apex created records in Object Equipos_vendedores, Apext Test CrearEquipoVendedoresTest.
--- CreateDate: 13/04/2021 - JIRA RN-6426
--- UpdateDate: 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
global class CrearEquipoVendedoresBatch implements Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    Integer i = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Equipo_Vendedor__c, POCH_Vendedor__c, CurrencyIsoCode, POCH_Cliente__c, Poch_Sucursal__c FROM POCH_SucursalAmpliada__c WHERE Equipo_Vendedor__c = NULL AND POCH_Vendedor__c != NULL AND Poch_Sucursal__c != NULL');
    }
    public void execute(Database.BatchableContext bc, List<POCH_SucursalAmpliada__c> scope){
        // process each batch of records
        
        List<AccountShare> accountShare = new List<AccountShare>();
		List<Equipo_Vendedores__c> listEquipoV = new List<Equipo_Vendedores__c>();
        for (POCH_SucursalAmpliada__c auxSucursal : scope) {
            i++;
			Equipo_Vendedores__c equipoTem = new Equipo_Vendedores__c();
            equipoTem.Sucursal__c = auxSucursal.Poch_Sucursal__c  ; 
            equipoTem.Sucursal_Ampliada__c = auxSucursal.Id;
            equipoTem.Vendedor__c = auxSucursal.POCH_Vendedor__c;   
            equipoTem.Acceso_Cliente__c = 'Escritura';
            equipoTem.CurrencyIsoCode = auxSucursal.CurrencyIsoCode;
            equipoTem.Rol__c = 'Vendedor Principal';
            //equipoTem.Acceso_Opportunity__c = 'Escritura';
            listEquipoV.add(equipoTem);
            AccountShare accountShareTemp = new AccountShare();
            accountShareTemp.AccountId = auxSucursal.POCH_Cliente__c;
            accountShareTemp.UserOrGroupId = auxSucursal.POCH_Vendedor__c;
            accountShareTemp.AccountAccessLevel = 'Edit';
            accountShareTemp.OpportunityAccessLevel = 'Edit';
            accountShare.add(accountShareTemp);
            
            // increment the instance member counter
            recordsProcessed = recordsProcessed + 1;

        }
        insert listEquipoV;
        try{
            insert accountShare;
            System.debug('--- print otorgo permisos -> ');
        }catch(Exception e){
            System.debug('--- print error al otorgar permisos -> ' + e);
        }
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
        email.setHtmlBody('Funalizó el proceso batch ->  job, recordsProcessed' + job + recordsProcessed + 'total --> i ' + i);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }
        //EmailUtils.sendMessage(job, recordsProcessed);
    }
}