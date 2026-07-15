@isTest
public class rve_ConvocationQR_PDFControllerTest {
    @testSetup
    static void setup() {
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            rve_Convocation_Date_Time__c = DateTime.now().addDays(30)
        );
        insert programBatch;

        
        // Create sample Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact contact = new Contact(
                FirstName = 'Test' + i,
                LastName = 'User' + i,
                SRN_Number__c = 'SRN' + i,
                Personal_Email__c = 'test' + i + '@example.com',
                rve_Present_for_Convocation__c = false,
                Program_Batch__c = programBatch.Id
            );
            contacts.add(contact);
        }
        insert contacts;
    }

    @isTest
    static void testSendEmailNotification() {
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 5];
        List<List<Contact>> contactIds = new List<List<Contact>>();
        contactIds.add(contacts);

        Test.startTest();
        // Instantiate the batch class with contactIds parameter
          rve_ConvocationQR_PDFController.sendEmailNotification(contactIds);
        // Execute the batch job
        //Database.executeBatch(batchJob, 100);
        Test.stopTest();

        // Verify that the batch executed correctly
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status='Completed']);
    }

    @isTest
    static void testUpdateIsPresent() {
        Contact testContact = [SELECT Id, SRN_Number__c, rve_Present_for_Convocation__c FROM Contact LIMIT 1];
        testContact.rve_Present_for_Convocation__c = false;
        update testContact;

        Test.startTest();
        String result = rve_ConvocationQR_PDFController.updateIsPresent(testContact.SRN_Number__c);
        Test.stopTest();

        // Verify that the contact was updated correctly
        testContact = [SELECT Id, SRN_Number__c, rve_Present_for_Convocation__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(true, testContact.rve_Present_for_Convocation__c);
        System.assertEquals('true', result);

        // Test for already present
        result = rve_ConvocationQR_PDFController.updateIsPresent(testContact.SRN_Number__c);
        System.assertEquals('neutral', result);

        // Test for non-existing SRN_Number
        result = rve_ConvocationQR_PDFController.updateIsPresent('NonExistentSRN');
        System.assertEquals('false', result);

        // Test for blank SRN_Number
        result = rve_ConvocationQR_PDFController.updateIsPresent('');
        System.assertEquals('false', result);
    }

    @isTest
    static void testUpdateIsPresentWithException() {
        Test.startTest();
        String result = rve_ConvocationQR_PDFController.updateIsPresent(null);
        Test.stopTest();

        // Verify that the method returns 'false' for null SRN_Number
        System.assertEquals('false', result);
    }
    
    @isTest
    static void testBatchProcessing() {
        // Query the test contacts
        List<Contact> contacts = [SELECT Id, Name, SRN_Number__c, Personal_Email__c, Program_Batch__r.rve_Convocation_Date_Time__c, Program_Batch__r.rve_Convocation_Time__c FROM Contact];
        
        // Divide the contacts into batches of lists
        List<List<Contact>> contactBatches = new List<List<Contact>>();
        Integer batchSize = 5;
        for (Integer i = 0; i < contacts.size(); i += batchSize) {
            contactBatches.add(contacts);
        }
        
        // Instantiate the batchable class
        rve_ConvocationEmailNotification batchable = new rve_ConvocationEmailNotification(contactBatches);
        
        // Run the batch job
        Test.startTest();
        Database.executeBatch(batchable, batchSize);
        Test.stopTest();
        
        // Verify that the emails were sent
        //List<Messaging.SingleEmailMessage> sentEmails = [SELECT Id FROM Messaging.SingleEmailMessage];
        //System.assertEquals(contacts.size(), sentEmails.size(), 'The number of sent emails should match the number of contacts.');
    }
}