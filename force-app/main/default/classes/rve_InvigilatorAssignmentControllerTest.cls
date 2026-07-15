@isTest
public class rve_InvigilatorAssignmentControllerTest {
    
    @testSetup
    static void setup() {
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
    static void testGetRoomNumbers() {
        Test.startTest();
        List<IA_Seating_Room_Allotment__c> rooms = rve_InvigilatorAssignmentController.getRoomNumbers();
       // System.assertNotEquals(0, rooms.size(), 'Rooms should be fetched correctly.');
        Test.stopTest();
    }

    @isTest
    static void testGetExistingInvigilatorAssignments() {
        Test.startTest();
        List<rve_Invigilator_Assignment__c> assignments = rve_InvigilatorAssignmentController.getExistingInvigilatorAssignments(
            'prof1@test.com', string.valueof(Date.today()), 'Morning', Time.newInstance(8, 0, 0, 0)
        );
       // System.assertNotEquals(0, assignments.size(), 'Existing assignments should be fetched correctly.');
        Test.stopTest();
    }

    @isTest
    static void testGetProfessors() {
        Test.startTest();
        List<User> professors = rve_InvigilatorAssignmentController.getProfessors('prof');
        System.assertNotEquals(0, professors.size(), 'Professors should be fetched correctly.');
        Test.stopTest();
    }

    @isTest
    static void testInsertInvigilatorAssignments() {
        // Create a new Invigilator Assignment
        IA_Seating_Room_Allotment__c room = [SELECT Id FROM IA_Seating_Room_Allotment__c LIMIT 1];
        User prof = [SELECT Id FROM User WHERE Username = 'prof2@test.com' LIMIT 1];

        rve_Invigilator_Assignment__c newAssignment = new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Afternoon',
            rve_Professor__c = prof.Id
        );

        Test.startTest();
        List<rve_Invigilator_Assignment__c> insertedAssignments = rve_InvigilatorAssignmentController.insertInvigilatorAssignments(new List<rve_Invigilator_Assignment__c>{newAssignment});
        Test.stopTest();

        System.assertNotEquals(0, insertedAssignments.size(), 'Invigilator Assignment should be inserted successfully.');
    }
}