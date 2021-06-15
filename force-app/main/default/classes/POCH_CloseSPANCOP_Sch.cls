global class POCH_CloseSPANCOP_Sch implements Schedulable {
    
    global void execute(SchedulableContext sc) {
		POCH_CloseSPANCOP_Bch spancopBCH = new POCH_CloseSPANCOP_Bch();
		Database.executeBatch(spancopBCH, 1);
    }

}