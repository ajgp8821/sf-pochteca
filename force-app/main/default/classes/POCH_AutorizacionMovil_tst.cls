@isTest
public class POCH_AutorizacionMovil_tst {
    
    @TestSetup
    static void createData() {
        POCH_AutorizacionMovil__c am = new POCH_AutorizacionMovil__c();
        am.Comentarios__c = 'cmts';
        am.CurrencyIsoCode = 'MXN';
		am.Incoterm__c = 'inm';
        am.POCH_Aprobador__c = UserInfo.getUserId();
        am.POCH_Aprobador1__c = UserInfo.getUserId();
        am.POCH_Aprobador2__c = UserInfo.getUserId();
        am.POCH_Aprobador3__c = UserInfo.getUserId();
        am.POCH_Aprobador4__c = UserInfo.getUserId();
        am.POCH_Cliente__c = 'ACC';
        am.POCH_NumeroPedido__c = 'P0018';
        am.POCH_Plazo__c= '12';
        am.POCH_Sucursal__c = 'METRO';
        am.POCH_Vendedor__c = UserInfo.getUserId();
        am.Estatus__c = 'Pendiente por Aprobar';
        am.POCH_PedidoDuplicado__c = false;
        am.POCH_SendResponseSAP__c = false;
        insert am;
        
        POCH_DetalleAutorizacion__c da = new POCH_DetalleAutorizacion__c();
        da.POCH_Almancen__c = 'ALM';
        da.POCH_AutorizacionMovil__c = am.Id;
		da.POCH_Cantidad__c = 5;
        da.POCH_Costo__c = 10;
        da.POCH_PorcentajeUtil__c = 50;
        da.POCH_Precio__c = 4;
        da.POCH_Producto__c = 'PRD';
        da.POCH_Utilidad__c = 5;
        insert da;
        
        
        POCH_AutorizacionMovil__c aum = new POCH_AutorizacionMovil__c();
        aum.Comentarios__c = 'cmts';
        aum.CurrencyIsoCode = 'MXN';
		aum.Incoterm__c = 'inm';
        aum.POCH_Aprobador__c = UserInfo.getUserId();
        aum.POCH_Aprobador1__c = UserInfo.getUserId();
        aum.POCH_Aprobador2__c = UserInfo.getUserId();
        aum.POCH_Aprobador3__c = UserInfo.getUserId();
        aum.POCH_Aprobador4__c = UserInfo.getUserId();
        aum.POCH_Cliente__c = 'ACCC';
        aum.POCH_NumeroPedido__c = 'P00188';
        aum.POCH_Plazo__c= '12';
        aum.POCH_Sucursal__c = 'METRO';
        aum.POCH_Vendedor__c = UserInfo.getUserId();
        aum.POCH_PedidoDuplicado__c = true;
        aum.POCH_SendResponseSAP__c = true;
        insert aum;
        
         POCH_AutorizacionMovil__c aumo = new POCH_AutorizacionMovil__c();
        aumo.Comentarios__c = 'cmts';
        aumo.CurrencyIsoCode = 'MXN';
		aumo.Incoterm__c = 'inm';
        aumo.POCH_Aprobador__c = UserInfo.getUserId();
        aumo.POCH_Aprobador1__c = UserInfo.getUserId();
        aumo.POCH_Aprobador2__c = UserInfo.getUserId();
        aumo.POCH_Aprobador3__c = UserInfo.getUserId();
        aumo.POCH_Aprobador4__c = UserInfo.getUserId();
        aumo.POCH_Cliente__c = 'ACCCC';
        aumo.POCH_NumeroPedido__c = 'P001888'; 
        aumo.POCH_Plazo__c= '12';
        aumo.POCH_Sucursal__c = 'METRO';
        aumo.POCH_Vendedor__c = UserInfo.getUserId();
        aumo.Estatus__c = 'Pendiente por Aprobar';
        aumo.POCH_PedidoDuplicado__c = false;
        aumo.POCH_SendResponseSAP__c = false;
        insert aumo;
    }
        
    
    class TestDataWrapper {
        public POCH_AutorizacionMovil__c   autMov {get;set;}
        public POCH_DetalleAutorizacion__c detAut {get;set;}
        public testDataWrapper() {
            this.autMov = [SELECT Id FROM POCH_AutorizacionMovil__c   LIMIT 1];
            this.detAut = [SELECT Id FROM POCH_DetalleAutorizacion__c LIMIT 1];
        }
    }
    
    @IsTest
    static void testApprReq() {
        Test.startTest();
        	TestDataWrapper tdw = new TestDataWrapper();
        
        	POCH_AutorizacionMovil__c am = POCH_AutorizacionMovilDetalle_ctrl.getDetallesPedido(tdw.autMov.Id);
        	System.assertEquals(tdw.autMov.Id, am.Id, 'Id de Pedido encontrado');	
        
        	String appReq = POCH_AutorizacionMovilDetalle_ctrl.getIdApprovalRequest(tdw.autMov.Id);
        
        	POCH_AutorizacionMovilDetalle_ctrl.getApprovalComments(tdw.autMov.Id); 
        
        	User usr = getUser();
        	insert usr;
        
        	tdw.autMov.POCH_Aprobador4__c = usr.Id;
        	update tdw.autMov;

        
        	String strDes = POCH_AutorizacionMovilDetalle_ctrl.makeApprovalDecision(tdw.autMov.Id, appReq, 'Approve', 'Test Comments');
        	System.assertEquals('OK', strDes, 'Aprobado correcamente');
        
        	POCH_AutorizacionMovilHandler.updatePedidoExistente(tdw.autMov.Id, usr.Id, usr.Id, usr.Id, usr.Id, usr.Id);
 } 
    
	static User getUser() {
        return new User(Alias = 'aseriv', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Asesor', LanguageLocaleKey='es_Mx', LocaleSidKey='es_MX', 
                        ProfileId = [SELECT Id FROM Profile WHERE Name Like '%Admin%' LIMIT 1].Id, TimeZoneSidKey='America/Los_Angeles', UserName='asesor@pochteca.com');
    }    

}