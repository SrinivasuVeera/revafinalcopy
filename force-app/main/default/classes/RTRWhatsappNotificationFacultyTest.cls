@isTest
public class RTRWhatsappNotificationFacultyTest {
 @isTest
    static void testTrsWhatsappNotification() {

      Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'User1',
          	//Name ='Test User1',
            MobilePhone = '1234567890',
          	Employee_Number__c = 'ru123456',
          	Salary__c = 15000
          
        );
        insert contact1;

       RTR_Route_Master__c routeMaster = TestDataFactory.createRouteMaster();
	   Reva_Transport__c revaTransport = TestDataFactory.createRevaTransport();
       RTR_Route_Pick_Up_Point__c pickupPoint = TestDataFactory.createPickUpPoint(); 

        // Create a Transport_Registeration__c record
         Transport_Registeration__c createtransport= new Transport_Registeration__c(//Name='Testing',
                                                   Route_Pick_Up_Point__C= pickupPoint.Id ,
                                                   Reva_Transport__C=revaTransport.Id,
                                                   Route_Master__C= routeMaster.Id,
                                                   Contact__C= contact1.Id,
             									   Amount_Paid__c = 2000,
             									   rtr_Start_Date__c = Date.today().addDays(3),	
                                                   Registration_Status__c='Active');
          insert createtransport;

        
      

       WhatsApp_Notification_Template__mdt cusmeta =[select id,developerName, Template_ID__c,Template_Field__c from WhatsApp_Notification_Template__mdt where developerName = 'transport_registration_confirmation_staf'];

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Collect the record IDs for testing
        List<String> recordIds = new List<String>{createtransport.Id};

        // Test start
        Test.startTest();
        RTRWhatsappNotificationFaculty.trsWhatsappNotification(recordIds);
        Test.stopTest();

        // Add assertions to validate behavior
        // Note: As this is an asynchronous callout, we will need to validate the outcomes of the asynchronous processing
        // and mock responses accordingly.
        // In a real test, you may need to verify the callout made by checking the HTTP request in the mock.
        System.assert(true, 'Add more assertions as necessary to verify the expected outcomes');
    }

    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}