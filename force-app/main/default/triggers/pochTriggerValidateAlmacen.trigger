trigger pochTriggerValidateAlmacen on OrderItem (after update) {
    // Creamos una lista de ordenItem Vacia
    List<OrderItem> itemsToUpdate = new List<OrderItem>();
    List<OrderItem> itemsToUpdate2 = new List<OrderItem>(); 
    List<Stock_details__c> detallesToUpdate = new List<Stock_details__c>();
    boolean upd = false;
    
    //Creamos seteo vacio
    Set<Id> itemsIds = new Set<Id>();
    Set<Id> detallesIds = new Set<Id>();
    
    
    // Itera los items seleccionados
    for (OrderItem items : Trigger.new){
        itemsIds.add(items.id);
    }
    system.debug(itemsIds);
    
    // Buscar registros seleccionados
    List<OrderItem> orderItemList = [select Id,POCH_Almacen__c,AlmacenDeResumen__c,Control_sf__c from OrderItem where Id in:itemsIds];
    system.debug(orderItemList);
    
    List<Stock_details__c> detallesInventario = [SELECT Id,Name,POCH_Almacen__c
                                                 FROM Stock_details__c WHERE Control__c =: orderItemList[0].Control_sf__c];
    system.debug(detallesInventario);
    system.debug(detallesInventario.size());
    
    // Itera los items seleccionados
    /*for (Stock_details__c detalles : detallesInventario){
detallesIds.add(detalles.id);
}
system.debug(detallesIds);*/
    
    if(RecursiveHandler.IsNotRecursive){
        RecursiveHandler.IsNotRecursive = false;
        for (OrderItem orderItemRecord:orderItemList){
            for(Stock_details__c detalleRecord: detallesInventario){
                if(detalleRecord.POCH_Almacen__c == orderItemRecord.POCH_Almacen__c){
                    orderItemRecord.AlmacenDeResumen__c = true;
                    itemsToUpdate.add(orderItemRecord);
                    upd = true;
                    system.debug(itemsToUpdate);
                    system.debug(itemsToUpdate.size());
                    break;
                }else{ 
                    orderItemRecord.AlmacenDeResumen__c = false;
                    itemsToUpdate2.add(orderItemRecord);
                    upd = false;
                    system.debug(itemsToUpdate2);
                    system.debug(itemsToUpdate2.size());
                }
            }
        }
    }
    
    //create a map that will hold the values of the list 
    map<id,OrderItem> ordMap = new map<id,OrderItem>();
    
    system.debug(itemsToUpdate2);
    system.debug(upd);
    if(upd == true){
        ordMap.putall(itemsToUpdate);
        system.debug(ordMap);
        system.debug(ordMap.size());
        //if(ordMap.size()>0){
            update ordMap.values();
            system.debug(ordMap);//}
    }else{
        try{
        ordMap.putall(itemsToUpdate2);
        system.debug(ordMap);
        system.debug(ordMap.size());
        //update itemsToUpdate2; 
        // if(ordMap.size()>0){
            update ordMap.values();
            system.debug(ordMap); 
        }catch(dmlexception e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not insert account record. Error: ' + e));    
        }
        //}
    }
    
    system.debug(upd);
    /*if(upd != true){
          throw new applicationException('Debe elegir un almacen disponible en el resumen Stock');
    }*/
   
}