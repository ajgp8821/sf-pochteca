/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System 
--- Author: Jesús Azuaje
--- Update for: Jesús Azuaje
--- Description: helper Trigger tu created record in Equipo_Vendedores, Apext Test CrearEquipoVendedoresTest
--- CreateDate: 15/04/2021 - JIRA RN-6426
--- UpdateDate: 17/05/2021 - JIRA CAM-2085 - find and grant access to inventary.
--- Version: 1.2
---------------------------------------------------------------------------------------------------------------*/
public class SucursalAmpliadaHelper {
    public class AuraHandledException extends exception {
        
    }
    /*this method received object User and update privacy*/
    public static void insertEquipoVendedor(List<POCH_SucursalAmpliada__c> listSucursalAmp) {
        Boolean existVendedor = false;
        Id accountId, sucursalId, vendedorId;
        try {
            for (POCH_SucursalAmpliada__c input: listSucursalAmp){
                if(input.POCH_Vendedor__c != null){
                    existVendedor = true;
                 	Equipo_Vendedores__c equipo = new Equipo_Vendedores__c();
                    equipo.Sucursal__c = input.Poch_Sucursal__c;
                    sucursalId = input.Poch_Sucursal__c;
                    equipo.Sucursal_Ampliada__c = input.Id;
                    equipo.Vendedor__c = input.POCH_Vendedor__c;
                    equipo.Acceso_Cliente__c = 'Escritura';
                    equipo.Rol__c = 'Vendedor Principal';
                    //equipo.Acceso_Opportunity__c = 'Escritura';
                    equipo.CurrencyIsoCode = input.CurrencyIsoCode;
                    insert equipo;
                    AccountShare accountShare = new AccountShare();
                    accountShare.AccountId = input.POCH_Cliente__c;
                    accountId = input.POCH_Cliente__c;
                    accountShare.UserOrGroupId = input.POCH_Vendedor__c;
                    vendedorId = input.POCH_Vendedor__c;
                    accountShare.AccountAccessLevel = 'Edit';
                    accountShare.OpportunityAccessLevel = 'Edit';
                    try{
                        insert accountShare;
                    }catch(Exception e){
                        System.debug('error al otorgar permisos -> ' + e);
                    }
                }   
            }
            if (existVendedor){
                List<POCH_HojaInventario__c> listHojaInventario = [SELECT 
                                                                        Id, 
                                                                        POCH_Cuenta__c
                                                                    FROM POCH_HojaInventario__c 
                                                                    WHERE POCH_Cuenta__c =: accountId 
                                                                    AND POCH_Sucursal__c =: sucursalId];
                if (listHojaInventario.size() > 0){
                    for (POCH_HojaInventario__c auxInventario : listHojaInventario) {
                        POCH_HojaInventario__Share inventarioTemp = new POCH_HojaInventario__Share();
                        inventarioTemp.ParentId = auxInventario.Id;
                        inventarioTemp.UserOrGroupId = vendedorId;
                        inventarioTemp.AccessLevel = 'Edit';
                        inventarioTemp.RowCause = Schema.POCH_HojaInventario__Share.RowCause.Manual;
                        Database.SaveResult sr = Database.insert(inventarioTemp,false);
                        if (sr.isSuccess()){
                            System.debug('exito shared Iventario');
                        }
                        else {
                            // Get first save result error.
                            Database.Error err = sr.getErrors()[0];
                        }
                        for (POCH_DetalleInventario__c listDetalle : [SELECT
                                                                            Id 
                                                                        FROM POCH_DetalleInventario__c 
                                                                        WHERE POCH_HojaInventario__c =: auxInventario.Id 
                                                                        AND POCH_Sucursal__c =: sucursalId]){
                            POCH_DetalleInventario__Share inventarioDetShareTemp = new POCH_DetalleInventario__Share();
                            inventarioDetShareTemp.ParentId = listDetalle.Id;
                            inventarioDetShareTemp.UserOrGroupId = vendedorId;
                            inventarioDetShareTemp.AccessLevel = 'Edit';
                            inventarioDetShareTemp.RowCause = Schema.POCH_HojaInventario__Share.RowCause.Manual;
                            Database.SaveResult srd = Database.insert(inventarioDetShareTemp,false);
                            if (sr.isSuccess()){
                                // Indicates success
                                System.debug('exito');
                            }else{
                                // Get first save result error.
                                Database.Error err = sr.getErrors()[0];
                            }
                        }
                    }
                }
            }
        }catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            String msg = 'Ocurrio un error al ejecutar insert de equipo de vendedores: '+ e.getMessage();
            throw new AuraHandledException('Ocurrio un error al ejecutar insert de equipo de vendedores: '
                                           + e.getMessage());    
        }
    }
    
    /*this method received object User and update privacy*/
    public static void updateVendedor(List<POCH_SucursalAmpliada__c> listSucursalAmp, List<POCH_SucursalAmpliada__c> listSucursalAmpOld) {
        try {
            List<AccountShare> listAccountShareAll = new List<AccountShare>();
            String moneda = '';
            Id propietarioOld,vendedorOld, vendedorNew, accountOld, accountNew, sucursalId, sucursalIdNew, sucursalAmpId, sucursalAmpIdNew;
            List<POCH_SucursalAmpliada__c> listaSucursal = new List<POCH_SucursalAmpliada__c>(); 
            List<Equipo_Vendedores__c> listEquipoV = new List<Equipo_Vendedores__c>();
            List<Equipo_Vendedores__c> listEquipoNew = new List<Equipo_Vendedores__c>();
            for (POCH_SucursalAmpliada__c inputOld: listSucursalAmpOld){
                vendedorOld = inputOld.POCH_Vendedor__c;
                accountOld = inputOld.POCH_Cliente__c;
                sucursalId = inputOld.Poch_Sucursal__c;
                sucursalAmpId = inputOld.Id;
            }
            for (POCH_SucursalAmpliada__c input: listSucursalAmp){
                if(input.POCH_Vendedor__c != null){
                    if (!string.isBlank(input.POCH_Vendedor__c)){
                        vendedorNew = input.POCH_Vendedor__c;
                        accountNew = input.POCH_Cliente__c;
                        sucursalIdNew = input.Poch_Sucursal__c;
                	}	
                }
            }
            if (vendedorNew != vendedorOld){
                Account cliente = [SELECT Id, OwnerId  FROM Account WHERE Id =: accountOld];
                propietarioOld = cliente.OwnerId;
                if (vendedorOld != null){
                    if (!string.isBlank(vendedorOld)){
                        for (Equipo_Vendedores__c listEquipo : [SELECT Id FROM Equipo_Vendedores__c WHERE Vendedor__c =: vendedorOld AND Sucursal__c =: sucursalId AND Sucursal_Ampliada__c =: sucursalAmpId]){
                            listEquipoV.add(listEquipo);
                        }
                        if (listEquipoV.size() > 0){
                            List<POCH_HojaInventario__c> listHojaInventario = [SELECT 
                                                                                    Id, 
                                                                                    POCH_Cuenta__c,
                                                                                    OwnerId
                                                                                FROM POCH_HojaInventario__c 
                                                                                WHERE POCH_Cuenta__c =: accountOld 
                                                                                AND POCH_Sucursal__c =: sucursalId];
                            if (listHojaInventario.size() > 0){
                                for (POCH_DetalleInventario__c listDetalle : [SELECT 
                                                                                    Id,
                                                                                    OwnerId 
                                                                                FROM POCH_DetalleInventario__c 
                                                                                WHERE POCH_HojaInventario__c =: listHojaInventario[0].Id
                                                                                AND POCH_Sucursal__c =: sucursalId]){
                                    for (POCH_DetalleInventario__Share listHojaDetShare : [SELECT Id, RowCause FROM POCH_DetalleInventario__Share WHERE UserOrGroupId =: vendedorOld  AND ParentId =: listDetalle.Id]){
                                        if (listDetalle.OwnerId == vendedorOld){
                                            listDetalle.OwnerId = vendedorNew;
                                            update listDetalle;
                                            if (listHojaDetShare.RowCause == 'Manual'){
                                                delete listHojaDetShare;
                                            }
                                        }else{
                                            delete listHojaDetShare;
                                        } 
                                    }
                                }
                                for (POCH_HojaInventario__c auxInventario : listHojaInventario) {
                                    for (POCH_HojaInventario__Share listHojaShare : [SELECT Id, RowCause FROM POCH_HojaInventario__Share WHERE UserOrGroupId =: vendedorOld  AND ParentId =: auxInventario.Id]){
                                        if (auxInventario.OwnerId == vendedorOld){
                                            auxInventario.OwnerId = vendedorNew;
                                            update auxInventario;
                                                    //listHojaDetShare.AccessLevel = 'Read';
                                                    //update listHojaDetShare;
                                            if (listHojaShare.RowCause == 'Manual'){
                                                delete listHojaShare;
                                            }
                                        }else{
                                            delete listHojaShare;
                                            System.debug('---- print delete Share Inventario ');
                                        }
                                    }
                                }
                            }
                            delete listEquipoV;
                        }
                    }
                }
                
                for (POCH_SucursalAmpliada__c listSuc : [SELECT Id FROM POCH_SucursalAmpliada__c WHERE POCH_Vendedor__c =: vendedorOld AND POCH_Cliente__c =: accountOld AND Id !=: sucursalAmpId]){
                    listaSucursal.add(listSuc);
                }
                if (listaSucursal.size() == 0){
                    //List<AccountShare> listAccountShare = [SELECT Id FROM AccountShare WHERE UserOrGroupId =: vendedorOld  AND AccountId =: accountOld];
                    List<Order> listOrder = [SELECT Id FROM Order WHERE OwnerId =: vendedorOld AND AccountId =: accountOld];
                    List<SBQQ__Quote__c> listQuote = [SELECT Id FROM SBQQ__Quote__c WHERE OwnerId =: vendedorOld AND SBQQ__Account__c =: accountOld];
                    List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity WHERE OwnerId =: vendedorOld AND POCH_IDCliente__c =: accountOld];
                    List<Contact> listContact = [SELECT Id FROM Contact WHERE OwnerId =: vendedorOld AND AccountId =: accountOld];
                    List<Account_Plan__c> listAccountPlan = [SELECT Id FROM Account_Plan__c WHERE OwnerId =: vendedorOld AND Name__c =: accountOld];
                    for (AccountShare listAccountShare : [SELECT Id FROM AccountShare WHERE UserOrGroupId =: vendedorOld  AND AccountId =: accountOld]){
                        listAccountShare.AccountAccessLevel  = 'Read';
                        listAccountShareAll.add(listAccountShare);    
                    }
                    if (propietarioOld != vendedorOld){
                        if (listOrder.size() == 0 && listQuote.size() == 0 && listOpportunity.size() == 0 && listContact.size() == 0 && listAccountPlan.size() == 0){
                            delete listAccountShareAll;
                        }else{
                            update listAccountShareAll;
                        }	    
                    }
                }
                for (POCH_SucursalAmpliada__c input: listSucursalAmp){
                    if(input.POCH_Vendedor__c != null){
                        if (!string.isBlank(input.POCH_Vendedor__c)){
                            vendedorNew = input.POCH_Vendedor__c;
                            accountNew = input.POCH_Cliente__c;
                            sucursalIdNew = input.Poch_Sucursal__c;
                            sucursalAmpIdNew = input.Id;  
                            moneda = input.CurrencyIsoCode;
                        }	
                    }
                }
                for (Equipo_Vendedores__c listEquipo : [SELECT Id FROM Equipo_Vendedores__c WHERE Vendedor__c =: vendedorNew AND Sucursal__c =: sucursalIdNew AND Sucursal_Ampliada__c =: sucursalAmpIdNew]){
                    listEquipoNew.add(listEquipo);
                }
                if (listEquipoNew.size() == 0 && vendedorNew != null){
                    Equipo_Vendedores__c equipo = new Equipo_Vendedores__c();
                    equipo.Sucursal__c = sucursalIdNew;
                    equipo.Sucursal_Ampliada__c = sucursalAmpIdNew;
                    equipo.Vendedor__c = vendedorNew;
                    
                    equipo.Acceso_Cliente__c = 'Escritura';
                    equipo.Rol__c = 'Vendedor Principal';
                    //equipo.Acceso_Opportunity__c = 'Escritura';
                    equipo.CurrencyIsoCode = moneda;
                    insert equipo;
                    AccountShare accountShare = new AccountShare();
                    accountShare.AccountId = accountNew;
                    accountShare.UserOrGroupId = vendedorNew;
                    accountShare.AccountAccessLevel = 'Edit';
                    accountShare.OpportunityAccessLevel = 'Edit';
                    try{
                        insert accountShare;
                    }catch(Exception e){
                        System.debug('error al otorgar permisos -> ' + e);
                    }
                    List<POCH_HojaInventario__c> listHojaInventario = [SELECT 
                                                                            Id, 
                                                                            POCH_Cuenta__c
                                                                        FROM POCH_HojaInventario__c 
                                                                        WHERE POCH_Cuenta__c =: accountNew 
                                                                        AND POCH_Sucursal__c =: sucursalIdNew];
                    if (listHojaInventario.size() > 0){
                        for (POCH_HojaInventario__c auxInventario : listHojaInventario) {
                            POCH_HojaInventario__Share inventarioTemp = new POCH_HojaInventario__Share();
                            inventarioTemp.ParentId = auxInventario.Id;
                            inventarioTemp.UserOrGroupId = vendedorNew;
                            inventarioTemp.AccessLevel = 'Edit';
                            inventarioTemp.RowCause = Schema.POCH_HojaInventario__Share.RowCause.Manual;
                            Database.SaveResult sr = Database.insert(inventarioTemp,false);
                            if (sr.isSuccess()){
                                System.debug('exito shared Iventario');
                            }
                            else {
                                // Get first save result error.
                                Database.Error err = sr.getErrors()[0];
                            }
                            for (POCH_DetalleInventario__c listDetalle : [SELECT
                                                                                Id 
                                                                            FROM POCH_DetalleInventario__c 
                                                                            WHERE POCH_HojaInventario__c =: auxInventario.Id 
                                                                            AND POCH_Sucursal__c =: sucursalIdNew]){
                                POCH_DetalleInventario__Share inventarioDetShareTemp = new POCH_DetalleInventario__Share();
                                inventarioDetShareTemp.ParentId = listDetalle.Id;
                                inventarioDetShareTemp.UserOrGroupId = vendedorNew;
                                inventarioDetShareTemp.AccessLevel = 'Edit';
                                inventarioDetShareTemp.RowCause = Schema.POCH_HojaInventario__Share.RowCause.Manual;
                                Database.SaveResult srd = Database.insert(inventarioDetShareTemp,false);
                                if (sr.isSuccess()){
                                    // Indicates success
                                    System.debug('exito');
                                }
                                else {
                                    // Get first save result error.
                                    Database.Error err = sr.getErrors()[0];
                                }
                            }
                        }
                    }
                }
            }
        }catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            String msg = 'Ocurrio un error al ejecutar insert de equipo de vendedores: '+ e.getMessage();
            throw new AuraHandledException('Ocurrio un error al ejecutar insert de equipo de vendedores o update en sucursal ampliada : '
                                           + e.getMessage());    
        }
    }
}