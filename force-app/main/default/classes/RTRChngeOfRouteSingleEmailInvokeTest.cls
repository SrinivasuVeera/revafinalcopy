@isTest
public class RTRChngeOfRouteSingleEmailInvokeTest {
@isTest
    static void test_routechangeEmail() {
        // Generate test data
        Contact con = TestDataFactory.createContact();
        RTR_Reva_Transport_Request__c transportRequests = TestDataFactory.createTestTransportRequests();
        RTR_Route_Pick_Up_Point__c pickupPoint = TestDataFactory.createPickUpPoint();        
        Reva_Transport__c revaTransport = TestDataFactory.createRevaTransport();        
        RTR_Route_Master__c routeMaster = TestDataFactory.createRouteMaster();
        Transport_Registeration__c createTransport = TestDataFactory.createTransport();
           
        Test.startTest();
        List<String> recordIds = new List<String>{transportRequests.Id};
        RTRChangeOfRouteSingleDayEmailInvoke.routeChangeEmailSingleDay(recordIds);
        Test.stopTest();
    }
}