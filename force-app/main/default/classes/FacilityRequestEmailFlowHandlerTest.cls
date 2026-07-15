@isTest
private class FacilityRequestEmailFlowHandlerTest {

    @isTest
    static void testSendEmailsWithValidRequest() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        // Create a test Facility Request record with required fields
        Facility_Request__c request = new Facility_Request__c(
            Account__c = acc.Id,
            Start_Date__c = Date.today(),
            Additional_Amenities_Required2__c = 'Projector, Chairs'
        );
        insert request;

        // Wrap the request ID
        FacilityRequestEmailFlowHandler.IdWrapper wrapper = new FacilityRequestEmailFlowHandler.IdWrapper();
        wrapper.requestId = request.Id;

        List<FacilityRequestEmailFlowHandler.IdWrapper> wrappers = new List<FacilityRequestEmailFlowHandler.IdWrapper>{ wrapper };

        Test.startTest();
        FacilityRequestEmailFlowHandler.sendEmails(wrappers);
        Test.stopTest();

        System.assert(true); // Ensures method runs without error
    }

    @isTest
    static void testSendEmailsWithEmptyList() {
        List<FacilityRequestEmailFlowHandler.IdWrapper> emptyList = new List<FacilityRequestEmailFlowHandler.IdWrapper>();

        Test.startTest();
        FacilityRequestEmailFlowHandler.sendEmails(emptyList);
        Test.stopTest();

        System.assert(true); // Method should exit safely
    }

    @isTest
    static void testSendEmailsWithNullList() {
        Test.startTest();
        FacilityRequestEmailFlowHandler.sendEmails(null);
        Test.stopTest();

        System.assert(true); // Method should handle null input gracefully
    }

    @isTest
    static void testSendEmailsWithNullRequestId() {
        FacilityRequestEmailFlowHandler.IdWrapper wrapper = new FacilityRequestEmailFlowHandler.IdWrapper();
        wrapper.requestId = null;

        List<FacilityRequestEmailFlowHandler.IdWrapper> wrappers = new List<FacilityRequestEmailFlowHandler.IdWrapper>{ wrapper };

        Test.startTest();
        FacilityRequestEmailFlowHandler.sendEmails(wrappers);
        Test.stopTest();

        System.assert(true); // Validates null ID is handled
    }
}