@IsTest
public class ASM_CourseMasterFomSfAPITest {
    
    @TestSetup
    static void setupTestData() {
        // Insert test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        // Create Semester (hed__Term__c)
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c = ProgramBatch.Id;
        semester.hed__Account__c = acc.Id;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);
        semester.Term_Number__c = 1;
        insert semester;
        System.debug('test semester>>' + semester);
        
        // Insert test Course
        /*hed__Course__c course = new hed__Course__c(Name = 'Test Course', hed__Course_ID__c = '12345', Credits__c = 3, L_T_P__c = 2,
                                                   HardCore_Sub_Type__c = 'Theory', Theory_Maximum_Marks__c = 20, Seminar_Maximum_Marks__c = 20, Quiz_Maximum_Marks__c = 5,
                                                   Category__c = 'Hardcore Course',
                                                   rve_OldCourseCode__c = 'OC001', hed__Account__c = acc.Id,Maximum_Internal_Marks__c=10);
        insert course;*/
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=1;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            if(i < 3){
                list_Crs.add(ASM_TestDataFactory.CreateCourse(i, acc.Id, cat));
            }else{
                hed__Course__c proj = ASM_TestDataFactory.CreateCourse(i, acc.Id, 'Hardcore Course');
                proj.HardCore_Sub_Type__c = 'Project';
                list_Crs.add(proj);
            }
            
        }
        list_Crs[0].hed__Course_ID__c = 'SUB01';
        Insert list_Crs;
        // Insert test Plan Requirement
        hed__Plan_Requirement__c planRequirement = new hed__Plan_Requirement__c(Name = 'Test Plan Requirement', Semester__c = semester.Id, hed__Course__c = list_Crs[0].Id);
        insert planRequirement;
    }
    
    @IsTest
    static void testSendCourseDetails() {
        // List of semester Ids
        List<Id> semesterIds = new List<Id>{[SELECT Id FROM hed__Term__c LIMIT 1].Id};
        
        // Mock HTTP Callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the future method
        Test.startTest();
        ASM_CourseMasterFomSfAPI.sendCourseDetails_future(semesterIds);
        Test.stopTest();
        
        // Verify the Debug Log record
        Debug_Log__c log = [SELECT Id, Status__c, Request__c, Response__c FROM Debug_Log__c WHERE Class_Name__c = 'ASM_CourseMasterFomSfAPI' LIMIT 1];
       // System.assertEquals('Success', log.Status__c);
    }
    @isTest
    static void testSendIAMarksFailure() {
        List<Id> semesterIds = new List<Id>{[SELECT Id FROM hed__Term__c LIMIT 1].Id};
        
            ASM_MockCallout TestMock = new ASM_MockCallout(200, '{"status":"failure","error_code":-1,"data":{"Exception"}}', 'Failed');
        Test.setMock(HttpCalloutMock.class, TestMock);

        Test.startTest();
        ASM_CourseMasterFomSfAPI.sendCourseDetails_future(semesterIds);
        Test.stopTest();
    }
    // Mock HTTP Response Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","error_code":0,"data":{"resdata":[{"subtype":"Theory","subshort":"Artificial Intelligence with python","subname":"Artificial Intelligence with python","subcode":"12345","sem":"1","rtype":"I","oldsubcode":null,"ltp":"2","iamaxmarks":"6","degcode":"B. Tech in CSE-2024","credit":"2.0","category":"Hardcore Course"}]}}');
            res.setStatusCode(200);
            return res;
        }
    }
}