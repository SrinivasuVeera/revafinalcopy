@isTest
public class StudentPaymentTriggerEmailHandlerTest {
    
    public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
  
    
        @isTest
    static void testHostelRoomRequestUpdate() {
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
    
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
       system.debug('test semester>>' +ProgramBatch.hed__Account__c);
        
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);        
        insert semester;
        
        Contact contact = new Contact(LastName = 'Test',Active_Semester__c =semester.Id,Email='Test@email.com' );
        insert contact;

        // Create a related Student_Payment__c record
        Student_Payment__c studentPayment = new Student_Payment__c(
            Contact__c = contact.Id,
            Fee_Type__c = 'Hostel Fee',
            Payment_Status__c = 'Success'
        );
        insert studentPayment;
        
        // Create necessary Reva_Hostel_Request__c data
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = contact.Id,
            Type__c = '1',
            Status__c = 'Booked',
            Reva_Hostel_Premium_Room__c = true
        );
        insert hostelRequest;
        
        // Create a Reva_Hostel_Room__c record to be used in the allotment
        Reva_Hostel_Room__c hostelRoom = new Reva_Hostel_Room__c(
            Name = 'Room A',
            Block__c = 'A',
            Floor__c = 'SF',
            Occupied_Occupancy__c = 0,
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng Non-CS',
            Is_Premium__c = true
        );
        insert hostelRoom;
		Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        
        // Call the method under test
        List<Student_Payment__c> payments = [SELECT Id, Contact__c, Fee_Type__c, Payment_Status__c FROM Student_Payment__c WHERE Contact__c = :contact.Id];
        try {
            StudentPaymentTriggerEmailHandler.HostelRoomRequestUpdate(payments);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        
        Test.stopTest();
      }
}