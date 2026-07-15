@isTest
public class RTRCancelledSMSMultipleDaysInvokeTest {
    
    @isTest
    static void test_busCancelledMultiple() {
        // Generate test data
        Contact con = TestDataFactory.createContact();
        RTR_Reva_Transport_Request__c transportRequests = TestDataFactory.createTestTransportRequests();
        RTR_Route_Pick_Up_Point__c pickupPoint = TestDataFactory.createPickUpPoint();        
        Reva_Transport__c revaTransport = TestDataFactory.createRevaTransport();        
        RTR_Route_Master__c routeMaster = TestDataFactory.createRouteMaster();
        Transport_Registeration__c createTransport = TestDataFactory.createTransport();
           
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        List<String> recordIds = new List<String>{transportRequests.Id};
        RTRCancelledSMSMultipleDaysInvoke.cancelledSMS(recordIds);
        Test.stopTest();
    }
    
    // Mock HTTP callout response class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"user" : "revaerp.trans","password" : "s1Sz2"},"from" : "REVAUn","shortMessages" : [ {"dltContentId" : "1007278312264240472","message" : "Dear Test User1, We’d like to inform you that the University bus will arrive at the pickup point 10 mins earlier than the regular schedule on 26.05.2024 on account of Test Description. REVA University", "recipient" : "1234567890"} ],"unicode" : true}');
            res.setStatusCode(200);
            return res;
        }
    }
}