trigger pochTriggerUpdateAlmacen on OrderItem (after update) {
    
    Set<Id> OrderItemIdForUpdate = new Set<Id> ();
    for (OrderItem item : trigger.new) {
        OrderItemIdForUpdate.add(item.Id);
        system.debug(OrderItemIdForUpdate);
    }
    
    OrderItem[] Almacenlst = [SELECT Id,OrderId, POCH_Almacen__c,AlmacenBoolean__c,Control_sf__c,AlmacenDeResumen__c FROM OrderItem WHERE Id IN :OrderItemIdForUpdate];
    system.debug(Almacenlst);
    
    OrderItem[] booleanlst = [SELECT Id,OrderId, POCH_Almacen__c,AlmacenBoolean__c,Control_sf__c,AlmacenDeResumen__c FROM OrderItem WHERE OrderId =: Almacenlst[0].OrderId];
    system.debug(booleanlst);
    system.debug(booleanlst.size());
   
    List <OrderItem> items = new list<OrderItem>();
    
    for(OrderItem totalLst : booleanlst) { 
        if(totalLst.AlmacenBoolean__c == true){
            items.add(totalLst);
        }     
    }
    
    system.debug(items);
    system.debug(items.size());
    
    List<Order> OrderForUpdate = [SELECT Almacen_de_inventario__c,Id 
                                  FROM Order
                                  WHERE Id =: Almacenlst[0].OrderId]; 
    
    system.debug(OrderForUpdate);
    
    for (Order order: OrderForUpdate) {
        if (booleanlst.size() == items.size()){
            order.AlmacenBooleanInv__c = true;}else{
                order.AlmacenBooleanInv__c = false;}
    }
    //order.Almacen_de_inventario__c = Almacenlst[0].POCH_Almacen__c;
    
    //update Almacenlst;  
    update OrderForUpdate;  
    system.debug(OrderForUpdate); 
}