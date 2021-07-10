@isTest
public class POCH_VentaMostrador_cls_test {
    
    static Ventas_Mostrador__c insertVentasMostrador(){
        Account acc = POCH_DataCreationTest.getAccount();
        Ventas_Mostrador__c vm = new Ventas_Mostrador__c(
            Cliente__c = acc.id,
            CurrencyIsoCode = 'MXN',
            Email__c = 'ventas3@conjuntolar.com',
            Credito_disponible__c = 303597.8,
            Digitos_tarjeta__c = null,
            Via_de_pago__c = '7',
            Condicion_de_Pago__c = 'Prepaid',
            Metodo_de_Pago__c = '003',
            Metodo_de_Pago2__c = '004',
            Metodo_de_Pago3__c = null,
            Importe__c = 174.87,
            Importe_2__c = 174.88,
            Importe_3__c = 0,
            Obs_Pago__c = null,
            Obs_Pago_2__c = null,
            Obs_Pago_3__c = null,
            Valor_Neto__c = 301.51,
            Descuento__c = 0,
            Subtotal__c = 301.51,
            IVA__c = 48.24,
            Precio_total__c = 349.75,
            Id_Registro_SAP__c = null,
            Status__c = 'Liberado a SAP',
            POCH_Sucursal__c = 'a1K4P00000LdvrtUAB',
            Uso_de_CFDI__c = 'G01',
            Enviado_SAP__c = false,
            OrganizacionVentas__c = '0168'
        );
        insert(vm);
        return vm;
    }

    static Venta_Mostrador_Detalle__c insertVentasMostradorDetalle(String idVM){
        Venta_Mostrador_Detalle__c vmd = new Venta_Mostrador_Detalle__c(
            CurrencyIsoCode = 'USD',
            Material__c = '57589',
            Descto__c = 0,
            Precio__c = 15.13,
            Descripcion__c = 'MANTISOFT 200 TAMBOR 220 KG',
            POCH_Cantidad__c = 1,
            UnidadMedida__c = 'Kg',
            Sucursal__c = 'a1K4P00000LdvrtUAB',
            Product__c = '01t4P00000AZZmTQAX',
            IVA__c = 48.24,
            Descuento_Monto__c = 0,
            Oficina_de_Venta__c = '9706',
            POCH_Centro__c = 'CLTL',
            Almacen__c = null,
            Stock__c = 0,
            Stock_Consignacion__c = 0,
            Valor_neto__c = 301.51,
            Margen__c = 1.2,
            Ventas_Mostrador__c = idVM
            );
        insert(vmd);
        return vmd;
    }

    @isTest
    public static void testgetCabeceraVentaMostrador() {
        
        Test.startTest();
        Ventas_Mostrador__c vm = insertVentasMostrador();
        Ventas_Mostrador__c vmTest = POCH_VentaMostrador_cls.getCabeceraVentaMostrador(vm.Id);
        Test.stopTest();
        system.assert(vmTest != null);
    }
    
    @isTest
    public static void testgetDetailsVentaMostrador() {
        
        Test.startTest();
        Ventas_Mostrador__c vm = insertVentasMostrador();
        Venta_Mostrador_Detalle__c vmd = insertVentasMostradorDetalle(vm.Id);
        List<Venta_Mostrador_Detalle__c> vmdTest = POCH_VentaMostrador_cls.getDetailsVentaMostrador(vm.Id);
        Test.stopTest();
        system.assert(vmdTest.size() != 0);
    }

    @isTest
    public static void testgetDataInv() {
        
        Test.startTest();
        Ventas_Mostrador__c vm = insertVentasMostrador();
        Ventas_Mostrador__c vmTest = POCH_VentaMostrador_cls.getDataInv(vm.Id);
        Test.stopTest();
        system.assert(vmTest != null);
    }

