public class AccountInventoryHelper {
    
    public class AuraHandledException extends exception {
        
    }
    
    public static void updateOwner(Map<Id, Account> oldMapAccs, List<Account> newListAccs){
        Map<Id, Id> accOwnerId = new Map<Id, Id>();
        for(Account acc : newListAccs){
            Account oldAcc = oldMapAccs.get(acc.id);
            if(acc.OwnerId != oldAcc.OwnerId){
                accOwnerId.put(acc.id, acc.OwnerId);
            }
        }
        
        List<POCH_HojaInventario__c> inventoryList = [Select id, POCH_Cuenta__c, OwnerId from POCH_HojaInventario__c where POCH_Cuenta__c = :accOwnerId.keySet()];
        
        for(POCH_HojaInventario__c inv : inventoryList){
            inv.OwnerId = accOwnerId.get(inv.POCH_Cuenta__c);
        }
        update inventoryList;
    }
    
    /*this method received object Account and find currency of sucursal and update currency Account*/
    public static void updateCurrency(List<Account> listAccount) {
        try {
            Boolean envioNotificacion = false;
            String orgVentas = '';
            String idClienteSAP = '';
            String createDate = '';
            String modDate = '';
            String zona = '';
            Id idSucursalAccount, idSucursal;
            for (Account accountInput: listAccount){
                orgVentas = accountInput.POCH_OrganizacionVentas__c;
                idClienteSAP = accountInput.POCH_IDClienteSAP__c;
                idSucursalAccount = accountInput.POCH_Sucursal__c;
                envioNotificacion = accountInput.Envio_notificacion_SAP_Sudamerica__c;
                createDate = string.valueOfGmt(accountInput.CreatedDate);
                modDate = string.valueOfGmt(accountInput.LastModifiedDate);
                zona = accountInput.Zona__c;
            }
            if (String.isBlank(idClienteSAP)){
             	POCH_Sucursal__c sucursal = [SELECT 
                                                Id, 
                                                POCH_OrganizacionVentas__c, 
                                                CurrencyIsoCode,
                                             	Zona__c,
                                             	POCH_ClasificacionFisca__c
                                             FROM POCH_Sucursal__c 
                                             WHERE POCH_OrganizacionVentas__c =: orgVentas
                                             LIMIT 1];
            	String currencyOrgVenta = sucursal.CurrencyIsoCode;
                idSucursal = sucursal.Id;
                String clasificacionFiscal = sucursal.POCH_ClasificacionFisca__c;
                 	for (Account accountInput: listAccount){
                    	accountInput.CurrencyIsoCode = currencyOrgVenta;
                        if (idSucursal != idSucursalAccount){
                            accountInput.POCH_Sucursal__c = idSucursal;
                            
                        }
                        accountInput.POCH_ClasificacionFiscal__c = clasificacionFiscal;
					}     
            }
            if (!String.isBlank(idClienteSAP)){
                if (createDate != modDate && zona == 'SUDAMERICA'){
                   for (Account accountInput: listAccount){
                       accountInput.Envio_notificacion_SAP_Sudamerica__c = true;
					} 
                }
            }              
        }catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            String msg = 'Ocurrio un error al ejecutar la actualización del currency de la cuenta: '+ e.getMessage();
            throw new AuraHandledException('Ocurrio un error al ejecutar la actualización del currency de la cuenta: '
                                           + e.getMessage());    
        }
    }
}