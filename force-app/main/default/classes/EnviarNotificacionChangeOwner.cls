/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Apex Send Email - Jira RN-6523
--- CreateDate: 29/03/2021 - 
--- UpdateDate:  - 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
public class EnviarNotificacionChangeOwner {
    @InvocableMethod
    public static void enviarNotification(List<Id> caseId){
        String idioma, userName, name, templateHtmlBody, subject, userMail, profileId;
        EmailTemplate et= [SELECT Id, DeveloperName , HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'notificar_Incidencia_creada'];
        Case caseAux = [SELECT
                        	Id,
                        	Type,
                        	Motivo__c,
                        	POCH_Submotivo__c,
                        	Owner.Email,
                        	CaseNumber,
                        	Status,
                        	POCH_SucursalAmpliada__r.POCH_Vendedor__r.Email,
                        	CreatedBy.Email
                        FROM Case
                        WHERE Id =: caseId[0]];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        templateHtmlBody = et.HtmlValue;
        templateHtmlBody = templateHtmlBody.replace('{!Case.Id}', caseAux.Id + '/view');
        if (caseAux.Type != null){
        	templateHtmlBody = templateHtmlBody.replace('{!Case.Type}', caseAux.Type);    
        }else{
            templateHtmlBody = templateHtmlBody.replace('{!Case.Type}', '');
        }
        if (caseAux.Motivo__c != null){
         	templateHtmlBody = templateHtmlBody.replace('{!Case.Motivo__c}', caseAux.Motivo__c);   
        }else{
        	templateHtmlBody = templateHtmlBody.replace('{!Case.Motivo__c}', '');    
        }
        if (caseAux.POCH_Submotivo__c != null){
         	templateHtmlBody = templateHtmlBody.replace('{!Case.POCH_Submotivo__c}', caseAux.POCH_Submotivo__c);   
        }else{
        	templateHtmlBody = templateHtmlBody.replace('{!Case.POCH_Submotivo__c}', '');    
        }
        templateHtmlBody = templateHtmlBody.replace('{!Case.CaseNumber}', caseAux.CaseNumber);
        String[] to = new string[] {caseAux.Owner.Email};
            email.setToAddresses(to);
        email.setTemplateID(et.Id); 
        subject = et.Subject;
        subject = subject.replace('{!Case.CaseNumber}', caseAux.CaseNumber);
        email.setSubject(subject);
        email.saveAsActivity = false;
        email.setHtmlBody(templateHtmlBody);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }
    }

}