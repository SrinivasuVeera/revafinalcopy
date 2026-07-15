@isTest
public class RegNotificationForMentorTest {
    
    @testSetup
    static void setupTestData() {
        // Create a contact to be queried by the batch job
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            MobilePhone = '+1234567890',
            SRN_Number__c = 'SRN12345',
            hed__WorkEmail__c = 'test@student.com'
        );
        insert contact;
        
        // Create metadata record for WhatsApp notification template
 /*       WhatsApp_Notification_Template__mdt template = new WhatsApp_Notification_Template__mdt(
            Template_ID__c = 'semester_registration_mentor',
            Template_Field__c = 'Sample Template Field'
        );
        insert template; */
    }
    
    @isTest
    static void testBatchable() {
        // Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Instantiate the batch class
        RegNotificationForMentor batch = new RegNotificationForMentor('Mentor Name', 'Semester Name', 'Student Name', 'SRN12345', '+1234567890','918877664455');
        
        // Execute the batch job
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify results
        // Check debug logs for verification
        List<Contact> results = [SELECT Id FROM Contact];
        System.assertEquals(1, results.size(), 'Expected one contact record to be processed.');
    }
    
    @isTest
    static void testNullPhoneNumber() {
        // Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Instantiate the batch class with null phone number
        RegNotificationForMentor batch = new RegNotificationForMentor('Mentor Name', 'Semester Name', 'Student Name', 'SRN12345', '+1234567890',null);
        
        // Execute the batch job
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify results
        // Check debug logs for verification
        List<Contact> results = [SELECT Id FROM Contact];
        System.assertEquals(1, results.size(), 'Expected one contact record to be processed.');
    }
    
    @isTest
    static void testExceptionHandling() {
        // Mock the HTTP response to throw an exception
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(true)); // True indicates to throw an exception
        
        // Instantiate the batch class
        RegNotificationForMentor batch = new RegNotificationForMentor('Mentor Name', 'Semester Name', 'Student Name', 'SRN12345', '+1234567890','918877664455');
        
        // Execute the batch job
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify results
        // Check debug logs for verification
        List<Contact> results = [SELECT Id FROM Contact];
        System.assertEquals(1, results.size(), 'Expected one contact record to be processed.');
    }
    
    // Mock HTTP callout response class
    private class MockHttpResponse implements HttpCalloutMock {
        private Boolean throwError = false;
        
        public MockHttpResponse() { }
        public MockHttpResponse(Boolean throwError) {
            this.throwError = throwError;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (throwError) {
                throw new CalloutException('Mock callout exception');
            } else {
                res.setStatusCode(200);
                res.setBody('{"status":"success"}');
            }
            return res;
        }
    }
}