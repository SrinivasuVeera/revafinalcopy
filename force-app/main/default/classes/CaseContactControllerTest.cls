@isTest
public class CaseContactControllerTest {

    @testSetup
    static void setup() {
        // Create a test Contact
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            //Active_Semester__c = 'Spring 2024',
            SRN_Number__c = 'SRN12345',
            email = 'testuser@example.com'
        );
        insert testContact;
        
       

        // Create a test Case linked to the test Contact
        Case testCase = new Case(
            ContactId = testContact.Id,
            //CaseNumber = '00001000',
            Description = 'Test Case Description',
            Reason_for_C__c = 'Graduated from School'
        );
        insert testCase;

        // Create related Manodhaara_Appointment__c records
        List<ManodhaaraAppointment__c> appointments = new List<ManodhaaraAppointment__c>();
        for (Integer i = 0; i < 3; i++) {
            appointments.add(new ManodhaaraAppointment__c(
                Case__c = testCase.Id,Email__c = 'testuser@example.com',
            Start_Date_Time__c = datetime.newInstance(2024, 1, 25, 3, 30, 0),
            End_Date_Time__c = datetime.newInstance(2024, 1, 25, 4, 30, 0),
            Appointment_Date__c = system.today()
                
               // Name = 'Test Appointment ' + i
            ));
        }
        insert appointments;
    }

    @isTest
    static void testCaseContactController() {
        // Retrieve the test Case
        Case testCase = [SELECT Id, ContactId FROM Case LIMIT 1];

        // Instantiate the StandardController with the test Case
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);

        // Instantiate the CaseContactController
        CaseContactController controller = new CaseContactController(stdController);

        // Assert that the Case record is correctly initialized
        System.assertNotEquals(null, controller.caseRecord, 'Case record should be initialized');
        System.assertEquals(testCase.Id, controller.caseRecord.Id, 'Case record ID should match the test case ID');

        // Assert that the Contact record is correctly initialized
        System.assertNotEquals(null, controller.contact, 'Contact record should be initialized');
        System.assertEquals(testCase.ContactId, controller.contact.Id, 'Contact ID should match the test case Contact ID');

        // Assert the number of Manodhaara_Appointment__c records related to the Case
        System.assertEquals(3, controller.appointmentCount, 'Appointment count should match the number of test appointments');
    }

    @isTest
    static void testCaseContactControllerWithoutAppointment() {
         Contact testContact2 = new Contact(
            LastName = 'Test Contact2',
            //Active_Semester__c = 'Spring 2024',
            SRN_Number__c = 'SRN123452',
            email = 'testuser2@example.com'
        );
        insert testContact2;
        
        // Create a test Case without a appointment
        Case testCaseWithoutContact = new Case(
            //CaseNumber = '00001001',
            ContactId = testContact2.Id,
            Description = 'Test Case Description without Contact',
            Reason_for_C__c = 'Graduated from School'
        );
        insert testCaseWithoutContact;

        // Instantiate the StandardController with the test Case without Contact
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCaseWithoutContact);

        // Instantiate the CaseContactController
        CaseContactController controller = new CaseContactController(stdController);

        // Assert that the Case record is correctly initialized
        System.assertNotEquals(null, controller.caseRecord, 'Case record should be initialized');
        System.assertEquals(testCaseWithoutContact.Id, controller.caseRecord.Id, 'Case record ID should match the test case ID without Contact');

        // Assert that the Contact record is null since there is no Contact linked to the Case
        //System.assertEquals(null, controller.contact, 'Contact record should be null since there is no Contact linked to the Case');

        // Assert the number of Manodhaara_Appointment__c records related to the Case is 0
        System.assertEquals(0, controller.appointmentCount, 'Appointment count should be 0 since there are no related appointments');
    }
}