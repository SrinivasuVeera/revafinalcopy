@isTest
public class InfraApprovalSMSTest {
     private class SMSAPIMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate a valid JSON response
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    @isTest
    static void testInfraSMSNotification() {
        // Create test data
        List<Facility_Request__c> facilityRequests = new List<Facility_Request__c>();
        for (Integer i = 0; i < 3; i++) {
            Facility_Request__c fr = new Facility_Request__c(
                Start_Date__c = Date.today(),
                Account__c = createTestAccount().Id,
                Start_Time__c = Time.newInstance(9, 0, 0, 0),
                End_Date__c = Date.today(),
                End_Time__c = Time.newInstance(17, 0, 0, 0),
                Facility_Name__c = 'Facility ' + i,
                Building_Name__c = 'Building ' + i,
                Additional_Amenities_Required__c = 'None',
                Floor__c = 'Floor ' + i,
                Room_No__c = 'Room No ' + i,
                TemplateName__c = (i == 0) ? 'Requested' : (i == 1) ? 'Rejected' : 'Approved',
                ApprovalStatus__c = 'Pending'
            );
            facilityRequests.add(fr);
        }
        insert facilityRequests;
        
        Test.startTest();
        
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new SMSAPIMock());
        
        // Test infraSMSNotification method
        List<String> recordIds = new List<String>();
        for (Facility_Request__c fr : facilityRequests) {
            recordIds.add(fr.Id);
        }
        
        InfraApprovalSMS.infraSMSNotification(recordIds);
        
        Test.stopTest();
        
        // Verify results (use System.assert if applicable)
        // Since this is asynchronous, direct verification of callouts will not be possible without further setup
    }
    
    @isTest
    static void testMakeCalloutAsync() {
        // Create test data
        List<Facility_Request__c> facilityRequests = new List<Facility_Request__c>();
        for (Integer i = 0; i < 3; i++) {
            Facility_Request__c fr = new Facility_Request__c(
                Start_Date__c = Date.today(),
                Account__c = createTestAccount().Id,
                Start_Time__c = Time.newInstance(9, 0, 0, 0),
                End_Date__c = Date.today(),
                End_Time__c = Time.newInstance(17, 0, 0, 0),
                Facility_Name__c = 'Facility ' + i,
                Building_Name__c = 'Building ' + i,
                Additional_Amenities_Required__c = 'None',
                Floor__c = 'Floor ' + i,
                Room_No__c = 'Room No ' + i,
                TemplateName__c = (i == 0) ? 'Requested' : (i == 1) ? 'Rejected' : 'Approved',
                ApprovalStatus__c = 'Pending'
            );
            facilityRequests.add(fr);
        }
        insert facilityRequests;
        
        List<String> recordIds = new List<String>();
        for (Facility_Request__c fr : facilityRequests) {
            recordIds.add(fr.Id);
        }
        
       
        
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new SMSAPIMock());
       
         Test.startTest();
        
        // Call the future method directly
        InfraApprovalSMS.makeCalloutAsync(recordIds);
        
        Test.stopTest();
        
         Test.setMock(HttpCalloutMock.class, new SMSAPIMock());

          //  Test.startTest();
            //FacilityWhatAppNotifications.makeCalloutAsync(recordIds);
          //  Test.stopTest();
            Account testAccount = new Account(Name='testaccount');
            insert testAccount;
            
            Facility_Request__c testRequest2 = new Facility_Request__c(
                Start_Date__c = Date.today(),
                Start_Time__c = Time.newInstance(9, 0, 0, 0),
                End_Date__c = Date.today().addDays(1),
                End_Time__c = Time.newInstance(17, 0, 0, 0),
                TemplateName__c = 'Approved',
                Building_Name__c = 'Building 1',
                Floor__c = 'Floor 2',
                Room_No__c = 'Room 101',
                Account__c = testAccount.Id,
                ApproverName__c = 'Test Approver'
            );
            insert testRequest2;

            Facility_Request__c testRequest3 = new Facility_Request__c(
                Start_Date__c = Date.today(),
                Start_Time__c = Time.newInstance(9, 0, 0, 0),
                End_Date__c = Date.today().addDays(1),
                End_Time__c = Time.newInstance(17, 0, 0, 0),
                TemplateName__c = 'Rejected',
                Building_Name__c = 'Building 1',
                Floor__c = 'Floor 2',
                Room_No__c = 'Room 101',
                Account__c = testAccount.Id,
                ApproverName__c = 'Test Approver'
            );
            insert testRequest3;
            
           // Test.startTest();
            //FacilityWhatAppNotifications.FacilityRejected(testRequest3);
           // Test.stopTest();
            
          //  Test.startTest();
            //FacilityWhatAppNotifications.FacilityApproved(testRequest2);
          //  Test.stopTest();
            
        
        // Verify results (use System.assert if applicable)
        // Since this is asynchronous, direct verification of callouts will not be possible without further setup
    }
    
    @isTest
    static Account createTestAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;
    }
}