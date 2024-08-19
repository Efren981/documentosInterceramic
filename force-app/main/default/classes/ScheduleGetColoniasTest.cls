@isTest
public class ScheduleGetColoniasTest {
    @isTest
    static void testScheduleGetColonias() {
        // Create an instance of the Schedulable class
        ScheduleGetColonias schedulableInstance = new ScheduleGetColonias(5); // Provide the desired number of pages
        
        // Schedule the job
        String cronExp = '0 0 0 15 * ?'; // Specify the cron expression for scheduling (e.g., every 15th day of the month at 12:00 AM)
        String jobID = System.schedule('Test ScheduleGetColonias Job', cronExp, schedulableInstance);
        
        // Verify that the job was scheduled successfully
        System.assertNotEquals(null, jobID);
        
        // Get the scheduled job details
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobID];
        
        // Verify that the job's cron expression is set correctly
        System.assertEquals(cronExp, cronTrigger.CronExpression);
        
        // Verify that the job has not yet executed
        System.assertEquals(0, cronTrigger.TimesTriggered);
        
        // Cancel the scheduled job
        System.abortJob(jobID);
    }
}