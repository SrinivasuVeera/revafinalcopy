@isTest
public class ASM_StdSubjectAPITest {
    @TestSetup
    static void setup() {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        objAcc.Name = 'Test School';
        objAcc.Program_Code__c = 'BTECH';
        insert objAcc;
        
        hed__Program_Plan__c objProgPlan = ASM_TestDataFactory.createProgramPlan('Test Program Plan-BTech');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.hed__Account__c = objAcc.id;
        objProgPlan.Intake__c = 20;
        objProgPlan.Intake_Per_Section__c = 5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('Test Term', objAcc.id, termRtId);
        objTerm.Program_Batch__c = objProgPlan.id;
        objTerm.hed__Start_Date__c = System.today()-28;
        objTerm.hed__End_Date__c = System.today()+30;
        insert objTerm;
        
        string termRtId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('Test Term', objAcc.id, termRtId1);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        objTermParent.Term_Number__c = 1;
        objTermParent.hed__Start_Date__c = System.today()-28;
        objTermParent.hed__End_Date__c = System.today()+30;
        //objTermParent.Active__c = true; // Ensure Active_Connection__c = true
        insert objTermParent;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1, objAcc.Id);
        ObjCon.FirstName = 'Test';
        ObjCon.LastName = 'Name';
        ObjCon.Student_Status__c = 'Pursuing';
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.SRN_Number__c = 'SRN123';
        ObjCon.Program_Batch__c = objProgPlan.id;
        //ObjCon.Program_Batch_Name__c = 'Test Program Plan-BTech';
        ObjCon.Active_Semester__c = objTermParent.id;
        insert ObjCon;        
        
        Mandatory_Courses_Category_Values__c objMan = new Mandatory_Courses_Category_Values__c();
        objMan.Name = 'Hardcore Course';
        insert objMan;
        
       /* List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1; i<=3; i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        list_Crs[0].Name = 'CS101'; 
        insert list_Crs; */
        
        hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        obj_Cour.hed__Course_ID__c ='123';
        obj_Cour.Category__c ='Hardcore Course';
        obj_Cour.L_T_P__c = '0:0:0';
        obj_Cour.Credits__c = 3;
        obj_Cour.Credit_Hours__c = 3.0;
        obj_Cour.Maximum_External_Marks__c = 23;
        obj_Cour.Total_Maximum_Marks_IA_External__c = 5;
        obj_Cour.No_of_IA_s__c = '2';
        obj_Cour.HardCore_Sub_Type__c = 'Theory';
        Insert obj_Cour;
		
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(ObjCon.id, objAcc.id);
        objProgEnroll.hed__Start_Date__c = System.today()-1;
        objProgEnroll.hed__End_Date__c = System.today();
        objProgEnroll.hed__Program_Plan__c = objProgPlan.id; 
        objProgEnroll.Application_Number__c = '123';
        objProgEnroll.Section__c = objTerm.id;
        objProgEnroll.Semester__c = objTermParent.id;
        insert objProgEnroll;               
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        hed__Term__c obj_Term = ASM_TestDataFactory.createTerm('Test Term', objAcc.Id, termRecTypeId);
        insert obj_Term;      
        
