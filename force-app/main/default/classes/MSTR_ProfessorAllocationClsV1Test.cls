@isTest
public class MSTR_ProfessorAllocationClsV1Test {
    @testSetup
    static void setup() {
        string universityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        String batchRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
        String contactRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        String sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
        String groupRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();
        String facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account', universityRecId);
        insert objAccount;
        
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account 1', universityRecId);
        objAccount1.ParentId = objAccount.Id;
        insert objAccount1;
        
        /*Contact objContact = MSTR_TestDataFactory.createContact('Test Contact');
        objContact.Designation__c='Professor'; 
        objContact.RecordTypeId=contactRtId;
        objContact.Employee_Number__c = 'REVA15627';
        objContact.hed__WorkEmail__c ='testacdemicpro536fagg@gmail.com';
        objContact.Active__c=True;
        insert objContact; */
        
         Contact objContact = MSTR_TestDataFactory.createContact('test2tryeuee');
        objContact.AccountId = objAccount.id;
        objContact.FirstName  = 'Test2 Contact2';
        objContact.Employee_Number__c ='EP123745';
        objContact.RecordTypeId = contactRtId;
        objContact.Active__c = true;
        objContact.hed__WorkEmail__c  = 'test16767233trt@ex.com';
        insert objContact;
        
        hed__Program_Plan__c objProgramPlan = MSTR_TestDataFactory.CreateProgramPlan('Test Program Plan');
        objProgramPlan.hed__Account__c = objAccount1.Id;
        objProgramPlan.Intake__c = 120;
        objProgramPlan.Intake_Per_Section__c = 60;
        objProgramPlan.Batches_Per_Section__c = 2;
        insert objProgramPlan;
        
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('Test Term', objAccount1.Id, termRtId);
        objTerm.Program_Batch__c = objProgramPlan.Id;
        objTerm.Section_Number__c  = 1;
        objTerm.No_of_professor_per_Batch__c = 2;
        objTerm.Professors_Sections_Allotted__c = True; 
        objTerm.Approval_Status__c = 'Confirmed';        
        insert objTerm;
        
        hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('Test Term 1', objAccount1.Id, termRtId);
        objTerm1.Program_Batch__c = objProgramPlan.Id;
        objTerm1.Section_Number__c  = 1;
        objTerm1.hed__Parent_Term__c = objTerm.Id;
        insert objTerm1;
        
        hed__Term__c objTerm2 = MSTR_TestDataFactory.createTerm('Test Term 2', objAccount1.Id, batchRtId);
        objTerm2.Program_Batch__c = objProgramPlan.Id;
        objTerm2.Section_Number__c  = 1;
        objTerm2.hed__Parent_Term__c = objTerm1.Id;
        insert objTerm2;
        
        hed__Term__c objTerm3 = MSTR_TestDataFactory.createTerm('Test Term 3', objAccount1.Id, sectionRtId);
        objTerm3.Program_Batch__c = objProgramPlan.Id;
        objTerm3.Section_Number__c  = 1;        
        objTerm3.No_of_professor_per_Section__c = 2;        
        objTerm3.Approval_Status__c = 'Confirmed';
        objTerm3.hed__Parent_Term__c = objTerm.Id;
        insert objTerm3;
        
        
        hed__Course__c objCourse = MSTR_TestDataFactory.createCourse('Test Course', objAccount1.Id);
        objCourse.Credits__c = 3;
        objCourse.Offered_By_School__c = objAccount.Id;
        objCourse.Credit_Hours__c = 20;
        objCourse.Maximum_External_Marks__c = 100;
        objCourse.Total_Maximum_Marks_IA_External__c = 50;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='1:2:3';
        insert objCourse;
        
        hed__Course_Offering__c objCourseOffering = MSTR_TestDataFactory.createCourseOffering('Test Course Offering',  objTerm.Id,objCourse.Id);        
        objCourseOffering.Sequence__c = 1;
        objCourseOffering.hed__Course__c = objCourse.Id;
        objCourseOffering.Faculty_Course_Connection_Created__c = True;
        objCourseOffering.hed__Term__c = objTerm1.Id;
        objCourseOffering.Category__c = 'Practical/Term work';
        insert objCourseOffering;
        
        hed__Course_Offering__c objCourseOffering1 = MSTR_TestDataFactory.createCourseOffering('Test Course Offering 1',  objTerm.Id,objCourse.Id);        
        objCourseOffering1.Sequence__c = 1;
        objCourseOffering1.hed__Course__c = objCourse.Id;
        objCourseOffering1.Faculty_Course_Connection_Created__c = True;
        objCourseOffering1.hed__Term__c = objTerm.Id;
        objCourseOffering1.Category__c = 'Practical/Term work';
        insert objCourseOffering1;
        
        hed__Course_Offering__c objCourseOffering2 = MSTR_TestDataFactory.createCourseOffering('Test Course Offering 2',  objTerm.Id,objCourse.Id);        
        objCourseOffering2.Sequence__c = 1;
        objCourseOffering2.hed__Course__c = objCourse.Id;
        objCourseOffering2.Faculty_Course_Connection_Created__c = True;
        objCourseOffering2.hed__Term__c = objTerm.Id;
        objCourseOffering2.Category__c = 'Professional Elective';
        objCourseOffering2.Parent_Course_Offering__c = objCourseOffering1.Id;
        insert objCourseOffering2;
        
        hed__Course_Offering__c objCourseOffering3 = MSTR_TestDataFactory.createCourseOffering('Test Course Offering 3',  objTerm.Id,objCourse.Id);        
        objCourseOffering3.Sequence__c = 2;
        objCourseOffering3.hed__Course__c = objCourse.Id;
        objCourseOffering3.Faculty_Course_Connection_Created__c = True;
        objCourseOffering3.hed__Term__c = objTerm.Id;
        objCourseOffering3.Category__c = 'Professional Elective';
        objCourseOffering3.Parent_Course_Offering__c = objCourseOffering1.Id;
        insert objCourseOffering3;
        
        hed__Term__c objTerm4 = MSTR_TestDataFactory.createTerm('Test Term 4', objAccount1.Id, groupRtId);
        objTerm4.Program_Batch__c = objProgramPlan.Id;
        objTerm4.Group_Number__c = 1;        
        objTerm4.No_of_professor_per_Section__c = 2;        
        objTerm4.Approval_Status__c = 'Confirmed';
        objTerm4.hed__Parent_Term__c = objTerm.Id;
        objTerm4.Course_Offering__c = objCourseOffering.Id;
        insert objTerm4;
        
        hed__Term__c objTerm5 = MSTR_TestDataFactory.createTerm('Test Term 4', objAccount1.Id, groupRtId);
        objTerm5.Program_Batch__c = objProgramPlan.Id;
        objTerm5.Group_Number__c = 1;        
        objTerm5.No_of_professor_per_Section__c = 2;        
        objTerm5.Approval_Status__c = 'Confirmed';
        objTerm5.hed__Parent_Term__c = objTerm.Id;
        objTerm5.Course_Offering__c = objCourseOffering3.Id;
        insert objTerm5;
        
        
        hed__Course_Enrollment__c objCourseEnrollment = MSTR_TestDataFactory.createCourseEnrollment(objContact.Id,objCourseOffering.Id);
        objCourseEnrollment.Section__c = objTerm3.Id;
        objCourseEnrollment.RecordTypeId = facultyRtId;
        insert objCourseEnrollment;
        
        hed__Course_Enrollment__c objCourseEnrollment1 = MSTR_TestDataFactory.createCourseEnrollment(objContact.Id,objCourseOffering.Id);        
        insert objCourseEnrollment1;
        
        Professor_Student_Course_Preference__c objProfessorStudent = MSTR_TestDataFactory.CreateProfessorStudent('Test ProfStudentName', objCourseOffering.Id, objTerm.Id);
        objProfessorStudent.Preference__c = '1';
        objProfessorStudent.Professor__c=objContact.Id;
        objProfessorStudent.Course_Offering__c = objCourseOffering.Id;
        insert objProfessorStudent;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];
        
