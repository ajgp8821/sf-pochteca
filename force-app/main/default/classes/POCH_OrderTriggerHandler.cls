/***************************************************************************************************************
Name:        POCH_OrderTriggerHandler.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 12-08-2019
Project:	 Pochteca

Description: Order Trigger Handler Class
***************************************************************************************************************/

public class POCH_OrderTriggerHandler {      
    
    public static void beforeDelete(List<Order> lOrderTrigger) {
	//	POCH_OrderTriggerService.avoidDeleteOrders(lOrderTrigger);        
    }
    public static void afterInsert(List<Order> lOrderTrigger) {
        POCH_OrderTriggerService.deleteOrderNotSelected(lOrderTrigger);
      //   POCH_OrderTriggerService.validateOnStatus(lOrderTrigger);
        POCH_OrderTriggerService.updateChildField(lOrderTrigger);
    }
    public static void afterUpdate(List<Order> lOrderTrigger) {
        POCH_OrderTriggerService.accumulateOrderAmountinSPANCOP(lOrderTrigger);
         POCH_OrderTriggerService.updateChildField(lOrderTrigger);
    }
    

    
}