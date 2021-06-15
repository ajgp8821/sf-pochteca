@isTest
public class POCH_ActivityTriggerHandlerTest {
    
    @TestSetup static void createdDateWF() {
        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;
        
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        Account acc = POCH_DataCreationTest.getAccount();
        acc.POCH_TipoRegistro__c = 'Prospecto';
        acc.POCH_Region__c = reg.Id;
        insert acc;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal();
        suc.POCH_Sociedad__c = '400';
        insert suc;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        
        Lead ld = new Lead();
        ld.FirstName = 'FN';
        ld.LastName  = 'LN';
        ld.Company   = 'CM';
        insert ld;
    }
    
    class TestData {
        public Account 			acc {get;set;}
        public Poch_Sucursal__c suc {get;set;}
        public Lead				ldd {get;set;}
        
        public TestData() {
            this.acc = [SELECT Id FROM Account LIMIT 1];
            this.suc = [SELECT Id FROM Poch_Sucursal__c LIMIT 1];
            this.ldd = [SELECT Id FROM Lead LIMIT 1];
        }
    }

    public static testMethod void testTask_Acc() {
 		TestData td = new TestData();
        
        Task tsk    = new Task();
        tsk.Subject = 'TST';
        tsk.WhatId  = td.acc.Id;
        tsk.POCH_Sucursal__c = td.suc.Id;
        insert tsk;       
    }
    
    public static testMethod void testTask_Lead() {
 		TestData td = new TestData();
        
        Task tsk    = new Task();
        tsk.Subject = 'TST';
        tsk.WhoId   = td.ldd.Id;
        tsk.POCH_Sucursal__c = td.suc.Id;
        insert tsk;       
    }
    
	public static testMethod void testEvent_Acc() {
        TestData td = new TestData();
        
        Event evt = new Event();
        evt.Subject = 'TST';
        evt.WhatId  = td.acc.Id;
        evt.POCH_Sucursal__c  = td.suc.Id;
        evt.DurationInMinutes = 15;
        evt.ActivityDateTime  = System.now();
        insert evt;       
    }
    
    public static testMethod void testEvent_Lead() {
        TestData td = new TestData();
        
        Event evt = new Event();
        evt.Subject = 'TST';
        evt.WhoId   = td.ldd.Id;
        evt.POCH_Sucursal__c  = td.suc.Id;
        evt.DurationInMinutes = 15;
        evt.ActivityDateTime  = System.now();
        insert evt;       
    }
    
}