/***************************************************************************************************************
Name:        POCH_QuoteLineWFRequest.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 10-09-2019
Project:	 Pochteca

Description: Quote Line WF Request Class
***************************************************************************************************************/

public class POCH_QuoteLineWFRequest {
    
    //::::::::::::::::::::::::::::::::::::: METODO PARA ENVIAR A APROBACION LAS QUOTE LINES :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    public static void submitWFApprovalRequest(List<SBQQ__QuoteLine__c> lQuoteLinesWF) {
        System.debug('::: IN POCH_QuoteLineWFRequest.submitWFApprovalRequest --> lQuoteLinesWF : ' + lQuoteLinesWF);
        
       
      for(SBQQ__QuoteLine__c qlWF : lQuoteLinesWF) {
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setProcessDefinitionNameOrId(qlWF.POCH_WF__c);
            req.setComments(qlWF.POCH_WFComentarios__c);
            req.setObjectId(qlWF.Id);
            requests.add(req);                                
            List<Approval.ProcessResult> results = Approval.process(requests);
        }               
        //sendWFEmailApprovers(lQuoteLinesWF);
        
        System.debug('::: OUT POCH_QuoteLineWFRequest.submitWFApprovalRequest');
    }
    /*
private static void sendWFEmailApprovers(List<SBQQ__QuoteLine__c> lQuoteLinesWF) {
System.debug('::: IN POCH_QuoteLineWFRequest.sendWFEmailApprovers --> lQuoteLinesWF : ' + lQuoteLinesWF);

EmailTemplate template1 = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Name = 'POCH_WFNotificacion'];
EmailTemplate template2 = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Name = 'POCH_WFReNotificacion'];
List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

set<Id> setIdApprovers = new set<Id>();  
Map<Id,Map<String,String>> mapAccQuote = new Map<Id,Map<String,String>>();
Map<Id,String> mapAprob = new Map<Id,String>();
for(SBQQ__QuoteLine__c ql : lQuoteLinesWF) {
System.debug('--> ' + ql.POCH_WFAprobador1__c);
System.debug('--> ' + ql.POCH_WFAprobador2__c);
System.debug('--> ' + ql.POCH_WFAprobador3__c);
System.debug('--> ' + ql.POCH_WFAprobador4__c);
System.debug('--> ' + ql.POCH_WFAprobador5__c);
System.debug('--> ' + ql.POCH_ReenviarAutorizacion__c);
if(String.isNotBlank(ql.POCH_WFAprobador1__c)) {
if(ql.POCH_ReenviarAutorizacion__c) {
System.debug('--> entra como reenviar aut');
allmsg.add(getEmail(ql, template2, ql.POCH_WFAprobador1Name__c, ql.POCH_WFAprobador1__c));    
} else {
System.debug('--> entra por primera vez');
if(mapAccQuote.containsKey(ql.POCH_WFAprobador1__c)) {
System.debug('--> contiene llave apr1');
if(!mapAccQuote.get(ql.POCH_WFAprobador1__c).containsKey(ql.POCH_SucursalQuoteName__c)) {
System.debug('--> no contiene llave org ventas, agrega mapa');
mapAccQuote.get(ql.POCH_WFAprobador1__c).put(ql.POCH_SucursalQuoteName__c, ql.POCH_AccountNameQuote__c);
}
} else { 
System.debug('--> no contiene llave apr1, agrega mapa');
mapAccQuote.put(ql.POCH_WFAprobador1__c, new Map<String,String>{ql.POCH_SucursalQuoteName__c => ql.POCH_AccountNameQuote__c});
}

if(!mapAprob.containsKey(ql.POCH_WFAprobador1__c))   
mapAprob.put(ql.POCH_WFAprobador1__c, ql.POCH_WFAprobador1Name__c);

System.debug('--> mapAccQuote ' + mapAccQuote);
System.debug('--> mapAprob ' + mapAprob);
} 
}
if(String.isNotBlank(ql.POCH_WFAprobador2__c)) {
if(ql.POCH_ReenviarAutorizacion__c) {
allmsg.add(getEmail(ql, template2, ql.POCH_WFAprobador2Name__c, ql.POCH_WFAprobador2__c));    
} else {
if(mapAccQuote.containsKey(ql.POCH_WFAprobador2__c))
if(!mapAccQuote.get(ql.POCH_WFAprobador2__c).containsKey(ql.POCH_SucursalQuoteName__c))
mapAccQuote.get(ql.POCH_WFAprobador2__c).put(ql.POCH_SucursalQuoteName__c, ql.POCH_AccountNameQuote__c);
else mapAccQuote.put(ql.POCH_WFAprobador2__c, new Map<String,String>{ql.POCH_SucursalQuoteName__c => ql.POCH_AccountNameQuote__c});

if(!mapAprob.containsKey(ql.POCH_WFAprobador2__c))   
mapAprob.put(ql.POCH_WFAprobador2__c, ql.POCH_WFAprobador1Name__c);

System.debug('--> mapAccQuote ' + mapAccQuote);
} 
}
if(String.isNotBlank(ql.POCH_WFAprobador3__c)) {
if(ql.POCH_ReenviarAutorizacion__c) {
allmsg.add(getEmail(ql, template2, ql.POCH_WFAprobador1Name__c, ql.POCH_WFAprobador3__c));    
} else {
if(mapAccQuote.containsKey(ql.POCH_WFAprobador3__c))
if(!mapAccQuote.get(ql.POCH_WFAprobador3__c).containsKey(ql.POCH_SucursalQuoteName__c))
mapAccQuote.get(ql.POCH_WFAprobador3__c).put(ql.POCH_SucursalQuoteName__c, ql.POCH_AccountNameQuote__c);
else mapAccQuote.put(ql.POCH_WFAprobador3__c, new Map<String,String>{ql.POCH_SucursalQuoteName__c => ql.POCH_AccountNameQuote__c});

if(!mapAprob.containsKey(ql.POCH_WFAprobador3__c))   
mapAprob.put(ql.POCH_WFAprobador3__c, ql.POCH_WFAprobador1Name__c);

System.debug('--> mapAccQuote ' + mapAccQuote);
} 
}
if(String.isNotBlank(ql.POCH_WFAprobador4__c)) {
if(ql.POCH_ReenviarAutorizacion__c) {
allmsg.add(getEmail(ql, template2, ql.POCH_WFAprobador1Name__c, ql.POCH_WFAprobador4__c));    
} else {
if(mapAccQuote.containsKey(ql.POCH_WFAprobador4__c))
if(!mapAccQuote.get(ql.POCH_WFAprobador4__c).containsKey(ql.POCH_SucursalQuoteName__c))
mapAccQuote.get(ql.POCH_WFAprobador4__c).put(ql.POCH_SucursalQuoteName__c, ql.POCH_AccountNameQuote__c);
else mapAccQuote.put(ql.POCH_WFAprobador4__c, new Map<String,String>{ql.POCH_SucursalQuoteName__c => ql.POCH_AccountNameQuote__c});

if(!mapAprob.containsKey(ql.POCH_WFAprobador4__c))   
mapAprob.put(ql.POCH_WFAprobador4__c, ql.POCH_WFAprobador1Name__c);

System.debug('--> mapAccQuote ' + mapAccQuote);
} 
}
if(String.isNotBlank(ql.POCH_WFAprobador5__c)) {
if(ql.POCH_ReenviarAutorizacion__c) {
allmsg.add(getEmail(ql, template2, ql.POCH_WFAprobador1Name__c, ql.POCH_WFAprobador5__c));    
} else {
if(mapAccQuote.containsKey(ql.POCH_WFAprobador5__c))
if(!mapAccQuote.get(ql.POCH_WFAprobador5__c).containsKey(ql.POCH_SucursalQuoteName__c))
mapAccQuote.get(ql.POCH_WFAprobador5__c).put(ql.POCH_SucursalQuoteName__c, ql.POCH_AccountNameQuote__c);
else mapAccQuote.put(ql.POCH_WFAprobador5__c, new Map<String,String>{ql.POCH_SucursalQuoteName__c => ql.POCH_AccountNameQuote__c});

if(!mapAprob.containsKey(ql.POCH_WFAprobador5__c))   
mapAprob.put(ql.POCH_WFAprobador5__c, ql.POCH_WFAprobador1Name__c);

System.debug('--> mapAccQuote ' + mapAccQuote);
} 
}                      
}        
System.debug('--> mapAccQuote ' + mapAccQuote);

for(String aprId : mapAccQuote.keySet()) {
for(String orgVts : mapAccQuote.get(aprId).keySet())
allmsg.add(getEmail(template1, mapAccQuote.get(aprId).get(orgVts), orgVts, mapAprob.get(aprId), aprId));            
}
if(!allmsg.isEmpty())
Messaging.sendEmail(allmsg, false);

System.debug('::: OUT POCH_QuoteLineWFRequest.sendWFEmailApprovers');
}

private static Messaging.SingleEmailMessage getEmail(SBQQ__QuoteLine__c ql, EmailTemplate template, String aprobadorName, String aprobadorId) {
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                

String htmlBody = template.HtmlValue;        
htmlBody = htmlBody.replace('{!Aprobador}', String.isBlank(aprobadorName) ? '' : aprobadorName);
htmlBody = htmlBody.replace('{!Cliente}'  , ql.POCH_AccountNameQuote__c);
htmlBody = htmlBody.replace('{!Orgventas}', ql.POCH_SucursalQuoteName__c);
htmlBody = htmlBody.replace('{!Link}'     , URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/ProcessInstanceWorkitem/list?filterName=00B4P000007TUZBUA4');
htmlBody = htmlBody.replace('{!Material}', ql.SBQQ__ProductName__c);
htmlBody = htmlBody.replace('{!Precio}'  , String.valueOf(ql.SBQQ__CustomerPrice__c));
htmlBody = htmlBody.replace('{!Cantidad}', String.valueOf(ql.SBQQ__Quantity__c));
htmlBody = htmlBody.replace('{!Unidad}'  , ql.POCH_UnidadMedidaVenta__c);
htmlBody = htmlBody.replace('{!Margen}'  , String.valueOf(ql.POCH_MargenUtilidad__c));

String plainBody = template.Body;
plainBody = plainBody.replace('{!Aprobador}', String.isBlank(aprobadorName) ? '' : aprobadorName);
plainBody = plainBody.replace('{!Cliente}'  , ql.POCH_AccountNameQuote__c);
plainBody = plainBody.replace('{!Orgventas}', ql.POCH_SucursalQuoteName__c);
plainBody = plainBody.replace('{!Link}'     , URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/ProcessInstanceWorkitem/list?filterName=00B4P000007TUZBUA4');
plainBody = plainBody.replace('{!Material}', ql.SBQQ__ProductName__c);
plainBody = plainBody.replace('{!Precio}'  , String.valueOf(ql.SBQQ__CustomerPrice__c));
plainBody = plainBody.replace('{!Cantidad}', String.valueOf(ql.SBQQ__Quantity__c));
plainBody = plainBody.replace('{!Unidad}'  , ql.POCH_UnidadMedidaVenta__c);
plainBody = plainBody.replace('{!Margen}'  , String.valueOf(ql.POCH_MargenUtilidad__c));

mail.setTargetObjectId(aprobadorId);
mail.setSaveAsActivity(false);        
mail.setSubject(template.Subject);
mail.setHtmlBody(htmlBody);
mail.setPlainTextBody(plainBody);        

return mail;
}

private static Messaging.SingleEmailMessage getEmail(EmailTemplate template, String acc, String orgVts, String aprobadorName, String aprobadorId) {
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                

String htmlBody = template.HtmlValue;        
htmlBody = htmlBody.replace('{!Aprobador}', String.isBlank(aprobadorName) ? '' : aprobadorName);
htmlBody = htmlBody.replace('{!Cliente}'  , String.isBlank(acc) ? '' : acc);
htmlBody = htmlBody.replace('{!Orgventas}', String.isBlank(orgVts) ? '' : orgVts);
htmlBody = htmlBody.replace('{!Link}'     , URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/ProcessInstanceWorkitem/list?filterName=00B4P000007TUZBUA4');

String plainBody = template.Body;
plainBody = plainBody.replace('{!Aprobador}', String.isBlank(aprobadorName) ? '' : aprobadorName);
plainBody = plainBody.replace('{!Cliente}'  , String.isBlank(acc) ? '' : acc);
plainBody = plainBody.replace('{!Orgventas}', String.isBlank(orgVts) ? '' : orgVts);
plainBody = plainBody.replace('{!Link}'     , URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/ProcessInstanceWorkitem/list?filterName=00B4P000007TUZBUA4');

mail.setTargetObjectId(aprobadorId);
mail.setSaveAsActivity(false);        
mail.setSubject(template.Subject);
mail.setHtmlBody(htmlBody);
mail.setPlainTextBody(plainBody);        

return mail;
}
*/
}