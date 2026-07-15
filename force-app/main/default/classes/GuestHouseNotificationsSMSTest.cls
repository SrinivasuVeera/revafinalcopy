@isTest
public class GuestHouseNotificationsSMSTest {
    
    public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    @testSetup
    static void setupTestData() {
        // Find the Record Type ID for 'Non Teaching'
        RecordType nonTeachingRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1];
        
        // Create test data for Contacts
        Contact guestContact = new Contact(
            LastName = 'Test Guest', 
            Email = 'test585@gmail.com',
            MobilePhone = '+919876543210'
        );
        insert guestContact;
        
        Contact coContact = new Contact(
            LastName = 'Test Co', 
            Email = 'test555co@gmail.com',
            MobilePhone = '+919876543212'
        );
        insert coContact;
        
        Contact guestHouseManagerContact = new Contact(
            LastName = 'Guest Manager', 
            Email = 'guestmanager@example.com',
            MobilePhone = '+919876543213',
            RecordTypeId = nonTeachingRecordType.Id
        );
        insert guestHouseManagerContact;
        
        // Create Users with specific profiles
        Profile departmentHeadProfile = [SELECT Id FROM Profile WHERE Name = 'School Director' LIMIT 1];
        Profile professorProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        Profile guestHouseManagerProfile = [SELECT Id FROM Profile WHERE Name = 'Guest House Manager' LIMIT 1];
        
        User departmentHead = new User(
            Username = 'depthead@example.com',
            LastName='testdept',
            Email = 'depthead@example.com',
            ProfileId = departmentHeadProfile.Id,
            Alias = 'depad',
            CommunityNickname = 'depthead',
            UserRoleId = null, // set if you have specific roles
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert departmentHead;
        
        User generalAdmin = new User(
            Username = 'professor@example.com',
            LastName='testgen',
            Email = 'professor@example.com',
            ProfileId = professorProfile.Id,
            Alias = 'prssor',
            CommunityNickname = 'professor',
            UserRoleId = null, // set if you have specific roles
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert generalAdmin;
        
        User guestHouseManager = new User(
            Username = 'guestmanager@example.com',
            Email = 'guestmanager@example.com',
            LastName='gueHm',
            ProfileId = guestHouseManagerProfile.Id,
            Alias = 'gstmgr',
            CommunityNickname = 'guestmgr',
            UserRoleId = null, // set if you have specific roles
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = guestHouseManagerContact.Id,
            IsActive = true
        );
        insert guestHouseManager;
        
        // Create Guest House Room records
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        // Create Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = guestContact.Id,
            Sharing_Type__c = 'Two Sharing',
            Room_Type__c = 'A/C',
            Guest_House_Room__c = guestHouseRoom.Id,
            Start_Time__c = System.now(),
            End_Time__c = System.now().addDays(1),
            Mobile_Number__c = '+91-9876543210',
            Department_Head__c = departmentHead.Id,
            General_Admin__c = generalAdmin.Id,
            Purpose_of_Visit__c = 'Business',
            Contact__c = coContact.Id,
            Status__c = 'Booked'
        );
        insert guestHouseBooking;
        
         Guest_Person__c gp = new Guest_Person__c();
       // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = guestHouseBooking.id;
        insert gp;
        
    }
    
    @isTest
    static void testMakeCalloutAsync_Booking() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        List<Reva_Guest_House_Booking__c> bookings = [SELECT Id FROM Reva_Guest_House_Booking__c LIMIT 1];
        // Call the method and simulate future method execution
        Guest_Person__c gp = new Guest_Person__c();
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = bookings[0].id;
        insert gp;
        
        GuestHouseNotificationsSMS.makeCalloutAsync(new List<Id>{bookings[0].Id}, 'Booking');
        Test.stopTest();
        
