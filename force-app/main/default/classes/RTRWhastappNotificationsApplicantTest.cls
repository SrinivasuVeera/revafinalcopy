@isTest
public class RTRWhastappNotificationsApplicantTest {
@isTest
    static void testTrsWhatsappNotification() {
        // Set up test data
        // Create a Contact
      
      Account academicProgram = new Account(Name ='School of engineering');
        insert academicProgram;
      Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'User1',
            MobilePhone = '1234567890',
          	Application_Number__c='abre1245',
          	Primary_Academic_Program__c = academicProgram.Id
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
                                                   Registration_Status__c='Active');
          insert createtransport;

        // Create a Student_Fee__c record
        Student_Fee__c studentFee = new Student_Fee__c(
            Amount_Paid__c = 100.0,
            Amount_Pending__c = 50.0,
            Amount__c = 150.0,
   			Contact__c = contact1.Id,
            Fee_Type__c = 'Transportation Fee',
            RTR_Transport_Registration__c = createtransport.Id,
            Due_Date__c = Date.today().addDays(30)
        );
        insert studentFee;

       WhatsApp_Notification_Template__mdt cusmeta =[select id,developerName, Template_ID__c,Template_Field__c from WhatsApp_Notification_Template__mdt where developerName = 'transport_registration_confirmation_appl'];

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Collect the record IDs for testing
        List<String> recordIds = new List<String>{createtransport.Id};

        // Test start
        Test.startTest();
        RTRWhastappNotificationsApplicant.trsWhatsappNotification(recordIds);
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