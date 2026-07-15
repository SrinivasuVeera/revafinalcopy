@isTest
public class Exam_Application_Form_whats_Test {
     @IsTest//@TestSetUp
    static void testTrsWhatsappNotification() {
        
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        Contact father = new Contact(
        LastName = 'Father',
        MobilePhone = '7731030243'
        
        );
        
        insert father;
        
         Contact Mother = new Contact(
        LastName = 'Mother',
        MobilePhone = '7731030286'
        
        );
        
        insert Mother;
        
         Contact Guardian = new Contact(
        LastName = 'Guardian',
        MobilePhone = '7731030290'
        
        );
        
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
            MobilePhone = '7731030343',
            Email = 'revatransport@yopmail.com',
            Active_Semester__c = semester.Id,
            Active__c = true,
            Father__c = father.Id,
            Mother__c = Mother.Id,
            Guardian__c = Guardian.Id
           // Father_Name__c = father.name,
           // Father_Mobile_Number__c = father.MobilePhone
        );
        insert testContact;
        
      
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Rve_Exam_Notification__c' AND Name = 'Semester Notification' LIMIT 1];
        
        Rve_Exam_Notification__c examNotification = new Rve_Exam_Notification__c(
            Name = 'Test Notification',
            hed_Program_Batch__c = ProgramBatch.Id,
            Rve_Semester__c = semester.Id,
          //  hed_Program_Batch__c = 'Test Program Batch',
          //  Rve_Semester__c = 'Test Semester',
            rve_Exam_Start_Date__c = Date.today(),
            Rve_End_Date__c = Date.today().addDays(5),
            RecordTypeId = rt.Id,
            hed_IA_Type__c = 'IA 1'
        );
        insert examNotification;
        
        hed_Time_Table_Line_Item__c TimeTableItem = new hed_Time_Table_Line_Item__c();
        TimeTableItem.Name = 'TestTimeTable';
        TimeTableItem.Reva_Exam_Notification__c = ExamNotification.Id;
        TimeTableItem.hed_Date__c = System.today();
        TimeTableItem.hed_Start_Time__c =Time.newInstance(11,0,0,0);
        TimeTableItem.hed_End_Time__c = Time.newInstance(12,0,0,0);
        insert TimeTableItem;
        
         Rve_Exam_Application__c revExam = new Rve_Exam_Application__c( Name='testExam', 
                                                                      Rve_Amount__c=12000,
                                                                      Rve_Applied_Date__c=System.today(),
                                                                      Rve_Exam_Notification__c=examNotification.Id,
                                                                      Rve_Logisys_Field_Check__c=true,
                                                                      Rve_Payment_Date__c=System.today(),
                                                                      Rve_Payment_Status__c='Success',
                                                                      Rve_Payment_Type__c='Online',
                                                                      Rve_Registration_Number__c='1234tyu', 
                                                                      Rve_Status__c='Active', 
                                                                      
                                                                      Rve_Student__c=testContact.Id);
        insert revExam;
        
        Rve_Exam_Application_Line_Item__c lineItem = new Rve_Exam_Application_Line_Item__c(//Name = 'testLineItem' ,
            Rve_QP_Code__c='abbb223',
            Rve_Semester__c='semester',
            Rve_Subject__c='salesforce',
            Rve_Exam_Application__c= revExam.ID);
        
        insert lineItem;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call the method to test
        Test.startTest();
                Exam_Application_Form_whats.trsWhatsappNotification(new List<List<String>> { new List<String> { revExam.Id } });

        //Exam_Application_Form_whats.trsWhatsappNotification(new List<String> { revExam.Id });
        Test.stopTest();
    }
    
     /*@IsTest(seeAllData=true)
    static void testBatch() {
     
        Contact con = [Select Id,name,mobilephone,Father_Name__c,Father_Mobile_Number__c,Mother_Mobile_Number__c,Mother_Name__c,
                       Guardian__r.Name ,Guardian__r.MobilePhone
                       from contact where lastname='Contact'];
        
        system.debug('conlist>>'+con);
        Rve_Exam_Application__c applicationtlist = [ SELECT Id, Name, Rve_Exam_Notification__r.hed_Program_Batch__r.Name,
                   Rve_Exam_Notification__r.Rve_Semester__r.Name, Rve_Exam_Notification__r.hed_Program_Batch__c,
                   Rve_Exam_Notification__r.Rve_Semester__c, Rve_Exam_Notification__r.Rve_End_Date__c, 
                   Rve_Exam_Notification__r.RecordType.Name, 
                   Rve_Exam_Notification__r.Rve_Semester__r.IA_2_End_date__c, Rve_Student__r.MobilePhone, Rve_Student__r.Name,
                   Rve_Student__r.Email, Rve_Student__c, Student_Name__c
            FROM Rve_Exam_Application__c 
            WHERE Rve_Exam_Notification__r.RecordType.Name = 'Semester Notification' AND name = 'testExam'];
        
          // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Execute the batch
        //Exam_Application_Form_whats_batch batch = new Exam_Application_Form_whats_batch(applicationtlist.Id);
        Test.startTest();
        //Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify results
        // Verify that the batch has processed the records
      /*  List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClassId = :Schema.getGlobalDescribe().get('Change_in_Time_Table_whats_batch').getSObjectType().getDescribe().getId() LIMIT 1];
        System.assertEquals(1, batchJobs.size(), 'Batch job should have been executed');
        System.assertEquals('Completed', batchJobs[0].Status, 'Batch job should have completed successfully');
    }*/
    
     public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

}