@isTest
public class ProfessorSubjectAllocationControllerTest {
    @testSetup
    static void setup() {        
        string universityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        String sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        String batchRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
        String groupRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();
        String facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
        
        Account objAcc = new Account();
        objAcc.Name = 'Test Account 1';
        objAcc.RecordTypeId = universityRecId;
        insert objAcc;
        
        hed__Term__c term1 = new hed__Term__c();
        term1.Name = 'Parent Sem-1';
        term1.Section_Number__c = 1;
        term1.hed__Account__c=objAcc.Id;
        insert term1;
        
        hed__Term__c term2 = new hed__Term__c();
        term2.Name = 'Section-1';
        term2.Section_Number__c  = 1;
        term2.hed__Parent_Term__c = term1.Id;
        term2.RecordTypeId = sectionRtId;
        term2.hed__Account__c=objAcc.Id;
        insert term2;
        
        hed__Term__c term3 = new hed__Term__c();
        term3.Name = 'section-2';
        term3.Section_Number__c  = 2;
        term3.hed__Parent_Term__c = term1.Id;
        term3.RecordTypeId = sectionRtId;
        term3.hed__Account__c=objAcc.Id;
        insert term3;
        
        
        hed__Term__c term4 = new hed__Term__c();
        term4.Name = 'Sec-1 Batch 1';            
        term4.hed__Parent_Term__c = term2.Id;
        term4.RecordTypeId = batchRtId;
        term4.hed__Account__c=objAcc.Id;
        insert term4;
        
        hed__Term__c term5 = new hed__Term__c();
        term5.Name = 'Sec-2 Batch 2';            
        term5.hed__Parent_Term__c = term3.Id;
        term5.RecordTypeId = batchRtId;
        term5.hed__Account__c=objAcc.Id;
        insert term5;
        
        
     /*   hed__Term__c term6 = new hed__Term__c();
        term6.Name = 'Test Term 6';        
        term6.Group_Number__c = 1;
        term6.hed__Parent_Term__c = term1.Id;
        term6.RecordTypeId = groupRtId;
        term6.hed__Account__c=objAcc.Id;
        insert term6;*/
        
        
        
        hed__Term__c term8 = new hed__Term__c();
        term8.Name = 'Test Term 8';        
        term8.Group_Number__c = 2;
        term8.hed__Parent_Term__c = term1.Id;        
        term8.hed__Account__c=objAcc.Id;
        term8.RecordTypeId = groupRtId;
        insert term8; 
        
        
        
        hed__Course__c course = new hed__Course__c();
        course.Name = 'Test course';
        course.hed__Account__c = objAcc.Id;
        course.Credits__c = 3;
        course.Offered_By_School__c = objAcc.Id;
        course.Credit_Hours__c = 20;
        course.Maximum_External_Marks__c = 100;
        course.Total_Maximum_Marks_IA_External__c = 50;
        course.No_of_IA_s__c = '1';
        course.L_T_P__c='1:2:3';
        insert course;
        
        
        hed__Course__c coursePrac = new hed__Course__c();
        coursePrac.Name = 'Test course';
        coursePrac.hed__Account__c = objAcc.Id;
        coursePrac.Credits__c = 3;
        coursePrac.Offered_By_School__c = objAcc.Id;
        coursePrac.Credit_Hours__c = 20;
        coursePrac.Maximum_External_Marks__c = 100;
        coursePrac.Total_Maximum_Marks_IA_External__c = 50;
        coursePrac.No_of_IA_s__c = '1';
        coursePrac.L_T_P__c='1:2:3';
        insert coursePrac;
        
        
        hed__Course__c coursetheory = new hed__Course__c();
        coursetheory.Name = 'Test course';
        coursetheory.hed__Account__c = objAcc.Id;
        coursetheory.Credits__c = 3;
        coursetheory.Offered_By_School__c = objAcc.Id;
        coursetheory.Credit_Hours__c = 20;
        coursetheory.Maximum_External_Marks__c = 100;
        coursetheory.Total_Maximum_Marks_IA_External__c = 50;
        coursetheory.No_of_IA_s__c = '1';
        coursetheory.L_T_P__c='1:2:3';
        insert coursetheory;
                
        
        hed__Course_Offering__c courseOffering1 = new hed__Course_Offering__c();
        courseOffering1.Name = 'Test Course Offer 1';
        courseOffering1.hed__Course__c = course.Id;
        courseOffering1.hed__Term__c = term1.Id;
        courseOffering1.Category__c = 'Professional Elective';
        insert courseOffering1;
        
        hed__Term__c term7 = new hed__Term__c();
        term7.Name = 'Test Term 7';
        term7.Section_Number__c = 2;
        term7.Group_Number__c = 1;
        term7.hed__Parent_Term__c = term1.Id;
        term7.RecordTypeId = groupRtId;
        term7.hed__Account__c=objAcc.Id;
        term7.Course_Offering__c=courseOffering1.Id;
        insert term7;
        
        hed__Course_Offering__c courseOffering2 = new hed__Course_Offering__c();
        courseOffering2.Name = 'Test Course Offer 2';
        courseOffering2.hed__Course__c = coursetheory.Id;
        courseOffering2.hed__Term__c = term1.Id;
        courseOffering2.Category__c = 'Hardcore Course';
        insert courseOffering2;
        
        hed__Course_Offering__c courseOffering3 = new hed__Course_Offering__c();
        courseOffering3.Name = 'Test Course Offer 3';
        courseOffering3.hed__Course__c = coursePrac.Id;
        courseOffering3.hed__Term__c = term1.Id;
        courseOffering3.Category__c = 'Practical/Term work';
        insert courseOffering3;
        
        
        hed__Course_Offering__c courseOffering4 = new hed__Course_Offering__c();
        courseOffering4.Name = 'Test Course Offer 2';
        courseOffering4.hed__Course__c = coursetheory.Id;
        courseOffering4.hed__Term__c = term2.Id;
        courseOffering4.Category__c = 'Hardcore Course';
        insert courseOffering4;
        
        hed__Course_Offering__c courseOffering5 = new hed__Course_Offering__c();
        courseOffering5.Name = 'Test Course Offer 3';
        courseOffering5.hed__Course__c = coursePrac.Id;
        courseOffering5.hed__Term__c = term2.Id;
        courseOffering5.Category__c = 'Practical/Term work';
        insert courseOffering5;
        
       /* hed__Course_Offering__c courseOffering4 = new hed__Course_Offering__c();
        courseOffering4.Name = 'Test Course Offer 4';
        courseOffering4.hed__Course__c = course.Id;
        courseOffering4.hed__Term__c = term8.Id;
        courseOffering4.Category__c = 'Practical/Term work';
        insert courseOffering4; */
        
        
        Contact objCon = new Contact();
        objCon.FirstName = 'Test';
        objCon.LastName = 'Contact 1';
        objCon.Active__c = True;
        insert objCon;
        
        hed__Term__c batchTerm = [SELECT Id, Batch_Number__c FROM hed__Term__c WHERE RecordTypeId =:batchRtId LIMIT 1];
        
        hed__Course_Enrollment__c courseEnrollment1 = new hed__Course_Enrollment__c();
        courseEnrollment1.hed__Course_Offering__c = courseOffering2.Id;
        courseEnrollment1.RecordTypeId = facultyRtId;
        courseEnrollment1.hed__Contact__c = objCon.Id;
        courseEnrollment1.Allotted_Section__c='A';        
        courseEnrollment1.Section__c = term1.Id;
        //courseEnrollment1.Allotted_Batch_Number__c = String.valueof(batchTerm.Batch_Number__c);
        insert courseEnrollment1;
        
        
        hed__Course_Enrollment__c courseEnrollment2 = new hed__Course_Enrollment__c();
        courseEnrollment2.hed__Course_Offering__c = courseOffering3.Id;
        //courseEnrollment2.RecordTypeId = facultyRtId;
        courseEnrollment2.hed__Contact__c = objCon.Id;
        courseEnrollment2.Allotted_Section__c='B';
        courseEnrollment2.Section__c = term2.Id;
        courseEnrollment2.Allotted_Batch_Number__c = String.valueof(term4.Batch_Number__c);
        insert courseEnrollment2;
        
        
        
        hed__Course_Enrollment__c courseEnrollment3 = new hed__Course_Enrollment__c();
        courseEnrollment3.hed__Course_Offering__c = courseOffering1.Id;
        courseEnrollment3.RecordTypeId = facultyRtId;
        courseEnrollment3.hed__Contact__c = objCon.Id;
        courseEnrollment3.Allotted_Section__c='A';
        courseEnrollment3.Section__c = term1.Id;
        insert courseEnrollment3;
        
        
       
        //courseEnrollment4.Allotted_Batch_Number__c = String.valueof(batchTerm.Batch_Number__c);
       // insert courseEnrollment4;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];
        
        User testUser = new User(
            Username = 'sysadminuser@test.com',
            Email = 'sysadminuser@email.com',
            Alias = 'sysadmin',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test System Admin',
            LastName = 'User'
        );
        insert testUser;
        
    }
    
