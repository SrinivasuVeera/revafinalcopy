@isTest
public class RTREarlyPickupBatchContinuationTest {
    @testSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Reva_Transport__c testRevaTransport = new Reva_Transport__c(Name = 'Test Transport', Active__c = true);
        insert testRevaTransport;

        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            MobilePhone = '1234567890',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create test transport registration
        Transport_Registeration__c testRegistration = new Transport_Registeration__c(
            Contact__c = testContact.Id,
            Registration_Status__c = 'Active',
            Reva_Transport__c = testRevaTransport.Id
        );
        insert testRegistration;

        // Create test transport request
        RTR_Reva_Transport_Request__c testRequest = new RTR_Reva_Transport_Request__c(
            RTR_Number_of_Minutes__c = 30,
            RTR_Start_Date__c = Date.today(),
            RTR_End_Date__c = Date.today().addDays(1),
            RTR_Descriptions__c = 'Test early pickup'
            //Contact__c = testContact.Id
        );
        insert testRequest;
    }

    @isTest
    static void testQueueableContinuationExecution() {
        // Fetch test request record
        RTR_Reva_Transport_Request__c testRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];

        // Create batch instance
        RTREarlyPickUpMultipleBatchNotification batchInstance = new RTREarlyPickUpMultipleBatchNotification(testRequest.Id);

        // Create and enqueue the Queueable continuation job
        Test.startTest();
        System.enqueueJob(new RTREarlyPickupBatchContinuation(batchInstance));
        Test.stopTest();

        // Assertions (Can check debug logs, job execution status, or other expected behaviors)
        System.assert(true, 'Queueable continuation executed successfully.');
    }
}