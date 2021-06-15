@IsTest 
public class pochIntegracionSapScheduleTest {
    
    static TestMethod void pochIntegracionSapScheduleTest(){
        
        Date fechafin = Date.parse('31/12/2021');
        Date fecha = Date.today();
        
        List <Product2> lstProduct = new List<Product2>();
        Product2 one = new Product2(); 
        one.POCH_IdProductoSAP__c = '00001';
        one.Name = 'STRETCH MANUAL';
        one.Family='E-CAJA';
        one.POCH_Linea__c ='EMPAQUE';
        one.POCH_Division__c='MAQUINARIA / EMPAQUE / EMBALAJE';
        one.QuantityUnitOfMeasure='KG';
        one.POCH_UnidadesMedida__c='KG, PZ,';
        one.POCH_GrupoMateriales2__c = 'LINEA';
        lstProduct.add(one);
        
        Product2 two = new Product2(); 
        two.POCH_IdProductoSAP__c = '00002';
        two.Name = 'STRETCH MANUAL 222';
        two.Family='E-CAJA';
        two.POCH_Linea__c ='EMPAQUE';
        two.POCH_Division__c='MAQUINARIA / EMPAQUE / EMBALAJE';
        two.QuantityUnitOfMeasure='KG';
        two.POCH_UnidadesMedida__c='KG, PZ,';
        two.POCH_GrupoMateriales2__c = 'LINEA';
        lstProduct.add(two);
        
        insert lstProduct;
        system.debug(lstProduct);  
        //system.debug(lstProduct.size());
        
        Pricebook2 libro = new Pricebook2(); 
        libro.Name = 'Test';
        Libro.POCH_IdExterno__c = '0007';
        libro.Description = 'testdescription';
        libro.IsActive = true;
        insert libro;
        
        SBQQ__DiscountSchedule__c scheduleNuevo = new SBQQ__DiscountSchedule__c();
        scheduleNuevo.Name = '221420019';
        scheduleNuevo.POCH_NoRegCondicion__c = '51728';
        scheduleNuevo.CurrencyIsoCode = 'MXN';
        scheduleNuevo.SBQQ__DiscountUnit__c = 'Percent';
        scheduleNuevo.SBQQ__Type__c = 'Range';    
        scheduleNuevo.Unidad_Escala__c = 'Kg';
        scheduleNuevo.SBQQ__Product__c = lstProduct[0].id;
        scheduleNuevo.SBQQ__Pricebook__c = libro.id;
        insert scheduleNuevo;
        
        
        List<SBQQ__DiscountSchedule__c> result = new list <SBQQ__DiscountSchedule__c> ();
        List<SBQQ__DiscountSchedule__c> result2 = new list <SBQQ__DiscountSchedule__c> ();
        List<Product2> result3 = new list <Product2> ();
        List<Pricebook2> result4 = new list <Pricebook2> ();
        
        result =  [SELECT Id
                   FROM SBQQ__DiscountSchedule__c Where id =: scheduleNuevo.id]; 
        system.debug(result);
        
        result2 =  [SELECT Id
                    FROM SBQQ__DiscountSchedule__c Where id =: result[0].id]; 
        system.debug(result2);
        
        result3 =  [SELECT Id,POCH_IdProductoSAP__c
                    FROM Product2 Where id =: lstProduct[0].id]; 
        system.debug(result3);
        
        result4 =  [SELECT Id,POCH_IdExterno__c
                    FROM Pricebook2 Where id =: libro.id]; 
        system.debug(result4);
        
        pochIntegracionSapSchedule.MyScheduleClass schedule = new pochIntegracionSapSchedule.MyScheduleClass();
        pochIntegracionSapSchedule.MyScheduleClass schedule2 = new pochIntegracionSapSchedule.MyScheduleClass();
        
        List<pochIntegracionSapSchedule.MyScheduleClass> scheduleList = new List< pochIntegracionSapSchedule.MyScheduleClass>();
        schedule.scheduleName='221420019';
        schedule.schedulePOCH_IDExterno = '0007';
        schedule.scheduleCurrency = 'MXN';
        schedule.scheduleIdProductoSap= '00001';
        schedule.schedulePOCH_NoRegCondicion= '51728';
        schedule.scheduleUnidad_Escala='KG';
        //discount.tiersPOCHNoRegistroCondicion= '51728';
        scheduleList.add(schedule);
        
        schedule2.scheduleName='219340118';
        schedule2.schedulePOCH_IDExterno = '0007';
        schedule2.scheduleCurrency = 'MXN';
        schedule2.scheduleIdProductoSap= '00002';
        schedule2.schedulePOCH_NoRegCondicion= '2133198111';
        schedule2.scheduleUnidad_Escala='KG';
        //discount2.tiersPOCHNoRegistroCondicion= '2133198111';
        scheduleList.add(schedule2);
        
        system.debug(scheduleList[0]);

        test.startTest();
        
        //POST
        String JSONMsg= JSON.serialize(scheduleList);
        RestRequest req = new RestRequest();
        req.requestURI = '/integracionSchedule/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        req.requestBody = Blob.valueof(JSONMsg); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        system.debug(JSONMsg);
        
        pochIntegracionSapSchedule.doPost(scheduleList);        
        Test.stopTest(); 
    }
}