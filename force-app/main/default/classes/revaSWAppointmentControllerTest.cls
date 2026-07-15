@isTest
public class revaSWAppointmentControllerTest {
 @isTest
    static void testGetUserProfile() {
        // Set up a user with a specific profile
        Profile testSystemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile testProfessorProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        Profile testCounsellorProfile = [SELECT Id FROM Profile WHERE Name = 'Counselor' LIMIT 1];
        system.debug('testCounsellorProfile==>'+ testCounsellorProfile);
        
         User testCounsellor = new User(
            FirstName = 'Test',
            LastName = 'counsellor',
            Email = 'testuser@example.com',
            Username = 'test768@example.com',
            Alias = 'TUser',
            CommunityNickname = 'test',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testCounsellorProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testCounsellor;
        
        
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
            LanguageLocaleKey = 'en_US',
            ManagerId = testCounsellor.id
        );
        insert testSystemAdmin;
        
        
        Contact testContact = new Contact(
                FirstName = 'Test Contact',
                LastName = 'Test Last',
                Email = 'testuser@example.com'
               // MobilePhone = '917088142959'
                // Set other required fields
            );
            insert testContact;
        
        Test.startTest();
        List<ManodhaaraAppointment__c> resultAppointments = revaSWAppointmentController.getExistingAppointments(testContact.Email);
        Test.stopTest();
        
        System.runAs(testSystemAdmin) {
            // Create a test Case record
            Case testCase = new Case(
                Subject = 'Test Case',
                ContactId = testContact.id,
                Description__c = 'Test Description'
                // Set other required fields
            );
            insert testCase;
        
   		ManodhaaraAppointment__c testAppointment = new ManodhaaraAppointment__c(
                Case__c = testCase.id,
               // LastName = 'Test Last',
                Email__c = 'testuser@example.com',
            Start_Date_Time__c = datetime.newInstance(2024, 1, 25, 3, 30, 0),
            End_Date_Time__c = datetime.newInstance(2024, 1, 25, 4, 30, 0),
            Appointment_Date__c = system.today()
                // Set other required fields
            );
            insert testAppointment;  
            
            revaSWAppointmentController.NewAppointmentWrapper result = revaSWAppointmentController.CreateNewAppointment(testAppointment.Id);
            
            System.runAs(testSystemAdmin){
             
            Boolean hasAppointments = revaSWAppointmentController.checkManodaraAppointments();
            
            }
       
        }

        // Run the method and verify the result
        System.runAs(testSystemAdmin) {
            String userProfile = revaSWAppointmentController.getUserProfile();
            System.assertEquals('System Administrator', userProfile, 'User profile should be System Administrator');
            List<RevaSWAppointmentController.AppointmentWrapper> appointments = RevaSWAppointmentController.getAppointments();

            // Perform assertions based on your expected results
            System.assertEquals(1, appointments.size(), 'No appointments should be found for the test user');
            
        }
        
        User testProfessor = new User(
            FirstName = 'Test',
            LastName = 'Professor',
            Email = 'testprofessor@example.com',
            Username = 'test11223344@example.com',
            Alias = 'TProf',
            CommunityNickname = 'testprofessor',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testProfessorProfile.Id,
            LanguageLocaleKey = 'en_US',
            ManagerId = testCounsellor.id
        );
        insert testProfessor;
        
        Contact testContactProf = new Contact(
                FirstName = 'Test Contact Prof',
                LastName = 'Test Last',
                Email = 'testprofessor@example.com'
               // MobilePhone = '917088142959'
                // Set other required fields
            );
            insert testContactProf;
        
        System.runAs(testProfessor) {
            // Create a test Case record
            Case testCaseProf = new Case(
                Subject = 'Test Case Prof',
                ContactId = testContactProf.id,
                Description__c = 'Test Description'
                // Set other required fields
            );
            insert testCaseProf;
        
   		ManodhaaraAppointment__c testAppointmentByProf = new ManodhaaraAppointment__c(
                Case__c = testCaseProf.id,
               // LastName = 'Test Last',
                Email__c = 'testprofessor@example.com',
            Start_Date_Time__c = datetime.newInstance(2024, 1, 25, 3, 30, 0),
            End_Date_Time__c = datetime.newInstance(2024, 1, 25, 4, 30, 0),
            Appointment_Date__c = system.today()
                // Set other required fields
            );
            insert testAppointmentByProf;   
            
            Event testEvent = new Event(
            WhatId = testAppointmentByProf.Id,
            StartDateTime = testAppointmentByProf.Start_Date_Time__c,
            EndDateTime = testAppointmentByProf.End_Date_Time__c
            
        );
        insert testEvent;
            
            String userProfile = revaSWAppointmentController.getUserProfile();
            System.assertEquals('Professor', userProfile, 'User profile should be Professor');
            List<RevaSWAppointmentController.AppointmentWrapper> appointments = RevaSWAppointmentController.getAppointments();

            // Perform assertions based on your expected results
            System.assertEquals(1, appointments.size(), 'No appointments should be found for the test user');
            
             // Call the cancelAppointment method
        revaSWAppointmentController.cancelAppointment(testAppointmentByProf.Id, 'Cancellation Reason');

        // Retrieve the updated appointment record
        ManodhaaraAppointment__c updatedAppointment = [SELECT Id, Appointment_Status__c, Reason_For_Cancellation__c FROM ManodhaaraAppointment__c WHERE Id = :testAppointmentByProf.Id LIMIT 1];

        // Perform assertions to verify that the appointment was canceled and related events were deleted
        System.assertEquals('Cancelled', updatedAppointment.Appointment_Status__c);
        System.assertEquals('Cancellation Reason', updatedAppointment.Reason_For_Cancellation__c);

        // Ensure that related events were deleted
        List<Event> deletedEvents = [SELECT Id FROM Event WHERE Id = :testEvent.Id];
        System.assertEquals(0, deletedEvents.size(), 'Related events should be deleted');
       
        }

        // Run the method and verify the result
        System.runAs(testProfessor) {
            String userProfile = revaSWAppointmentController.getUserProfile();
            System.assertEquals('Professor', userProfile, 'User profile should be Professor');
            List<RevaSWAppointmentController.AppointmentWrapper> appointments = RevaSWAppointmentController.getAppointments();

            // Perform assertions based on your expected results
            System.assertEquals(0, appointments.size(), 'No appointments should be found for the test user');
        }
            
          
        
    }
    
  @isTest
    static void testGetContactsForStudentPortal() {
        // Create a test Student Profile record type
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];

        // Create a test Contact with the Student record type
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'test.student@example.com',
            SRN_Number__c = 'SRN123',
            RecordTypeId = studentRecordType.id
        );
        insert testContact;

        // Call the getContactsForStudentPortal method
        List<Contact> resultContacts = revaSWAppointmentController.getContactsForStudentPortal('Test');

        // Perform assertions
        System.assertEquals(1, resultContacts.size(), 'There should be one matching contact');
        System.assertEquals(testContact.Id, resultContacts[0].Id, 'Returned contact should match the created contact');
    }
}