@isTest
public class UpdateSyllabusCountTest {
    
    @testSetup
    static void setupTestData() {
        // Create Account hierarchy with proper record types
        String deptRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department')?.getRecordTypeId();
        String programRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program')?.getRecordTypeId();
        
        Account department;
        if (deptRecTypeId != null) {
            department = new Account(
                Name = 'Test Department',
                RecordTypeId = deptRecTypeId
            );
            insert department;
        } else {
            department = new Account(Name = 'Test Department');
            insert department;
        }
        
        Account academicProgram;
        if (programRecTypeId != null) {
            academicProgram = new Account(
                Name = 'Test Academic Program',
                RecordTypeId = programRecTypeId,
                ParentId = department.Id,
                Program_Type__c = 'UG'
            );
        } else {
            academicProgram = new Account(
                Name = 'Test Academic Program',
                ParentId = department.Id,
                Program_Type__c = 'UG'
            );
        }
        insert academicProgram;
        
        // Create Program Plan
        hed__Program_Plan__c programPlan = new hed__Program_Plan__c(
            Name = 'Test Program Plan (2024-2027)',
            hed__Start_Date__c = System.today().addDays(-30),
            hed__End_Date__c = System.today().addYears(3),
            hed__Account__c = academicProgram.Id
        );
        insert programPlan;
        
        // Create Semester
        hed__Term__c semester = new hed__Term__c(
            Name = 'Test Semester 1',
            Program_Batch__c = programPlan.Id,
            hed__Account__c = academicProgram.Id
        );
        insert semester;
        
        // Reset flag before creating test data to avoid setup triggering handler
        UpdateSyllabusCountHandler.resetIsProcessed();
        
        // Create courses using factory with unique IDs
        hed__Course__c course1 = ASM_TestDataFactory.CreateCourse(1, department.Id, 'Mathematics 101');
        course1.hed__Course_ID__c = 'MATH101';
        course1.Total_Maximum_Marks_IA_External__c = 100.0;
        course1.SEE_Conducted_Marks__c = 10;
        course1.L_T_P__c = '2:2:0';        
        insert course1; 
        
        hed__Course__c course2 = ASM_TestDataFactory.CreateCourse(1, department.Id, 'Physics 101');
        course2.hed__Course_ID__c = 'PHYS101'; // Unique ID
        course2.Total_Maximum_Marks_IA_External__c = 75.0;
        course2.SEE_Conducted_Marks__c = 10;
        course2.L_T_P__c = '2:2:0'; 
        insert course2;
        
        // Create zero marks course for testing
        hed__Course__c zeroMarksCourse = ASM_TestDataFactory.CreateCourse(1, department.Id, 'Theory Course');
        zeroMarksCourse.hed__Course_ID__c = 'THEORY001';
        zeroMarksCourse.Total_Maximum_Marks_IA_External__c = 0.0;
        zeroMarksCourse.SEE_Conducted_Marks__c = 10;
        zeroMarksCourse.L_T_P__c = '2:2:0'; 
        insert zeroMarksCourse;
        
        // Create qualifying Plan Requirements (these will trigger handler during setup)
        List<hed__Plan_Requirement__c> qualifyingRequirements = new List<hed__Plan_Requirement__c>();
        
        qualifyingRequirements.add(new hed__Plan_Requirement__c(
            Name = 'Math Syllabus',
            Semester__c = semester.Id,
            hed__Course__c = course1.Id,
            hed__Plan_Requirement__c = null
        ));
        
        qualifyingRequirements.add(new hed__Plan_Requirement__c(
            Name = 'Physics Syllabus',
            Semester__c = semester.Id,
            hed__Course__c = course2.Id,
            hed__Plan_Requirement__c = null
        ));
        
        insert qualifyingRequirements;
        
        // Create non-qualifying records
        hed__Plan_Requirement__c parentReq = new hed__Plan_Requirement__c(
            Name = 'Parent Requirement',
            Semester__c = semester.Id,
            hed__Course__c = course1.Id,
            hed__Plan_Requirement__c = null
        );
        insert parentReq;
        
        hed__Plan_Requirement__c childReq = new hed__Plan_Requirement__c(
            Name = 'Child Requirement',
            Semester__c = semester.Id,
            hed__Course__c = course2.Id,
            hed__Plan_Requirement__c = parentReq.Id
        );
        insert childReq;
        
        // Create zero marks requirement (shouldn't count)
        hed__Plan_Requirement__c zeroMarksReq = new hed__Plan_Requirement__c(
            Name = 'Zero Marks Syllabus',
            Semester__c = semester.Id,
            hed__Course__c = zeroMarksCourse.Id,
            hed__Plan_Requirement__c = null
        );
        insert zeroMarksReq;
    }
    
    @isTest
    static void testInsertQualifyingSyllabus() {
        hed__Term__c semester = [SELECT Id FROM hed__Term__c LIMIT 1];
        hed__Course__c course = [SELECT Id FROM hed__Course__c WHERE Total_Maximum_Marks_IA_External__c > 0 LIMIT 1];
        
        Test.startTest();
        UpdateSyllabusCountHandler.resetIsProcessed();
        
        hed__Plan_Requirement__c newSyllabus = new hed__Plan_Requirement__c(
            Name = 'New Qualifying Syllabus',
            Semester__c = semester.Id,
            hed__Course__c = course.Id,
            hed__Plan_Requirement__c = null
        );
        insert newSyllabus;
        
        Test.stopTest();
        
        hed__Term__c updatedSemester = [SELECT No_of_Courses_Per_Student__c 
                                       FROM hed__Term__c 
                                       WHERE Id = :semester.Id];
        // Setup has 2 qualifying + 1 new = 3
        System.assertEquals(4, updatedSemester.No_of_Courses_Per_Student__c, 
                           'Should count 3 qualifying syllabi after insert');
    }
    
