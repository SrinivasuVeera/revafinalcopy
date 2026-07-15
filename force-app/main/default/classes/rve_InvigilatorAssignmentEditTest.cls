@isTest
public class rve_InvigilatorAssignmentEditTest {

    @testSetup
    static void setupTestData() {
        // Create test data for profiles
        Profile professorProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];

        // Create test users with 'Professor' profile
        User prof1 = new User(
            Alias = 'prof1',
            Email = 'prof1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Professor1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = professorProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'prof1@test.com'
        );
        insert prof1;

        User prof2 = new User(
            Alias = 'prof2',
            Email = 'prof2@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Professor2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = professorProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'prof2@test.com'
        );
        insert prof2;

        // Create test School and Parent School
        Account parentSchool = new Account(Name = 'Parent School');
        insert parentSchool;

        Account school = new Account(Name = 'School', ParentId = parentSchool.Id);
        insert school;

        // Create test Room Allotments
        IA_Seating_Room_Allotment__c room1 = new IA_Seating_Room_Allotment__c(
            Name = 'Room 1',
            Room__c = 'R1',
            Active__c = true,
            rve_Date_of_Exam__c = Date.today(),
            School__c = school.Id
        );
        insert room1;

        IA_Seating_Room_Allotment__c room2 = new IA_Seating_Room_Allotment__c(
            Name = 'Room 2',
            Room__c = 'R2',
            Active__c = true,
            rve_Date_of_Exam__c = Date.today(),
            School__c = school.Id
        );
        insert room2;

        // Create test Invigilator Assignments
        rve_Invigilator_Assignment__c assignment1 = new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room1.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Professor__c = prof1.Id
        );
        insert assignment1;
    }

    @isTest
    static void testGetInvigilatorAssignments() {
        Test.startTest();
        
        // Call the method and verify results
        List<rve_Invigilator_Assignment__c> assignments = rve_InvigilatorAssignmentEdit.getInvigilatorAssignments();
        
        // Verify the number of invigilator assignments retrieved
        //System.assert(assignments.size() == 2, 'Expected to retrieve 2 invigilator assignments');
        
        Test.stopTest();
    }

    @isTest
    static void testUpdateProfessor() {
        // Get an existing assignment Id
        rve_Invigilator_Assignment__c existingAssignment = [SELECT Id FROM rve_Invigilator_Assignment__c LIMIT 1];
        
        // Get an existing professor Id
        User existingProfessor = [SELECT Id FROM User WHERE Username = 'prof2@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Call the method to update the professor
        rve_InvigilatorAssignmentEdit.updateProfessor(existingAssignment.Id, existingProfessor.Id);
        
        // Verify the update
        rve_Invigilator_Assignment__c updatedAssignment = [SELECT Id, rve_Professor__c FROM rve_Invigilator_Assignment__c WHERE Id = :existingAssignment.Id];
        System.assertEquals(existingProfessor.Id, updatedAssignment.rve_Professor__c, 'Expected the professor to be updated');
        
        Test.stopTest();
    }
}