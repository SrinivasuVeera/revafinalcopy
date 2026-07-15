@istest
public class SLCM_HCMQuarterCancellationAPI_Test {

     public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('TransportHostelQuarters')) {
                System.debug('req--- ins>');
                List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id FROM Staff_Quarters_Request__c LIMIT 1];
                String quaterreqId = quaterReqs[0].Id;
                res.setBody('[{"Status": "Success", "SLCM_Record_Id": "' + quaterreqId + '", "ErrorMessage": null}]');

                res.setStatusCode(200);
            } else{
                res.setBody('{"error":"Invalid Request"}');
                res.setStatusCode(400);
            }
            return res;
        }
    }
    
     public class MockFailedHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('TransportHostelQuarters')) {
                System.debug('req--- ins>');
                List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id FROM Staff_Quarters_Request__c LIMIT 1];
                String quaterReqId = quaterReqs[0].Id;
                res.setBody('[{"Status": "Failed", "SLCM_Record_Id": "' + quaterReqId + '", "ErrorMessage": "invalid request-failure"}]');

                res.setStatusCode(200);
            } else{
                res.setBody('{"error":"Invalid Request"}');
                res.setStatusCode(400);
            }
            return res;
        }
    }
    
    public class MockCatchblockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('TransportHostelQuarters')) {
                System.debug('req--- ins>');
                res.setBody('');                 
                res.setStatusCode(200);
            } else{
                res.setBody('{"error":"Invalid Request"}');
                res.setStatusCode(400);
            }
            return res;
        }
    }
    
     public class MockCatchblockHttpResponse1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('TransportHostelQuarters')) {
                System.debug('req--- ins>');
                res.setBody('[{"Status": "Failed"}]');               
                res.setStatusCode(200);
            } else{
                res.setBody('{"error":"Invalid Request"}');
                res.setStatusCode(400);
            }
            return res;
        }
    }
    
    @TestSetup
    public static void setupTestData() {
        // Create test data for custom settings HCM_Endpoints__c
        HCM_Endpoints__c hcmEndpoint = new HCM_Endpoints__c();
        hcmEndpoint.Name = 'Deduction Cancellation API';
        hcmEndpoint.End_Point__c = 'https://rukminieducationalcharitabletrust--revdev.sandbox.my.salesforce.com/services/apexrest/TransportHostelQuarters';
        insert hcmEndpoint;
        
         Id Non_teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non Teaching').getRecordTypeId();

        Contact testContact = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            hed__WorkEmail__c = 'nonteaching@example.com',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;

        // Create a user for Hostel_Room_Request_For__c reference
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuserrrrrrgolive002@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LanguageLocaleKey = 'en_US',
            EmployeeNumber= 'REVA01462'
        );
       // insert testUser;
       Staff_Quarters_Room__c stRooms = new Staff_Quarters_Room__c();
        stRooms.Floor__c ='Ground Floor';
        stRooms.Availability__c = true;
        stRooms.Type__c ='2 BHK';
        insert stRooms;
        
        // Create a Reva_Hostel_Request__c record with required fields
        Staff_Quarters_Request__c quaterRequest = new Staff_Quarters_Request__c();
        quaterRequest.Quarter_Request_For__c = testContact.Id;
        quaterRequest.Employee_Salary__c = 5000;
        quaterRequest.Is_HCM_Salary_Deduction_CNF__c = true;
        quaterRequest.Approved_by_Hostel_Office__c = true;
        quaterRequest.Status__c = 'Vacation Approved';
        quaterRequest.Staff_Quarters_Room__c = stRooms.Id;
        quaterRequest.Type__c ='2 BHK';
        quaterRequest.HCM_Approval_Status__c = 'Deduction Approved';
        quaterRequest.Staff_Quarters_Joining_Date__c = Date.today();
        quaterRequest.Quarters_Request_Type__c = 'NonTeachingStaff';
        quaterRequest.Cancellation_Approved_Date__c = system.today();
        quaterRequest.Vacation_Date__c = system.today();
        insert quaterRequest;
        
                                      
    }

    @IsTest
    static void testSendApprovedConfirmationHCM_Success(){
        List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id ,HCM_Approval_Status__c FROM Staff_Quarters_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        quaterReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
        update quaterReqs;
         Database.executeBatch(new SLCM_HCM_QuarterReqCancelCNFBatch(),1);
        Test.stopTest();
        Staff_Quarters_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Staff_Quarters_Request__c WHERE Id = :quaterReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    
     @IsTest
    static void testSendApprovedConfirmationHCM_Failed(){
        List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id FROM Staff_Quarters_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockFailedHttpResponse());
        Test.startTest();
        Database.executeBatch(new SLCM_HCM_QuarterReqCancelCNFBatch(),1);
        Test.stopTest();
       
        Staff_Quarters_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c,HCM_Salary_Approval_CNF_Error__c FROM Staff_Quarters_Request__c WHERE Id = :quaterReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
        System.assertEquals(null, updatedRequest.HCM_Salary_Approval_CNF_Error__c);
    }
    
     @IsTest
    static void testSendApprovedConfirmationHCM_Failed1(){
        List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id FROM Staff_Quarters_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockCatchblockHttpResponse());
        Test.startTest();
        Database.executeBatch(new SLCM_HCM_QuarterReqCancelCNFBatch(),1);
        Test.stopTest();
        
         Staff_Quarters_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c,HCM_Salary_Approval_CNF_Error__c FROM Staff_Quarters_Request__c WHERE Id = :quaterReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }

     @IsTest
    static void testSendApprovedConfirmationHCM_Failed2(){
        List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id FROM Staff_Quarters_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockCatchblockHttpResponse());
        Test.startTest();
        SLCM_HCMQuarterCancellationAPI.sendApprovedCancellationToHCM(null);
        Test.stopTest();
        
         Staff_Quarters_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c,HCM_Salary_Approval_CNF_Error__c FROM Staff_Quarters_Request__c WHERE Id = :quaterReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    
     @IsTest
    static void testSendApprovedConfirmationHCM_Failed3(){
        List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id FROM Staff_Quarters_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockCatchblockHttpResponse1());
        Test.startTest();
 Database.executeBatch(new SLCM_HCM_QuarterReqCancelCNFBatch(),1);
        Test.stopTest();
        
    }
    
}