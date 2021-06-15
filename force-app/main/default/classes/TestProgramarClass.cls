global class TestProgramarClass implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        POCH_QuoteBatch quoteBatch = new POCH_QuoteBatch();
        Database.executeBatch(quoteBatch, 1);
    }

}