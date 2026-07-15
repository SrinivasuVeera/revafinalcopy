@isTest
public class StudentFeeNotificationBatchTest {
    
    // Mock response generator for callouts
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
    public static void setupTestData() {
        
        
        
        //Account
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = 'B. Tech in Computer Science Engineering',
                                Program_Alias__c = 'BT-CS',
                                Program_Code__c = 'CS',
                                Program_Type__c = 'UG',
                                Intake_Per_Section__c = 60
                               ));
        insert accList;
        
        // Create RecordType for Contact if it doesn't exist
        Id studentRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1].Id;
        
        // Create test data for hed__Term__c
        List<hed__Term__c> terms = new List<hed__Term__c>();
        for (Integer i = 0; i < 2; i++) {
            terms.add(new hed__Term__c(
                Name = 'Term ' + i,
                hed__Start_Date__c = Date.today().addMonths(-3),
                hed__Account__c = accList[0].Id
            ));
        }
        insert terms;
        
        // Create test data for Contacts
        List<Contact> contList = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            contList.add(new Contact(
                LastName = 'Student' + i,
                MobilePhone = '1234567890',
                Active__c = true,
                Active_Semester__c = terms[0].Id,
                RecordTypeId = studentRecordTypeId
            ));
        }
        insert contList;
        
        // Create test data for Student_Fee__c
        List<Student_Fee__c> studentFeesList = new List<Student_Fee__c>();
        for (Contact c : contList) {
            studentFeesList.add(new Student_Fee__c(
                Contact__c = c.Id,
                Amount__c = 50000,
                Amount_Paid__c = 30000,
                Amount_Pending__c = 20000,//100 * Math.random(),
                Due_Date__c = Date.today().addMonths(2),
                Session__c = '1st Year'
            ));
        }
        insert studentFeesList;
        
        Test.startTest();
        //StudentFeeNotificationBatch sfBatch = new StudentFeeNotificationBatch();
        //sfBatch.sendWhatsAppNotifications(contList, studentFeesList, semesterPendingAmountMap);
        // Schedule the batch job
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String cronExp = '0 0 * * * ?';
        String jobId = System.schedule('Test Job', cronExp, new StudentFeeNotificationBatch());
        //Database.executebatch(new StudentFeeNotificationBatch());
        Test.stopTest();
    }
}



/*@isTest
static void testExecute() {
Test.startTest();

// Schedule the batch job
String cronExp = '0 0 * * * ?';
String jobId = System.schedule('Test Job', cronExp, new StudentFeeNotificationBatch());

// Assert that the job was scheduled
System.assertNotEquals(null, jobId);

// Execute the batch
StudentFeeNotificationBatch batch = new StudentFeeNotificationBatch();
ID batchId = Database.executeBatch(batch, 100);

// Assert that the batch job was executed
System.assertNotEquals(null, batchId);

Test.stopTest();
}

@isTest
static void testStart() {
Test.startTest();

// Execute the batch's start method and check the query
StudentFeeNotificationBatch batch = new StudentFeeNotificationBatch();
Database.QueryLocator ql = batch.start(null);
System.assertNotEquals(null, ql);

Test.stopTest();
}

@isTest
static void testExecuteBatch() {
Test.startTest();

// Fetch the test contacts
List<Contact> contacts = [SELECT Id, Name, MobilePhone, Active_Semester__c FROM Contact WHERE Active__c = true LIMIT 10];

// Execute the batch's execute method
StudentFeeNotificationBatch batch = new StudentFeeNotificationBatch();
batch.execute(null, contacts);

// Perform assertions on internal states like contactMap, semesterPendingAmountMap, etc.
System.assertNotEquals(0, batch.contactMap.size());
System.assertNotEquals(0, batch.semesterPendingAmountMap.size());
System.assertNotEquals(0, batch.studentFeeMap.size());

Test.stopTest();
}

@isTest
static void testFinish() {
Test.startTest();

// Execute the batch's finish method
StudentFeeNotificationBatch batch = new StudentFeeNotificationBatch();
batch.finish(null);

// Perform any necessary assertions
// (The finish method is currently empty, so there's not much to assert here)

Test.stopTest();
}

@isTest
static void testCallouts() {
// Test method for callout logic, using HttpCalloutMock or similar

Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

Test.startTest();

// Create some dummy data to pass to the sendWhatsAppNotifications method
Map<Id, List<Contact>> contactMap = new Map<Id, List<Contact>>();
Map<Id, List<Student_Fee__c>> studentFeeMap = new Map<Id, List<Student_Fee__c>>();
Map<Id, Decimal> semesterPendingAmountMap = new Map<Id, Decimal>();

// Invoke the method that performs the callout
RemainderFeeNotification.sendWhatsAppNotifications(contactMap, studentFeeMap, semesterPendingAmountMap);

Test.stopTest();

// Assert on the mock callout
// (Assertions depend on what the mock does)
}

// Mock response generator for callouts
private class MockHttpResponseGenerator implements HttpCalloutMock {
public HTTPResponse respond(HTTPRequest req) {
HttpResponse res = new HttpResponse();
res.setHeader('Content-Type', 'application/json');
res.setBody('{"status":"success"}');
res.setStatusCode(200);
return res;
}
}
}*/