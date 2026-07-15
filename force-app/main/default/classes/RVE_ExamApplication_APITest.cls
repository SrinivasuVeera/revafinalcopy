@isTest
public class RVE_ExamApplication_APITest {
    
    @isTest
    static void testSendExamApplication() {
        // Test data setup
        Account acc = new Account(Name = 'Test School',Program_Code__c='TC');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestIAProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        
        hed__Term__c Semester = new hed__Term__c(
            Name = 'TestSemester',
            hed__Account__c = acc.Id,
            hed__Start_Date__c = System.today(),
            hed__End_Date__c = System.today(),
            Term_Number__c = 1,
            Program_Batch__c = programbatch.Id
            
        );
        
        insert Semester;
        
        Contact testStudent = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            SRN_Number__c = 'SRN001',
            Active_Semester__c = Semester.Id,
            Program__c = 'Master of Business Administration in Human Resource',
            Primary_Academic_Program__c = acc.Id
        );
        insert testStudent;
        
        Rve_Exam_Application__c testExamApplication = new Rve_Exam_Application__c(
            Name = 'Test Exam Application',
            Rve_Student__c = testStudent.Id,
            Rve_Logisys_Field_Check__c=false
        );
        insert testExamApplication;
        
        Rve_Exam_Application_Line_Item__c testLineItem = new Rve_Exam_Application_Line_Item__c(
            Rve_Exam_Application__c = testExamApplication.Id,
            Course_Code__c = 'B20FA579',
            Rve_Subject__c = 'LINEAR ALGEBRA AND PARTIAL DIFFERENTIAL EQUATIONS'
        );
        insert testLineItem;
        
        Set<Id> testSetExamApplicationId = new Set<Id>{testExamApplication.Id};
            // Mock HTTP Callout
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method under test
        Test.startTest();
        RVE_ExamApplication_API.sendExamApplication(testSetExamApplicationId);
        Test.stopTest();
        
        // Verify debug log creation
        List<Debug_Log__c> debugLogs = [SELECT Id FROM Debug_Log__c WHERE Class_Name__c = 'RVE_ExamApplication_API' LIMIT 1];
        System.assertNotEquals(0, debugLogs.size(), 'Debug log should have been created');
        
        // Additional assertions can be added to verify specific behavior based on response
    }
    // Mock HTTP Response Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","data":{"resdata":[{"subtype":"Theory","subshort":"Artificial Intelligence with python","subname":"Artificial Intelligence with python","subcode":"12345","sem":"1","rtype":"I","oldsubcode":null,"ltp":"2","iamaxmarks":"6","degcode":"B. Tech in CSE-2024","credit":"2.0","category":"Hardcore Course"}]}}');
            res.setStatusCode(200);
            return res;
        }
    }
}