@isTest
public class FacilityRequestCancellationTest {

    // ---------- Mock HTTP Response ----------
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    // ---------- Utility to create Facility Request ----------
    private static Facility_Request__c createFacilityRequest(User createdByUser, User approverUser, hed__Facility__c facility, Date startDate, Id accountId) {
        Facility_Request__c req = new Facility_Request__c(
            Facility_Type__c = 'Auditorium',
            Building_Name__c = 'Block A',
            Floor__c = '1',
            Room_No__c = 'A101',
            Start_Date__c = startDate,
            End_Date__c = startDate.addDays(1),
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(10, 0, 0, 0),
            Facility__c = facility.Id,
            TemplateName__c = 'Approved',
            Approver__c = approverUser.Id,
            Account__c = accountId
            
        );
        insert req;
        return req;
    }

    // ---------- Setup Data ----------
    @testSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        // Create Users
        User creatorUser = new User(
            FirstName = 'Creator',
            LastName = 'User',
            Alias = 'cru',
            Email = 'creator@test.com',
            Username = 'creatoruser@test.com.' + System.currentTimeMillis(),
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            MobilePhone = '+911111111111'
        );
        insert creatorUser;

        User approverUser = new User(
            FirstName = 'Approver',
            LastName = 'User',
            Alias = 'apu',
            Email = 'approver@test.com',
            Username = 'approveruser@test.com.' + System.currentTimeMillis(),
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            MobilePhone = '+912222222222'
        );
        insert approverUser;

        // Create Account
        Account acc = new Account(Name = 'Test School');
        insert acc;

        // Get valid picklist value
        Schema.DescribeFieldResult typeField = hed__Facility__c.hed__Facility_Type__c.getDescribe();
        String validFacilityType = (typeField.getPicklistValues().isEmpty())
            ? null
            : typeField.getPicklistValues()[0].getValue();

        // Create Facility
        hed__Facility__c facility = new hed__Facility__c(
            Name = 'Event Hall 1',
            hed__Facility_Type__c = validFacilityType
        );
        insert facility;

        // Create Facility Contact
        Contact facilityContact = new Contact(
            FirstName = 'Facility',
            LastName = 'Manager',
            Email = 'facility@test.com',
            MobilePhone = '+913333333333'
        );
        insert facilityContact;

        Facility_Contact__c fc = new Facility_Contact__c(Facility__c = facility.Id, Contact__c = facilityContact.Id);
        insert fc;

        //  Avoid callout during setup
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        createFacilityRequest(creatorUser, approverUser, facility, Date.today().addDays(2), acc.Id);
        Test.stopTest();
    }

    @isTest
 static void testGetUserFacilityRequests() {
    User u = [SELECT Id FROM User WHERE Email = 'creator@test.com' LIMIT 1];
    
    System.runAs(u) {
        // Create facility request for this user
        Facility_Request__c fr = new Facility_Request__c(
              Account__c = [SELECT Id FROM Account LIMIT 1].Id
            );
        insert fr;

        Test.startTest();
        List<Facility_Request__c> results = FacilityRequestCancellationController.getUserFacilityRequests();
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Should return facility requests created by current user');
    }
}


    // ---------- Test cancelFacilityRequest (Valid) ----------
    @isTest
    static void testCancelFacilityRequest_Valid() {
        User u = [SELECT Id FROM User WHERE Email = 'creator@test.com' LIMIT 1];
        Facility_Request__c req = [SELECT Id FROM Facility_Request__c LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            String result = FacilityRequestCancellationController.cancelFacilityRequest(req.Id, 'No longer needed');
            Test.stopTest();

            System.assertEquals('Your booking has been cancelled successfully.', result);
            Facility_Request__c updatedReq = [SELECT TemplateName__c, Reason_of_Cancelation__c FROM Facility_Request__c WHERE Id = :req.Id];
            System.assertEquals('Rejected', updatedReq.TemplateName__c);
            System.assertEquals('No longer needed', updatedReq.Reason_of_Cancelation__c);
        }
    }

 
  @isTest
static void testCancelFacilityRequest_Allowed() {
    User u = [SELECT Id FROM User WHERE Email = 'creator@test.com' LIMIT 1];
    hed__Facility__c facility = [SELECT Id FROM hed__Facility__c LIMIT 1];
    User approver = [SELECT Id FROM User WHERE Email = 'approver@test.com' LIMIT 1];
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test School' LIMIT 1];

    System.runAs(u) {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Event starts in 5 hours → allowed to cancel
        Date startDate = Date.today();
        Time startTime = DateTime.now().addHours(5).time();

        Facility_Request__c req = createFacilityRequest(u, approver, facility, startDate, acc.Id);
        req.Start_Date__c = startDate;
        req.Start_Time__c = startTime;
        update req;

        String result = FacilityRequestCancellationController.cancelFacilityRequest(req.Id, 'Test reason');

        Test.stopTest();
        System.assertEquals('Your booking has been cancelled successfully.', result);
    }
}

    // ---------- Test sendWhatsAppNotifications (Covers All) ----------
    @isTest
    static void testSendWhatsAppNotifications_CoversAllBranches() {
        User u = [SELECT Id FROM User WHERE Email = 'creator@test.com' LIMIT 1];
        Facility_Request__c req = [SELECT Id FROM Facility_Request__c LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            FacilityRequestCancellationController.cancelFacilityRequest(req.Id, 'Testing WhatsApp Trigger');
            Test.stopTest();
        }
    }
}