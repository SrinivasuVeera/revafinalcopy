@isTest
public class FacultySalaryDeductionCancellationTest {

    @isTest
    static void testTransportCancel() {
        // Step 1: Create test data for Transport_Registeration__c
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Employee_Number__c = 'E12345'
        );
        insert testContact;

        Transport_Registeration__c testRegistration = new Transport_Registeration__c(
            Contact__c = testContact.Id,
            Amount_Paid__c = 100.0,
            //Registration_Type__c = 'Professor',
            rtr_Start_Date__c = Date.today(),
            Cancellation_Approved_Date__c = Date.today().addDays(1),
            Cancellation_Request_Date__c = Date.today(),
            Reason_for_Cancellation__c = 'Test Reason'
        );
        insert testRegistration;

       HCM_Credential__mdt[] HCMmetadataRecordss = [SELECT Id,End_Point__c,DeveloperName, Label 
                                                    FROM HCM_Credential__mdt where Label='FacultySalaryDeductionCancel'];
        // Step 3: Mock the HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FacultySalaryDeductionCancellationMock());

        // Step 4: Call the method
        List<String> recordIds = new List<String>{testRegistration.Id};
        FacultySalaryDeductionCancellation.transportCancel(recordIds);

        Test.stopTest();

        // Step 5: Verify the results (assertions)
        // Add assertions to validate behavior, such as checking debug logs, if necessary.
    }

    // Mock class for HTTP callouts
    private class FacultySalaryDeductionCancellationMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('token')) {
                res.setStatusCode(200);
                res.setBody('{"access_token": "testAccessToken"}');
            } else {
                res.setStatusCode(200);
                res.setBody('{"status": "Success"}');
            }
            return res;
        }
    }
}