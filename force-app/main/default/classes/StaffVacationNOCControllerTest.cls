@IsTest
public class StaffVacationNOCControllerTest {
    
    @TestSetup
    static void setup() {
        // Create Profile for Staff
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
        
        // Create RecordType for Contact
        RecordType staffRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1];
        System.assertNotEquals(null, staffRecordType, 'RecordType "Non Teaching" for Contact should exist.');

        // Create Contact
        Contact contact = new Contact(
            LastName = 'Test Contact',
            Email = 'test367@gmail.com',
            RecordTypeId = staffRecordType.Id,
            hed__WorkEmail__c ='test367@gmail.com'
        );
        insert contact;

        // Create a User associated with the contact
        User testUser = new User(
            Alias = 'testuser',
            Email = 'test367@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testStaff555staffNoc@example.com',
            ContactId = contact.Id
        );
        insert testUser;
        
        // Create Staff_Quarters_Request__c and set Room_Request_For__c to the test user's Id
        Staff_Quarters_Request__c sqr = new Staff_Quarters_Request__c(
            Staff_Quarters_Joining_Date__c = System.Today(),
            Room_Request_For__c = testUser.Id,
            Status__c ='Approved',
            Quarter_Request_For__c =contact.Id
        );
        insert sqr;
    }
    
    @IsTest
    static void testStaffVacationNOCController() {
        // Retrieve the test data
        User staffUser = [SELECT Id, LastName FROM User WHERE Email = 'test367@gmail.com' LIMIT 1];
        System.assertNotEquals(null, staffUser, 'Test User should exist.');
        
        Staff_Quarters_Request__c staffRequest = [SELECT Id FROM Staff_Quarters_Request__c WHERE Room_Request_For__c = :staffUser.Id LIMIT 1];
        System.assertNotEquals(null, staffRequest, 'Staff Quarters Request should exist.');
        
        // Set the page reference and parameters
        PageReference pageRef = Page.StaffVacationNOC;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', staffRequest.Id);
        
        // Run the test as the staff user
        System.runAs(staffUser) {
            StaffVacationNOCController svnc = new StaffVacationNOCController();
            System.assertNotEquals(null, svnc.staffQuarterRequests, 'Staff quarter request should be retrieved.');
            System.assertNotEquals(null, svnc.Con, 'Contact should be retrieved.');
        }
    }
}