@isTest
public class SLCM_updateEmpSalaryInQuarterBatchTest {
    
    public class MockHttpResponsesuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('TransportHostelQuarters')) {
                System.debug('req--- ins>');
                List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id FROM Staff_Quarters_Request__c];
                String quaterreqId = quaterReqs[1].Id;
                res.setBody('[{"Status": "Success", "SLCM_Record_Id": "' + quaterreqId + '", "ErrorMessage": null}]');
                
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
        Contact testContact1 = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact1;
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'teyy4674stuserrrrr7bhdsjr852test@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            ContactId =testContact1.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
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
        quaterRequest.Type__c ='2 BHK';
        quaterRequest.Staff_Quarters_Room__c = stRooms.Id;
        quaterRequest.HCM_Approval_Status__c = 'Deduction Approved';
        quaterRequest.Staff_Quarters_Joining_Date__c = Date.today();
        quaterRequest.Quarters_Request_Type__c = 'NonTeachingStaff';
        quaterRequest.Reporting_Manager__c = testUser.Id;
        quaterRequest.Admin_Director__c = testUser.Id;
        quaterRequest.HR_Lead__c = testUser.Id;
        quaterRequest.Hostel_Officer__c = testUser.Id;
        
        insert quaterRequest;
        
        SLCM_Employee_Rent_Detail__c empRent = new SLCM_Employee_Rent_Detail__c ();
        empRent.Monthly_Deduction_Amount__c = 500.00;
        empRent.Request_Type__c = 'Quarter';
        empRent.Room_Type__c = '2 BHK';
        insert empRent;
        
        
        
    }
    
    @IsTest
    static void testSendApprovedConfirmationHCM_Success(){
        List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id ,HCM_Approval_Status__c FROM Staff_Quarters_Request__c LIMIT 1];
        List<SLCM_Employee_Rent_Detail__c> quarterRent = [SELECT Id , Monthly_Deduction_Amount__c,Request_Type__c,Room_Type__c FROM SLCM_Employee_Rent_Detail__c LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponsesuccess());
        Test.startTest();
        
        quarterRent[0].Monthly_Deduction_Amount__c = 9000.00;
        update quarterRent[0];
        Test.stopTest();
        Staff_Quarters_Request__c updatedRequest = [SELECT Employee_Salary__c ,Is_Revised_Salary_Push_to_HCM__c FROM Staff_Quarters_Request__c WHERE Id = :quaterReqs[0].Id];
        System.assertEquals(9000.00, updatedRequest.Employee_Salary__c);
    }
    
}