@isTest
public class UpdateWardenUserTest {
    public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
   /* @testSetup
    static void setup() {
        // Create test Warden Users
        Warden_Users__c blockWarden = new Warden_Users__c(
            Name = 'Block Warden',
            Block__c = 'A',
            Gender__C = 'Boys'
        );
        insert blockWarden;
        
        Warden_Users__c chiefWarden = new Warden_Users__c(
            Name = 'Chief Warden',
            Block__c = null,
            Gender__C = 'Boys'
        );
        insert chiefWarden;
        
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test367@gmail.com',
            MobilePhone = '9998887770', 
            Date_of_Admission_in_Institute__c = System.today(), 
            SRN_Number__c ='EOBP3458D',
            Primary_Academic_Program__c = acc.Id,
            hed__Gender__c='Male'
        );
        insert contact;
        
        // Create a test Warden user
        Profile wardenProfile = [SELECT Id FROM Profile WHERE Name = 'Warden' LIMIT 1];
        
        User blockWardenUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Block Warden',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = wardenProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'block.warden@example.com'
        );
        insert blockWardenUser;
        
        User chiefWardenUser = new User(
            Username = 'chief.warden@example.com',
            FirstName = 'Chief',
            LastName = 'Warden',
            Email = 'chief.warden@example.com',
            Alias = 'cwarden',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = wardenProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert chiefWardenUser;
        
        Reva_Hostel_Room__c hostelRoom = new Reva_Hostel_Room__c(
            Name = 'HR-NO-202',
            Floor__c = 'FF',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A',
            Room_Category__c = '1 Eng CS'
        );
        insert hostelRoom;
        
        Student_Fee__c stuFee = new Student_Fee__c(
            Amount_paid__c = 20000,
            Amount_Pending__c = 20000,
            Amount__c = 40000
        );
        insert stuFee;
        
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Reva_Hostel_JoiningDate__c = System.today(),
            RevaHostelVacatingDate__c = System.today() + 10,
            Type__c = '4',
            Hostel_Room_Request_For__c = contact.Id,
            Reva_Hostel_Room__c = hostelRoom.Id,
            Status__c = 'Room Allotted', 
            Approved_by_warden__c = true,
            Approved_by_ChiefWarden__c = true,
            Approved_by_Admin__c = true,
            Student_Fee__c = stuFee.Id
        );
        insert hostelRequest;
    }*/
    
    @isTest
    static void testGetCustomWardenUser() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
          Warden_Users__c blockWarden = new Warden_Users__c(
            Name = 'Block Warden',
            Block__c = 'A',
            Gender__C = 'Boys'
        );
        insert blockWarden;
        