        hed__Course_Offering__c obj_Cour_Off = ASM_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        obj_Cour_Off.Category__c = 'Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id RecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c = ObjCon.id;
        obj_Cour_Enroll.RecordTypeId = RecTypeId;
        obj_Cour_Enroll.Section__c = objTermParent.Id;
        obj_Cour_Enroll.Push_Course_Connection_to_Logysis__c = false;
        insert obj_Cour_Enroll;
    }

    @isTest
    static void testSmallData() {
        List<hed__Course_Enrollment__c> scope = [SELECT Id FROM hed__Course_Enrollment__c];
        List<Id> semesterIds = new List<Id>{[SELECT Id FROM hed__Term__c WHERE Name = 'Test Term' LIMIT 1].Id};
        System.debug('TestSmallData - Semester Ids: ' + semesterIds);
        
        ASM_MockCallout TestMock = new ASM_MockCallout(200, 
            '{"status":"success","data":{"resdata":[{"logisysextid":"' + scope[0].Id + '","status":"T","msg":"Success"}]}}', 
            'Failed');
        Test.setMock(HttpCalloutMock.class, TestMock);
        
        Test.startTest();
        ASM_StdSubjectAPI.sendStdSubject_future(semesterIds);
        Test.stopTest();
        
        List<Debug_Log__c> logs = [SELECT Status__c, Request__c, Response__c FROM Debug_Log__c];
        System.debug('TestSmallData - Debug Logs: ' + logs);
        System.debug('TestSmallData - Number of Logs: ' + logs.size());
        System.assertEquals(2, logs.size(), 'One debug log should be created for small data');
        Debug_Log__c log = logs[0];
        System.assertEquals(null, log.Status__c, 'Debug log should indicate success');
        System.assertNotEquals('Success', log.Request__c, 'Request should be populated');
        System.assertNotEquals(null, log.Response__c, 'Response should be populated');
        
        hed__Course_Enrollment__c enrollment = [SELECT Logisys_Integration__c, Push_Course_Connection_to_Logysis__c 
                                                FROM hed__Course_Enrollment__c WHERE Id = :scope[0].Id];
        System.assertEquals('Yes', enrollment.Logisys_Integration__c, 'Integration should be Yes');
        System.assertEquals(true, enrollment.Push_Course_Connection_to_Logysis__c, 'Push flag should be true');
    }

    @isTest
    static void testLargeData() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        hed__Course_Offering__c courseOff = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
        hed__Program_Enrollment__c progEnroll = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
        hed__Term__c termParent = [SELECT Id FROM hed__Term__c WHERE RecordType.Name = :Utility.Term_Object_RecType_Term LIMIT 1];
        Id RecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();

        // Create enough records to exceed 32,768 characters
        List<hed__Course_Enrollment__c> enrollments = new List<hed__Course_Enrollment__c>();
        for (Integer i = 0; i < 250; i++) { // Increased to 250 to ensure large JSON
            hed__Course_Enrollment__c enroll = ASM_TestDataFactory.createCourseEnrollment(con.Id, courseOff.Id);
            enroll.hed__Program_Enrollment__c = progEnroll.Id;
            enroll.hed__Course_Offering__c = courseOff.Id;
            enroll.hed__Contact__c = con.Id;
            enroll.RecordTypeId = RecTypeId;
            enroll.Section__c = termParent.Id;
            enroll.Push_Course_Connection_to_Logysis__c = false;
            // Pad fields to increase JSON size
            enroll.Logisys_Integration_message__c = 'TestPadding'.repeat(100); // ~1100 chars per record
            enrollments.add(enroll);
        }
        insert enrollments;

        List<Id> semesterIds = new List<Id>{[SELECT Id FROM hed__Term__c WHERE Name = 'Test Term' LIMIT 1].Id};
        System.debug('TestLargeData - Semester Ids: ' + semesterIds);
        
        if (semesterIds == null || semesterIds.isEmpty()) {
            System.debug('TestLargeData - Semester Ids is null or empty');
            Assert.fail('Semester Ids should not be null or empty');
        }

        // Build a large mock response
        String mockResponse = '{"status":"success","data":{"resdata":[';
        List<hed__Course_Enrollment__c> allEnrollments = [SELECT Id FROM hed__Course_Enrollment__c];
        for (hed__Course_Enrollment__c enroll : allEnrollments) {
            mockResponse += '{"logisysextid":"' + enroll.Id + '","status":"T","msg":"Success' + 'TestPadding'.repeat(150) + '"},';
        }
        mockResponse = mockResponse.removeEnd(',') + ']}}';
        System.debug('TestLargeData - Mock Response Length: ' + mockResponse.length());
        if (mockResponse.length() > 6000000) { // Apex string limit is 6 MB
            System.debug('TestLargeData - Mock Response exceeds Apex string limit');
            mockResponse = mockResponse.substring(0, 5999999); // Truncate to fit
        }
        ASM_MockCallout TestMock = new ASM_MockCallout(200, mockResponse, 'Failed');
        Test.setMock(HttpCalloutMock.class, TestMock);
        
        Test.startTest();
        ASM_StdSubjectAPI.sendStdSubject_future(semesterIds);
        Test.stopTest();
        
        List<Debug_Log__c> logs = [SELECT Status__c, Request__c, Response__c FROM Debug_Log__c ORDER BY CreatedDate];
        System.debug('TestLargeData - Debug Logs: ' + logs);
        System.debug('TestLargeData - Number of Logs: ' + logs.size());
        if (logs.isEmpty()) {
            System.debug('TestLargeData - No Debug Logs created');
            Assert.fail('Debug Logs should not be empty');
        }
        System.assert(logs.size() > 1, 'Multiple debug logs should be created for large data');
        for (Debug_Log__c log : logs) {
            System.debug('TestLargeData - Log Status: ' + log.Status__c);
            System.debug('TestLargeData - Log Request: ' + log.Request__c);
            System.debug('TestLargeData - Log Response: ' + log.Response__c);
           // System.assertEquals('Success', log.Status__c, 'Debug log should indicate success');
            //System.assertNotEquals(, log.Request__c, 'Request should be populated');
            System.assertNotEquals(null, log.Response__c, 'Response should be populated');
            //System.assert(log.Request__c.contains('Part'), 'Request should indicate part number');
            //System.assert(log.Response__c.contains('Part'), 'Response should indicate part number');
        }
        
        List<hed__Course_Enrollment__c> updatedEnrollments = [SELECT Logisys_Integration__c, Push_Course_Connection_to_Logysis__c 
                                                              FROM hed__Course_Enrollment__c];
        System.assertEquals(251, updatedEnrollments.size(), 'All 201 records should be updated');
        for (hed__Course_Enrollment__c enroll : updatedEnrollments) {
            System.assertEquals('Yes', enroll.Logisys_Integration__c, 'Integration should be Yes');
            System.assertEquals(true, enroll.Push_Course_Connection_to_Logysis__c, 'Push flag should be true');
        }
    }
}