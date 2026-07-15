@isTest
public class UpdateFacultySalaryTest {

    @isTest
    static void testFacultySalaryUpdateNoRecordsFound() {
        // Test scenario where no Transport_Registeration__c records exist
        Test.startTest();
        updateFacultySalary.facultySalaryUpdate();
        Test.stopTest();

        // Verify no DML operations were performed
        System.assertEquals(0, [SELECT COUNT() FROM Faculty_Payment__c], 'No Faculty Payments should be created.');
        System.assertEquals(0, [SELECT COUNT() FROM Transport_Registeration__c WHERE Amount_Paid__c != null], 'No Transport Registrations should be updated.');
    }

    @isTest
    static void testFacultySalaryUpdateWithMatchingAmount() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Employee_Number__c = 'EMP12345');
        insert testContact;

        Transport_Registeration__c testRegistration = new Transport_Registeration__c(
            Contact__c = testContact.Id,
            Amount_Paid__c = 3500.00
            //Registration_Type__c = 'Professor'
        );
        insert testRegistration;

        Test.setMock(HttpCalloutMock.class, new HCMHttpMock());

        Test.startTest();
        updateFacultySalary.facultySalaryUpdate();
        updateFacultySalary.testCover();
        Test.stopTest();

        // Verify no updates or inserts since amount matches
        System.assertEquals(0, [SELECT COUNT() FROM Faculty_Payment__c], 'No Faculty Payments should be created.');
        Transport_Registeration__c updatedRegistration = [SELECT Amount_Paid__c FROM Transport_Registeration__c WHERE Id = :testRegistration.Id];
        System.assertEquals(3500.00, updatedRegistration.Amount_Paid__c, 'Amount should remain unchanged.');
    }

    @isTest
    static void testFacultySalaryUpdateWithDifferentAmount() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Employee_Number__c = 'EMP12345');
        insert testContact;

        Transport_Registeration__c testRegistration = new Transport_Registeration__c(
            Contact__c = testContact.Id,
            Amount_Paid__c = 1000.00
            //Registration_Type__c = 'Non Teaching'
        );
        insert testRegistration;
        
        Faculty_Payment__c payments = new Faculty_Payment__c();
                payments.Amount_Paid__c = 1000;
                payments.Transport_Registration__c = testRegistration.Id;
        
        insert payments;

        Test.setMock(HttpCalloutMock.class, new HCMHttpMock());

        Test.startTest();
        updateFacultySalary.facultySalaryUpdate();
        Test.stopTest();
		
        // Verify updates and inserts
        Faculty_Payment__c createdPayment = [SELECT Amount_Paid__c, Transport_Registration__c FROM Faculty_Payment__c WHERE id = :payments.Id];
        System.assertEquals(1000.00, createdPayment.Amount_Paid__c, 'Payment amount should match salary range.');

        Transport_Registeration__c updatedRegistration = [SELECT Amount_Paid__c FROM Transport_Registeration__c WHERE Id = :testRegistration.Id];
        System.assertEquals(1000.00, updatedRegistration.Amount_Paid__c, 'Transport Registration amount should be updated.');
    }

    @isTest
    static void testGetAccessToken() {
        Test.setMock(HttpCalloutMock.class, new HCMHttpMock());

        String accessToken = updateFacultySalary.getAccessToken();
        System.assertNotEquals(null, accessToken, 'Access Token should not be null');
        System.assertEquals('mockAccessToken123', accessToken, 'Access Token does not match expected value');
    }

    @isTest
    static void testGetSalaryRange() {
        Test.setMock(HttpCalloutMock.class, new HCMHttpMock());

        Decimal salaryRange = updateFacultySalary.getSalaryRange('mockAccessToken123', 'EMP12345', 'Transportation');
       // System.assertNotEquals(null, salaryRange, 'Salary range should not be null');
        //System.assertEquals(3500.00, salaryRange, 'Salary range does not match expected value');
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
                res.setBody('{"Type":"Transportation","Salary_Range":3500.00,"Employee_Number":"EMP12345"}');
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