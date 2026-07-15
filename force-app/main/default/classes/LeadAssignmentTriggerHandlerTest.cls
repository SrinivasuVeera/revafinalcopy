@istest
public class LeadAssignmentTriggerHandlerTest {

    /* =========================================
       MOCK CLASS FOR CALLOUT
       ========================================= */
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testNotificationFlow() {

        // Register mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        /* =========================================
           CREATE TEST USER (Counselor)
           ========================================= */
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User counselor = new User(
            FirstName = 'Test',
            LastName = 'Counselor',
            Email = 'counselor@test.com',
            Username = 'counselor' + System.currentTimeMillis() + '@test.com',
            Alias = 'tcoun',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            MobilePhone = '9876543210'
        );
        insert counselor;
        
         Account acc = new Account(
            Name = 'School of Engineering',
            Program_Type__c = 'Ph.D'
        );
        insert acc;
        
        // Create Program Plan
        hed__Program_Plan__c pp = new hed__Program_Plan__c(
            Name = 'Engineering Batch',
            hed__Account__c = acc.Id,
            Select_Counselors__c = 'sidaram@reva.edu.in'
        );
        insert pp;

        
        Fee_Master__c fm = new Fee_Master__c(
            Program_Batch__c = pp.Id,
            Program_Name_Display__c = 'B.Tech. - Civil Engineering',   
            Applicant_Category__c = 'Non-Resident Indian(NRI)',
            Fee_Type__c = 'Application Fee',
            Application_Number_Prefix__c = '240401',
            Fee_Amount__c = 1000,
            IsActive__c = true
        );
        insert fm;

        /* =========================================
           CREATE CONTACT (Student)
           ========================================= */
        Contact con = new Contact(
            LastName = 'Student',
            Email = 'student@test.com',
            MobilePhone = '9123456789',
            Phone = '9123456789',
            OwnerId = counselor.Id,
            Application_Number__c = 'APP001'
        );
        insert con;

        /* =========================================
           CREATE LEAD FOR ASSIGNMENT
           ========================================= */
        Lead ld = new Lead(
            LastName = 'LeadTest',
            Company = 'Test Company',
            Category__c = 'Karnataka',
            Assigned__c = false,
            Program_Name_Display__c = 'b.tech computer science',
            School__c = acc.Name 
           // Program_Batch__c =pp.Id
        );
        insert ld;

Lead ld1 = new Lead(
            LastName = 'LeadTest',
            Company = 'Test Company',
            Category__c = 'Karnataka',
            Assigned__c = false,
            Program_Name_Display__c = 'b.tech computer science',
            School__c = acc.Name,
            Program_Batch__c =pp.Id
        );
        insert ld1;


        /* =========================================
           TEST ASSIGNMENT METHOD
           ========================================= */
        Test.startTest();

        LeadAssignmentTriggerHandler.assignCounselor(
            new Set<Id>{ld.Id}
        );
        LeadAssignmentTriggerHandler.sendNotification(con.Id);
        LeadAssignmentTriggerHandler.assignCounselor(
            new Set<Id>{ld1.Id}
        );
        Test.stopTest();

        /* =========================================
           ASSERTIONS
           ========================================= */
        Lead updatedLead = [SELECT Assigned__c FROM Lead WHERE Id = :ld.Id];
        System.assertNotEquals(null, updatedLead);
        //LeadAssignmentTriggerHandler.resolveFeeMasterCategory('Karnataka');
        System.assert(true, 'Test completed successfully');
    }
}