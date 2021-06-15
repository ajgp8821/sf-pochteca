/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Apex created records in Object Equipos_vendedores.
--- CreateDate: 13/04/2021 - JIRA RN-6426
--- UpdateDate: 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class CrearEquipoVendedoresTest {
    @isTest
    private static void findRecords(){     
        Test.startTest();
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal2();
        insert suc;
        
        Account acc = POCH_DataCreationTest.getAccountIdSAPCLiente();
        acc.POCH_Sucursal__c = suc.Id;
        acc.POCH_Region__c = reg.Id;  
        insert acc;
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        sam.POCH_Vendedor__c = userinfo.getuserid();
        insert sam;
        CrearEquipoVendedores crearEquipoVendedores = new CrearEquipoVendedores();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, crearEquipoVendedores); 
        CrearEquipoVendedores.execute(null);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'POCH-Gerente Ctas Claves'];
        Contact contact = POCH_DataCreationTest.getContact();
        contact.AccountId = acc.Id;
        insert contact;
        User usuario = POCH_DataCreationTest.getUser(); 
        usuario.ProfileId = p.Id;
        insert usuario;
        POCH_SucursalAmpliada__c sucAmplUpdate = [SELECT Id, POCH_Vendedor__c FROM POCH_SucursalAmpliada__c WHERE POCH_Vendedor__c =: userinfo.getuserid()];
        sucAmplUpdate.POCH_Vendedor__c = usuario.Id;
        update sucAmplUpdate;
        
        Equipo_Vendedores__c equipo = POCH_DataCreationTest.getEquipoVendedor();
        equipo.Sucursal__c = suc.Id; 
        equipo.Sucursal_Ampliada__c = sam.Id;
        equipo.Vendedor__c = usuario.Id;   
        equipo.Acceso_Cliente__c = 'Escritura';
        equipo.Rol__c = 'Vendedor Principal';
        //equipo.Acceso_Opportunity__c = 'Escritura';
        insert equipo;
        Equipo_Vendedores__c equipoUpd = [SELECT Id FROM Equipo_Vendedores__c WHERE Id =: equipo.Id];
        equipoUpd.Vendedor__c = userinfo.getuserid();
        equipoUpd.Acceso_Cliente__c = 'Lectura';
        update equipoUpd;
        
        Equipo_Vendedores__c equipoUpdRead = [SELECT Id FROM Equipo_Vendedores__c WHERE Id =: equipo.Id];
        equipoUpdRead.Vendedor__c = userinfo.getuserid();
        //equipoUpdRead.Acceso_Opportunity__c = 'Lectura';
        update equipoUpdRead;
        Equipo_Vendedores__c equipoDelete = [SELECT Id FROM Equipo_Vendedores__c WHERE Id =: equipo.Id];
        delete equipoDelete;
        Test.stopTest(); 
    }
}