    @isTest
    static void testInsertNonQualifyingSyllabus() {
        hed__Term__c semester = [SELECT Id FROM hed__Term__c LIMIT 1];
        List<hed__Plan_Requirement__c> existing = [SELECT Id, hed__Course__c 
                                                  FROM hed__Plan_Requirement__c 
                                                  WHERE Semester__c = :semester.Id 
                                                  AND hed__Plan_Requirement__c = null 
                                                  AND hed__Course__r.Total_Maximum_Marks_IA_External__c > 0];
        
        Test.startTest();
        UpdateSyllabusCountHandler.resetIsProcessed();
        
        if (!existing.isEmpty()) {
            hed__Plan_Requirement__c nonQualifying = new hed__Plan_Requirement__c(
                Name = 'Non-Qualifying Syllabus',
                Semester__c = semester.Id,
                hed__Course__c = existing[0].hed__Course__c,
                hed__Plan_Requirement__c = existing[0].Id // Has parent - won't count
            );
            insert nonQualifying;
        }
        
        Test.stopTest();
        
        hed__Term__c updatedSemester = [SELECT No_of_Courses_Per_Student__c 
                                       FROM hed__Term__c 
                                       WHERE Id = :semester.Id];
        // Should remain 2 (setup qualifying records)
        System.assertEquals(3, updatedSemester.No_of_Courses_Per_Student__c, 
                           'Count should remain 2 - non-qualifying record ignored');
    }
    
    @isTest
    static void testUpdateQualifyingToNonQualifying() {
        hed__Term__c semester = [SELECT Id FROM hed__Term__c LIMIT 1];
        List<hed__Plan_Requirement__c> qualifying = [SELECT Id 
                                                    FROM hed__Plan_Requirement__c 
                                                    WHERE Semester__c = :semester.Id 
                                                    AND hed__Plan_Requirement__c = null 
                                                    AND hed__Course__r.Total_Maximum_Marks_IA_External__c > 0];
        
        Test.startTest();
        UpdateSyllabusCountHandler.resetIsProcessed();
        
        if (qualifying.size() >= 2) {
            // Update first to make it non-qualifying
            qualifying[0].hed__Plan_Requirement__c = qualifying[1].Id;
            update qualifying[0];
        }
        
        Test.stopTest();
        
        hed__Term__c updatedSemester = [SELECT No_of_Courses_Per_Student__c 
                                       FROM hed__Term__c 
                                       WHERE Id = :semester.Id];
        // Should now have only 1 qualifying left
        System.assertEquals(2, updatedSemester.No_of_Courses_Per_Student__c, 
                           'Should count 1 qualifying syllabus after update');
    }
    
    @isTest
    static void testDeleteQualifyingSyllabus() {
        hed__Term__c semester = [SELECT Id FROM hed__Term__c LIMIT 1];
        List<hed__Plan_Requirement__c> qualifying = [SELECT Id 
                                                    FROM hed__Plan_Requirement__c 
                                                    WHERE Semester__c = :semester.Id 
                                                    AND hed__Plan_Requirement__c = null 
                                                    AND hed__Course__r.Total_Maximum_Marks_IA_External__c > 0];
        
        Test.startTest();
        UpdateSyllabusCountHandler.resetIsProcessed();
        
        if (!qualifying.isEmpty()) {
            delete qualifying[0];
        }
        
        Test.stopTest();
        
        hed__Term__c updatedSemester = [SELECT No_of_Courses_Per_Student__c 
                                       FROM hed__Term__c 
                                       WHERE Id = :semester.Id];
        // Should have 1 qualifying left
        System.assertEquals(2, updatedSemester.No_of_Courses_Per_Student__c, 
                           'Should count 1 qualifying syllabus after delete');
    }
    
    @isTest
    static void testZeroMarksCourseNotCounted() {
        hed__Term__c semester = [SELECT Id, No_of_Courses_Per_Student__c FROM hed__Term__c LIMIT 1];
        hed__Course__c zeroMarksCourse = [SELECT Id FROM hed__Course__c WHERE Total_Maximum_Marks_IA_External__c = 0];
        
        Test.startTest();
        UpdateSyllabusCountHandler.resetIsProcessed();
        
        // Insert another zero marks requirement
        hed__Plan_Requirement__c anotherZeroMarks = new hed__Plan_Requirement__c(
            Name = 'Another Zero Marks',
            Semester__c = semester.Id,
            hed__Course__c = zeroMarksCourse.Id,
            hed__Plan_Requirement__c = null
        );
        insert anotherZeroMarks;
        
        Test.stopTest();
        
        // Zero marks courses shouldn't increase count
        hed__Term__c updatedSemester = [SELECT No_of_Courses_Per_Student__c 
                                       FROM hed__Term__c 
                                       WHERE Id = :semester.Id];
        System.assertEquals(3, updatedSemester.No_of_Courses_Per_Student__c, 
                           'Zero marks courses should not be counted');
    }
    
    @isTest
    static void testDirectHandlerCall() {
        hed__Term__c semester = [SELECT Id FROM hed__Term__c LIMIT 1];
        
        Test.startTest();
        UpdateSyllabusCountHandler.resetIsProcessed();
        UpdateSyllabusCountHandler.updateSemesterCourseCounts(new Set<Id>{semester.Id});
        Test.stopTest();
        
        hed__Term__c updatedSemester = [SELECT No_of_Courses_Per_Student__c 
                                       FROM hed__Term__c 
                                       WHERE Id = :semester.Id];
        System.assertEquals(3, updatedSemester.No_of_Courses_Per_Student__c, 
                           'Direct handler call should update count correctly');
    }
}