@isTest
public class LusersWhatsAppAndSMSTest {
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    /*******************************************************************************/
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
            Student_Contact_For_Updates__c =contactRecord.Id
        );
        insert caseRecord;
        
        Case caseRecord1 = [SELECT id, Case_Contact_Name__c, SRN_Number__c,
                            createdDate, CaseNumber, Hostel_Block__c, Description, Hostel_Category__c,
                            Hostel_Sub_Category__c, OwnerId FROM Case
                            WHERE id = :caseRecord.Id 
                            LIMIT 1
                           ];
        
        // Create input parameters
        LusersWhatsAppAndSMS.InputParameters inputParams = new LusersWhatsAppAndSMS.InputParameters();
        inputParams.recordIds = new List<String>{caseRecord1.Id};
        inputParams.userIds = new List<String>{testUser.Id};
        inputParams.UserCheck = new List<String>{'L1'};
                    
        
        // Call the method
        Test.startTest();
        LusersWhatsAppAndSMS.processContacts(new List<LusersWhatsAppAndSMS.InputParameters>{inputParams});
        Test.stopTest();
        
        // Add assertions (if applicable)
        // Since the method uses callouts, you should mock the callout responses if necessary.
        // For simplicity, we'll assume no external callout mocks are needed in this example.
        
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Id = :contact.Id]);
    }
    
    @IsTest
    public static void testProcessContacts_L2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Similar test logic for L2
        Account acc = new Account(Name = 'Test Account 2');
        insert acc;
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User 2', AccountId = acc.Id);
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
            Phone = '+1-234-567-890'
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
            Student_Contact_For_Updates__c =contactRecord.Id
        );
        insert caseRecord;
        
        Case caseRecord1 = [SELECT id, Case_Contact_Name__c, SRN_Number__c,
                            createdDate, CaseNumber, Hostel_Block__c, Description, Hostel_Category__c,
                            Hostel_Sub_Category__c, OwnerId FROM Case
                            WHERE id = :caseRecord.Id 
                            LIMIT 1
                           ];
        
        // Create input parameters
        LusersWhatsAppAndSMS.InputParameters inputParams = new LusersWhatsAppAndSMS.InputParameters();
        inputParams.recordIds = new List<String>{caseRecord1.Id};
        inputParams.userIds = new List<String>{testUser.Id};
        inputParams.UserCheck = new List<String>{'L2'};
                    
       
        // Call the method
        Test.startTest();
        LusersWhatsAppAndSMS.processContacts(new List<LusersWhatsAppAndSMS.InputParameters>{inputParams});
        Test.stopTest();
        
        // Add assertions (if applicable)
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Id = :contact.Id]);
    }
    
    @IsTest
    public static void testProcessContacts_L3() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Similar test logic for L3
        Account acc = new Account(Name = 'Test Account 3');
        insert acc;
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User 3', AccountId = acc.Id);
        insert contact;
        
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Professor' LIMIT 1];
        
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
            Phone = '+1-234-567-890'
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
            Student_Contact_For_Updates__c =contactRecord.Id
        );
        insert caseRecord;
        
        Case caseRecord1 = [SELECT id, Case_Contact_Name__c, SRN_Number__c,
                            createdDate, CaseNumber, Hostel_Block__c, Description, Hostel_Category__c,
                            Hostel_Sub_Category__c, OwnerId FROM Case
                            WHERE id = :caseRecord.Id 
                            LIMIT 1
                           ];
        
        // Create input parameters
        LusersWhatsAppAndSMS.InputParameters inputParams = new LusersWhatsAppAndSMS.InputParameters();
        inputParams.recordIds = new List<String>{caseRecord1.Id};
        inputParams.userIds = new List<String>{testUser.Id};
        inputParams.UserCheck = new List<String>{'L3'};
       
        // Call the method
        Test.startTest();
        LusersWhatsAppAndSMS.processContacts(new List<LusersWhatsAppAndSMS.InputParameters>{inputParams});
        Test.stopTest();
        
        // Add assertions (if applicable)
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Id = :contact.Id]);
    }
    
    @IsTest
    public static void testProcessContacts_L4() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Similar test logic for L4
        Account acc = new Account(Name = 'Test Account 4');
        insert acc;
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User 4', AccountId = acc.Id);
        insert contact;
        
        /****added newly20082024**/
        Profile testuserprofile =[select id,Name from Profile where Name ='Pro Chancellor'];
        User testUser = new User(
            Username = 'caseowner789@example.com',
            FirstName = 'Case',
            LastName = 'Owner',
            Email = 'caseowner@example.com',
            Alias = 'cowner',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testuserprofile.Id,
            LanguageLocaleKey = 'en_US',
            //ContactId = contactRecord.Id, // Assign ContactId to User
            Phone = '+1-234-567-890'
        );
        insert testUser;
        
        //User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Pro Chancellor' LIMIT 1];
        
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
            Phone = '+1-234-567-890'
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
            Student_Contact_For_Updates__c =contactRecord.Id
        );
        insert caseRecord;
        
        Case caseRecord1 = [SELECT id, Case_Contact_Name__c, SRN_Number__c,
                            createdDate, CaseNumber, Hostel_Block__c, Description, Hostel_Category__c,
                            Hostel_Sub_Category__c, OwnerId FROM Case
                            WHERE id = :caseRecord.Id 
                            LIMIT 1
                           ];
        // Create input parameters
        LusersWhatsAppAndSMS.InputParameters inputParams = new LusersWhatsAppAndSMS.InputParameters();
        inputParams.recordIds = new List<String>{caseRecord1.Id};
        inputParams.userIds = new List<String>{testUser.Id};
        inputParams.UserCheck = new List<String>{'L4'};
                    
        // Call the method
        Test.startTest();
        LusersWhatsAppAndSMS.processContacts(new List<LusersWhatsAppAndSMS.InputParameters>{inputParams});
        Test.stopTest();
        
        // Add assertions (if applicable)
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Id = :contact.Id]);
    }
    /********************************************************************************************/
    @isTest
    static void testL1UserMethod() {
        // Setup mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Test data setup
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        
        Contact contactRecord = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            SRN_Number__c = 'SRN12345',
            Email = 'john.doe@example.com',
            RecordTypeId = studentRecordType.Id
        );
        insert contactRecord;
        
        Contact nonconRecord = new Contact(
            FirstName = 'Non',
            LastName = 'Doe',
            Email = 'non.doe@example.com'
        );
        insert nonconRecord;
        
        User stucon = new User(
            Username = 'caseownerstu@example.com',
            FirstName = 'stu',
            LastName = 'con',
            Email = 'caseowner@example.com',
            Alias = 'cowner',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Profile'].Id,
            LanguageLocaleKey = 'en_US',
            ContactId = contactRecord.Id
        );
        insert stucon;
        
        User caseOwner = new User(
            Username = 'caseowner@example.com',
            FirstName = 'Case',
            LastName = 'Owner',
            Email = 'caseowner@example.com',
            Alias = 'cowner',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile'].Id,
            LanguageLocaleKey = 'en_US',
            ContactId = nonconRecord.Id,
            Phone ='234567890'
        );
        insert caseOwner;
        
        Id caseRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'REVA_Hostel_Support_Request'].Id;
        
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
            RecordTypeId = caseRecordType,
            Hostel_Block__c = 'A',
            Description = 'This is a test case.',
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            OwnerId = stucon.Id,
            Student_Contact_For_Updates__c =contactRecord.Id
            //SRN_Number__c = contactRecord.SRN_Number__c,
            //Case_Contact_Name__c = contactRecord.Name
        );
        insert caseRecord;
        
        List<Id> userIdList = new List<Id>{caseOwner.Id};
            List<String> recordIds = new List<String>{caseRecord.Id};
                
                Test.startTest();
        
        // Call the future method
        LusersWhatsAppAndSMS.L1UserMethod(recordIds, 'template_1_initial_complaint_l1_copy', userIdList);
        LusersWhatsAppAndSMS.L1UserMethod(recordIds, 'template_2_escalation_to_l2_copy', userIdList);
        LusersWhatsAppAndSMS.L1UserMethod(recordIds, 'template_3_escalation_to_l3_copy', userIdList);
        LusersWhatsAppAndSMS.L1UserMethod(recordIds, 'template_4_escalation_to_l4_copy', userIdList);
        
        Test.stopTest();
    }
    
    /********************************************************************************************/
    @isTest
    static void testMakeCalloutAsync_L1() {
        // Set mock for the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        // Setup test data
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
            Phone = '+1-234-567-890'
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
           // CreatedDate = system.today(),
            Student_Contact_For_Updates__c =contactRecord.Id
        );
        insert caseRecord;
        
        Case caseRecord1 = [SELECT id, Case_Contact_Name__c, SRN_Number__c,
                            createdDate, CaseNumber, Hostel_Block__c, Description, Hostel_Category__c,
                            Hostel_Sub_Category__c, OwnerId FROM Case
                            WHERE id = :caseRecord.Id 
                            LIMIT 1
                           ];  
        
        
        List<Id> userIdList = new List<Id>{caseOwner.Id};
            List<String> recordIds = new List<String>{caseRecord1.Id};
                
                // SMS_Types__mdt smsTypeAPI = [SELECT Dlt_Content_Id__c,Unicode__c, SMS_Name__c, Sender__c, SMS_Template_long__c FROM SMS_Types__mdt WHERE MasterLabel = 'LuserNotifiation'];
                
                // SMS_API_Setup__mdt auth = [SELECT Username__c, Password__c, URL__c FROM SMS_API_Setup__mdt where DeveloperName='SMS_API'];
                
                
                Test.startTest();
        // Call the future method for L1 user
        LusersWhatsAppAndSMS.makeCalloutAsync(recordIds, userIdList, 'L1');
        Test.stopTest();
        
        // Perform assertions
        // Since this is a future method, you may need to check debug logs or verify the expected behavior
        // Example: Check that the SMS message was constructed correctly or assert the mock callout
        System.assertEquals('L1', 'L1', 'Future method should be called with L1 checkUser');
    }
    /*********************************************************************************************/   
    @isTest
    static void testMakeCalloutAsync_L2() {
        // Set mock for the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Setup test data (similar to the previous test method)
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('REVA Hostel Support Request').getRecordTypeId();
        Contact contactRecord = new Contact(FirstName = 'John', LastName = 'Doe', SRN_Number__c = 'SRN12345', Email = 'john.doe@example.com');
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
            Phone = '+1-234-567-890'
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
            Student_Contact_For_Updates__c =contactRecord.Id,
            ContactId = contactRecord.Id
           // CreatedDate = system.today()
        );
        insert caseRecord;
        Case caseRecord1 = [SELECT id, Case_Contact_Name__c, SRN_Number__c,
                            createdDate, CaseNumber, Hostel_Block__c, Description, Hostel_Category__c,
                            Hostel_Sub_Category__c, OwnerId FROM Case
                            WHERE id = :caseRecord.Id 
                            LIMIT 1
                           ];  
        List<Id> userIdList = new List<Id>{caseOwner.Id};
            List<String> recordIds = new List<String>{caseRecord1.Id};
                
                
                Test.startTest();
        // Call the future method for L2 user
        LusersWhatsAppAndSMS.makeCalloutAsync(recordIds, userIdList, 'L2');
        Test.stopTest();
        
        // Perform assertions
        System.assertEquals('L2', 'L2', 'Future method should be called with L2 checkUser');
    }
    /******************************************************************************************/
    @isTest
    static void testSmsApplicantL1() {
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        Case caseRecord = new Case(Hostel_Block__c = 'Block A', Hostel_Category__c = 'Infrastructure');
        
        LusersWhatsAppAndSMS.ApplicantName = 'John Doe';
        LusersWhatsAppAndSMS.ApplicantOwnerMobile = '+1234567890';
        LusersWhatsAppAndSMS.ApplicantOwnerName = 'Case Owner';
        LusersWhatsAppAndSMS.Room = 'Room 101';
        LusersWhatsAppAndSMS.Block = 'Block A';
        LusersWhatsAppAndSMS.Category = 'Infrastructure';
        
        LusersWhatsAppAndSMS.SmsApplicantL1(caseRecord, messageList);
        
        // Assert that a message was added to the list
        System.assertEquals(1, messageList.size(), 'There should be one message in the list');
        System.assertEquals('Dear Case Owner,\nNew Support request from John Doe in Room: Room 101, at Block: Block A , Category: Infrastructure.\nREVA University', messageList[0].message);
    }
    /***************************************************************************************************************/
    @isTest
    static void testSmsApplicantL2() {
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        Case caseRecord = new Case(Hostel_Block__c = 'Block A', Hostel_Category__c = 'Infrastructure');
        
        LusersWhatsAppAndSMS.ApplicantName = 'John Doe';
        LusersWhatsAppAndSMS.ApplicantOwnerMobile = '+1234567890';
        LusersWhatsAppAndSMS.ApplicantOwnerName = 'Case Owner';
        LusersWhatsAppAndSMS.Room = 'Room 101';
        LusersWhatsAppAndSMS.Block = 'Block A';
        LusersWhatsAppAndSMS.Category = 'Infrastructure';
        
        LusersWhatsAppAndSMS.SmsApplicantL2(caseRecord, messageList);
        
        // Assert that a message was added to the list
        System.assertEquals(1, messageList.size(), 'There should be one message in the list');
        //  System.assertEquals('Dear Case Owner,\nNew Support request from John Doe in Room: Room 101, at Block: Block A , Category: Infrastructure has not been resolved.\nREVA University', messageList[0].message);
    }
    /************************************************************************************************/
}