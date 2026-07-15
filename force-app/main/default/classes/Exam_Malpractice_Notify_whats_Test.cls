@isTest
public class Exam_Malpractice_Notify_whats_Test {
    
    @testSetup
    static void setup() {
        try{
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
           Contact father = new Contact(
        LastName = 'Father',
        MobilePhone = '7731030243',
        Email = 'revatransport@yopmail.com'
        
        );
        
        insert father;
        
         Contact Mother = new Contact(
        LastName = 'Mother',
        MobilePhone = '7731030286',
        Email='shubhampanat@yopmail.com'
        
        );
        
        insert Mother;
        
         Contact Guardian = new Contact(
        LastName = 'Guardian',
        MobilePhone = '7731030290',
        Email = 'salesforcetechbuddy513@gmail.com'
        
        );
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        insert Guardian;
           // Create Semester (hed__Term__c)
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);        
        insert semester;
        
        
        // Create test data
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            MobilePhone = '7731030243',
            Email = 'kruthika@yopmail.com',
            SRN_Number__c = 'SA001',
            Active_Semester__c = semester.Id,
            Active__c = true,
            Father__c = father.Id,
            Mother__c = Mother.Id,
            Guardian__c = Guardian.Id,
            Mentor__c = Guardian.Id
           // Father_Name__c = father.name,
           // Father_Mobile_Number__c = father.MobilePhone
        );
        insert testContact;
        
        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name = 'Course';
        objCourse.hed__Account__c = acc.id;
       // objCourse.Category__c = cat;
       // objCourse.hed__Course_ID__c = 'CRS00'+i;
        insert objcourse;
        
            hed__Course_Offering__c CourseOffering = new hed__Course_Offering__c(
            hed__Course__c = objcourse.Id,
            hed__Term__c = semester.Id,
            Name = 'test course offering'
            
            );
            
            insert CourseOffering;
            
            hed__Course_Enrollment__c CourseEnrollment = new hed__Course_Enrollment__c(
            hed__Contact__c = testcontact.Id,
            hed__Course_Offering__c = CourseOffering.Id
      
            );
        
            insert CourseEnrollment;        
        // Create test Attendance Event
       hed__Attendance_Event__c event = new hed__Attendance_Event__c(
           hed__Course_Connection__c = CourseEnrollment.Id,
            rve_Room_Number__c = '101', 
            hed__Date__c = Date.today(), 
            hed__Start_Time__c = Time.newInstance(9, 0, 0, 0),
            hed__End_Time__c = Time.newInstance(11,0,0,0),
            rve_Exam_type__c = 'Internal Assessment- 1',
            hed_Malpractice__c = true,
           hed__Contact__c = testcontact.Id,
           hed__Attendance_Type__c  = 'Absent' 
           
        );
        insert event;
  //      insert testEvent;
        System.debug('TestEvent=> '+event);
        }
        catch(Exception e)
        {
            System.debug('Line=> '+e.getLineNumber()+' Message=> '+e.getMessage());
        }
    }
    
    @isTest
   public static void testTrsWhatsappNotification() {
        // Get the test Attendance Event
        hed__Attendance_Event__c testEvent = [SELECT Id, Name, hed__Course_Name__c, rve_Exam_type__c, hed__Date__c,
        hed__Start_Time__c, hed__End_Time__c, hed__Contact__c, hed__Contact__r.Name,
        hed__Contact__r.MobilePhone, hed__Contact__r.Father_Mobile_Number__c,
        hed__Contact__r.Father_Name__c, hed__Contact__r.Mother_Name__c,
        hed__Contact__r.Mother_Mobile_Number__c, hed__Contact__r.Guardian__r.MobilePhone,
        hed__Contact__r.Guardian__r.Name, hed_Malpractice__c
        FROM hed__Attendance_Event__c LIMIT 1];
        
        // Create a list of record IDs
        List<String> recordIds = new List<String>{testEvent.Id};
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the Invocable method
        Test.startTest();
        Exam_Malpractice_Notify_whats.trsWhatsappNotification(recordIds);
        Test.stopTest();
        
        // Verify the expected behavior
        // This will vary based on what you expect to happen after the call
        // For instance, you might want to check the debug logs or the state of certain objects
    }
    
      @isTest
   public static void testTrsAbsentWhatsappNotification() {
        // Get the test Attendance Event
        hed__Attendance_Event__c testEvent = [SELECT Id, Name, hed__Course_Name__c, rve_Exam_type__c, hed__Date__c,
        hed__Start_Time__c, hed__End_Time__c, hed__Contact__c, hed__Contact__r.Name,
        hed__Contact__r.MobilePhone, hed__Contact__r.Father_Mobile_Number__c,
        hed__Contact__r.Father_Name__c, hed__Contact__r.Mother_Name__c,
        hed__Contact__r.Mother_Mobile_Number__c, hed__Contact__r.Guardian__r.MobilePhone,
        hed__Contact__r.Guardian__r.Name, hed_Malpractice__c
        FROM hed__Attendance_Event__c LIMIT 1];
        
        // Create a list of record IDs
        List<String> recordIds = new List<String>{testEvent.Id};
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the Invocable method
        Test.startTest();
        Exam_Absent_Notification_whats.trsWhatsappNotification(recordIds);
        Test.stopTest();
        
        // Verify the expected behavior
        // This will vary based on what you expect to happen after the call
        // For instance, you might want to check the debug logs or the state of certain objects
    }
    
        private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success"}');
        res.setStatusCode(200);
        return res;
    }
}

    // Additional test methods for different scenarios can be added here
}