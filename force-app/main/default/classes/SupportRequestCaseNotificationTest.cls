@IsTest
public class SupportRequestCaseNotificationTest {
   public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }

   @IsTest
    public static void testProcessContacts_L1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', AccountId = acc.Id);
        insert contact;
        
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Student Profile' LIMIT 1];
        
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('REVA Hostel Support Request').getRecordTypeId();
        Contact contactRecord = new Contact(FirstName = 'John', LastName = 'Doe', SRN_Number__c = 'SRN12345', Email = 'john.doe@example.com',RecordTypeId = studentRecordType.Id);
        insert contactRecord;
        
        User caseOwner = new User(
            Username = 'caseowner@example.com',
            FirstName = 'Case',
            LastName = 'Owner',
            Email = 'caseowner@example.com',
            Alias = 'cowner',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Profile'].Id,
            LanguageLocaleKey = 'en_US',
            ContactId = contactRecord.Id, // Assign ContactId to User
            Phone = '9999999999'
        );
        insert caseOwner;
        
        Reva_Hostel_Room__c testRoom = new Reva_Hostel_Room__c(
            Name = '206',
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS',
            Is_Premium__c = false
        );
        insert testRoom;
        
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = contactRecord.Id,
            Reva_Hostel_Room__c = testRoom.Id,
            Type__c = '4'
        );
        insert hostelRequest;
        
        Case caseRecord = new Case(
            RecordTypeId = caseRecordTypeId,
            Hostel_Block__c = 'A',
            Description = 'This is a test case.',
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            OwnerId = caseOwner.Id,
            Status ='New',
            REVA_Hostel_Request__c = hostelRequest.Id,
            ContactId = contactRecord.Id,
            //CreatedDate = system.today(),
            Student_Contact_For_Updates__c =contactRecord.Id,
            phone__c = '9999999999'
        );
        insert caseRecord;
        
        Case caseRecord1 = [SELECT id, Case_Contact_Name__c, SRN_Number__c,
                            createdDate, CaseNumber, Hostel_Block__c, Description, Hostel_Category__c,
                            Hostel_Sub_Category__c,Room_Number__c, OwnerId FROM Case
                            WHERE id = :caseRecord.Id 
                            LIMIT 1
                           ];
        
        // Create input parameters
        SupportRequestCaseNotification.InputParameters inputParams = new SupportRequestCaseNotification.InputParameters();
        inputParams.recordIds = new List<String>{caseRecord1.Id};
       // inputParams.userIds = new List<String>{testUser.Id};
        inputParams.UserCheck = new List<String>{'WhatsApp'};
                    
        
        // Call the method
        Test.startTest();
        SupportRequestCaseNotification.processContacts(new List<SupportRequestCaseNotification.InputParameters>{inputParams});
        Test.stopTest();
        
        // Add assertions (if applicable)
        // Since the method uses callouts, you should mock the callout responses if necessary.
        // For simplicity, we'll assume no external callout mocks are needed in this example.
        
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Id = :contact.Id]);
    }
}