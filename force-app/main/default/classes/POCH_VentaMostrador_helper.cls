public with sharing class POCH_VentaMostrador_helper {

    //Inner class to save any operation messages to allow us correct error and debug handling
   /* Public Class operationResult {
        @AuraEnabled public string successMessage{get;set;}
        @AuraEnabled public string errorMessage{get;set;}
        @AuraEnabled public string idRecord{get;set;}
        public operationResult() {
        }
    }

    //class to iterate and fill a list with data
    public static List<Ventas_Mostrador__c> fillProductList(List<Ventas_Mostrador__c> lstProducts, string inventorySheetId,String idBranchOffice) {
        List<Ventas_Mostrador__c> listToReturn = new List<Ventas_Mostrador__c>();                
        
        String idExtHI = [SELECT POCH_IdExterno__c FROM POCH_HojaInventario__c WHERE Id =: inventorySheetId LIMIT 1].POCH_IdExterno__c;
        
        Set<String> setProds = new Set<String>();
        for(Ventas_Mostrador__c objProducts : lstproducts){
            if(String.isNotBlank(objProducts.POCH_Producto__c)) { setProds.add(objProducts.POCH_Producto__c); }
        } 
        Map<Id,Product2> mapProds = new Map<Id,Product2>([SELECT Id,POCH_IdProductoSAP__c FROM Product2 WHERE Id IN : setProds]);
        
        for(Ventas_Mostrador__c objProducts : lstproducts) {
            objProducts.POCH_HojaInventario__c = inventorySheetId;
            objProducts.POCH_Sucursal__c =  idBranchOffice;                
            objProducts.POCH_PrecioLista__c =  String.valueOf(objProducts.POCH_PrecioLista__c);
            objProducts.POCH_EsBase__c =  String.valueOf(objProducts.POCH_EsBase__c);
            objProducts.POCH_EsPotencial__c =  String.valueOf(objProducts.POCH_EsPotencial__c);
            objProducts.CurrencyIsoCode = objProducts.POCH_Moneda__c;
            objProducts.POCH_CantidadBase__c = String.valueOf(objProducts.POCH_CantidadBase__c);
            objProducts.POCH_CantidadPotencial__c = String.valueOf(objProducts.POCH_CantidadPotencial__c);
            objProducts.POCH_CantidadCompetencia__c = String.valueOf(objProducts.POCH_CantidadCompetencia__c);
            objProducts.Moneda_competencia__c = String.valueOf(objProducts.Moneda_competencia__c);
            
            String idPrd = '';
            if(mapProds.containsKey(objProducts.POCH_Producto__c))
                idPrd = mapProds.get(objProducts.POCH_Producto__c).POCH_IdProductoSAP__c;
            objProducts.POCH_IdExterno__c = (String.isNotBlank(idExtHI) ? idExtHI : inventorySheetId) + (String.isNotBlank(idPrd) ? idPrd : objProducts.POCH_Producto__c); //inventorySheetId +''+ ext;
            System.debug(objProducts.POCH_IdExterno__c);
            listToReturn.add(objProducts);            
        }
        return listToReturn;
    }

    public static POCH_HojaInventario__c buildInventorySheet(String idBranchOffice, String strIdAccountRelated, String strIdRecordSheetInve, String strFrecuencyQuote) {
        POCH_HojaInventario__c inventorySheet = new POCH_HojaInventario__c();
        POCH_Sucursal__c sucursal = [Select Name,POCH_OrganizacionVentas__c FROM POCH_Sucursal__c Where id=:idBranchOffice];
        String IdCliente = '';
		Date fechaCotizacion = null;      
        if(string.isNotBlank(strIdRecordSheetInve)) {
        	inventorySheet.Id = strIdRecordSheetInve;
            POCH_HojaInventario__c hi = [SELECT POCH_FechaUltimaCotizacion__c FROM POCH_HojaInventario__c WHERE Id =: strIdRecordSheetInve LIMIT 1];
            if(hi.POCH_FechaUltimaCotizacion__c <> null)
                fechaCotizacion = hi.POCH_FechaUltimaCotizacion__c;
        }
        inventorySheet.POCH_Sucursal__c = idBranchOffice;   
        System.debug(strIdAccountRelated);
        if(string.isNotEmpty(strIdAccountRelated)) {
            inventorySheet.POCH_Cuenta__c = strIdAccountRelated;   
            Account acc = [SELECT POCH_IDCliente__c,POCH_IDClienteSAP__c FROM Account WHERE Id =: strIdAccountRelated];
            if(acc <> null) IdCliente = String.isBlank(acc.POCH_IDClienteSAP__c) ? String.valueOf(acc.POCH_IDCliente__c) : acc.POCH_IDClienteSAP__c;
        }
        inventorySheet.POCH_Sucursal__c = idBranchOffice;
        if(String.isNotEmpty(strFrecuencyQuote)) {
        	inventorySheet.POCH_FrecuenciaCotizacion__c = strFrecuencyQuote;    
        } 
        if(String.isEmpty(String.valueOf(fechaCotizacion))) {
        	inventorySheet.POCH_FechaUltimaCotizacion__c = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        }                
        inventorySheet.Name = sucursal.POCH_OrganizacionVentas__c +'_'+ IdCliente;
        inventorySheet.POCH_IdExterno__c = sucursal.POCH_OrganizacionVentas__c + IdCliente;
        
        return inventorySheet;
    }
    //determine if the record can be inserted based on "Branch office". False->inventorySheet Exist
    public static boolean checkInsert(String strIdRecordSheetInve,String idBranchOffice, String strIdAccountRelated) {
        if(string.isBlank(strIdRecordSheetInve)){
            List<POCH_HojaInventario__c> inventorySheet = [Select id,Name FROM POCH_HojaInventario__c Where  POCH_Cuenta__c= :strIdAccountRelated AND POCH_Sucursal__c=: idBranchOffice];
            return inventorySheet.size() > 0 ? false : true;
        } else{
            return true;
        }
    }

    public static POCH_InventorySheet_helper.operationResult dmlOpportunity(string dmlToDo,List<sObject> oppToUpdate) {
		System.debug('--> dmlToDo: ' + dmlToDo + ' - ' + oppToUpdate);
        POCH_InventorySheet_helper.operationResult operationResult = new POCH_InventorySheet_helper.operationResult();
        switch on  dmlToDo.toLowerCase() {
            when 'insert' , 'update'  {
                List<Database.SaveResult> result = dmlToDo.toLowerCase() == 'insert' ? Database.insert(oppToUpdate,false) : Database.update(oppToUpdate,false); 
                if(result[0].isSuccess()) {
                    operationResult.successMessage = System.label.POCH_Ok;
                    operationResult.idRecord       = result[0].getId();
                } else{
                    operationResult.errorMessage =  result[0].getErrors()[0].getMessage();
                }
            }
            when 'delete' {
                Database.DeleteResult[] result = Database.delete(oppToUpdate,false);
                if(result[0].isSuccess()) {
                    operationResult.successMessage = System.label.POCH_Ok;
                } else{
                    operationResult.errorMessage =  result[0].getErrors()[0].getMessage();
                }
            }
        }
        System.debug('ID dml' + oppToUpdate);
        return operationResult;
    }
    

    //if branchId doesn`t have a valid value then query it
    public static string setBranchOffice(String idBranchOffice,String strIdRecordSheetInve) {
        return string.isNotBlank(idBranchOffice) == false ? [Select Id,POCH_Sucursal__c FROM POCH_HojaInventario__c Where id=:strIdRecordSheetInve][0].POCH_Sucursal__c :  idBranchOffice;
    }
    
    //Consulta las divisas de las lineas de inventario
    public static Set<String> getLinesCurrencies(string inventorySheetId) {
        Set<String> setDIV = new Set<String>();
        for(Ventas_Mostrador__c hi : [SELECT POCH_Moneda__c FROM Ventas_Mostrador__c WHERE POCH_HojaInventario__c =: inventorySheetId AND POCH_Estatus__c = :System.label.POCH_activeStatus])
            setDIV.add(hi.POCH_Moneda__c);        
        return setDIV;
    }
    
    //Obtiene los PB Entries de las lineas de inventario
    public static Map<Id,Id> getPBEntries(string inventorySheetId) {
        Map<Id,Id>     mapPrdPBE = new Map<Id,String>();
        Map<Id,String> mapPrdDiv = new Map<Id,String>();
        Set<Id>        setIdPrd  = new Set<Id>();
        set<Id>        setIdSuc  = new Set<Id>();        
        for(Ventas_Mostrador__c hi : [SELECT POCH_Producto__c,POCH_HojaInventario__r.POCH_Sucursal__c,POCH_Moneda__c FROM Ventas_Mostrador__c 
                                            WHERE POCH_HojaInventario__c =: inventorySheetId AND POCH_Estatus__c = :System.label.POCH_activeStatus]) 
        {
            if(String.isNotBlank(hi.POCH_Moneda__c))                          { mapPrdDiv.put(hi.POCH_Producto__c, hi.POCH_Moneda__c); }
            if(String.isNotBlank(hi.POCH_Producto__c))                        { setIdPrd.add( hi.POCH_Producto__c); }
            if(String.isNotBlank(hi.POCH_HojaInventario__r.POCH_Sucursal__c)) { setIdSuc.add( hi.POCH_HojaInventario__r.POCH_Sucursal__c); }
        }
        
        for(PricebookEntry pbe : [SELECT Id,Product2Id,CurrencyIsoCode FROM PricebookEntry WHERE Product2Id IN : setIdPrd 
                                  AND Pricebook2.POCH_Sucursal__c IN : setIdSuc AND Pricebook2.IsStandard = FALSE AND IsActive = TRUE]) 
        {
            if(mapPrdDiv.containsKey(pbe.Product2Id))
                if(pbe.CurrencyIsoCode == mapPrdDiv.get(pbe.Product2Id))
                    mapPrdPBE.put(pbe.Product2Id, pbe.Id);                             
        }
        
        return mapPrdPBE;
    }

    //CREA UN OBJETO Y SU PRICEBOOKENTRY A PARTIR DE UNA LISTA DE MAPAS QUE REPRESENTA CADA CAMPO LLENADO EN EL FORMULARIO DEL COMPONENTE.
    public static POCH_InventorySheet_helper.operationResult manageProductObj(List<Map<String,Object>> productData, String idHI, String idSuc) {
        System.debug('--> idHI '  + idHI);
        System.debug('--> idSuc ' + idSuc);        
        POCH_InventorySheet_helper.operationResult operationResult = new POCH_InventorySheet_helper.operationResult();                       
        
        Product2 producto = new Product2();
        Ventas_Mostrador__c detalleInv = new Ventas_Mostrador__c();
        PriceBookEntry productEntry = new PriceBookEntry();		 
        
        transient sObject tempProduct = producto;
        transient sObject tempDetInvn = detalleInv;
        transient sObject tempPEEntry = productEntry;        

        for(Map<String,Object> input : productData) {
            System.debug('--> input ' + input);            
            String field      = (string)input.get('field');
            String toObject   = (string)input.get('tobject');
            String inputValue = (string)input.get('inputValue');			
            
            switch on toObject {
                when 'Product2' {
                    tempProduct.put(field,inputValue);
                    if(field == 'ProductCode') { tempProduct.put('POCH_IdProductoSAP__c', inputValue); }
                    if(field == 'ProductCode') { tempDetInvn.put('POCH_Codigo__c', inputValue); }
                    if(field == 'Name')        { tempDetInvn.put('Name', inputValue); }                                            
                }
                when 'Ventas_Mostrador__c' {
                    tempDetInvn.put(field,inputValue);
                    if(field == 'POCH_Moneda__c')       { tempPEEntry.put('CurrencyIsoCode', inputValue); }
                    if(field == 'POCH_PrecioLista__c')  { tempPEEntry.put('unitPrice', decimal.valueOf(inputValue)); }
                    if(field == 'POCH_UnidadMedida__c') { tempPEEntry.put('Unidad_de_medida__c', inputValue); }
                }
                when else {
                    operationResult.errorMessage = 'El objeto no está contemplado. Se contemplan productos y pricebookentry.';
                }
            }
        }
        
        producto = (Product2)tempProduct;
        detalleInv = (Ventas_Mostrador__c)tempDetInvn;
        productEntry = (PriceBookEntry)tempPEEntry;
        
        producto.isActive = true;
        producto.onlyInSalesforce__c = true;    
        producto.QuantityUnitOfMeasure = productEntry.Unidad_de_medida__c;
        operationResult = dmlOpportunity('insert',new List<sObject>{producto}); 
        System.debug('--> operationResult ' + operationResult);
                            
        String idExtHI = [SELECT POCH_IdExterno__c FROM POCH_HojaInventario__c WHERE Id =: idHI LIMIT 1].POCH_IdExterno__c;
        detalleInv.POCH_Estatus__c      = 'Inactivo';
        detalleInv.POCH_AquienCompra__c = 'Otros';
        detalleInv.POCH_CantidadBase__c = '0';
        detalleInv.POCH_CantidadPotencial__c = '0';
        detalleInv.POCH_EsBase__c = '0';
        detalleInv.POCH_EsPotencial__c = '0';
        if(String.isNotBlank(idHI) && String.isNotBlank(idSuc) && String.isNotBlank(producto.Id)) {
            detalleInv.POCH_Producto__c = producto.Id;    
            detalleInv.POCH_Sucursal__c = idSuc;
            detalleInv.POCH_HojaInventario__c = idHi;
            detalleInv.POCH_IdExterno__c = idExtHI + producto.Id;
            operationResult = dmlOpportunity('insert',new List<sObject>{detalleInv}); 
        }
                
        productEntry.isActive = true;
        if(String.isNotBlank(producto.Id) && String.isNotBlank(idSuc)) {
            productEntry.Product2Id = producto.id;                      
            Id idPB = POCH_InventorySheet_data.retrievePriceBook(idSuc);
            productEntry.IsActive = false;
            productEntry.POCH_UnidadMedidaEscala__c = productEntry.Unidad_de_medida__c;
            if(String.isNotBlank(idPB)) {
                productEntry.PriceBook2Id = idPB;
                operationResult = dmlOpportunity('insert',new List<sObject>{productEntry});
            }
        }
        
        POCH_UnidadMedidaProducto__c ump = new POCH_UnidadMedidaProducto__c();
        ump.POCH_Producto__c    = producto.Id;
        ump.POCH_UMA__c         = productEntry.Unidad_de_medida__c;
        ump.POCH_UnidadPeso__c  = productEntry.Unidad_de_medida__c;
        ump.POCH_Denominador__c = 1;        
        ump.POCH_Numerador__c   = 1;
        ump.POCH_IdExterno__c   = String.valueOf(producto.Id);
        insert ump;
        
        return operationResult;
    }
    //Elimina las oportunidades con error producto del boton cotizar de Hoja de Inv
    //@future
    public static void deleteOppsError(Set<Id> setIdOpps) {
        if(!setIdOpps.isEmpty())
        	delete [SELECT Id FROM Opportunity WHERE Id IN : setIdOpps];
    }*/

}