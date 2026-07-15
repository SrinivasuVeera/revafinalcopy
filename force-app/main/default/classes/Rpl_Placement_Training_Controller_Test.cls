@isTest
public class Rpl_Placement_Training_Controller_Test {

    @isTest
    static void testGetAttendanceData() {
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;

        Rpl_Training_Module__c testModule = new Rpl_Training_Module__c(
            Rpl_Main_Topic__c = 'Test Main Topic',
            Rpl_Sub_Topic__c = 'Test Sub Topic',
            Rpl_Target__c = 'Test Target',
            Rpl_No_of_Hours__c = 10
        );
        insert testModule;

        Rpl_Training_Attendances__c testAttendance = new Rpl_Training_Attendances__c(
            Rpl_Student__c = testContact.Id,
            Rpl_Training_Module__c = testModule.Id,
            Rpl_Date__c = Date.today(),
            Rpl_Attendance__c = 'Present'
        );
        insert testAttendance;

        Test.startTest();
        List<Rpl_Training_Attendances__c> result = Rpl_Placement_Training_Controller.getAttendanceData(testContact.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'One attendance record should be returned');
    }

    @isTest
    static void testGetAssessmentResultData() {
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;


        Test.startTest();
        List<Rpl_Training_Assement_Result__c> result = Rpl_Placement_Training_Controller.getAssessmentResultData(testContact.Id);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'No assessment result record should be returned');
    }

    @isTest
    static void testGetTrainingMaterialData() {
        Account testSchool = new Account(Name = 'Test School');
        insert testSchool;


        Test.startTest();
        List<Rpl_Training_Module__c> result = Rpl_Placement_Training_Controller.getTrainingMaterialData(1, 'Test School');
        Test.stopTest();

        System.assertEquals(0, result.size(), 'No training module record should be returned');
    }

    @isTest
    static void testExceptionScenario() {
        Test.startTest();
        try {
            List<Rpl_Training_Attendances__c> result = Rpl_Placement_Training_Controller.getAttendanceData('invalidContactId');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
}