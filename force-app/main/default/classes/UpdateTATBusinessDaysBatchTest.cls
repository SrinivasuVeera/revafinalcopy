@IsTest
private class UpdateTATBusinessDaysBatchTest {
    // Mock class to simulate HTTP response for callouts
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }
    @TestSetup
    static void createTestData() {
        Account createAccount = new Account(
            Name = 'School of Civil Engineering'
        );
        insert createAccount;
        
        hed__Program_Plan__c programBatchRec = new hed__Program_Plan__c(
            Name = 'School of Civil Engineering',
            hed__Account__c = createAccount.Id,
            hed__Start_Date__c =  Date.parse('01/01/2026')
        );
        insert programBatchRec;
        // Contact
        Contact con = new Contact(
            LastName = 'Test Applicant',
            Application_Fee_Paid__c = true,
            Application_Fee_Paid_Date__c = System.today(),
            Disposition__c = '',
            Description1__c = '',
            TAT_Status__c = '',
            TAT_Business_Days__c =8,
            Program_Batch__c = programBatchRec.id
        );
        insert con;
        
        // Application
        hed__Application__c app = new hed__Application__c(
            hed__Applicant__c = con.Id,
            Partial_Paid__c = false
        );
        insert app;
        
        // Student Fee Record
        Student_Payment__c fee = new Student_Payment__c(
            Contact__c = con.Id,
            Fee_Type__c = 'Application Fee',
            Payment_Date_Time__c = System.now().addDays(-5),
            Payment_Status__c = 'Success'
        );
        insert fee;
    }
    
    @IsTest
    static void testBatchExecution() {
        
        Test.startTest();
        
        UpdateTATBusinessDaysBatch batchObj =
            new UpdateTATBusinessDaysBatch();
        
        Database.executeBatch(batchObj, 200);
        
        Test.stopTest();
        
        Contact con = [
            SELECT Id,
            TAT_Business_Days__c
            FROM Contact
            LIMIT 1
        ];
        
        
    }
    
    @IsTest
    static void testScheduler() {
        
        Test.startTest();
        
        String cronExp = '0 0 17 * * ?';
        
        System.schedule(
            'Test Update TAT Scheduler',
            cronExp,
            new UpdateTATBusinessDaysScheduler()
        );
        
        Test.stopTest();
        
        List<CronTrigger> jobs = [
            SELECT Id,
            CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name =
            'Test Update TAT Scheduler'
        ];
        
        System.assertEquals(
            1,
            jobs.size(),
            'Scheduler should be created'
        );
    }
    
    @IsTest
    static void testBatch() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Admission Team Lead' LIMIT 1];
        User u = new User(
            Alias = 'ptes',
            Email = 'fariha.tabassumf@reva.edu.in',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'prof_save_test@testorg.com',
            Department = 'Test Account'
        );
        insert u;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Database.executeBatch(
            new ReassignApplicantsBatch(),
            200
        );
        
        Test.stopTest();
        
        Contact con = [
            SELECT Id,
            TAT_Status__c,
            Counselor_Reassigned_date__c
            FROM Contact
            LIMIT 1
        ];
        
        
    }
    
    @IsTest
    static void testScheduler1() {
         Profile p = [SELECT Id FROM Profile WHERE Name = 'Admission Team Lead' LIMIT 1];
        User u = new User(
            Alias = 'ptes',
            Email = 'fariha.tabassumf@reva.edu.in',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'prof_save_test@testorg.com',
            Department = 'Test Account'
        );
        insert u;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String cronExp =
            '0 0 12 * * ?';
        
        System.schedule(
            'Test ReassignApplicantsScheduler',
            cronExp,
            new ReassignApplicantsScheduler()
        );
        
        Test.stopTest();
        
        
    }
}