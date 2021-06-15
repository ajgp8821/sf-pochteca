/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System 
--- Author: Jesús Azuaje
--- Update for: Jesús Azuaje
--- Description: Helper Trigger tu grant access to Account or Opportunities, Apext Test CrearEquipoVendedoresTest
--- CreateDate: 16/04/2021 - JIRA RN-6426
--- UpdateDate: 17/05/2021 - JIRA CAM-2085 - find and grant access to inventary.
--- Version: 1.2
---------------------------------------------------------------------------------------------------------------*/
public class EquipoVendedorHelper {
    public class AuraHandledException extends exception {
        
    }
    public static void evaluateAccess(List<Equipo_Vendedores__c> listEquipoVendedor) {
        try {
            Id sucursalAmpliadaId, accountId, idVendedor, idSucursal;
            Boolean readInventario = false;
            Boolean editInventario = false;
            AccountShare accountShare = new AccountShare();
            for (Equipo_Vendedores__c input: listEquipoVendedor){
                sucursalAmpliadaId = input.Sucursal_Ampliada__c;
                idSucursal = input.Sucursal__c;
            }  
            List<POCH_SucursalAmpliada__c> sucAux = [SELECT Id, POCH_Cliente__c FROM POCH_SucursalAmpliada__c WHERE Id =: sucursalAmpliadaId];
            if (sucAux.size() > 0){
            	accountShare.AccountId = sucAux[0].POCH_Cliente__c; 
                accountId = sucAux[0].POCH_Cliente__c;
                for (Equipo_Vendedores__c input: listEquipoVendedor){
                    accountShare.UserOrGroupId = input.Vendedor__c;
                    idVendedor = input.Vendedor__c;
                    if (input.Acceso_Cliente__c == 'Lectura'){
                        accountShare.AccountAccessLevel = 'Read';
                        accountShare.OpportunityAccessLevel = 'Read';
                        readInventario = true;
                    }
                    if (input.Acceso_Cliente__c == 'Escritura'){
                        accountShare.AccountAccessLevel = 'Edit';
                        accountShare.OpportunityAccessLevel = 'Edit';
                        editInventario = true; 
                    }
                    try{
                        insert accountShare;
                    }catch(Exception e){
                        System.debug('error al otorgar permisos -> ' + e);
                    }
                }
                List<POCH_HojaInventario__c> listHojaInventario = [SELECT 
                                                                        Id, 
                                                                        POCH_Cuenta__c
                                                                    FROM POCH_HojaInventario__c 
                                                                    WHERE POCH_Cuenta__c =: accountId 
                                                                    AND POCH_Sucursal__c =: idSucursal];
                if (listHojaInventario.size() > 0){
                    if (editInventario){
                        for (POCH_HojaInventario__c auxInventario : listHojaInventario) {
                            POCH_HojaInventario__Share inventarioTemp = new POCH_HojaInventario__Share();
                            inventarioTemp.ParentId = auxInventario.Id;
                            inventarioTemp.UserOrGroupId = idVendedor;
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
                                                                            AND POCH_Sucursal__c =: idSucursal]){
                                POCH_DetalleInventario__Share inventarioDetShareTemp = new POCH_DetalleInventario__Share();
                                inventarioDetShareTemp.ParentId = listDetalle.Id;
                                inventarioDetShareTemp.UserOrGroupId = idVendedor;
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
                    if (readInventario){
                        for (POCH_HojaInventario__c auxInventario : listHojaInventario) {
                            POCH_HojaInventario__Share inventarioTemp = new POCH_HojaInventario__Share();
                            inventarioTemp.ParentId = auxInventario.Id;
                            inventarioTemp.UserOrGroupId = idVendedor;
                            inventarioTemp.AccessLevel = 'Read';
                            inventarioTemp.RowCause = Schema.POCH_HojaInventario__Share.RowCause.Manual;
                            Database.SaveResult sr = Database.insert(inventarioTemp,false);
                            if (sr.isSuccess()){
                                // Indicates success
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
                                                                            AND POCH_Sucursal__c =: idSucursal]){
                                POCH_DetalleInventario__Share inventarioDetShareTemp = new POCH_DetalleInventario__Share();
                                inventarioDetShareTemp.ParentId = listDetalle.Id;
                                inventarioDetShareTemp.UserOrGroupId = idVendedor;
                                inventarioDetShareTemp.AccessLevel = 'Read';
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
            String msg = 'Ocurrio un error al ejecutar insert / update de equipo de vendedores: '+ e.getMessage();
            throw new AuraHandledException('Ocurrio un error al ejecutar insert / update de equipo de vendedores: '
                                           + e.getMessage());    
        }
    }
    
    public static void getSucursal(List<Equipo_Vendedores__c> listEquipoVendedor) {
        try {
            Id sucursalAmpliadaId, sucursalId, clientId, vendedorId;
            for (Equipo_Vendedores__c input: listEquipoVendedor){
                vendedorId = input.Vendedor__c;
                sucursalId = input.Sucursal__c;
                sucursalAmpliadaId = Input.Sucursal_Ampliada__c;
            }    
            List<POCH_SucursalAmpliada__c> sucAux = [SELECT Id, Poch_Sucursal__c FROM POCH_SucursalAmpliada__c WHERE Id =: sucursalAmpliadaId];
            if (sucAux.size() > 0){
                sucursalId = sucAux[0].Poch_Sucursal__c;
                for (Equipo_Vendedores__c input: listEquipoVendedor){
                    input.Sucursal__c = sucursalId; 
                }  
            }                
        }catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            String msg = 'Ocurrio un error al ejecutar insert de equipo de vendedores: '+ e.getMessage();
            throw new AuraHandledException('Ocurrio un error al ejecutar insert de equipo de vendedores: '
                                           + e.getMessage());    
        }
    }
    
    public static void deleteAccess(List<Equipo_Vendedores__c> listEquipoVendedor) {
        try {
            List<AccountShare> listAccountShareAll = new List<AccountShare>();
			Id propietarioId,sucursalAmpliadaId, vendedorId, sucursalId, clientId, inventarioId;
            for (Equipo_Vendedores__c input: listEquipoVendedor){
                sucursalAmpliadaId = Input.Sucursal_Ampliada__c;
                vendedorId = input.Vendedor__c;
                sucursalId = input.Sucursal__c;
            }
            for (POCH_SucursalAmpliada__c listSucAux2 : [SELECT Id, POCH_Cliente__c  FROM POCH_SucursalAmpliada__c WHERE Id =: sucursalAmpliadaId]){
            	clientId = listSucAux2.POCH_Cliente__c; 
            }
            List<POCH_SucursalAmpliada__c> listSucAux = [SELECT Id FROM POCH_SucursalAmpliada__c WHERE POCH_Vendedor__c =: vendedorId AND POCH_Cliente__c =: clientId AND Id !=: sucursalAmpliadaId];
            if (listSucAux.size() == 0){
                List<Order> listOrder = [SELECT Id FROM Order WHERE OwnerId =: vendedorId AND AccountId =: clientId];
                List<SBQQ__Quote__c> listQuote = [SELECT Id FROM SBQQ__Quote__c WHERE OwnerId =: vendedorId AND SBQQ__Account__c =: clientId];
                List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity WHERE OwnerId =: vendedorId AND POCH_IDCliente__c =: clientId];
                List<Contact> listContact = [SELECT Id FROM Contact WHERE OwnerId =: vendedorId AND AccountId =: clientId];
                List<Account_Plan__c> listAccountPlan = [SELECT Id FROM Account_Plan__c WHERE OwnerId =: vendedorId AND Name__c =: clientId];
                for (AccountShare listAccountShare : [SELECT Id FROM AccountShare WHERE UserOrGroupId =: vendedorId  AND AccountId =: clientId]){
                    listAccountShare.AccountAccessLevel = 'Read';
                    listAccountShareAll.add(listAccountShare); 
                }
                Account cliente = [SELECT Id, OwnerId  FROM Account WHERE Id =: clientId];
                propietarioId = cliente.OwnerId;
                if (propietarioId != vendedorId){
                    if (listOrder.size() == 0 && listQuote.size() == 0 && listOpportunity.size() == 0 && listContact.size() == 0 && listAccountPlan.size() == 0){
                        delete listAccountShareAll;
                    }else{
                        update listAccountShareAll;
                    }	  
                } 
            }
            List<POCH_HojaInventario__c> listHojaInventario = [SELECT 
                                                                    Id, 
                                                                    POCH_Cuenta__c,
                                                                    OwnerId
                                                                FROM POCH_HojaInventario__c 
                                                                WHERE POCH_Cuenta__c =: clientId 
                                                                AND POCH_Sucursal__c =: sucursalId];  
            if (listHojaInventario.size() > 0){
                for (POCH_DetalleInventario__c listDetalle : [SELECT 
                                                                    Id,
                                                                    OwnerId 
                                                                FROM POCH_DetalleInventario__c 
                                                                WHERE POCH_HojaInventario__c =: listHojaInventario[0].Id
                                                                AND POCH_Sucursal__c =: sucursalId]){
                    for (POCH_DetalleInventario__Share listHojaDetShare : [SELECT Id, RowCause FROM POCH_DetalleInventario__Share WHERE UserOrGroupId =: vendedorId  AND ParentId =: listDetalle.Id]){
                        if (listDetalle.OwnerId == vendedorId){
                            listDetalle.OwnerId = UserInfo.getUserId();
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
                    for (POCH_HojaInventario__Share listHojaShare : [SELECT Id, RowCause FROM POCH_HojaInventario__Share WHERE UserOrGroupId =: vendedorId  AND ParentId =: auxInventario.Id]){
                        if (auxInventario.OwnerId == vendedorId){
                            auxInventario.OwnerId = UserInfo.getUserId();
                            update auxInventario;
                                    //listHojaDetShare.AccessLevel = 'Read';
                                    //update listHojaDetShare;
                            if (listHojaShare.RowCause == 'Manual'){
                                delete listHojaShare;
                            }
                        }else{
                            delete listHojaShare;
                        }
                    }
                    
                }
            }
        }catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            String msg = 'Ocurrio un error al ejecutar update de equipo de vendedores: '+ e.getMessage();
            throw new AuraHandledException('Ocurrio un error al ejecutar delete de equipo de vendedores: '
                                           + e.getMessage());    
        }
    }

    public static void updateEquipo(List<Equipo_Vendedores__c> listEquipoVendedor, List<Equipo_Vendedores__c> listEquipoVendedorOld) {
        try {
            Boolean readInventario = false;
            Boolean editInventario = false;
            List<AccountShare> listAccountShareAll = new List<AccountShare>();
            Id sucursalAmpliadaId, vendedorIdOld, vendedorIdNew, accountId, propietarioId, sucursalId, sucursalIdOld;
            AccountShare accountShare = new AccountShare();
            for (Equipo_Vendedores__c InputOld: listEquipoVendedorOld){
                vendedorIdOld = InputOld.Vendedor__c;
                sucursalIdOld = InputOld.Sucursal__c;
            }
            for (Equipo_Vendedores__c input: listEquipoVendedor){
                sucursalAmpliadaId = input.Sucursal_Ampliada__c;
                vendedorIdNew = input.Vendedor__c;
                sucursalId = input.Sucursal__c;
            }  
            List<POCH_SucursalAmpliada__c> sucAux = [SELECT Id, POCH_Cliente__c FROM POCH_SucursalAmpliada__c WHERE Id =: sucursalAmpliadaId];
            if (sucAux.size() > 0){
                accountId = sucAux[0].POCH_Cliente__c;
                if (vendedorIdNew != vendedorIdOld){
                    List<Order> listOrder = [SELECT Id FROM Order WHERE OwnerId =: vendedorIdOld AND AccountId =: accountId];
                    List<SBQQ__Quote__c> listQuote = [SELECT Id FROM SBQQ__Quote__c WHERE OwnerId =: vendedorIdOld AND SBQQ__Account__c =: accountId];
                    List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity WHERE OwnerId =: vendedorIdOld AND POCH_IDCliente__c =: accountId];
                    List<Contact> listContact = [SELECT Id FROM Contact WHERE OwnerId =: vendedorIdOld AND AccountId =: accountId];
                    List<Account_Plan__c> listAccountPlan = [SELECT Id FROM Account_Plan__c WHERE OwnerId =: vendedorIdOld AND Name__c =: accountId];
                    for (AccountShare listAccountShare : [SELECT Id FROM AccountShare WHERE UserOrGroupId =: vendedorIdOld  AND AccountId =: accountId]){
                        listAccountShare.AccountAccessLevel = 'Read';
                        listAccountShare.OpportunityAccessLevel = 'None';
                        listAccountShareAll.add(listAccountShare); 
                    }
                    Account cliente = [SELECT Id, OwnerId  FROM Account WHERE Id =: accountId];
                    propietarioId = cliente.OwnerId;
                    if (propietarioId != vendedorIdOld){
                        if (listOrder.size() == 0 && listQuote.size() == 0 && listOpportunity.size() == 0 && listContact.size() == 0 && listAccountPlan.size() == 0){
                            delete listAccountShareAll;
                        }else{
                            update listAccountShareAll;
                        }	  
                    }
                    List<POCH_HojaInventario__c> listHojaInventario = [SELECT 
                                                                            Id, 
                                                                            POCH_Cuenta__c,
                                                                            OwnerId
                                                                        FROM POCH_HojaInventario__c 
                                                                        WHERE POCH_Cuenta__c =: accountId 
                                                                        AND POCH_Sucursal__c =: sucursalIdOld];
                    if (listHojaInventario.size() > 0){
                        for (POCH_DetalleInventario__c listDetalle : [SELECT 
                                                                            Id,
                                                                            OwnerId 
                                                                        FROM POCH_DetalleInventario__c 
                                                                        WHERE POCH_HojaInventario__c =: listHojaInventario[0].Id
                                                                        AND POCH_Sucursal__c =: sucursalIdOld]){
                            for (POCH_DetalleInventario__Share listHojaDetShare : [SELECT Id, RowCause FROM POCH_DetalleInventario__Share WHERE UserOrGroupId =: vendedorIdOld  AND ParentId =: listDetalle.Id]){
                                if (listDetalle.OwnerId == vendedorIdOld){
                                    listDetalle.OwnerId = vendedorIdNew;
                                    update listDetalle;
                                    //listHojaDetShare.AccessLevel = 'Read';
                                    //update listHojaDetShare;
                                    if (listHojaDetShare.RowCause == 'Manual'){
                                        delete listHojaDetShare;
                                    } 
                                }else{
                                    delete listHojaDetShare;
                                }     
                            }
                        }
                        for (POCH_HojaInventario__c auxInventario : listHojaInventario) {
                            for (POCH_HojaInventario__Share listHojaShare : [SELECT Id, RowCause FROM POCH_HojaInventario__Share WHERE UserOrGroupId =: vendedorIdOld  AND ParentId =: auxInventario.Id]){
                                if (auxInventario.OwnerId == vendedorIdOld){
                                    auxInventario.OwnerId = vendedorIdNew;
                                    update auxInventario;
                                    if (listHojaShare.RowCause == 'Manual'){
                                        delete listHojaShare;
                                    }
                                }else{
                                    delete listHojaShare;
                                }    
                            }   
                        }
                    }
                }
            	accountShare.AccountId = accountId; 
                for (Equipo_Vendedores__c Input: listEquipoVendedor){
                    accountShare.UserOrGroupId = Input.Vendedor__c;
                    if(Input.Acceso_Cliente__c == 'Lectura'){
                        accountShare.AccountAccessLevel = 'Read';
                        accountShare.OpportunityAccessLevel = 'Read';
                        readInventario = true;
                    }
                    if(Input.Acceso_Cliente__c == 'Escritura'){
                        accountShare.AccountAccessLevel = 'Edit';
                        accountShare.OpportunityAccessLevel = 'Edit';
                        editInventario = true;
                    }
                    try{
                        insert accountShare;
                    }catch(Exception e){
                        System.debug('error al otorgar permisos -> ' + e);
                    }
                }
                List<POCH_HojaInventario__c> listHojaInventario = [SELECT 
                                                                        Id, 
                                                                        POCH_Cuenta__c,
                                                                        OwnerId
                                                                    FROM POCH_HojaInventario__c 
                                                                    WHERE POCH_Cuenta__c =: accountId 
                                                                    AND POCH_Sucursal__c =: sucursalId]; 
                if (listHojaInventario.size() > 0){
                    if (editInventario){
                        for (POCH_HojaInventario__c auxInventario : listHojaInventario) {
                            POCH_HojaInventario__Share inventarioTemp = new POCH_HojaInventario__Share();
                            inventarioTemp.ParentId = auxInventario.Id;
                            inventarioTemp.UserOrGroupId = vendedorIdNew;
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
                                inventarioDetShareTemp.UserOrGroupId = vendedorIdNew;
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
                    if (readInventario){
                        for (POCH_HojaInventario__c auxInventario : listHojaInventario) {
                            POCH_HojaInventario__Share inventarioTemp = new POCH_HojaInventario__Share();
                            inventarioTemp.ParentId = auxInventario.Id;
                            inventarioTemp.UserOrGroupId = vendedorIdNew;
                            inventarioTemp.AccessLevel = 'Read';
                            inventarioTemp.RowCause = Schema.POCH_HojaInventario__Share.RowCause.Manual;
                            Database.SaveResult sr = Database.insert(inventarioTemp,false);
                            if (sr.isSuccess()){
                                // Indicates success
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
                                inventarioDetShareTemp.UserOrGroupId = vendedorIdNew;
                                inventarioDetShareTemp.AccessLevel = 'Read';
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
            String msg = 'Ocurrio un error al ejecutar insert / update de equipo de vendedores: '+ e.getMessage();
            throw new AuraHandledException('Ocurrio un error al ejecutar  update de equipo de vendedores: '
                                           + e.getMessage());    
        }
    }
}