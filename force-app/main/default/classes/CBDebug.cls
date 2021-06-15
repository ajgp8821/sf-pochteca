/**
 * Created by Alex JR on 18/06/20.
 */

global with sharing class CBDebug {

    global static void syncUsers() {
        List<User> users = [
                SELECT Id, Name, FirstName, LastName, POCH_UserRoleName__c, POCH_IdSAP__c, POCH_OrganizacionesVentas__c, POCH_ProfileName__c, Division
                FROM User
                WHERE IsActive = true AND
                POCH_UserRoleName__c LIKE '%Ejecutivo Comercial%'
                ORDER BY POCH_UserRoleName__c
        ];

        Map<String, String> divisionMap = new Map<String, String>();
        for (cb4__CBTag__c t : [SELECT Id, NAme FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Department']) divisionMap.put(t.Name, t.Id);
        System.debug(divisionMap);

        cb4__CBDimension__c empDim = [SELECT Id FROM cb4__CBDimension__c WHERE Name = 'Employee'];

        List<cb4__CBTag__c> tags = new List<cb4__CBTag__c>();
        for (USer a : users) {
            String divId = divisionMap.get(a.Division);
            cb4__CBTag__c div = new cb4__CBTag__c(
                    Name = a.Name,
                    cb4__Text1__c = a.FirstName,
                    cb4__Text2__c = a.LastName,
                    cb4__Dimension__c = empDim.Id,
                    cb4__Tag6__c = divId,
                    cb4__ExtId__c = a.Id,
                    cb4__Text6__c = a.POCH_UserRoleName__c,
                    cb4__User__c = a.Id
            );
            tags.add(div);
        }
        System.debug(tags[0]);
        insert tags;
    }

    /**
     * Create Dimension 'Sucursal' before
     */
    global static void syncSucursal() {
        List<POCH_Sucursal__c> sucursal = [
                SELECT Id, Name, POCH_CalleSucursal__c, POCH_Centro__c
                FROM POCH_Sucursal__c
        ];

        cb4__CBDimension__c sDim = [SELECT Id FROM cb4__CBDimension__c WHERE Name = 'Sucursal'];

        List<cb4__CBTag__c> tags = new List<cb4__CBTag__c>();
        for (POCH_Sucursal__c a : sucursal) {
            cb4__CBTag__c div = new cb4__CBTag__c(
                    Name = a.Name,
                    cb4__Text1__c = a.POCH_CalleSucursal__c,
                    cb4__Text2__c = a.POCH_Centro__c,
                    cb4__Dimension__c = sDim.Id,
                    cb4__ExtId__c = a.Id
            );
            tags.add(div);
        }
        System.debug(tags[0]);
        insert tags;
    }

    /**
     * Create Product Division
     */
    global static void syncProductDivision() {

        cb4__CBDimension__c sDim = [SELECT Id FROM cb4__CBDimension__c WHERE Name = 'Product Division'];
        List<cb4__CBTag__c> tags = new List<cb4__CBTag__c>();

        for (AggregateResult p : [
                SELECT POCH_Division__c pd
                FROM Product2
                WHERE POCH_Division__c != null
                GROUP BY POCH_Division__c
                ORDER BY POCH_Division__c
        ]) {
            cb4__CBTag__c div = new cb4__CBTag__c(
                    Name = (String) p.get('pd'),
                    cb4__Dimension__c = sDim.Id
            );
            tags.add(div);
        }
        insert tags;
    }

    /**
     * Crate Dimension Region
     */
    global static void syncRegions() {
        List<POCH_Region__c> regions = [
                SELECT ID, Name, POCH_Pais__c
                FROM POCH_Region__c
        ];
        cb4__CBDimension__c sDim = [SELECT Id FROM cb4__CBDimension__c WHERE Name = 'Region'];
        List<cb4__CBTag__c> tags = new List<cb4__CBTag__c>();
        for (POCH_Region__c a : regions) {
            cb4__CBTag__c div = new cb4__CBTag__c(
                    Name = a.Name,
                    cb4__Text1__c = a.POCH_Pais__c,
                    cb4__Dimension__c = sDim.Id,
                    cb4__ExtId__c = a.Id
            );
            tags.add(div);
        }
        System.debug(tags[0]);
        insert tags;
    }


    /**
     * Clients
     */
    global static void syncCRMAccounts() {
        List<AggregateResult> aggr = [
                SELECT Opportunity.AccountId acc, MAX(Opportunity.Account.Name) accName,
                        MAX(Opportunity.Account.POCH_Region__r.Name) reg,
                        MAX(Opportunity.Account.POCH_Sucursal__r.Name) suc
                FROM OpportunityLineItem
                WHERE Opportunity.StageName = 'Cerrada Perdida'
                AND Opportunity.POCH_IniciativaComercial__c != 'PMV'
                AND Opportunity.CloseDate = THIS_YEAR
                GROUP BY Opportunity.AccountId
        ];

        Map<String, String> sucursalMap = new Map<String, String>();
        for (cb4__CBTag__c t : [SELECT Id, NAme FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Sucursal']) sucursalMap.put(t.Name, t.Id);
        System.debug(sucursalMap);

        Map<String, String> regionMap = new Map<String, String>();
        for (cb4__CBTag__c t : [SELECT Id, NAme FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Region']) regionMap.put(t.Name, t.Id);
        System.debug(regionMap);

        cb4__CBDimension__c sDim = [SELECT Id FROM cb4__CBDimension__c WHERE Name = 'Client'];

        List<cb4__CBTag__c> tags = new List<cb4__CBTag__c>();
        for (AggregateResult a : aggr) {
            cb4__CBTag__c div = new cb4__CBTag__c(
                    Name = (String) a.get('accName'),
                    cb4__Dimension__c = sDim.Id,
                    cb4__Tag6__c = sucursalMap.get((String) a.get('suc')),
                    cb4__Tag7__c = regionMap.get((String) a.get('reg')),
                    cb4__ExtId__c = (String) a.get('acc')
            );
            tags.add(div);
        }
        System.debug(tags[0]);
        insert tags;
    }


    global static void importActual() {
        // employee
        Set<String> repId = new Set<String>();
        Map<Id, Id> employeeMap = new Map<Id, Id>();
        for (cb4__CBTag__c t : [SELECT Id, cb4__ExtId__c FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Employee' ORDER BY Name LIMIT 50000]) {
            employeeMap.put(t.cb4__ExtId__c, t.Id);
            repId.add(t.cb4__ExtId__c);
        }
        String repFilter = cb4.CBUtils.getFormattedINQuery(repId);

        // department
        Set<String> devId = new Set<String>();
        Map<String, String> departmentMap = new Map<String, String>();
        for (cb4__CBTag__c t : [SELECT Id, Name FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Department' ORDER BY Name LIMIT 50000]) {
            departmentMap.put(t.Name, t.Id);
            repId.add(t.Name);
        }
        String devFilter = cb4.CBUtils.getFormattedINQuery(devId);
        System.debug(devFilter);

        // common account
        String accId = [SELECT Id FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Account' AND Name = 'Mayoristas' LIMIT 1][0].Id;
        String oppItDimId = [SELECT Id FROM cb4__CBDimension__c WHERE Name = 'Opportunity Item' LIMIT 1][0].Id;

        //periods
        Map<Date, Id> periodMap = new Map<Date, Id>();
        for (cb4__CBTag__c p : [SELECT Id, cb4__Start__c FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Period']) periodMap.put(p.cb4__Start__c, p.Id);


        //sucursal
        Map<Id, Id> sucursalMap = new Map<Id, Id>();
        for (cb4__CBTag__c p : [SELECT Id, cb4__ExtId__c FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Sucursal']) sucursalMap.put(p.cb4__ExtId__c, p.Id);


        //product division
        Map<String, String> productDivisionMap = new Map<String, String>();
        for (cb4__CBTag__c p : [SELECT Id, Name FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Product Division']) productDivisionMap.put(p.Name, p.Id);

        //client
        Map<String, String> clientMap = new Map<String, String>();
        for (cb4__CBTag__c p : [SELECT Id, cb4__ExtId__c FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Client']) clientMap.put(p.cb4__ExtId__c, p.Id);


        String q = 'SELECT Opportunity.POCH_AccountName__c, Name, Opportunity.OwnerId, Opportunity.Amount, Product2.POCH_Division__c, Opportunity.CreatedDate, ' +
                ' Opportunity.POCH_Sucursal__c, Opportunity.Owner.Division, Opportunity.AccountId, Opportunity.Id, Product2.Id  ' +
                ' FROM OpportunityLineItem ' +
                ' WHERE Opportunity.StageName = \'Cerrado Pagado\' AND Opportunity.POCH_IniciativaComercial__c != \'PMV\' ' +
                ' AND Opportunity.CloseDate = THIS_YEAR  ' + // AND Opportunity.Owner.Name  LIKE \'%CLAUDIA MERCEDES%\'
                ' AND Opportunity.OwnerId IN ' + repFilter +
                ' AND Product2.POCH_Division__c != null ';
        List<OpportunityLineItem> items = Database.query(q);
        System.debug('Items = ' + items.size());

        List<cb4__CBTag__c> actuals = new List<cb4__CBTag__c>();
        for (OpportunityLineItem i : items) {
            String periodId = periodMap.get(Date.newInstance(i.Opportunity.CreatedDate.year(), i.Opportunity.CreatedDate.month(), 1));
            if (periodId == null) {
                System.debug('NO PERIOD');
                continue;
            }

            String clientId = clientMap.get(i.Opportunity.AccountId);
            if (clientId == null) {
                System.debug('NO CLIENT - ' + i.Opportunity.AccountId);
                continue;
            }

            String sucursalId = sucursalMap.get(i.Opportunity.POCH_Sucursal__c);
            String employeeId = employeeMap.get(i.Opportunity.OwnerId);//Ejecutivo Comercial
            String productDivId = productDivisionMap.get(i.Product2.POCH_Division__c);
            String depId = departmentMap.get(i.Opportunity.Owner.Division);
            Decimal amount = i.Opportunity.Amount;
            Id oppId = i.Opportunity.Id;
            String oiname = i.Name;
            Date transDate = Date.valueOf(i.Opportunity.CreatedDate);
            Id prodId = i.Product2.Id;

            cb4__CBTag__c oppIt = new cb4__CBTag__c();
            oppIt.cb4__Dimension__c = oppItDimId;
            oppIt.cb4__Tag2__c = accId;
            oppIt.cb4__Tag3__c = periodId;
            oppIt.cb4__Tag4__c = employeeId;
            oppIt.cb4__Tag5__c = clientId;
            oppIt.cb4__Tag6__c = sucursalId;
            oppIt.cb4__Tag7__c = productDivId;
            oppIt.cb4__Tag8__c = depId;
            oppIt.cb4__ExtId__c = oppId;
            oppIt.cb4__Decimal1__c = amount;
            oppIt.cb4__Text1__c = oiname;
            oppIt.cb4__Date1__c = transDate;
            oppIt.cb4__Product__c = prodId;

            actuals.add(oppIt);
        }
        System.debug(actuals[0]);
        System.debug(actuals.size());

        insert actuals;

    }

/**
 * SELECT
Id,
POCH_Codigo__c,
Name,
POCH_CantidadPotencial__c,
POCH_CantidadBase__c,
POCH_UnidadMedida__c,
POCH_PrecioLista__c,
POCH_EsPotencial__c,
POCH_EsBase__c,
POCH_AquienCompra__c,
POCH_Estatus__c,
POCH_Producto__c,
POCH_Sucursal__c,
POCH_Notas__c,
POCH_Moneda__c,
POCH_Sucursal__r.Name,
POCH_MonedaCompetencia__c,
POCH_CantidadCompetencia__c,
POCH_HojaInventario__r.POCH_FrecuenciaCotizacion__c,
POCH_HojaInventario__r.POCH_Cuenta__c,
POCH_OnlyInSFDC__c,
POCH_uma__c,
POCH_UMAS__c
ROM POCH_DetalleInventario__c
LIMIT 10
 */

}