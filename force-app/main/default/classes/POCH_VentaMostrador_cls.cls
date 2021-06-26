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
        cabecera.Uso_de_CFDI__c = getDescriptionString('Ventas_Mostrador__c', 'Uso_de_CFDI__c', cabecera.Uso_de_CFDI__c);
        cabecera.Metodo_de_Pago__c = getDescriptionString('Ventas_Mostrador__c', 'Metodo_de_Pago__c', cabecera.Metodo_de_Pago__c);
        cabecera.Metodo_de_Pago2__c = getDescriptionString('Ventas_Mostrador__c', 'Metodo_de_Pago2__c', cabecera.Metodo_de_Pago2__c);
        cabecera.Metodo_de_Pago3__c = getDescriptionString('Ventas_Mostrador__c', 'Metodo_de_Pago3__c', cabecera.Metodo_de_Pago3__c);
        cabecera.Via_de_pago__c = getDescriptionString('Ventas_Mostrador__c', 'Via_de_pago__c', cabecera.Via_de_pago__c);
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
                        Product__c,
                        IVA__c,
                        Descuento_Monto__c,
                        Oficina_de_Venta__c,
                        POCH_Centro__c,
                        Almacen__c,
                        Stock__c,
                        Stock_Consignacion__c,
                        Valor_neto__c,
                        Margen__c
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
            //User usuario  = [SELECT Profile.Name,POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            User usuario  = [SELECT Profile.Name,POCH_OrganizacionesVentas__c FROM User WHERE Id = '0052i000003KL7YAAW' LIMIT 1];
            
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
        //User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId()];
        User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id = '0052i000003KL7YAAW'];
        POCH_SucursalAmpliada__c sucursalAmp = [SELECT 
                                                    Id, 
                                                    Poch_Sucursal__c,
                                                    Name,
                                                    Poch_Sucursal__r.POCH_OrganizacionVentas__c
                                                FROM POCH_SucursalAmpliada__c 
                                                WHERE POCH_Cliente__c =: idAccount
                                                //AND POCH_IdOrgVenta__c = '0029'];
                                                AND POCH_IdOrgVenta__c =: usuario.POCH_OrganizacionesVentas__c];
        Poch_Sucursal__c organizacionVentas = [SELECT id, POCH_OrganizacionVentas__c, POCH_OficinaVentas__c FROM Poch_Sucursal__c WHERE id =: sucursalAmp.Poch_Sucursal__c];
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
        //User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId()];
        User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id = '0052i000003KL7YAAW'];
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
        //User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId()];
        User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id = '0052i000003KL7YAAW'];
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
    Metodo para obtener el description de un api name 
    */
    @AuraEnabled        
    public static String getDescriptionString(String objectType, String selectedField, String apiField) {
        String description = '';
        //List<String> listDescription = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //for (String apiField : listApiField) {
            for(Schema.PicklistEntry pickListVal : ple) {
                if (apiField == pickListVal.getValue()){
                    description = pickListVal.getLabel();
                }
                //pickListValuesList.add(pickListVal.getLabel());
            }   
        //}
            
        return description;
    }

    /**
    Metodo para validar la moneda vs la moneda de la sucursal 
    */
    @AuraEnabled        
    public static Boolean validarCurrency(String idAccount, String moneda, Boolean notIsApiField, String objectType, String selectedField) {
        if (notIsApiField){
            moneda = getApiName(objectType, selectedField, moneda);
        }
        Boolean currencyCorrect = false;
        //User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId()];
        User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id = '0052i000003KL7YAAW'];
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

    @AuraEnabled
    public static Boolean saveVentasMostrador(Ventas_Mostrador__c ventasMostrador, Venta_Mostrador_Detalle__c[] ventasMostradorDetalle) {
        Boolean saveDetails = true;
        // ventasMostrador.Status = 'On Hold';
        // insert(ventasMostrador);
        ventasMostrador.Status__c = 'Creado';
        if (!string.isBlank(ventasMostrador.Metodo_de_Pago__c)){
            ventasMostrador.Metodo_de_Pago__c = getApiName('Ventas_Mostrador__c', 'Metodo_de_Pago__c', ventasMostrador.Metodo_de_Pago__c);
        }
        if (!string.isBlank(ventasMostrador.Metodo_de_Pago2__c)){
            ventasMostrador.Metodo_de_Pago2__c = getApiName('Ventas_Mostrador__c', 'Metodo_de_Pago2__c', ventasMostrador.Metodo_de_Pago2__c);
        }
        if (!string.isBlank(ventasMostrador.Metodo_de_Pago3__c)){
            ventasMostrador.Metodo_de_Pago3__c = getApiName('Ventas_Mostrador__c', 'Metodo_de_Pago3__c', ventasMostrador.Metodo_de_Pago3__c);
        }
        ventasMostrador.CurrencyIsoCode = getApiName('Ventas_Mostrador__c', 'CurrencyIsoCode', ventasMostrador.CurrencyIsoCode);
        ventasMostrador.Via_de_pago__c = getApiName('Ventas_Mostrador__c', 'Via_de_pago__c', ventasMostrador.Via_de_pago__c);
        ventasMostrador.Uso_de_CFDI__c = getApiName('Ventas_Mostrador__c', 'Uso_de_CFDI__c', ventasMostrador.Uso_de_CFDI__c);
        ventasMostrador.Digitos_tarjeta__c = String.valueOf(ventasMostrador.Digitos_tarjeta__c);
        //System.debug(JSON.serializePretty(ventasMostrador));
        //System.debug(JSON.serializePretty(ventasMostradorDetalle));
        Database.SaveResult ventasM = Database.insert(ventasMostrador, false);
        System.debug('print respuesta insert Cabecera : ' + ventasM);

        if (ventasMostradorDetalle.size() > 0){
            for (Venta_Mostrador_Detalle__c detalle : ventasMostradorDetalle) {
                System.debug('print centro--> : ' + detalle.POCH_Centro__c);
                detalle.Almacen__c = getApiName('Venta_Mostrador_Detalle__c', 'Almacen__c', detalle.Almacen__c);
                detalle.POCH_Centro__c = getApiName('Venta_Mostrador_Detalle__c', 'POCH_Centro__c', detalle.POCH_Centro__c);
                detalle.UnidadMedida__c = getApiName('Venta_Mostrador_Detalle__c', 'UnidadMedida__c', detalle.UnidadMedida__c);
                detalle.Cte_Consigna__c = 0;
                System.debug('print centro salida --> : ' + detalle.POCH_Centro__c);
            }
            saveDetails = saveVentasMostradorDetalle(ventasM.getId(), ventasMostradorDetalle);
            
            if(saveDetails == false) {
                delete(ventasMostrador);
            }
        }
        // System.debug('print respuesta insert detalle : ' + saveDetails);
        // System.debug('print ventasM.isSuccess() : ' + ventasM.isSuccess() + ' saveDetails -> '+ saveDetails);
        if (ventasM.isSuccess() && saveDetails == true) {
            return true;
        }
        else {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean saveVentasMostradorDetalle(Id idVentasMostrador, List<Venta_Mostrador_Detalle__c> ventasMostradorDetalle) {
        
        for (Venta_Mostrador_Detalle__c detail: ventasMostradorDetalle) {
            System.debug('print2 Material__c: ' + detail.Material__c);
            System.debug('print2 POCH_Cantidad__c: ' + detail.POCH_Cantidad__c);
            System.debug('print2 UnidadMedida__c: ' + detail.UnidadMedida__c);
            System.debug('print2 Precio__c: ' + detail.Precio__c);
            System.debug('print2 CurrencyIsoCode: ' + detail.CurrencyIsoCode);
            System.debug('print2 POCH_Centro__c: ' + detail.POCH_Centro__c);
            System.debug('print2 Almacen__c: ' + detail.Almacen__c);
            System.debug('print2 Descto__c: ' + detail.Descto__c);
            System.debug('print2 Valor_neto__c: ' + detail.Valor_neto__c);
            System.debug('print2 Stock__c: ' + detail.Stock__c);
            System.debug('print2 Stock_Consignacion__c: ' + detail.Stock_Consignacion__c);
            System.debug('print2 Cte_Consigna__c: ' + detail.Stock_Consignacion__c);
            System.debug('print2 Descuento_Monto__c: ' + detail.Descuento_Monto__c);
            System.debug('print2 IVA__c: ' + detail.IVA__c);
            System.debug('print2 Oficina_de_Venta__c: ' + detail.Oficina_de_Venta__c);
            System.debug('print2 Product__c: ' + detail.Product__c);
            System.debug('print2 Sucursal__c: ' + detail.Sucursal__c);
            detail.Ventas_Mostrador__c = idVentasMostrador;
        }
        // insert(ventasMostradorDetalle);
        System.debug(JSON.serializePretty(ventasMostradorDetalle));
        
        System.debug('print  idPadre andtes -> : ' +idVentasMostrador);
        
        System.debug('print  idPadre -> : ' + ventasMostradorDetalle[0].Ventas_Mostrador__c);
        Database.SaveResult[] srList = Database.insert(ventasMostradorDetalle, false);
        System.debug('print result' + srList[0].isSuccess());

        if (srList[0].isSuccess()) {
            return true;
        }
        else {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean editVentasMostrador(Ventas_Mostrador__c ventasMostrador, Venta_Mostrador_Detalle__c[] ventasMostradorDetalle) {

        Boolean editDetails = true;
        if (!string.isBlank(ventasMostrador.Metodo_de_Pago__c)){
            ventasMostrador.Metodo_de_Pago__c = getApiName('Ventas_Mostrador__c', 'Metodo_de_Pago__c', ventasMostrador.Metodo_de_Pago__c);
        }
        if (!string.isBlank(ventasMostrador.Metodo_de_Pago2__c)){
            ventasMostrador.Metodo_de_Pago2__c = getApiName('Ventas_Mostrador__c', 'Metodo_de_Pago2__c', ventasMostrador.Metodo_de_Pago2__c);
        }
        if (!string.isBlank(ventasMostrador.Metodo_de_Pago3__c)){
            ventasMostrador.Metodo_de_Pago3__c = getApiName('Ventas_Mostrador__c', 'Metodo_de_Pago3__c', ventasMostrador.Metodo_de_Pago3__c);
        }
        ventasMostrador.CurrencyIsoCode = getApiName('Ventas_Mostrador__c', 'CurrencyIsoCode', ventasMostrador.CurrencyIsoCode);
        ventasMostrador.Via_de_pago__c = getApiName('Ventas_Mostrador__c', 'Via_de_pago__c', ventasMostrador.Via_de_pago__c);
        ventasMostrador.Uso_de_CFDI__c = getApiName('Ventas_Mostrador__c', 'Uso_de_CFDI__c', ventasMostrador.Uso_de_CFDI__c);
        ventasMostrador.Digitos_tarjeta__c = String.valueOf(ventasMostrador.Digitos_tarjeta__c);


        // Create a savepoint before update 
        Savepoint spVentasM = Database.setSavepoint();
        Database.SaveResult ventasM = Database.update(ventasMostrador, false);

        if (ventasMostradorDetalle.size() > 0){
            for (Venta_Mostrador_Detalle__c detalle : ventasMostradorDetalle) {
                System.debug('print centro--> : ' + detalle.POCH_Centro__c);
                detalle.Almacen__c = getApiName('Venta_Mostrador_Detalle__c', 'Almacen__c', detalle.Almacen__c);
                detalle.POCH_Centro__c = getApiName('Venta_Mostrador_Detalle__c', 'POCH_Centro__c', detalle.POCH_Centro__c);
                detalle.UnidadMedida__c = getApiName('Venta_Mostrador_Detalle__c', 'UnidadMedida__c', detalle.UnidadMedida__c);
                detalle.Cte_Consigna__c = 0;
                System.debug('print centro salida --> : ' + detalle.POCH_Centro__c);
            }
            editDetails = editVentasMostradorDetalle(ventasM.getId(), ventasMostradorDetalle);
            
            if (editDetails == false) {
                Database.rollback(spVentasM);
            }
        }

        // editVentasMostradorDetalle(ventasMostrador.Id, ventasMostradorDetalle);
        if (ventasM.isSuccess() && editDetails == true) {
            return true;
        }
        else {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean editVentasMostradorDetalle(Id idVentasMostrador, List<Venta_Mostrador_Detalle__c> ventasMostradorDetalle) {
        
        // Create a savepoint before delete 
        Savepoint spVentasMD = Database.setSavepoint();
        // System.debug('idVentasMostrador = ' + idVentasMostrador);
        Database.DeleteResult[] deleteVentasM = Database.delete(ventasMostradorDetalle, false);
        // delete
        // delete [SELECT Id FROM Venta_Mostrador_Detalle__c where Ventas_Mostrador__c.Id =: idVentasMostrador];

        for (Venta_Mostrador_Detalle__c detail: ventasMostradorDetalle) {
            System.debug('print2 ' + JSON.serializePretty(detail));
            detail.Ventas_Mostrador__c = idVentasMostrador;
        }
        // insert(ventasMostradorDetalle);
        System.debug(JSON.serializePretty(ventasMostradorDetalle));
        
        System.debug('print  idPadre andtes -> : ' +idVentasMostrador);
        
        System.debug('print  idPadre -> : ' + ventasMostradorDetalle[0].Ventas_Mostrador__c);
        
        
        // saveVentasMostradorDetalle(idVentasMostrador, deploymentDetails);

        if (deleteVentasM[0].isSuccess()) {
            Database.SaveResult[] srList = Database.insert(ventasMostradorDetalle, false);
            System.debug('print result' + srList[0].isSuccess());
            // Boolean saveVMD = saveVentasMostradorDetalle(idVentasMostrador, deploymentDetails);
            if (srList[0].isSuccess() == true){
                return true;
            }
            else {
                Database.rollback(spVentasMD);
                return false;
            }
        }
        return false;
    }

    /**
    Metodo para obtener stock 
    */
    @AuraEnabled        
    public static Double getStock(Id product, String centro, String almacen, String stockConsigna) {
        Double stock = 0.0;
        almacen = getApiName('Venta_Mostrador_Detalle__c', 'Almacen__c', almacen);
        centro = getApiName('Venta_Mostrador_Detalle__c', 'POCH_Centro__c', centro);
        Stock_of_matrials__c stockCabecera = [SELECT Id FROM Stock_of_matrials__c WHERE Product__c =: product AND POCH_Centro__c =: centro];
        for(Stock_details__c listStockDatalle :[SELECT 
                                                    Id,
                                                    POCH_Stock_valorado_libre_utilizacion__c 
                                                FROM Stock_details__c 
                                                WHERE POCH_Almacen__c =: almacen 
                                                AND POCH_Indicador_stock_especial__c =: stockConsigna 
                                                AND Stock_of_matrials__c =: stockCabecera.Id]){
            stock = stock + listStockDatalle.POCH_Stock_valorado_libre_utilizacion__c;
        }
        return stock;
    }

    /**
    Metodo para obtener IVA 
    */
    @AuraEnabled        
    public static Double getIVA(Id product, Id sucursal, Double valorNeto) {
        Double iva = 0.0;
        System.debug('print  IVA product: ' + product + ' sucursal -> '+ sucursal + ' valorNeto -> ' + valorNeto);
        for(POCH_ProductoSucursal__c sucursalProducto :[SELECT 
                                                            Id,
                                                            IMPUESTO_PRODUCTO__c,
                                                            Tasa_de_Impuesto__c 
                                                        FROM POCH_ProductoSucursal__c 
                                                        WHERE POCH_Producto__c =: product 
                                                        AND POCH_Sucursal__c =: sucursal
                                                        AND POCH_CanalDistribucion__c = '12']){
            iva = valorNeto * sucursalProducto.Tasa_de_Impuesto__c / 100;
        }
        return iva;
    }
    
    @AuraEnabled 
    public static List<String> getDependentPicklistValues(String objectType, String firstField, String selectedField, String filter, Boolean isApiField) {
        if (isApiField){
            filter = getDescriptionString(objectType, firstField, filter);
        }
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult depend = res.fields.getMap().get(selectedField).getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new List<String>();
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        
        List<String> filters = new List<String>();
        filters.addall(dependentPicklistValues.get(filter));
        return filters;
    }

    /**
    Metodo para calcular el precio segun la cantidad 
    */
    @AuraEnabled        
    public static Double getPrice(Id product, Id sucursal, Integer cantidad, Id account, String unidadMedida, Boolean notIsApiField, 
                                    String objectType, String selectedField, String organizacionVenta) {
        System.debug('print cantidad: ' + cantidad);
        Double precio = 0.0;
        Double precioContractPrice = 0.0;
        String unidadMedidaEscala = '';
        String unidadMedidaPricebook = '';
        String unidadMedidaEscalaContract = '';
        String unidadMedidaPricebookContract = '';
        DOUBLE factorConversionA = 0.0;
        DOUBLE factorConversionACantidad = 0.0;
        DOUBLE factorConversionB = 0.0;
        Boolean consiguio = false;
        Boolean tengoPrecio = false;
        Boolean precioCantidadConvertido = false;
        DOUBLE cantidadConvertida = 0;
        String unidadMedidaTemp = '';
        DOUBLE cantidadMinima = 0.0;
        if (notIsApiField){
            unidadMedida = getApiName(objectType, selectedField, unidadMedida);
        }  
        for(SBQQ__ContractedPrice__c listContractedPrice :[SELECT Id,
                                                                SBQQ__Price__c,
                                                                POCH_UnidadMedidaEscala__c,
                                                                POCH_UnidadMedida__c,
                                                                CurrencyIsoCode  //devolver esto para la moneda
                                                            FROM SBQQ__ContractedPrice__c
                                                            WHERE POCH_Sucursal__c =: sucursal 
                                                            AND SBQQ__Product__c =: product
                                                            AND SBQQ__Account__c =: account]){
            consiguio = true;
            precioContractPrice = listContractedPrice.SBQQ__Price__c;
            unidadMedidaTemp = listContractedPrice.POCH_UnidadMedidaEscala__c;
            if (unidadMedida == listContractedPrice.POCH_UnidadMedidaEscala__c){
                precio = listContractedPrice.SBQQ__Price__c;
            }else{
                unidadMedidaEscalaContract = listContractedPrice.POCH_UnidadMedidaEscala__c;
                
            }                                                                 
        }
        if (consiguio){
            if (unidadMedida != unidadMedidaTemp){
                for (POCH_UnidadMedidaProducto__c umP : [SELECT 
                                                                Id,
                                                                POCH_FactorConversion__c  
                                                            FROM POCH_UnidadMedidaProducto__c 
                                                            WHERE POCH_Producto__c =: product
                                                            AND POCH_UMA__c =: unidadMedidaEscalaContract]){
                    factorConversionA = umP.POCH_FactorConversion__c;
                }
                for (POCH_UnidadMedidaProducto__c umP : [SELECT 
                                                            Id,
                                                            POCH_FactorConversion__c  
                                                        FROM POCH_UnidadMedidaProducto__c 
                                                        WHERE POCH_Producto__c =: product
                                                        AND POCH_UMA__c =: unidadMedida]){
                    factorConversionB = umP.POCH_FactorConversion__c;
                }
                if (unidadMedidaEscalaContract != unidadMedida){              
                    Double auxFactores = factorConversionA / factorConversionB;
                    precio = precioContractPrice / auxFactores;
                }
            }
        }else{
            for(PricebookEntry pbe : [SELECT 
                                            Id,
                                            POCH_UnidadMedidaEscala__c,
                                            Unidad_de_medida__c,
                                            CurrencyIsoCode //devolver y sustituir currency 
                                        FROM PricebookEntry 
                                        WHERE Product2Id =: product
                                        AND POCH_OrganizacionVentas__c =: organizacionVenta 
                                        AND IsActive = true ]){
                unidadMedidaEscala = pbe.POCH_UnidadMedidaEscala__c;
                unidadMedidaPricebook = pbe.Unidad_de_medida__c ;
            }
            for (POCH_UnidadMedidaProducto__c umP : [SELECT 
                                                            Id,
                                                            POCH_FactorConversion__c  
                                                        FROM POCH_UnidadMedidaProducto__c 
                                                        WHERE POCH_Producto__c =: product
                                                        AND POCH_UMA__c =: unidadMedidaEscala]){
                factorConversionA = umP.POCH_FactorConversion__c;
            }

            for (POCH_UnidadMedidaProducto__c umP : [SELECT 
                                                        Id,
                                                        POCH_FactorConversion__c  
                                                    FROM POCH_UnidadMedidaProducto__c 
                                                    WHERE POCH_Producto__c =: product
                                                    AND POCH_UMA__c =: unidadMedidaPricebook]){
                factorConversionACantidad = umP.POCH_FactorConversion__c;
            }
            for (POCH_UnidadMedidaProducto__c umP : [SELECT 
                                                        Id,
                                                        POCH_FactorConversion__c  
                                                    FROM POCH_UnidadMedidaProducto__c 
                                                    WHERE POCH_Producto__c =: product
                                                    AND POCH_UMA__c =: unidadMedida]){
                factorConversionB = umP.POCH_FactorConversion__c;
            }
            if (unidadMedidaPricebook != unidadMedida){              
                    Double auxFactores = factorConversionACantidad / factorConversionB;
                    cantidadConvertida = cantidad / auxFactores;
                }
                
            }
            for (SBQQ__DiscountSchedule__c ds : [SELECT
                                                    Id, 
                                                    POCH_CantidadMinima__c
                                                FROM SBQQ__DiscountSchedule__c 
                                                WHERE SBQQ__Product__c =: product
                                                AND ScheduleIdExterno__c =: organizacionVenta]){
                cantidadMinima = ds.POCH_CantidadMinima__c;
                for (SBQQ__DiscountTier__c dt : [SELECT
                                                    Id,
                                                    SBQQ__LowerBound__c,
                                                    SBQQ__UpperBound__c,
                                                    POCH_ImporteCondicion__c,
                                                    SBQQ__Schedule__r.SBQQ__Product__c,
                                                    SBQQ__Number__c 
                                                FROM SBQQ__DiscountTier__c 
                                                WHERE SBQQ__Schedule__c =: ds.Id]){ 
                    if (unidadMedidaPricebook != unidadMedida){
                        /*if (cantidadMinima > cantidadConvertida){
                            precio = -1;
                        }else{*/
                            if (cantidadConvertida >= dt.SBQQ__LowerBound__c && cantidadConvertida < dt.SBQQ__UpperBound__c){
                                precio = dt.POCH_ImporteCondicion__c;
                                precioCantidadConvertido = true;
                            }
                            if (dt.SBQQ__UpperBound__c == null && cantidadConvertida >= dt.SBQQ__LowerBound__c){
                                precio = dt.POCH_ImporteCondicion__c;
                                precioCantidadConvertido = true;
                            }
                        //}                                  
                    }else{
                        /*if (cantidadMinima > cantidad){
                            precio = -1; 
                        }else{*/
                            if (cantidad >= dt.SBQQ__LowerBound__c && cantidad < dt.SBQQ__UpperBound__c){
                                precio = dt.POCH_ImporteCondicion__c;
                                tengoPrecio = true;
                            }
                            if (dt.SBQQ__UpperBound__c == null && cantidad >= dt.SBQQ__LowerBound__c){
                                precio = dt.POCH_ImporteCondicion__c;
                                tengoPrecio = true;
                            }
                        //}    
                    }
                }
            }

            if (unidadMedidaEscala != unidadMedida){
                if (tengoPrecio){                
                    Double auxFactores = factorConversionA / factorConversionB;
                    precio = precio / auxFactores;
                }
                
            }
            if (unidadMedidaPricebook != unidadMedida){
                if (precioCantidadConvertido){                
                    Double auxFactores = factorConversionACantidad / factorConversionB;
                    precio = precio / auxFactores;
                }
                
            }
        return precio;
    }

    /**
    Metodo para calcular el margen 
    */
    @AuraEnabled        
    public static Double getMargen(Id product, String unidadMedida, Boolean notIsApiField, String objectType, String selectedField,
                    Double precio, Double porcentajeDescuento, String centro, String selectedField2, String moneda, String selectedField3) {
        Double margen = 0.0;
        DOUBLE factorConversionA = 0.0;
        DOUBLE factorConversionB = 0.0;
        DOUBLE precioAuxiliar = 0.0;
        DOUBLE descuentoAux = 0.0;
        DOUBLE tipoCambio = 0.0;
        DOUBLE tipoCambio2 = 0.0;

        if (notIsApiField){
            unidadMedida = getApiName(objectType, selectedField, unidadMedida);
            centro = getApiName(objectType, selectedField2, centro);
            //moneda = getApiName(objectType, selectedField3, moneda);
        }
        System.debug('print centro: ' + centro);
        System.debug('print moneda: ' + moneda);
        
        for (Product2 pr : [SELECT Id, QuantityUnitOfMeasure FROM Product2 WHERE Id =: product]){
            for (POCH_UnidadMedidaProducto__c umP : [SELECT 
                                                    Id,
                                                    POCH_FactorConversion__c  
                                                FROM POCH_UnidadMedidaProducto__c 
                                                WHERE POCH_Producto__c =: product
                                                AND POCH_UMA__c =: unidadMedida]){
                System.debug('print POCH_UnidadMedidaProducto__c: ' + umP.POCH_FactorConversion__c );
                factorConversionA = umP.POCH_FactorConversion__c;
            }
            System.debug('print porcentajeDescuento: ' + porcentajeDescuento );
            System.debug('print precio: ' + precio );
            
            if (porcentajeDescuento > 0){// Verificar que no llegue null
                descuentoAux = (precio * porcentajeDescuento) / 100;
            }
            precio = precio - descuentoAux;
            precioAuxiliar = precio / factorConversionA;
            System.debug('print precioAuxiliar: ' + precioAuxiliar + ' => precio ' + precio + ' * factorConversionA -> ' +factorConversionA);
            // buscamos valoracionProducto
            for (POCH_ValoracionProducto__c vp : [SELECT 
                                                    Id,
                                                    POCH_CostoFactInterna__c,
                                                    CurrencyIsoCode  
                                                FROM POCH_ValoracionProducto__c 
                                                WHERE POCH_Producto__c =: product 
                                                AND POCH_AreaValoracion__c =: centro]){
                System.debug('print (moneda ' + moneda + ' = ' + vp.CurrencyIsoCode + ' vp.POCH_CostoFactInterna__c -> ' + vp.POCH_CostoFactInterna__c);
                if (moneda == vp.CurrencyIsoCode){
                    margen = ((precioAuxiliar - vp.POCH_CostoFactInterna__c) / precioAuxiliar) * 100;
                }else{
                    List<String> listRates = getRates();
                    for (String rate : listRates) {
                        //listRates[i].substr(0,3) ISOCODE
                        //listRates[i].substr(3) RATE
                        System.debug('print rate ' + rate.substring(0,3));
                        if (moneda == rate.substring(0,3)){
                            tipoCambio = decimal.valueOf(rate.substring(3));     
                        } 
                        if (vp.CurrencyIsoCode == rate.substring(0,3)){
                            tipoCambio2 = decimal.valueOf(rate.substring(3));
                            //precioAuxiliar = (precioAuxiliar / rate.substr(3) / );   
                        }           
                    }
                    System.debug('print precioAuxiliar ' + precioAuxiliar); 
                    precioAuxiliar = (precioAuxiliar / tipoCambio) / tipoCambio2 ; 
                    margen = ((precioAuxiliar - vp.POCH_CostoFactInterna__c) / precioAuxiliar) * 100;
                    System.debug('print margen : ' + margen );
                }                                        
            }
        }
        return margen;
    }
}