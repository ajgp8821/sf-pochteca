global class POCH_QuoteBatch_Sch implements Schedulable {

    global void execute(SchedulableContext sc) {
        POCH_QuoteBatch quoteBatch = new POCH_QuoteBatch();
        Database.executeBatch(quoteBatch, 1);
    }
    
}