@isTest
private class FacilityRequestFlowHandlerTest {

    @isTest
    static void testSendNotifications() {
        // Step 0: Create an Account (required by Facility_Request__c)
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Step 1: Create a Facility
        hed__Facility__c facility = new hed__Facility__c(Name = 'Test Facility');
        insert facility;

        // Step 2: Create a Contact with MobilePhone
        Contact contact = new Contact(LastName = 'Test Contact', MobilePhone = '9876543210');
        insert contact;

        // Step 3: Create a Facility_Contact__c linking Facility and Contact
        Facility_Contact__c facilityContact = new Facility_Contact__c(
            Facility__c = facility.Id,
            Contact__c = contact.Id
        );
        insert facilityContact;

        // Step 4: Create a Facility_Request__c with required fields
        Facility_Request__c facilityRequest = new Facility_Request__c(
            Facility__c = facility.Id,
            Account__c = acc.Id, 
            //Requester__c = contact.Id, // Optional: only if relevant in your org
            Start_Date__c = Date.today(),
            Start_Time__c = Time.newInstance(10, 0, 0, 0),
            End_Date__c = Date.today().addDays(1),
            End_Time__c = Time.newInstance(12, 0, 0, 0),
            Additional_Amenities_Required2__c = 'Projector, Chairs',
            TemplateName__c = 'Approved'
        );
        insert facilityRequest;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new YellowAIWhatsAppMock());
        FacilityRequestFlowHandler.sendNotifications(new List<Id>{ facilityRequest.Id });
        Test.stopTest();

        System.debug('Test completed for FacilityRequestFlowHandler.');
    }
    

}