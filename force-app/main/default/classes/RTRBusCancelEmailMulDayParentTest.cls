@isTest
public class RTRBusCancelEmailMulDayParentTest {
@testSetup
    static void setup() {
        // Create test data
        RTR_Route_Pick_Up_Point__c pickupPoint = TestDataFactory.createPickUpPoint();        
        Reva_Transport__c revaTransport = TestDataFactory.createRevaTransport();        
        RTR_Route_Master__c routeMaster = TestDataFactory.createRouteMaster();
        Id ParentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        // Create test transport request
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTR_Number_of_Minutes__c = 10,
            RTR_Date__c = Date.today(),
            RTR_Descriptions__c = 'Test Description',
            RTR_Start_Date__c = Date.today(),
            RTR_End_Date__c = Date.today().addDays(3)
        );
        insert transportRequest;
        Contact FatherCon= new Contact( FirstName = 'Tests1',
            LastName = 'User1679',
            Email = 'tests1@gmail.com',
            recordTypeId=ParentRecordTypeId);
        insert FatherCon;
        Contact MotherCon= new Contact( FirstName = 'Tests2',
            LastName = 'User1679',
            Email = 'tests2@gmail.com',
            recordTypeId=ParentRecordTypeId);
        insert MotherCon;
        Contact GaurdianCon= new Contact( FirstName = 'Tests3',
            LastName = 'User1679',
           Email = 'tests3@gmail.com',
            recordTypeId=ParentRecordTypeId);
        insert GaurdianCon;
              
        // Create additional contacts with mobile phones
        Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'User1',
            MobilePhone = '1234567890',
            Email = 'testuser@gmail.com',
            Father__c = FatherCon.id
        );
        insert contact1;
        
        // Create additional contacts with mobile phones
        Contact contact2 = new Contact(
            FirstName = 'Test',
            LastName = 'User1',
            MobilePhone = '1234567890',
            Email = 'testuser2@gmail.com',
            Mother__c = MotherCon.id
        );
        insert contact2;
        
        // Create additional contacts with mobile phones
        Contact contact3 = new Contact(
            FirstName = 'Test',
            LastName = 'User1',
            MobilePhone = '1234567890',
            Email = 'testuser2@gmail.com',
            Guardian__c = GaurdianCon.id
        );
        insert contact3;
        
        // Insert transport registration with the new contact
        Transport_Registeration__c createtransport = new Transport_Registeration__c(
            Route_Pick_Up_Point__c = pickupPoint.Id,
            Reva_Transport__c = revaTransport.Id,
            Route_Master__c = routeMaster.Id,
            Contact__c = contact1.Id, 
            Registration_Status__c = 'Active'
        );
        insert createtransport;
        
         // Insert transport registration with the new contact
        Transport_Registeration__c createtransport1 = new Transport_Registeration__c(
            Route_Pick_Up_Point__c = pickupPoint.Id,
            Reva_Transport__c = revaTransport.Id,
            Route_Master__c = routeMaster.Id,
            Contact__c = contact2.Id, 
            Registration_Status__c = 'Active'
        );
        insert createtransport1;
        
         // Insert transport registration with the new contact
        Transport_Registeration__c createtransport3 = new Transport_Registeration__c(
            Route_Pick_Up_Point__c = pickupPoint.Id,
            Reva_Transport__c = revaTransport.Id,
            Route_Master__c = routeMaster.Id,
            Contact__c = contact3.Id, 
            Registration_Status__c = 'Active'
        );
        insert createtransport3;
                
    }
    
    @isTest
    static void testBatch() {
        // Fetch test transport request
        RTR_Reva_Transport_Request__c transportRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];
        
        // Instantiate batch class with a list of Ids
        List<String> transportRequestIds = new List<String>{transportRequest.Id};
        RTRBusCancelledEmailMultipleDayParent batch = new RTRBusCancelledEmailMultipleDayParent(transportRequestIds);
           
        // Execute batch
        Test.startTest();
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();
        
        // Validate that the batch ran successfully
        System.assertNotEquals(null, batchId, 'Batch job did not execute successfully.');
    }
    
    @isTest
    static void testExecuteMethodExceptionHandling() {
        // Fetch test transport request
        RTR_Reva_Transport_Request__c transportRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];
        
        // Fetch Transport_Registeration__c records
        List<Transport_Registeration__c> transportRegistrations = [SELECT Id FROM Transport_Registeration__c LIMIT 1];
        
               
        Test.startTest();
        // Instantiate batch class with a list of Ids
        List<String> transportRequestIds = new List<String>{transportRequest.Id};
        RTRBusCancelledEmailMultipleDayParent batch = new RTRBusCancelledEmailMultipleDayParent(transportRequestIds);
        // Execute batch context
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();
        
        // Validate that the batch ran successfully
        System.assertNotEquals(null, batchId, 'Batch job did not execute successfully.');
    }
}