    @isTest
    public static void testgetStocks() {
        
        Test.startTest();
        POCH_DetalleInventario__c detInv = POCH_DataCreationTest.getDetalleInventario();
        insert detInv;
        List<POCH_DetalleInventario__c> detInvTest = POCH_VentaMostrador_cls.getStocks('');
        Test.stopTest();
        system.assert(detInvTest.size() != 0);
    }

    @isTest
    public static void testPickListValuesIntoList() {
        
        Test.startTest();
        List<String> pickListValuesList = POCH_VentaMostrador_cls.PickListValuesIntoList('Ventas_Mostrador__c', 'Via_de_pago__c');
        Test.stopTest();
        system.assert(pickListValuesList.size() != 0);
    }

    @isTest
    public static void testgetSucursal() {
        
        Test.startTest();

        Profile p = [SELECT Id FROM Profile WHERE Name='POCH-Ventas Mostrador'];
        User user = POCH_DataCreationTest.getUser();
        user.ProfileId = p.Id;
        user.POCH_OrganizacionesVentas__c = '0049';
        insert user;

        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal2();
        suc.POCH_OrganizacionVentas__c = '0049';
        insert suc;
        
        Account acc = POCH_DataCreationTest.getAccountIdSAPCLiente();
        acc.POCH_Sucursal__c = suc.Id;
        acc.POCH_Region__c = reg.Id;
        
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get('POCH_GrupoVendedores__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
        }
        insert acc;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;

        Poch_Sucursal__c psTest = new Poch_Sucursal__c();
        System.runAs(user) {
            psTest = POCH_VentaMostrador_cls.getSucursal(acc.Id);
        }
        Test.stopTest();
        system.assert(psTest != null);
    }


    @isTest
    public static void testgetAccount() {
        
        Test.startTest();
        
        Account acc = POCH_DataCreationTest.getAccount();
        insert acc;
        
        Account accTest = POCH_VentaMostrador_cls.getAccount(acc.Id);
        Test.stopTest();
        system.assert(accTest != null);
    }

