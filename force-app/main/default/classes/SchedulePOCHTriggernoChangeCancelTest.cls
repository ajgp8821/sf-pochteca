@isTest
public class SchedulePOCHTriggernoChangeCancelTest {
 
     @isTest static void test_ScheduleRefresh() {
        test.startTest();
    
        String jobId = System.schedule('testBasicScheduledApex', '0 0 0 3 9 ? 2022', new SchedulePOCHTriggernoChangeCancel());
        test.stopTest();
    }
}