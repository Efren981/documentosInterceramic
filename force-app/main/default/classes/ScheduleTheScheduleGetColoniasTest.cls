@IsTest
public class ScheduleTheScheduleGetColoniasTest {
    
    @IsTest
    static void testExecute() {
        // Create test data for Colonia_Pagination__c
        Colonia_Pagination__c coloniaPage = new Colonia_Pagination__c(Pages__c = 5);
        insert coloniaPage;
        
        // Create a mock of SchedulableContext
        Test.startTest();
        Test.setMock(System.SchedulableContext.class, new TestSchedulableContext());
        
        // Create an instance of ScheduleTheScheduleGetColonias and invoke execute
        ScheduleTheScheduleGetColonias scheduler = new ScheduleTheScheduleGetColonias();
        scheduler.execute(null);
        Test.stopTest();
    }
    
    // Mock class for SchedulableContext
    public class TestSchedulableContext implements System.SchedulableContext {
        public String getTriggerId() {
            return null;
        }
        public Map<String, Object> getJobData() {
            return null;
        }
        public Integer getRetryCount() {
            return null;
        }
    }
}