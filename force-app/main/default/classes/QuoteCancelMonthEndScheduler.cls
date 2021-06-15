global class QuoteCancelMonthEndScheduler implements Schedulable {
    global void execute(SchedulableContext sc){        
        QuoteCancelMonthEndBatch batch = new QuoteCancelMonthEndBatch();
        Database.executeBatch(batch,5);        
    }
}