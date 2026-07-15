@isTest
public class RevaGuestHouseBookingTriggerHandlerTest {
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    private static void testHandleBookingPayments() {
         
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
 
        // Setup test data
        Account universityAccount = new Account(
            Name = 'University Department A',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'University Department' LIMIT 1].Id
        );
        insert universityAccount;
        
        Account academicProgramAccount = new Account(
            Name = 'Academic Program A',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Academic Program' LIMIT 1].Id
        );
        insert academicProgramAccount;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'Batch 2023',
            hed__Account__c = academicProgramAccount.Id
        );
        insert programBatch;
        
        Guest_House_Booking__c customSetting = new Guest_House_Booking__c(
            Name = 'test1',
            Amount__c = 100,
            Room_Type__c = 'A/C',
            Sharing__c = 'Shared'
        );
        insert customSetting;
        
       /* Contact studentContact = new Contact(
            LastName = 'Student Contact',
            Email = 'studentcontact@test.com',
            MobilePhone = '1112223333'
        );
        insert studentContact;*/
        RecordType professorRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];

        // Create a contact with Professor record type
        Contact studentContact = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert studentContact;
        
         Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Guest House Manager' LIMIT 1];

          User testUser = new User(
            MobilePhone = '27445678',
            ProfileId = p.Id,
            Username = 'testuser@example.com',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'tuser',
            LastName = 'Testing',
            ContactId = studentContact.Id
        );
        insert testUser;
        
        
        Reva_Guest_House_Booking__c guestBooking = new Reva_Guest_House_Booking__c(
            //Name = 'Booking 1',
            Room_Type__c = 'A/C',
            No_of_Rooms__c = '2',
            Start_Time__c = DateTime.now().addHours(-2), // 2 hours ago
            End_Time__c = DateTime.now(), // Now
            ContactLookUp__c = studentContact.Id, // Using student contact for testing
            Sharing_Type__c = 'Shared',
            Email__c = 'test123@gmail.com'
        );
        insert guestBooking;
       // System.runAs(testUser) {
        Guest_Person__c gp = new Guest_Person__c();
        // gp.Name = 'test';
        gp.Guest_Name__c = 'test1';
        gp.REVA_Guest_House_Booking__c = guestBooking.id;
        insert gp;
        update guestBooking;
        // Execute the method
        Test.startTest();
        RevaGuestHouseBookingTriggerHandler.handleBookingPayments(new List<Reva_Guest_House_Booking__c> { guestBooking });
        Test.stopTest();
        
       // }
        // Verify results
        Student_Fee__c sf = [SELECT Id, Amount__c, Amount_Pending__c, Actual_Program_Fee__c FROM Student_Fee__c WHERE Contact__c = :studentContact.Id AND Fee_Type__c = 'Guest House Fee' LIMIT 1];
        
        System.assertNotEquals(null, sf, 'Student Fee record should be created.');
        System.assertEquals(200, sf.Amount__c, 'The amount should be calculated as 200.');
        System.assertEquals(200, sf.Amount_Pending__c, 'The pending amount should be 200.');
        System.assertEquals(200, sf.Actual_Program_Fee__c, 'The actual program fee should be 200.');
    }

    @isTest
    private static void testHandleExatandPayments() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
 
        // Setup test data
        Account universityAccount = new Account(
            Name = 'University Department A',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'University Department' LIMIT 1].Id
        );
        insert universityAccount;
        
        Account academicProgramAccount = new Account(
            Name = 'Academic Program A',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Academic Program' LIMIT 1].Id
        );
        insert academicProgramAccount;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'Batch 2023',
            hed__Account__c = academicProgramAccount.Id
        );
        insert programBatch;
        
        Guest_House_Booking__c customSetting = new Guest_House_Booking__c(
            Name = 'test2',
            Amount__c = 100,
            Room_Type__c = 'A/C',
            Sharing__c = 'Shared'
        );
        insert customSetting;
        
        RecordType professorRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];

        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;
        
        Reva_Guest_House_Booking__c oldGuestBooking = new Reva_Guest_House_Booking__c(
            //Name = 'Old Booking',
            Room_Type__c = 'A/C',
            No_of_Rooms__c = '2',
            Start_Time__c = DateTime.now().addHours(1), // 1 hour ago
            End_Time__c = DateTime.now().addHours(32), // Now
            ContactLookUp__c = testContact1.Id, // Using student contact2 for testing
            Sharing_Type__c = 'Shared',
            Email__c = 'test123@gmail.com'
            
        );
        insert oldGuestBooking;
        system.debug('old==>'+ [SELECT id,Name,Duration__c From Reva_Guest_House_Booking__c Where Id=:oldGuestBooking.Id]);
        Reva_Guest_House_Booking__c oldRecFetch = [SELECT id,Name,Duration__c From Reva_Guest_House_Booking__c Where Id=:oldGuestBooking.Id];
       
        Reva_Guest_House_Booking__c newGuestBooking = new Reva_Guest_House_Booking__c(
            Id = oldGuestBooking.Id,
            Start_Time__c = DateTime.now().addHours(3), // 2 hours ago
            End_Time__c = DateTime.now().addHours(7) // 1 hour from now
        );
        
        Student_Fee__c sfee = new Student_Fee__c(Name = 'Guest House Fee',
                                               Contact__c = testContact1.Id,
                                               Amount_Pending__c = 200,
                                               Amount__c = 200,
                                               Actual_Program_Fee__c = 0,
                                               Fee_Type__c ='Hostel Fee');
        insert sfee;
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Guest House Manager' LIMIT 1];

        User testUser = new User(
            MobilePhone = '27445678',
            ProfileId = p.Id,
            Username = 'testuser@example.com',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'tuser',
            LastName = 'Testing',
            ContactId = testContact1.Id
        );
        insert testUser;
        
       // User testUser = [select id,Name from User where ProfileId =: p.Id LIMIT 1];
        // Execute the method
        // 
       // System.runAs(testUser) {
        Test.startTest();
        RevaGuestHouseBookingTriggerHandler.handleExatandPayments(new List<Reva_Guest_House_Booking__c> { newGuestBooking }, new Map<Id, Reva_Guest_House_Booking__c> { 
            oldRecFetch.Id => oldRecFetch 
        });
        Test.stopTest();
       // }
        // Verify results
        Student_Fee__c sf = [SELECT Id, Amount__c, Amount_Pending__c, Actual_Program_Fee__c FROM Student_Fee__c WHERE Contact__c = :testContact1.Id AND Fee_Type__c = 'Hostel Fee' LIMIT 1];
        
      
    }
}