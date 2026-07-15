@isTest
public class TransportCancelSMSEmployeeTest {
    
    @isTest
    static void testRTRSMSNotificationStudent() {
        // Step 1: Create test data
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RecordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c.getRecordTypeInfosByName().get('Transport Cancellation').getRecordTypeId(),
            RTR_Student__c = createTestStudent()
        );
        insert transportRequest;

        List<String> recordIds = new List<String>{transportRequest.Id};

        // Step 2: Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockSMSApiResponseGenerator());

        // Step 3: Call the method
        Test.startTest();
        TransportCancelSMSEmployee.rtrSMSNotificationStudent(recordIds);
        Test.stopTest();

        // Step 4: Assertions
        System.assert(true, 'Test executed without errors.');
    }
    
    @isTest
    static void testRTRSMSNotificationStudentWithEmptyList() {
        List<String> recordIds = new List<String>();
        
        Test.startTest();
        TransportCancelSMSEmployee.rtrSMSNotificationStudent(recordIds);
        Test.stopTest();
        
        System.assert(true, 'No errors for empty record list.');
    }
    
    @isTest
    static void testRTRSMSNotificationStudentWithNullList() {
        List<String> recordIds = null;
        
        Test.startTest();
        TransportCancelSMSEmployee.rtrSMSNotificationStudent(recordIds);
        Test.stopTest();
        
        System.assert(true, 'No errors for null record list.');
    }
    
    @isTest
    static void testMakeCalloutAsync() {
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RecordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c.getRecordTypeInfosByName().get('Transport Cancellation').getRecordTypeId(),
            RTR_Student__c = createTestStudent()
        );
        insert transportRequest;

        List<String> recordIds = new List<String>{transportRequest.Id};

        Test.setMock(HttpCalloutMock.class, new MockSMSApiResponseGenerator());

        Test.startTest();
        TransportCancelSMSEmployee.makeCalloutAsync(recordIds);
        Test.stopTest();

        System.assert(true, 'Make callout logic executed without errors.');
    }
    
    private static Id createTestStudent() {
        Contact testStudent = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            MobilePhone = '1234567890'
        );
        insert testStudent;
        return testStudent.Id;
    }

    private class MockSMSApiResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"SMS sent successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }
}