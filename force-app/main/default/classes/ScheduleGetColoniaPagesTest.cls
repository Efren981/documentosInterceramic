@IsTest
private class ScheduleGetColoniaPagesTest {
    @IsTest
    static void testSchedule() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"COLONIAS": []}');
        
        Test.setMock(HttpCalloutMock.class, new QueueableGetColoniaPagesMock(mockResponse));
        
        // Enqueue the scheduled job
        Test.startTest();
        ScheduleGetColoniaPages scheduledJob = new ScheduleGetColoniaPages();
        String cronExpression = '0 0 0 15 3 ? 2025'; // Set the desired cron expression
        System.schedule('Test Schedule', cronExpression, scheduledJob);
        Test.stopTest();

        // Verify the scheduled job has been enqueued
        List<CronTrigger> cronTriggers = [SELECT Id, CronExpression, CronJobDetail.Name, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'Test Schedule'];
        System.assertEquals(1, cronTriggers.size());
    }
    
    private class QueueableGetColoniaPagesMock implements HttpCalloutMock {
        HttpResponse mockResponse;
        
        public QueueableGetColoniaPagesMock(HttpResponse mockResponse) {
            this.mockResponse = mockResponse;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return mockResponse;
        }
    }
}