@isTest
public class SLCM_HCMhstleSalRngANDApprvlAPI_Test {

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
    
    public class MockHttpFailureResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('HCM_SalaryRangeAPI')) {
                 System.debug('req--- ins>');
                res.setBody('{"Employee_Number":"12345", "Employee_Name":"John Doe", "Salary_Range":null,"Type":"Hostel"}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('ApprovalHierarchy')) {
                res.setBody('[]');                
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
            if (req.getEndpoint().contains('HCM_SalaryRangeAPI')) {
                 System.debug('req--- ins>');
                res.setBody('{"Employee_Number":"12345", "Employee_Name":"John Doe", "Salary_Range":1000.0 , "Type":"Hostel"}');
                res.setStatusCode(200);
            } 
            else if (req.getEndpoint().contains('ApprovalHierarchy')) {
               res.setBody('[{"Official_email": "ganesha@epeoplebc.com","Employee_Number": "REVA01463","Employee_Name": "Sanjay Gupta","Approver_type": "Reporting Manager"},{"Official_email": "dhanamjaya@gmail.com","Employee_Number": "REVA01463","Employee_Name": "Dhanamjaya M","Approver_type":"Admin Director"},{"Official_email": "chethan@gmail.com","Employee_Number": "REVA01463","Employee_Name": "Chethan A S","Approver_type": "HR Lead"}]');                
               res.setStatusCode(200);
            } 
            return res;
        }
    }

    @isTest
    static void testSLCM_HCMSEmptyResponese() {
        //method with empty response
        HCM_Endpoints__c mockEndpoint = new HCM_Endpoints__c(
            Name = 'Salary Range API',
            End_Point__c = 'https://test.salesforce.com/services/apexrest/HCM_SalaryRangeAPI/'
        );
        insert mockEndpoint;
        
        HCM_Endpoints__c approMockEndpoint = new HCM_Endpoints__c(
            Name = 'Approval hierarchy API',
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
            hed__WorkEmail__c = 'nonteacheeeing@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;
        
        Contact testContact2 = new Contact(
            FirstName = 'NonTeaching2',
            LastName = 'Staff2',
            Email = 'nonteach2ing@example.com',
            hed__WorkEmail__c = 'nont44eassssching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Male',
            Employee_Number__c = 'REVA01463',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact2;
 
        // Create a user for Hostel_Room_Request_For__c reference
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuserrrrr7bhdsjr888895@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            ContactId = testContact2.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        List<Reva_Hostel_Request__c> hostelRequests = new List<Reva_Hostel_Request__c>();
        Reva_Hostel_Request__c req = new Reva_Hostel_Request__c(
            Type__c = '2',
            HCM_Approval_Status__c = 'Deduction Request Initiated',
            Hostel_Room_Request_For__c = testContact.Id
        );
        hostelRequests.add(req);
        insert hostelRequests;
        hostelRequests[0].Employee_Salary__c =300.00;
        update hostelRequests;
        
          
        Test.setMock(HttpCalloutMock.class, new MockHttpEmptyResponse());
        Test.stopTest();
        
        List<Reva_Hostel_Request__c> updatedRequests = [
            SELECT Id, Employee_Salary__c, Reporting_Manager__c FROM Reva_Hostel_Request__c WHERE Id IN :hostelRequests
        ];
        System.assertEquals(null, updatedRequests[0].Reporting_Manager__c, 'Report manager as null.');
   }
    
     @isTest
    static void testSLCM_HCMfailureRes() {
        // method with failure logic to cover else part
        HCM_Endpoints__c mockEndpoint = new HCM_Endpoints__c(
            Name = 'Salary Range API',
            End_Point__c = 'https://test.salesforce.com/services/apexrest/HCM_SalaryRangeAPI/'
        );
        insert mockEndpoint;
        
        HCM_Endpoints__c approMockEndpoint = new HCM_Endpoints__c(
            Name = 'Approval hierarchy API',
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
            hed__WorkEmail__c = 'nonteassssching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;
        
        Contact testContact2 = new Contact(
            FirstName = 'NonTeaching2',
            LastName = 'Staff2',
            Email = 'nonteach2ing@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Male',
            hed__WorkEmail__c = 'nonteasssrrrsching@example.com',
            Employee_Number__c = 'REVA01463',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact2;
 
        // Create a user for Hostel_Room_Request_For__c reference
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuserrrrr7bhdsjr888872@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            ContactId = testContact2.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        List<Reva_Hostel_Request__c> hostelRequests = new List<Reva_Hostel_Request__c>();
        Reva_Hostel_Request__c req = new Reva_Hostel_Request__c(
            Type__c = '2',
            HCM_Approval_Status__c = 'Deduction Request Initiated',
            Hostel_Room_Request_For__c = testContact.Id
        );
        hostelRequests.add(req);
        insert hostelRequests;
        hostelRequests[0].Employee_Salary__c =300.00;
        update hostelRequests;
        Test.setMock(HttpCalloutMock.class, new MockHttpFailureResponse());
        Test.stopTest();

        List<Reva_Hostel_Request__c> updatedRequests = [
            SELECT Id, Employee_Salary__c, Reporting_Manager__c FROM Reva_Hostel_Request__c WHERE Id IN :hostelRequests
        ];
        System.assertEquals(null, updatedRequests[0].Reporting_Manager__c, 'Report manager as null.');
    } 
    
    @isTest
    static void testSLCM_HCMSucessAPI() {
        // method with success logic
        HCM_Endpoints__c mockEndpoint = new HCM_Endpoints__c(
            Name = 'Salary Range API',
            End_Point__c = 'https://test.salesforce.com/services/apexrest/HCM_SalaryRangeAPI/'
        );
        insert mockEndpoint;
        
       HCM_Endpoints__c approMockEndpoint = new HCM_Endpoints__c(
            Name = 'Approval hierarchy API',
            End_Point__c = 'https://rukminieducationalcharitabletrust--revdev.sandbox.my.salesforce.com/services/apexrest/ApprovalHierarchy/'
        );
        insert approMockEndpoint; 
        
         Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
         Id nonTeachingProfileId = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1].Id;
         Id Non_teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non Teaching').getRecordTypeId();
 
        Contact testContact = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            hed__WorkEmail__c = 'nontdddeassssching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;
        
        Contact testContact2 = new Contact(
            FirstName = 'NonTeaching2',
            LastName = 'Staff2',
            Email = 'nonteach2ing@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Male',
            Employee_Number__c = 'REVA01463',
            hed__WorkEmail__c = 'nonteach2455ing@example.com',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact2;
 
        // Create a user for Hostel_Room_Request_For__c reference
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuserrrrr7bhdsjr88881234@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            ContactId = testContact2.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        List<Reva_Hostel_Request__c> hostelRequests = new List<Reva_Hostel_Request__c>();
        Reva_Hostel_Request__c req = new Reva_Hostel_Request__c(
            Type__c = '2',
            HCM_Approval_Status__c = 'Deduction Request Initiated',
            Hostel_Room_Request_For__c = testContact.Id,
            Reva_Hostel_JoiningDate__c =  System.today()
        );
        hostelRequests.add(req);
        
        Test.startTest();
        insert hostelRequests;
      
        
        Test.stopTest();

        List<Reva_Hostel_Request__c> updatedRequests = [
            SELECT Id, Employee_Salary__c FROM Reva_Hostel_Request__c WHERE Id IN :hostelRequests
        ];
        System.assertEquals(1000.0, updatedRequests[0].Employee_Salary__c, 'Employee salary should be updated.');
    }
    
    public static testmethod void updateHCMhostelRevisedSalaryTest(){
    HCM_Endpoints__c mockEndpoint = new HCM_Endpoints__c(
            Name = 'Salary Range API',
            End_Point__c = 'https://test.salesforce.com/services/apexrest/HCM_SalaryRangeAPI/'
        );
        insert mockEndpoint;
    
        
         Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
         Id nonTeachingProfileId = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1].Id;
         Id Non_teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non Teaching').getRecordTypeId();
 
        Contact testContact = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            Employee_Number__c = '12345',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;
        
        Contact testContact2 = new Contact(
            FirstName = 'NonTeaching2',
            LastName = 'Staff2',
            hed__WorkEmail__c ='nonteach222ing@example.com',
            Email = 'nonteach2ing@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Male',
            Employee_Number__c = 'REVA01463',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact2;
 
        // Create a user for Hostel_Room_Request_For__c reference
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuserrrrr7bhdsjr8888001@test.com',
            Email = 'testuser6736@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            ContactId = testContact2.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        List<Reva_Hostel_Request__c> hostelRequests = new List<Reva_Hostel_Request__c>();
        Reva_Hostel_Request__c req = new Reva_Hostel_Request__c(
            Type__c = '2',
            Employee_Salary__c = 500.00,
            Status__c = 'Booked',
            Hostel_Room_Request_For__c = testContact.Id,
            Reva_Hostel_JoiningDate__c =  System.today()
        );
        hostelRequests.add(req);
        
        Test.startTest();
        insert hostelRequests;
      
        testContact.Salary_Revised_Date__c = System.Today()+1;  
        update testContact;
        Test.stopTest();

        List<Reva_Hostel_Request__c> updatedRequests = [
            SELECT Id, Employee_Salary__c ,Salary_Last_Revised_Date__c FROM Reva_Hostel_Request__c WHERE Id IN :hostelRequests
        ];
        System.assertEquals(1000.0, updatedRequests[0].Employee_Salary__c, 'Employee salary should be updated.');
       System.assertEquals(testContact.Salary_Revised_Date__c, updatedRequests[0].Salary_Last_Revised_Date__c, 'Updated date ');
    
    }
}