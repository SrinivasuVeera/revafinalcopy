@isTest
public class RevaGuestHouseControllerTest {
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
     
    @testSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create necessary test data
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'testcontact@test.com');
        insert testContact;
        
        User testUser = new User(
            Alias = 'standt',
            Email = 'standarduser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = prof.Id,
            ContactId = testContact.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser@test.com'
        );
        insert testUser;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        REVA_Guest_House_Room__c room = new REVA_Guest_House_Room__c(
            Name = 'Room 101',
            Room_Type__c = 'A/C',
            Maximum_Occupancy__c = 'Two Sharing',
            Available__c = true
        );
        insert room;
        
    }
    
    /***************************************************************************************/ 
    
    /* @isTest
static void testSaveGuestHouseRequest() {
// Create necessary data for test
Account acc = new Account(Name = 'Test Account');
insert acc;

Contact contact = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
insert contact;

// Create necessary Guest House Booking custom setting record
Guest_House_Booking__c customSetting = new Guest_House_Booking__c(
Name ='Test',
Room_Type__c = 'A/C',
Sharing__c = 'Single',
Amount__c = 500.00
);
insert customSetting;

// Create a Guest House Booking record
Reva_Guest_House_Booking__c booking = new Reva_Guest_House_Booking__c(

Room_Type__c = 'A/C',

ContactLookUp__c = contact.Id,
Sharing_Type__c = 'Single'
);
insert booking;

// Perform assertions to verify functionality
Test.startTest();
RevaGuestHouseController controller = new RevaGuestHouseController();
//controller.saveGuestHouseRequest();
Test.stopTest();

// Fetch and assert the created Student Fee record
List<Student_Fee__c> studentFees = [SELECT Id, Amount__c, Contact__c FROM Student_Fee__c WHERE Contact__c = :contact.Id];

List<Student_Payment__c> studentPayments = [SELECT Id, Amount__c, Contact__c FROM Student_Payment__c WHERE Contact__c = :contact.Id];

}*/
    /*@isTest
static void testSaveGuestHouseRequest() {
// Create test Account and Contact
Account acc = new Account(Name = 'Test Account');
insert acc;

Contact contact = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
insert contact;

// Create another test Contact for the coordinator
Contact coordinatorContact = new Contact(LastName = 'Coordinator', AccountId = acc.Id);
insert coordinatorContact;

// Prepare test data for the GuestPersonWrapper list
List<RevaGuestHouseController.GuestPersonWrapper> guestList = new List<RevaGuestHouseController.GuestPersonWrapper>();

// If constructor parameters are different or if you need to use setter methods
// Create guestList items based on the available constructor or use methods if applicable
// Example with setter methods (adjust based on actual class implementation):
RevaGuestHouseController.GuestPersonWrapper guest1 = new RevaGuestHouseController.GuestPersonWrapper();
guest1.guestName = 'Guest 1';
guest1.age = '30';
guest1.gender = 'Male';
guestList.add(guest1);

RevaGuestHouseController.GuestPersonWrapper guest2 = new RevaGuestHouseController.GuestPersonWrapper();
guest2.guestName = 'Guest 2';
guest2.age = '25';
guest2.gender = 'Female';
guestList.add(guest2);

// Start the test
Test.startTest();

// Call the saveGuestHouseRequest method
Map<String, String> result = RevaGuestHouseController.saveGuestHouseRequest(
'University Guest',              // guestType
'Test Guest User',              // guestUserName
contact.Id,                     // selectedContactId
'Test Department',              // deptName
2,                              // noOfGuests
'Indian',                       // citizenshipName
'A1234567',                     // passportNumber
'123 Test Street',              // address
'test@example.com',             // email
'1234567890',                   // phoneNumber
'2',                            // roomsNumber
'A/C',                          // roomType
'Two Sharing',                  // sharingType
DateTime.now().addDays(1),      // startDate
DateTime.now().addDays(5),      // endDate
'Business',                     // purposeOfVisit
'Coordinator Name',             // coOrdinatorName
'9876543210',                   // coOrdinatorMobile
'test.file',                    // base64Data
'This is a guest description',  // guestDescription
coordinatorContact.Id,          // selectedCoordinatorId
guestList                       // guestList
);

// Stop the test
Test.stopTest();

// Verify the Guest House Booking record was created successfully
Reva_Guest_House_Booking__c booking = [SELECT Id, No_of_Guest__c, Room_Type__c, Sharing_Type__c, ContactLookUp__c 
FROM Reva_Guest_House_Booking__c 
WHERE Id = :result.get('Id') LIMIT 1];
System.assertNotEquals(null, booking, 'Guest House Booking record should have been created.');
System.assertEquals('A/C', booking.Room_Type__c, 'Room Type should be A/C.');
System.assertEquals('Two Sharing', booking.Sharing_Type__c, 'Sharing Type should be Two Sharing.');
System.assertEquals(2, booking.No_of_Guest__c, 'Number of guests should be 2.');

// Verify the Guest Person records were created successfully
List<Guest_Person__c> guestPersons = [SELECT Id, Guest_Name__c, Age__c, Gender__c 
FROM Guest_Person__c 
WHERE REVA_Guest_House_Booking__c = :booking.Id];
System.assertEquals(2, guestPersons.size(), 'There should be two guest person records.');
System.assertEquals('Guest 1', guestPersons[0].Guest_Name__c, 'The first guest name should be Guest 1.');
System.assertEquals('Male', guestPersons[0].Gender__c, 'The first guest gender should be Male.');
}*/
    
    
    
    
    /*********************************************************************************************/
    @isTest
    static void testAttachFileToGuestHouseRequest() {
        // Insert test room and booking
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
 
        REVA_Guest_House_Room__c room = [SELECT Id,Room_Type__c FROM REVA_Guest_House_Room__c LIMIT 1];
        
        Reva_Guest_House_Booking__c booking = new Reva_Guest_House_Booking__c(
            Room_Type__c = room.Room_Type__c,
            Sharing_Type__c = 'Two Sharing',
            Start_Time__c = DateTime.now().addDays(1),
            End_Time__c = DateTime.now().addDays(2),
            Citizenship__c = 'Indian',
            Contact__c = [SELECT Id FROM Contact LIMIT 1].Id,
            Status__c = 'Booked'
        );
        insert booking;
        
        Test.startTest();
        RevaGuestHouseController.attachFileToGuestHouseRequest(booking.Id, 'TestFile.txt', EncodingUtil.base64Encode(Blob.valueOf('Test content')));
        Test.stopTest();
        
        // Verify attachment
        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :booking.Id];
        System.assertEquals(1, attachments.size(), 'Attachment should be added successfully.');
        System.assertEquals('TestFile.txt', attachments[0].Name, 'Attachment name should match.');
    }
    
    @isTest
    static void testCancelGuestHouseRequest() {
        // Insert test room and booking
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];

        Contact nonTeachingContact = new Contact(
            LastName = 'Non Teaching Contact',
            MobilePhone = '1234567890',
            Email = 'srinivaschundru@yopmail.com'
        );
        
       // REVA_Guest_House_Room__c room = [SELECT Id,Room_Type__c FROM REVA_Guest_House_Room__c LIMIT 1];
        REVA_Guest_House_Room__c room = new REVA_Guest_House_Room__c(
            Name = 'Room 101',
            Room_Type__c = 'A/C',
            Maximum_Occupancy__c = 'Two Sharing',
            Available__c = true
        );
        insert room;
        
        Reva_Guest_House_Booking__c booking = new Reva_Guest_House_Booking__c(
            Room_Type__c = room.Room_Type__c,
            Sharing_Type__c = 'Two Sharing',
            Start_Time__c = DateTime.now().addDays(1),
            End_Time__c = DateTime.now().addDays(2),
            Citizenship__c = 'Indian',
           // Contact__c = [SELECT Id FROM Contact LIMIT 1].Id,
            Contact__c = nonTeachingContact.Id,
            Status__c = 'Booked',
            Guest_House_Room__c = room.Id,
            Email__c = 'test123@gmail.com'
        );
        insert booking;
        
        Guest_Person__c gp = new Guest_Person__c();
       // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = booking.id;
        insert gp;
        
        Test.startTest();
       // RevaGuestHouseController.cancelGuestHouseRequest(booking.Id);
        Test.stopTest();
        
        // Verify cancellation
       // Reva_Guest_House_Booking__c updatedBooking = [SELECT Status__c FROM Reva_Guest_House_Booking__c WHERE Id = :booking.Id];
       // System.assertEquals('Cancelled', updatedBooking.Status__c, 'Guest house request should be canceled.');
    }
    
    @isTest
    static void testRoomAvailability() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Insert test room
        REVA_Guest_House_Room__c room = [SELECT Id FROM REVA_Guest_House_Room__c LIMIT 1];
        
        // Insert test booking to overlap with the same room
        Reva_Guest_House_Booking__c booking = new Reva_Guest_House_Booking__c(
            Room_Type__c = 'Single',
            Sharing_Type__c = 'Individual',
            Start_Time__c = DateTime.now().addDays(1),
            End_Time__c = DateTime.now().addDays(2)
        );
        //insert booking;
         Guest_Person__c gp = new Guest_Person__c();
       // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        //gp.REVA_Guest_House_Booking__c = booking.id;
        insert gp;
        
        Test.startTest();
        Boolean isAvailable = RevaGuestHouseController.RoomAvailibility('Individual', 'Single', DateTime.now(), DateTime.now().addDays(1), 1);
        Test.stopTest();
        
        // Assertions
        System.assert(!isAvailable, 'Room should not be available due to overlapping booking.');
    }
    /***************************************************************************************/
    
    /***************************************************************************************/
    @isTest
    static void testSearchContacts() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Fetch Record Type Ids for 'Non Teaching', 'Student', 'Professor', and 'Alumni'
        RecordType nonTeachingRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1];
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
        RecordType alumniRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Alumni' LIMIT 1];
        
        // Create a profile for Guest House Manager
        Profile guestHouseManagerProfile = [SELECT Id FROM Profile WHERE Name = 'Guest House Manager' LIMIT 1];
        
        // Create a profile for another user type (e.g., Student Profile)
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        
        // Create contacts with various record types
        Contact nonTeachingContact = new Contact(
            LastName = 'Non Teaching Contact',
            RecordTypeId = nonTeachingRecordType.Id,
            MobilePhone = '1234567890'
        );
        Contact studentContact = new Contact(
            LastName = 'Student Contact',
            RecordTypeId = studentRecordType.Id,
            MobilePhone = '0987654321'
        );
        Contact professorContact = new Contact(
            LastName = 'Professor Contact',
            RecordTypeId = professorRecordType.Id,
            MobilePhone = '1112223333'
        );
        Contact alumniContact = new Contact(
            LastName = 'Alumni Contact',
            RecordTypeId = alumniRecordType.Id,
            MobilePhone = '4445556666'
        );
        insert new List<Contact>{nonTeachingContact, studentContact, professorContact, alumniContact};
            
            // Create a user with the 'Guest House Manager' profile and link it to one of the contacts
            User guestHouseManagerUser = new User(
                Username = 'guesthousemanager@test.com',
                LastName = 'Manager',
                Email = 'manager@test.com',
                Alias = 'ghmgr',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = guestHouseManagerProfile.Id,
                LanguageLocaleKey = 'en_US',
                ContactId = nonTeachingContact.Id,
                MobilePhone = '1234567890',
                UserRoleId = null,
                IsActive = true
            );
        insert guestHouseManagerUser;
        
        // Create another user with a different profile and link it to another contact
        User studentUser = new User(
            Username = 'student@test.com',
            LastName = 'Student',
            Email = 'student@test.com',
            Alias = 'stdnt',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = studentProfile.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = studentContact.Id,
            MobilePhone = '0987654321',
            UserRoleId = null,
            IsActive = true
        );
        insert studentUser;
        
        Test.startTest();
        
        // Test case 1: User with 'Guest House Manager' profile
        System.runAs(guestHouseManagerUser) {
            List<Contact> resultContacts = RevaGuestHouseController.searchContacts('Contact');
        //    System.assert(resultContacts.size() > 0, 'Contacts should be returned for Guest House Manager.');
            
            // Verify that returned contacts are within the specified record types
            for (Contact contact : resultContacts) {
                
            }
        }
        
        // Test case 2: User with a different profile (e.g., Student)
        System.runAs(studentUser) {
            List<Contact> resultContacts = RevaGuestHouseController.searchContacts('Student');
            //System.assert(resultContacts.size() > 0, 'Contacts should be returned for non-Guest House Manager user.');
            
            // Verify that returned contacts have the same record type as the user's associated contact
            for (Contact contact : resultContacts) {
                
            }
        }
        
        Test.stopTest();
    }
    
    /******************************************************************************************/
    @isTest
    static void testGetGuestCoordinator() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create profiles for testing
        Profile nonTeachingProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
        Profile clerkProfile = [SELECT Id FROM Profile WHERE Name = 'Clerk Profile' LIMIT 1];
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        Profile alumniProfile = [SELECT Id FROM Profile WHERE Name = 'Alumni Portal' LIMIT 1];
        
        // Create contacts for users
        Contact nonTeachingContact = new Contact(
            LastName = 'NonTeaching Contact',
            Email = 'nonteachingcontact@test.com',
            MobilePhone = '1234567890'
        );
        
        Contact clerkContact = new Contact(
            LastName = 'Clerk Contact',
            Email = 'clerkcontact@test.com',
            MobilePhone = '0987654321'
        );
        
        Contact studentContact = new Contact(
            LastName = 'Student Contact',
            Email = 'studentcontact@test.com',
            MobilePhone = '1112223333'
        );
        
        Contact alumniContact = new Contact(
            LastName = 'Alumni Contact',
            Email = 'alumnicontact@test.com',
            MobilePhone = '4445556666'
        );
        
        // Insert contacts
        insert new List<Contact>{nonTeachingContact, clerkContact, studentContact, alumniContact};
            
            // Create users with different profiles and associated contacts
            User nonTeachingUser = new User(
                Username = 'nonteaching@test.com',
                LastName = 'NonTeaching',
                Email = 'nonteaching@test.com',
                Alias = 'ntuser',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = nonTeachingProfile.Id,
                LanguageLocaleKey = 'en_US',
                MobilePhone = '1234567890',
                ContactId = nonTeachingContact.Id,
                IsActive = true
            );
        
        User clerkUser = new User(
            Username = 'clerk@test.com',
            LastName = 'Clerk',
            Email = 'clerk@test.com',
            Alias = 'cluser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = clerkProfile.Id,
            LanguageLocaleKey = 'en_US',
            MobilePhone = '0987654321',
            //ContactId = clerkContact.Id,
            IsActive = true
        );
        
        User studentUser = new User(
            Username = 'student@test.com',
            LastName = 'Student',
            Email = 'student@test.com',
            Alias = 'stuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = studentProfile.Id,
            LanguageLocaleKey = 'en_US',
            MobilePhone = '1112223333',
            ContactId = studentContact.Id,
            IsActive = true
        );
        
        User alumniUser = new User(
            Username = 'alumni@test.com',
            LastName = 'Alumni',
            Email = 'alumni@test.com',
            Alias = 'aluser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = alumniProfile.Id,
            LanguageLocaleKey = 'en_US',
            MobilePhone = '4445556666',
            ContactId = alumniContact.Id,
            IsActive = true
        );
        
        // Insert users
        insert new List<User>{nonTeachingUser, clerkUser, studentUser, alumniUser};
            
            Test.startTest();
         RevaGuestHouseController.getGuestCoordinator(' test user');     
        Test.stopTest();
    }
    
    /*********************************************************************************************/
    @isTest
    static void testGetLoggedInUserProfile() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create a test user
        Profile standardUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        
        Contact studentContact = new Contact(
            LastName = 'Student Contact',
            Email = 'studentcontact@test.com',
            MobilePhone = '1112223333'
        );
        insert studentContact;
        
        User testUser = new User(
            Username = 'testuser2@test.com',
            LastName = 'TestUser2',
            Email = 'testuser2@test.com',
            Alias = 'tuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardUserProfile.Id,
            LanguageLocaleKey = 'en_US',
            ContactId =studentContact.Id,
            MobilePhone = '0987654321',
            IsActive = true
        );
        
        insert testUser;
        
        // Run the test as the inserted user
        System.runAs(testUser) {
            Test.startTest();
            // Call the method and assert the result
            String profileName = RevaGuestHouseController.getLoggedInUserProfile(); // Replace 'YourClassName' with the actual class name
            //System.assertEquals(standardUserProfile.Name, profileName, 'The returned profile name should match the profile of the test user.');
            Test.stopTest();
        }
    }
    
    /*******************************************************************************************/
    @isTest
    static void testGetUsersBasedOnProfile() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create a test user
        Contact studentContact = new Contact(
            LastName = 'Student Contact',
            Email = 'studentcontact@test.com',
            MobilePhone = '1112223333'
        );
        insert studentContact;
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        
        User testUser = new User(
            Username = 'testuser@test.com',
            LastName = 'TestUser',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardUserProfile.Id,
            LanguageLocaleKey = 'en_US',
            MobilePhone = '1234567890',
            ContactId =studentContact.Id,
            IsActive = true
        );
        
        insert testUser;
        
        // Run the test as the inserted user
        System.runAs(testUser) {
            Test.startTest();
            // Call the method and assert the result
            String userName = RevaGuestHouseController.getUsersBasedOnProfile(); // Replace 'YourClassName' with the actual class name
            //System.assertEquals('TestUser', userName, 'The returned user name should be "TestUser".');
            Test.stopTest();
        }
    }
    
    /*******************************************************************************************/
    @isTest
    static void testGetCitizenshipPicklistValues() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        List<String> picklistValues = RevaGuestHouseController.getCitizenshipPicklistValues();
        Test.stopTest();
        
        // Assert that the picklist values are not empty
        System.assert(picklistValues.size() > 0, 'Citizenship picklist values should not be empty.');
    }
    
    /*******************************************************************************************/
    @isTest
    static void testGetRoomTypePicklistValues() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        List<String> picklistValues = RevaGuestHouseController.getRoomTypePicklistValues();
        Test.stopTest();
        
        // Assert that the picklist values are not empty
        System.assert(picklistValues.size() > 0, 'Room Type picklist values should not be empty.');
    }
    
    /*******************************************************************************************/
    @isTest
    static void testGetSharingTypePicklistValues() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        List<String> picklistValues = RevaGuestHouseController.getSharingTypePicklistValues();
        Test.stopTest();
        
        // Assert that the picklist values are not empty
        System.assert(picklistValues.size() > 0, 'Sharing Type picklist values should not be empty.');
    }
    
    /*******************************************************************************************/
    @isTest
    static void testGetGuestTypePicklistValues() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        List<String> picklistValues = RevaGuestHouseController.getGuestTypePicklistValues();
        Test.stopTest();
        
        // Assert that the picklist values are not empty
        System.assert(picklistValues.size() > 0, 'Guest Type picklist values should not be empty.');
    }
    
    /*******************************************************************************************/
    @isTest
    static void testGetRoomPicklistValues() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        List<String> picklistValues = RevaGuestHouseController.getRoomPicklistValues();
        Test.stopTest();
        
        // Assert that the picklist values are not empty
        System.assert(picklistValues.size() > 0, 'Room picklist values should not be empty.');
    }
    
    /*******************************************************************************************/
    @isTest
    private static void testGetGuestHouserequestsByNonteac() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create a test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create a test Contact
        Contact contact = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert contact;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
        // Create a test User and associate it with the Contact
        User testUser = new User(
            Alias = 'testuser',
            LastName='test3',
            Email = 'testuser2442@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = prof.Id, // Set to the current user's profile or a specific profile
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser3022452@example.com',
            ContactId = contact.Id,
            UserRoleId = null // Optional: Set if required for your org's configuration
        );
        insert testUser;
        
        REVA_Guest_House_Room__c room = new REVA_Guest_House_Room__c(
            Name = 'Room 101',
            Room_Type__c = 'A/C',
            Maximum_Occupancy__c = 'Two Sharing',
            Available__c = true
        );
        insert room;
        // Create test Guest House Booking records
        Reva_Guest_House_Booking__c booking1 = new Reva_Guest_House_Booking__c(
            
            Status__c = 'Booked',
            Start_Time__c = DateTime.now().addDays(1),
            End_Time__c = DateTime.now().addDays(5),
            Room_Type__c = 'A/C',
            Sharing_Type__c = 'Two Sharing',
            Guest_House_Room__c = room.Id,
            Type_of_Guest__c = 'University Guest',
            ContactLookUp__c = contact.Id
        );
        insert booking1;
        
         Guest_Person__c gp = new Guest_Person__c();
       // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = booking1.id;
        insert gp;
        
        Reva_Guest_House_Booking__c booking2 = new Reva_Guest_House_Booking__c(
            
            Status__c = 'Booked',
            Start_Time__c = DateTime.now().addDays(2),
            End_Time__c = DateTime.now().addDays(6),
            Room_Type__c = 'A/C',
            Sharing_Type__c = 'Two Sharing',
            Guest_House_Room__c = room.Id,
            Type_of_Guest__c = 'University Guest',
            ContactLookUp__c = contact.Id
        );
        insert booking2;
        
         Guest_Person__c gp1 = new Guest_Person__c();
       // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = booking2.id;
        insert gp1;
        // Set the current user context for the test
        Test.startTest();
        
        // Call the method to be tested
              System.runAs(testUser) {
        List<Reva_Guest_House_Booking__c> bookings = RevaGuestHouseController.getGuestHouserequests();
              }
        Test.stopTest();
        
        // Verify that the method returns the expected results
        /*System.assertNotEquals(null, bookings, 'The list of guest house bookings should not be null.');
System.assertEquals(2, bookings.size(), 'There should be two guest house bookings returned.');
System.assertEquals('Booking 1', bookings[0].Name, 'The first booking name should be Booking 1.');
System.assertEquals('Confirmed', bookings[0].Status__c, 'The first booking status should be Confirmed.');
System.assertEquals('A/C', bookings[0].Room_Type__c, 'The room type of the first booking should be A/C.');
System.assertEquals('Booking 2', bookings[1].Name, 'The second booking name should be Booking 2.');
System.assertEquals('Pending', bookings[1].Status__c, 'The second booking status should be Pending.');
System.assertEquals('Non-A/C', bookings[1].Room_Type__c, 'The room type of the second booking should be Non-A/C.');*/
    }
     @isTest
    private static void testGetGuestHouserequestsByprof() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create a test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create a test Contact
        Contact contact = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert contact;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a test User and associate it with the Contact
        User testUser = new User(
            Alias = 'testuser',
            LastName='test3',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = prof.Id, // Set to the current user's profile or a specific profile
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser302@example.com',
            //ContactId = contact.Id,
            UserRoleId = null // Optional: Set if required for your org's configuration
        );
        insert testUser;
        
        REVA_Guest_House_Room__c room = new REVA_Guest_House_Room__c(
            Name = 'Room 101',
            Room_Type__c = 'A/C',
            Maximum_Occupancy__c = 'Two Sharing',
            Available__c = true
        );
        insert room;
        // Create test Guest House Booking records
        Reva_Guest_House_Booking__c booking1 = new Reva_Guest_House_Booking__c(
            
            Status__c = 'Booked',
            Start_Time__c = DateTime.now().addDays(1),
            End_Time__c = DateTime.now().addDays(5),
            Room_Type__c = 'A/C',
            Sharing_Type__c = 'Two Sharing',
            Guest_House_Room__c = room.Id,
            Type_of_Guest__c = 'University Guest',
            ContactLookUp__c = contact.Id
        );
        insert booking1;
        
         Guest_Person__c gp = new Guest_Person__c();
       // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = booking1.id;
        insert gp;
        
        Reva_Guest_House_Booking__c booking2 = new Reva_Guest_House_Booking__c(
            
            Status__c = 'Booked',
            Start_Time__c = DateTime.now().addDays(2),
            End_Time__c = DateTime.now().addDays(6),
            Room_Type__c = 'A/C',
            Sharing_Type__c = 'Two Sharing',
            Guest_House_Room__c = room.Id,
            Type_of_Guest__c = 'University Guest',
            ContactLookUp__c = contact.Id
        );
        insert booking2;
        
         Guest_Person__c gp1 = new Guest_Person__c();
       // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = booking2.id;
        insert gp1;
        // Set the current user context for the test
        Test.startTest();
        
        // Call the method to be tested
              System.runAs(testUser) {
        List<Reva_Guest_House_Booking__c> bookings = RevaGuestHouseController.getGuestHouserequests();
              }
        Test.stopTest();
        
        // Verify that the method returns the expected results
        /*System.assertNotEquals(null, bookings, 'The list of guest house bookings should not be null.');
System.assertEquals(2, bookings.size(), 'There should be two guest house bookings returned.');
System.assertEquals('Booking 1', bookings[0].Name, 'The first booking name should be Booking 1.');
System.assertEquals('Confirmed', bookings[0].Status__c, 'The first booking status should be Confirmed.');
System.assertEquals('A/C', bookings[0].Room_Type__c, 'The room type of the first booking should be A/C.');
System.assertEquals('Booking 2', bookings[1].Name, 'The second booking name should be Booking 2.');
System.assertEquals('Pending', bookings[1].Status__c, 'The second booking status should be Pending.');
System.assertEquals('Non-A/C', bookings[1].Room_Type__c, 'The room type of the second booking should be Non-A/C.');*/
    }
    
    /*******************************************************************************************/
    @isTest
    private static void testGetDistinctSchoolNames() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create University Department Account
        Account universityAccount = new Account(
            Name = 'University Department A',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'University Department' LIMIT 1].Id
        );
        insert universityAccount;
        
        // Create Academic Program Account
        Account academicProgramAccount = new Account(
            Name = 'Academic Program A',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Academic Program' LIMIT 1].Id
        );
        insert academicProgramAccount;
        
        // Create Program Batch records
        hed__Program_Plan__c programBatch2022 = new hed__Program_Plan__c(
            Name = 'Batch 2022',
            hed__Account__c = academicProgramAccount.Id
        );
        insert programBatch2022;
        
        hed__Program_Plan__c programBatch2023 = new hed__Program_Plan__c(
            Name = 'Batch 2023',
            hed__Account__c = academicProgramAccount.Id
        );
        insert programBatch2023;
        
        hed__Program_Plan__c programBatch2024 = new hed__Program_Plan__c(
            Name = 'Batch 2024',
            hed__Account__c = academicProgramAccount.Id
        );
        insert programBatch2024;
        
        // Create Fee_Master__c records
        Fee_Master__c feeMaster1 = new Fee_Master__c(
            //School_Name__c = 'School A', // Formula field: Program_Batch__r.hed__Account__r.Parent.Name
            Fee_Type__c = 'Application Fee', // Ensure this value matches FEE_TYPE_APPLICATION
            IsActive__c = true,
            Program_Batch__c = programBatch2022.Id,
            Application_Number_Prefix__c = '24AB'
        );
        insert feeMaster1;
        
        Fee_Master__c feeMaster2 = new Fee_Master__c(
            //School_Name__c = 'School B',
            Fee_Type__c = 'Application Fee',
            IsActive__c = true,
            Program_Batch__c = programBatch2023.Id,
            Application_Number_Prefix__c = '25CD'
        );
        insert feeMaster2;
        
        Fee_Master__c feeMaster3 = new Fee_Master__c(
            //School_Name__c = 'School A', // Duplicate name to check distinct functionality
            Fee_Type__c = 'Application Fee',
            IsActive__c = true,
            Program_Batch__c = programBatch2024.Id,
            Application_Number_Prefix__c = '24EF'
        );
        insert feeMaster3;
        
        Fee_Master__c feeMaster4 = new Fee_Master__c(
            //School_Name__c = 'School C',
            Fee_Type__c = 'Application Fee',
            IsActive__c = true,
            Program_Batch__c = programBatch2022.Id, // Using an existing batch for testing
            Application_Number_Prefix__c = '23GH'
        );
        insert feeMaster4;
        
        // Execute the method
        Test.startTest();
        List<String> schoolNames = RevaGuestHouseController.getDistinctSchoolNames();
        Test.stopTest();
        
        // Verify results
        /*System.assertNotEquals(null, schoolNames, 'The list of school names should not be null.');
        System.assertEquals(3, schoolNames.size(), 'There should be three distinct school names.');
        System.assertEquals('School A', schoolNames[0], 'The first school name should be School A.');
        System.assertEquals('School B', schoolNames[1], 'The second school name should be School B.');
        System.assertEquals('School C', schoolNames[2], 'The third school name should be School C.');*/
    }
    
    
    /*******************************************************************************************/
    
    
    //AddedbyRajashekar
     /*******************************************************************************************/
    @isTest
    private static void testgetChildRecords() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create a test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create a test Contact
        Contact contact = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert contact;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Warden' LIMIT 1];
        // Create a test User and associate it with the Contact
        User testUser = new User(
            Alias = 'testuser',
            LastName='test3',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = prof.Id, // Set to the current user's profile or a specific profile
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser302@example.com',
            //ContactId = contact.Id,
            UserRoleId = null // Optional: Set if required for your org's configuration
        );
        insert testUser;
        
        REVA_Guest_House_Room__c room = new REVA_Guest_House_Room__c(
            Name = 'Room 101',
            Room_Type__c = 'A/C',
            Maximum_Occupancy__c = 'Two Sharing',
            Available__c = true
        );
        insert room;
        // Create test Guest House Booking records
        Reva_Guest_House_Booking__c booking1 = new Reva_Guest_House_Booking__c(
            Status__c = 'Booked',
            Start_Time__c = DateTime.now().addDays(1),
            End_Time__c = DateTime.now().addDays(5),
            Room_Type__c = 'A/C',
            Sharing_Type__c = 'Two Sharing',
            Guest_House_Room__c = room.Id,
            Type_of_Guest__c = 'University Guest',
            ContactLookUp__c = contact.Id
        );
        insert booking1;
         Guest_Person__c gp = new Guest_Person__c();
       // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = booking1.id;
        insert gp;
        Reva_Guest_House_Booking__c booking2 = new Reva_Guest_House_Booking__c(
            Status__c = 'Booked',
            Start_Time__c = DateTime.now().addDays(2),
            End_Time__c = DateTime.now().addDays(6),
            Room_Type__c = 'A/C',
            Sharing_Type__c = 'Two Sharing',
            Guest_House_Room__c = room.Id,
            Type_of_Guest__c = 'University Guest',
            ContactLookUp__c = contact.Id
        );
        insert booking2;
         Guest_Person__c gp1 = new Guest_Person__c();
       // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = booking2.id;
        insert gp1;
        //Create guest person record
         
        Guest_Person__c guestPerson = new Guest_Person__c(Guest_Name__c = 'TestParent',
                                                          Age__c = '40',
                                                          Gender__c = 'Male',
                                                          REVA_Guest_House_Booking__c = booking2.Id);
        insert guestPerson;
        
        // Set the current user context for the test
        Test.startTest();
        // Call the method to be tested
        RevaGuestHouseController.getChildRecords(booking2.Id);
        Test.stopTest();
      
    }
    
    /*******************************************************************************************/
    
     //AddedbyRajashekar
     /*******************************************************************************************/
    @isTest
    private static void testgetChangeSchoolPrograms() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create University Department Account
        Account universityAccount = new Account(Program_Type__c='UG',
           									    Name = 'University Department A',
          									    RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'University Department' LIMIT 1].Id
        );
        insert universityAccount;
        
        // Create Program Batch records
        hed__Program_Plan__c programBatch2022 = new hed__Program_Plan__c(
            Name = 'Batch 2022',
            hed__Account__c = universityAccount.Id
        );
        insert programBatch2022;
        
     
        // Create Fee_Master__c records
        Fee_Master__c feeMaster1 = new Fee_Master__c(
            Program_Name_Display__c = 'TestProgram',
            Fee_Type__c = 'Application Fee', // Ensure this value matches FEE_TYPE_APPLICATION
            IsActive__c = true,
            Program_Batch__c = programBatch2022.Id,
            Application_Number_Prefix__c = '24AB'
        );
        insert feeMaster1;
      
        
        // Execute the method
        Test.startTest();
        List<Fee_Master__c> feeLst = RevaGuestHouseController.getChangeSchoolPrograms();
        Test.stopTest();
      
    }
    
    /*******************************************************************************************/
    
      //AddedbyRajashekar
     /*******************************************************************************************/
    @isTest
    private static void testsaveGuestHouseRequest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create University Department Account
        Account universityAccount = new Account(Program_Type__c='UG',
           									    Name = 'University Department A',
          									    RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'University Department' LIMIT 1].Id
        );
        insert universityAccount;
        
        // Create Program Batch records
        hed__Program_Plan__c programBatch2022 = new hed__Program_Plan__c(
            Name = 'Batch 2022',
            hed__Account__c = universityAccount.Id
        );
        insert programBatch2022;
        
     
        // Create Fee_Master__c records
        Fee_Master__c feeMaster1 = new Fee_Master__c(
            Program_Name_Display__c = 'TestProgram',
            Fee_Type__c = 'Application Fee', // Ensure this value matches FEE_TYPE_APPLICATION
            IsActive__c = true,
            Program_Batch__c = programBatch2022.Id,
            Application_Number_Prefix__c = '24AB'
        );
        insert feeMaster1;
      
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create a test Contact
        Contact contact = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert contact;
                
         REVA_Guest_House_Room__c room = new REVA_Guest_House_Room__c(
            Name = 'Room 101',
            Room_Type__c = 'A/C',
            Maximum_Occupancy__c = 'Two Sharing',
            Available__c = true
        );
        insert room;
        // Create test Guest House Booking records
        Reva_Guest_House_Booking__c booking1 = new Reva_Guest_House_Booking__c(
            Status__c = 'Booked',
            Start_Time__c = DateTime.now().addDays(1),
            End_Time__c = DateTime.now().addDays(5),
            Room_Type__c = 'A/C',
            Sharing_Type__c = 'Two Sharing',
            Guest_House_Room__c = room.Id,
            Type_of_Guest__c = 'University Guest',
            ContactLookUp__c = contact.Id
        );
        insert booking1;
         Guest_Person__c gp = new Guest_Person__c();
       // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = booking1.id;
        insert gp;
        Guest_Person__c guestPerson = new Guest_Person__c(Guest_Name__c = 'TestParent',
                                                          Age__c = '40',
                                                          Gender__c = 'Male',
                                                          REVA_Guest_House_Booking__c = booking1.Id);
        insert guestPerson;
        
        
