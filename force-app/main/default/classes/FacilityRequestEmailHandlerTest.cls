@isTest
private class FacilityRequestEmailHandlerTest {

    @isTest
    static void testSendEmails() {
        // Set mock for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new DummyHttpCalloutMock());

        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        hed__Facility__c facility = new hed__Facility__c(Name = 'Auditorium');
        insert facility;

        Contact contact = new Contact(LastName = 'Email Contact', Email = 'test@example.com');
        insert contact;

        Facility_Contact__c fc = new Facility_Contact__c(
            Facility__c = facility.Id,
            Contact__c = contact.Id
        );
        insert fc;

        Facility_Request__c approvedRequest = new Facility_Request__c(
            Facility__c = facility.Id,
            Account__c = acc.Id,
            //RequesterName__c = 'John Doe',
            //Reqester_Phone_Number__c = '9876543210',
            Start_Date__c = Date.today(),
            Start_Time__c = Time.newInstance(10, 0, 0, 0),
            End_Date__c = Date.today().addDays(1),
            End_Time__c = Time.newInstance(12, 0, 0, 0),
            Additional_Amenities_Required2__c = 'Projector, Chairs',
            TemplateName__c = 'Approved'
        );
        insert approvedRequest;

        Test.startTest();
        FacilityRequestEmailHandler.sendEmails(new List<Id>{ approvedRequest.Id });
        Test.stopTest();
    }

    @isTest
    static void testEmptyAndNullInputs() {
        Test.setMock(HttpCalloutMock.class, new DummyHttpCalloutMock());

        Test.startTest();
        FacilityRequestEmailHandler.sendEmails(new List<Id>());
        FacilityRequestEmailHandler.sendEmails(null);
        Test.stopTest();
    }

    @isTest
    static void testNoFacilityContacts() {
        Test.setMock(HttpCalloutMock.class, new DummyHttpCalloutMock());

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        hed__Facility__c facility = new hed__Facility__c(Name = 'Mini Hall');
        insert facility;

        Facility_Request__c req = new Facility_Request__c(
            Facility__c = facility.Id,
            Account__c = acc.Id,
            //RequesterName__c = 'Jane Doe',
            //Reqester_Phone_Number__c = '9999999999',
            Start_Date__c = Date.today(),
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Date__c = Date.today().addDays(1),
            End_Time__c = Time.newInstance(11, 0, 0, 0),
            Additional_Amenities_Required2__c = 'None',
            TemplateName__c = 'Approved'
        );
        insert req;

        Test.startTest();
        FacilityRequestEmailHandler.sendEmails(new List<Id>{ req.Id });
        Test.stopTest();
    }
}