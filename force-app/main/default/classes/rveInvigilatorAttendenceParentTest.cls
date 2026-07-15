@isTest
public class rveInvigilatorAttendenceParentTest {

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
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'prof1@test.com'
        );
        insert prof1;

        // Create rve_Invigilator_Assignment__c records
        List<rve_Invigilator_Assignment__c> assignments = new List<rve_Invigilator_Assignment__c>();
        
            assignments.add(new rve_Invigilator_Assignment__c(
                Name = 'Room1',
                rve_Professor__c = prof1.Id,
                rve_Date__c = Date.today(),
                rve_Shift__c = 'Morning',
                rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0), // 9:00 AM
                rve_Exam_End_Time__c = Time.newInstance(12, 0, 0, 0), // 12:00 PM
                rve_Attendance_Submitted__c = false
               // rve_Room_Allotment__r.Active__c    = true
            ));
        
        insert assignments;
    }

    @isTest
    static void testGetRoomNumbers() {
        // Set the user context
        User prof1 = [SELECT Id FROM User WHERE Username = 'prof1@test.com' LIMIT 1];
        System.debug('prof1=> '+prof1);
        list<rve_Invigilator_Assignment__c>Invigilator = [Select Id,name,rve_Professor__c,rve_Date__c from rve_Invigilator_Assignment__c where rve_Professor__r.Id = :prof1.Id];
        System.debug('Invigilator=> '+Invigilator);
        System.runAs(prof1) {
            // Execute the method to be tested
            Test.startTest();
            List<rve_Invigilator_Assignment__c> results = rveInvigilatorAttendenceParent.getRoomNumbers();
            Test.stopTest();
            
            // Verify the results
            System.assertNotEquals(null, results);
           // System.assertEquals(5, results.size());
            for (rve_Invigilator_Assignment__c assignment : results) {
                System.assertEquals(prof1.Id, assignment.rve_Professor__r.Id);
                //System.assertEquals(Date.today(), assignment.rve_Date__c);
            }
        }
    }

    @isTest
    static void testFetchInvigilatorDetails() {
        // Set the user context
        User prof1 = [SELECT Id FROM User WHERE Username = 'prof1@test.com' LIMIT 1];
        System.runAs(prof1) {
            // Execute the method to be tested
            Test.startTest();
            List<rve_Invigilator_Assignment__c> results = rveInvigilatorAttendenceParent.fetchInvigilatorDetails();
            Test.stopTest();
            
            // Verify the results
            System.assertNotEquals(null, results);
            //System.assertEquals(5, results.size());
            for (rve_Invigilator_Assignment__c assignment : results) {
              //  System.assertEquals(prof1.Id, assignment.rve_Professor__c);
                System.assertEquals(Date.today(), assignment.rve_Date__c);
                //System.assertTrue(assignment.rve_Room_Allotment__r.Active__c);
            }
        }
    }
}