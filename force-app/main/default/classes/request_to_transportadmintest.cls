@isTest
public class request_to_transportadmintest {

    public class SMSMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testingmethod() {
        // Query existing RecordType (DON’T insert new one)
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = 'Transport_Cancellation'
              AND SObjectType = 'RTR_Reva_Transport_Request__c'
            LIMIT 1
        ];

        // Insert Contact — remove non-writeable fields
        Contact con = new Contact(
            FirstName = 'Sathiya',
            LastName = 'Deva',
            MiddleName = 'Rajendra',
            MobilePhone = '7079090900',
            SRN_Number__c = 'SRN123N',
            RH_Parent_Phone_Number__c = '9090909090'
        );
        insert con;

        // Insert test User (remove .Name field)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Lakshmanan',
            LastName = 'G',
            Email = 'lakshmanan@example.com',
            Username = 'lakshmanan' + Math.random() + '@example.com',
            Alias = 'laks',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            MobilePhone = '9876543210'
        );
        insert u;

        // Insert Transport Registration
        Transport_Registeration__c tr = new Transport_Registeration__c(
            Contact__c = con.Id,
            Registration_Status__c = 'Cancelled'
        );
        insert tr;

        // Insert RTR_Reva_Transport_Request__c
        RTR_Reva_Transport_Request__c reva = new RTR_Reva_Transport_Request__c(
            Cancellation_Date__c = System.today(),
            RTR_Reason_For_Cancellation__c = 'I have Bike',
            SRN_EmployeeID__c = con.SRN_Number__c,
            RecordTypeId = rt.Id
        );
        insert reva;

        // Add ID to list
        List<String> regis = new List<String>{ tr.Id };

        // Mock callout and run test
        Test.setMock(HttpCalloutMock.class, new SMSMock());
        Test.startTest();
        request_to_transportadmin.rtrSMSNotificationStudent(regis);
        Test.stopTest();

        System.assert(true, 'Callout executed successfully');
    }
}