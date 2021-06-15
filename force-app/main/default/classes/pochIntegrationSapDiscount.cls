@RestResource(urlMapping='/integracionDiscountV2/*')
global with sharing class pochIntegrationSapDiscount {
    global class MyDiscuountClass {
        
        //Discount Tiers
        public string scheduleName;
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
        public List<SBQQ__DiscountTier__c> tier = new List <SBQQ__DiscountTier__c>();   
    }
    
    @HttpPost
    global static void doPost(MyDiscuountClass[] Discount) { 
        //Declaramos la variable res que será utilizada para dar repuesta al servicio
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        
        //Declaramos las variables Nuevo y Nuevos2 para retornar en caso de ser exitoso
        List<RegistrosConsulta> Nuevos2= new List<RegistrosConsulta>();
        //List<SBQQ__DiscountSchedule__c> stopschedule = new List<SBQQ__DiscountSchedule__c>();
        List<SBQQ__DiscountTier__c> stop = new List<SBQQ__DiscountTier__c>();
        List<SBQQ__DiscountTier__c> stopDelete = new List<SBQQ__DiscountTier__c>();
        set<String> setIdStoTier = new set<String>();
        set<Id> setIdS = new set<Id>();
        boolean Data = false;
        set<Id> setIdSSchedule = new set<Id>();
        RegistrosConsulta Nuevos= new RegistrosConsulta();
        Savepoint sp = Database.setSavepoint();
        boolean upd = false;
        boolean upd2 = false;
        
        
        
        for (MyDiscuountClass i : Discount ){ 
            
            List <SBQQ__DiscountSchedule__c> scheduleLst = [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                            SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c,ScheduleIdExterno__c,ScheduleIdProducto__c
                                                            FROM SBQQ__DiscountSchedule__c Where Name =: i.scheduleName];
            
            
            List <SBQQ__DiscountTier__c> Tier = [SELECT Id, SBQQ__Schedule__c,Name,POCH_ImporteCondicion__c,POCH_ImporteUpper__c,SBQQ__Discount__c,SBQQ__Number__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c,
                                                 POCH_IdExterno__c,POCH_NoRegistroCondicion__c,TierSchedule__c
                                                 FROM SBQQ__DiscountTier__c Where SBQQ__Schedule__r.id =: scheduleLst[0].id];
            
            system.debug(Tier);
            system.debug(Tier.size());
            delete tier;
            
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
            discountTier.SBQQ__Schedule__c = scheduleLst[0].id;
            setIdStoTier.add(i.tiersPOCHNoRegistroCondicion);
            stop.add(discountTier);
            //insert Stockdetail;
        }
        //delete stopDelete;
        insert stop;
        
        List <SBQQ__DiscountSchedule__c> descuentos = [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                       SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c
                                                       FROM SBQQ__DiscountSchedule__c Where POCH_NoRegCondicion__c  in : setIdStoTier]; 
        
        for (SBQQ__DiscountSchedule__c descuentos2 : [SELECT Id,Name, SBQQ__Product__c,SBQQ__Type__c,POCH_NoRegCondicion__c,SBQQ__DiscountUnit__c,
                                                      SBQQ__Pricebook__c,POCH_PrecioMinimo__c,SBQQ__PriceScale__c,Unidad_Escala__c
                                                      FROM SBQQ__DiscountSchedule__c Where POCH_NoRegCondicion__c  in : setIdStoTier]) {
                                                          setIdS.add(descuentos2.id); 
                                                      }
        
        system.debug('==VASRIOS IDIIDIDID=='+setIdStoTier);
        system.debug('==INSERT =='+stop); 
                
        List <SBQQ__DiscountTier__c> two = [SELECT Id, SBQQ__Schedule__c,Name,POCH_ImporteCondicion__c,POCH_ImporteUpper__c,
                                            SBQQ__Discount__c,SBQQ__Number__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c,
                                            POCH_IdExterno__c,POCH_NoRegistroCondicion__c,TierSchedule__c
                                            FROM SBQQ__DiscountTier__c Where POCH_NoRegistroCondicion__c IN : setIdStoTier];
        
        system.debug('==LOPPP DE BUSQUEDA=='+two);

        Nuevos.tier=two;
        
        Nuevos2.add(Nuevos);
        system.debug(Nuevos2);
        system.debug(Nuevos2.size());
        res.responseBody = Blob.valueOf(JSON.serialize(Nuevos2));
        res.statusCode = 200; 
    }
}