@isTest
public class PartialPAFPaymentBatchTest {

    // Mock class for HTTP callouts
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // You can customize the response as needed for testing
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup
    static void createTestData() {
        RecordType applicantRT = [Select id FROM RecordType Where DeveloperName = 'Applicant' Limit 1];
        /*
        Create Applicant Contact
        */
        Contact applicant = new Contact(
            LastName = 'Applicant Test',
            Email = 'applicant@test.com',
            MobilePhone = '9876543210',
            RecordTypeId = applicantRT.Id
        );
        insert applicant;
        
        /*
        Create Application
        */
        hed__Application__c app = new hed__Application__c(
            hed__Applicant__c = applicant.Id,
            Partial_Paid__c = true,
            Provisional_Admission_Fee_Paid__c = false,
            First_Payment_Date__c = Date.newInstance(2026, 6, 16)
        );
        insert app;
        
        /*
        Create Student Fee
        */
        Student_Fee__c fee = new Student_Fee__c(
            Contact__c = applicant.Id,
            Fee_Year__c = '1st year',
            Fee_Type__c = 'Tuition Fee',
            Provisional_Admission_Fee__c = 50000,
             Amount__c = 50000
        );
        insert fee;
        
        /*
        Existing Success Payment
        Remaining should become:
        50000 - 10000 = 40000
        */
        Student_Payment__c successPayment = new Student_Payment__c(
            //Student_Fee__c = fee.Id,
            Amount__c = 10000,
            Payment_Status__c = 'Success'
        );
        insert successPayment;
    }
    
    @isTest
    static void testBatchCreatesPendingPayment() {
        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        PartialPAFPaymentBatch batchObj = new PartialPAFPaymentBatch();
        Database.executeBatch(batchObj, 1);
        
        Test.stopTest();
        
        /*
        Verify Student Payment Created
        */
        List<Student_Payment__c> paymentList = [
            SELECT Id,
                   Contact__c,
                   Amount__c,
                   Payment_Status__c,
                   Duplication_PAF__c
            FROM Student_Payment__c
        ];

        
        Student_Payment__c payment = paymentList[0];
        
    }
    
    @isTest
    static void testBatchNoDuplicatePendingPayment() {
        
        Contact con = [
            SELECT Id
            FROM Contact
            LIMIT 1
        ];
        
        /*
        Existing Pending Payment
        */
        Student_Payment__c existingPending = new Student_Payment__c(
            Contact__c = con.Id,
            Amount__c = 40000,
            Payment_Status__c = 'Pending',
            Payment_Mode_Type__c = 'Online',
            Mode_of_Payment__c = 'Online'
        );
        insert existingPending;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Database.executeBatch(new PartialPAFPaymentBatch(), 1);
        
        Test.stopTest();
        
        }
    
 
 @isTest
    static void testSchedulerExecutesBatch() {
        
        String cronExp = '0 0 0 15 8 ? 2026';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        String jobId = System.schedule(
            'Partial PAF Scheduler Test1',
            cronExp,
            new PartialPAFPaymentScheduler()
        );
        
        Test.stopTest();
        
    }

 @isTest
    static void testSchedulerExecutesBatch1() {
                
        Contact con = [
            SELECT Id
            FROM Contact
            LIMIT 1
        ];
        Student_Payment__c existingPending = new Student_Payment__c(
            Contact__c = con.Id,
            Amount__c = 40000,
            Payment_Status__c = 'Pending',
            Payment_Mode_Type__c = 'Online',
            Duplication_PAF__c = true
        );
        insert existingPending;
        String cronExp = '0 0 0 15 8 ? 2026';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
         String jobId1 = System.schedule(
            'Partial PAF Scheduler Test11',
            cronExp,
            new PartialPAFReminderScheduler()
        );
        
        Test.stopTest();
        
    }

}