    @isTest
    public static void testgetCreditLine() {
        
        Test.startTest();
        POCH_InformacionCredito__c infoCredTest = new POCH_InformacionCredito__c();
        Profile p = [SELECT Id FROM Profile WHERE Name='POCH-Ventas Mostrador']; 
        User u = new User(Alias = 'standt', Email='testuserp@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuserp@testorg.com',
            POCH_OrganizacionesVentas__c = '0029'
        );
        
        Account acc = POCH_DataCreationTest.getAccount();
        insert acc;
        
        Poch_Sucursal__c sucursal = POCH_DataCreationTest.getSucursal();
        sucursal.POCH_OrganizacionVentas__c = '0029';
        insert sucursal;
        
        POCH_SucursalAmpliada__c sucursalAmp = POCH_DataCreationTest.getSucursalAmp();
        sucursalAmp.POCH_Cliente__c = acc.id;
        sucursalAmp.Poch_Sucursal__c = sucursal.id;
        sucursalAmp.POCH_AreaControlCreditos__c = '410';
        insert sucursalAmp;

        POCH_InformacionCredito__c infoCred = new POCH_InformacionCredito__c();
        infoCred.POCH_LineaCredito__c  = 10000;
        infoCred.POCH_SaldoActual__c  = 1000;
        infoCred.POCH_AreaControlCredito__c  = '410';
        infoCred.POCH_Cliente__c  = acc.id;
        // infoCred.POCH_AreaControlCreditos__c = '410';
        insert infoCred;
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            infoCredTest = POCH_VentaMostrador_cls.getCreditLine(acc.Id);
        }
        Test.stopTest();
        system.assert(infoCredTest != null);
    }

    @isTest
    public static void testgetConditionPago() {
        
        Test.startTest();
        String conditionPagoTest = '';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='testuserp@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuserp@testorg.com',
            POCH_OrganizacionesVentas__c = '0029'
        );
        
        Account acc = POCH_DataCreationTest.getAccount();
        insert acc;
        
        Poch_Sucursal__c sucursal = POCH_DataCreationTest.getSucursal();
        sucursal.POCH_OrganizacionVentas__c = '0029';
        insert sucursal;
        
        POCH_SucursalAmpliada__c sucursalAmp = POCH_DataCreationTest.getSucursalAmp();
        sucursalAmp.POCH_Cliente__c = acc.id;
        sucursalAmp.Poch_Sucursal__c = sucursal.id;
        sucursalAmp.POCH_AreaControlCreditos__c = '410';
        insert sucursalAmp;
        
        
        System.runAs(u) {
            // The following code runs as user 'u'
            conditionPagoTest = POCH_VentaMostrador_cls.getConditionPago(acc.Id);
        }
        Test.stopTest();
        system.assert(conditionPagoTest != null);
    }


    @isTest
    public static void testgetApiName() {
        
        Test.startTest();
        String apiNameTest = POCH_VentaMostrador_cls.getApiName('Ventas_Mostrador__c', 'CurrencyIsoCode', 'U.S. Dollar');
        Test.stopTest();
        system.assert(apiNameTest != null);
    }

    @isTest
    public static void testgetDescription() {
        
        Test.startTest();
        List<String> listDescriptionTest = new List<String>();
        List<String> values = new List<String>();
        values.add('MXN');
        listDescriptionTest = POCH_VentaMostrador_cls.getDescription('Ventas_Mostrador__c', 'CurrencyIsoCode', values);
        Test.stopTest();
        system.assert(listDescriptionTest.size() != 0);
    }

    
    @isTest
    public static void testvalidarCurrency() {
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='POCH-Ventas Mostrador'];
        User user = POCH_DataCreationTest.getUser();
        user.ProfileId = p.Id;
        user.POCH_OrganizacionesVentas__c = '0049';
        insert user;

        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal2();
        suc.POCH_OrganizacionVentas__c = '0049';
        insert suc;
        
        Account acc = POCH_DataCreationTest.getAccountIdSAPCLiente();
        acc.POCH_Sucursal__c = suc.Id;
        acc.POCH_Region__c = reg.Id;
        
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get('POCH_GrupoVendedores__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
        }
        insert acc;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;

        Boolean currencyCorrectTest = false;
        System.runAs(user) {
            currencyCorrectTest = POCH_VentaMostrador_cls.validarCurrency(acc.id, 'Brazilian Real', true, 'Ventas_Mostrador__c', 'CurrencyIsoCode');
        }
        Test.stopTest();
        system.assert(currencyCorrectTest == true);
    }

    // getRates
    @isTest
    public static void testgetRates() {
        
        Test.startTest();
        List<String> listDescriptionTest = new List<String>();
        listDescriptionTest = POCH_VentaMostrador_cls.getRates();
        Test.stopTest();
        system.assert(listDescriptionTest.size() != 0);
    }

    @isTest
    public static void testsaveVentasMostrador() {
        
        Test.startTest();
        Boolean saveDetailsTest = false;

        Poch_Sucursal__c sucursal = POCH_DataCreationTest.getSucursal();
        insert sucursal;


        Account acc = POCH_DataCreationTest.getAccount();
        Ventas_Mostrador__c vm = new Ventas_Mostrador__c(
            Cliente__c = acc.id,
            CurrencyIsoCode = 'MXN',
            Email__c = 'ventas3@conjuntolar.com',
            Credito_disponible__c = 303597.8,
            Digitos_tarjeta__c = null,
            Via_de_pago__c = '7',
            Condicion_de_Pago__c = 'Prepaid',
            Metodo_de_Pago__c = '003',
            Metodo_de_Pago2__c = '004',
            Metodo_de_Pago3__c = '004',
            Importe__c = 174.87,
            Importe_2__c = 174.88,
            Importe_3__c = 0,
            Obs_Pago__c = null,
            Obs_Pago_2__c = null,
            Obs_Pago_3__c = null,
            Valor_Neto__c = 301.51,
            Descuento__c = 0,
            Subtotal__c = 301.51,
            IVA__c = 48.24,
            Precio_total__c = 349.75,
            Id_Registro_SAP__c = null,
            Status__c = 'Liberado a SAP',
            POCH_Sucursal__c = 'a1K4P00000LdvrtUAB',
            Uso_de_CFDI__c = 'G01',
            Enviado_SAP__c = false,
            OrganizacionVentas__c = '0168'
        );

        List<Venta_Mostrador_Detalle__c> vmd = new List<Venta_Mostrador_Detalle__c>();
        Venta_Mostrador_Detalle__c vmd1 = new Venta_Mostrador_Detalle__c(
            CurrencyIsoCode = 'USD',
            Material__c = '57589',
            Descto__c = 0,
            Precio__c = 15.13,
            Descripcion__c = 'MANTISOFT 200 TAMBOR 220 KG',
            POCH_Cantidad__c = 1,
            UnidadMedida__c = 'Kg',
            Sucursal__c = 'a1K4P00000LdvrtUAB',
            Product__c = '01t4P00000AZZmTQAX',
            IVA__c = 48.24,
            Descuento_Monto__c = 0,
            Oficina_de_Venta__c = '9706',
            POCH_Centro__c = 'CLTL',
            Almacen__c = null,
            Stock__c = 0,
            Stock_Consignacion__c = 0,
            Valor_neto__c = 301.51,
            Margen__c = 1.2
        );

        vmd.add(vmd1);

        saveDetailsTest = POCH_VentaMostrador_cls.saveVentasMostrador(vm, vmd, true);
        Test.stopTest();
        system.assert(saveDetailsTest == true);
    }

    @isTest
    public static void testupdateVentasMostrador() {
        
        Test.startTest();
        Boolean saveDetailsTest = false;

        Poch_Sucursal__c sucursal = POCH_DataCreationTest.getSucursal();
        insert sucursal;


        Account acc = POCH_DataCreationTest.getAccount();
        Ventas_Mostrador__c vm = new Ventas_Mostrador__c(
            Cliente__c = acc.id,
            CurrencyIsoCode = 'MXN',
            Email__c = 'ventas3@conjuntolar.com',
            Credito_disponible__c = 303597.8,
            Digitos_tarjeta__c = null,
            Via_de_pago__c = '7',
            Condicion_de_Pago__c = 'Prepaid',
            Metodo_de_Pago__c = '003',
            Metodo_de_Pago2__c = '004',
            Metodo_de_Pago3__c = '004',
            Importe__c = 174.87,
            Importe_2__c = 174.88,
            Importe_3__c = 0,
            Obs_Pago__c = null,
            Obs_Pago_2__c = null,
            Obs_Pago_3__c = null,
            Valor_Neto__c = 301.51,
            Descuento__c = 0,
            Subtotal__c = 301.51,
            IVA__c = 48.24,
            Precio_total__c = 349.75,
            Id_Registro_SAP__c = null,
            Status__c = 'Liberado a SAP',
            POCH_Sucursal__c = 'a1K4P00000LdvrtUAB',
            Uso_de_CFDI__c = 'G01',
            Enviado_SAP__c = false,
            OrganizacionVentas__c = '0168'
        );
        insert vm;

        List<Venta_Mostrador_Detalle__c> vmd = new List<Venta_Mostrador_Detalle__c>();
        Venta_Mostrador_Detalle__c vmd1 = new Venta_Mostrador_Detalle__c(
            CurrencyIsoCode = 'USD',
            Material__c = '57589',
            Descto__c = 0,
            Precio__c = 15.13,
            Descripcion__c = 'MANTISOFT 200 TAMBOR 220 KG',
            POCH_Cantidad__c = 1,
            UnidadMedida__c = 'Kg',
            Sucursal__c = 'a1K4P00000LdvrtUAB',
            Product__c = '01t4P00000AZZmTQAX',
            IVA__c = 48.24,
            Descuento_Monto__c = 0,
            Oficina_de_Venta__c = '9706',
            POCH_Centro__c = 'CLTL',
            Almacen__c = null,
            Stock__c = 0,
            Stock_Consignacion__c = 0,
            Valor_neto__c = 301.51,
            Margen__c = 1.2,
            Ventas_Mostrador__c = vm.id
        );
        insert vmd1;

        vmd.add(vmd1);

        saveDetailsTest = POCH_VentaMostrador_cls.updateVentasMostrador(vm, vmd, true);
        Test.stopTest();
        system.assert(saveDetailsTest == true);
    }

    @isTest
    public static void testcalcelVentasMostrador() {
        
        Test.startTest();
        Boolean cancelTest = false;

        Poch_Sucursal__c sucursal = POCH_DataCreationTest.getSucursal();
        insert sucursal;
        
        Account acc = POCH_DataCreationTest.getAccount();
        Ventas_Mostrador__c vm = new Ventas_Mostrador__c(
            Cliente__c = acc.id,
            CurrencyIsoCode = 'MXN',
            Email__c = 'ventas3@conjuntolar.com',
            Credito_disponible__c = 303597.8,
            Digitos_tarjeta__c = null,
            Via_de_pago__c = '7',
            Condicion_de_Pago__c = 'Prepaid',
            Metodo_de_Pago__c = '003',
            Metodo_de_Pago2__c = '004',
            Metodo_de_Pago3__c = '004',
            Importe__c = 174.87,
            Importe_2__c = 174.88,
            Importe_3__c = 0,
            Obs_Pago__c = null,
            Obs_Pago_2__c = null,
            Obs_Pago_3__c = null,
            Valor_Neto__c = 301.51,
            Descuento__c = 0,
            Subtotal__c = 301.51,
            IVA__c = 48.24,
            Precio_total__c = 349.75,
            Id_Registro_SAP__c = null,
            Status__c = 'Liberado a SAP',
            POCH_Sucursal__c = 'a1K4P00000LdvrtUAB',
            Uso_de_CFDI__c = 'G01',
            Enviado_SAP__c = false,
            OrganizacionVentas__c = '0168'
        );
        insert vm;

        cancelTest = POCH_VentaMostrador_cls.calcelVentasMostrador(vm);
        Test.stopTest();
        system.assert(cancelTest == true);
    }

    @isTest
    public static void testgetUnidadesMedidas() {
        
        Test.startTest();

        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal2();
        insert suc;
        
        Account acc = POCH_DataCreationTest.getAccountIdSAPCLiente();
        acc.POCH_Sucursal__c = suc.Id;
        acc.POCH_Region__c = reg.Id;
        
        
        
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get('POCH_GrupoVendedores__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
        }
       
        insert acc;
        
        Contact contact =  POCH_DataCreationTest.getContact();
        contact.AccountId = acc.Id;
        insert contact;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        
        Pricebook2 pb = POCH_DataCreationTest.getCustomPricebook();
        pb.POCH_Sucursal__c = suc.Id;
        insert pb;   
        
        Product2 prd = POCH_DataCreationTest.getProduct();
        prd.POCH_UnidadesMedida__c =  'KG';
        insert prd; 
        
        POCH_UnidadMedidaProducto__c um = POCH_DataCreationTest.getUM();
        um.POCH_Producto__c  = prd.Id;
        insert um;

        List<String> listIdProducto = new List<String>();
        listIdProducto.add(prd.id);

        List<String> psTest = new List<String>();

        psTest = POCH_VentaMostrador_cls.getUnidadesMedidas(listIdProducto);
        Test.stopTest();
        system.assert(psTest.size() != 0);
    }

    @isTest
    public static void testgetDependentPicklistValues() {
        
        Test.startTest();
        Ventas_Mostrador__c vm = insertVentasMostrador();

        List<String> psTest = new List<String>();
        psTest = POCH_VentaMostrador_cls.getDependentPicklistValues('Venta_Mostrador_Detalle__c', 'Oficina_de_Venta__c', 'POCH_Centro__c', '9706', true);
        Test.stopTest();
        system.assert(psTest.size() != 0);
    }

    @isTest
    public static void testgetIVA() {
        Test.startTest();

        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal();
        suc.POCH_ClasificacionFisca__c = '4';
        insert suc;

        Product2 prd = POCH_DataCreationTest.getProduct();
        prd.POCH_UnidadesMedida__c =  'KG';
        insert prd;

        POCH_ProductoSucursal__c ps  = POCH_DataCreationTest.getPS();
        ps.IMPUESTO_PRODUCTO__c = 10;
        ps.POCH_Producto__c = prd.id;
        ps.POCH_Sucursal__c = suc.id;
        ps.POCH_CanalDistribucion__c = '12';
        insert ps;
        
        
        Double psTest;
        psTest = POCH_VentaMostrador_cls.getIVA(prd.Id, suc.Id, 1000);
        Test.stopTest();
        system.assert(psTest == 100);
    }

    @isTest
    public static void testgetPrice() {
        Test.startTest();

        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;

        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal2();
        suc.POCH_ClasificacionFisca__c = '4';
        insert suc;
        
        Account acc = POCH_DataCreationTest.getAccountIdSAPCLiente();
        acc.POCH_Sucursal__c = suc.Id;
        acc.POCH_Region__c = reg.Id;
        
        
        
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get('POCH_GrupoVendedores__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
        }
       
        insert acc;
        
        Contact contact =  POCH_DataCreationTest.getContact();
        contact.AccountId = acc.Id;
        insert contact;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        
        Pricebook2 pb = POCH_DataCreationTest.getCustomPricebook();
        pb.POCH_Sucursal__c = suc.Id;
        insert pb;
        
        Product2 prd = POCH_DataCreationTest.getProduct();
        prd.POCH_UnidadesMedida__c =  'KG';
        prd.Family = 'PP_SBS';
        prd.Description ='amoniaco';
        prd.Name ='amoniaco';
        prd.IsActive  = true;
        prd.onlyInSalesforce__c = false;
        insert prd; 
        
        POCH_UnidadMedidaProducto__c um = POCH_DataCreationTest.getUM();
        um.POCH_Producto__c  = prd.Id;
        um.POCH_Numerador__c  = 10;
        insert um;

        PricebookEntry pbe  = new PricebookEntry();
        pbe.Product2Id         = prd.id;
        pbe.Pricebook2Id       =  pb.id;
        pbe.IsActive           = true;
        pbe.POCH_CanalDistribucion__c 	= '12';
        pbe.POCH_CantidadBase__c 		= 1;
        pbe.CurrencyIsoCode    =   'MXN';
        pbe.POCH_FinValidez__c 		= Date.today() + 30;
        pbe.POCH_IdExterno__c 			= 'IDEXTPBET';
        pbe.POCH_InicioValidez__c 		= Date.today() - 1;
        pbe.POCH_NoRegCondicion__c 	= '181114_C';
        pbe.POCH_OrganizacionVentas__c = '0049';
        pbe.Unidad_de_medida__c 		= 'KG';
        pbe.POCH_UnidadMedidaEscala__c = 'KG';
        pbe.UnitPrice          =   25.0;
        pbe.Grupo_de_Materiales__c    =   '';
        insert pbe;
        
        SBQQ__ContractedPrice__c contractedPrice = POCH_DataCreationTest.getPrecioEspecial();
        contractedPrice.POCH_UnidadMedidaEscala__c = 'KG';
        contractedPrice.POCH_UnidadMedida__c = 'KG';
        contractedPrice.POCH_Sucursal__c = suc.id;
        contractedPrice.SBQQ__Product__c = prd.id;
        contractedPrice.SBQQ__Account__c = acc.id;
        insert contractedPrice;

        SBQQ__DiscountSchedule__c ds = POCH_DataCreationTest.getDiscountSchedule();
        ds.SBQQ__Product__c = prd.id;
        ds.SBQQ__Pricebook__c = pb.id;
        insert ds;

        SBQQ__DiscountTier__c dt = POCH_DataCreationTest.getDiscountTier();
        dt.SBQQ__Schedule__c = ds.id;
        dt.SBQQ__Discount__c = 10;
        insert dt;

        String psTest = '';
        psTest = POCH_VentaMostrador_cls.getPrice(prd.Id, suc.Id, 15, acc.id, 'KG', true, 'Venta_Mostrador_Detalle__c', 'UnidadMedida__c', '0049');
        Test.stopTest();
        system.assert(psTest != '');
    }

    @isTest
    public static void testgetPrice2() {
        Test.startTest();

        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;

        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal2();
        suc.POCH_ClasificacionFisca__c = '4';
        insert suc;
        
        Account acc = POCH_DataCreationTest.getAccountIdSAPCLiente();
        acc.POCH_Sucursal__c = suc.Id;
        acc.POCH_Region__c = reg.Id;
        
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get('POCH_GrupoVendedores__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
        }
       
        insert acc;
        
        Contact contact =  POCH_DataCreationTest.getContact();
        contact.AccountId = acc.Id;
        insert contact;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        
        Pricebook2 pb = POCH_DataCreationTest.getCustomPricebook();
        pb.POCH_Sucursal__c = suc.Id;
        insert pb;   
        
        Product2 prd = POCH_DataCreationTest.getProduct();
        prd.POCH_UnidadesMedida__c =  'KG';
        prd.Family = 'PP_SBS';
        prd.Description ='amoniaco';
        prd.Name ='amoniaco';
        prd.IsActive  = true;
        prd.onlyInSalesforce__c = false;
        insert prd; 
        
        POCH_UnidadMedidaProducto__c um = POCH_DataCreationTest.getUM();
        um.POCH_Producto__c  = prd.Id;
        um.POCH_Numerador__c  = 10;
        insert um;

        PricebookEntry pbe  = new PricebookEntry();
        pbe.Product2Id         = prd.id;
        pbe.Pricebook2Id       =  pb.id;
        pbe.IsActive           = true;
        pbe.POCH_CanalDistribucion__c 	= '12';
        pbe.POCH_CantidadBase__c 		= 1;
        pbe.CurrencyIsoCode    =   'MXN';
        pbe.POCH_FinValidez__c 		= Date.today() + 30;
        pbe.POCH_IdExterno__c 			= 'IDEXTPBET';
        pbe.POCH_InicioValidez__c 		= Date.today() - 1;
        pbe.POCH_NoRegCondicion__c 	= '181114_C';
        pbe.POCH_OrganizacionVentas__c = '0049';
        pbe.Unidad_de_medida__c 		= 'KG';
        pbe.POCH_UnidadMedidaEscala__c = 'KG';
        pbe.UnitPrice          =   25.0;
        pbe.Grupo_de_Materiales__c    =   '';
        insert pbe;
        
        SBQQ__ContractedPrice__c contractedPrice = POCH_DataCreationTest.getPrecioEspecial();
        contractedPrice.POCH_UnidadMedidaEscala__c = 'KG';
        contractedPrice.POCH_UnidadMedida__c = 'KG';
        contractedPrice.POCH_Sucursal__c = suc.id;
        contractedPrice.SBQQ__Product__c = prd.id;
        contractedPrice.SBQQ__Account__c = acc.id;
        insert contractedPrice;

        SBQQ__DiscountSchedule__c ds = POCH_DataCreationTest.getDiscountSchedule();
        ds.SBQQ__Product__c = prd.id;
        ds.SBQQ__Pricebook__c = pb.id;
        insert ds;

        SBQQ__DiscountTier__c dt = POCH_DataCreationTest.getDiscountTier();
        dt.SBQQ__Schedule__c = ds.id;
        dt.SBQQ__Discount__c = 10;
        insert dt;

        String psTest = '';
        psTest = POCH_VentaMostrador_cls.getPrice(prd.Id, suc.Id, 15, acc.id, 'LT', true, 'Venta_Mostrador_Detalle__c', 'UnidadMedida__c', '0049');
        Test.stopTest();
        system.assert(psTest != '');
    }

    @isTest
    public static void testgetMargen() {
        Test.startTest();

        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;

        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal2();
        suc.POCH_ClasificacionFisca__c = '4';
        insert suc;
        
        Account acc = POCH_DataCreationTest.getAccountIdSAPCLiente();
        acc.POCH_Sucursal__c = suc.Id;
        acc.POCH_Region__c = reg.Id;
        
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get('POCH_GrupoVendedores__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
        }
       
        insert acc;
        
        Contact contact =  POCH_DataCreationTest.getContact();
        contact.AccountId = acc.Id;
        insert contact;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        
        Pricebook2 pb = POCH_DataCreationTest.getCustomPricebook();
        pb.POCH_Sucursal__c = suc.Id;
        insert pb;   
        
        Product2 prd = POCH_DataCreationTest.getProduct();
        prd.POCH_UnidadesMedida__c =  'KG';
        prd.Family = 'PP_SBS';
        prd.Description ='amoniaco';
        prd.Name ='amoniaco';
        prd.IsActive  = true;
        prd.onlyInSalesforce__c = false;
        insert prd; 
        
        POCH_UnidadMedidaProducto__c um = POCH_DataCreationTest.getUM();
        um.POCH_Producto__c  = prd.Id;
        um.POCH_Numerador__c  = 10;
        insert um;

        PricebookEntry pbe  = new PricebookEntry();
        pbe.Product2Id         = prd.id;
        pbe.Pricebook2Id       =  pb.id;
        pbe.IsActive           = true;
        pbe.POCH_CanalDistribucion__c 	= '12';
        pbe.POCH_CantidadBase__c 		= 1;
        pbe.CurrencyIsoCode    =   'MXN';
        pbe.POCH_FinValidez__c 		= Date.today() + 30;
        pbe.POCH_IdExterno__c 			= 'IDEXTPBET';
        pbe.POCH_InicioValidez__c 		= Date.today() - 1;
        pbe.POCH_NoRegCondicion__c 	= '181114_C';
        pbe.POCH_OrganizacionVentas__c = '0049';
        pbe.Unidad_de_medida__c 		= 'KG';
        pbe.POCH_UnidadMedidaEscala__c = 'KG';
        pbe.UnitPrice          =   25.0;
        pbe.Grupo_de_Materiales__c    =   '';
        insert pbe;

        SBQQ__ContractedPrice__c contractedPrice = POCH_DataCreationTest.getPrecioEspecial();
        contractedPrice.POCH_UnidadMedidaEscala__c = 'KG';
        contractedPrice.POCH_UnidadMedida__c = 'KG';
        contractedPrice.POCH_Sucursal__c = suc.id;
        contractedPrice.SBQQ__Product__c = prd.id;
        contractedPrice.SBQQ__Account__c = acc.id;
        insert contractedPrice;

        SBQQ__DiscountSchedule__c ds = POCH_DataCreationTest.getDiscountSchedule();
        ds.SBQQ__Product__c = prd.id;
        ds.SBQQ__Pricebook__c = pb.id;
        insert ds;

        SBQQ__DiscountTier__c dt = POCH_DataCreationTest.getDiscountTier();
        dt.SBQQ__Schedule__c = ds.id;
        dt.SBQQ__Discount__c = 10;
        insert dt;

        POCH_ValoracionProducto__c vp = POCH_DataCreationTest.getVP();
        vp.POCH_Producto__c = prd.Id;
        vp.POCH_AreaValoracion__c = '';
        vp.POCH_CostoFactInterna__c = 123;
        vp.CurrencyIsoCode = 'MXN';
        insert vp;

        Double psTest;
        psTest = POCH_VentaMostrador_cls.getMargen(prd.Id, 'KG', true, 'Venta_Mostrador_Detalle__c', 'UnidadMedida__c', 2, 0, 'CENTRO', 'POCH_Centro__c', 'MXN', 'Almacen__c');
        Test.stopTest();
        system.assert(psTest != 0);
    }

}