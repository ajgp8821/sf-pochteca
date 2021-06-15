trigger AccountInventroyTrigger on Account (before insert, before update, after update) {

    if(Trigger.isAfter){
        
        if(Trigger.isUpdate){
            AccountInventoryHelper.updateOwner(Trigger.oldMap, Trigger.new);
        }
    }
    if (trigger.isBefore && trigger.isInsert){ 
        AccountInventoryHelper.updateCurrency(Trigger.New);
    }
    if (trigger.isBefore && trigger.isUpdate){ 
        AccountInventoryHelper.updateCurrency(Trigger.New);
    }
}