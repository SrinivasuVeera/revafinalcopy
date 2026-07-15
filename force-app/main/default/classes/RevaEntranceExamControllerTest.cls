@isTest
public class RevaEntranceExamControllerTest {

    @isTest
    static void testRevaEntranceExamController(){

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(
            LastName = 'Test Contact',
            AccountId = acc.Id,
            Primary_Application_Submitted__c = true
        );
        insert con;

        Test.startTest();

        Contact result = RevaEntranceExamController.getContactDetails();

        System.assertNotEquals(null, result);

        RevaEntranceExamController.updateExamDetails(
            'Yes'
            //'Offline',
            //'2026-04-04'
        );

        Test.stopTest();

        Contact updatedContact = [
            SELECT Applying_For_REVA_CET__c
                  // Exam_Type__c,
                   //Exam_Date1__c
            FROM Contact
            WHERE Id = :con.Id
        ];

        System.assertEquals('Yes', updatedContact.Applying_For_REVA_CET__c);
        //System.assertEquals('Offline', updatedContact.Exam_Type__c);
    }
}