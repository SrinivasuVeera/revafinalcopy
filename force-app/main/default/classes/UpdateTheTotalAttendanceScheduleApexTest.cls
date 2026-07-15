@isTest
public class UpdateTheTotalAttendanceScheduleApexTest {
    @isTest
    static void testScheduleApex() {
        // Schedule the class
        String cronExpression = '0 0 3 * * ?';
        String jobName = 'Test Attendance Update Schedule';

        Test.startTest();
        // Schedule the job
        String jobId = System.schedule(jobName, cronExpression, new UpdateTheTotalAttendanceScheduleApex());
        Test.stopTest();
        
    }

   
}