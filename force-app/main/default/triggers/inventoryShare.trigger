trigger inventoryShare on POCH_HojaInventario__c (before insert, before update) {
    
      InventoryClienteTriggerHandler.shareRecord(trigger.new, trigger.oldMap);
    
}