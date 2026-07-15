@isTest
public class Student_Leave_WhatsAppNotificationsTest {
    
    @isTest
    static void testSendLeaveApprovalWhatsAppNotification() {
       
        Contact fatherContact = new Contact(FirstName = 'JohnTest', LastName = 'DoeTest', MobilePhone = '7862347927', Email = 'test@123.com');
        insert fatherContact;
        
        Contact MentorContact = new Contact(FirstName = 'JohnMentor', LastName = 'DoeMentor', MobilePhone = '7862347957', Email = 'test@1234.com');
        insert MentorContact;
        
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', MobilePhone = '1234567890', Email = 'test@1235.com',Father__c = fatherContact.Id, Mentor__c = MentorContact.Id,SRN_Number__c = 'testuni1que3457'  );
        insert testContact;
        
        Reva_Hostel_Room__c room1 = new Reva_Hostel_Room__c(
            Name = '101',
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS'
        );
        insert room1;
        
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Status__c = 'Room Allotted',
            Type__c = '1',
            Reva_Hostel_Room__c = room1.id,
            Reva_Hostel_Premium_Room__c = false
        );
        insert hostelRequest;
        
        REVA_Hostel_Leave_Request__c testLeaveRequest = new REVA_Hostel_Leave_Request__c(
            Start_Date_and_Time__c = System.now().addDays(1),
            End_Date_and_Time__c = System.now().addDays(2),
            Reason_For_Leave__c = 'Going Home',
            Contact__c = testContact.Id,
            Status__c = 'Approved'
        );
        insert testLeaveRequest;
        
        Student_Leave_WhatsAppNotifications.InputParameters inputParams = new Student_Leave_WhatsAppNotifications.InputParameters();
        inputParams.recordIds = new List<String>{testLeaveRequest.Id};
        inputParams.status = new List<String>{'Approved'};
            
        Student_Leave_WhatsAppNotifications.InputParameters inputParams1 = new Student_Leave_WhatsAppNotifications.InputParameters();
        inputParams1.recordIds = new List<String>{testLeaveRequest.Id};
        inputParams1.status = new List<String>{'Check Out'};
            
        Student_Leave_WhatsAppNotifications.InputParameters inputParams2 = new Student_Leave_WhatsAppNotifications.InputParameters();
        inputParams2.recordIds = new List<String>{testLeaveRequest.Id};
        inputParams2.status = new List<String>{'Check In'};
            
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Student_Leave_WhatsAppNotifications.sendLeaveApprovalWhatsAppNotification(new List<Student_Leave_WhatsAppNotifications.InputParameters>{inputParams});
        Student_Leave_WhatsAppNotifications.sendLeaveApprovalWhatsAppNotification(new List<Student_Leave_WhatsAppNotifications.InputParameters>{inputParams1});
        Student_Leave_WhatsAppNotifications.sendLeaveApprovalWhatsAppNotification(new List<Student_Leave_WhatsAppNotifications.InputParameters>{inputParams2});
        Test.stopTest();
    }
    

    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status": "success"}'); // Mock response body
            return res;
        }
    }
}