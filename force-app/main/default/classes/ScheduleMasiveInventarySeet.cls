global class ScheduleMasiveInventarySeet implements Schedulable {
    global void execute(SchedulableContext sc) {
      
       Database.executeBatch(new POCH_QuoteBatch(), 1);
    }
}