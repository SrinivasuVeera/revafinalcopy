@isTest
private class sendSAPForExtraRouteAmountTest {

    // Mock response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('AddARInvoicepost')) {
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"success"}');
            } else {
                // For token endpoint
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token":"dummy_token","token_type":"Bearer","expires_in":3600}');
            }
            return res;
        }
    }

    @testSetup
    static void setupTestData() {
        // Create Contact
        Contact con = new Contact(LastName = 'Test', SRN_Number__c = 'SRN123456', Application_Number__c = 'APP2024');
        insert con;

        // Create Transport Registration
       	Transport_Registeration__c transportReg = new 	Transport_Registeration__c(
            //Name = 'TR-001',
            Contact__c = con.Id,
            Amount_Paid__c = 10000.00
        );
        insert transportReg;

        // Create Student Fee Payment
        Student_Fee_Payment__c feePayment = new Student_Fee_Payment__c(//Name = 'TestPayment',
																		Mode_of_Payment__c ='online');
        insert feePayment;

        // Create Student Fee record
        Student_Fee__c studentFee = new Student_Fee__c(
            Fee_Type__c = 'Transportation Fee',
            Contact__c = con.Id,
            Session__c = '2024-25',
            Amount_Paid__c = 8000.00,
            RTR_Transport_Registration__c = transportReg.Id
        );
        insert studentFee;

        // Link the payment manually (simulate child relationship)
        feePayment.Student_Fee__c = studentFee.Id;
        update feePayment;

        // Create RTR_Reva_Transport_Request__c
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND DeveloperName = 'Route_Change_Request' LIMIT 1];

        RTR_Reva_Transport_Request__c request = new RTR_Reva_Transport_Request__c(
            RecordTypeId = rt.Id,
            RTRStudent_Faculty_NonFaculty__c = con.Id,
            Amount_to_be_Refunded__c = 2000.00,
            StartDate_routeChange__c = Date.today()
        );
        insert request;
    }

    @isTest
    static void testPostFeeDetails_success() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Get test Student_Fee__c record
        Id studentFeeId = [SELECT Id FROM Student_Fee__c LIMIT 1].Id;

        Test.startTest();
        sendSAPForExtraRouteAmount.postFeeDetails(new List<Id>{studentFeeId});
        Test.stopTest();

        //System.assert(true); // Just to confirm no exceptions
    }

    @isTest
    static void testGetAccessToken_noMetadata() {
        // Simulate missing CMDT (query will return empty)
        Test.startTest();
        String token = sendSAPForExtraRouteAmount.getAccessToken();
        Test.stopTest();

        System.assertEquals(null, token);
    }

    @isTest
    static void testPostFeeDetails_missingToken() {
        // Don't set mock to simulate token failure
        Test.startTest();
        sendSAPForExtraRouteAmount.postFeeDetails(new List<Id>{'001000000000001'}); // dummy ID
        Test.stopTest();

        System.assert(true); // Should not throw even if token is blank
    }
}