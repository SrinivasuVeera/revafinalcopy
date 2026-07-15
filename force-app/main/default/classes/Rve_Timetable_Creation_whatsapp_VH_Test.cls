@isTest
public class Rve_Timetable_Creation_whatsapp_VH_Test {
    
    @isTest
    static void testTrsWhatsappNotification() {
        // Arrange
        // Create test data
        
        // Get the profile for Vertical Head
        Profile verticalHeadProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];
        
        // Create a User (Vertical Head)
        User verticalHead = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            Username = 'johndoe' + DateTime.now().getTime() + '@example.com',
            Alias = 'jdoe',
            CommunityNickname = 'jdoe',
            ProfileId = verticalHeadProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            MobilePhone = '1234567890'
        );
        insert verticalHead;
        
        // Create an Account
        Account schoolAccount = new Account(
            Name = 'Engineering School',
            Vertical_Head__c = verticalHead.Id
        );
        insert schoolAccount;
        
        // Create a Program Batch
        hed__Program_Plan__c objProgPlan = new hed__Program_Plan__c(
            Name = 'test program plan',
            hed__Account__c = schoolAccount.Id,
            hed__Start_Date__c = Date.today().addDays(-1),
            hed__End_Date__c = Date.today().addDays(2)
        );
        insert objProgPlan;
        
        // Create a Term
        hed__Term__c term = new hed__Term__c(
            Name = 'Fall 2024',
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
        insert term;
        
        List<String> recordIds = new List<String>{ term.Id };
        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Act
        Test.startTest();
        Rve_Timetable_Creation_whatsapp_VH.trsWhatsappNotification(new List<List<String>>{ recordIds });
        Test.stopTest();
        
        // Assert
        List<AsyncApexJob> batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById 
                                        FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'Rve_Timetable_Creation_whatsapp_VH_Batch'];
        System.assert(batchJobs.size() > 0, 'Batch job should be enqueued.');
        System.assertEquals('Completed', batchJobs[0].Status, 'Batch job should be completed.');
    }
    
    @isTest
    static void testTrsWhatsappNotificationWithNullElement() {
        // Arrange
        List<String> recordIds = new List<String>{ null };
        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Act
        Test.startTest();
        Rve_Timetable_Creation_whatsapp_VH.trsWhatsappNotification(new List<List<String>>{ recordIds });
        Test.stopTest();
        
        // Assert
        List<AsyncApexJob> batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById 
                                        FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'Rve_Timetable_Creation_whatsapp_VH_Batch'];
       // System.assert(batchJobs.isEmpty(), 'No batch job should be enqueued for list containing null element.');
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