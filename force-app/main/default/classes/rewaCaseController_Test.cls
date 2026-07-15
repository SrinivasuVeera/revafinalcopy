@isTest
public class rewaCaseController_Test {

    @isTest(SeeAllData=true)
    static void testCreateAppointmentCaseEventWithExistingCase() {
         Profile testSystemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
         User testSystemAdmin = new User(
            FirstName = 'Test',
            LastName = 'System Admin',
            Email = 'test@example.com',
            Username = 'test09878@example.com',
            Alias = 'TUser',
            CommunityNickname = 'testsystemadmin',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testSystemAdminProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testSystemAdmin;
        
        // Create a test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Personal_Email__c = 'test@example.com',
             hed__WorkEmail__c = 'test@example.com',
            Email = 'test@example.com'
            // Add other required fields as needed
        );
        insert testContact;

        // Create a test case
        
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Manodhaara' LIMIT 1];
        
        Case testCase = new Case(
            Severity__c = 'Urgent',
            ModeOfCounselling__c = 'Face to Face',
            PreferredLanguage__c = 'English',
            Description__c = 'Test Case',
            RecordTypeId = recordTypes[0].id, // Replace with the actual Record Type Id
            ContactId = testContact.Id,
            Status = 'New'
            // Add other required fields as needed
        );
        insert testCase;

        // Set the current user's email for testing
        System.runAs(new User(Id = UserInfo.getUserId(), Email = testContact.Personal_Email__c)) {
            // Call the createAppointmentCaseEvent method
            Test.startTest();
            RewaCaseController.createAppointmentCaseEvent(
                testCase.Severity__c,
                testCase.ModeOfCounselling__c,
                testCase.PreferredLanguage__c,
                'Lonely',
                'Family',
                testCase.Description__c,
                Date.today(),
                '9:00 AM - 10:00 AM',
                'Self',
                2023,
                4,
                21,
                9,
                0,
                10,
                0,
                testContact.Id,
                1, // Angry
            2, // Stressed
            3, // Sad
            4, // Lonely
            5, // Hurt
            6, // Confused
            7, // Frightened
            8, //Anxious
            'Family issue'
            );
            Test.stopTest();

            // Perform assertions or add more logic based on your use case
            // For example, check if the appointment and related records are created successfully
            
        }  
    }
        
  /* @isTest(SeeAllData=true)
    static void testCreateAppointmentCaseEventWithExistingCaseNoCon() {
         Profile testSystemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
         User testSystemAdmin = new User(
            FirstName = 'Test',
            LastName = 'System Admin',
            Email = 'test@example.com',
            Username = 'test09878@example.com',
            Alias = 'TUser',
            CommunityNickname = 'testsystemadmin',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testSystemAdminProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testSystemAdmin;
        
        // Create a test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Personal_Email__c = 'test@example.com',
             hed__WorkEmail__c = 'test@example.com'
            // Add other required fields as needed
        );
        insert testContact;

        // Create a test case
        
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Manodhaara' LIMIT 1];
        
        Case testCase = new Case(
            Severity__c = 'Urgent',
            ModeOfCounselling__c = 'Face to Face',
            PreferredLanguage__c = 'English',
            Description__c = 'Test Case',
            RecordTypeId = recordTypes[0].id, // Replace with the actual Record Type Id
            ContactId = testContact.Id,
            Status = 'New'
            // Add other required fields as needed
        );
        insert testCase;

        // Set the current user's email for testing
        System.runAs(new User(Id = UserInfo.getUserId(), Email = testContact.Personal_Email__c)) {
            // Call the createAppointmentCaseEvent method
            Test.startTest();
            RewaCaseController.createAppointmentCaseEvent(
                testCase.Severity__c,
                testCase.ModeOfCounselling__c,
                testCase.PreferredLanguage__c,
                'Lonely',
                'Family',
                testCase.Description__c,
                Date.today(),
                '9:00 AM - 10:00 AM',
                'Self',
                2023,
                4,
                21,
                9,
                0,
                10,
                0,
                null,
                1, // Angry
            2, // Stressed
            3, // Sad
            4, // Lonely
            5, // Hurt
            6, // Confused
            7, // Frightened
            8, //Anxious
            'Family issue'
            );
            Test.stopTest();

            // Perform assertions or add more logic based on your use case
            // For example, check if the appointment and related records are created successfully
        }  
          
    }*/
    
