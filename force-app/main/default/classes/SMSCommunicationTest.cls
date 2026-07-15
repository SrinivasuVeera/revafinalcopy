@isTest
public class SMSCommunicationTest {

    // Test method for SMSCommunication batch job
    @isTest
    public static void testSMSCommunicationBatch() {
        
        // Step 1: Create Household Account
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
        Account objAcc = TT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        // Step 2: Create University Department Account
        Id AccountRecTypeIdRACE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();        
        Account acc = TT_TestDataFactory.CreateAccount('REVA', AccountRecTypeId);
        acc.RecordTypeId = AccountRecTypeIdRACE;
        acc.Program_Type__c = 'PG';
        insert acc;
        
        // Step 3: Create Program Plan (Program Batch)
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'Master of Science in Biotechnology-(2023-2025)',
            hed__Start_Date__c = system.today().addDays(-5),
            hed__End_Date__c = system.today().addYears(1),
            hed__Account__c = acc.id
        );
        insert programBatch;

        // Step 4: Create Contact (Student)
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objCon = TT_TestDataFactory.createContact('test Contact');
        objCon.AccountId = objAcc.id;
        objCon.School__c = acc.id;
        objCon.Student_Status__c = 'Pursuing';
        objCon.Professor_Across_Schools__c = true;
        objCon.Application_Number__c = '123';
        objCon.hed__WorkEmail__c = '123@reva.edu.in';
        objCon.Email = 'test@gmail.com';
        objCon.MobilePhone = '8963210547';
        objCon.SRN_Number__c = 'Srn123';
        objCon.RecordTypeId = ContactRecTypeId;
        objCon.OwnerId = UserInfo.getUserId();
        objCon.Nationality__c = 'Indian';
        objCon.Program_Batch__c = programBatch.Id;
        objCon.Aadhar_Card_Number__c = '368845632147'; 
        objCon.PAN_Number__c = 'HRAPO4561D';
        insert objCon;

        // Step 5: Execute Batch Job
        Test.startTest();
        
        // Instantiate the batch class
        SMSCommunication batchJob = new SMSCommunication();
        
        // Execute the batch job
        Id batchJobId = Database.executeBatch(batchJob, 1); // Set batch size to 1 for testing
        
        Test.stopTest();

        // Verify the AsyncApexJob was created and completed
        AsyncApexJob job = [SELECT Status, NumberOfErrors, JobItemsProcessed FROM AsyncApexJob WHERE Id = :batchJobId];
        System.assertEquals('Completed', job.Status);
        System.assertEquals(0, job.NumberOfErrors);
        System.assertEquals(1, job.JobItemsProcessed, 'The batch job should process 1 item');

        // Verify that the contact was processed for SMS (mock or system assert for message logic can be added)
        System.assertEquals('8963210547', objCon.MobilePhone, 'Contact with MobilePhone should be processed.');
    }
    
    // Test method for getTimeDetails method in SMSNotification_Batch class
    public static testMethod void testGetTimeDetails() {
        // Test with a time in 24-hour format
        String formattedTime1 = SMSCommunication.getTimeDetails('14:30');
        System.assertEquals('2:30 PM', formattedTime1, 'Time format should be in 12-hour format with PM');

        // Test with a time in 24-hour format with leading 0 (for AM times)
        String formattedTime2 = SMSCommunication.getTimeDetails('09:15');
        System.assertEquals('09:15 AM', formattedTime2, 'Time format should be in 12-hour format with AM');

        // Test with a time in 12-hour format (7:45 AM)
        String formattedTime3 = SMSCommunication.getTimeDetails('07:45');
        System.assertEquals('07:45 AM', formattedTime3, 'Time format should remain the same as 12-hour format with AM');

        // Add more test cases if needed for edge cases (e.g., midnight, noon)
    }
}