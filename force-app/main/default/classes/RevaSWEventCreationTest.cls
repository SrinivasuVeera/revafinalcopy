@isTest
public class RevaSWEventCreationTest {

      @isTest(seeAllData=true)
    static void testTrigger() {
        //getting counsellor details
     Counsellor_Details__mdt counsellorId = [SELECT Id__c from Counsellor_Details__mdt][0];

        Profile testSystemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
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
            LanguageLocaleKey = 'en_US'
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
        
        System.runAs(testSystemAdmin) {
            // Create a test Case record
            Case testCase = new Case(
                Subject = 'Test Case',
                ContactId = testContact.id,
                Description__c = 'Test Description'
                // Set other required fields
            );
            insert testCase;
            
            
        // Create a ManodhaaraAppointment__c record
        ManodhaaraAppointment__c testAppointment = new ManodhaaraAppointment__c(
            Case__c = testCase.id,
               // LastName = 'Test Last',
                Email__c = 'testuser@example.com',
            Start_Date_Time__c = datetime.newInstance(2024, 1, 25, 3, 30, 0),
            End_Date_Time__c = datetime.newInstance(2024, 1, 25, 4, 30, 0),
            Appointment_Date__c = system.today()
        );
        insert testAppointment;

        // Update the ManodhaaraAppointment__c record to simulate trigger execution
        testAppointment.Appointment_Status__c = 'Scheduled';
        update testAppointment;

        // Verify that an Event record was created
        List<Event> events = [SELECT Id FROM Event WHERE WhatId = :testAppointment.Id];
        System.assertEquals(1, events.size(), 'Expected one Event record to be created');
    }
}
}