@isTest(SeeAllData=true)
public class WhatsAppNotificationsTest {
    
      // Mock class for HTTP callouts
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // You can customize the response as needed for testing
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendWhatsAppNotifications() {
        
        Profile testSystemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
         User testSystemAdmin = new User(
            FirstName = 'Test',
            LastName = 'System Admin',
            Email = 'testuser@example.com',
            Username = 'test09878@example.com',
            Alias = 'TUser',
            CommunityNickname = 'testsystemadmin',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testSystemAdminProfile.Id,
            LanguageLocaleKey = 'en_US'
           // ManagerId = testCounsellor.id
        );
        insert testSystemAdmin;
        
        
        Contact testContact = new Contact(
                FirstName = 'Test Contact',
                LastName = 'Test Last',
                Email = 'testuser@example.com',
                MobilePhone = '917088142959'
                // Set other required fields
            );
            insert testContact;
        
        Case testCase = new Case(
                Subject = 'Test Case',
                ContactId = testContact.id,
                Description__c = 'Test Description'
                // Set other required fields
            );
            insert testCase;
        
        // Create a test appointment record
        ManodhaaraAppointment__c testAppointment = new ManodhaaraAppointment__c(
           Case__c = testCase.id,
               // LastName = 'Test Last',
                Email__c = 'testuser@example.com',
            Start_Date_Time__c = datetime.newInstance(2024, 1, 25, 3, 30, 0),
            End_Date_Time__c = datetime.newInstance(2024, 1, 25, 4, 30, 0),
            Appointment_Date__c = system.today(),
            Reason_For_Cancellation__c = 'Test Reason',
            Severity__c = 'As Soon As Possible'
            
        );
        insert testAppointment;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Call the sendWhatsAppNotifications method
        Test.startTest();
        List<String> recordIds = new List<String>{testAppointment.Id};
        WhatsAppNotifications.Appointment_ApprovedNotifications(recordIds);
        Initiated_WhatsappNotification.Appointment_InitiatedNotifications(recordIds);
        Cancelled_WhatsappNotification.Appointment_CancelledNotification(recordIds);
        Test.stopTest();

        // Perform assertions based on your use case
        // For example, check if the callout was made successfully
        // Check if the DML operations were performed as expected
    }
}