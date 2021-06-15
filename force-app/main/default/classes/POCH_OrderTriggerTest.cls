@isTest(SeeAllData = False)
public class POCH_OrderTriggerTest {
    public static testMethod void testOrder() {
        POCH_TriggerSettings__c ts = POCH_DataCreationTest.getTrgSettings();
        insert ts;
        
        POCH_Region__c reg = POCH_DataCreationTest.getRegion();
        insert reg;
        
        Account acc = POCH_DataCreationTest.getAccount();
        acc.POCH_Region__c = reg.Id;
        acc.POCH_TipoRegistro__c = 'Prospecto';
        insert acc;
        
        POCH_Sucursal__c suc = POCH_DataCreationTest.getSucursal();
        insert suc;
        
        POCH_SucursalAmpliada__c sam = POCH_DataCreationTest.getSucursalAmp();
        sam.POCH_Cliente__c  = acc.Id;
        sam.Poch_Sucursal__c = suc.Id;
        insert sam;
        
        Pricebook2 pb = POCH_DataCreationTest.getCustomPricebook();
        pb.POCH_Sucursal__c = suc.Id;
        insert pb;
        
        Set<Id> setQuoteSPANCOP   = new Set<Id>();
        Set<Id> setIdQuoteTrigger = new Set<Id>();
        Opportunity opp = POCH_DataCreationTest.getOpportunity();
        opp.AccountId   = acc.Id;
        opp.StageName   = 'Sospechoso';
        opp.POCH_Sucursal__c = suc.id;
        opp.POCH_MontoOrdenes__c = 0;
        
        //opp.SBQQ__PrimaryQuote__c = qt.Id;
        upsert opp;
        
        SBQQ__Quote__c qt = POCH_DataCreationTest.getQuote();
        qt.SBQQ__Account__c = acc.Id;
        qt.POCH_Sucursal__c = suc.Id;
        qt.SBQQ__Primary__c = true;
        qt.SBQQ__Opportunity2__c = opp.Id;
        
        insert qt;
        
        User usr = [SELECT Id,POCH_OrganizacionesVentas__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        usr.POCH_OrganizacionesVentas__c = '0049;0023;0015;0019;0101';
        update usr;
        
        Product2 prd = POCH_DataCreationTest.getProduct();
        insert prd;
        
        PricebookEntry pbe  = POCH_DataCreationTest.getPBEntry();
        pbe.Pricebook2Id = pb.Id;
        pbe.Product2Id   = prd.Id;
        insert pbe;
        

        Order ord1 = POCH_DataCreationTest.getOrder();
        Opportunity op = new Opportunity();
        ord1.OpportunityId = opp.Id;  
        ord1.AccountId     = acc.Id;
        ord1.Pricebook2Id  = pb.Id; 
        ord1.POCH_CFDI__c = 'G01';
        ord1.POCH_Incoterm_list__c = 'CFR';
        //  ord1.POCH_FormaPago__c = '1';
        ord1.CurrencyIsoCode = 'MXN';
        ord1.SBQQ__Quote__c  = qt.id;
        ord1.Cancelado__c= true;
        ord1.POCH_EnviadoSAP__c = true;
        ord1.SBQQ__Contracted__c = false;
        ord1.Status = 'Alta';
        ord1.IsReductionOrder = false;
        ord1.EffectiveDate = date.today();
        ord1.OwnerId = usr.Id;
        
        Order ord2 = POCH_DataCreationTest.getOrder();
        ord2.OpportunityId = opp.Id;
        ord2.AccountId     = acc.Id;
        ord2.Pricebook2Id  = pb.Id;
        ord2.POCH_CFDI__c = 'G01';
        ord2.POCH_Incoterm_list__c = 'CFR';
        //  ord2.POCH_FormaPago__c = '1';
        ord2.CurrencyIsoCode = 'MXN';
        ord2.SBQQ__Quote__c  = qt.id;
        ord2.Cancelado__c= true;
        ord2.POCH_EnviadoSAP__c = true;
        ord2.SBQQ__Contracted__c = false;
        ord2.Status = 'Alta';
        ord2.IsReductionOrder = false;
        ord2.EffectiveDate = date.today();
        ord2.OwnerId = usr.Id;
        setQuoteSPANCOP.add(ord1.OpportunityId);
        
        try{
            Order ord3 = POCH_DataCreationTest.getOrder();
            ord3.OpportunityId = opp.Id;
            ord3.AccountId     = acc.Id;
            ord3.Pricebook2Id  = pb.Id;
            insert ord3;
            ord3.Status = 'Alta';
            update ord3;
            delete ord3;
        }
        catch(Exception e){
            
        }
        
        try
			{
				Delete 	ord1;
			}
			catch(Exception ee)
			{}
        
        List<Order> lOrd = new List<Order>{ord1,ord2};
         //     insert lOrd;
            try{
               insert lOrd;
            }  catch(exception e){
                e.getMessage();
            }
        
        // Map <  Id,  Order > mapOrder = new Map < Id, Order >([SELECT Id, PoNumber From Order WHERE Id IN : lOrd]);
        opp.POCH_MontoOrdenes__c = ord1.TotalAmount;
        update opp;
        
        
        OrderItem oi = POCH_DataCreationTest.getOrderItem();
        oi.Product2Id = prd.Id;
        oi.OrderId = lOrd[0].Id;
        oi.PricebookEntryId = pbe.Id;
        oi.Quantity = 24.55;
        oi.SBQQ__Activated__c = true;
        oi.SBQQ__Contracted__c = false;
        oi.PosicionSAP__c = ord1.PoNumber + oi.Posici_n__c;
        try{
            upsert oi; 
        }catch(exception e){
            e.getMessage();
        }
        
       
        
        
        
        System.debug('--> UPDATE');
        POCH_OrderTriggerService.esInvocadoPorTrigger = false;
        lOrd[0].Status = 'Liberado a SAP';
        //  lOrd[0].OpportunityId = opp.Id;
        try{
            update lOrd[0]; 
        }catch(exception e){
            e.getMessage();
        }
        test.startTest();
        //POCH_OrderTriggerService ob= new POCH_OrderTriggerService();
        POCH_OrderTriggerHandler.beforeDelete(lOrd);
     //   POCH_OrderTriggerService.avoidDeleteOrders(lOrd);
        POCH_OrderTriggerService.accumulateOrderAmountinSPANCOP(lOrd);
        POCH_OrderTriggerService.deleteOrderNotSelected(lOrd);
        
        //POCH_OrderTriggerService.updateChildField(lOrd);
        test.stopTest();
            
    }
    
    
}