    @isTest
    static void testProfessorSubjectSecAllot(){
        hed__Term__c objTerm = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE Name = 'Parent Sem-1' LIMIT 1];		
        
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            List<hed__Course_Enrollment__c> courseConnections = [SELECT Id FROM hed__Course_Enrollment__c];
            
            String result = ProfessorSubjectAllocationController.professorSubjectSecAllot(objTerm.Id);            
            System.assertNotEquals(null, result, 'Expected a valid Status message to be returned');            
            System.assert(result.startsWith('Allocation completed At Section/Batch/Group. New connections moved :'), 'Expected allocation completion message to be returned');
            System.assert(courseConnections.size() > 0, 'Expected at least one course connection created.');
        }
    }
    
    @isTest
    static void testProfessorSubjectSecAllotElective(){
        hed__Term__c objTerm = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE Name = 'Parent Sem-1' LIMIT 1];        
        
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            List<hed__Course_Enrollment__c> courseConnections = [SELECT Id FROM hed__Course_Enrollment__c];
                   
            
            String result = ProfessorSubjectAllocationController.professorSubjectSecAllot(objTerm.Id);
            System.assertNotEquals(null, result, 'Expected a valid Status message to be returned');            
            System.assert(result.startsWith('Allocation completed At Section/Batch/Group. New connections moved :'), 'Expected allocation completion message to be returned');
            System.assert(courseConnections.size() > 0, 'Expected at least one course connection created.');
        }
    }
    
    @isTest
    static void testNullParentTerm(){
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {                        
            String result = ProfessorSubjectAllocationController.professorSubjectSecAllot(null);
            System.assertNotEquals(null, result, 'Result should not be null');            
            System.assertEquals('Parent Term Id is required.', result, 'Expected a valid Status message to be returned');
        }
    }
    
    @isTest
    static void testEmptyParentConnections(){
        hed__Term__c objTerm = [SELECT Id, Name, Program_Batch__c FROM hed__Term__c WHERE Name = 'Test Term 8' LIMIT 1];
        
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            String result = ProfessorSubjectAllocationController.professorSubjectSecAllot(objTerm.Id);
            System.assertNotEquals(null, result, 'Result should not be null');            
            System.assertEquals('No professor course connections exist in Parent Semester.', result, 'Expected a valid Status message to be returned');
        }
    }
       
    
}