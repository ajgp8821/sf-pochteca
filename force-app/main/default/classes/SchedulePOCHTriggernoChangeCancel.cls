global class SchedulePOCHTriggernoChangeCancel implements Schedulable {
    global void execute(SchedulableContext sc) {
      
       Database.executeBatch(new POCH_CancelaQuoteForTime_Bch(), 1);
    }
}