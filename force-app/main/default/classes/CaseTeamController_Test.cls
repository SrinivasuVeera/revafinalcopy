@isTest
private class CaseTeamController_Test {

    // Utility method to ensure CaseTeamRole exists (setup object)
    private static Id ensureCaseTeamRoleExists() {
        List<CaseTeamRole> existingRoles = [SELECT Id FROM CaseTeamRole WHERE Name = 'Student Member' LIMIT 1];
        if (existingRoles.isEmpty()) {
            System.runAs(new User(Id = UserInfo.getUserId())) {
                CaseTeamRole role = new CaseTeamRole(Name = 'Student Member', AccessLevel = 'Edit');
                insert role;
                return role.Id;
            }
        }
        return existingRoles[0].Id;
    }

    // Setup method to create test data (non-setup objects only)
    @TestSetup
    static void setup() {
        // Create record type IDs
        String HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        String AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        String StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id mentorRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Mentor').getRecordTypeId();

        // Create University Department Account
        Account objAcc = new Account(
            Name = 'Test Account',
            RecordTypeId = HouseholdRecId
        );
        insert objAcc;

        // Create Academic Program Account
        Account objAccount1 = new Account(
            Name = 'Test Account1',
            RecordTypeId = AcaRecId,
            ParentId = objAcc.Id,
            Program_Type__c = 'UG'
        );
        insert objAccount1;

        // Create Program Plan
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'B.Sc in Physics, Mathematics, and Computer Science-(2022-2025)',
            hed__Start_Date__c = System.today().addDays(-5),
            hed__End_Date__c = System.today().addYears(1),
            hed__Account__c = objAccount1.Id
        );
        insert programBatch;

        // Create Contact (Student)
        Contact objCon = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            AccountId = objAcc.Id,
            RecordTypeId = StudentRecId,
            MobilePhone = '9090909090',
            Aadhar_Card_Number__c = '098765435612',
            School__c = objAcc.Id,
            Application_Number__c = 'test123',
            SRN_Number__c = '123',
            Quota__c = 'Management Quota',
            Email = 'testing1234@reva.edu.in',
            Personal_Email__c = 'naveen123978@gmail.com',
            hed__Preferred_Email__c = 'Personal Email',
            hed__WorkEmail__c = 'test123@reva.edu.in',
            Nationality__c = 'Indian',
            Active__c = true,
            Student_Status__c = 'Pursuing',
            Program_Batch__c = programBatch.Id,
            Primary_Academic_Program__c = objAccount1.Id
        );
        insert objCon;

        // Create Case
        Case testCase = new Case(
            RecordTypeId = mentorRecordTypeId,
            ContactId = objCon.Id,
            Status = 'Queued',
            Priority = 'Medium',
            Origin = 'Email'
        );
        insert testCase;

        // Ensure CaseTeamRole exists and get its ID (still needed for CaseTeamMember creation)
        Id roleId = ensureCaseTeamRoleExists();

        // Create CaseTeamMember
        CaseTeamMember testMember = new CaseTeamMember(
            ParentId = testCase.Id,
            MemberId = objCon.Id,
            TeamRoleId = roleId
        );
        insert testMember;
    }

    // Test getCaseTeamMembers method - Positive scenario
    @isTest
    static void testGetCaseTeamMembers_Success() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        List<CaseTeamController.TeamMemberWrapper> members = CaseTeamController.getCaseTeamMembers(testCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, members, 'Case team members should not be null');
        System.assertEquals(1, members.size(), 'Should return one case team member');
        System.assertEquals('Test Student', members[0].memberName, 'Member name should match');
        System.assertEquals('Pursuing', members[0].studentStatus, 'Student Status should be Pursuing');
        System.assertEquals('123', members[0].srnNumber, 'SRN Number should be 123');
    }

    // Test getCaseTeamMembers method - Empty result
    @isTest
    static void testGetCaseTeamMembers_NoMembers() {
        Id mentorRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Mentor').getRecordTypeId();
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Student' LIMIT 1];
        Case emptyCase = new Case(
            RecordTypeId = mentorRecordTypeId,
            ContactId = testContact.Id,
            Status = 'Queued',
            Priority = 'Medium',
            Origin = 'Email'
        );
        insert emptyCase;

        Test.startTest();
        List<CaseTeamController.TeamMemberWrapper> members = CaseTeamController.getCaseTeamMembers(emptyCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, members, 'Result should not be null');
        System.assertEquals(0, members.size(), 'Should return zero case team members');
    }

    // Test deleteCaseTeamMembers method - Positive scenario
    @isTest
    static void testDeleteCaseTeamMembers_Success() {
        CaseTeamMember testMember = [SELECT Id FROM CaseTeamMember LIMIT 1];
        List<Id> memberIds = new List<Id>{testMember.Id};

        Test.startTest();
        CaseTeamController.deleteCaseTeamMembers(memberIds);
        Test.stopTest();

        List<CaseTeamMember> remainingMembers = [SELECT Id FROM CaseTeamMember WHERE Id = :testMember.Id];
        System.assertEquals(0, remainingMembers.size(), 'Case team member should be deleted');
    }

    // Test deleteCaseTeamMembers method - Empty list
    @isTest
    static void testDeleteCaseTeamMembers_EmptyList() {
        List<Id> emptyMemberIds = new List<Id>();

        Test.startTest();
        CaseTeamController.deleteCaseTeamMembers(emptyMemberIds);
        Test.stopTest();

        System.assert(true, 'Method should execute without error for empty list');
    }
}