@isTest
public class Push_Course_Logisys_whatsapp_Test {
    
    @isTest
    static void testTrsWhatsappNotification() {
        // Arrange
        // Create test data
        
        // Create a Contact (Vertical Head)
        Profile verticalHeadProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];
        
        // Create a User (Vertical Head)
        User verticalHead = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'coindia@yopmail.com',
            Username = 'johndoe' + DateTime.now().getTime() + '@example.com',
            Alias = 'jdoe',
            CommunityNickname = 'jdoe',
            ProfileId = verticalHeadProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            MobilePhone = '7731030243'
        );
        insert verticalHead;
        
        // Create a School
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account school = new Account(
            Name = 'Engineering School',
            Recordtypeid = UniversityRecId,
            Vertical_Head__c = verticalHead.Id
        );
        insert school;
        
       hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'test program plan';
        ProgramBatch.hed__Account__c = school.Id;
        insert ProgramBatch;
        
        // Create a Term
        hed__Term__c term = new hed__Term__c(
            Name = 'Fall 2024',
            hed__Start_Date__c = Date.today().addMonths(-1),
            hed__End_Date__c = Date.today().addMonths(5),
            IA_2_End_date__c = Date.today().addMonths(1),
            Program_Batch__c = ProgramBatch.id,
            hed__Account__c = school.Id,
            IA_1_Start_date__c = Date.today().addMonths(1)
        );
        insert term;
        
        // Create a Course
        hed__Course__c course = new hed__Course__c(
            Name = 'Computer Science 101',
            hed__Course_ID__c = 'CS101',
            hed__Account__c = school.Id
        );
        insert course;
        
        // Create a Course Offering
        hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(
            Name = 'CS101 - Fall 2024',
            hed__Term__c = term.Id,
            hed__Course__c = course.Id,
            Offered_By_School__c = school.Id,
            Trigger_Approval__c = false
        );
        insert courseOffering;
        
        List<String> recordIds = new List<String>();
        recordIds.add(courseOffering.Id);
        List<List<String>> wrappedRecordIds = new List<List<String>>();
        wrappedRecordIds.add(recordIds);
        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Act
        Test.startTest();
        Push_Course_Logisys_whatsapp.trsWhatsappNotification(wrappedRecordIds);
        Test.stopTest();
        
        // Assert
        List<AsyncApexJob> batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById 
                                        FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'Push_Course_Logisys_whatsapp_batch'];
        System.assert(batchJobs.size() > 0, 'Batch job should be enqueued.');
        System.assertEquals('Completed', batchJobs[0].Status, 'Batch job should be completed.');
    }
    
    @isTest
    static void testTrsWhatsappNotificationWithNullElement() {
        // Arrange
        List<String> recordIds = new List<String>();
        recordIds.add(null);
        List<List<String>> wrappedRecordIds = new List<List<String>>();
        wrappedRecordIds.add(recordIds);
        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Act
        Test.startTest();
        Push_Course_Logisys_whatsapp.trsWhatsappNotification(wrappedRecordIds);
        Test.stopTest();
        
        // Assert
        List<AsyncApexJob> batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById 
                                        FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'Push_Course_Logisys_whatsapp_batch'];
       // System.assert(batchJobs.isEmpty(), 'No batch job should be enqueued for list containing null element.');
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