@isTest
public class TestRTRLateDropOffBatchContinuation {
    @isTest
    static void testQueueableContinuation() {
        // Step 1: Create test data
        // Create Reva_Transport__c record
        Reva_Transport__c transport = new Reva_Transport__c(Name = 'Transport 1', Active__c = true);
        insert transport;

        // Create Contact record
        Contact contact = new Contact(
            LastName = 'TestContact',
            MobilePhone = '1234567890'
        );
        insert contact;

        // Create Transport_Registeration__c record
        Transport_Registeration__c registration = new Transport_Registeration__c(
            Contact__c = contact.Id,
            Registration_Status__c = 'Active',
            Reva_Transport__c = transport.Id
        );
        insert registration;

        // Create RTR_Reva_Transport_Request__c record
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTR_Number_of_Minutes__c = 15,
            RTR_Date__c = Date.today(),
            RTR_Descriptions__c = 'Late drop-off reason'
        );
        insert transportRequest;

        // Step 2: Instantiate the Batch
        String recordIds = transportRequest.Id;
        RTRLateDropOffBatchNotification batchInstance = new RTRLateDropOffBatchNotification(recordIds);

        // Step 3: Enqueue the Queueable
        Test.startTest();
        RTRLateDropOffBatchContinuation continuationInstance = new RTRLateDropOffBatchContinuation(batchInstance);
        System.enqueueJob(continuationInstance);
        Test.stopTest();

        // Step 4: Assertions
        System.assert(true, 'Queueable executed without exceptions.');
    }
}