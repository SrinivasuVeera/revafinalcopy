@isTest
public class RouteChangeReqWhatsappParentTest {

    // Mock callout class to simulate WhatsApp response
    public class WhatsAppMockCallout implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendWhatsAppToParent() {
        Test.setMock(HttpCalloutMock.class, new WhatsAppMockCallout());

        // Insert test Father Contact (as parent)
        Contact father = new Contact(
            LastName = 'Mr. Sharma'
        );
        insert father;

        // Insert test Student Contact with SRN and parent phone
        Contact student = new Contact(
            LastName = 'Student A',
            SRN_Number__c = 'SRN001',
            RH_Parent_Phone_Number__c = '9999988888',
            Father__c = father.Id
        );
        insert student;

        // Insert 2 Transport Registrations with both statuses
        List<Transport_Registeration__c> regs = new List<Transport_Registeration__c>{
            new Transport_Registeration__c(
               // Name = 'REG001',
                Contact__c = student.Id,
                Registration_Status__c = 'Route Change Request Submitted'
            ),
            new Transport_Registeration__c(
                //Name = 'REG002',
                Contact__c = student.Id,
                Registration_Status__c = 'Route change Finance team approved'
            )
        };
        insert regs;

        // Insert dummy route master and pickup point for new route details
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'R003');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickupPoint = new RTR_Route_Pick_Up_Point__c(
            Name = 'Main Gate',
            RTR_Route_Master__c = routeMaster.Id
        );
        insert pickupPoint;

        // Insert transport request for SRN
        RTR_Reva_Transport_Request__c transportReq = new RTR_Reva_Transport_Request__c(
            SRN_EmployeeID__c = 'SRN001',
            Cancellation_Date__c = Date.today(),
            New_Route_Master__c = routeMaster.Id,
            New_Route_Pick_Up_Point__c = pickupPoint.Id
        );
        insert transportReq;

        // Collect record IDs
        List<String> regIds = new List<String>();
        for (Transport_Registeration__c reg : regs) {
            regIds.add(reg.Id);
        }

        Test.startTest();
        RouteChangeReqWhatsappParent.sendWhatsAppNotifications(regIds);
        Test.stopTest();
    }
}