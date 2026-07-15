@isTest
public class RTRFacultySMSTest {
    
    @testSetup
    static void setupTestData() {
         Id StudentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            recordTypeId= StudentRecordTypeId,
            Employee_Number__c = 'APP123456',
            Salary__c = 15000,
            MobilePhone = '1234567890'
        );
        insert testContact;
        
        RTR_Route_Master__c routeMaster = TestDataFactory.createRouteMaster();
        Reva_Transport__c revaTransport = TestDataFactory.createRevaTransport();
        RTR_Route_Pick_Up_Point__c pickupPoint = TestDataFactory.createPickUpPoint(); 
        
        // Create a Transport_Registeration__c record
        Transport_Registeration__c createtransport = new Transport_Registeration__c(
            Route_Pick_Up_Point__c = pickupPoint.Id,
            Reva_Transport__c = revaTransport.Id,
            Route_Master__c = routeMaster.Id,
            Contact__c = testContact.Id, 
            Registration_Status__c = 'Active'
        );
        insert createtransport;
    }
    
    @isTest
    static void testRTRSMSNotificationStudent() {
        // Retrieve the inserted Transport Registration
        List<Transport_Registeration__c> trRegList = [SELECT Id FROM Transport_Registeration__c LIMIT 1];
        List<String> recordIds = new List<String>();
        for (Transport_Registeration__c trReg : trRegList) {
            recordIds.add(trReg.Id);
        }
        
        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Test the RTR Send SMS Notifications to Student method
        Test.startTest();
        RTRFacultySMS.rtrSMSNotificationFaculty(recordIds);
        Test.stopTest();
    }
    
    @isTest
    static void testMakeCalloutAsync() {
        // Retrieve the inserted Transport Registration
        List<Transport_Registeration__c> trRegList = [SELECT Id FROM Transport_Registeration__c LIMIT 1];
        List<String> recordIds = new List<String>();
        for (Transport_Registeration__c trReg : trRegList) {
            recordIds.add(trReg.Id);
        }
        
        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Test the future method makeCalloutAsync directly
        Test.startTest();
        RTRFacultySMS.makeCalloutAsync(recordIds);
        Test.stopTest();
    }


// Mock HTTP callout response class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"user" : "revaerp.trans","password" : "s1Sz2"},"from" : "REVAUn","shortMessages" : [ {"dltContentId" : "1007083624798832011","message" : "Dear Test User1, We’d like to inform you that the University bus will arrive at the pickup point 10 mins earlier than the regular schedule on 26.05.2024 on account of Test Description. REVA University", "recipient" : "1234567890"} ],"unicode" : true}');
            res.setStatusCode(200);
            return res;
        }
    }
}