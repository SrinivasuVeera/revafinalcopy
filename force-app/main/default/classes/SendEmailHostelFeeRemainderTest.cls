@isTest
public class SendEmailHostelFeeRemainderTest {

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendEmailHostelFeeRemainderBatch() {
        // Setup test data
        Date today = System.today();
        Date joinDate = today.addDays(-35);

        // Create necessary data
        Account acc = new Account(Name = 'Test School');
        insert acc;

        hed__Program_Plan__c programBatch = new hed__Program_Plan__c();
        programBatch.Name = 'TestIAProgramBatch';
        programBatch.hed__Account__c = acc.Id;
        insert programBatch;

        String studentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();

        Contact student1 = new Contact();
        student1.LastName = 'Test Student 1';
        student1.MobilePhone = '9090909090';
        student1.Aadhar_Card_Number__c = '098765435612';
        student1.RecordTypeId = studentRecId;
        student1.Program_Batch__c = programBatch.Id;
        student1.Personal_Email__c = 'student1@example.com';
        student1.Nationality__c = 'Indian';
        insert student1;

        Contact student2 = new Contact();
        student2.LastName = 'Test Student 2';
        student2.MobilePhone = '9090909091';
        student2.Aadhar_Card_Number__c = '098765435613';
        student2.RecordTypeId = studentRecId;
        student2.Program_Batch__c = programBatch.Id;
        student2.Personal_Email__c = 'student2@example.com';
        student2.Nationality__c = 'Indian';
        insert student2;

        // Create test fee records - only create a small number of records
        List<Student_Fee__c> testFees = new List<Student_Fee__c>();

        testFees.add(new Student_Fee__c(
            Name = 'Fee 1',
            Student_Personal_Email__c = 'student1@example.com',
            Father_Email_ID__c = 'father1@example.com',
            Actual_Program_Fee__c = 1000.00,
            Amount__c = 1000.00,
            Amount_Paid__c = 0,
            Amount_Pending__c = 1000.00,
            Date_of_Joining_Hostel__c = joinDate,
            Payment_Type__c = 'Partial Payment'
        ));

        insert testFees;

        // Set the mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Execute the batch - ensure it only processes one batch
        Test.startTest();
        MissedMealScheduleFlow sch =new MissedMealScheduleFlow();
        System.schedule('Missed meal checking- I', '0 59 * * * ? ' , sch);
         SchedulableSendEmailHostelFeeRemainder schhsl =new SchedulableSendEmailHostelFeeRemainder();
        System.schedule('hostel remainder checking- I', '0 59 * * * ? ' , schhsl);
        SendEmailHostelFeeRemainder batch = new SendEmailHostelFeeRemainder();
        Database.executeBatch(batch, 1); // Use batch size of 1 to match the number of records
        Test.stopTest();
    }
}