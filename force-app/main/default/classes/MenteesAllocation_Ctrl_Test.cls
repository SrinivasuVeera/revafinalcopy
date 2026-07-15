@isTest
public class MenteesAllocation_Ctrl_Test {
    
    private static void ensureCaseTeamRoleExists() {        
        List<CaseTeamRole> existingRoles = [SELECT Id FROM CaseTeamRole WHERE Name = 'Student Member' LIMIT 1];
        if (existingRoles.isEmpty()) {            
            System.runAs(new User(Id = UserInfo.getUserId())) {
                CaseTeamRole role = new CaseTeamRole(Name = 'Student Member', AccessLevel = 'Edit');
                insert role;
            }
        }
    }
    
    @TestSetup
    static void setupTestData() {        
        Account testSchool = new Account(
            Name = 'Test University',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId()
        );
        insert testSchool;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.Parentid = testSchool.id;
        objAccount1.Program_Type__c = 'UG';
        insert objAccount1;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'B.Sc in Physics, Mathematics, and Computer Science-(2022-2025)',
            hed__Start_Date__c = system.today().addDays(-5),
            hed__End_Date__c = system.today().addyears(+1),
            hed__Account__c = objAccount1.id
        );
        insert programBatch;
        
        List<Contact> professors = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact prof = new Contact(
                FirstName = 'Professor',
                LastName = 'Test' + i,
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Professor').getRecordTypeId(),
                AccountId = testSchool.Id,                
                Max_Mentees__c = 5,
                hed__WorkEmail__c = 'prof' + i + '@testuniversity.edu'
            );
            professors.add(prof);
        }
        insert professors;
        
        List<User> profUsers = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        for (Integer i = 0; i < 5; i++) {
            User u = new User(
                FirstName = 'Professor',
                LastName = 'Test' + i,
                Email = 'prof' + i + '@testuniversity.edu',
                Username = 'prof' + i + '@testuniversity.edu' + System.currentTimeMillis(),
                FederationIdentifier = 'prof' + i + '@testuniversity.edu',
                Alias = 'ptest' + i,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id,
                IsActive = true
            );
            profUsers.add(u);
        }
        insert profUsers;
        
        List<Contact> students = new List<Contact>();
        for (Integer i = 0; i < 20; i++) {
            Contact student = new Contact(
                FirstName = 'Student',
                LastName = 'Test' + i,
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId(),
                AccountId = testSchool.Id
            );
            students.add(student);
        }
        insert students;       
        
        hed__Term__c term = new hed__Term__c(
            Name = 'Fall 2023',
            hed__Account__c = objAccount1.Id,            
            Program_Batch__c = programBatch.Id
        );
        insert term;
        
        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        for (Contact student : students) {
            hed__Program_Enrollment__c enrollment = new hed__Program_Enrollment__c(
                hed__Contact__c = student.Id,
                hed__Program_Plan__c = programBatch.Id,
                Semester__c = term.Id
            );
            enrollments.add(enrollment);
        }
        insert enrollments;        
    }
    @isTest
    static void testGetTermDetails() {
        hed__Term__c term = [SELECT Id FROM hed__Term__c WHERE Name = 'Fall 2023' LIMIT 1];  
        Test.startTest();        
        MenteesAllocation_Ctrl.TermDetailsWrp result = MenteesAllocation_Ctrl.getTermDetails(term.Id, 4,null);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('Fall 2023', result.objTerm.Name, 'Term name should match');
        System.assertEquals(0, result.totalUnassignedRecords, 'Should have 20 unassigned mentees from setup');
        System.assertEquals(0, result.menteeGroups.size(), 'Should have 5 mentee groups (20 students / 4 per group)');
        System.assertEquals(5, result.professors.size(), 'Should have 5 professor records from the main school');
        System.assert(result.crossSchoolProfessors.isEmpty(), 'Cross school professors should be empty when no school is selected');
    }
    @isTest
    static void testSRNNumberComparatorSorting() {       
        hed__Program_Plan__c progBatch = [SELECT Id, hed__Account__c FROM hed__Program_Plan__c LIMIT 1];
        hed__Term__c srnTerm = new hed__Term__c(
            Name = 'SRN Test Term', hed__Account__c = progBatch.hed__Account__c, Program_Batch__c = progBatch.Id,
            Term_Number__c = 2 
        );
        insert srnTerm;
        
        List<Contact> studentsForTest = new List<Contact>{
            new Contact(LastName = 'StudentC', SRN_Number__c = 'SRN0003', AccountId = progBatch.hed__Account__c, Student_Status__c = 'Pursuing'),
                new Contact(LastName = 'StudentA', SRN_Number__c = 'SRN0001', AccountId = progBatch.hed__Account__c, Student_Status__c = 'Pursuing'),
                new Contact(LastName = 'StudentB', SRN_Number__c = 'SRN0002', AccountId = progBatch.hed__Account__c, Student_Status__c = 'Pursuing')
                };
                    insert studentsForTest;
        
        List<hed__Program_Enrollment__c> enrollmentsForTest = new List<hed__Program_Enrollment__c>();
        for(Contact s : studentsForTest){
            enrollmentsForTest.add(new hed__Program_Enrollment__c(
                hed__Contact__c = s.Id, hed__Program_Plan__c = progBatch.Id,
                Semester__c = srnTerm.Id
            ));
        }
        insert enrollmentsForTest;
        
        Test.startTest();
        MenteesAllocation_Ctrl.TermDetailsWrp result = MenteesAllocation_Ctrl.getTermDetails(srnTerm.Id, 3, null);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals(3, result.totalUnassignedRecords, 'Should find the 3 enrollments created for this test.');
        System.assertEquals(1, result.menteeGroups.size(), 'Should have one group of 3.');
        
        List<hed__Program_Enrollment__c> theOnlyGroup = result.menteeGroups[0];
        System.assertEquals('SRN0001', theOnlyGroup[0].hed__Contact__r.SRN_Number__c, 'First student should be SRN0001 after sorting');
        System.assertEquals('SRN0002', theOnlyGroup[1].hed__Contact__r.SRN_Number__c, 'Second student should be SRN0002 after sorting');
        System.assertEquals('SRN0003', theOnlyGroup[2].hed__Contact__r.SRN_Number__c, 'Third student should be SRN0003 after sorting');
    }
    
    @isTest
    static void testNameComparatorSorting() {        
        hed__Program_Plan__c progBatch = [SELECT Id, hed__Account__c FROM hed__Program_Plan__c LIMIT 1];        
        hed__Term__c firstTerm = new hed__Term__c(
            Name = 'Spring 2023', hed__Account__c = progBatch.hed__Account__c, Program_Batch__c = progBatch.Id,
            Term_Number__c = 1 
        );
        insert firstTerm;
        
        List<Contact> studentsForTest = new List<Contact>{
            new Contact(LastName = 'Zulu', AccountId = progBatch.hed__Account__c, Student_Status__c = 'Pursuing'),
                new Contact(LastName = 'Alpha', AccountId = progBatch.hed__Account__c, Student_Status__c = 'Pursuing'),
                new Contact(LastName = 'Charlie', AccountId = progBatch.hed__Account__c, Student_Status__c = 'Pursuing')
                };
                    insert studentsForTest;
        
        List<hed__Program_Enrollment__c> enrollmentsForTerm1 = new List<hed__Program_Enrollment__c>();
        for(Contact s : studentsForTest){
            enrollmentsForTerm1.add(new hed__Program_Enrollment__c(
                hed__Contact__c = s.Id, hed__Program_Plan__c = progBatch.Id,
                Semester__c = firstTerm.Id
            ));
        }
        insert enrollmentsForTerm1;
        
        Test.startTest();
        MenteesAllocation_Ctrl.TermDetailsWrp result = MenteesAllocation_Ctrl.getTermDetails(firstTerm.Id, 3, null);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals(3, result.totalUnassignedRecords, 'Should find the 3 enrollments for this term.');
        List<hed__Program_Enrollment__c> theOnlyGroup = result.menteeGroups[0];
        System.assertEquals('Alpha', theOnlyGroup[0].hed__Contact__r.LastName, 'First student should be Alpha after sorting');
        System.assertEquals('Charlie', theOnlyGroup[1].hed__Contact__r.LastName, 'Second student should be Charlie after sorting');
        System.assertEquals('Zulu', theOnlyGroup[2].hed__Contact__r.LastName, 'Third student should be Zulu after sorting');
    }
    
    @isTest
    static void testGetTermDetailsWithCrossSchool() {
        hed__Term__c term = [SELECT Id FROM hed__Term__c WHERE Name = 'Fall 2023' LIMIT 1];
        Account crossSchool = [SELECT Id FROM Account WHERE Name = 'Test Account1'];        
           
        List<String> selectedSchools = new List<String>{ crossSchool.Id };        
                    
        Contact professor1 = new Contact(
        LastName = 'Prof One',
        AccountId = crossSchool.Id,
        RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Professor').getRecordTypeId(),
        Max_Mentees__c = 5,
        hed__WorkEmail__c = 'prof1@test.com'
    	);
        insert professor1;
            
        Case testCase = new Case(
            Subject = 'Test Case',
            ContactId = professor1.Id,
             RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Mentor').getRecordTypeId()
        );
         insert testCase;
                
        Test.startTest();        
        MenteesAllocation_Ctrl.TermDetailsWrp result = MenteesAllocation_Ctrl.getTermDetails(term.Id, 4, selectedSchools);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.crossSchoolProfessors.size(), 'Should find 1 cross-school professor');
    }
    
    @isTest
    static void testSubmitMenteeAllocation() {
        ensureCaseTeamRoleExists(); 
        hed__Term__c term = [SELECT Id FROM hed__Term__c WHERE Name = 'Fall 2023' LIMIT 1];
        List<Contact> professors = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Professor' AND FirstName = 'Professor' LIMIT 3];
        List<Contact> students = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student' LIMIT 12];
        
        Map<String, List<String>> allocations = new Map<String, List<String>>();
        allocations.put(professors[0].Id, new List<String>{students[0].Id, students[1].Id, students[2].Id, students[3].Id});
        allocations.put(professors[1].Id, new List<String>{students[4].Id, students[5].Id, students[6].Id, students[7].Id});
        allocations.put(professors[2].Id, new List<String>{students[8].Id, students[9].Id, students[10].Id, students[11].Id});        
        String allocationDataStr = JSON.serialize(allocations);
        
        Test.startTest();
        MenteesAllocation_Ctrl.submitMenteeAllocation(term.Id, allocationDataStr);
        Test.stopTest();
        System.assertEquals(3, [SELECT COUNT() FROM Case WHERE RecordType.DeveloperName = 'Mentor'], 'Should create 3 mentor cases');
        System.assertEquals(12, [SELECT COUNT() FROM Case WHERE RecordType.DeveloperName = 'Mentee'], 'Should create 12 mentee cases');
        System.assertEquals(12, [SELECT COUNT() FROM CaseTeamMember], 'Should create 12 case team members');
        System.assertEquals(12, [SELECT COUNT() FROM Contact WHERE Mentor__c != null], 'Should update 12 student contacts with a mentor');
    }
    
    @isTest
    static void testExistingMentorCase() {
        ensureCaseTeamRoleExists(); 
        hed__Term__c term = [SELECT Id FROM hed__Term__c WHERE Name = 'Fall 2023' LIMIT 1];
        List<Contact> professors = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Professor' AND FirstName = 'Professor' LIMIT 2];
        List<Contact> students = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student' LIMIT 6];
        
        Id mentorRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Mentor').getRecordTypeId();
        Case existingMentorCase = new Case(RecordTypeId = mentorRecordTypeId, ContactId = professors[0].Id, Status = 'Queued');
        insert existingMentorCase;
        
        Map<String, List<String>> allocations = new Map<String, List<String>>();
        allocations.put(professors[0].Id, new List<String>{students[0].Id, students[1].Id, students[2].Id});
        allocations.put(professors[1].Id, new List<String>{students[3].Id, students[4].Id, students[5].Id});        
        String allocationDataStr = JSON.serialize(allocations);
        
        Test.startTest();
        MenteesAllocation_Ctrl.submitMenteeAllocation(term.Id, allocationDataStr);
        Test.stopTest();
        
        List<Case> mentorCases = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Mentor'];
        System.assertEquals(2, mentorCases.size(), 'Should have 2 mentor cases (1 existing + 1 new)');
        
        List<Case> reusedCases = [SELECT Id FROM Case WHERE Id = :existingMentorCase.Id];
        System.assertEquals(1, reusedCases.size(), 'The existing mentor case should have been reused, not deleted.');
    }
}