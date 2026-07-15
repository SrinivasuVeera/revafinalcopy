@isTest
public class RoomAllocationWhatsAppNotificationsTest {
    
  @isTest
    static void testSendRoomAllotedWhatsAppNotification() {
        // Setup test data
        // 
        RecordType parentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent' LIMIT 1];
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        Contact testStudent = new Contact(
           
            MobilePhone = '1234567890',
           FirstName = 'test name',
            LastName = 'Name',
            Email = 'TestContact01@gmail.co',
          RecordTypeId = studentRecordType.Id
        );
        insert testStudent;
         Contact fatherContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice1.doe@example.com',
            MobilePhone = '987654321',
            ReportsToId = testStudent.Id,
            RecordTypeId = parentRecordType.Id
        );
        insert fatherContact;

        Reva_Hostel_Room__c testRoom = new Reva_Hostel_Room__c(
             Name = '100',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A',
            Floor__c = 'SF', 
            Room_Type__c = 'Student',
            Room_Category__c = 'Eng CS',
            Maximum_Occupancy__c = '4'

        );
        insert testRoom;

        Student_Fee__c testFee = new Student_Fee__c(
            Amount__c = 1000.00,
            Amount_Paid__c = 200.00,
            Amount_Pending__c = 800.00,
            Due_Date__c = Date.today()
        );
        insert testFee;

        Reva_Hostel_Request__c testRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testStudent.Id,
            Reva_Hostel_Room__r = testRoom,
            Student_Fee__r = testFee,
            Status__c = 'Room Allotted',
            Type__c = '1'
           
            
        );
        insert testRequest;

        Test.startTest();

        // Mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method to be tested
        List<String> recordIds = new List<String>{testRequest.Id};
        RoomAllocationWhatsAppNotifications.sendRoomAllotedWhatsAppNotification(recordIds);

        Test.stopTest();
        
        // Add assertions to verify the behavior
        // You can verify logs or state changes if applicable
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    
}