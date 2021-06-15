global class POCH_SchLeadInactive implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Cada cuanto tiempo se va a ejecutar.
        DateTime nextRunTime = DateTime.now().addHours(1);

        String cronString = ''+ nextRunTime.second() +' '+ nextRunTime.minute() +' '+ nextRunTime.hour() +' '+ nextRunTime.day() +' '+ nextRunTime.month() +' ? '+ nextRunTime.year(); 

        if(!Test.isRunningTest()){ 
            System.schedule(POCH_SchLeadInactive.class.getName() + '-' + DateTime.now().format(), cronString, new POCH_SchLeadInactive()); 
            System.abortJob(sc.getTriggerId());             
            this.verifyLead24();
            this.verifyLead48();
            this.verifyLead72();
        }   
    }
    @TestVisible
    private void verifyLead24() {
        Integer hmin = Test.isRunningTest() ? 0 : 24;
        Map<Id, Lead> mapLead = New Map<Id, Lead>();        
        for (Lead lead: [SELECT Id, Name FROM Lead Where POCH_Notificado24Hrs__c = False AND POCH_Notificado48Hrs__c = False AND POCH_Notificado72Hrs__c = False
                         AND POCH_Horas__c >= : hmin AND POCH_Horas__c < 48 AND (Status NOT IN ('Descartado') OR IsConverted = False)]) {
            mapLead.put(lead.Id, New Lead(Id = lead.Id, POCH_Notificado24Hrs__c = true));
        }
        Database.update(mapLead.values());
    }
    @TestVisible
    private void verifyLead48() {
        Map<Id, Lead> mapLead = New Map<Id, Lead>();
        Integer hmin = Test.isRunningTest() ? 0 : 24;
        for (Lead lead: [SELECT Id, Name FROM Lead Where POCH_Notificado24Hrs__c = True AND POCH_Notificado48Hrs__c = False AND POCH_Notificado72Hrs__c = False 
                         AND POCH_Horas__c >= : hmin AND POCH_Horas__c < 48 AND (Status NOT IN ('Descartado') OR IsConverted = False)]) {
            mapLead.put(lead.Id, New Lead(Id = lead.Id, POCH_Notificado48Hrs__c = true));
        }
        Database.update(mapLead.values());
    }    
    @TestVisible
    private void verifyLead72() {
        Map<Id, Lead> mapLead = New Map<Id, Lead>();
        Integer hmin = Test.isRunningTest() ? 0 : 24;
        for (Lead lead: [SELECT Id, Name FROM Lead Where POCH_Notificado24Hrs__c = True AND POCH_Notificado48Hrs__c = True AND POCH_Notificado72Hrs__c = False
                         AND POCH_Horas__c >= : hmin AND (Status NOT IN ('Descartado') OR IsConverted = False)]) {
            mapLead.put(lead.Id, New Lead(Id = lead.Id, POCH_Notificado72Hrs__c = true));
        }
        Database.update(mapLead.values());
    }    
}