/*
* Created by Rajashekar on August 14 2024
*/
@IsTest
public class StudentVacationNOCControllerTest {
    
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static testmethod void StudentVacation(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create Contact
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test367@gmail.com',
            RecordTypeId = studentRecordType.Id,
            MobilePhone = '9998887770', 
            Date_of_Admission_in_Institute__c = system.today(), 
            SRN_Number__c ='EOBP3458D',
            Primary_Academic_Program__c = acc.Id
        );
        insert contact;
        
        // Fetch portal Profile for User
        Profile profile = [SELECT Id FROM Profile WHERE Name='Student Profile' LIMIT 1];
        
        // Create a User
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser555@example.com',
            ContactId = contact.Id
        );
        insert testUser;
        
           Profile profile1 = [SELECT Id FROM Profile WHERE Name='Warden' LIMIT 1];
        
        // Create a User
        User testUser1 = new User(
            Alias = 'testuser',
            Email = 'testwardenProfiler@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile1.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testwardenProfiler@example.com'
        );
        insert testUser1;
        
        Reva_Hostel_Room__c hostelRoom = new Reva_Hostel_Room__c(Name='HR-NO-202',
                                                                 Floor__c = 'FF',
                                                                 Dormitory_Type__c = 'Boys',
                                                                 Block__c = 'A',
                                                                 Room_Category__c = '1 Eng CS');
        insert hostelRoom;
        
        Student_Fee__c stuFee = new Student_Fee__c(Amount_paid__c = 20000,
                                                   Amount_Pending__c = 20000,
                                                   Amount__c = 40000
                                                  );
        insert stuFee;
        
        // Create Reva_Hostel_Request__c
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(Reva_Hostel_JoiningDate__c = system.today(),
                                                                          RevaHostelVacatingDate__c = system.today()+10,
                                                                          Type__c = '4',
                                                                          Hostel_Room_Request_For__c = contact.Id,
                                                                          Reva_Hostel_Room__c = hostelRoom.Id,
                                                                          Status__c = 'Room Allotted', 
                                                                          Approved_by_warden__c = true,
                                                                          Approved_by_ChiefWarden__c = true,
                                                                          Approved_by_Admin__c = true,
                                                                          Student_Fee__c = stuFee.Id);
        insert hostelRequest;
        List<Reva_Hostel_Request__c> hstlreqLst = new List<Reva_Hostel_Request__c>();
        hstlreqLst.add(hostelRequest);
        
        Test.starttest();
        // ApexPages.StandardController sc = new ApexPages.StandardController(hostelRequest);
        ApexPages.currentPage().getParameters().put('RequestId', hostelRequest.Id);
        StudentVacationNOCController sv = new StudentVacationNOCController();
        StudentVacationNOCPdfGenerator pdfGenerator = new StudentVacationNOCPdfGenerator(hostelRequest.Id);
        System.enqueueJob(pdfGenerator);
        Test.stoptest();
        
    }
}