@RestResource(urlMapping='/integracionSuministros/*')
global with sharing class pochIntegrationCESuministros {
    global class MyCeSumClass {
        
        //Campos a llegar de suministros
        public String suministroName; 
        public String suministroIdProductoSap;
        public String suministroCentro;  
        public String suministroOrg;
        
    }
    
    //Clase que define las variables que retornará el HTTP POST
    global class RegistrosConsulta{
        public List<CE_Suministradores__c> suministrosFn = new List <CE_Suministradores__c>();  
    }
    
    @HttpPost
    global static void doPost(MyCeSumClass[] suministros) { 
        //Declaramos la variable res que será utilizada para dar repuesta al servicio
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        
        //Declaramos las variables para retornar en caso de ser exitoso
        RegistrosConsulta suministrosOk= new RegistrosConsulta();
        List<RegistrosConsulta> suministrosOk2 = new List<RegistrosConsulta>();
        List<CE_Suministradores__c> suministrosLstUpd = new List<CE_Suministradores__c>();
        List<CE_Suministradores__c> suministrosIns = new List<CE_Suministradores__c>();
        boolean upd = false;
        
        for (MyCeSumClass i : suministros ){
            
            List <CE_Suministradores__c> suministrosLst = [SELECT id,Name,Sucursal__c,Id_Producto_SAP__c,Material__c,Centro__c,Organizacion_de_ventas__c 
                                                           FROM CE_Suministradores__c WHERE Name =: i.suministroName];
            
            system.debug(suministrosLst.size());
            system.debug(suministrosLst);
            
            List <POCH_Sucursal__c	> SucursalLst = [SELECT id,Name,POCH_OrganizacionVentas__c,POCH_OficinaVentas__c,POCH_Centro__c 
                                                     FROM POCH_Sucursal__c WHERE POCH_OrganizacionVentas__c =: i.suministroOrg];
            
            system.debug(SucursalLst.size());
            system.debug(SucursalLst);
            
            List <Product2 > producto = [SELECT Id, Name,POCH_IdProductoSAP__c FROM Product2  Where POCH_IdProductoSAP__c =: i.suministroIdProductoSap];
            system.debug(producto);
            
            system.debug(producto.size());
            system.debug(producto);
            
            if(suministrosLst.size() > 0 ) {
                for (CE_Suministradores__c suministrosUpd :  suministrosLst){
                    suministrosUpd.Name = i.suministroName;
                    suministrosUpd.Id_Producto_SAP__c = i.suministroIdProductoSap;
                    suministrosUpd.Centro__c = i.suministroCentro;
                    suministrosUpd.Organizacion_de_ventas__c =  i.suministroOrg;
                    suministrosUpd.Material__c = producto[0].Id; 
                    suministrosUpd.Sucursal__c = SucursalLst[0].Id; 
                    suministrosLstUpd.add(suministrosUpd);
                    //upd = true; 
                } 
            }else{
                CE_Suministradores__c suministroNuevo = new CE_Suministradores__c();
                suministroNuevo.Name = i.suministroName;
                suministroNuevo.Id_Producto_SAP__c = i.suministroIdProductoSap;
                suministroNuevo.Centro__c = i.suministroCentro;
                suministroNuevo.Organizacion_de_ventas__c =  i.suministroOrg;
                suministroNuevo.Material__c = producto[0].Id;
                suministroNuevo.Sucursal__c = SucursalLst[0].Id; 
                suministrosLstUpd.add(suministroNuevo);      
            }  
        }
        
        upsert suministrosLstUpd;
        //insert suministrosIns;
        system.debug(suministrosLstUpd);
        //system.debug(suministrosIns);
        
        //if (upd == true){
            suministrosOk.suministrosFn=suministrosLstUpd;//}else{
                system.debug(suministrosOk);
                //suministrosOk.suministrosFn=suministrosIns;//}
        //system.debug(suministrosOk);
        
        suministrosOk2.add(suministrosOk);
        system.debug(suministrosOk2);
        system.debug(suministrosOk2.size());
        res.responseBody = Blob.valueOf(JSON.serialize(suministrosOk2));
        res.statusCode = 200;  
    }
}