        User testUser = new User(
            Username = 'verticalheaduser@test.com',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test',
            LastName = 'User'
        );
        insert testUser;
        
    }
    
    @isTest
    static void testGetTermDetails() {
        hed__Term__c objTerm = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE Name = 'Test Term' LIMIT 1];        
        
        User testUser = [SELECT Id FROM User WHERE Username = 'verticalheaduser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            hed__Term__c result = MSTR_ProfessorAllocationClsV1.getTermDetails(objTerm.Id);            
            System.assertNotEquals(null, result, 'Expected a valid hed__Term__c record to be returned');
            System.assertEquals(objTerm.Id, result.Id, 'Expected the Ids to match');
        }        
    }
    
    @isTest
    static void testGetTermDetailsException() {
        Boolean exceptionThrown = false;
        User testUser = [SELECT Id FROM User WHERE Username = 'verticalheaduser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            try {                
                String invalidId = 'invalid_id';            
                
                MSTR_ProfessorAllocationClsV1.getTermDetails(invalidId);                    
                
            } catch (AuraHandledException e) {
                exceptionThrown = true;                
                System.assertEquals('Script-thrown exception', e.getMessage(),
                                    'Expected AuraHandledException message to be "Script-thrown exception"');                
            }
            
            System.assertEquals(true, exceptionThrown, 'AuraHandledException should be thrown for invalid Id');                    
            
        }
        
    }
    
    @isTest
    static void testGetProgramPlan() {
        hed__Term__c objTerm = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE Name = 'Test Term' LIMIT 1];                
        
        User testUser = [SELECT Id FROM User WHERE Username = 'verticalheaduser@test.com' LIMIT 1];                        
        
        System.runAs(testUser) {
            MSTR_ProfessorAllocationClsV1.MainCourseWrap result = MSTR_ProfessorAllocationClsV1.getProgramPlan(objTerm.Id);                        
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');            
            
        }
    }
    
    @isTest
    static void testMapCourses() {
        hed__Course_Offering__c courseOffering = [SELECT Id, Name, Sequence__c, hed__Course__c, hed__Course__r.Name, 
                                                  Faculty_Course_Connection_Created__c  
                                                  FROM hed__Course_Offering__c 
                                                  WHERE Name = 'Test Course Offering' LIMIT 1];
        
        User testUser = [SELECT Id FROM User WHERE Username = 'verticalheaduser@test.com' LIMIT 1];
        System.runAs(testUser) {
            MSTR_ProfessorAllocationClsV1.CourseWrap result = MSTR_ProfessorAllocationClsV1.mapCourses(courseOffering);
            
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');
            System.assertEquals(courseOffering.Id, result.courseOfferId, 'Expected the courseOfferingId to match');
            System.assertEquals(courseOffering.hed__Course__c, result.courseId, 'Returned Course Id should match');
            System.assertEquals('Test Course', result.courseName, 'Returned Course Name should match');
            //System.assertEquals('1.00', result.count, 'Returned Course count should match');
            System.assertEquals(True, result.isCourseOfferingConfirmed, 'Returned Course count should match');
        }
    }
    
    @isTest
    static void testMapCourseSection(){
        hed__Course_Offering__c courseOffering = [SELECT Id, Name, Sequence__c, hed__Course__c, hed__Course__r.Name,
                                                  hed__Term__r.Section_Name__c, Faculty_Course_Connection_Created__c, 
                                                  hed__Term__r.hed__Parent_Term__r.No_of_professor_per_Section__c  
                                                  FROM hed__Course_Offering__c
                                                  WHERE Name = 'Test Course Offering'
                                                  LIMIT 1];
        List<hed__Course_Enrollment__c> listCourseEnrollments = [SELECT Id, Name FROM hed__Course_Enrollment__c];
        
        Map <string,list<hed__Course_Enrollment__c>> mapProfessors = new Map <string,list<hed__Course_Enrollment__c>>();
        
        
        mapProfessors.put(courseOffering.hed__Course__c+'-'+courseOffering.hed__Term__r.Section_Name__c, listCourseEnrollments);
        
        User testUser = [SELECT Id FROM User WHERE Username = 'verticalheaduser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            MSTR_ProfessorAllocationClsV1.CourseSectionWrap result = MSTR_ProfessorAllocationClsV1.mapCourseSection(courseOffering, mapProfessors);
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');
        }
    }
    
    @isTest
    static void testGetPreferencesDetailsBatch(){
        hed__Term__c objTerm = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE Name = 'Test Term' LIMIT 1];        
        objTerm.Professors_Sections_Allotted__c = False;
        update objTerm;
        hed__Course_Offering__c courseOffering = [SELECT Id, Name, Sequence__c, hed__Course__c, hed__Course__r.Name, Faculty_Course_Connection_Created__c  FROM hed__Course_Offering__c WHERE Name = 'Test Course Offering' LIMIT 1];
        
        User testUser = [SELECT Id FROM User WHERE Username = 'verticalheaduser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            List<MSTR_ProfessorAllocationClsV1.BatchPreferenceWrapper> result = MSTR_ProfessorAllocationClsV1.getPreferencesDetailsBatch(objTerm.Id, courseOffering.Id, 'Practical/Term work');                        
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');            
        }      
    }
       
    @isTest
    static void testGetPreferencesDetailsTheory(){
        hed__Term__c objTerm = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE Name = 'Test Term' LIMIT 1];        
        hed__Course_Offering__c courseOffering = [SELECT Id, Name, Sequence__c, hed__Course__c, hed__Course__r.Name, Faculty_Course_Connection_Created__c  FROM hed__Course_Offering__c WHERE Name = 'Test Course Offering' LIMIT 1];
        
        User testUser = [SELECT Id FROM User WHERE Username = 'verticalheaduser@test.com' LIMIT 1];
        
        
        System.runAs(testUser) {
            List<MSTR_ProfessorAllocationClsV1.BatchPreferenceWrapper> result = MSTR_ProfessorAllocationClsV1.getPreferencesDetailsTheory(objTerm.Id, courseOffering.Id, 'Practical/Term work');                        
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');            
            
        }   
    }
    
    @isTest
    static void testGetPreferencesDetailsGroup(){
        hed__Term__c objTerm = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE Name = 'Test Term' LIMIT 1];        
        objTerm.Professors_Sections_Allotted__c = False;
        update objTerm;
        hed__Course__c objCourse = [SELECT Id, Name  FROM hed__Course__c WHERE Name = 'Test Course' LIMIT 1];
        
        User testUser = [SELECT Id FROM User WHERE Username = 'verticalheaduser@test.com' LIMIT 1];                
        
        
        System.runAs(testUser) {
            List<MSTR_ProfessorAllocationClsV1.BatchPreferenceWrapper> result = MSTR_ProfessorAllocationClsV1.getPreferencesDetailsGroup(objTerm.Id, objCourse.Id, 'Practical/Term work');                        
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');                        
        }   
    }
    
    @isTest
    static void testSaveProfessorPreferences(){        
        String batchRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
        String sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
        
        hed__Term__c objTermBatch = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE RecordTypeId =: batchRtId LIMIT 1];
        hed__Term__c objTermSection = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE RecordTypeId =: sectionRtId LIMIT 1];        
        Contact objContact = [SELECT Id,Active__c FROM Contact];
        hed__Course_Offering__c courseOffering = [SELECT Id, Name, Sequence__c, hed__Course__c, hed__Course__r.Name, Faculty_Course_Connection_Created__c  FROM hed__Course_Offering__c WHERE Name = 'Test Course Offering' LIMIT 1];
        hed__Course__c objCourse = [SELECT Id, Name  FROM hed__Course__c WHERE Name = 'Test Course' LIMIT 1];
        hed__Term__c objTermParent = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE Name = 'Test Term' LIMIT 1];        
        
        MSTR_ProfessorAllocationClsV1.ProfessorBatchWrapper saveWrapper = new MSTR_ProfessorAllocationClsV1.ProfessorBatchWrapper();
        
        saveWrapper.batchId = objTermBatch.Id;
        saveWrapper.sectionId = objTermSection.Id;
        saveWrapper.sectionCode='A';
        saveWrapper.batchCode='1';
        saveWrapper.isSectionLevelAllocationAllowed = True;
        saveWrapper.professorId=objContact.Id;
        saveWrapper.courseOffId=courseOffering.Id;
        saveWrapper.courseId=objCourse.Id;
        saveWrapper.termId=objTermParent.Id;
        saveWrapper.isPrimary=True;
        
        User testUser = [SELECT Id FROM User WHERE Username = 'verticalheaduser@test.com' LIMIT 1];                
    
        System.runAs(testUser) {
            MSTR_ProfessorAllocationClsV1.ResponseWrapper result = MSTR_ProfessorAllocationClsV1.saveProfessorPreferences(new List<MSTR_ProfessorAllocationClsV1.ProfessorBatchWrapper> {saveWrapper});
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');            
            System.assertEquals('Professor details saved successfully.', result.message, 'Expected message should be returned');
            System.assertEquals(True, result.success,'Expected success value should be returned');
        }   
    }
    @isTest
