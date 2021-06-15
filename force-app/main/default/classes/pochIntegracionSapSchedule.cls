@RestResource(urlMapping='/integracionSchedule/*')
global with sharing class pochIntegracionSapSchedule {
    global class MyScheduleClass {
        
        //Discount Schedules
        public String scheduleName;
        public String scheduleCurrency;
        public String schedulePOCH_IDExterno;
        public String scheduleIdProductoSap;
        public String schedulePOCH_NoRegCondicion;
        public String scheduleSBQQDiscountUnit;
        public String scheduleUnidad_Escala;
        //public decimal CurrencyIsoCodediscount;
        public decimal scheduleSBQQPriceScale;
        
    }
    //Clase que define las variables que retornará el HTTP POST
    global class RegistrosConsulta{
        public List<SBQQ__DiscountSchedule__c> schedules = new List <SBQQ__DiscountSchedule__c>();  
    }
    
    @HttpPost
    global static void doPost(MyScheduleClass[] schedule) { 
        //Declaramos la variable res que será utilizada para dar repuesta al servicio
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        
        //Declaramos las variables Nuevo y Nuevos2 para retornar en caso de ser exitoso
        List<RegistrosConsulta> Nuevos2= new List<RegistrosConsulta>();
        List<SBQQ__DiscountSchedule__c> stopschedule = new List<SBQQ__DiscountSchedule__c>();
        List<SBQQ__DiscountSchedule__c> schedulesLstUpd = new List<SBQQ__DiscountSchedule__c>();
        set<String> setIdStoTier = new set<String>();
        set<String> setIdStoSchedule = new set<String>();
        set<Id> setIdS = new set<Id>();
        boolean Data = false;
        set<Id> setIdSSchedule = new set<Id>();
        RegistrosConsulta Nuevos= new RegistrosConsulta();
        Savepoint sp = Database.setSavepoint();
        boolean upd = false;
        boolean upd2 = false;
        
        for (MyScheduleClass i : schedule ){ 
            
            List <SBQQ__DiscountSchedule__c> scheduleLst = [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                            SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c,ScheduleIdExterno__c,ScheduleIdProducto__c
                                                            FROM SBQQ__DiscountSchedule__c Where Name =: i.scheduleName];
            
            system.debug(scheduleLst.size());
            system.debug(scheduleLst);
            
            if(scheduleLst.size() > 0 ) {
                for (SBQQ__DiscountSchedule__c schedulesUpd :  scheduleLst){
                    schedulesUpd.Name = i.scheduleName;
                    schedulesUpd.CurrencyIsoCode = i.scheduleCurrency; 
                    schedulesUpd.POCH_NoRegCondicion__c = i.schedulePOCH_NoRegCondicion;
                    schedulesUpd.SBQQ__DiscountUnit__c =  'Percent';
                    schedulesUpd.SBQQ__Type__c = 'Range';   
                    schedulesUpd.Unidad_Escala__c = i.scheduleUnidad_Escala; 
                    setIdStoSchedule.add(i.schedulePOCH_NoRegCondicion);
                    schedulesLstUpd.add(schedulesUpd);
                } 
                upd = true; 
            }else{
                //Encontramos el producto segun el ID de SAP
                List <Product2 > producto = [SELECT Id, Name,POCH_IdProductoSAP__c FROM Product2  Where POCH_IdProductoSAP__c =: i.scheduleIdProductoSap];
                system.debug(producto);
                
                //Encontramos la lista de precios
                List <Pricebook2> listaprecio = [SELECT Id,Name,POCH_IdExterno__c FROM Pricebook2 Where POCH_IdExterno__c  =: i.schedulePOCH_IDExterno];
                system.debug(listaprecio);
                
                
                SBQQ__DiscountSchedule__c scheduleNuevo = new SBQQ__DiscountSchedule__c();
                scheduleNuevo.Name = i.scheduleName;
                scheduleNuevo.CurrencyIsoCode = i.scheduleCurrency;
                scheduleNuevo.POCH_NoRegCondicion__c = i.schedulePOCH_NoRegCondicion;
                scheduleNuevo.SBQQ__DiscountUnit__c = 'Percent';
                scheduleNuevo.SBQQ__Type__c = 'Range';    
                scheduleNuevo.Unidad_Escala__c = i.scheduleUnidad_Escala;
                scheduleNuevo.SBQQ__Product__c = producto[0].id;
                scheduleNuevo.SBQQ__Pricebook__c = listaprecio[0].id;
                //insert scheduleNuevo;
                stopschedule.add(scheduleNuevo);
                setIdStoSchedule.add(i.schedulePOCH_NoRegCondicion);
                system.debug(scheduleNuevo);
            }
        }
        update schedulesLstUpd;
        insert stopschedule;
        system.debug(stopschedule.size());
        system.debug(stopschedule);
        system.debug(schedulesLstUpd);
        system.debug(schedulesLstUpd.size());
        
        List <SBQQ__DiscountSchedule__c> descuent = [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                     SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c
                                                     FROM SBQQ__DiscountSchedule__c Where POCH_NoRegCondicion__c  in : setIdStoSchedule]; 
        
        for (SBQQ__DiscountSchedule__c descuent2 : [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                    SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c
                                                    FROM SBQQ__DiscountSchedule__c Where POCH_NoRegCondicion__c  in : setIdStoSchedule]) {
                                                        setIdSSchedule.add(descuent2.id); 
                                                    }
        
        system.debug('==VASRIOS IDIIDIDID=='+setIdSSchedule);
        system.debug('==INSERT =='+stopschedule); 
        
        
        List <SBQQ__DiscountSchedule__c> one = [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c,ScheduleIdExterno__c,ScheduleIdProducto__c
                                                FROM SBQQ__DiscountSchedule__c Where POCH_NoRegCondicion__c  in : setIdSSchedule];
        
        system.debug('==LOPPP DE BUSQUEDA=='+one);
        
        if (upd == true){
            Nuevos.schedules=schedulesLstUpd;}else{
                Nuevos.schedules=stopschedule;} 
        
        Nuevos2.add(Nuevos);
        system.debug(Nuevos2);
        system.debug(Nuevos2.size());
        res.responseBody = Blob.valueOf(JSON.serialize(Nuevos2));
        res.statusCode = 200;  
    }
}