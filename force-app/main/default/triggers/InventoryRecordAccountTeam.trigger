trigger InventoryRecordAccountTeam on POCH_HojaInventario__c (after insert, after update) {
    
    AccountTeamTriggerHandler.accountRecord(Trigger.New, Trigger.oldMap);

}