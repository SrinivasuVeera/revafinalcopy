@isTest
public class WhatsAppFollowUpBatchTest {

    @isTest
    static void testBatchExecution1() {
        
    id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();

        Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
       // accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        //accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        insert accRecPhd;

        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c();
        mbaAcc.Name = 'Master of Business Administration(2024-2026)';
       // mbaAcc.RecordTypeId = accAcademicProgRecTypeId;
        mbaAcc.hed__Account__c =accRecPhd.Id;
        insert mbaAcc;
        
        // Create test data - Contact records
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 100; i++) {
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = False,
               Primary_Academic_Program__c = accRecPhd.Id,
               RecordTypeId  = conRecTypeId,
                Program_Batch__c=mbaAcc.Id
            );
            testContacts.add(applicant);
        }
        insert testContacts;

        // Set up mock response for WhatsApp utility callout
      //  Test.setMock(HttpCalloutMock.class, new WhatsAppMockResponse());

        Test.startTest();       
        WhatsAppFollowUpBatch1 batch = new WhatsAppFollowUpBatch1();
        Database.executeBatch(batch);
        Test.stopTest();
  }    

  static testMethod void testBatchExecution2() {
      
       id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
       Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
       // accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        //accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        insert accRecPhd;

        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c();
        mbaAcc.Name = 'Master of Business Administration(2024-2026)';
       // mbaAcc.RecordTypeId = accAcademicProgRecTypeId;
        mbaAcc.hed__Account__c =accRecPhd.Id;
        insert mbaAcc;
      
        // Test data setup
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) { // create multiple records for testing
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = true,
                Primary_Academic_Program__c = accRecPhd.Id,
                RecordTypeId  = conRecTypeId,
                Admission_Mode__c ='UQ',
                Program_Batch__c=mbaAcc.Id
                
            );
            contacts.add(applicant);
        }
        insert contacts;

        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts.size(); i++) { 
            hed__Application__c app = new hed__Application__c(
                hed__Applicant__c = contacts[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0'),
                hed__Application_Status__c = 'Started'
            );
            applications.add(app);
        }
        insert applications;
     
        // Start the batch
        Test.startTest();
        WhatsAppFollowUpBatch2 batch = new WhatsAppFollowUpBatch2();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
     static testMethod void testBatchExecution3() {
      
       id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
       Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
       // accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        //accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        insert accRecPhd;

        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c();
        mbaAcc.Name = 'Master of Business Administration(2024)';
       // mbaAcc.RecordTypeId = accAcademicProgRecTypeId;
        mbaAcc.hed__Account__c =accRecPhd.Id;
        insert mbaAcc;
      
        // Test data setup
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) { // create multiple records for testing
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = true,
                Primary_Academic_Program__c = accRecPhd.Id,
                RecordTypeId  = conRecTypeId,
                Admission_Mode__c ='UQ',
                Program_Batch__c=mbaAcc.Id
                
            );
            contacts.add(applicant);
        }
        insert contacts;

        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts.size(); i++) { 
            hed__Application__c app = new hed__Application__c(
                hed__Applicant__c = contacts[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0'),
                hed__Application_Status__c = 'Incomplete'
            );
            applications.add(app);
        }
        insert applications;

     //  Test.setMock(HttpCalloutMock.class, new WhatsAppMockResponse());
        // Start the batch
        Test.startTest();
        WhatsAppFollowUpBatch3 batch = new WhatsAppFollowUpBatch3();
        Database.executeBatch(batch);
        Test.stopTest();
      }  
    
     
    static testMethod void testBatchExecution5() {        
     id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
       Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
       // accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Account accRecBtech = new Account();
        accRecBtech.Name = 'B.Tech in Mechanical Engineering';
        accRecBtech.Program_Type__c = 'UG';
        insert accRecBtech;

        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c();
        mbaAcc.Name = 'Master of Business Administration(2024-2026)';
       // mbaAcc.RecordTypeId = accAcademicProgRecTypeId;
       // mbaAcc.hed__Account__c =accRecPhd.Id;
         mbaAcc.hed__Account__c =accRecBtech.Id;
        insert mbaAcc;
      
        // Test data setup
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) { // create multiple records for testing
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = true,
                Primary_Academic_Program__c = accRecBtech.Id,
                RecordTypeId  = conRecTypeId,
                Admission_Mode__c ='UQ',
                Program_Batch__c=mbaAcc.Id
             //   OwnerId = user.Id
            );
            contacts.add(applicant);
        }
        insert contacts;

        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts.size(); i++) { 
            hed__Application__c app = new hed__Application__c(
                hed__Applicant__c = contacts[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0'),
                hed__Application_Status__c = 'In Review'                
            );
            applications.add(app);
        }
        insert applications;

     //  Test.setMock(HttpCalloutMock.class, new WhatsAppMockResponse());
        // Start the batch
        Test.startTest();
        WhatsAppFollowUpBatch5 batch = new WhatsAppFollowUpBatch5();
        Database.executeBatch(batch);
        Test.stopTest();
  }
    
    @isTest
    static void testScheduler() {
        // Enqueue job
        Test.startTest();
        String jobId = System.schedule('Test WhatsAppFollowUp Scheduler', '0 0 0 * * ?', new WhatsAppFollowUp_Scheduler());
        Test.stopTest();

        // Verify job has been scheduled
        CronTrigger ct = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('Test WhatsAppFollowUp Scheduler', ct.CronJobDetail.Name);
        
        }    
      @isTest
    static void testSchedulerPAF() {
        // Enqueue job
        Test.startTest();
        String jobId = System.schedule('Test WhatsAppFollowUp Scheduler', '0 0 0 * * ?', new WhatsAppFollowUp_PAF_Scheduler());
        Test.stopTest();

        // Verify job has been scheduled
        CronTrigger ct = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('Test WhatsAppFollowUp Scheduler', ct.CronJobDetail.Name);
    }
        
    // Mock response class for WhatsApp callout
    private class WhatsAppMockResponse implements HttpCalloutMock {
        // This method mocks the response for the HTTP request
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
 
}