        Warden_Users__c chiefWarden = new Warden_Users__c(
            Name = 'Chief Warden',
            Block__c = null,
            Gender__C = 'Boys'
        );
        insert chiefWarden;
        
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test367@gmail.com',
            MobilePhone = '9998887770', 
            Date_of_Admission_in_Institute__c = System.today(), 
            SRN_Number__c ='EOBP3458D',
            Primary_Academic_Program__c = acc.Id,
            hed__Gender__c='Male'
        );
        insert contact;
        
        // Create a test Warden user
        Profile wardenProfile = [SELECT Id FROM Profile WHERE Name = 'Warden' LIMIT 1];
        
        User blockWardenUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Block Warden',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = wardenProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'block.warden@example.com'
        );
        insert blockWardenUser;
        
        User chiefWardenUser = new User(
            Username = 'chief.warden@example.com',
            FirstName = 'Chief',
            LastName = 'Warden',
            Email = 'chief.warden@example.com',
            Alias = 'cwarden',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = wardenProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert chiefWardenUser;
        
        Reva_Hostel_Room__c hostelRoom = new Reva_Hostel_Room__c(
            Name = 'HR-NO-202',
            Floor__c = 'FF',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A',
            Room_Category__c = '1 Eng CS'
        );
        insert hostelRoom;
        
        Student_Fee__c stuFee = new Student_Fee__c(
            Amount_paid__c = 20000,
            Amount_Pending__c = 20000,
            Amount__c = 40000
        );
        insert stuFee;
        
        Reva_Hostel_Request__c hostelRequests = new Reva_Hostel_Request__c(
            Reva_Hostel_JoiningDate__c = System.today(),
            RevaHostelVacatingDate__c = System.today() + 10,
            Type__c = '4',
            Hostel_Room_Request_For__c = contact.Id,
            Reva_Hostel_Room__c = hostelRoom.Id,
            Status__c = 'Room Allotted', 
            Approved_by_warden__c = true,
            Approved_by_ChiefWarden__c = true,
            Approved_by_Admin__c = true,
            Student_Fee__c = stuFee.Id
        );
        insert hostelRequests;
        
        //List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id FROM Reva_Hostel_Request__c WHERE Status__c = 'Room Allotted' LIMIT 1];
       
        
        // Adding debug to trace
        System.debug('Hostel Requests: ' + hostelRequests);
       // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        
        UpdateWardenUser.GetCustomWardenUser(new List<Reva_Hostel_Request__c> {hostelRequests} );
        Test.stopTest();
        
        // Verify that Warden__c and ChiefWarden__c were updated correctly
        Reva_Hostel_Request__c updatedRequest = [
            SELECT Warden__c, ChiefWarden__c 
            FROM Reva_Hostel_Request__c 
            WHERE Id = :hostelRequests.Id LIMIT 1
        ];
        
        // Verify that the fields were updated
        System.assertNotEquals(null, updatedRequest.Warden__c, 'Warden__c should have been updated');
        System.assertNotEquals(null, updatedRequest.ChiefWarden__c, 'ChiefWarden__c should have been updated');
    }
    
    @isTest
    static void testEmptyInput() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
          Warden_Users__c blockWarden = new Warden_Users__c(
            Name = 'Block Warden',
            Block__c = 'A',
            Gender__C = 'Boys'
        );
        insert blockWarden;
        
        Warden_Users__c chiefWarden = new Warden_Users__c(
            Name = 'Chief Warden',
            Block__c = null,
            Gender__C = 'Boys'
        );
        insert chiefWarden;
        
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test367@gmail.com',
            MobilePhone = '9998887770', 
            Date_of_Admission_in_Institute__c = System.today(), 
            SRN_Number__c ='EOBP3458D',
            Primary_Academic_Program__c = acc.Id,
            hed__Gender__c='Male'
        );
        insert contact;
        
        // Create a test Warden user
        Profile wardenProfile = [SELECT Id FROM Profile WHERE Name = 'Warden' LIMIT 1];
        
        User blockWardenUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Block Warden',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = wardenProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'block.warden@example.com'
        );
        insert blockWardenUser;
        
        User chiefWardenUser = new User(
            Username = 'chief.warden@example.com',
            FirstName = 'Chief',
            LastName = 'Warden',
            Email = 'chief.warden@example.com',
            Alias = 'cwarden',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = wardenProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert chiefWardenUser;
        
        Reva_Hostel_Room__c hostelRoom = new Reva_Hostel_Room__c(
            Name = 'HR-NO-202',
            Floor__c = 'FF',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A',
            Room_Category__c = '1 Eng CS'
        );
        insert hostelRoom;
        
        Student_Fee__c stuFee = new Student_Fee__c(
            Amount_paid__c = 20000,
            Amount_Pending__c = 20000,
            Amount__c = 40000
        );
        insert stuFee;
        
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Reva_Hostel_JoiningDate__c = System.today(),
            RevaHostelVacatingDate__c = System.today() + 10,
            Type__c = '4',
            Hostel_Room_Request_For__c = contact.Id,
            Reva_Hostel_Room__c = hostelRoom.Id,
            Status__c = 'Room Allotted', 
            Approved_by_warden__c = true,
            Approved_by_ChiefWarden__c = true,
            Approved_by_Admin__c = true,
            Student_Fee__c = stuFee.Id
        );
        insert hostelRequest;
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        UpdateWardenUser.GetCustomWardenUser(new List<Reva_Hostel_Request__c>());
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Reva_Hostel_Request__c], 'No records should have been updated');
    }
}