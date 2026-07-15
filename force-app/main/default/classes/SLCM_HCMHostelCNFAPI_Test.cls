@isTest
public class SLCM_HCMHostelCNFAPI_Test {

    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('TransportHostelQuarters')) {
                System.debug('req--- ins>');
                List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
                String hostlreqId = hostelReqs[0].Id;
                res.setBody('[{"Status": "Success", "SLCM_Record_Id": "' + hostlreqId + '", "ErrorMessage": null}]');
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
                List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
                String hostlreqId = hostelReqs[0].Id;
                res.setBody('[{"Status": "Failed", "SLCM_Record_Id": "' + hostlreqId + '", "ErrorMessage": "invalid request-failure"}]');

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
    @TestSetup
    public static void setupTestData() {
        // Create test data for custom settings HCM_Endpoints__c
        HCM_Endpoints__c hcmEndpoint = new HCM_Endpoints__c();
        hcmEndpoint.Name = 'Hostel Quarters API';
        hcmEndpoint.End_Point__c = 'https://rukminieducationalcharitabletrust--revdev.sandbox.my.salesforce.com/services/apexrest/TransportHostelQuarters';
        insert hcmEndpoint;
        
         Id nonTeachingProfileId = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1].Id;
         Id Non_teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non Teaching').getRecordTypeId();

        Contact testContact = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;

        // Create a user for Hostel_Room_Request_For__c reference
        

        
        Reva_Hostel_Room__c hostelroom = new Reva_Hostel_Room__c(
        Room_Type__c = 'Student',
        Room_Category__c = '1 Eng',
        Dormitory_Type__c = 'Boys',
            Block__c = 'A'
        );
        insert hostelroom ;
 
        // Create a Reva_Hostel_Request__c record with required fields
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c();
        hostelRequest.Hostel_Room_Request_For__c = testContact.Id;
        hostelRequest.Employee_Salary__c = 5000;
        hostelRequest.Is_HCM_Salary_Deduction_CNF__c = false;
        hostelRequest.Approved_by_Hostel_Office__c = true;
        hostelRequest.Status__c = 'Approved';
      //  hostelRequest.Reva_Hostel_Room__c = hostelroom.Id;
        hostelRequest.Reva_Hostel_JoiningDate__c = Date.today();
        hostelRequest.Type__c = '4ExtraSpace';
        insert hostelRequest;
        
   
    }

    @IsTest
    static void testSendApprovedConfirmationHCM_Success(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        hostelReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
        update hostelReqs;
        Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
        Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
     @IsTest
    static void testSendApprovedConfirmationHCM_Success2Sharing(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        hostelReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
        hostelReqs[0].Type__c = '2';
        update hostelReqs;
        Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
        Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    @IsTest
    static void testSendApprovedConfirmationHCM_Success3Sharing(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        hostelReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
        hostelReqs[0].Type__c = '3';
        update hostelReqs;
        Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
        Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    @IsTest
    static void testSendApprovedConfirmationHCM_Success4Sharing(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        hostelReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
        hostelReqs[0].Type__c = '4';
        update hostelReqs;
        Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
        Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    @IsTest
    static void testSendApprovedConfirmationHCM_Success6Sharing(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        hostelReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
        hostelReqs[0].Type__c = '6';
        update hostelReqs;
        Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
        Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    @IsTest
    static void testSendApprovedConfirmationHCM_Success8Sharing(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        hostelReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
        hostelReqs[0].Type__c = '8';
        update hostelReqs;
        Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
        Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    @IsTest
     static void testSendApprovedConfirmationHCM_Success1Sharing(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        hostelReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
         hostelReqs[0].Type__c = '1';
        update hostelReqs;
        Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
        Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    
    
     @IsTest
    static void testSendApprovedConfirmationHCM_Failed(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockFailedHttpResponse());
        Test.startTest();
        hostelReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
        update hostelReqs;
        Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
        Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c,HCM_Salary_Approval_CNF_Error__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        System.assertEquals(false, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
        System.assertEquals('invalid request-failure OR Contact your Admin because deduction confirmation failed by HCM', updatedRequest.HCM_Salary_Approval_CNF_Error__c);
    }
    
     @IsTest
    static void testSendApprovedConfirmationHCM_Failed1(){
        Contact co = [SELECT Id ,Employee_Number__c FROM Contact LIMIT 1];
         co.Employee_Number__c = null;
        update co;
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id,Hostel_Room_Request_For__c FROM Reva_Hostel_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockCatchblockHttpResponse());
        Test.startTest();
        hostelReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
       // hostelReqs[0].Hostel_Room_Request_For__c = co.Id ;
        update hostelReqs;
         Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
    }
     @IsTest
    static void testSendApprovedConfirmationHCM_EmptyReq(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockCatchblockHttpResponse());
        Test.startTest();
        hostelReqs[0].HCM_Approval_Status__c = 'Deduction Approved';
        update hostelReqs;
         Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
    }
    
@isTest    
 static void ReqRoomAllotedCNFtest() {
        // Create test data for custom settings HCM_Endpoints__c
        HCM_Endpoints__c hcmEndpoint = new HCM_Endpoints__c();
        hcmEndpoint.Name = 'Hostel Quarters API';
        hcmEndpoint.End_Point__c = 'https://rukminieducationalcharitabletrust--revdev.sandbox.my.salesforce.com/services/apexrest/TransportHostelQuarters';
        insert hcmEndpoint;
        
         Id nonTeachingProfileId = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1].Id;
         Id Non_teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non Teaching').getRecordTypeId();

        Contact testContact = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;
Profile p = [SELECT Id FROM Profile WHERE Name = 'Professor'];
      User objUser = new User(
            LastName = 'Te',
            FirstName ='testing',
            alias = 'testng',
            Email = 'test@unitingambitionn.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = p.Id,
            
            UserName='test@unitingambitions.com',
            EmployeeNumber ='EP1341'
        );
        
        insert objUser;
        

        
        Reva_Hostel_Room__c hostelroom = new Reva_Hostel_Room__c(
        Room_Type__c = 'Student',
        Room_Category__c = '1 Eng',
        Dormitory_Type__c = 'Boys',
            Block__c = 'A'
        );
        insert hostelroom ;
 
        // Create a Reva_Hostel_Request__c record with required fields
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c();
        hostelRequest.Hostel_Room_Request_For__c = testContact.Id;
        hostelRequest.Employee_Salary__c = 5000;
        hostelRequest.Hostel_Officer__c = objUser.Id;
        hostelRequest.HR_Lead__c = objUser.Id;
        hostelRequest.Admin_Director__c = objUser.Id;
        hostelRequest.Reporting_Manager__c = objUser.Id;
        hostelRequest.Approved_by_Hostel_Office__c = true;
        hostelRequest.Status__c = 'Room Allotted';
        hostelRequest.Is_HCM_Salary_Deduction_CNF__c = true;        
        hostelRequest.Reva_Hostel_JoiningDate__c = Date.today();
        hostelRequest.Type__c = '4ExtraSpace';
        hostelRequest.HCM_Approval_Status__c = 'Deduction Approved';
        hostelRequest.Approved_by_HR_Lead__c = true;
       // hostelRequest.Salary_Last_Revised_Date__c = System.today();
        insert hostelRequest;
        
       Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        hostelRequest.Salary_Last_Revised_Date__c = System.today();
        hostelRequest.Employee_Salary__c = 50000;
       
        
   
        update hostelRequest;
        Database.executeBatch(new SLCM_HCM_HstlReqRoomAllotCNFBatch(),1);
        Test.stopTest();
        Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelRequest.Id];
        System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);   
    }

}