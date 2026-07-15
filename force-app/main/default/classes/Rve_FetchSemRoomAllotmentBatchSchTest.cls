@isTest

public class Rve_FetchSemRoomAllotmentBatchSchTest {
  @isTest
    static void testScheduledJob() {
        
      
        Account acc = new Account(Name='TestAcc');
        insert acc;

        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
          Contact con = new Contact();
        con.FirstName = 'suraj';
        con.LastName = 'Madala';
        con.Program_Batch__c = ProgramBatch.Id;
        con.SRN_Number__c='SA001';
        con.Active__c=true;
        insert con;
        
        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name = 'Course1';
        objCourse.hed__Account__c = acc.Id;
        objCourse.hed__Course_ID__c = 'CRS001';
        insert objCourse;
        
        // Create Semester (hed__Term__c)
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.Exam_Start_Date__c = Date.today().addDays(-30);
        semester.Exam_End_Date__c = Date.today().addDays(30);        
        insert semester;
        system.debug('test semester>>'+semester);

        Rve_Exam_Notification__c TestNotification = new Rve_Exam_Notification__c();
        TestNotification.Name = 'Test';
        TestNotification.rve_Exam_Start_Date__c = System.Today();
        TestNotification.Rve_Publish__c = true;
        TestNotification.hed_Program_Batch__c = ProgramBatch.Id;
        TestNotification.hed_IA_Type__c = 'IA 1';
        TestNotification.Rve_Semester__c = semester.id;
        insert TestNotification;
        

        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());


        // Create an instance of the schedulable class
        Rve_FetchSemesterRoomAllotmentBatchSch schedulableInstance = new Rve_FetchSemesterRoomAllotmentBatchSch();

        // Schedule the job
        String jobId = System.schedule('Test Scheduled Job', '0 0 12 * * ?', schedulableInstance);
        
        // Verify the scheduled job exists
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];

        System.assertEquals('0 0 12 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertNotEquals(null, ct.NextFireTime);

        // Now, let's simulate the execution of the scheduled job
        Test.startTest();
        // Here we invoke the scheduled job execution, which will enqueue the batch job
        // Salesforce will take care of invoking the execute method
        Test.stopTest();

        // Check that the batch job has been enqueued
        Integer numOfQueuedJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status IN ('Queued', 'Processing', 'Completed')];
        System.assert(numOfQueuedJobs > 0);
    }
    // Mock HTTP response generator
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status": "success", "data": {"resdata": [{"sem": "Semester", "examdate": "2024-05-15", "regno": "SA001", "subshort": "CRS001", "qpcode": "QP001", "doe": "15/05/2024", "session": "9:00 AM to 12:00 PM", "batch": "1"}]}}');     
            return res;
        }
    }
}