static void testGetProfessorPreferencesForCourse() {

    hed__Term__c objTerm = [
        SELECT Id
        FROM hed__Term__c
        WHERE Name = 'Test Term'
        LIMIT 1
    ];

    hed__Course__c objCourse = [
        SELECT Id
        FROM hed__Course__c
        WHERE Name = 'Test Course'
        LIMIT 1
    ];

    // Make sure Professor_Preference__c is true
    Professor_Student_Course_Preference__c pref =
    [
        SELECT Id, Professor_Preference__c
        FROM Professor_Student_Course_Preference__c
        LIMIT 1
    ];

    pref.Professor_Preference__c = true;
    update pref;

    User testUser = [
        SELECT Id
        FROM User
        WHERE Username = 'verticalheaduser@test.com'
        LIMIT 1
    ];

    System.runAs(testUser) {

        Test.startTest();

        List<MSTR_ProfessorAllocationClsV1.ProfessorPreferenceWrapper> result =
            MSTR_ProfessorAllocationClsV1.getProfessorPreferencesForCourse(
                objTerm.Id,
                objCourse.Id
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            result,
            'Result should not be null'
        );

        System.assert(
            result.size() > 0,
            'At least one preference record should be returned'
        );

        System.assertEquals(
            '1',
            result[0].preference,
            'Preference should match'
        );

        System.assertNotEquals(
            null,
            result[0].professorId,
            'Professor Id should be populated'
        );

        System.assertNotEquals(
            null,
            result[0].professorName,
            'Professor Name should be populated'
        );
    }
}
    
}