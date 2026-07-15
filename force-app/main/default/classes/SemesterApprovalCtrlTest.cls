@isTest
private class SemesterApprovalCtrlTest {
    @testSetup
    static void setupData() {
        // Query RecordType safely
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'University_Department' LIMIT 1];
        // If no RecordType exists, create without it (adjust based on your org requirements)
        Account acc = new Account(Name = 'Test University Department');
        if (rt != null) {
            acc.RecordTypeId = rt.Id;
        }
        insert acc;
        
        hed__Term__c term = new hed__Term__c(
            Name = 'Fall Semester 2025',
            hed__Account__c = acc.Id
        );
        insert term;
        
        hed__Course__c course = new hed__Course__c(
            Name = 'Advanced Apex Programming',
            hed__Course_ID__c = 'CS-505',
            hed__Account__c = acc.Id,
            Category__c = 'Hardcore Course',
            Lcoursetype__c = 'AEC',
            HardCore_Sub_Type__c = 'Theory',
            Lmandatory__c = 'Mandatory',
            L_T_P__c = '3:1:0',
            Credits__c = 4.0,
            Credit_Hours__c = 40,
            No_of_IA_s__c = '1',
            Theory_Maximum_Marks__c = 1.0,
            Seminar_Maximum_Marks__c = 2.5,
            Quiz_Maximum_Marks__c = 1.5,
            Results_Max_Marks__c = 1.0,
            Continuous_Learning_Max_Marks__c = 5.0,
           // Maximum_Internal_Marks__c = 60,
            Maximum_External_Marks__c = 40,
            Total_Maximum_Marks_IA_External__c = 100,
            Lsubtype__c = 'Theory',
            Offered_By_School__c = acc.id
        );
        insert course;
        
        hed__Course_Offering__c offering = new hed__Course_Offering__c(
            Name = 'CS-505 Fall Offering',
            hed__Term__c = term.Id,
            hed__Course__c = course.Id
        );
        insert offering;
    }
    
    @isTest
    static void testGetCourseOfferings() {
        hed__Term__c term = [SELECT Id FROM hed__Term__c LIMIT 1];
        
        Test.startTest();
        List<SemesterApprovalCtrl.CourseWrapper> result = SemesterApprovalCtrl.getCourseOfferings(term.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result list should not be null');
        System.assertEquals(1, result.size(), 'Should return 1 course offering');
        
        SemesterApprovalCtrl.CourseWrapper item = result[0];
        System.assertEquals('CS-505', item.courseId, 'Course ID should match');
        System.assertEquals('Advanced Apex Programming', item.courseName, 'Course Name should match');
        System.assertEquals(4.0, item.credits, 'Credits should match');
        System.assertEquals(1.0, item.theoryMarks, 'Theory marks should match');
        System.assertEquals('Theory', item.lsubtype, 'Lsubtype should match');
        // Additional assertions for other fields if needed
    }
    
    @isTest
    static void testGetApprovalSteps_NoApproval() {
        hed__Term__c term = [SELECT Id FROM hed__Term__c LIMIT 1];
        
        Test.startTest();
        List<SemesterApprovalCtrl.ApprovalStep> steps = SemesterApprovalCtrl.getApprovalSteps(term.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, steps, 'Should return a list');
        // Typically empty if no approval process/submission
        System.assertEquals(0, steps.size(), 'No approval steps expected without submission');
    }
    
    @isTest
    static void testApprovalStepWrapperSorting() {
        SemesterApprovalCtrl.ApprovalStep step1 = new SemesterApprovalCtrl.ApprovalStep();
        step1.stepName = 'Step 1 (Oldest)';
        step1.createdDate = Datetime.now().addDays(-2);
        
        SemesterApprovalCtrl.ApprovalStep step2 = new SemesterApprovalCtrl.ApprovalStep();
        step2.stepName = 'Step 2 (Newest)';
        step2.createdDate = Datetime.now();
        
        SemesterApprovalCtrl.ApprovalStep step3 = new SemesterApprovalCtrl.ApprovalStep();
        step3.stepName = 'Step 3 (Null Date)';
        step3.createdDate = null;
        
        List<SemesterApprovalCtrl.ApprovalStep> steps = new List<SemesterApprovalCtrl.ApprovalStep>{step1, step2, step3};
            
            Test.startTest();
        steps.sort();
        Test.stopTest();
        
        System.assertEquals('Step 2 (Newest)', steps[0].stepName, 'Newest should be first');
        System.assertEquals('Step 1 (Oldest)', steps[1].stepName, 'Older should be second');
        System.assertEquals('Step 3 (Null Date)', steps[2].stepName, 'Null should be last');
    }
    
    @isTest
    static void testProcessAction_InvalidId() {
        Boolean exceptionCaught = false;
        
        Test.startTest();
        try {
            SemesterApprovalCtrl.processAction(null, 'Approve', 'Test Comments');
        } catch (Exception e) {
            exceptionCaught = true;
            // Expected: null workItemId or invalid ID
            //System.assert(e.getMessage().contains('Argument cannot be null') || e.getMessage().contains('invalid'), 'Expected exception for invalid workItemId');
        }
        Test.stopTest();
        
        System.assert(exceptionCaught, 'Exception should be thrown for invalid workItemId');
    }
    
    @isTest
    static void testApprovalLoop_Refactored() {
        // Create a Mock JSON structure mimicking the Query Result
        String mockJson = '[' +
            '{' +
            '"Id": "04g000000000001",' +
            '"StepsAndWorkitems": {' +
            '"totalSize": 1,' +
            '"done": true,' +
            '"records": [' +
            '{' +
            '"attributes": {"type": "ProcessInstanceStep"},' +
            '"Id": "04h000000000001",' +
            '"StepStatus": "Approved",' +
            '"Comments": "Looks good",' +
            '"CreatedDate": "2025-01-01T12:00:00.000+0000"' +
            '}' +
            ']' +
            '}' +
            '}' +
            ']';
        
        // Deserialize into SObjects
        List<ProcessInstance> mockData = (List<ProcessInstance>)JSON.deserialize(mockJson, List<ProcessInstance>.class);
        
        Test.startTest();
        // Call the helper method directly
        List<SemesterApprovalCtrl.ApprovalStep> results = SemesterApprovalCtrl.processApprovalSteps(mockData);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Approved', results[0].status);
    }
}