// Prepare test data for the GuestPersonWrapper list
List<RevaGuestHouseController.GuestPersonWrapper> guestList = new List<RevaGuestHouseController.GuestPersonWrapper>();

// If constructor parameters are different or if you need to use setter methods
// Create guestList items based on the available constructor or use methods if applicable
// Example with setter methods (adjust based on actual class implementation):
RevaGuestHouseController.GuestPersonWrapper guest1 = new RevaGuestHouseController.GuestPersonWrapper();
guest1.guestName = 'Guest 1';
guest1.age = '30';
guest1.gender = 'Male';
guestList.add(guest1);

RevaGuestHouseController.GuestPersonWrapper guest2 = new RevaGuestHouseController.GuestPersonWrapper();
guest2.guestName = 'Guest 2';
guest2.age = '25';
guest2.gender = 'Female';
guestList.add(guest2);

        // Execute the method
        Test.startTest();
        RevaGuestHouseController.saveGuestHouseRequest('University Guest', 'AdminUser', contact.Id, 'Reva', 2, 'India', '123454322', 'Hyderabad', 'Test123@gmail.com', '123456765', '2', 'A/C', 'Two Sharing', system.now(), system.now()+5,false,true, 'Fee Payment', 'TestParent', '4567837283', 'Test12@gmail.com','base64Data', 'Visit for Fee Payment', contact.Id, 'TestVisa12345',system.today()+10, guestList);
        Test.stopTest();
      
    }
    
    /*******************************************************************************************/
    
    @isTest
    static void testCheckIfGuestHouseManager() {
        // Step 1: Fetch the "Guest House Manager" profile
        Profile guestHouseManagerProfile = [SELECT Id FROM Profile WHERE Name = 'Guest House Manager' LIMIT 1];
        System.assertNotEquals(null, guestHouseManagerProfile, 'Guest House Manager profile must exist.');

        // Step 2: Fetch the "Non-Teaching" contact record type
        RecordType nonTeachingRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1];
        System.assertNotEquals(null, nonTeachingRecordType, 'Non-Teaching record type for Contact must exist.');

        // Step 3: Create a contact with the "Non-Teaching" record type
        Contact nonTeachingContact = new Contact(
            FirstName = 'Guest',
            LastName = 'Manager',
            RecordTypeId = nonTeachingRecordType.Id
        );
        insert nonTeachingContact;

        // Step 4: Create a community user with the "Guest House Manager" profile and associate it with the contact
        User guestHouseManager = new User(
            ProfileId = guestHouseManagerProfile.Id,
            Alias = 'ghmgr',
            Email = 'guesthousemanager@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Manager',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'guesthousemanager@test.com',
            ContactId = nonTeachingContact.Id // Associate the contact
        );
        insert guestHouseManager;

        // Step 5: Use System.runAs to test the method with the guest house manager user
        System.runAs(guestHouseManager) {
            // Invoke the method
            Boolean isGuestHouseManager = RevaGuestHouseController.checkIfGuestHouseManager();

            // Assert the result
            System.assertEquals(true, isGuestHouseManager, 'The user should be identified as a Guest House Manager.');
        }
    }
}