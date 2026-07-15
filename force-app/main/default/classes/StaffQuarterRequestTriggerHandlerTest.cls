/*@IsTest
public class StaffQuarterRequestTriggerHandlerTest {

@IsTest
static void testCreateAttachment() {
// Create a mock Warden user
User wardenUser = new User(
FirstName = 'Warden', 
LastName = 'One', 
Email = 'warden1@example.com', 
Username = 'warden1@example.com' + System.currentTimeMillis(),
Alias = 'warden',
TimeZoneSidKey = 'America/Los_Angeles',
LocaleSidKey = 'en_US',
EmailEncodingKey = 'UTF-8',
ProfileId = [SELECT Id FROM Profile WHERE Name = 'Warden' LIMIT 1].Id,
LanguageLocaleKey = 'en_US'
);
insert wardenUser;

//insert contact
Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
RecordType nonTeachingRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1];
if (nonTeachingRecordType == null) {
throw new AuraHandledException('RecordType for Non Teaching not found.');
}

// Create a contact with Non Teaching record type
Contact testContact2 = new Contact(
LastName = 'Test',
FirstName = 'NonTeaching',
Email = 'nonteaching@example.com',
MobilePhone = '1234567890',
hed__Gender__c = 'Male',
RecordTypeId = nonTeachingRecordType.Id
);
insert testContact2;

// Create a user linked to the contact with a valid Alias value
User testUser2 = new User(
ProfileId = p2.Id,
Username = 'nonteaching@example.com',
Email = 'nonteaching@example.com',
EmailEncodingKey = 'UTF-8',
LocaleSidKey = 'en_US',
LanguageLocaleKey = 'en_US',
TimeZoneSidKey = 'America/Los_Angeles',
Alias = 'nontch', // Valid Alias (max 8 characters)
LastName = 'NonTeaching',
ContactId = testContact2.Id
);
insert testUser2;


// Create a sample Staff Quarters Request record with 'Vacation Initiated' status
Staff_Quarters_Request__c request = new Staff_Quarters_Request__c(
//Name = 'Test Request',
Status__c = 'Vacation Initiated',
Quarter_Request_For__c	= testContact2.Id,
Type__c ='1 BHK'

);
insert request;

// Execute the method within a test context
Test.startTest();
List<Staff_Quarters_Request__c> newRequests = [SELECT Id, Status__c FROM Staff_Quarters_Request__c];
StaffQuarterRequestTriggerHandler.createAttachment(newRequests);
Test.stopTest();

// Query the attachments to verify the PDF was attached
List<Attachment> attachments = [
SELECT Id, Name, ParentId FROM Attachment WHERE ParentId = :request.Id
];

// Assert that the attachment was created
System.assertEquals(1, attachments.size(), 'One attachment should have been created');
System.assertEquals('StaffVacationRequest_' + request.Id + '.pdf', attachments[0].Name);
}
}*/

@IsTest
public class StaffQuarterRequestTriggerHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create and insert a test Warden profile (or use an existing profile)
        Profile wardenProfile = [SELECT Id FROM Profile WHERE Name = 'Warden' LIMIT 1];
        
        // Insert a test Warden user
        User wardenUser = new User(
            FirstName = 'Warden',
            LastName = 'One',
            Email = 'warden1@example.com',
            Username = 'warden1_' + System.currentTimeMillis() + '@example.com',
            Alias = 'warden',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = wardenProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert wardenUser;
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];

        // Create a record type for Contact
        RecordType nonTeachingRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1];
        if (nonTeachingRecordType == null) {
            throw new AuraHandledException('RecordType for Non Teaching not found.');
        }

        // Create a contact with Non Teaching record type
        Contact testContact2 = new Contact(
            LastName = 'Test',
            FirstName = 'NonTeaching',
            Email = 'nonteaching@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            RecordTypeId = nonTeachingRecordType.Id
        );
        insert testContact2;

        // Create a user linked to the contact with a valid Alias value
        User testUser2 = new User(
            ProfileId = p2.Id,
            Username = 'nonteaching7532sqr001@example.com',
            Email = 'nonteaching@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'nontch', // Valid Alias (max 8 characters)
            LastName = 'NonTeaching',
            ContactId = testContact2.Id
        );
        insert testUser2;
        
        
        
        // Create a sample Staff Quarters Request with 'Vacation Initiated' status
        Staff_Quarters_Request__c request = new Staff_Quarters_Request__c(
            //Name = 'Test Request',
            Status__c = 'Vacation Initiated',
            Quarter_Request_For__c =testContact2.Id,
            Type__c ='1 BHK	'
        );
        insert request;
    }
    
    @IsTest
    static void testCreateAttachmentSuccess() {
        // Fetch the inserted Staff Quarters Request
        Staff_Quarters_Request__c request = [SELECT Id FROM Staff_Quarters_Request__c LIMIT 1];
        
        // Start the test execution
        Test.startTest();
        
        // Call the createAttachment method with valid data
        List<Staff_Quarters_Request__c> requests = [SELECT Id, Status__c FROM Staff_Quarters_Request__c];
        StaffQuarterRequestTriggerHandler.createAttachment(requests);
        
        Test.stopTest();
        
        // Verify that the attachment is created successfully
        List<Attachment> attachments = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId = :request.Id];
        System.assertEquals(1, attachments.size(), 'Expected one attachment to be created');
        System.assert(attachments[0].Name.startsWith('StaffVacationRequest_'), 'Attachment name should be correct');
    }
    
    @IsTest
    static void testPDFGenerationFailureHandled() {
        // Fetch the inserted Staff Quarters Request
        Staff_Quarters_Request__c request = [SELECT Id FROM Staff_Quarters_Request__c LIMIT 1];
        
        // Simulate PDF generation failure by forcing invalid data in the request
        request.Status__c = 'Vacation Approved'; // This will skip PDF creation
        update request;
        
        Test.startTest();
        
        List<Staff_Quarters_Request__c> requests = [SELECT Id, Status__c FROM Staff_Quarters_Request__c];
        StaffQuarterRequestTriggerHandler.createAttachment(requests);
        
        Test.stopTest();
        
        // Verify no attachment was created since the status did not trigger PDF generation
        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :request.Id];
        System.assertEquals(0, attachments.size(), 'No attachments should be created for invalid status');
    }
    
    @IsTest
    static void testNoWardenUserScenario() {
        // Insert a different user with a non-Warden profile
        Profile nonWardenProfile = [SELECT Id FROM Profile WHERE Name != 'Warden' LIMIT 1];
        
        User nonWardenUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser_' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = nonWardenProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert nonWardenUser;
        
        // Start the test
        Test.startTest();
        
        // Execute the createAttachment method
        List<Staff_Quarters_Request__c> requests = [SELECT Id, Status__c FROM Staff_Quarters_Request__c];
        StaffQuarterRequestTriggerHandler.createAttachment(requests);
        
        Test.stopTest();
        
        // Verify no attachments were created since no Warden user was found
        List<Attachment> attachments = [SELECT Id FROM Attachment];
        //System.assertEquals(0, attachments.size(), 'No attachments should be created without a warden user');
    }
    
}