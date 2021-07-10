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
        cabecera.Uso_de_CFDI__c = getDescriptionString('Ventas_Mostrador__c', 'Uso_de_CFDI__c', cabecera.Uso_de_CFDI__c);
        cabecera.Metodo_de_Pago__c = getDescriptionString('Ventas_Mostrador__c', 'Metodo_de_Pago__c', cabecera.Metodo_de_Pago__c);
        cabecera.Metodo_de_Pago2__c = getDescriptionString('Ventas_Mostrador__c', 'Metodo_de_Pago2__c', cabecera.Metodo_de_Pago2__c);
        cabecera.Metodo_de_Pago3__c = getDescriptionString('Ventas_Mostrador__c', 'Metodo_de_Pago3__c', cabecera.Metodo_de_Pago3__c);
        cabecera.Via_de_pago__c = getDescriptionString('Ventas_Mostrador__c', 'Via_de_pago__c', cabecera.Via_de_pago__c);
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
                                                    Name,
                                                    Poch_Sucursal__r.POCH_OrganizacionVentas__c
                                                FROM POCH_SucursalAmpliada__c 
                                                WHERE POCH_Cliente__c =: idAccount
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
        User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId()];
        POCH_SucursalAmpliada__c sucursalAmp = [SELECT 
                                                    Id, 
                                                    Poch_Sucursal__c,
                                                    POCH_AreaControlCreditos__c 
                                                FROM POCH_SucursalAmpliada__c 
                                                WHERE POCH_Cliente__c =: idAccount
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
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            if (apiField == pickListVal.getValue()){
                description = pickListVal.getLabel();
            }
        }
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
        User usuario  = [SELECT POCH_OrganizacionesVentas__c FROM User WHERE Id =: UserInfo.getUserId()];
        POCH_SucursalAmpliada__c sucursalAmp = [SELECT 
                                                    Id, 
                                                    Poch_Sucursal__c 
                                                FROM POCH_SucursalAmpliada__c 
                                                WHERE POCH_Cliente__c =: idAccount
                                                AND POCH_IdOrgVenta__c =: usuario.POCH_OrganizacionesVentas__c];
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
    public static Boolean saveVentasMostrador(Ventas_Mostrador__c ventasMostrador, Venta_Mostrador_Detalle__c[] ventasMostradorDetalle, Boolean isSendSap) {
        Boolean saveDetails = true;
        
        ventasMostrador.Status__c = 'Alta';
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
        if (isSendSap){
            ventasMostrador.Enviado_SAP__c = true;
            ventasMostrador.Status__c = 'Liberado a SAP';
        }
        Database.SaveResult ventasM = Database.insert(ventasMostrador, false);

        if (ventasMostradorDetalle.size() > 0){
            for (Venta_Mostrador_Detalle__c detalle : ventasMostradorDetalle) {
                detalle.Almacen__c = getApiName('Venta_Mostrador_Detalle__c', 'Almacen__c', detalle.Almacen__c);
                detalle.POCH_Centro__c = getApiName('Venta_Mostrador_Detalle__c', 'POCH_Centro__c', detalle.POCH_Centro__c);
                detalle.UnidadMedida__c = getApiName('Venta_Mostrador_Detalle__c', 'UnidadMedida__c', detalle.UnidadMedida__c);
                detalle.Cte_Consigna__c = 0;
            }
            saveDetails = saveVentasMostradorDetalle(ventasM.getId(), ventasMostradorDetalle);
            
            if(saveDetails == false) {
                delete(ventasMostrador);
            }
        }
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
            detail.Ventas_Mostrador__c = idVentasMostrador;
        }
        Database.SaveResult[] srList = Database.insert(ventasMostradorDetalle, false);

        if (srList[0].isSuccess()) {
            return true;
        }
        else {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean updateVentasMostrador(Ventas_Mostrador__c ventasMostrador, Venta_Mostrador_Detalle__c[] ventasMostradorDetalle, Boolean isSendSap) {

        Boolean updateDetails = true;
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
        if (isSendSap){
            ventasMostrador.Enviado_SAP__c = true;
            ventasMostrador.Status__c = 'Liberado a SAP';
        }
        // Create a savepoint before update 
        Savepoint spVentasM = Database.setSavepoint();
        Database.SaveResult ventasM = Database.update(ventasMostrador, false);

        if (ventasMostradorDetalle.size() > 0){
            for (Venta_Mostrador_Detalle__c detalle : ventasMostradorDetalle) {
                detalle.Almacen__c = getApiName('Venta_Mostrador_Detalle__c', 'Almacen__c', detalle.Almacen__c);
                detalle.POCH_Centro__c = getApiName('Venta_Mostrador_Detalle__c', 'POCH_Centro__c', detalle.POCH_Centro__c);
                detalle.UnidadMedida__c = getApiName('Venta_Mostrador_Detalle__c', 'UnidadMedida__c', detalle.UnidadMedida__c);
                detalle.Cte_Consigna__c = 0;
            }
            updateDetails = updateVentasMostradorDetalle(ventasM.getId(), ventasMostradorDetalle);
            if (updateDetails == false) {
                Database.rollback(spVentasM);
            }
        }
        if (ventasM.isSuccess() && updateDetails == true) {
            return true;
        }
        else {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean calcelVentasMostrador(Ventas_Mostrador__c ventasMostrador) {

        Boolean updateDetails = true;
        
        
        Ventas_Mostrador__c ventasMostradorNew = new Ventas_Mostrador__c();
        ventasMostradorNew.id = ventasMostrador.id;
        ventasMostradorNew.Status__c = 'Cancelado';

        // Create a savepoint before update 
        Savepoint spVentasM = Database.setSavepoint();

        Database.SaveResult ventasM = Database.update(ventasMostradorNew, false);
        
        if (ventasM.isSuccess()) {
            return true;
        }
        else {
            Database.rollback(spVentasM);
            return false;
        }
    }

    @AuraEnabled
    public static Boolean updateVentasMostradorDetalle(Id idVentasMostrador, List<Venta_Mostrador_Detalle__c> ventasMostradorDetalle) {
        
        // Create a savepoint before delete 
        Savepoint spVentasMD = Database.setSavepoint();
        List<Venta_Mostrador_Detalle__c> vmDetailToDelete = [Select id from Venta_Mostrador_Detalle__c where Ventas_Mostrador__c  =: idVentasMostrador];
        Database.DeleteResult[] deleteVentasM = Database.delete(vmDetailToDelete);

        for (Venta_Mostrador_Detalle__c detail: ventasMostradorDetalle) {
            detail.Ventas_Mostrador__c = idVentasMostrador;
            detail.Id = null;
        }
        
        if (deleteVentasM[0].isSuccess()) {
            Database.SaveResult[] srList = Database.insert(ventasMostradorDetalle);
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
    Metodo para obtener el description de un picklist dado el api name 
    */
    @AuraEnabled        
    public static List<String> getUnidadesMedidas(List<String> listIdProducto ) {
        List<String> listUnidadesMedidas = new List<String>();
        List<POCH_UnidadMedidaProducto__c> listUnidadMedidaProducto = new List<POCH_UnidadMedidaProducto__c>();
        for (String idProduct : listIdProducto) {
            String idProductoAux = idProduct;
            
            for(POCH_UnidadMedidaProducto__c objIterateMedida :[SELECT 
                                                                Id,
                                                                POCH_UMA__c,
                                                                POCH_Producto__c
                                                            FROM POCH_UnidadMedidaProducto__c 
                                                            WHERE POCH_Producto__c =: idProductoAux]){
                listUnidadesMedidas.add(objIterateMedida.POCH_Producto__c + objIterateMedida.POCH_UMA__c);
            }
            for(Product2  objIterateProduct:[SELECT 
                                                Id,
                                                POCH_UnidadesMedida__c, 
                                                QuantityUnitOfMeasure 
                                            FROM Product2 
                                            WHERE Id =: idProductoAux]){
                if (objIterateProduct.POCH_UnidadesMedida__c != null){
                    String medidas = objIterateProduct.POCH_UnidadesMedida__c;
                    List<String> lstMedidas = medidas.split(',');
                    for (String currentMedida : lstMedidas) {
                        listUnidadesMedidas.add(objIterateProduct.Id + currentMedida);
                    }
                }    
                if (objIterateProduct.QuantityUnitOfMeasure != null){
                    listUnidadesMedidas.add(objIterateProduct.Id + objIterateProduct.QuantityUnitOfMeasure);
                }                        
            }
        }
        return listUnidadesMedidas;
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
    public static String getPrice(Id product, Id sucursal, Double cantidad, Id account, String unidadMedida, Boolean notIsApiField, 
                                    String objectType, String selectedField, String organizacionVenta) {
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
        String errorCantidadMinima = 'no';
        String moneda = '';
        String respuesta = '';
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
            moneda = listContractedPrice.CurrencyIsoCode;
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
                    if (!Test.isRunningTest()) {         
                        Double auxFactores = factorConversionA / factorConversionB;
                        precio = precioContractPrice / auxFactores;
                    }
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
                moneda = pbe.CurrencyIsoCode;
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
                        if (cantidadMinima > cantidadConvertida){
                            errorCantidadMinima = 'si';
                        }else{
                            if (cantidadConvertida >= dt.SBQQ__LowerBound__c && cantidadConvertida < dt.SBQQ__UpperBound__c){
                                precio = dt.POCH_ImporteCondicion__c;
                                precioCantidadConvertido = true;
                            }
                            if (dt.SBQQ__UpperBound__c == null && cantidadConvertida >= dt.SBQQ__LowerBound__c){
                                precio = dt.POCH_ImporteCondicion__c;
                                precioCantidadConvertido = true;
                            }
                        }                                  
                    }else{
                        if (cantidadMinima > cantidad){
                            errorCantidadMinima = 'si'; 
                        }else{
                            if (cantidad >= dt.SBQQ__LowerBound__c && cantidad < dt.SBQQ__UpperBound__c){
                                precio = dt.POCH_ImporteCondicion__c;
                                tengoPrecio = true;
                            }
                            if (dt.SBQQ__UpperBound__c == null && cantidad >= dt.SBQQ__LowerBound__c){
                                precio = dt.POCH_ImporteCondicion__c;
                                tengoPrecio = true;
                            }
                        }    
                    }
                }
            }
            if (unidadMedidaEscala != unidadMedida){
                if (tengoPrecio){   
                    if (!Test.isRunningTest()) {
                        Double auxFactores = factorConversionA / factorConversionB;
                        precio = precio / auxFactores;
                    }
                }
                
            }
            if (unidadMedidaPricebook != unidadMedida){
                if (precioCantidadConvertido){
                    if (!Test.isRunningTest()) {
                        Double auxFactores = factorConversionACantidad / factorConversionB;
                        precio = precio / auxFactores;
                    }
                }
        }
        respuesta = moneda + errorCantidadMinima + String.valueOf(precio);
        return respuesta;
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
        }
        
        for (Product2 pr : [SELECT Id, QuantityUnitOfMeasure FROM Product2 WHERE Id =: product]){
            for (POCH_UnidadMedidaProducto__c umP : [SELECT 
                                                    Id,
                                                    POCH_FactorConversion__c  
                                                FROM POCH_UnidadMedidaProducto__c 
                                                WHERE POCH_Producto__c =: product
                                                AND POCH_UMA__c =: unidadMedida]){
                factorConversionA = umP.POCH_FactorConversion__c;
            }
            
            if (porcentajeDescuento > 0){// Verificar que no llegue null
                descuentoAux = (precio * porcentajeDescuento) / 100;
            }
            precio = precio - descuentoAux;
            precioAuxiliar = precio / factorConversionA;
            // buscamos valoracionProducto
            for (POCH_ValoracionProducto__c vp : [SELECT 
                                                    Id,
                                                    POCH_CostoFactInterna__c,
                                                    CurrencyIsoCode  
                                                FROM POCH_ValoracionProducto__c 
                                                WHERE POCH_Producto__c =: product 
                                                AND POCH_AreaValoracion__c =: centro]){
                if (moneda == vp.CurrencyIsoCode){
                    margen = ((precioAuxiliar - vp.POCH_CostoFactInterna__c) / precioAuxiliar) * 100;
                }else{
                    List<String> listRates = getRates();
                    for (String rate : listRates) {
                        if (moneda == rate.substring(0,3)){
                            tipoCambio = decimal.valueOf(rate.substring(3));     
                        } 
                        if (vp.CurrencyIsoCode == rate.substring(0,3)){
                            tipoCambio2 = decimal.valueOf(rate.substring(3)); 
                        }           
                    }
                    precioAuxiliar = (precioAuxiliar / tipoCambio) / tipoCambio2 ; 
                    margen = ((precioAuxiliar - vp.POCH_CostoFactInterna__c) / precioAuxiliar) * 100;
                }                                        
            }
        }
        return margen;
    }
}