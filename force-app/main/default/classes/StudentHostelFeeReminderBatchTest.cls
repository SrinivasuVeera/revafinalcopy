@Istest
public class StudentHostelFeeReminderBatchTest {
        public static Id parentRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Parent').getRecordTypeId();
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup
    static void setupData() {
        
        WhatsApp_Notification_Template__mdt studentTemplate = [
            SELECT Id, DeveloperName, Template_ID__c
            FROM WhatsApp_Notification_Template__mdt
            WHERE DeveloperName = 'hostel_fee_reminder_student'
            LIMIT 1
        ];
        WhatsApp_Notification_Template__mdt parentTemplate = [
            SELECT DeveloperName, Template_ID__c
            FROM WhatsApp_Notification_Template__mdt
            WHERE DeveloperName = 'hostel_fee_reminder_parent'
            LIMIT 1
        ];
        
        // Create Parent Contacts
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890',
            Email = 'testFather@example.com'
        );
        insert contact2;

        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890',
            Email = 'testMother@example.com'
        );
        insert contact3;

        // Create Student Contact
        Contact con = new Contact(
            LastName = 'Test Student',
            Phone = '+91-9876543210',
            Email = 'teststudent@example.com',
            Father__c = contact2.Id,
            Mother__c = contact3.Id
        );
        insert con;

        // Create Hostel Fee (Main Fee record)
        Student_Fee__c hostelFee = new Student_Fee__c(
            Name = 'Hostel Fee - 2025',
            Fee_type__c = 'Hostel Fee',
            Contact__c = con.Id,
            Amount__c = 50000,
            Amount_Paid__c = 20000,
            Amount_Pending__c = 30000,
            Due_Date__c = Date.today().addDays(-10),
            Date_of_Joining_Hostel__c  = Date.today().addDays(-90)
        );
        insert hostelFee;

        Student_Fee__c hostelFee1 = new Student_Fee__c(
            Name = 'Hostel Fee - 2025',
            Fee_type__c = 'Hostel Fee',
            Contact__c = con.Id,
            Amount__c = 50000,
            Amount_Paid__c = 20000,
            Amount_Pending__c = 30000,
            Due_Date__c = Date.today().addDays(10),
            Date_of_Joining_Hostel__c  = Date.today().addDays(-55)
        );
        insert hostelFee1;
        
         Student_Fee__c hostelFee2 = new Student_Fee__c(
            Name = 'Hostel Fee - 2025',
            Fee_type__c = 'Hostel Fee',
            Contact__c = con.Id,
            Amount__c = 50000,
            Amount_Paid__c = 20000,
            Amount_Pending__c = 30000,
            Due_Date__c = Date.today().addDays(-62),
            Date_of_Joining_Hostel__c  = Date.today().addDays(-125)
        );
        insert hostelFee2;

        // Create Child Penalty Fee
        Student_Fee__c penaltyFee = new Student_Fee__c(
            Name = 'Late Penalty',
            Fee_type__c = 'Hostel Fee',
            Contact__c = con.Id,
            Amount__c = 1000,
            Amount_Paid__c = 0,
            Amount_Pending__c = 1000,
            Due_Date__c = Date.today().addDays(5),
            Student_Hostel_Fee__c = hostelFee.Id
        );
        insert penaltyFee;
    }

    @isTest
    static void testStudentBatchExecution() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();

        // Run batch
        Id batchId = Database.executeBatch(new StudentHostelFeeReminderBatch(), 50);

        Test.stopTest();

        // Validate student fee exists
        List<Student_Fee__c> fees = [SELECT Id, Amount_Pending__c FROM Student_Fee__c];
        System.assert(!fees.isEmpty(), 'Student Fee records should exist');

        // Validate Contact Email is set
        Contact c = [SELECT Email, Phone FROM Contact WHERE LastName = 'Test Student' LIMIT 1];
        System.assertEquals('teststudent@example.com', c.Email);

        // Validate Batch Completed
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :batchId];
        System.assertEquals('Completed', job.Status, 'Batch should complete successfully');
    }
    
   /* @isTest
    static void testSchedulableExecution() {
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
          Contact contact2 = new Contact(
            LastName = 'Father S1',
            Type_of_Relationship__c = 'Father',
           // RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890',
            Email = 'testFather@example.com'
        );
        insert contact2;

        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            Type_of_Relationship__c = 'Mother',
           // RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890',
            Email = 'testMother@example.com'
        );
        insert contact3;
        
        // Create Contact with parent details
        Contact con = new Contact(
            LastName = 'Test Student',
            Email = 'student@example.com',
            father__c = contact2.id,
            Mother__c= contact3.id
        );
        insert con;
        
        
        Student_Fee__c fee = new Student_Fee__c(
            Name = 'SchedulableFee',
            Contact__c = con.Id,
            Fee_type__c = 'Hostel Fee',
            Amount__c = 5000,
            Amount_Paid__c = 0,
            Amount_Pending__c = 5000,
            Due_Date__c = Date.today(),
            Date_of_Joining_Hostel__c = Date.today().addDays(5)
        );
        insert fee;

        // Fake CMDT records for WhatsApp Notification Template
        List<Id> fakeIds = new List<Id>();
        for (Integer i = 0; i < 2; i++) {
            fakeIds.add(((SObject) new WhatsApp_Notification_Template__mdt(
                DeveloperName = 'SchedTemplate' + i,
                MasterLabel = 'Sched Template ' + i,
                Template_ID__c = (i == 0 ? 'hostel_fee_reminder_parent' : 'hostel_fee_due_parent'),
                Template_Field__c = 'due_date,remaining_amount'
            )).Id);
        }
        Test.setFixedSearchResults(fakeIds);

        // Run the schedulable class
        Test.startTest();
        String jobId = System.schedule(
            'TestSchedulableJob',
            '0 0 12 * * ?',
            new SchedulableHostelFeeReminderBatch()
        );
        Test.stopTest(); // This triggers the schedulable execute
       
        // Assert
        System.assertNotEquals(null, jobId, 'Schedulable job should be scheduled');
      
    }*/
    
    
}