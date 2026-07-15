@isTest
public class SLCM_HCM_QuaterApprvlAPI_Test {
    
    
    public class MockHttpFailureResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('HCM_SalaryRangeAPI')) {
                System.debug('req--- ins>');
                res.setBody('{"Employee_Number":"12345", "Employee_Name":"John Doe", "Salary_Range":null}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('ApprovalHierarchy')) {
                res.setBody('[]');                
                res.setStatusCode(200);
            }
            return res;
        }
    }
    
    public class MockHttpEmptyResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('HCM_SalaryRangeAPI')) {
                System.debug('req--- ins>');
                res.setBody('');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('ApprovalHierarchy')) {
                res.setBody('');                
                res.setStatusCode(200);
            }
            return res;
        }
    }
    
    public class MockHttpcatcheResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('HCM_SalaryRangeAPI')) {
                System.debug('req--- ins>');
                res.setBody('{"Employee_Number":"12345", "Employee_Name":"John Doe", "Salary_Range":1000.0}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('ApprovalHierarchy')) {
                res.setBody('[{"Official_email": "ganesha@epeoplebc.com","Employee_Number": "REVA01462","Employee_Name": "Sanjay Gupta","Approver_type": "Reporting Manager"},{"Official_email": "dhanamjaya@gmail.com","Employee_Number": "REVA01462","Employee_Name": "Dhanamjaya M","Approver_type":"Admin Director"},{"Official_email": "chethan@gmail.com","Employee_Number": "REVA01462","Employee_Name": "Chethan A S","Approver_type": "HR Lead"}]');                
                res.setStatusCode(200);
            }
            return res;
        }
    }
    
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
             if (req.getEndpoint().contains('ApprovalHierarchy')) {
                res.setBody('[{"Official_email": "ganesha@epeoplebc.com","Employee_Number": "REVA014622","Employee_Name": "Sanjay Gupta","Approver_type": "Reporting Manager"},{"Official_email": "dhanamjaya@gmail.com","Employee_Number": "REVA014622","Employee_Name": "Dhanamjaya M","Approver_type":"Admin Director"},{"Official_email": "chethan@gmail.com","Employee_Number": "REVA014622","Employee_Name": "Chethan A S","Approver_type": "HR Lead"}]');                
                res.setStatusCode(200);
            }
            return res;
        }
    }
    @testSetup
    static void testSetup(){
       
        
        HCM_Endpoints__c approMockEndpoint = new HCM_Endpoints__c(
            Name = 'Approval hierarchy API',
            End_Point__c = 'https://rukminieducationalcharitabletrust--revdev.sandbox.my.salesforce.com/services/apexrest/ApprovalHierarchy/'
        );
        insert approMockEndpoint; 
        
    }
    
    
    @isTest
    static void testFailureResponse() {
        // Insert mock endpoint'
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
            hed__WorkEmail__c = 'nonteaching@example.com',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;
        
        // Create a user for Hostel_Room_Request_For__c reference
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'teyy4674stuserrrrr7bhdsjr0128@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            ContactId =testContact.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        List<Staff_Quarters_Request__c> quarterRequests = new List<Staff_Quarters_Request__c>();
        Staff_Quarters_Request__c req = new Staff_Quarters_Request__c(
            Type__c = '2 BHK',
            Quarters_Request_Type__c = 'TeachingStaff',
            HCM_Approval_Status__c = 'Deduction Request Initiated',
            Quarter_Request_For__c = testContact.Id,
            Status__c = 'Request Submitted',
             Employee_Salary__c = 1000
        );
        quarterRequests.add(req);
        insert quarterRequests;
        quarterRequests[0].Employee_Salary__c =300.00;
        update quarterRequests;
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpFailureResponse());
        Test.stopTest();
        
        // Verify that the Employee Salary was updated correctly
        List<Staff_Quarters_Request__c> updatedRequests = [
            SELECT Id, Employee_Salary__c,Reporting_Manager__c FROM Staff_Quarters_Request__c WHERE Id IN :quarterRequests
        ];
        
        System.assertEquals(null, updatedRequests[0].Reporting_Manager__c, 'Reporing Manager as null');
    }
    
    @isTest
    static void testEmptyResponse() {
        // Insert mock endpoint'
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
            hed__WorkEmail__c = 'nonteaching@example.com',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;
        
        // Create a user for Hostel_Room_Request_For__c reference
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'teyy4674stuserrrrr7bhdsjr0026@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            ContactId =testContact.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        List<Staff_Quarters_Request__c> quarterRequests = new List<Staff_Quarters_Request__c>();
        Staff_Quarters_Request__c req = new Staff_Quarters_Request__c(
            Type__c = '2 BHK',
            Quarters_Request_Type__c = 'TeachingStaff',
            HCM_Approval_Status__c = 'Deduction Request Initiated',
            Quarter_Request_For__c = testContact.Id,
            Status__c = 'Request Submitted',
            Employee_Salary__c = 1000
        );
        quarterRequests.add(req);
        insert quarterRequests;
        quarterRequests[0].Employee_Salary__c =300.00;
        update quarterRequests;
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpEmptyResponse());
        Test.stopTest();
        
        // Verify that the Employee Salary was updated correctly
        List<Staff_Quarters_Request__c> updatedRequests = [
            SELECT Id, Employee_Salary__c,Reporting_Manager__c FROM Staff_Quarters_Request__c WHERE Id IN :quarterRequests
        ];
        
        System.assertEquals(null, updatedRequests[0].Reporting_Manager__c, 'Reporing Manager as null');
    }
    
    
    @isTest
   static void testSucessResponse() {
        Id nonTeachingProfileId = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1].Id;
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
        
        Contact testContact2 = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching2@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            hed__WorkEmail__c = 'nonteaching2@example.com',
            Employee_Number__c = 'REVA014622',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact2;
        
        // Create a user for Hostel_Room_Request_For__c reference
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testusehhd547rrrrr7bhdsjr@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            EmployeeNumber = 'REVA014622',
            ContactId =testContact2.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
   
        
        List<Staff_Quarters_Request__c> quarterRequests = new List<Staff_Quarters_Request__c>();
        Staff_Quarters_Request__c req = new Staff_Quarters_Request__c(
            Type__c = '2 BHK',
            Quarters_Request_Type__c = 'TeachingStaff',
            HCM_Approval_Status__c = 'Deduction Request Initiated',
            Quarter_Request_For__c = testContact.Id,
            Status__c = 'Request Submitted',
            Employee_Salary__c = 1000
        );
        quarterRequests.add(req);
        
       
        insert quarterRequests;
        
       
        Test.startTest();
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.stopTest();
        
        // Verify that the Employee Salary was updated correctly
        List<Staff_Quarters_Request__c> updatedRequests = [
            SELECT Id, Employee_Salary__c FROM Staff_Quarters_Request__c WHERE Id IN :quarterRequests
        ];
        
        System.assertEquals(1000.0, updatedRequests[0].Employee_Salary__c, 'Employee salary should be updated.');
    } 
    
    

    
}