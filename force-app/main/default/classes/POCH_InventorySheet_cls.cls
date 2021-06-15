/****************************************************************************************************
General Information
-------------------
author: Hector Diaz
email:
company: Freeway MX 
Project:
Customer:
Description:  Controller APEX component POCH_InventorySheet_cmp
@Helper class : POCH_InventorySheet_helper
Information about changes (versions)
-------------------------------------
Number    Dates             Author                       Description
------    --------          --------------------------   -----------
1.0       20-Junio-2019       Hector Diaz Hernandez      Creation Class
1.1       12-agosto-2019      Esquivel Cázares Mauricio  Refactorization->SOC MODEL
1.2       10-Febrero-2021     Jesús Azuaje               Colocar parametro adicional metodo getDataPickListValues
1.3       06-Mayo-2021        Jesús Azuaje               new method getDescription
1.4       07-Mayo-2021        Jesús Azuaje               new method getUnidadesMedidas
****************************************************************************************************/
public class POCH_InventorySheet_cls {
    /**
------------------------------------------
*/
    @AuraEnabled
    public static string insertValuesDetailProduct(String strFrecuencyQuote, List<POCH_DetalleInventario__c>  lstproducts, String idBranchOffice, String strIdAccountRelated,Boolean blnIsUpdate,String strIdRecordSheetInve) {
        try {
            string currentBranchOffice = POCH_InventorySheet_helper.setBranchOffice(idBranchOffice,strIdRecordSheetInve);   
            if(POCH_InventorySheet_helper.checkInsert(strIdRecordSheetInve,currentBranchOffice,strIdAccountRelated)) {
                POCH_HojaInventario__c objInventorySheet = POCH_InventorySheet_helper.buildInventorySheet(currentBranchOffice, strIdAccountRelated , strIdRecordSheetInve, strFrecuencyQuote);
                upsert objInventorySheet;
                
                List<POCH_DetalleInventario__c> lstDetailSheet = POCH_InventorySheet_helper.fillProductList(lstproducts, objInventorySheet.Id, currentBranchOffice);
                if(lstDetailSheet.size() > 0) {  
                    Database.UpsertResult[] lUR = Database.upsert(lstDetailSheet, POCH_DetalleInventario__c.POCH_IdExterno__c, false);
                    for(Database.UpsertResult sr : lUR) {
                        if(!sr.isSuccess())
                            for(Database.Error error : sr.getErrors()) { System.debug('--> ERROR (' + sr.getId() +') : ' + error.getMessage()); }
                    }
                    List<Opportunity> objOppUpdate = POCH_InventorySheet_data.retrieveOpportunityData(strIdAccountRelated);
                    if(objOppUpdate.size() > 0 && !String.isEmpty(objOppUpdate[0].id)) {
                        objOppUpdate[0].POCH_MaterialHojaInventario__c = true;
                        update objOppUpdate;
                    }
                    
                }
                return 'OK';
            } else {
                return 'ERROR';
            }
        } catch(Exception e) { 
            System.debug('--> ERROR: ' + e.getMessage() + ' - ' + e.getStackTraceString()); 
            return 'ERROR';
        }
    }
    /**
Metodo para Obtener los detalles de inventario y mostarlos en el componente
*/
    @AuraEnabled
    public static List<POCH_DetalleInventario__c> getDetailsInventorySheet(String idSheetDetail) {
        List<POCH_DetalleInventario__c> lstDetail = new List<POCH_DetalleInventario__c>();    
        
        lstDetail = [SELECT Id, POCH_Codigo__c, Name, POCH_CantidadPotencial__c,POCH_CantidadBase__c,POCH_UnidadMedida__c,
                     POCH_PrecioLista__c,POCH_EsPotencial__c,POCH_EsBase__c,POCH_AquienCompra__c,POCH_Estatus__c, 
                     POCH_Producto__c,POCH_Sucursal__c,POCH_Notas__c,POCH_Moneda__c,POCH_Sucursal__r.Name,Moneda_competencia__c,
                     POCH_MonedaCompetencia__c,POCH_CantidadCompetencia__c,POCH_HojaInventario__r.POCH_FrecuenciaCotizacion__c,
                     POCH_HojaInventario__r.POCH_Cuenta__c, POCH_OnlyInSFDC__c, POCH_uma__c, POCH_UMAS__c, POCH_Sucursal__r.POCH_Sociedad__c
                     FROM POCH_DetalleInventario__c WHERE POCH_HojaInventario__c =: idSheetDetail  ];
        return lstDetail;
    }
    /**
Metodo para eliminar registos (Detalle de inventario ) para la hoja de inventario
*/
    @AuraEnabled
    public static void deleteRecordOnDetail(String IdRecordDetail) {
        List<POCH_DetalleInventario__c> lstDetailDetelete = new List<POCH_DetalleInventario__c>();
        lstDetailDetelete = [SELECT Id FROM POCH_DetalleInventario__c WHERE id =: IdRecordDetail];
        delete lstDetailDetelete;
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
Metodo para obtener las frecuencias de cotizacion por pèrfil
*/
    @AuraEnabled
    public static List<String> getDataPickListValues(String strObject, String idHojaInventario) {
        List<String> lstReturnValues = new List<String>();
        if(strObject == 'POCH_FrecuenciaCotizacion__mdt') {    
            String strNameProfile = [SELECT Name FROM Profile where Id =: UserInfo.getProfileId()].Name;
            for(POCH_FrecuenciaCotizacion__mdt objIterateMdt :  [SELECT MasterLabel ,id , POCH_Fecuencia__c, POCH_Activo__c FROM POCH_FrecuenciaCotizacion__mdt WHERE MasterLabel =:strNameProfile AND POCH_Activo__c =: true ] ){
                lstReturnValues = objIterateMdt.POCH_Fecuencia__c.split(',');
            }    
        } else if(strObject == 'POCH_Competencia__c') {
            lstReturnValues.add('-NA-');
            if (idHojaInventario != null){
                POCH_HojaInventario__c hojaIventario = [SELECT Id, POCH_Sucursal__r.POCH_Sociedad__c FROM POCH_HojaInventario__c WHERE Id =: idHojaInventario];
                if(hojaIventario.POCH_Sucursal__r.POCH_Sociedad__c != null){
                    for(POCH_Competencia__c objIterateCompetition :  [SELECT Name, Id, Activa__c, Sociedad__c FROM POCH_Competencia__c WHERE Activa__c =: true AND Sociedad__c =: hojaIventario.POCH_Sucursal__r.POCH_Sociedad__c ORDER BY Name ASC] ){
                        lstReturnValues.add(String.valueOf(objIterateCompetition.Name));
                    } 
                } else{
                    for(POCH_Competencia__c objIterateCompetition :  [SELECT Name, Id, Activa__c, Sociedad__c FROM POCH_Competencia__c WHERE Activa__c =: true  ORDER BY Name ASC] ){
                        lstReturnValues.add(String.valueOf(objIterateCompetition.Name));
                    }    
                }
                
            } else{
                for(POCH_Competencia__c objIterateCompetition :  [SELECT Name, Id, Activa__c, Sociedad__c FROM POCH_Competencia__c WHERE Activa__c =: true  ORDER BY Name ASC] ){
                    lstReturnValues.add(String.valueOf(objIterateCompetition.Name));
                } 
            }
            
        }
        return lstReturnValues;
    }
    /*@Descripción: Manda a cotización la hoja de inventario actual del usuario con los productos activos con su precio y cantidad
correspondientes .Helper:POCH_InventorySheet_helper. Hace uso de las clases POCH_OpportunityWithQuote y POCH_Quote .
*/
    @AuraEnabled
    public static string quoteCurrentSheet(string accountId, string sheetId, Boolean isBatch) {
        
        String  result      = ''; 
        String  errores     = '';
        Boolean isEmptyLine = true;
        Set<Id> setIdOpps   = new Set<Id>();
        string divisa;        
        SBQQ.TriggerControl.disable();
        Set<String> setDivisas = POCH_InventorySheet_helper.getLinesCurrencies(sheetId);
        Map<Id,Id>  mapPrdPBE  = POCH_InventorySheet_helper.getPBEntries(sheetId);
        
        List<SBQQ__QuoteLine__c> listQuoteLines = new List<SBQQ__QuoteLine__c>();
        POCH_InventorySheet_helper.operationResult operationResult = new POCH_InventorySheet_helper.operationResult();  
        POCH_OpportunityWithQuote objOpportunityUsd = new POCH_OpportunityWithQuote(accountId, sheetId, isBatch, divisa); 
        POCH_OpportunityWithQuote objOpportunityMxn = new POCH_OpportunityWithQuote(accountId, sheetId, isBatch, divisa); 
        POCH_Quote quoteItem = objOpportunityUsd.createQuote();
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesMxn = new List<SBQQ__QuoteLine__c>();
        //for(String divisas : setDivisas) {
           // System.debug('::::>>> divisa ' + divisas);
            operationResult = new POCH_InventorySheet_helper.operationResult(); 
            quoteCurrentSheetFuture(accountId,sheetId,isBatch,setDivisas);
       //  }
          if(!setDivisas.isEmpty()) {   isEmptyLine = false; }
      
         try {
            
            // result = objOpportunity.oportunidad.id;
         //   System.debug(':::>> quoteLines ' + quoteLines);
        } catch(Exception e) { System.debug('::>> ERRor ; ' + e.getMessage()); }
        
        if(String.isNotBlank(errores) || Test.isRunningTest()) { 
            result = System.label.POCH_Error + errores; 
            POCH_InventorySheet_helper.deleteOppsError(setIdOpps);
        }
        SBQQ.TriggerControl.enable();
        
        String strActiveDetails = 'ERROR Para cotizar, debe tener al menos (1) producto activo';
        String urlInvDetails    = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/' + accountId + '/related/Opportunities/view';
        return isEmptyLine ? strActiveDetails : (result.containsIgnoreCase('Error') ? result : (setDivisas.size() > 1 ? urlInvDetails : result));      
            }
    /*
@Description: Retorna una lista de campos configurados en metadatatypes que deben de corresponder a algún campo del objeto
producto, ya que serán mapeados dentro de Producto una vez que el usuario llene los datos.
IMPORTANTE: El nombre api del metadato tiene que ser el mismo nombre api en producto.
*/
     public static List<SBQQ__QuoteLine__c>quoteCurrentSheetBacht(string accountId, string sheetId, Boolean isBatch) {
        String  result      = ''; 
        String  errores     = '';
        Boolean isEmptyLine = true;
        boolean usd = false;
        boolean mxn = false;
        Set<Id> setIdOpps   = new Set<Id>();
        String divisa;

        SBQQ.TriggerControl.disable();
        Set<String> setDivisas = POCH_InventorySheet_helper.getLinesCurrencies(sheetId);
        Map<Id,Id>  mapPrdPBE  = POCH_InventorySheet_helper.getPBEntries(sheetId);
        POCH_OpportunityWithQuote objOpportunity = new POCH_OpportunityWithQuote(accountId, sheetId, isBatch, divisa); 
        POCH_OpportunityWithQuote objOpportunityU = new POCH_OpportunityWithQuote(accountId, sheetId, isBatch, divisa); 



        POCH_InventorySheet_helper.operationResult operationResult = new POCH_InventorySheet_helper.operationResult();  
        List<Object> quoteLines = new List<SBQQ__QuoteLine__c>();
         List<SBQQ__QuoteLine__c> quoteLinesU = new List<SBQQ__QuoteLine__c>();
        for(String divisass : setDivisas) {
           // System.debug('::::>>> divisa ' + divisass);

            
        } 
        if(setDivisas.CONTAINS('MXN') ){
            mxn = true;
            operationResult = new POCH_InventorySheet_helper.operationResult();      
            objOpportunity = new POCH_OpportunityWithQuote(accountId, sheetId, isBatch, 'MXN'); 
        }
       
        if(!objOpportunity.getPriceBookEntries().isEmpty()) {
            operationResult = POCH_InventorySheet_helper.dmlOpportunity('insert', new List<sObject>{objOpportunity.oportunidad});
            if(operationResult.successMessage != System.label.POCH_Ok) { errores += ' ::: ' + operationResult.errorMessage; } 
            else { 

                setIdOpps.add(objOpportunity.oportunidad.id);
                

                POCH_Quote quoteItem = objOpportunity.createQuote();
                operationResult = POCH_InventorySheet_helper.dmlOpportunity('insert', new List<sObject>{quoteItem.innerQuote});                    
                if(operationResult.successMessage != System.label.POCH_Ok) { errores += ' ::: ' + operationResult.errorMessage; }
                else {                    
                  quoteLinesU.addAll(quoteItem.createQuoteProducts(objOpportunity.products, mapPrdPBE));
                  //  POCH_QuoteLineTriggerService.isBatch = true;
                 
                }
            }                
            isEmptyLine = false;
         
        }                                  
        if(setDivisas.CONTAINS('USD') ){
            usd = true;
            operationResult = new POCH_InventorySheet_helper.operationResult();      
            objOpportunityU = new POCH_OpportunityWithQuote(accountId, sheetId, isBatch, 'USD'); 
             }
            if(!objOpportunityU.getPriceBookEntries().isEmpty()) {
            operationResult = POCH_InventorySheet_helper.dmlOpportunity('insert', new List<sObject>{objOpportunityU.oportunidad});
            if(operationResult.successMessage != System.label.POCH_Ok) { errores += ' ::: ' + operationResult.errorMessage; } 
            else { 
                setIdOpps.add(objOpportunityU.oportunidad.id);
                
                POCH_Quote quoteItem = objOpportunityU.createQuote();
                operationResult = POCH_InventorySheet_helper.dmlOpportunity('insert', new List<sObject>{quoteItem.innerQuote});                    
                if(operationResult.successMessage != System.label.POCH_Ok) { errores += ' ::: ' + operationResult.errorMessage; }
                else {                    

                   quoteLinesU.addAll(quoteItem.createQuoteProducts(objOpportunityU.products, mapPrdPBE));
                   // POCH_QuoteLineTriggerService.isBatch = true;
                  
                }
            }                

            isEmptyLine = false;

        } 
        
        try {
         
 // result = objOpportunity.oportunidad.id;
         //   System.debug(':::>> quoteLines ====================' + quoteLines);
        } catch(Exception e) { System.debug('::>> ERRor ; ' + e.getMessage()); }
        
        if(String.isNotBlank(errores) || Test.isRunningTest()) { 
            result = System.label.POCH_Error + errores; 
            POCH_InventorySheet_helper.deleteOppsError(setIdOpps);
        }
        SBQQ.TriggerControl.enable();
      // database.insert(quoteLinesU,false);
                 return quoteLinesU;
     
     }
    @future
    public static void quoteCurrentSheetFuture(string accountId, string sheetId, Boolean isBatch,Set<String> setDivisas) {
        String  result      = ''; 
        String  errores     = '';
        Boolean isEmptyLine = true;
        Set<Id> setIdOpps   = new Set<Id>();
        string divisa;
        //system.debug('accountId'+accountId);
             // system.debug('accountId'+sheetId);
                     //   system.debug('accountId'+isBatch);
        SBQQ.TriggerControl.disable();
        // Set<String> setDivisas = POCH_InventorySheet_helper.getLinesCurrencies(sheetId);
        Map<Id,Id>  mapPrdPBE  = POCH_InventorySheet_helper.getPBEntries(sheetId);
        
        List<SBQQ__QuoteLine__c> listQuoteLines = new List<SBQQ__QuoteLine__c>();
        POCH_InventorySheet_helper.operationResult operationResult = new POCH_InventorySheet_helper.operationResult();  
        POCH_OpportunityWithQuote objOpportunityUsd = new POCH_OpportunityWithQuote(accountId, sheetId, isBatch, divisa); 
        POCH_OpportunityWithQuote objOpportunityMxn = new POCH_OpportunityWithQuote(accountId, sheetId, isBatch, divisa); 
        POCH_Quote quoteItem = objOpportunityUsd.createQuote();
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesMxn = new List<SBQQ__QuoteLine__c>();
        for(String divisas : setDivisas) {
          //  System.debug('::::>>>===== divisa ' + divisas);
            operationResult = new POCH_InventorySheet_helper.operationResult(); 
            objOpportunityUsd = new POCH_OpportunityWithQuote(accountId, sheetId, isBatch, divisas);
            /* for(String divisa : setDivisas) {
System.debug('::::>>> divisa ' + divisa);
POCH_InventorySheet_helper.operationResult operationResult = new POCH_InventorySheet_helper.operationResult();            
POCH_OpportunityWithQuote objOpportunity = new POCH_OpportunityWithQuote(accountId, sheetId, isBatch, divisa); */
     
            //        if(setDivisas.contains('USD')){
            if(!objOpportunityUsd.getPriceBookEntries().isEmpty()) {
              //  system.debug('LINEA DE PECIOENTRADA  290'+sheetId);
                operationResult = POCH_InventorySheet_helper.dmlOpportunity('insert', new List<sObject>{objOpportunityUsd.oportunidad});
                if(operationResult.successMessage != System.label.POCH_Ok) { errores += ' ::: ' + operationResult.errorMessage; } 
                else { 
                    setIdOpps.add(objOpportunityUsd.oportunidad.id);
                      
                    quoteItem = objOpportunityUsd.createQuote();
                  //  system.debug('LINEA DE PECIOENTRADA  295'+ new List<sObject>{quoteItem.innerQuote});
                    operationResult = POCH_InventorySheet_helper.dmlOpportunity('insert', new List<sObject>{quoteItem.innerQuote});                    
                    if(operationResult.successMessage != System.label.POCH_Ok) { errores += ' ::: ' + operationResult.errorMessage;
                    //     system.debug('LINEA DE ERRORES  300'+errores);                                                         
                                                                               }
                    else {                    
                        quoteItem.createQuoteProductsList(objOpportunityUsd.products, mapPrdPBE);
                        POCH_QuoteLineTriggerService.isBatch = false;
                        // insert quoteLines;
                        
                    }                
                    isEmptyLine = false;
                }                                  
            } 
            
            
            
            
        }
        try {
            
            // result = objOpportunity.oportunidad.id;
           // System.debug(':::>> quoteLines ' + quoteLines);
        } catch(Exception e) { System.debug('::>> ERRor ; ' + e.getMessage()); }
        
        if(String.isNotBlank(errores) || Test.isRunningTest()) { 
         //   result = System.label.POCH_Error + errores; 
            POCH_InventorySheet_helper.deleteOppsError(setIdOpps);
        }
        SBQQ.TriggerControl.enable();
        
        String strActiveDetails = 'ERROR Para cotizar, debe tener al menos (1) producto activo';
        String urlInvDetails    = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/' + accountId + '/related/Opportunities/view';
        
        
        
    }
    
    
    
    @AuraEnabled
    public static List<Object> getFieldList(){
        return POCH_Utilities.getcustomFields('Product_Setting__mdt');
    }
    
    /*
@Description:Inserta el producto y el priceBookEntry a partir de los datos ingresados por el usuario.
*/
    @AuraEnabled
    public static POCH_InventorySheet_helper.operationResult insertProduct(String objProdToInsert, String idHI, String idSuc) {
        List<Object> dataDeserialized = (List<Object>)JSON.deserializeUntyped(objProdToInsert);
        List<Map<String,Object>> dataMap = new List<Map<String,Object>>();
        For(Object singleInput : dataDeserialized) {
            Map<String,Object> inputToMap = (Map<String,Object>)singleInput;
            dataMap.add(inputToMap);
        }        
        return POCH_InventorySheet_helper.manageProductObj(dataMap, idHI, idSuc);
    }    
    /*
@Description:Consulta las unidades de medida por producto y retorna el factor de conversion
*/
    @AuraEnabled
    public static Decimal getUnitOfMeasureConversion(String idProd, String umInv, String umPrecio) {
        Decimal factorConversion = 0;
        for(POCH_UnidadMedidaProducto__c umpr : [SELECT POCH_FactorConversion__c FROM POCH_UnidadMedidaProducto__c WHERE POCH_Producto__c =: idProd AND POCH_UMA__c =: umInv]) {
            factorConversion = umpr.POCH_FactorConversion__c;
        }
        return factorConversion;
    }    
    /*
@Description:Consulta el precio de lista o especiales y los asigna al precio del inventario cuando cambie la cantidad
*/
    @AuraEnabled
    public static String getUMP(String idProd, String idSuc) {
        String ump = '';
        String pbook = '';
        List<Pricebook2> lPB = new List<Pricebook2>([SELECT Id FROM Pricebook2 WHERE POCH_Sucursal__c =: idSuc LIMIT 1]);
        if(!lPB.isEmpty()) { 
            pbook = lPB[0].Id; 
        } 
        List<PricebookEntry> lPBE = New List<PricebookEntry>(
            [SELECT POCH_UnidadMedida__c FROM PricebookEntry WHERE Pricebook2Id =: pbook AND Product2Id =: idProd AND IsActive = TRUE LIMIT 1]
        );
        if(!lPBE.isEmpty()) { 
            ump = lPBE[0].POCH_UnidadMedida__c;
        } else {
            ump = [SELECT QuantityUnitOfMeasure FROM Product2 WHERE Id =: idProd LIMIT 1].QuantityUnitOfMeasure;
        } 
        return ump;
    }
    /*
@Description:Consulta el precio de lista o especiales y los asigna al precio del inventario cuando cambie la cantidad
*/
    @AuraEnabled
    public static PrecioWrapper getSpecialOrListPrice(String idProd, String idSuc, String idAcc, Decimal qty, String um) {
        PrecioWrapper pw = new PrecioWrapper();  
        String UMV = String.isNotBlank(um) ? um.toUpperCase() : '';
        String UMB = '';          
        
        for(PricebookEntry pbe : [SELECT UnitPrice,CurrencyIsoCode,POCH_UnidadMedida__c,Product2.QuantityUnitOfMeasure, POCH_UnidadMedidaEscala__c, Unidad_de_Medida__c
                                  FROM PricebookEntry WHERE Pricebook2.POCH_Sucursal__c =: idSuc AND Product2Id =: idProd AND IsActive = TRUE LIMIT 1])
        { 
            pw.precio = pbe.UnitPrice;
            pw.moneda = pbe.CurrencyIsoCode;
            pw.medida = pbe.POCH_UnidadMedida__c;
            UMB       = String.isNotBlank(pbe.Unidad_de_Medida__c) ? pbe.Unidad_de_Medida__c : pbe.Product2.QuantityUnitOfMeasure;  //PBE unidad_de_medida
        }
        
        Map<String,POCH_UnidadMedidaProducto__c> mapUM = new Map<String,POCH_UnidadMedidaProducto__c>();
        for(POCH_UnidadMedidaProducto__c ump : [SELECT POCH_Producto__c, POCH_FactorConversion__c, POCH_Denominador__c, POCH_Numerador__c, POCH_UMA__c, POCH_UnidadPeso__c 
                                                FROM POCH_UnidadMedidaProducto__c WHERE POCH_Producto__c =: idProd]) 
        {
            mapUM.put(ump.POCH_UMA__c, ump);
        }
        
        Decimal fCon_V = mapUM.containsKey(UMV)       ? (mapUM.get(UMV).POCH_Numerador__c       / mapUM.get(UMV).POCH_Denominador__c)       : 1;
        Decimal fCon_B = mapUM.containsKey(UMB)       ? (mapUM.get(UMB).POCH_Numerador__c       / mapUM.get(UMB).POCH_Denominador__c)       : 1;
        Decimal fCon_P = mapUM.containsKey(pw.medida) ? (mapUM.get(pw.medida).POCH_Numerador__c / mapUM.get(pw.medida).POCH_Denominador__c) : 1;
        Decimal ctdB_Q = (qty * fCon_V) / fCon_B;
        Decimal fctCnv = fCon_V / fCon_P;                
        
        List<SBQQ__DiscountTier__c> lDT = new List<SBQQ__DiscountTier__c>(
            [SELECT POCH_ImporteCondicion__c,CurrencyIsoCode,SBQQ__Schedule__r.POCH_CantidadMinima__c FROM SBQQ__DiscountTier__c
             WHERE SBQQ__LowerBound__c <=: ctdB_Q AND (SBQQ__UpperBound__c >=: ctdB_Q OR SBQQ__UpperBound__c = NULL) AND SBQQ__Schedule__r.SBQQ__Product__c =: idProd 
             AND SBQQ__Schedule__r.SBQQ__Pricebook__r.POCH_Sucursal__c =: idSuc ORDER BY CreatedDate DESC LIMIT 1]
        );
        if(!lDT.isEmpty()) {
            if(String.isNotBlank(String.valueOf(lDT[0].POCH_ImporteCondicion__c))) { pw.precio = lDT[0].POCH_ImporteCondicion__c; }
        }
        
        List<SBQQ__ContractedPrice__c> lPE = new List<SBQQ__ContractedPrice__c> (
            [SELECT Id,SBQQ__Price__c,CurrencyIsoCode,POCH_UnidadMedida__c,POCH_UnidadMedidaEscala__c FROM SBQQ__ContractedPrice__c 
             WHERE SBQQ__Product__c =: idProd AND SBQQ__Account__c =: idAcc AND POCH_Sucursal__c =: idSuc AND SBQQ__ExpirationDate__c >= TODAY LIMIT 1]
        );
        if(!lPE.isEmpty()) {
            if(String.isNotBlank(String.valueOf(lPE[0].SBQQ__Price__c))) {
                pw.precio = lPE[0].SBQQ__Price__c;
                pw.moneda = lPE[0].CurrencyIsoCode;
                pw.isPEsp = true;
            }
        }else{
            system.debug('no pasa linea 452'+idProd+',,,,cuenta,,,'+idAcc+'sucur'+idSuc);
        }     
        pw.preQty = pw.precio * fctCnv;
        return pw;
    } 
    public class PrecioWrapper {
        @AuraEnabled Decimal precio {get;set;}
        @AuraEnabled Decimal preQty {get;set;}
        @AuraEnabled String  moneda {get;set;}
        @AuraEnabled String  medida {get;set;}
        @AuraEnabled Boolean isPEsp {get;set;}
        public PrecioWrapper() {
            precio = 0;
            preQty = 0;
            moneda = '';
            medida = '';
            isPEsp = false;
        }
    }   
    /*
@Description:Asigna el precio actualizado a los items del Inventario
*/
    @AuraEnabled
    public static void actualizaPreciosItems(sObject[] lItems, String idSuc, String idAcc) {        
        Set<Id> setProducts = new Set<Id>(); 
        String idInventario = '';       
        
        for(POCH_DetalleInventario__c di : (List<POCH_DetalleInventario__c>) lItems) {
            if(String.isNotBlank(di.POCH_Producto__c))       { setProducts.add(di.POCH_Producto__c); }  
            if(String.isNotBlank(di.POCH_HojaInventario__c)) { idInventario = di.POCH_HojaInventario__c; }             
        }
        
        Map<Id,PricebookEntry> mapProduct_PBE = new Map<Id,PricebookEntry>();
        for(PricebookEntry pbe : [SELECT Id,Product2Id,POCH_UnidadMedida__c,Product2.QuantityUnitOfMeasure,POCH_UnidadMedidaEscala__c,Unidad_de_medida__c,UnitPrice,CurrencyIsoCode
                                  FROM PricebookEntry WHERE Product2Id IN : setProducts AND Pricebook2.POCH_Sucursal__r.Name =: idSuc AND IsActive = TRUE]) 
        {
            mapProduct_PBE.put(pbe.Product2Id,pbe);
        }
        
        Map<Id,Map<String,POCH_UnidadMedidaProducto__c>> mapPrd_UM = new Map<Id,Map<String,POCH_UnidadMedidaProducto__c>>();
        for(POCH_UnidadMedidaProducto__c umpr : [SELECT POCH_Producto__c, POCH_FactorConversion__c, POCH_Denominador__c, POCH_Numerador__c, POCH_UMA__c, POCH_UnidadPeso__c
                                                 FROM POCH_UnidadMedidaProducto__c WHERE POCH_Producto__c IN : setProducts])
        {
            if(mapPrd_UM.containsKey(umpr.POCH_Producto__c)) {
                mapPrd_UM.get(umpr.POCH_Producto__c).put(umpr.POCH_UMA__c, umpr);
            } else mapPrd_UM.put(umpr.POCH_Producto__c, new Map<String,POCH_UnidadMedidaProducto__c>{umpr.POCH_UMA__c => umpr});
        }
        
        Map<Id,List<SBQQ__DiscountTier__c>> mapProduct_DT = new Map<Id,List<SBQQ__DiscountTier__c>>();
        for(SBQQ__DiscountTier__c dt : [SELECT Id,SBQQ__Schedule__r.SBQQ__Product__c,POCH_ImporteCondicion__c,CurrencyIsoCode,SBQQ__Schedule__r.POCH_CantidadMinima__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c 
                                        FROM SBQQ__DiscountTier__c WHERE SBQQ__Schedule__r.SBQQ__Product__c IN : setProducts AND SBQQ__Schedule__r.SBQQ__Pricebook__r.POCH_Sucursal__r.Name =: idSuc ORDER BY SBQQ__Number__c ASC]) // =: pbook
        {
            if(mapProduct_DT.containsKey(dt.SBQQ__Schedule__r.SBQQ__Product__c)) {
                mapProduct_DT.get(dt.SBQQ__Schedule__r.SBQQ__Product__c).add(dt);
            } else mapProduct_DT.put(dt.SBQQ__Schedule__r.SBQQ__Product__c, new List<SBQQ__DiscountTier__c>{dt});
        }
        
        map<Id,SBQQ__ContractedPrice__c> mapProduct_PEsp = new Map<Id,SBQQ__ContractedPrice__c>();
        for(SBQQ__ContractedPrice__c cp : [SELECT Id,SBQQ__Product__c,SBQQ__Price__c,CurrencyIsoCode,POCH_UnidadMedida__c,POCH_UnidadMedidaEscala__c FROM SBQQ__ContractedPrice__c 
                                           WHERE SBQQ__Product__c IN : setProducts AND SBQQ__Account__c =: idAcc AND POCH_Sucursal__r.Name =: idSuc AND SBQQ__ExpirationDate__c >= TODAY]) 
        {
            mapProduct_PEsp.put(cp.SBQQ__Product__c, cp);
        }
        List<POCH_DetalleInventario__c> lDetalleInv_Upd = new List<POCH_DetalleInventario__c>();
        for(POCH_DetalleInventario__c di : (List<POCH_DetalleInventario__c>) lItems) {
            
            Decimal ctdBase   = String.isBlank(String.valueOf(di.POCH_CantidadBase__c))      ? 0 : Decimal.valueOf(String.valueOf(di.POCH_CantidadBase__c));
            Decimal ctdPotn_P = String.isBlank(String.valueOf(di.POCH_CantidadPotencial__c)) ? 0 : Decimal.valueOf(String.valueOf(di.POCH_CantidadPotencial__c));
            Decimal ctdBase_P = String.isBlank(String.valueOf(di.POCH_CantidadBase__c))      ? 0 : Decimal.valueOf(String.valueOf(di.POCH_CantidadBase__c)); 
            di.POCH_PrecioLista__c = '0.0';
            di.POCH_Moneda__c = 'MXN';
            di.POCH_uma__c = 'KG';
            
            if(mapPrd_UM.containsKey(di.POCH_Producto__c)) {
                String UMV = String.isBlank(di.POCH_UnidadMedida__c) ? '' : di.POCH_UnidadMedida__c.toUpperCase();
                String UMB = mapProduct_PBE.containsKey(di.POCH_Producto__c) ? (String.isNotBlank(mapProduct_PBE.get(di.POCH_Producto__c).Unidad_de_medida__c) ? mapProduct_PBE.get(di.POCH_Producto__c).Unidad_de_medida__c : mapProduct_PBE.get(di.POCH_Producto__c).Product2.QuantityUnitOfMeasure) : '';  //PBE unidad_de_medida
                String UMA = mapProduct_PBE.containsKey(di.POCH_Producto__c) ? mapProduct_PBE.get(di.POCH_Producto__c).POCH_UnidadMedida__c : '';                                
                
                ctdBase   = (ctdBase   * getQuantityUM(mapPrd_UM,di.POCH_Producto__c,UMV)) / getQuantityUM(mapPrd_UM,di.POCH_Producto__c,UMB);
                ctdBase_P = (ctdBase_P * getQuantityUM(mapPrd_UM,di.POCH_Producto__c,UMV)) / getQuantityUM(mapPrd_UM,di.POCH_Producto__c,UMA);
                ctdPotn_P = (ctdPotn_P * getQuantityUM(mapPrd_UM,di.POCH_Producto__c,UMV)) / getQuantityUM(mapPrd_UM,di.POCH_Producto__c,UMA);
            }
            if(mapProduct_PBE.containsKey(di.POCH_Producto__c)) {                  
                di.POCH_PrecioLista__c = String.valueOf(mapProduct_PBE.get(di.POCH_Producto__c).UnitPrice);
                di.POCH_Moneda__c      = mapProduct_PBE.get(di.POCH_Producto__c).CurrencyIsoCode;
                di.POCH_uma__c         = mapProduct_PBE.get(di.POCH_Producto__c).POCH_UnidadMedida__c;
            }
            if(mapProduct_DT.containsKey(di.POCH_Producto__c)) {                                    
                for(SBQQ__DiscountTier__c dt : mapProduct_DT.get(di.POCH_Producto__c)) {
                    if(dt.SBQQ__LowerBound__c <= ctdBase && (dt.SBQQ__UpperBound__c >= ctdBase || dt.SBQQ__UpperBound__c == NULL)) {
                        if(String.isNotBlank(String.valueOf(dt.POCH_ImporteCondicion__c))) { di.POCH_PrecioLista__c = String.valueOf(dt.POCH_ImporteCondicion__c); }
                    }
                }
            }
            if(mapProduct_PEsp.containsKey(di.POCH_Producto__c)) {
                if(String.isNotBlank(String.valueOf(mapProduct_PEsp.get(di.POCH_Producto__c).SBQQ__Price__c))) {
                    di.POCH_PrecioLista__c = String.valueOf(mapProduct_PEsp.get(di.POCH_Producto__c).SBQQ__Price__c);
                    di.POCH_Moneda__c      = mapProduct_PEsp.get(di.POCH_Producto__c).CurrencyIsoCode;
                }
            }
            if(String.isNotBlank(di.Id)) {     
                di.POCH_EsBase__c      = String.valueOf((ctdBase_P * Decimal.valueOf(String.valueOf(di.POCH_PrecioLista__c))).setScale(2, RoundingMode.HALF_UP));
                di.POCH_EsPotencial__c = String.valueOf((ctdPotn_P * Decimal.valueOf(String.valueOf(di.POCH_PrecioLista__c))).setScale(2, RoundingMode.HALF_UP));                
                
                di.POCH_CantidadBase__c        = String.valueOf(di.POCH_CantidadBase__c);
                di.POCH_CantidadPotencial__c   = String.valueOf(di.POCH_CantidadPotencial__c);
                di.POCH_CantidadCompetencia__c = String.valueOf(di.POCH_CantidadCompetencia__c);
                
                lDetalleInv_Upd.add(di);
            }            
        }
        
        if(!lDetalleInv_Upd.isEmpty()) {
            update lDetalleInv_Upd;
            
            if(String.isNotBlank(idInventario)) {
                POCH_HojaInventario__c hi = new POCH_HojaInventario__c();
                hi.Id = idInventario;
                hi.FechaActualizacionPrecios__c = Date.today();
                update hi;
            }
        }
    }    
    private static Decimal getQuantityUM(Map<Id,Map<String,POCH_UnidadMedidaProducto__c>> mapPrd_UM, Id Producto, String UM) {
        if(mapPrd_UM.get(Producto).containsKey(UM)) {
            return mapPrd_UM.get(Producto).get(UM).POCH_Numerador__c / mapPrd_UM.get(Producto).get(UM).POCH_Denominador__c;
        } else return 1;
    }
    /*
@Description:Obtiene datos iniciales de Inventario
*/
    @AuraEnabled
    public static POCH_HojaInventario__c getDataInv(String idInv) {
        return [SELECT POCH_Cuenta__c,POCH_Sucursal__c,POCH_Sucursal__r.Name,RequiereActualizacion__c FROM POCH_HojaInventario__c WHERE Id =: idInv];
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
    
    /**
    Metodo para obtener las frecuencias de cotizacion por pèrfil
    */
    @AuraEnabled
    public static List<String> getCountryListValues(String strObject) {
        List<String> lstReturnValues = new List<String>();
        if(strObject == 'POCH_FrecuenciaCotizacion__mdt') {    
            String strNameProfile = [SELECT Name FROM Profile where Id =: UserInfo.getProfileId()].Name;
            for(POCH_FrecuenciaCotizacion__mdt objIterateMdt :  [SELECT MasterLabel ,id , POCH_Fecuencia__c, POCH_Activo__c FROM POCH_FrecuenciaCotizacion__mdt WHERE MasterLabel =:strNameProfile AND POCH_Activo__c =: true ] ){
                lstReturnValues = objIterateMdt.POCH_Fecuencia__c.split(',');
            }    
        } else if(strObject == 'POCH_Competencia__c') {
            lstReturnValues.add('-NA-');
            for(POCH_Competencia__c objIterateCompetition :  [SELECT Name, Id, Activa__c FROM POCH_Competencia__c WHERE Activa__c =: true ORDER BY Name ASC] ){
                lstReturnValues.add(String.valueOf(objIterateCompetition.Name));
            } 
        }
        return lstReturnValues;
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
            //mapUnidadesMedidas.put (idProductoAux, listUnidadesMedidas);
            //listUnidadesMedidas.clear(); //add values into the map
        }
                 
        return listUnidadesMedidas;
    }

    /**
    Metodo para obtener acceso a los registros de detalle 
    */
    @AuraEnabled        
    public static Boolean getAccesDetalle(List<String> listIdDetalleInventario) {
        Boolean readAccess = false;
        List<POCH_UnidadMedidaProducto__c> listUnidadMedidaProducto = new List<POCH_UnidadMedidaProducto__c>();
        for (String idDetalleAux : listIdDetalleInventario) {
            for (POCH_DetalleInventario__Share listHojaDetShare : [SELECT Id, AccessLevel FROM POCH_DetalleInventario__Share WHERE UserOrGroupId =: UserInfo.getUserId()  AND ParentId =: idDetalleAux]){
                System.debug('print each detalle -> : ' + idDetalleAux +  ' -> ' + listHojaDetShare.AccessLevel);
                if (listHojaDetShare.AccessLevel == 'Read'){
                    readAccess = true;   
                }
            }
        }      
        return readAccess;
    }
}