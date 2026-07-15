@isTest
public class HostelAcademicYearTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        REVA_Hostel_Academic_Year__c inactiveYear = new REVA_Hostel_Academic_Year__c(
            Name = '2023-24',
            Is_Active_Academic__c = false
        );
        insert inactiveYear;

        REVA_Hostel_Academic_Year__c activeYear = new REVA_Hostel_Academic_Year__c(
            Name = '2022-23',
            Is_Active_Academic__c = false
        );
        insert activeYear;
       

        Hostel_Fee_Structure__c feeStructure = new Hostel_Fee_Structure__c(
            Name = 'Fee Structure 1',
            Occupancy__c = '1' ,
            Hostel_Room_Fees__c = 207000,
            Gender__c = 'Boys',
            REVA_Hostel_Academic_Year__c = inactiveYear.Id
        );
        insert feeStructure;
        
                REVA_Hostel_Academic_Year__c activeYear3 = new REVA_Hostel_Academic_Year__c(
            Name = '2027-29',
            Is_Active_Academic__c = false
        );
        insert activeYear3;
        
         Hostel_Fee_Structure__c feeStructure1 = new Hostel_Fee_Structure__c(
            Name = 'Fee Structure 1',
            Occupancy__c = '1' ,
            Hostel_Room_Fees__c = 207000,
            Gender__c = 'Boys',
            REVA_Hostel_Academic_Year__c = activeYear3.Id
        );
        insert feeStructure1;
        
        activeYear3.Is_Active_Academic__c = true;
        update activeYear3;
    }

    @isTest
    static void testActivateAcademicYear_Failure_DueToExistingActive() {
        Test.startTest();
                                                   
        REVA_Hostel_Academic_Year__c acadYear = [SELECT Id, Is_Active_Academic__c FROM REVA_Hostel_Academic_Year__c WHERE Name = '2023-24' LIMIT 1];
        acadYear.Is_Active_Academic__c = true;

        try {
            update acadYear;
            System.assert(false, 'Expected an error due to another active academic year.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Another academic year is already active'));
        }
        Test.stopTest();
    }

    @isTest
    static void testActivateAcademicYear_Failure_DueToNoChildRecords() {
        Test.startTest();
        REVA_Hostel_Academic_Year__c acadYear1 = [SELECT Id, Is_Active_Academic__c FROM REVA_Hostel_Academic_Year__c WHERE Name = '2027-29' LIMIT 1];
        
         acadYear1.Is_Active_Academic__c = false;
        update acadYear1;
        
         REVA_Hostel_Academic_Year__c acadYear = [SELECT Id, Is_Active_Academic__c FROM REVA_Hostel_Academic_Year__c WHERE Name = '2022-23' LIMIT 1];
         acadYear.Is_Active_Academic__c = true;
       

        try {
            update acadYear;
            System.assert(false, 'no associated Hostel Fee Structures.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot activate this academic year as there are no associated Hostel Fee Structures'));
        }
        Test.stopTest();
    }

    @isTest
    static void testDeleteActiveAcademicYear_Failure() {
        Test.startTest();
        REVA_Hostel_Academic_Year__c activeYear = [SELECT Id FROM REVA_Hostel_Academic_Year__c WHERE Is_Active_Academic__c = true LIMIT 1];

        try {
            delete activeYear;
            System.assert(false, 'Expected an error due to attempting to delete an active academic year.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Deletion not allowed for an active academic year.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testDeactivateAndDeleteAcademicYear_Success() {
        Test.startTest();
        REVA_Hostel_Academic_Year__c activeYear = [SELECT Id, Is_Active_Academic__c FROM REVA_Hostel_Academic_Year__c WHERE Is_Active_Academic__c = true LIMIT 1];

        activeYear.Is_Active_Academic__c = false;
        update activeYear;

        delete activeYear;

        List<REVA_Hostel_Academic_Year__c> deletedRecord = [SELECT Id FROM REVA_Hostel_Academic_Year__c WHERE Id = :activeYear.Id];
        System.assertEquals(0, deletedRecord.size(), 'The academic year should be deleted successfully.');

        Test.stopTest();
    }
}