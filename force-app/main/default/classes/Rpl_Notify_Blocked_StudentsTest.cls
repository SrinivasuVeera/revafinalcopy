@isTest
private class Rpl_Notify_Blocked_StudentsTest {
      public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('Mock response body');
            return res;
        }
    }

    @isTest
    static void testBatchExecution() {


        Contact Father = new Contact();
        Father.lastName = 'Test Data';
        Father.Email = 'testfather@gmail.com';
        Father.MobilePhone = '8234823428';
        insert Father;
        
        Contact Mother = new Contact();
        Mother.lastName = 'Test Data';
        Mother.Email = 'testmother@gmail.com';
        Mother.MobilePhone = '9233492348';
        insert Mother;

        Contact eCon = new Contact();
        eCon.lastName = 'Test Data';
        eCon.Email = 'test@gmail.com';
        eCon.MobilePhone = '8234923408';
        eCon.Mother__c = Mother.Id;
        eCon.Father__c = Father.Id;
        insert eCon;


        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Student Name 1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Interested_in_placement__c = 'Yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
        std.Contact__c = eCon.Id;
        std.Rpl_Contact_No__c = '7820911232';
        insert std;
        
        Date startDate = Date.today();
        startDate.addDays(2);        
        Date endDate = Date.today();
        endDate.addDays(7);
        
        Rpl_Reva_Placement__c rpl = new Rpl_Reva_Placement__c();
        rpl.Rpl_Registration_Start_Date__c = startDate;
        rpl.Rpl_Registration_End_Date__c = endDate;
        rpl.Name = 'Test Reva Placement-01';
        insert rpl;
        
        Rpl_Company__c  cmp1 = new Rpl_Company__c();
        cmp1.Name = 'Cloud Odyssey';
        insert cmp1;

        Rpl_Placement_Drive__c plc = new Rpl_Placement_Drive__c();
        plc.Name = 'Cloud Odyssey Drive';
        plc.Reva_Placement__c = rpl.Id;
        plc.Rpl_Event_Date_Time__c = DateTime.Now().addDays(20); 
        plc.Rpl_Event_End_Date__c = Date.today().addDays(3);
        plc.Rpl_Event_Date__c = Date.today();
        plc.Rpl_Company_Name__c = cmp1.Id;
        plc.Rpl_CTC__c = 500000;
        insert plc; 
       
        Rpl_Student_Registration_Drive__c studentRegistrationDrive = new Rpl_Student_Registration_Drive__c();
        studentRegistrationDrive.Rpl_Placement_Drive__c =  plc.Id;
        studentRegistrationDrive.Rpl_Student_Registration__c = std.Id;
        studentRegistrationDrive.Rpl_Is_Failed__c = false;
        insert studentRegistrationDrive;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<List<String>> input = new List<List<String>>();
        input.add(new List<String>{studentRegistrationDrive.Id});
        Rpl_Notify_Blocked_Students.notifyBlockedStudents(input);
        Test.stopTest();

        
    }
  
    
}