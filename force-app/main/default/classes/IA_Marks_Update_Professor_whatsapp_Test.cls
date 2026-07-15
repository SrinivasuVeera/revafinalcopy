@isTest
public class IA_Marks_Update_Professor_whatsapp_Test {
    
    @isTest
    static void testTrsWhatsappNotification() {
        // Arrange
        // Create test data
        // Create a Contact (Primary Faculty)
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAcc = new Account(Name='TestAcc',Recordtypeid = UniversityRecId);
        insert objAcc;
        
        Contact faculty = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '7731030243',
            email='coindia@yopmail.com',
            AccountId = objAcc.Id
        );
        insert faculty;
        SYstem.debug('faculty=> '+faculty);
        
        hed__Program_Plan__c objProgPlan = new hed__Program_Plan__c();
        objProgPlan.Name = 'test program plan';
        objProgPlan.hed__Account__c = objAcc.Id;
        objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
        objProgPlan.hed__End_Date__c = system.today() + 2;
        insert objProgPlan;
       
        
        // Create a Term
        hed__Term__c term = new hed__Term__c(
            Name = 'Fall 2024',
            hed__Start_Date__c = Date.today().addMonths(-1),
            hed__End_Date__c = Date.today().addMonths(5),
            IA_2_End_date__c = Date.today().addMonths(1),
            Program_Batch__c = objProgPlan.id,
            hed__Account__c = objAcc.Id
        );
        insert term;
        
        // Create a Course
        hed__Course__c course = new hed__Course__c(
            Name = 'Computer Science 101',
            hed__Course_ID__c = 'CS101',
            hed__Account__c = objAcc.Id
        );
        insert course;
        
        // Create a Course Offering
        hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(
            Name = 'CS101 - Fall 2024',
            hed__Faculty__c = faculty.Id,
            hed__Term__c = term.Id,
            hed__Course__c = course.Id,
            IA_Marks_Update_Status__c = 'In Progress',
            IA_2_Marks_Update_Status__c = 'In Progress'
        );
        insert courseOffering;
        
        List<String> recordIds = new List<String>();
        recordIds.add(courseOffering.Id);
        List<List<String>> wrappedRecordIds = new List<List<String>>();
        wrappedRecordIds.add(recordIds);
        System.debug('wrappedRecordIds=> '+wrappedRecordIds);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        IA_Marks_Update_Professor_whatsapp.trsWhatsappNotification(wrappedRecordIds);
        Test.stopTest();
        
        // Assert
        // Verify that the batch job was enqueued by checking the Apex Job
       // List<AsyncApexJob> batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById 
//                                        FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'IA_Marks_Update_Professor_whatsapp_batch'];
      //  System.assert(batchJobs.size() > 0, 'Batch job should be enqueued.');
      //  System.assertEquals('Completed', batchJobs[0].Status, 'Batch job should be completed.');
    }
    
    @isTest
    static void testTrsWhatsappNotificationWithEmptyList() {
        // Arrange
        // Create an empty list of record Ids
        List<List<String>> wrappedRecordIds = new List<List<String>>();
        
        // Act
        Test.startTest();
        IA_Marks_Update_Professor_whatsapp.trsWhatsappNotification(wrappedRecordIds);
        Test.stopTest();
        
        // Assert
        // Verify no batch job was enqueued
       /* List<AsyncApexJob> batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById 
                                        FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'IA_Marks_Update_Professor_whatsapp_batch'];*/
       // System.assert(batchJobs.isEmpty(), 'No batch job should be enqueued for empty wrappedRecordIds list.');
    }
    
    @isTest
    static void testTrsWhatsappNotificationWithNullElement() {
        // Arrange
        // Create a list of record Ids with a null element
        List<String> recordIds = new List<String>();
        recordIds.add(null);
        List<List<String>> wrappedRecordIds = new List<List<String>>();
        wrappedRecordIds.add(recordIds);
        
        // Act
        Test.startTest();
        IA_Marks_Update_Professor_whatsapp.trsWhatsappNotification(wrappedRecordIds);
        Test.stopTest();
        
        // Assert
        // Verify no batch job was enqueued
    //    List<AsyncApexJob> batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById 
                                      //  FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'IA_Marks_Update_Professor_whatsapp_batch'];
        //System.assert(batchJobs.isEmpty(), 'No batch job should be enqueued for list containing null element.');
    }
    
    // Mock HTTP response generator
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status": "success", "data": {"resdata": [{"sem": "Semester", "examdate": "2024-05-15", "regno": "SA001", "subshort": "CRS001", "qpcode": "QP001", "doe": "15/05/2024", "session": "9:00 AM to 12:00 PM", "batch": "1"}]}}');     
            return res;
        }
    }
}