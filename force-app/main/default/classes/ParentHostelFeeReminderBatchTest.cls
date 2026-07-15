@isTest
public class ParentHostelFeeReminderBatchTest {
    
    // Mock class for WhatsApp callout
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    static void setupData() {
        
          // Create Parent Contacts
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
        
        // Create a Reminder student fee (days <= 0)
        Student_Fee__c feeReminder = new Student_Fee__c(
            Name = 'ReminderFee',
            Contact__c = con.Id,
            Fee_type__c = 'Hostel Fee',
            Amount__c = 10000,
            Amount_Paid__c = 2000,
            Amount_Pending__c = 8000,
            Due_Date__c = Date.today().addDays(-10),
            Date_of_Joining_Hostel__c  = Date.today().addDays(-55)
        );
        
        // Fee Student (1 to 60 days)
        Student_Fee__c feeDue = new Student_Fee__c(
            Name = 'DueFee',
            Contact__c = con.Id,
            Fee_type__c = 'Hostel Fee',
            Amount__c = 15000,
            Amount_Paid__c = 5000,
            Amount_Pending__c = 10000,
             Due_Date__c = Date.today().addDays(-10),
            Date_of_Joining_Hostel__c  = Date.today().addDays(-85)
        );
        
        // Blocked Student (> 60 days)
        Student_Fee__c feeBlocked = new Student_Fee__c(
            Name = 'BlockedFee',
            Contact__c = con.Id,
            Fee_type__c = 'Hostel Fee',
            Amount__c = 20000,
            Amount_Paid__c = 0,
            Amount_Pending__c = 20000,
           Due_Date__c = Date.today().addDays(-10),
            Date_of_Joining_Hostel__c  = Date.today().addDays(-85)
        );
        
        insert new List<Student_Fee__c>{ feeReminder, feeDue, feeBlocked };
        
        // Penalty record for FeeStudent case
        Student_Fee__c penalty = new Student_Fee__c(
            Name = 'Penalty',
            Fee_Type__c = 'Hostel Fee',
            Student_Hostel_Fee__c = feeDue.Id,
            Amount__c = 500,
            Amount_Paid__c = 0,
            Amount_Pending__c = 500,
            Due_Date__c = Date.today()
        );
        insert penalty;
        
        // Fake Custom Metadata using Test.setFixedSearchResults
        // (We can’t insert CMDT in tests, so we use this trick)
        List<Id> fakeIds = new List<Id>();
        for (Integer i = 0; i < 3; i++) {
            fakeIds.add(((SObject) new WhatsApp_Notification_Template__mdt(
                DeveloperName = 'TestTemplate' + i,
                MasterLabel = 'Test Template ' + i,
                Template_ID__c = (i == 0 ? 'hostel_fee_reminder_parent' :
                                 i == 1 ? 'hostel_fee_due_parent' :
                                          'hostel_meal_blocked_parent'),
                Template_Field__c = 'due_date,remaining_amount,penalty_fee,fine_amount'
            )).Id);
        }
        Test.setFixedSearchResults(fakeIds);
    }
    
    @isTest
    static void testBatchExecution() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        Database.executeBatch(new ParentHostelFeeReminderBatch(), 50);
        
          String jobId = System.schedule(
            'TestSchedulableJob',
            '0 0 12 * * ?',
            new SchedulableHostelFeeReminderBatch()
        );
        Test.stopTest();
        
      
    }
}