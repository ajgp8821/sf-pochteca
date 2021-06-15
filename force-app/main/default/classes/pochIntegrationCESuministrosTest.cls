@IsTest
public class pochIntegrationCESuministrosTest {
    static TestMethod void pochIntegrationCESuministrosTest(){ 
        
        date mydate = date.parse('1/12/2021');
        
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
        insert lstProduct;
        
        CE_Suministradores__c sumis = new CE_Suministradores__c(); 
        sumis.Id_Producto_SAP__c = '00001';
        sumis.Name = '963330049';
        sumis.Centro__c='GDTX';
        sumis.Material__c =lstProduct[0].id;
        sumis.Organizacion_de_ventas__c='0049';
        insert sumis;
        
        // Get standard price book ID.
        Id pricebookId = Test.getStandardPricebookId();
        system.debug(pricebookId);
        
        List<Pricebook2> standardPB = [select id from Pricebook2 where isStandard=true];
        System.debug(standardPB);
        System.debug(standardPB.size() > 0); // false 
        
        // Create a custom price book 
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        insert customPB;
        system.debug(customPB);
        
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        system.debug(reg);
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal();
        insert suc;
        system.debug(suc);
        
        Account acc = POCH_DataCreationTest.getAccount();
        acc.POCH_TipoRegistro__c = 'Prospecto';
        acc.POCH_Region__c = reg.Id;
        insert acc;
        system.debug(acc);
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        system.debug(sam);
        
        User usr = [SELECT Id,POCH_OrganizacionesVentas__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        usr.POCH_OrganizacionesVentas__c = '0049;0023;0015;0019;0101';
        update usr;
        
        pochIntegrationCESuministros.MyCeSumClass ce = new pochIntegrationCESuministros.MyCeSumClass();
        List< pochIntegrationCESuministros.MyCeSumClass> CeList = new List<pochIntegrationCESuministros.MyCeSumClass>();
        ce.suministroCentro ='GDTX';
		ce.suministroIdProductoSap ='00001';
        ce.suministroName =	'9633300499';
        ce.suministroOrg ='0049';
        CeList.add(ce);
        
        system.debug(CeList[0]);        
        test.startTest();
        
        //POST
        String JSONMsg= JSON.serialize(CeList);
        RestRequest req = new RestRequest();
        req.requestURI = '/integracionSuministros/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        req.requestBody = Blob.valueof(JSONMsg); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        system.debug(JSONMsg);
        
        pochIntegrationCESuministros.doPost(CeList);      
        Test.stopTest();
    } 
}