@isTest
public class RTRWhatsappNotificatrionearlydropoffTest {
@isTest
    static void test_trsWhatsappNotification() {
        // Generate test data
        contact con = testDataFactory.createContact();
        RTR_Reva_Transport_Request__c transportRequests = testDataFactory.createTestTransportRequests();
        RTR_Route_Pick_Up_Point__c pickupPoint = TestDataFactory.createPickUpPoint();        
        Reva_Transport__c revaTransport = TestDataFactory.createRevaTransport();        
        RTR_Route_Master__c routeMaster = TestDataFactory.createRouteMaster();
        Transport_Registeration__c createTransport = TestDataFactory.createTransport();
        List<String> recordIds = new List<String>{transportRequests.Id};
       
        
        Test.startTest();
        
        // Call the method to test
        RTR_WhatsappNotificatrion_early_drop_off.trsWhatsappNotification(recordIds);
        
        Test.stopTest();
               
    }
}