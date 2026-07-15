@isTest
public class ASM_ProgramMasterFomSfAPITest {
    
    @testSetup
    static void setup() {
        // Create test data for Program Plans
       Account acc = new Account(Name='TestAcc');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        // Create Semester (hed__Term__c)
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.Term_Number__c = 1;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);  
        insert semester;
        
        // Create test data for Plan Requirements
        hed__Plan_Requirement__c planRequirement = new hed__Plan_Requirement__c(
            Name = 'Requirement 1',
            Semester__c = semester.Id
        );
        insert planRequirement;
    }
    
@IsTest
    static void testSendCourseDetails() {
        // List of semester Ids
        List<Id> programIds = new List<Id>{[SELECT Id FROM hed__Program_Plan__c LIMIT 1].Id};
        
        // Mock HTTP Callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the future method
        Test.startTest();
        ASM_ProgramMasterFomSfAPI.sendProgramDetails_future(programIds);
        Test.stopTest();
        
        // Verify the Debug Log record
        Debug_Log__c log = [SELECT Id, Status__c, Request__c, Response__c FROM Debug_Log__c WHERE Class_Name__c = 'ASM_ProgramMasterFomSfAPI' LIMIT 1];
      //  System.assertEquals('Success', log.Status__c);
    }
    
    // Mock HTTP Response Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","data":{"resdata":[{"totsub":null,"sem":"1","rtype":"I","degname":"B. Tech in Artificial Intelligence and Data Science","degcode":"B. Tech in Artificial Intelligence and Data Science-2021"}]}}');
            res.setStatusCode(200);
            return res;
        }
    }
}