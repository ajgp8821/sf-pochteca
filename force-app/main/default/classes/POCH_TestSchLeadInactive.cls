@Istest
public class POCH_TestSchLeadInactive {
    
    public static testMethod void testSchLeadInactive() {
        Lead ld = new Lead();
        ld.FirstName = 'FN';
        ld.LastName  = 'LN';
        ld.Company   = 'CM';
        ld.POCH_Notificado24Hrs__c = false;
        ld.POCH_Notificado48Hrs__c = false;
        ld.POCH_Notificado72Hrs__c = false;
        insert ld;
        
        Test.startTest();
            DateTime nextRunTime = DateTime.now().addHours(1);
            String cronString    = nextRunTime.second() +' '+ nextRunTime.minute() +' '+ nextRunTime.hour() +' '+ nextRunTime.day() +' '+ nextRunTime.month() +' ? '+ nextRunTime.year(); 
    
            POCH_SchLeadInactive sli = new POCH_SchLeadInactive();
            System.schedule(POCH_SchLeadInactive.class.getName() + '-' + DateTime.now().format(), cronString, sli);
            
            sli.verifyLead24();
            
            ld.POCH_Notificado24Hrs__c = true;
            update ld;
            sli.verifyLead48();
            
            ld.POCH_Notificado48Hrs__c = true;
            update ld;
            sli.verifyLead72();        
        Test.stopTest();
    }

}