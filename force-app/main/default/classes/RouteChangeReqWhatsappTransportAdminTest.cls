@isTest
public class RouteChangeReqWhatsappTransportAdminTest {

    // Mock callout response class
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
    static void testSendWhatsAppToTransportAdmin() {
        Test.setMock(HttpCalloutMock.class, new WhatsAppMockCallout());

        // Insert Transport Admin User
        User admin = new User(
            Alias = 'tadmin',
            Email = 'admin@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Lakshmanan',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'lakshmanan.admin' + DateTime.now().getTime() + '@example.com',
            MobilePhone = '9999988888'
        );
        insert admin;

        // Insert Contact
        Contact con = new Contact(
            LastName = 'Student A',
            SRN_Number__c = 'SRN001'
        );
        insert con;

        // Create registration records with 2 statuses
        List<Transport_Registeration__c> regs = new List<Transport_Registeration__c>{
            new Transport_Registeration__c(
               // Name = 'REG-001',
                Contact__c = con.Id,
                Registration_Status__c = 'Route Change Request Submitted'
            ),
            new Transport_Registeration__c(
               // Name = 'REG-002',
                Contact__c = con.Id,
                Registration_Status__c = 'Route change Finance team approved'
            )
        };
        insert regs;

        // Create pickup point and route master
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'R001');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickupPoint = new RTR_Route_Pick_Up_Point__c(
            Name = 'Main Gate',
            RTR_Route_Master__c = routeMaster.Id
        );
        insert pickupPoint;
		
		Id routeChangeRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND Name = 'Route Change Request' LIMIT 1].Id;
        // Insert transport requests
        List<RTR_Reva_Transport_Request__c> requests = new List<RTR_Reva_Transport_Request__c>{
            new RTR_Reva_Transport_Request__c(
                SRN_EmployeeID__c = 'SRN001',
                Cancellation_Date__c = Date.today(),
                RTRStudent_Faculty_NonFaculty__c = con.Id,
                RTR_Route_Pick_Up_Point__c = pickupPoint.Id,
                RecordTypeId = routeChangeRtId
            ),
            new RTR_Reva_Transport_Request__c(
                SRN_EmployeeID__c = 'SRN001',
                Cancellation_Date__c = Date.today(),
                RTRStudent_Faculty_NonFaculty__c = con.Id,
                RTR_Route_Pick_Up_Point__c = pickupPoint.Id,
                RecordTypeId = routeChangeRtId
            )
        };
        insert requests;

        // Collect registration IDs
        List<String> regIds = new List<String>();
        for (Transport_Registeration__c reg : regs) {
            regIds.add(reg.Id);
        }

        Test.startTest();
        RouteChangeReqWhatsappTransportAdmin.sendWhatsAppNotifications(regIds);
        Test.stopTest();
    }
}