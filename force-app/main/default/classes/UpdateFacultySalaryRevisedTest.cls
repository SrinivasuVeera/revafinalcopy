@isTest
public class UpdateFacultySalaryRevisedTest {

    @isTest
    static void testFacultySalaryUpdateRevise() {
        // Step 1: Create test data
        Contact testContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Employee_Number__c = 'E67890'
        );
        insert testContact;

        Transport_Registeration__c testRegistration = new Transport_Registeration__c(
            Contact__c = testContact.Id,
            Amount_Paid__c = 500.00
            //Registration_Type__c = 'Professor'
        );
        insert testRegistration;
        
        Faculty_Payment__c payment = new Faculty_Payment__c();
                payment.Amount_Paid__c = 500;
                payment.Transport_Registration__c = testRegistration.Id;
        insert payment;

        // Step 2: Mock HTTP callouts
        Test.setMock(HttpCalloutMock.class, new HCMHttpMock());

        // Step 3: Invoke the method
        Test.startTest();
        List<String> contactIds = new List<String>{testContact.Id};
        updateFacultySalaryRevised.facultySalaryUpdateRevise(contactIds);
        updateFacultySalaryRevised.testCover();
        Test.stopTest();

        // Step 4: Assertions
        // Verify that the transport registration was updated
        Transport_Registeration__c updatedRegistration = [
            SELECT Amount_Paid__c
            FROM Transport_Registeration__c
            WHERE Id = :testRegistration.Id
        ];
        

        // Verify that a Faculty Payment record was created
        Faculty_Payment__c insertedPayment = [
            SELECT Amount_Paid__c, Transport_Registration__c
            FROM Faculty_Payment__c
            WHERE Transport_Registration__c = :testRegistration.Id
        ];
        
    }

    @isTest
    static void testGetAccessToken() {
        // Step 1: Mock HTTP callouts
        Test.setMock(HttpCalloutMock.class, new HCMHttpMock());

        // Step 2: Call getAccessToken
        String accessToken = updateFacultySalaryRevised.getAccessToken();

        
        
    }

    @isTest
    static void testGetSalaryRange() {
        // Step 1: Mock HTTP callouts
        Test.setMock(HttpCalloutMock.class, new HCMHttpMock());

        // Step 2: Call getSalaryRange
        Decimal salaryRange = updateFacultySalaryRevised.getSalaryRange('mockAccessToken123', 'E67890', 'Transportation');

        // Step 3: Assertions
        
    }

    private class HCMHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();

            if (req.getEndpoint().contains('/token')) {
                // Mocking the token API response
                res.setBody('{"access_token": "mockAccessToken123"}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('/salary')) {
                // Mocking the salary range API response
                res.setBody('{"Type":"transportation","Salary_Range":3500.00,"Employee_Number":"E67890","Employee_Name":"Jane Smith"}');
                res.setStatusCode(200);
            } else {
                // Fallback for unhandled endpoints
                res.setBody('{"error": "Endpoint not recognized"}');
                res.setStatusCode(404);
            }

            return res;
        }
    }
    
}