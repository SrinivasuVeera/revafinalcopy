@isTest
public class CanReqWhatsappStudentTest {

    // Mock Callout Class for Yellow_AI_Utility
    private class MockYellowAICallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mocked WhatsApp sent"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendWhatsAppNotificationsWithMock() {
        // Register the mock callout
        Test.setMock(HttpCalloutMock.class, new MockYellowAICallout());

        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            MobilePhone = '9876543210',
            SRN_Number__c = 'SRN12345'
        );
        insert testContact;

        // Create multiple Transport Registration records with different statuses
        List<Transport_Registeration__c> transportRegs = new List<Transport_Registeration__c>{
            new Transport_Registeration__c(
                //Name = 'TR001',
                Registration_Status__c = 'Cancellation Request Submitted',
                Contact__c = testContact.Id
            ),
            new Transport_Registeration__c(
               // Name = 'TR002',
                Registration_Status__c = 'Transport Admin Rejected',
                Contact__c = testContact.Id
            ),
            new Transport_Registeration__c(
               // Name = 'TR003',
                Registration_Status__c = 'Transport Admin Approved',
                Contact__c = testContact.Id
            ),
            new Transport_Registeration__c(
               // Name = 'TR004',
                Registration_Status__c = 'Cancellation Approved',
                Contact__c = testContact.Id
            )
        };
        insert transportRegs;
		Id routeChangeRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND Name = 'Transport Cancellation' LIMIT 1].Id;
        // Create related Transport Request
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            SRN_EmployeeID__c = 'SRN12345',
            Cancellation_Date__c = System.today(),
            RecordTypeId = routeChangeRtId
        );
        insert req;

        // Run the method
        Test.startTest();
        CanReqWhatsappStudent.sendWhatsAppNotifications(
            new List<String>{
                transportRegs[0].Id,
                transportRegs[1].Id,
                transportRegs[2].Id,
                transportRegs[3].Id
            }
        );
        Test.stopTest();
    }

    @isTest
    static void testEmptyRecordIds() {
        Test.startTest();
        CanReqWhatsappStudent.sendWhatsAppNotifications(new List<String>());
        CanReqWhatsappStudent.sendWhatsAppNotifications(null);
        Test.stopTest();
    }
}