        // Perform assertions to verify the expected outcomes
    }
    
    @isTest
    static void testMakeCalloutAsync_RoomAllocation() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        List<Reva_Guest_House_Booking__c> bookings = [SELECT Id FROM Reva_Guest_House_Booking__c LIMIT 1];
        // Call the method and simulate future method execution
        GuestHouseNotificationsSMS.makeCalloutAsync(new List<Id>{bookings[0].Id}, 'Allocation');
        Test.stopTest();
        
        // Perform assertions to verify the expected outcomes
    }
    
    @isTest
    static void testMakeCalloutAsync_CheckIn() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        List<Reva_Guest_House_Booking__c> bookings = [SELECT Id FROM Reva_Guest_House_Booking__c LIMIT 1];
        // Call the method and simulate future method execution
        GuestHouseNotificationsSMS.makeCalloutAsync(new List<Id>{bookings[0].Id}, 'Check In');
        Test.stopTest();
        
        // Perform assertions to verify the expected outcomes
    }
    
    @isTest
    static void testMakeCalloutAsync_CheckOut() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        List<Reva_Guest_House_Booking__c> bookings = [SELECT Id FROM Reva_Guest_House_Booking__c LIMIT 1];
        // Call the method and simulate future method execution
        GuestHouseNotificationsSMS.makeCalloutAsync(new List<Id>{bookings[0].Id}, 'Check Out');
        Test.stopTest();
        
        // Perform assertions to verify the expected outcomes
    }
    
    @isTest
    static void testMakeCalloutAsync_Cancellation() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        List<Reva_Guest_House_Booking__c> bookings = [SELECT Id FROM Reva_Guest_House_Booking__c LIMIT 1];
        // Call the method and simulate future method execution
        Guest_Person__c gp = new Guest_Person__c();
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = bookings[0].id;
        insert gp;
        GuestHouseNotificationsSMS.makeCalloutAsync(new List<Id>{bookings[0].Id}, 'Cancellation');
        Test.stopTest();
        
        // Perform assertions to verify the expected outcomes
    }
    
    @isTest
    static void testMakeCalloutAsync_GeneralAdmin() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        List<Reva_Guest_House_Booking__c> bookings = [SELECT Id FROM Reva_Guest_House_Booking__c LIMIT 1];
        // Call the method and simulate future method execution
        GuestHouseNotificationsSMS.makeCalloutAsync(new List<Id>{bookings[0].Id}, 'General Admin');
        Test.stopTest();
        
        // Perform assertions to verify the expected outcomes
    }
    
    @isTest
    static void testMakeCalloutAsync_DepartmentHead() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        List<Reva_Guest_House_Booking__c> bookings = [SELECT Id FROM Reva_Guest_House_Booking__c LIMIT 1];
        // Call the method and simulate future method execution
        GuestHouseNotificationsSMS.makeCalloutAsync(new List<Id>{bookings[0].Id}, 'Department Head');
        Test.stopTest();
        
        // Perform assertions to verify the expected outcomes
    }
    
    @isTest
    static void testMakeCalloutAsync_GuestManager() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        List<Reva_Guest_House_Booking__c> bookings = [SELECT Id FROM Reva_Guest_House_Booking__c LIMIT 1];
        // Call the method and simulate future method execution
         Guest_Person__c gp = new Guest_Person__c();
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = bookings[0].id;
        insert gp;
        GuestHouseNotificationsSMS.makeCalloutAsync(new List<Id>{bookings[0].Id}, 'Guest Manager');
        Test.stopTest();
        
        // Perform assertions to verify the expected outcomes
    }
    /*****************************************************************/
    @isTest
static void testConfirmationGuestManager() {
    // Setup mock data
    String guestPhoneNumber = '+919876543210'; // Sample phone number
    String guestHouseManager = 'John Doe'; // Sample manager name
    String guestName = 'Jane Smith'; // Sample guest name
    Datetime startDateTime = System.now().addDays(1);
    Datetime endDateTime = System.now().addDays(3);
    
    // Simulate the static variables
    GuestHouseNotificationsSMS.GuestPhoneNumber = guestPhoneNumber;
    GuestHouseNotificationsSMS.GuestHouseManger = guestHouseManager;
    GuestHouseNotificationsSMS.GuestName = guestName;
    GuestHouseNotificationsSMS.StartDateTime = startDateTime.format('yyyy-MM-dd HH:mm:ss');
    GuestHouseNotificationsSMS.EndDateTime = endDateTime.format('yyyy-MM-dd HH:mm:ss');
    
    // Initialize the list to pass to the method
    List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
    
    // Call the method
    Test.startTest();
    GuestHouseNotificationsSMS.ConfirmationGuestManger(messageList);
    Test.stopTest();
    
    // Assert that the list contains one message
    System.assertEquals(1, messageList.size(), 'The message list should contain one message.');
    
    // Retrieve the message from the list
    SMS_API_Utility.shortMessageWrp message = messageList[0];
    
    // Define the expected message
    String expectedMessage = 'Dear John Doe, \nGuest booking confirmed. Allocate room for Jane Smith From ' 
        + startDateTime.format('yyyy-MM-dd HH:mm:ss') + ' to ' + endDateTime.format('yyyy-MM-dd HH:mm:ss') 
        + '. Check details in the system.\nRegards,\nREVA University.';
    
    // Assert the message content
    System.assertEquals('1007501693404282210', message.dltContentId, 'The DLT Content ID should match.');
    //System.assertEquals(expectedMessage, message.message, 'The message content should be as expected.');
  //  System.assertEquals(guestPhoneNumber, message.recipient, 'The recipient phone number should match.');
}

    
}