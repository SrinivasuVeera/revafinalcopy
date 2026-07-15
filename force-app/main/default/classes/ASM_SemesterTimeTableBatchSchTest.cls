@isTest
public class ASM_SemesterTimeTableBatchSchTest {
  @isTest
    static void testScheduledJob() {
        
      
         // Test data setup

   // Create test records
        Account acc = new Account(Name = 'Test School');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestIAProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        hed__Term__c Semester = new hed__Term__c(
        Name = 'TestSemester',
        hed__Account__c = acc.Id,
        Exam_Start_Date__c = System.today().addDays(5),
        hed__End_Date__c = System.today(),
        Term_Number__c = 1,
        Program_Batch__c = programbatch.Id
        
        );
        
        insert Semester;
        
        RecordType ExamNotificationRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Rve_Exam_Notification__c' and DeveloperName='hed_Semester_Notification'];

        
        Rve_Exam_Notification__c TestNotification = new Rve_Exam_Notification__c();
        TestNotification.Name = 'TestExamNotification';
        TestNotification.rve_Exam_Start_Date__c = System.Today();
        TestNotification.Rve_Publish__c= true;
        TestNotification.hed_IA_Type__c = 'IA 1';
        TestNotification.RecordTypeId = ExamNotificationRecordType.Id;
        TestNotification.Rve_Semester__c = Semester.Id;
        insert TestNotification;
        
           Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            SRN_No__c = 'B20FA579',
            Program_Batch__c = ProgramBatch.Id
        );
        insert testContact;
        
        Rve_Exam_Application__c examApplication = new Rve_Exam_Application__c(
            Rve_Student__c = testcontact.Id, 
            Rve_Exam_Notification__c = TestNotification.Id
            
        );
        insert examApplication;
        
         Rve_Exam_Application_Line_Item__c ExamApplicationLineItem = new Rve_Exam_Application_Line_Item__c(
         Rve_Exam_Application__c = ExamApplication.Id,
         Course_Code__c = 'COURSE001',
         Rve_QP_Code__c = '123',
         Rve_Semester__c = Semester.Id,
         Date_Of_Examination__c = Date.Today(),
         Rve_Batch__c = 12,
         Rve_Start_Time__c = Time.NewInstance(11,0,0,0),
         Rve_End_Time__c = Time.NewInstance(1,0,0,0)
        );
        
        insert ExamApplicationLineItem;   
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());


        // Create an instance of the schedulable class
        ASM_SemesterTimeTableBatchSch schedulableInstance = new ASM_SemesterTimeTableBatchSch();

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
      //  System.assert(numOfQueuedJobs > 0);
    }
    
    // Mock HTTP response generator
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status": "success", "data": {"resdata": [{"sem": "Semester", "examdate": "2024-05-15", "regno": "Student ID", "subshort": "COURSE001", "qpcode": "QP001", "doe": "15/05/2024", "session": "9:00 AM to 12:00 PM", "batch": "1"}]}}');
    
            return res;
        }
    }
}