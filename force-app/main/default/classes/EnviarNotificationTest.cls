/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Apex Send Email Test - Jira RN-6523
--- CreateDate: 29/03/2021 - 
--- UpdateDate:  - 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class EnviarNotificationTest {
    @isTest
    private static void ProcessEmailOk() {        
        Test.startTest();  
        Case caseAux = POCH_DataCreationTest.getCase();
        insert caseAux;
        List<Id> ids = new List<Id>();
        List<Id> ids2 = new List<Id>();
        ids.add(caseAux.Id);
        
        Case caseClose = [SELECT Id, Status, OwnerId FROM Case WHERE Id =: caseAux.Id];
        caseClose.Status = 'Cerrado';
        caseClose.OwnerId = UserInfo.getUserId();
        update caseClose;
        ids2.add(caseClose.Id);
        EnviarNotification.enviarNotification(ids);
        EnviarNotificacionChangeOwner.enviarNotification(ids2);
        Test.stopTest();
            
    }
}