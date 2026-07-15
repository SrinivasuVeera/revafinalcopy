@isTest
public class Timetable_Notify_CandP_whatsapp_Test {
    
    @isTest
    static void testTrsWhatsappNotification() {
        // Arrange
        // Create test data
        Account schoolAccount = new Account(
            Name = 'Engineering School'
        );
        insert schoolAccount;
        // Create a Program Batch
        hed__Program_Plan__c objProgPlan = STOB_TestDataFactory.createProgramPlan('test program plan');
                objProgPlan.hed__Account__c = schoolAccount.Id;
                objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
                objProgPlan.hed__End_Date__c = system.today()+2;
                insert objProgPlan;
        // Create a Term (Semester)
        hed__Term__c semester = new hed__Term__c(
            Name = 'Spring 2024',
            Program_Batch__c = objProgPlan.Id,
            hed__Start_Date__c = Date.today().addMonths(-1),
            hed__End_Date__c = Date.today().addMonths(5),
            IA_1_Start_date__c = Date.today().addMonths(1),
            Exam_Start_Date__c = Date.today().addMonths(2),
            IA_1_End_date__c = Date.today().addMonths(3),
            IA_2_Start_date__c = Date.today().addMonths(4),
            IA_2_End_date__c = Date.today().addMonths(5),
            hed__Account__c = schoolAccount.Id
        );
        insert semester;
        
        
        // Create an Exam Notification
        Rve_Exam_Notification__c examNotification = new Rve_Exam_Notification__c(
            Name = 'Exam Notification 1',
            hed_Program_Batch__c = objProgPlan.Id,
            Rve_Semester__c = semester.Id,
            rve_Exam_Start_Date__c = Date.today().addDays(10),
            Rve_End_Date__c = Date.today().addDays(20),
            hed_IA_Type__c = 'IA 1'
        );
        insert examNotification;
        
        // Create a Course
        hed__Course__c course = new hed__Course__c(
            Name = 'Math 101',
            hed__Course_ID__c = 'CS101',
            hed__Account__c = schoolAccount.Id
        );
        insert course;
        
        // Create a Time Table Line Item
        hed_Time_Table_Line_Item__c timeTableLineItem = new hed_Time_Table_Line_Item__c(
            Name = 'Math 101 - Midterm',
            course__c = course.Id,
            hed_Date__c = Date.today().addDays(15),
            hed_Start_Time__c = Time.newInstance(9, 0, 0, 0),
            hed_End_Time__c = Time.newInstance(12, 0, 0, 0),
            Reva_Exam_Notification__c = examNotification.Id
        );
        insert timeTableLineItem;
        //Create father contact
        Contact father = new Contact(
            FirstName = 'John father',
            LastName = 'Doe father',
            MobilePhone = '8186824171',
            Active_Semester__c = semester.Id,
            Active__c = true,
            Email = 'vishnureddy9866@gmail.com'
         );
        insert father;
        // Create a Contact
        Contact studentContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '7731030243',
            Active_Semester__c = semester.Id,
            Active__c = true,
            Father__c= father.Id,
            Email = 'vishnureddy9866@gmail.com'
        );
        insert studentContact;
        
        
        
        List<String> recordIds = new List<String>();
        recordIds.add(examNotification.Id);
        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Act
        Test.startTest();
        Timetable_Notify_CandP_whatsapp.trsWhatsappNotification(recordIds);
        Test.stopTest();
        
        // Assert
     /*   List<AsyncApexJob> batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById 
                                        FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'Timetable_Notify_CandP_whatsapp_batch'];
        System.assert(batchJobs.size() > 0, 'Batch job should be enqueued.');
        System.assertEquals('Completed', batchJobs[0].Status, 'Batch job should be completed.');*/
    }
    
    /*@isTest
    static void testTrsWhatsappNotificationWithEmptyList() {
        // Arrange
        List<String> recordIds = new List<String>();
        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Act
        Test.startTest();
        Timetable_Notify_CandP_whatsapp.trsWhatsappNotification(recordIds);
        Test.stopTest();
        
        // Assert
        List<AsyncApexJob> batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById 
                                        FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'Timetable_Notify_CandP_whatsapp_batch'];
        System.assert(batchJobs.isEmpty(), 'No batch job should be enqueued for empty recordIds list.');
    }*/
    
    @isTest
    static void testTrsWhatsappNotificationWithNullElement() {
        // Arrange
        List<String> recordIds = new List<String>();
        recordIds.add(null);
        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Act
        Test.startTest();
        Timetable_Notify_CandP_whatsapp.trsWhatsappNotification(recordIds);
        Test.stopTest();
        
        // Assert
     /*   List<AsyncApexJob> batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById 
                                        FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'Timetable_Notify_CandP_whatsapp_batch'];
        System.assert(batchJobs.isEmpty(), 'No batch job should be enqueued for list containing null element.');*/
    }
    
   
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}