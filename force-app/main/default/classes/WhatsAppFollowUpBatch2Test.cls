@isTest
public class WhatsAppFollowUpBatch2Test {
    static testMethod void testBatchExecution2() {
        // Create Fee_Master__c records
        hed__Program_Plan__c progBatch = new hed__Program_Plan__c();
        progBatch.Name = 'B. Tech in Mechatronics Engineering-(2024-2028)';
        insert progBatch;

        List<Fee_Master__c> feeMasterList = new List<Fee_Master__c>();
        Fee_Master__c feeMaster = new Fee_Master__c(
            Program_Batch__c = progBatch.Id,
            IsActive__c = true,
            Fee_Type__c = 'Application Fee',
            Applicant_Category__c = 'Indian (SAARC)'
        );
        feeMasterList.add(feeMaster);
        insert feeMasterList;

        // Test data setup for hed__Application__c and hed__Applicant__c
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 1; i++) {
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = true,
                Program_Batch__c = progBatch.Id, // Ensure this matches the Program_Batch__c in Fee_Master__c
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId(),
                Admission_Mode__c = 'UQ'
            );
            contacts.add(applicant);
        }
        insert contacts;

        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts.size(); i++) {
            hed__Application__c app = new hed__Application__c(
                hed__Applicant__c = contacts[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0') + '2',
                hed__Application_Status__c = 'Started'
            );
            applications.add(app);
        }
        insert applications;

        // Start the batch
        Test.startTest();
        WhatsAppFollowUpBatch2 batch = new WhatsAppFollowUpBatch2();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}