     @isTest(SeeAllData=true)
    static void testCreateAppointmentCaseEventWithoutExistingCase() {
         Profile testSystemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
         User testSystemAdmin = new User(
            FirstName = 'Test',
            LastName = 'System Admin',
            Email = 'test@example.com',
            Username = 'test09878@example.com',
            Alias = 'TUser',
            CommunityNickname = 'testsystemadmin',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testSystemAdminProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testSystemAdmin;
        
        // Create a test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Personal_Email__c = 'test@example.com',
            hed__WorkEmail__c = 'test@example.com',
            Email = 'test@example.com'
            // Add other required fields as needed
        );
        insert testContact;

        // Create a test case
        
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Manodhaara' LIMIT 1];
        
        

        // Set the current user's email for testing
        System.runAs(new User(Id = UserInfo.getUserId(), Email = testContact.Personal_Email__c)) {
            // Call the createAppointmentCaseEvent method
            Test.startTest();
            RewaCaseController.createAppointmentCaseEvent(
                'Urgent',
                'Face to Face',
                'English',
                'Lonely',
                'Family',
                'Test Case',
                Date.today(),
                '9:00 AM - 10:00 AM',
                'Self',
                2023,
                4,
                21,
                9,
                0,
                10,
                0,
                testContact.Id,
                1, // Angry
            2, // Stressed
            3, // Sad
            4, // Lonely
            5, // Hurt
            6, // Confused
            7, // Frightened
            8, //Anxious
            'Family issue'
            );
            Test.stopTest();

            // Perform assertions or add more logic based on your use case
            // For example, check if the appointment and related records are created successfully
        
        
        }
    }
    
    
      @isTest
    static void testUpdateCaseEmailFromContactEmail() {
        // Create test data - Insert a Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;

        // Create test data - Insert a Case associated with the Contact
        Case testCase = new Case(
            Subject = 'Test Case',
            ContactId = testContact.Id
            // Add other required fields
        );
        insert testCase;

        // Call the method you want to test
        rewaCaseController.updateCaseEmailFromContactEmail(new List<Case>{testCase});

        // Retrieve the updated Case from the database
        Case updatedCase = [SELECT Id, Contact_Email__c FROM Case WHERE Id = :testCase.Id LIMIT 1];

        // Assert that the Contact_Email__c field is updated correctly
        System.assertEquals(testContact.Email, updatedCase.Contact_Email__c, 'Contact_Email__c should be updated');
        
         Test.startTest();
        // Call the getCasesWithAppointments method
        List<rewaCaseController.CaseWithAppointments> casesWithAppointments = rewaCaseController.getCasesWithAppointments(testContact.Id);
        Test.stopTest();

        // Add more assertions or test cases as needed
    }
    
   @isTest
    static void testGetAllCustomMetadata() {
        Test.startTest();
        // Call the method
        List<RSW_Manodhaara_CMT__mdt> result = revaSWCustomMetadataController.getAllCustomMetadata();
        Test.stopTest();

        // Assertions
        System.assertEquals(1, result.size(), 'Unexpected number of records returned');
        // Add more assertions as needed to verify the returned data
    }
    
           @isTest(seeAllData=True)
    static void testGetEvents() {
        
        Counsellor_Details__mdt counsellorId = [SELECT Id__c from Counsellor_Details__mdt][0];
         Id UserId = counsellorId.Id__c;
        
        // Create mock events
        List<Event> events = new List<Event>();
        for (Integer i = 0; i < 5; i++) {
            Event eventRecord = new Event(
                Subject = 'Test Event ' + i,
                StartDateTime = System.now().addDays(i),
                EndDateTime = System.now().addDays(i).addHours(1),
                IsAllDayEvent = false,
                OwnerId = UserId
            );
            events.add(eventRecord);
        }
        insert events;
        
         Test.startTest();
        // Call the getEvents method
        List<Event> events2 = rewaCaseController.getEvents();
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, events, 'The events list should not be null');
        System.assert(events.size() > 0, 'The events list should contain at least one event');
     }

         /*   @testSetup
    static void setupTestData() {
        // Create mock events
        List<Event> events = new List<Event>();
        for (Integer i = 0; i < 5; i++) {
            Event eventRecord = new Event(
                Subject = 'Test Event ' + i,
                StartDateTime = System.now().addDays(i),
                EndDateTime = System.now().addDays(i).addHours(1),
                IsAllDayEvent = false,
                OwnerId = UserInfo.getUserId()
            );
            events.add(eventRecord);
        }
        insert events;
     }*/

  

    @isTest
    static void testRescheduleAppointment() {
        List<Event> events = new List<Event>();
        for (Integer i = 0; i < 5; i++) {
            Event eventRecord = new Event(
                Subject = 'Test Event ' + i,
                StartDateTime = System.now().addDays(i),
                EndDateTime = System.now().addDays(i).addHours(1),
                IsAllDayEvent = false,
                OwnerId = UserInfo.getUserId()
            );
            events.add(eventRecord);
        }
        insert events;
        
        // Get an existing event ID
        Event existingEvent = [SELECT Id FROM Event LIMIT 1];

        Test.startTest();
        // Call the RescheduleAppointment method
        rewaCaseController.RescheduleAppointment(existingEvent.Id);
        Test.stopTest();

        // Add assertions if necessary, depending on what RescheduleAppointment is supposed to do
        // For now, just a debug check since the method is empty
        System.debug('RescheduleAppointment called successfully with ID: ' + existingEvent.Id);
    }
}