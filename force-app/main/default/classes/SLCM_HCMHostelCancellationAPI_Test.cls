@istest
public class SLCM_HCMHostelCancellationAPI_Test {

    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug('req--- ins>');
            List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c where Hostel_Room_Request_For__r.Employee_Number__c = 'REVA01462' LIMIT 1];
            String hostlreqId = hostelReqs[0].Id;
            res.setBody('[{"Status": "Success", "SLCM_Record_Id": "' + hostlreqId + '", "ErrorMessage": null}]');
            res.setStatusCode(200);
            return res;
        }
    }
    
     public class MockHttpfailureResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug('req--- ins>');
            List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c where Hostel_Room_Request_For__r.Employee_Number__c = 'REVA01462' LIMIT 1];
            String hostlreqId = hostelReqs[0].Id;
            res.setBody('[{"Status": "Failed", "SLCM_Record_Id": "' + hostlreqId + '", "ErrorMessage": "Failed-invalid request"}]');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockHttpEmptyResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug('req--- ins>');
            res.setBody('[]');
            res.setStatusCode(400);
            return res;
        }
    }
    
    public static testmethod void SLCM_HCMHostelCancellationSucess(){
        
        HCM_Endpoints__c approMockEndpoint = new HCM_Endpoints__c(
            Name = 'Deduction Cancellation API',
            End_Point__c = 'https://rukminieducationalcharitabletrust--revdev.sandbox.my.salesforce.com/services/apexrest/ApprovalHierarchy/'
        );
        insert approMockEndpoint;         
        Test.startTest();      
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

        
        Reva_Hostel_Room__c hostelroom = new Reva_Hostel_Room__c(
            Room_Type__c = 'Student',
            Room_Category__c = '1 Eng',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A'
        );
        insert hostelroom ;
        
        
        List<Reva_Hostel_Request__c> hostelRequests = new List<Reva_Hostel_Request__c>();
        Reva_Hostel_Request__c req = new Reva_Hostel_Request__c(
            Type__c = '1',
            HCM_Approval_Status__c = 'Deduction Approved',
            Hostel_Room_Request_For__c = testContact.Id,
            Vacating_Request__c = 'Approved',
            Status__c = 'Vacate Approved',
            Reva_Hostel_JoiningDate__c = system.today()-1,
            Is_HCM_Salary_Deduction_Cancelled__c = false,
            Reva_Hostel_Room__c = hostelroom.Id,
            Is_HCM_Salary_Deduction_CNF__c = true,
            Employee_Salary__c = 3500,
            Approved_by_Hostel_Office__c = true,
            RevaHostelVacatingDate__c = System.today()
        );
        hostelRequests.add(req);
        insert hostelRequests;
        
         
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        update hostelRequests;
        Database.executeBatch(new SLCM_HCM_HstlReqRoomCancelCNFBatch(),1);
        Test.stopTest();
        
    }
    @isTest
     public static  void SLCM_HCMHostelCancellationFailure(){
        
        HCM_Endpoints__c approMockEndpoint = new HCM_Endpoints__c(
            Name = 'Deduction Cancellation API',
            End_Point__c = 'https://rukminieducationalcharitabletrust--revdev.sandbox.my.salesforce.com/services/apexrest/ApprovalHierarchy/'
        );
        insert approMockEndpoint;         
        
        Profile nonTeachingProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
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
        
        User nonTeachingUser = new User(
            Alias = 'nontea',
            Email = 'nonteachinguser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NonTeachingUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = nonTeachingProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'nonteachinguserhcm001@example.com',
            ContactId = testContact.Id
        );
        insert nonTeachingUser;
        
        Reva_Hostel_Room__c hostelroom = new Reva_Hostel_Room__c(
            Room_Type__c = 'Student',
            Room_Category__c = '1 Eng',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A'
        );
        insert hostelroom ;
        
        
        List<Reva_Hostel_Request__c> hostelRequests = new List<Reva_Hostel_Request__c>();
        Reva_Hostel_Request__c req = new Reva_Hostel_Request__c(
            Type__c = '1',
            HCM_Approval_Status__c = 'Deduction Approved',
            Hostel_Room_Request_For__c = testContact.Id,
            Vacating_Request__c = 'Approved',
            Status__c = 'Vacate Approved',
            Reva_Hostel_JoiningDate__c = system.today()-1,
            Is_HCM_Salary_Deduction_Cancelled__c = false,
            Reva_Hostel_Room__c = hostelroom.Id,
            Is_HCM_Salary_Deduction_CNF__c = true,
            Employee_Salary__c = 3500,
            Approved_by_Hostel_Office__c = true,
            RevaHostelVacatingDate__c = System.today()
        );
        hostelRequests.add(req);
        insert hostelRequests;
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpfailureResponse());
        update hostelRequests;
         Database.executeBatch(new SLCM_HCM_HstlReqRoomCancelCNFBatch(),1);
        Test.stopTest();
        
    }
    @isTest
     public static  void SLCM_HCMHostelCancellationEmpty(){
        
        HCM_Endpoints__c approMockEndpoint = new HCM_Endpoints__c(
            Name = 'Deduction Cancellation API',
            End_Point__c = 'https://rukminieducationalcharitabletrust--revdev.sandbox.my.salesforce.com/services/apexrest/ApprovalHierarchy/'
        );
        insert approMockEndpoint;         
        
        Profile nonTeachingProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
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
        
        User nonTeachingUser = new User(
            Alias = 'nontea',
            Email = 'nonteachinguser001hstl@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NonTeachingUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = nonTeachingProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'nonteachinguserhcm001@example.com',
            ContactId = testContact.Id
        );
        insert nonTeachingUser;
        
        Reva_Hostel_Room__c hostelroom = new Reva_Hostel_Room__c(
            Room_Type__c = 'Student',
            Room_Category__c = '1 Eng',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A'
        );
        insert hostelroom ;
        
        
        List<Reva_Hostel_Request__c> hostelRequests = new List<Reva_Hostel_Request__c>();
        Reva_Hostel_Request__c req = new Reva_Hostel_Request__c(
            Type__c = '1',
            HCM_Approval_Status__c = 'Deduction Approved',
            Hostel_Room_Request_For__c = testContact.Id,
            Vacating_Request__c = 'Approved',
            Status__c = 'Vacate Approved',
            Reva_Hostel_JoiningDate__c = system.today()-1,
            Is_HCM_Salary_Deduction_Cancelled__c = false,
            Reva_Hostel_Room__c = hostelroom.Id,
            Is_HCM_Salary_Deduction_CNF__c = true,
            Employee_Salary__c = 3500,
            RevaHostelVacatingDate__c = System.today()
        );
        hostelRequests.add(req);
        insert hostelRequests;
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpEmptyResponse());
        update hostelRequests;
          Database.executeBatch(new SLCM_HCM_HstlReqRoomCancelCNFBatch(),1);
        Test.stopTest();
        
    }
    
     @isTest
     public static  void SLCM_HCMHostelCancellationEmpty1(){
        
        HCM_Endpoints__c approMockEndpoint = new HCM_Endpoints__c(
            Name = 'Deduction Cancellation API',
            End_Point__c = 'https://rukminieducationalcharitabletrust--revdev.sandbox.my.salesforce.com/services/apexrest/ApprovalHierarchy/'
        );
        insert approMockEndpoint;         
        
        Profile nonTeachingProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
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
        
        User nonTeachingUser = new User(
            Alias = 'nontea',
            Email = 'nonteachinguser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NonTeachingUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = nonTeachingProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'nonteachinguserhcm005@example.com',
            ContactId = testContact.Id
        );
        insert nonTeachingUser;
        
        Reva_Hostel_Room__c hostelroom = new Reva_Hostel_Room__c(
            Room_Type__c = 'Student',
            Room_Category__c = '1 Eng',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A'
        );
        insert hostelroom ;
        
        
        List<Reva_Hostel_Request__c> hostelRequests = new List<Reva_Hostel_Request__c>();
        Reva_Hostel_Request__c req = new Reva_Hostel_Request__c(
            Type__c = '1',
            HCM_Approval_Status__c = 'Deduction Approved',
            Hostel_Room_Request_For__c = testContact.Id,
            Vacating_Request__c = 'Approved',
            Status__c = 'Vacate Approved',
            Reva_Hostel_JoiningDate__c = system.today()-1,
            Is_HCM_Salary_Deduction_Cancelled__c = false,
            Reva_Hostel_Room__c = hostelroom.Id,
            Is_HCM_Salary_Deduction_CNF__c = true,
            Employee_Salary__c = 3500,
            Approved_by_Hostel_Office__c = true,
            RevaHostelVacatingDate__c = System.today()
        );
        hostelRequests.add(req);
        insert hostelRequests;
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpEmptyResponse());
        update hostelRequests;
          Database.executeBatch(new SLCM_HCM_HstlReqRoomCancelCNFBatch(),1);
        Test.stopTest();
        
    }
    
}