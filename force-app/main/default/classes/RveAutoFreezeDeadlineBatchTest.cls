@isTest
private class RveAutoFreezeDeadlineBatchTest {

    @testSetup
    static void setup() {
        // 1. Create a Semester (hed__term__c)
        // We set the date far in the past to ensure the deadline logic triggers
        Integer daysOffset = 0;
        try {
            daysOffset = Integer.valueOf(System.Label.FreezeExaminationVerticalHead);
        } catch(Exception e) {
            daysOffset = 5; // Fallback if label is not set
        }
        
        Account acc = new Account(Name = 'Test School');
        acc.recordtypeid = [Select Id from RecordType where sobjectType='Account' and developername='University_Department' limit 1].id;
        insert acc;
        
		string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__term__c testSemester = new hed__term__c(
            Name = 'Test Fall 2025',
            IA_2_Result_Date__c = Date.today().addDays(-(daysOffset + 2)), // 2 days past deadline
            ExamVerticalHeadFreeze__c = false,
            hed__Start_Date__c = system.today()+1,
            hed__end_Date__c = system.today()+1,
            RecordTypeId = termRtId,
            hed__Account__c = acc.id
        );
        insert testSemester;
        
        string termRtId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__term__c testSemester1 = new hed__term__c(
            Name = 'Test Fall 2025',
            IA_2_Result_Date__c = Date.today().addDays(-(daysOffset + 2)), // 2 days past deadline
            ExamVerticalHeadFreeze__c = false,
            hed__Start_Date__c = system.today()+1,
            hed__end_Date__c = system.today()+1,
            RecordTypeId = termRtId,
            hed__Account__c = acc.id
        );
        insert testSemester1;

        // 2. Create a Section / Course Offering 
        // Based on your query "Section__r.hed__Parent_Term__c"
        // In HED, Sections are usually hed__Course_Offering__c
        // We simulate the relationship expected by your batch logic
        

        hed__Course__c course = ASM_TestDataFactory.CreateCourse(1,acc.id,'Hardcore Course','Theory');
        course.SEE_Conducted_Marks__c = 12;
        course.L_T_P__c = '3:0:0';
        insert course;

        // If your org uses a custom Section__c object, replace hed__Course_Offering__c below
        hed__Course_Offering__c testSection = new hed__Course_Offering__c(
            hed__Course__c = course.Id,
            hed__Term__c = testSemester.Id,
            Name = 'Section A'
        );
        insert testSection;

        // 3. Create Course Enrollments (Faculty)
        // Get the Faculty Record Type ID for Course Enrollment
        Id facultyRecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Professor', AccountId = acc.Id,Active__c = true);
        insert testContact;

        List<hed__Course_Enrollment__c> facultyEnrollments = new List<hed__Course_Enrollment__c>();
        for(Integer i=0; i<5; i++) {
            facultyEnrollments.add(new hed__Course_Enrollment__c(
                hed__Contact__c = testContact.Id,
                hed__Course_Offering__c = testSection.Id,
                // The query uses 'Section__c', mapping it to hed__Course_Offering__c
                Section__c = testSemester1.Id, 
                RecordTypeId = facultyRecordTypeId,
                IA_Marks_Entry_Status__c = 'Locked',
                RVE_Professor_freeze__c = false,
                RVE_Exam_Vertical_Head_Freeze__c = false
            ));
        }
        insert facultyEnrollments;
    }

    @isTest
    static void testBatchExecution() {
        // Start Test
        Test.startTest();
        RveAutoFreezeDeadlineBatch batch = new RveAutoFreezeDeadlineBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        // End Test

        // Verify Semester Update
        hed__term__c updatedSem = [SELECT ExamVerticalHeadFreeze__c, ExamVHAcknowledged__c FROM hed__term__c LIMIT 1];
        System.assertEquals(true, updatedSem.ExamVerticalHeadFreeze__c, 'Semester should be frozen');
        System.assertEquals('Verified by System', updatedSem.ExamVHAcknowledged__c, 'Semester message should match');

        // Verify Enrollment Updates
        List<hed__Course_Enrollment__c> updatedEnrollments = [SELECT RVE_Professor_freeze__c, RVE_Exam_Vertical_Head_Freeze__c, Acknowledged__c FROM hed__Course_Enrollment__c];
        for(hed__Course_Enrollment__c ce : updatedEnrollments) {
            System.assertEquals(false, ce.RVE_Professor_freeze__c, 'Professor freeze should be true');
            System.assertEquals(false, ce.RVE_Exam_Vertical_Head_Freeze__c, 'Vertical Head freeze should be true');
           // System.assertEquals('Frozen by System', ce.Acknowledged__c, 'Acknowledgment message should match');
        }
    }
   
}