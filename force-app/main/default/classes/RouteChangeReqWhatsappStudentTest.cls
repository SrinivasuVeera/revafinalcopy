@isTest
public class RouteChangeReqWhatsappStudentTest {

    // Mock HTTP callout to simulate WhatsApp API
    public class WhatsAppMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendWhatsAppNotifications() {
        // Register mock callout
        Test.setMock(HttpCalloutMock.class, new WhatsAppMockCallout());

        // Create test Contact
        Contact con = new Contact(
            LastName = 'Test Student',
            MobilePhone = '9876543210',
            SRN_Number__c = 'SRN123'
        );
        insert con;

        // Create Transport Registration records with all relevant statuses
        List<Transport_Registeration__c> regList = new List<Transport_Registeration__c>();
        List<String> statuses = new List<String>{
            'Route Change Request Submitted',
            'Route change Transport admin Rejected',
            'Route change Transport admin Approved',
            'Route change Finance team approved'
        };

        for (String status : statuses) {
            regList.add(new Transport_Registeration__c(
                //Name = 'REG-' + status.replace(' ', ''),
                Contact__c = con.Id,
                Registration_Status__c = status,
                RouteChangeAmountToPay__c = status == 'Route change Transport admin Approved' ? 150.00 : 0
            ));
        }
        insert regList;
		system.debug('regList'+ regList);
        
        Id routeChangeRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND Name = 'Route Change Request' LIMIT 1].Id;
        // Create corresponding transport request
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            SRN_EmployeeID__c = 'SRN123',
            Cancellation_Date__c = Date.today(),
            Existing_Amount__c = 70,
            RecordTypeId = routeChangeRtId
        );
        insert req;
        system.debug('req'+ req);

        // Create WhatsApp Metadata records
        List<WhatsApp_Notification_Template__mdt> templates = new List<WhatsApp_Notification_Template__mdt>{
            new WhatsApp_Notification_Template__mdt(
                DeveloperName = 'transport_route_change_req_student',
                Template_ID__c = 'transport_route_change_req_student',
                Template_Field__c = 'student_name,5556'
            ),
            new WhatsApp_Notification_Template__mdt(
                DeveloperName = 'transport_rchg_rejected_student',
                Template_ID__c = 'transport_rchg_rejected_student',
                Template_Field__c = '565676,student_name'
            ),
            new WhatsApp_Notification_Template__mdt(
                DeveloperName = 'transport_rchg_payment_student',
                Template_ID__c = 'transport_rchg_payment_student',
                Template_Field__c = 'student_name,amount,www.Link to pay.com'
            ),
            new WhatsApp_Notification_Template__mdt(
                DeveloperName = 'transport_rchg_done_student',
                Template_ID__c = 'transport_rchg_done_student',
                Template_Field__c = 'student_name,55556'
            )
        };
        //insert templates;

        // Prepare record IDs
        List<String> regIds = new List<String>();
        for (Transport_Registeration__c reg : regList) {
            regIds.add(reg.Id);
        }

        // Call the method and execute @future logic
        Test.startTest();
        RouteChangeReqWhatsappStudent.sendWhatsAppNotifications(regIds);
        Test.stopTest();
    }
}