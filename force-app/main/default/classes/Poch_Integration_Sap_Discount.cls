//No se esta utilizando, se mejoro a la version v2 en pochIntegrationSapDiscount
@RestResource(urlMapping='/integracionDiscount/*')
global with sharing class Poch_Integration_Sap_Discount {
    global class MyDiscuountClass {
        
        //Discount Schedules
        public String discountName;
        public String discountCurrency;
        public String discountPOCH_IDExterno;
        public String discountSIdProductoSap;
        public String discountPOCH_NoRegCondicion;
        public String discountSBQQDiscountUnit;
        public String  discountUnidad_Escala;
        //public decimal CurrencyIsoCodediscount;
        public decimal discountSBQQPriceScale;
        
        //Discount Tiers
        public String tiersName;
        public String tiersCurrency;
        public decimal tiersPOCHImporteCondicion;
        public decimal tiersPOCHImporteUpper;
        public decimal tiersSBQQDiscount;
        public decimal tiersSBQQNumber;
        public decimal tiersSBQQLowerBound;
        public decimal tiersUpperBound;
        public String tiersPOCHIdExterno;
        public String tiersPOCHNoRegistroCondicion;
        //public String TiersCurrencyIsoCode;        
    } 
    
    //Clase que define las variables que retornará el HTTP POST
    global class RegistrosConsulta{
        public List<SBQQ__DiscountSchedule__c> schedule = new List <SBQQ__DiscountSchedule__c>();
        public List<SBQQ__DiscountTier__c> tier = new List <SBQQ__DiscountTier__c>();   
    }
    
    @HttpPost
    global static void doPost(MyDiscuountClass[] Discount) { 
        //Declaramos la variable res que será utilizada para dar repuesta al servicio
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        
        //Declaramos las variables Nuevo y Nuevos2 para retornar en caso de ser exitoso
        List<RegistrosConsulta> Nuevos2= new List<RegistrosConsulta>();
        List<SBQQ__DiscountSchedule__c> stopschedule = new List<SBQQ__DiscountSchedule__c>();
        List<SBQQ__DiscountSchedule__c> stopschedule2 = new List<SBQQ__DiscountSchedule__c>();
        List<SBQQ__DiscountSchedule__c> scheduleUpd = new List<SBQQ__DiscountSchedule__c>();
        List<SBQQ__DiscountTier__c> stop = new List<SBQQ__DiscountTier__c>();
        List<SBQQ__DiscountTier__c> stop2 = new List<SBQQ__DiscountTier__c>();
        set<String> setIdStoTier = new set<String>();
        set<String> setIdStoSchedule = new set<String>();
        set<Id> setIdS = new set<Id>();
        boolean Data = false;
        set<Id> setIdSSchedule = new set<Id>();
        RegistrosConsulta Nuevos= new RegistrosConsulta();
        Savepoint sp = Database.setSavepoint();
        boolean upd = false;
        boolean upd2 = false;
        
        for (MyDiscuountClass i : Discount ){ 
            
            List <SBQQ__DiscountSchedule__c> schedule = [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                         SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c,ScheduleIdExterno__c,ScheduleIdProducto__c
                                                         FROM SBQQ__DiscountSchedule__c Where Name =: i.discountName];
            
            system.debug(schedule.size());
            system.debug(schedule);
            
            
            if(schedule.size()==0) {//Si es schedule No existe
                
                //Encontramos el producto segun el ID de SAP
                List <Product2 > producto = [SELECT Id, Name,POCH_IdProductoSAP__c FROM Product2  Where POCH_IdProductoSAP__c =: i.discountSIdProductoSap];
                system.debug(producto);
                
                //Encontramos la lista de precios
                List <Pricebook2> listaprecio = [SELECT Id,Name,POCH_IdExterno__c FROM Pricebook2 Where POCH_IdExterno__c  =: i.discountPOCH_IDExterno];
                system.debug(listaprecio);
                
                //Se Crea el Schedule
                SBQQ__DiscountSchedule__c scheduleNuevo = new SBQQ__DiscountSchedule__c();
                scheduleNuevo.Name = i.discountName;
                scheduleNuevo.CurrencyIsoCode = i.discountCurrency;
                scheduleNuevo.POCH_NoRegCondicion__c = i.discountPOCH_NoRegCondicion;
                scheduleNuevo.SBQQ__DiscountUnit__c = 'Percent';
                scheduleNuevo.SBQQ__Type__c = 'Range';    
                scheduleNuevo.Unidad_Escala__c = i.discountUnidad_Escala;
                scheduleNuevo.SBQQ__Product__c = producto[0].id;
                scheduleNuevo.SBQQ__Pricebook__c = listaprecio[0].id;
                insert scheduleNuevo;
                stopschedule.add(scheduleNuevo);
                setIdStoSchedule.add(i.discountPOCH_NoRegCondicion);
                system.debug(scheduleNuevo);
                
                //Se crea el tier
                SBQQ__DiscountTier__c discountTier = new SBQQ__DiscountTier__c();
                discountTier.Name = i.tiersName;
                discountTier.CurrencyIsoCode = i.tiersCurrency;
                discountTier.POCH_ImporteCondicion__c = i.tiersPOCHImporteCondicion;
                discountTier.POCH_ImporteUpper__c = i.tiersPOCHImporteUpper;
                discountTier.SBQQ__Discount__c = i.tiersSBQQDiscount;
                discountTier.SBQQ__Number__c = i.tiersSBQQNumber;
                discountTier.SBQQ__LowerBound__c = i.tiersSBQQLowerBound;
                discountTier.SBQQ__UpperBound__c = i.tiersUpperBound;
                discountTier.POCH_IdExterno__c = i.tiersPOCHIdExterno;
                discountTier.POCH_NoRegistroCondicion__c = i.tiersPOCHNoRegistroCondicion;
                discountTier.SBQQ__Schedule__c = scheduleNuevo.id;
                setIdStoTier.add(i.discountPOCH_NoRegCondicion);
                stop.add(discountTier);
                
            }else{ //El sino, de si el schedule SI existe lo actualiza
                for (SBQQ__DiscountSchedule__c schedulelst :  schedule){ 
                schedule[0].Name = i.discountName;
                schedule[0].CurrencyIsoCode = i.discountCurrency; 
                schedule[0].POCH_NoRegCondicion__c = i.discountPOCH_NoRegCondicion;
                schedule[0].SBQQ__DiscountUnit__c =  'Percent';
                schedule[0].SBQQ__Type__c = 'Range';   
                schedule[0].Unidad_Escala__c = i.discountUnidad_Escala;
                update schedule[0];
                system.debug(schedule[0]);    
                //stopschedule2.add(schedulelst);
                //system.debug(stopschedule2);
                }
                //system.debug(stopschedule2);
                upd = true;
                
                List <SBQQ__DiscountTier__c> Tier = [SELECT Id, SBQQ__Schedule__c,Name,POCH_ImporteCondicion__c,POCH_ImporteUpper__c,SBQQ__Discount__c,SBQQ__Number__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c,
                                                     POCH_IdExterno__c,POCH_NoRegistroCondicion__c,TierSchedule__c
                                                     FROM SBQQ__DiscountTier__c Where SBQQ__Schedule__r.id =: schedule[0].id];
                system.debug(Tier);
                delete Tier;
                system.debug(Tier);
                system.debug(Tier.size());
                
                SBQQ__DiscountTier__c discountTier = new SBQQ__DiscountTier__c();
                discountTier.Name = i.tiersName;
                discountTier.CurrencyIsoCode = i.tiersCurrency;
                discountTier.POCH_ImporteCondicion__c = i.tiersPOCHImporteCondicion;
                discountTier.POCH_ImporteUpper__c = i.tiersPOCHImporteUpper;
                discountTier.SBQQ__Discount__c = i.tiersSBQQDiscount;
                discountTier.SBQQ__Number__c = i.tiersSBQQNumber;
                discountTier.SBQQ__LowerBound__c = i.tiersSBQQLowerBound;
                discountTier.SBQQ__UpperBound__c = i.tiersUpperBound;
                discountTier.POCH_IdExterno__c = i.tiersPOCHIdExterno;
                discountTier.POCH_NoRegistroCondicion__c = i.tiersPOCHNoRegistroCondicion;
                discountTier.SBQQ__Schedule__c = schedule[0].id;
                setIdStoTier.add(i.discountPOCH_NoRegCondicion);
                stop.add(discountTier);
                //insert Stockdetail;
            }   
        }
        
        insert stop;
        //update stopschedule2;
        //upsert stopschedule;
        system.debug(stop.size());
        system.debug(stop);
        system.debug(stopschedule2);
        
        List <SBQQ__DiscountSchedule__c> descuentos = [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                       SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c
                                                       FROM SBQQ__DiscountSchedule__c Where POCH_NoRegCondicion__c  in : setIdStoTier]; 
        
        for (SBQQ__DiscountSchedule__c descuentos2 : [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                      SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c
                                                      FROM SBQQ__DiscountSchedule__c Where POCH_NoRegCondicion__c  in : setIdStoTier]) {
                                                          setIdS.add(descuentos2.id); 
                                                      }
        
        List <SBQQ__DiscountSchedule__c> descuent = [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                     SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c
                                                     FROM SBQQ__DiscountSchedule__c Where POCH_NoRegCondicion__c  in : setIdStoSchedule]; 
        
        for (SBQQ__DiscountSchedule__c descuent2 : [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                    SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c
                                                    FROM SBQQ__DiscountSchedule__c Where POCH_NoRegCondicion__c  in : setIdStoSchedule]) {
                                                        setIdSSchedule.add(descuent2.id); 
                                                    }
        
        system.debug('==VASRIOS IDIIDIDID=='+setIdS);
        system.debug('==VASRIOS IDIIDIDID=='+setIdSSchedule);
        system.debug('==INSERT =='+stop);
        
        
        List <SBQQ__DiscountSchedule__c> one = [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c,ScheduleIdExterno__c,ScheduleIdProducto__c
                                                FROM SBQQ__DiscountSchedule__c Where POCH_NoRegCondicion__c  in : setIdSSchedule];
        
        
        List <SBQQ__DiscountTier__c> two = [SELECT Id, SBQQ__Schedule__c,Name,POCH_ImporteCondicion__c,POCH_ImporteUpper__c,
                                            SBQQ__Discount__c,SBQQ__Number__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c,
                                            POCH_IdExterno__c,POCH_NoRegistroCondicion__c,TierSchedule__c
                                            FROM SBQQ__DiscountTier__c Where SBQQ__Schedule__c IN : setIdS];
        
        
        system.debug('==LOPPP DE BUSQUEDA=='+one);
        system.debug('==LOPPP DE BUSQUEDA=='+two);
        
        if (upd == true){
            Nuevos.schedule=stopschedule2;}else{
                Nuevos.schedule=stopschedule;}
        
        if (upd2 == true){
            Nuevos.tier=stop2;}else{
                Nuevos.tier=two;}
        
        Nuevos2.add(Nuevos);
        system.debug(Nuevos2);
        system.debug(Nuevos2.size());
        res.responseBody = Blob.valueOf(JSON.serialize(Nuevos2));
        res.statusCode = 200;    
    }
}