@isTest
public class HCM_SLCM_Salary_Deduction_API_Test {
    
    @isTest
    static void testValidSalaryDeductionHostel() {
        
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
        Contact testContact2 = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact2;
        
        // Create a user for Hostel_Room_Request_For__c reference
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuserrrrr7bhdsjrsal001@test.com',
            Email = 'testusersalded001@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            ContactId =testContact2.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        
        
        List<Reva_Hostel_Request__c> hostelRequests = new List<Reva_Hostel_Request__c>();
        Reva_Hostel_Request__c req = new Reva_Hostel_Request__c(
            Type__c = '1',
            Is_HCM_Salary_Deduction_CNF__c = true,
            Admin_Director__c = testUser.Id,
            HR_Lead__c = testUser.Id,
            Reporting_Manager__c = testUser.Id,
            Hostel_Officer__c = testUser.Id,
            Hostel_Room_Request_For__c = testContact.Id
        );
        hostelRequests.add(req);
        
        // Insert hostel requests
        insert hostelRequests;
        
        String requestBody = '[{"Employee_Number": "REVA01462", "Employee_Name": "John Doe", "Type": "Hostel", "HCM_Record_Id": "HCM123", "Fiscal_Year": "2024", "Fiscal_Month": "09", "Actual_Deduction_Amount": 500.00, "Current_Deduction_Amount": 500.00}]';
        
        // Set the mock request body
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        RestContext.response = new RestResponse();
        
        // Call the API method
        Test.startTest();
        List<HCM_SLCM_Salary_Deduction_API.ResponseWrapper> responses = HCM_SLCM_Salary_Deduction_API.doPost();
        Test.stopTest();
        
        // Verify the response
        System.assertEquals(1, responses.size(), 'There should be one response.');
        HCM_SLCM_Salary_Deduction_API.ResponseWrapper response = responses[0];
        System.assertEquals('HCM123', response.HCM_Record_Id, 'HCM_Record_Id should match.');
        System.assertEquals(null, response.ErrorMessage, 'ErrorMessage should be null.');
        
        // Verify the record was created
        List<HCM_Monthly_Salary_Deduction__c> deductions = [SELECT Id, Employee_Name__c, Employee_Number__c FROM HCM_Monthly_Salary_Deduction__c WHERE HCM_Record_Id__c = 'HCM123'];
        System.assertEquals(1, deductions.size(), 'A salary deduction record should have been created.');
        System.assertEquals('John Doe', deductions[0].Employee_Name__c, 'Employee name should match.');
    }
    
    @isTest
    static void testInvalidEmployeeNumber() {
        // Create valid Salary Deduction request JSON with an invalid employee number
        String requestBody = '[{"Employee_Number": "99999", "Employee_Name": "Invalid User", "Type": "Hostel", "HCM_Record_Id": "HCM999", "Fiscal_Year": "2024", "Fiscal_Month": "09", "Actual_Deduction_Amount": 500.00, "Current_Deduction_Amount": 500.00}]';
        
        // Set the mock request body
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        RestContext.response = new RestResponse();
        
        // Call the API method
        Test.startTest();
        List<HCM_SLCM_Salary_Deduction_API.ResponseWrapper> responses = HCM_SLCM_Salary_Deduction_API.doPost();
        Test.stopTest();
        
        // Verify the response
        System.assertEquals(1, responses.size(), 'There should be one response.');
        HCM_SLCM_Salary_Deduction_API.ResponseWrapper response = responses[0];
        System.assertEquals('Failed', response.Status, 'Response should indicate failure.');
        System.assertEquals('Employee number not found In Hostel OR Salary deduction not yet confirmed by HCM', response.ErrorMessage, 'ErrorMessage should indicate employee not found.');
    }
    
    @isTest
    static void testInvalidJSON() {
        // Set invalid JSON in the request body
        String invalidRequestBody = '{"Invalid JSON Format}';
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(invalidRequestBody);
        RestContext.response = new RestResponse();
        
        // Call the API method
        Test.startTest();
        List<HCM_SLCM_Salary_Deduction_API.ResponseWrapper> responses = HCM_SLCM_Salary_Deduction_API.doPost();
        Test.stopTest();
        
        // Verify the response
        System.assertEquals(1, responses.size(), 'There should be one response.');
        HCM_SLCM_Salary_Deduction_API.ResponseWrapper response = responses[0];
        System.assertEquals('Failed', response.Status, 'Response should indicate failure.');
        System.assertEquals('Invalid JSON format', response.ErrorMessage, 'ErrorMessage should indicate invalid JSON.');
    }
    
    @isTest
    static void testValidSalaryDeductionQuarter() {
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
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testu7483serrrrr7bhdsjrsal002@test.com',
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
        // Create test data for Staff_Quarters_Request__c
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
        quaterRequest.Status__c = 'Room Allotted';
        quaterRequest.Type__c=  '2 BHK';
        quaterRequest.Staff_Quarters_Room__c = stRooms.Id;
        // quaterRequest.HCM_Approval_Status__c = 'Deduction Approved';
        quaterRequest.Staff_Quarters_Joining_Date__c = Date.today();
        quaterRequest.Quarters_Request_Type__c = 'NonTeachingStaff';
        quaterRequest.HR_Lead__c = testUser.Id;
        quaterRequest.Reporting_Manager__c = testUser.Id;
        quaterRequest.Hostel_Officer__c = testUser.Id;
        quaterRequest.Admin_Director__c = testUser.Id;
       
        insert quaterRequest;
        // Create valid Salary Deduction request JSON for Quarters
        String requestBody = '[{"Employee_Number": "REVA01462", "Employee_Name": "Jane Doe", "Type": "Quarter", "HCM_Record_Id": "HCM543", "Fiscal_Year": "2024", "Fiscal_Month": "09", "Actual_Deduction_Amount": 700.00, "Current_Deduction_Amount": 700.00}]';
        
        // Set the mock request body
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        RestContext.response = new RestResponse();
        
        // Call the API method
        Test.startTest();
        List<HCM_SLCM_Salary_Deduction_API.ResponseWrapper> responses = HCM_SLCM_Salary_Deduction_API.doPost();
        Test.stopTest();
        
        // Verify the response
        System.assertEquals(1, responses.size(), 'There should be one response.');
        HCM_SLCM_Salary_Deduction_API.ResponseWrapper response = responses[0];
        
        System.assertEquals('HCM543', response.HCM_Record_Id, 'HCM_Record_Id should match.');
        //System.assertEquals(null, response.ErrorMessage, 'ErrorMessage should be null.');
        
        // Verify the record was created
        List<HCM_Monthly_Salary_Deduction__c> deductions = [SELECT Id, Employee_Name__c, Employee_Number__c FROM HCM_Monthly_Salary_Deduction__c WHERE HCM_Record_Id__c = 'HCM543'];
        System.assertEquals(1, deductions.size(), 'A salary deduction record should have been created.');
        System.assertEquals('Jane Doe', deductions[0].Employee_Name__c, 'Employee name should match.');
    }
}