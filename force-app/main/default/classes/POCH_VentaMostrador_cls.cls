public class POCH_VentaMostrador_cls {
    /**
    Metodo para Obtener los detalles de inventario y mostarlos en el componente
    */
    @AuraEnabled
    public static Ventas_Mostrador__c getCabeceraVentaMostrador(String idCabeceraVentaMostrador) {
        Ventas_Mostrador__c cabecera = new Ventas_Mostrador__c();    
        
        cabecera = [SELECT 
                        Id, 
                        Name,
                        Cliente__c,
                        Name_Cliente__c,
                        Id_cliente_SAP__c,
                        POCH_Sucursal__r.Name,
                        POCH_Sucursal__r.POCH_Sociedad__c, 
                        CurrencyIsoCode,
                        Email__c,
                        Credito_disponible__c,
                        Digitos_tarjeta__c,
                        Via_de_pago__c, 
                        Condicion_de_Pago__c,
                        Metodo_de_Pago__c,
                        Metodo_de_Pago2__c,
                        Metodo_de_Pago3__c,
                        Importe__c,
                        Importe_2__c,
                        Importe_3__c,
                        Obs_Pago__c,
                        Obs_Pago_2__c,
                        Obs_Pago_3__c,
                        Valor_Neto__c,
                        Descuento__c,
                        Subtotal__c,
                        IVA__c,
                        Precio_total__c,
                        Id_Registro_SAP__c,
                        Status__c,
                        POCH_Sucursal__c,
                        Uso_de_CFDI__c,
                        Enviado_SAP__c,
                        OrganizacionVentas__c
                    FROM Ventas_Mostrador__c 
                    WHERE id =: idCabeceraVentaMostrador];
        system.debug(cabecera); 
        return cabecera; 
    }
    
    /**
    Metodo para Obtener los detalles de inventario y mostarlos en el componente
    */
    @AuraEnabled
    public static List<Venta_Mostrador_Detalle__c> getDetailsVentaMostrador(String idVentaMostrador) {
        List<Venta_Mostrador_Detalle__c> lstDetail = new List<Venta_Mostrador_Detalle__c>();    
        
        lstDetail = [SELECT 
                        Id, 
                        Name, 
                        CurrencyIsoCode, 
                        Material__c, 
                        Descto__c, 
                        Precio__c, 
                        Descripcion__c, 
                        POCH_Cantidad__c, 
                        UnidadMedida__c, 
                        Sucursal__c, 
                        Status__c,
                        IVA__c,
                        Descuento_Monto__c  
                    FROM Venta_Mostrador_Detalle__c 
                    WHERE Ventas_Mostrador__c =: idVentaMostrador];
        return lstDetail;
    }
    
    /*
    @Description:Obtiene datos iniciales de Inventario
    */
    @AuraEnabled
    public static Ventas_Mostrador__c getDataInv(String idInv) {
        return [SELECT Cliente__c,POCH_Sucursal__c,POCH_Sucursal__r.Name FROM Ventas_Mostrador__c WHERE Id =: idInv];
    }   

    /*
    @Description:Obtiene permisos de usuario actual
    */
    @AuraEnabled
    public static Boolean getAutorizacion(String idSuc) {
        if(String.isNotBlank(idSuc)) {
            String orgVts = [SELECT POCH_OrganizacionVentas__c FROM POCH_Sucursal__c WHERE Id =: idSuc OR Name =: idSuc LIMIT 1].POCH_OrganizacionVentas__c;            
            User usuario  = [SELECT Profile.Name,POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            
            List<String> lSuc = usuario.POCH_OrganizacionesVentas__c.split(';');
            Set<String>  setSuc = new Set<String>();
            for(String suc : lSuc)
                setSuc.add(suc);
            
            
            if(!setSuc.contains(orgVts) && !usuario.Profile.Name.containsIgnoreCase('admin'))            
                return true;
        }        
        return false;
    } 
    
    // Metodo para Obtener los stocks y mostarlos en el componente
    @AuraEnabled
    public static List<POCH_DetalleInventario__c> getStocks(String idSheetDetail) {
        List<POCH_DetalleInventario__c> lstDetail = new List<POCH_DetalleInventario__c>();    
        
        lstDetail = [SELECT Id FROM POCH_DetalleInventario__c limit 10 ];
        return lstDetail;
    }
    
    /**
    Metodo para obtener los valores de picklist esto es dinamico por objeto , solo funciona para un nivel de picklist
    */
    @AuraEnabled        
    public static List<String> PickListValuesIntoList(String objectType, String selectedField) {
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getLabel());
        }    
        return pickListValuesList;
    }
    
    /**
    Metodo para determinar el precio unitario
    */

     /**
    Metodo para obtener sucursal
    */
    @AuraEnabled
    public static Poch_Sucursal__c getSucursal(String idAccount) {
        User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId()];
        POCH_SucursalAmpliada__c sucursalAmp = [SELECT 
                                                    Id, 
                                                    Poch_Sucursal__c,
                                                    Poch_Sucursal__r.POCH_OrganizacionVentas__c
                                                FROM POCH_SucursalAmpliada__c 
                                                WHERE POCH_Cliente__c =: idAccount
                                                AND POCH_IdOrgVenta__c = '0029'];
                                                // AND POCH_IdOrgVenta__c =: usuario.POCH_OrganizacionesVentas__c];
        Poch_Sucursal__c organizacionVentas = [SELECT id, POCH_OrganizacionVentas__c FROM Poch_Sucursal__c WHERE id =: sucursalAmp.Poch_Sucursal__c];
        return organizacionVentas;
    }

    /**
    Metodo para obtener datos Account
    */
    @AuraEnabled
    public static Account getAccount(String idAccount) {
        Account cliente = [SELECT 
                                Id,
                                Name, 
                                POCH_IDClienteSAP__c,
                                CurrencyIsoCode,
                                POCH_CorreoElectronico__c,
                                POCH_ClasificacionFiscal__c
                            FROM Account 
                            WHERE Id =: idAccount];
        return cliente;
    }

    /**
    Metodo para obtener linea de credito
    */
    @AuraEnabled
    public static POCH_InformacionCredito__c getCreditLine(String idAccount) {
        User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId()];
        POCH_SucursalAmpliada__c sucursalAmp = [SELECT 
                                                    Id, 
                                                    Poch_Sucursal__c,
                                                    POCH_AreaControlCreditos__c 
                                                FROM POCH_SucursalAmpliada__c 
                                                WHERE POCH_Cliente__c =: idAccount
                                                //AND POCH_IdOrgVenta__c = '0029'];
                                                AND POCH_IdOrgVenta__c =: usuario.POCH_OrganizacionesVentas__c];

        POCH_InformacionCredito__c creditLine = [SELECT 
                                                    Id,
                                                    POCH_SaldoDisponible__c
                                                FROM POCH_InformacionCredito__c 
                                                WHERE POCH_Cliente__c =: idAccount
                                                AND POCH_AreaControlCredito__c =: sucursalAmp.POCH_AreaControlCreditos__c];
        return creditLine;
    }

    /**
    Metodo para obtener condition of pago
    */
    @AuraEnabled
    public static String getConditionPago(String idAccount) {
        String conditionPago = '';
        User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId()];
        POCH_SucursalAmpliada__c sucursalAmp = [SELECT 
                                                    Id, 
                                                    Condici_n_de_Pago__c
                                                FROM POCH_SucursalAmpliada__c 
                                                WHERE POCH_Cliente__c =: idAccount
                                                //AND POCH_IdOrgVenta__c = '0029'];
                                                AND POCH_IdOrgVenta__c =: usuario.POCH_OrganizacionesVentas__c];

        List<String> listDescription = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('POCH_SucursalAmpliada__c');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get('Condici_n_de_Pago__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry pickListVal : ple) {
                if (sucursalAmp.Condici_n_de_Pago__c == pickListVal.getValue()){
                    conditionPago = pickListVal.getLabel();
                }
                //pickListValuesList.add(pickListVal.getLabel());
            }   
        return conditionPago;
    }
    
    /**
    Metodo para obtener el description de un picklist dado el api name 
    */
    @AuraEnabled        
    public static List<String> getDescription(String objectType, String selectedField, List<String> listApiField) {
        List<String> listDescription = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (String apiField : listApiField) {
            for(Schema.PicklistEntry pickListVal : ple) {
                if (apiField == pickListVal.getValue()){
                    listDescription.add(pickListVal.getLabel());
                }
                //pickListValuesList.add(pickListVal.getLabel());
            }   
        }
            
        return listDescription;
    }

    /**
    Metodo para validar la moneda vs la moneda de la sucursal 
    */
    @AuraEnabled        
    public static Boolean validarCurrency(String idAccount, String moneda) {
        Boolean currencyCorrect = false;
        User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId()];
        POCH_SucursalAmpliada__c sucursalAmp = [SELECT 
                                                    Id, 
                                                    Poch_Sucursal__c 
                                                FROM POCH_SucursalAmpliada__c 
                                                WHERE POCH_Cliente__c =: idAccount
                                                AND POCH_IdOrgVenta__c =: usuario.POCH_OrganizacionesVentas__c];
                                                //AND POCH_IdOrgVenta__c = '0029'];
        POCH_Sucursal__c sucursal = [SELECT Id, CurrencyIsoCode FROM POCH_Sucursal__c WHERE Id =: sucursalAmp.Poch_Sucursal__c];
        if (moneda == sucursal.CurrencyIsoCode){
            currencyCorrect = true;
        }
        return currencyCorrect;
    }

    /**
    Metodo para obtener listado de rate of currency 
    */
    @AuraEnabled        
    public static List<String> getRates() {
        List<String> listDescriptions = new List<String>();
        for(CurrencyType listRates :[SELECT Id, ConversionRate, IsCorporate, IsActive, IsoCode FROM CurrencyType WHERE IsActive = true]){
            listDescriptions.add(listRates.IsoCode + listRates.ConversionRate);
        }
        return listDescriptions;
    }

    /**
    Metodo para obtener el apiName de un picklist dado el label
    */
    @AuraEnabled        
    public static String getApiName(String objectType, String selectedField, String apiLabel) {
        String description = '';
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            if (apiLabel == pickListVal.getLabel()){
                description = pickListVal.getValue();
            } 
        }
            
        return description;
    }
}