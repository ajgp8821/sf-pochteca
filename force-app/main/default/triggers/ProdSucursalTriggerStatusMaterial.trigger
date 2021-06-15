trigger ProdSucursalTriggerStatusMaterial on POCH_ProductoSucursal__c (after insert,after update) {
 /*   
    if (trigger.isAfter && trigger.isInsert) {
        Set<Id> caseIDs = new Set<Id> ();
        Set<String> OrgVentIDs = new Set<String>();
        //POCH_OrganizacionVentas__c
        Set<Id> sucIDs = new Set<Id> ();
        list<string> Ma=new list<string>();  
        for (POCH_ProductoSucursal__c pd : Trigger.new) {
            OrgVentIDs.add(pd.Organizaci_n_de_Ventas__c);
            caseIDs.add(pd.POCH_Producto__c);
            Ma.add(pd.POCH_Estatus_Material__c);
            sucIDs.add(pd.id);
            system.debug('producto============================================))))))))'+caseIDs+'PROBANDO DATOS'+OrgVentIDs);
        }
        PricebookEntry [] PricebookEntrys = [SELECT id ,UnitPrice,Product2Id,ProductCode,POCH_OrganizacionVentas__c,Name,CurrencyIsoCode,Product2.ProductCode,Product2.POCH_GrupoMateriales2__c,Product2.Name,Product2.Description FROM PricebookEntry WHERE IsActive = true  AND Product2.IsActive = true  AND Product2.id IN : caseIDs and POCH_OrganizacionVentas__c IN : OrgVentIDs];
        system.debug('PricebookEntrys============================================))))))))'+PricebookEntrys[0].Product2Id+'PROBANDO POCH_OrganizacionVentas__c'+PricebookEntrys[0].POCH_OrganizacionVentas__c+'POCH_GrupoMateriales2__c'+PricebookEntrys[0].Product2.POCH_GrupoMateriales2__c);
        
        
        List<PricebookEntry> prodAdd = new List<PricebookEntry>();
        if(PricebookEntrys.size() > 0){
            for (PricebookEntry pbe: PricebookEntrys) { 
                
                pbe.Grupo_de_Materiales__c = Ma.get(0);
                prodAdd.add(pbe);
                
            }
        }
        //database.Update(prodAdd,true);
        update prodAdd;
    }
    if (trigger.isAfter && trigger.isUpdate) {
        Set<Id> caseIDs = new Set<Id> ();
        Set<String> OrgVentIDs = new Set<String>();
        //POCH_OrganizacionVentas__c
        Set<Id> sucIDs = new Set<Id> ();
        list<string> Ma=new list<string>();  
        for (POCH_ProductoSucursal__c pd : Trigger.new) {
            OrgVentIDs.add(pd.Organizaci_n_de_Ventas__c);
            caseIDs.add(pd.POCH_Producto__c);
            Ma.add(pd.POCH_Estatus_Material__c);
            sucIDs.add(pd.id);
            system.debug('producto============================================))))))))'+caseIDs+'PROBANDO DATOS'+OrgVentIDs);
        }
        PricebookEntry [] PricebookEntrys = [SELECT id ,UnitPrice,Product2Id,ProductCode,POCH_OrganizacionVentas__c,Name,CurrencyIsoCode,Product2.ProductCode,Product2.POCH_GrupoMateriales2__c,Product2.Name,Product2.Description FROM PricebookEntry WHERE IsActive = true  AND Product2.IsActive = true  AND Product2.id IN : caseIDs and POCH_OrganizacionVentas__c IN : OrgVentIDs];
        system.debug('PricebookEntrys============================================))))))))'+PricebookEntrys[0].Product2Id+'PROBANDO POCH_OrganizacionVentas__c'+PricebookEntrys[0].POCH_OrganizacionVentas__c+'POCH_GrupoMateriales2__c'+PricebookEntrys[0].Product2.POCH_GrupoMateriales2__c);
        
        
        List<PricebookEntry> prodAdd = new List<PricebookEntry>();
        if(PricebookEntrys.size() > 0){
            for (PricebookEntry pbe: PricebookEntrys) { 
                
                pbe.Grupo_de_Materiales__c = Ma.get(0);
                prodAdd.add(pbe);
                
            }
        }
        //database.Update(prodAdd,true);
        update prodAdd;
    }
*/
}