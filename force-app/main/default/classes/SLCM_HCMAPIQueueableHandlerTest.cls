@isTest
public class SLCM_HCMAPIQueueableHandlerTest {
    
    @testSetup
    public static void testSetupData(){
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
        
        Id nonTeachingProfileId = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1].Id;
        Id Non_teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non Teaching').getRecordTypeId();
        
        Contact testContact = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            hed__WorkEmail__c = 'nonteaching@example.com',
            Employee_Number__c = 'REVA01463',
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
        
        // Create a Reva_Hostel_Request__c record with required fields
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c();
        hostelRequest.Hostel_Room_Request_For__c = testContact.Id;
        hostelRequest.Reva_Hostel_JoiningDate__c = Date.today();
        hostelRequest.Type__c = '4ExtraSpace';
        hostelRequest.HCM_Approval_Status__c = 'Deduction Request Initiated';
        insert hostelRequest;
        
        
        
        Staff_Quarters_Room__c stRooms = new Staff_Quarters_Room__c();
        stRooms.Floor__c ='Ground Floor';
        stRooms.Availability__c = true;
        stRooms.Type__c ='2 BHK';
        insert stRooms;
        
        
        
        
        // Create a Reva_Hostel_Request__c record with required fields
        Staff_Quarters_Request__c quaterRequest = new Staff_Quarters_Request__c();
        quaterRequest.Quarter_Request_For__c = testContact.Id;
        quaterRequest.Employee_Salary__c = 5000;
        quaterRequest.Status__c = 'Request Submitted';
        quaterRequest.Type__c ='2 BHK';
        quaterRequest.HCM_Approval_Status__c = 'Deduction Request Initiated';
        quaterRequest.Staff_Quarters_Joining_Date__c = Date.today()+1;
        insert quaterRequest;
        
    }
    
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('HCM_SalaryRangeAPI')) {
                System.debug('req--- ins>');
                res.setBody('{"Employee_Number":"REVA01463", "Employee_Name":"John Doe", "Salary_Range":1000.0 , "Type":"Hostel"}');
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
    public static void hostelSalaryRangeTest(){
        List<Contact> co =[SELECT Id from contact WHERE Email = 'nonteaching@example.com'];
        
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c();
        hostelRequest.Hostel_Room_Request_For__c = co[0].Id;
        hostelRequest.Reva_Hostel_JoiningDate__c = Date.today();
        hostelRequest.Type__c = '4ExtraSpace';
        hostelRequest.HCM_Approval_Status__c = 'Deduction Request Initiated';
        insert hostelRequest;
        
        
        
    }
    
    
    @isTest
    public static void hostelApprovalHierarchyTest(){
        List<Contact> co =[SELECT Id from contact WHERE Email = 'nonteaching@example.com'];
        
        List<Reva_Hostel_Request__c> hostelRe = [SELECT Id ,Employee_Salary__c,HCM_Approval_Status__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c =: co[0].Id];
        
        
        hostelRe[0].Employee_Salary__c = 5000;
        hostelRe[0].HCM_Approval_Status__c = 'Deduction Request Initiated';
        update hostelRe[0];
        
    }
    
    @isTest
    public static void hostelSalaryRevisedTest(){
        List<Contact> co =[SELECT Id from contact WHERE Email = 'nonteaching@example.com'];
        
        List<Reva_Hostel_Request__c> hostelRe = [SELECT Id ,Employee_Salary__c,HCM_Approval_Status__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c =: co[0].Id];
        
        
        hostelRe[0].Employee_Salary__c = 5000;
        hostelRe[0].Salary_Last_Revised_Date__c = System.today()+1;
        hostelRe[0].HCM_Approval_Status__c = 'Deduction Approved';
        hostelRe[0].Status__c = 'Room Allotted';
        hostelRe[0].Is_HCM_Salary_Deduction_CNF__c = true;
        hostelRe[0].Approved_by_HR_Lead__c = true;
        update hostelRe[0];
        
    }
    /*******************added by veera to cover the staff quaerters trigger****************************************/ 
  
    @isTest
    public static void testQuarterRequestApprovalHierarchyAPIQueueable() {
        // Arrange
        List<Contact> co = [SELECT Id FROM Contact WHERE Email = 'nonteaching@example.com'];
        Staff_Quarters_Request__c staffRequest = new Staff_Quarters_Request__c(
            Quarters_Request_Type__c = 'NonTeachingStaff',
            Quarter_Request_For__c = co[0].Id,
            Employee_Salary__c = 50000,
            HCM_Approval_Status__c = 'Deduction Request Initiated',
            Status__c = 'Request Submitted'
        );
        insert staffRequest;
        
        // Act
        Set<Id> reqIds = new Set<Id>{staffRequest.Id};
            Test.startTest();
        System.enqueueJob(new SLCM_HCMAPIQueueableHandler.QuarterRequestApprovalHierarchyAPIQueueable(reqIds));
        Test.stopTest();
        
        // Assert
        Staff_Quarters_Request__c updatedRequest = [
            SELECT Id, HCM_Approval_Status__c 
            FROM Staff_Quarters_Request__c 
            WHERE Id = :staffRequest.Id
        ];
        System.assertNotEquals(null, updatedRequest, 'Request should be updated successfully');
    }
    
    @isTest
    public static void testQuaterRequestSalaeyRevisedQueueable() {
        // Arrange
        List<Contact> co = [SELECT Id FROM Contact WHERE Email = 'nonteaching@example.com'];
        Staff_Quarters_Request__c staffRequest = new Staff_Quarters_Request__c(
            Quarters_Request_Type__c = 'NonTeachingStaff',
            Quarter_Request_For__c = co[0].Id,
            Employee_Salary__c = 50000,
            HCM_Approval_Status__c = 'Deduction Approved',
            Status__c = 'Room Allotted',
            Staff_Quarters_Joining_Date__c = System.today(),
            Approved_by_Hostel_Office__c = true,
            Is_HCM_Salary_Deduction_CNF__c = true
        );
        insert staffRequest;
        
        // Update salary to trigger logic
        staffRequest.Employee_Salary__c = 55000;
        update staffRequest;
        
        // Act
        Set<Id> reqIds = new Set<Id>{staffRequest.Id};
            Test.startTest();
        System.enqueueJob(new SLCM_HCMAPIQueueableHandler.QuaterRequestSalaeyRevisedQueueable(reqIds));
        Test.stopTest();
        
        // Assert
        Staff_Quarters_Request__c updatedRequest = [
            SELECT Id, Employee_Salary__c 
            FROM Staff_Quarters_Request__c 
            WHERE Id = :staffRequest.Id
        ];
        System.assertEquals(55000, updatedRequest.Employee_Salary__c, 'Salary should be updated to 55000');
    }
    
    @isTest
    public static void testSendNotificationsOnUpdate() {
        // Arrange
        List<Contact> co = [SELECT Id FROM Contact WHERE Email = 'nonteaching@example.com'];
        Staff_Quarters_Request__c staffRequest = new Staff_Quarters_Request__c(
            Quarters_Request_Type__c = 'NonTeachingStaff',
            Quarter_Request_For__c = co[0].Id,
            Employee_Salary__c = 50000,
            HCM_Approval_Status__c = 'Deduction Approved',
            Status__c = 'Booked',
            Staff_Quarters_Joining_Date__c = System.today(),
            Approved_by_ReportingManager__c = false,
            Approved_by_AdminDirector__c = false,
            Approved_by_HR_Lead__c = false,
            Approved_by_Hostel_Office__c = false
        );
        insert staffRequest;
        
        // Update to trigger notifications
        staffRequest.Status__c = 'Approved';
        staffRequest.Approved_by_Hostel_Office__c = true;
        staffRequest.Is_HCM_Salary_Deduction_CNF__c = true;
        update staffRequest;
        
        // Assert
        Staff_Quarters_Request__c updatedRequest = [
            SELECT Id, Status__c, Approved_by_Hostel_Office__c 
            FROM Staff_Quarters_Request__c 
            WHERE Id = :staffRequest.Id
        ];
        System.assertEquals('Approved', updatedRequest.Status__c, 'Status should be updated to Approved');
        System.assertEquals(true, updatedRequest.Approved_by_Hostel_Office__c, 'Hostel office approval should be true');
    }
    
    @isTest
    public static void testCreateAttachmentHandler() {
        // Arrange
        List<Contact> co = [SELECT Id FROM Contact WHERE Email = 'nonteaching@example.com'];
        Staff_Quarters_Request__c staffRequest = new Staff_Quarters_Request__c(
            Quarters_Request_Type__c = 'NonTeachingStaff',
            Quarter_Request_For__c = co[0].Id,
            Employee_Salary__c = 50000,
            HCM_Approval_Status__c = 'Deduction Approved',
            Status__c = 'Room Allotted'
        );
        insert staffRequest;
        
        // Act
        Test.startTest();
        StaffQuarterRequestTriggerHandler.createAttachment(new List<Staff_Quarters_Request__c>{staffRequest});
        Test.stopTest(); 
    }
    
    @isTest
    public static void testSendNotificationsElseIfCondition() {
        // Arrange
        List<Contact> co = [SELECT Id FROM Contact WHERE Email = 'nonteaching@example.com'];
        Staff_Quarters_Request__c staffRequest = new Staff_Quarters_Request__c(
            Quarters_Request_Type__c = 'NonTeachingStaff',
            Quarter_Request_For__c = co[0].Id,
            Employee_Salary__c = 50000,
            HCM_Approval_Status__c = 'Deduction Approved',
            Status__c = 'Booked',
            Staff_Quarters_Joining_Date__c = System.today(),
            Approved_by_ReportingManager__c = true,
            Approved_by_AdminDirector__c = false,
            Approved_by_HR_Lead__c = false,
            Approved_by_Hostel_Office__c = false
        );
        insert staffRequest;
        
        // Update record to meet the `else if` conditions
        staffRequest.Status__c = 'Approved';
        staffRequest.Approved_by_Hostel_Office__c = true;
        staffRequest.Is_HCM_Salary_Deduction_CNF__c = true;
        update staffRequest;
        
        // Assert
        Staff_Quarters_Request__c updatedRequest = [
            SELECT Id, Status__c, Approved_by_Hostel_Office__c 
            FROM Staff_Quarters_Request__c 
            WHERE Id = :staffRequest.Id
        ];
        System.assertEquals('Approved', updatedRequest.Status__c, 'Status should be updated to Approved');
        System.assertEquals(true, updatedRequest.Approved_by_Hostel_Office__c, 'Hostel office approval should be true');
    }
    
    /******************************/
    @isTest
public static void testElseIfConditionForBookedStatus() {
    // Arrange
    List<Contact> co = [SELECT Id FROM Contact WHERE Email = 'nonteaching@example.com'];
    Staff_Quarters_Request__c staffRequest = new Staff_Quarters_Request__c(
        Quarters_Request_Type__c = 'TeachingStaff',
        Quarter_Request_For__c = co[0].Id,
        Employee_Salary__c = 50000,
        HCM_Approval_Status__c = 'Deduction Approved',
        Status__c = 'Booked',
        Staff_Quarters_Joining_Date__c = System.today(),
        Approved_by_ReportingManager__c = false,
        Approved_by_AdminDirector__c = false,
        Approved_by_HR_Lead__c = false,
        Approved_by_Hostel_Office__c = false
    );
    insert staffRequest;

    // Act
    staffRequest.Status__c = 'Approved';
    staffRequest.Approved_by_HR_Lead__c = true;
    update staffRequest;

    // Assert
    Staff_Quarters_Request__c updatedRequest = [
        SELECT Id, Status__c, Approved_by_HR_Lead__c 
        FROM Staff_Quarters_Request__c 
        WHERE Id = :staffRequest.Id
    ];
    System.assertEquals('Approved', updatedRequest.Status__c, 'Status should be updated to Approved');
    System.assertEquals(true, updatedRequest.Approved_by_HR_Lead__c, 'HR lead approval should be true');
}
    /*******************************/
    @isTest
public static void testRecordWithoutSalary() {
    // Arrange
    List<Contact> co = [SELECT Id FROM Contact WHERE Email = 'nonteaching@example.com'];
    Staff_Quarters_Request__c staffRequest = new Staff_Quarters_Request__c(
        Quarters_Request_Type__c = 'TeachingStaff',
        Quarter_Request_For__c = co[0].Id,
        HCM_Approval_Status__c = 'Deduction Request Initiated',
        Status__c = 'Request Submitted'
    );
    insert staffRequest;

    // Assert
    Staff_Quarters_Request__c insertedRequest = [
        SELECT Id, Employee_Salary__c 
        FROM Staff_Quarters_Request__c 
        WHERE Id = :staffRequest.Id
    ];
    System.assertEquals(null, insertedRequest.Employee_Salary__c, 'Salary should be null for this test case');
}

    /*****************************/
}