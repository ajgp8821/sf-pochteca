/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Apex Send Email - Jira RN-6523
--- CreateDate: 29/03/2021 - 
--- UpdateDate:  - 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
public with sharing class EnviarNotification {
    @InvocableMethod
    public static void enviarNotification(List<Id> caseId){
        String idioma, userName, name, templateHtmlBody, subject, userMail, profileId;
        EmailTemplate etc= [SELECT Id, DeveloperName , HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'notificar_Incidencia_cerrada'];
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
        if (caseAux.Status == 'Cerrado'){
            templateHtmlBody = etc.HtmlValue;
            templateHtmlBody = templateHtmlBody.replace('{!Case.Id}', caseAux.Id + '/view');
            templateHtmlBody = templateHtmlBody.replace('{!Case.CaseNumber}', caseAux.CaseNumber);
            String[] to = new string[] {caseAux.Owner.Email,caseAux.CreatedBy.Email};
            if(caseAux.POCH_SucursalAmpliada__r.POCH_Vendedor__r.Email != null){
                if (caseAux.Owner.Email == caseAux.CreatedBy.Email){
                 	to[1] = caseAux.POCH_SucursalAmpliada__r.POCH_Vendedor__r.Email;   
                }else{
                 	to[2] = caseAux.POCH_SucursalAmpliada__r.POCH_Vendedor__r.Email;   
                }
                
            }
            email.setToAddresses(to);
            email.setTemplateID(etc.Id); 
            subject = etc.Subject;
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
}