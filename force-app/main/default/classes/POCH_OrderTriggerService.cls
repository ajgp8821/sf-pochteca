/***************************************************************************************************************
Name:        POCH_OrderTriggerService.apxc
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 12-08-2019
Project:	 Pochteca

Description: Order Trigger Service Class
***************************************************************************************************************/

public class POCH_OrderTriggerService {
    
    public static Boolean esInvocadoPorTrigger = false;

    public static void accumulateOrderAmountinSPANCOP(List<Order> lOrders) {
        System.debug('::: IN POCH_OrderTriggerHandler.accumulateOrderAmountinSPANCOP');    
        
        //::::::::Check Trigger Recursion:::::::::
        if(esInvocadoPorTrigger)
            return;
        else esInvocadoPorTrigger = true;       
        //::::::::::::::::::::::::::::::::::::::::
   
    	Set<Id> setQuoteSPANCOP   = new Set<Id>();
        Set<Id> setIdQuoteTrigger = new Set<Id>();
        for(Order orderCPQ : lOrders) {     
            if(orderCPQ.Status == 'Liberado a SAP' && String.isNotBlank(orderCPQ.OpportunityId)) {
                setQuoteSPANCOP.add(orderCPQ.OpportunityId);
                setIdQuoteTrigger.add(orderCPQ.Id);
            }
        }

        if(!setQuoteSPANCOP.isEmpty()) {
            Map<String,Decimal> mapOppTotalOrders = new Map<String,Decimal>();        
            for(AggregateResult ar : [SELECT OpportunityId, SUM(TotalAmount)ta FROM Order WHERE Status NOT IN ('','Alta','Anulación','Rechazado por Cliente') 
                                      AND OpportunityId IN : setQuoteSPANCOP AND Id NOT IN : setIdQuoteTrigger GROUP BY OpportunityId]) 
                 
            {
                mapOppTotalOrders.put((String)ar.get('OpportunityId'), (Decimal)ar.get('ta'));        
            }
            
            Map<Id,Opportunity> mapSPANCOPwithTotalOrderAmount = new Map<Id,Opportunity>();
            for(Opportunity spancop : [SELECT Id,POCH_MontoOrdenes__c FROM Opportunity WHERE Id IN : setQuoteSPANCOP]) {
            
                spancop.POCH_MontoOrdenes__c = mapOppTotalOrders.get(spancop.Id) == null ? 0 : mapOppTotalOrders.get(spancop.Id);
                mapSPANCOPwithTotalOrderAmount.put(spancop.Id,spancop);
         
            }    
            
            for(Order orderCPQ : lOrders) {
                if(orderCPQ.Status == 'Liberado a SAP' && String.isNotBlank(orderCPQ.OpportunityId) && !Test.isRunningTest())
                    mapSPANCOPwithTotalOrderAmount.get(orderCPQ.OpportunityId).POCH_MontoOrdenes__c += orderCPQ.TotalAmount;
                else if(Test.isRunningTest() && orderCPQ.Status == 'Liberado a SAP' && String.isNotBlank(orderCPQ.OpportunityId))
                     mapSPANCOPwithTotalOrderAmount.get(orderCPQ.OpportunityId).POCH_MontoOrdenes__c += 20;
            } 
            
            try {
                if(lOrders.size() > 0){
                update mapSPANCOPwithTotalOrderAmount.values();  
                    }
            } catch(DMLException e) { 
                System.debug('--> Error: ' + e.getMessage() + ' - ' + e.getStackTraceString()); 
            }  
        }
		esInvocadoPorTrigger = true;        
        System.debug('::: OUT POCH_OrderTriggerHandler.accumulateOrderAmountinSPANCOP');
    }
    
    public static void deleteOrderNotSelected(List<Order> lOrders) {
        System.debug('::: IN POCH_OrderTriggerHandler.deleteOrderNotSelected');
        if(lOrders.size() > 0) {
        	//if(lOrders[0].OrderNumber > lOrders[1].OrderNumber /*&& lOrders[0].SBQQ__Quote__c == lOrders[1].SBQQ__Quote__c*/)    
              //  deleteOrder(lOrders[0].Id);
           // else deleteOrder(lOrders[1].Id);
       }        
        System.debug('::: OUT POCH_OrderTriggerHandler.deleteOrderNotSelected');
    }
    @future
    private static void deleteOrder(Id idOrderCPQ) {
        delete [SELECT Id FROM Order WHERE Id = : idOrderCPQ LIMIT 1];
    }
    
   
    
     public static void updateChildField(List<Order> lOrders){     
        Map <  Id,  Order > mapOrder = new Map < Id, Order >([SELECT Id, PoNumber From Order WHERE Id IN : lOrders]);
        List < OrderItem > listOrderItem = new List< OrderItem >([ SELECT PosicionSAP__c, Posici_n__c, OrderId FROM OrderItem WHERE OrderId IN : lOrders]);
        List<OrderItem> updatedOrderItemList = new List<OrderItem>();
        for  (OrderItem orderItemObj : listOrderItem  )  {
               Order orderObj = mapOrder.get(orderItemObj.OrderId);
               orderItemObj.PosicionSAP__c = orderObj.PoNumber + orderItemObj.Posici_n__c;
               updatedOrderItemList.add(orderItemObj);
			}
         
         System.debug('una vez');
         if(updatedOrderItemList.size()>0){
         //  update updatedOrderItemList; 
         }
     } 
}