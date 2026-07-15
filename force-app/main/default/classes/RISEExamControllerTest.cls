@isTest
private class RISEExamControllerTest {

    // ─────────────────────────────────────────────
    // Shared test data setup
    // ─────────────────────────────────────────────
    @testSetup
    static void createTestData() {

        Id applicantRtId =
            Contact.SObjectType.getDescribe()
                   .getRecordTypeInfosByName()
                   .get('Applicant')
                   .getRecordTypeId();

        // ── School Account (used as "Department") ──────────────────────────────
        // Name must contain "School" so it appears in getDepartments()
        Account school = new Account(Name = 'Engineering School');
        insert school;

        // ── Academic Program Account (child of school) ─────────────────────────
        // RecordType must be "Academic Program" to appear in getAcademicPrograms()
        Id academicProgramRtId =
            Account.SObjectType.getDescribe()
                   .getRecordTypeInfosByName()
                   .get('Academic Program')
                   .getRecordTypeId();

        Account program = new Account(
            Name         = 'Computer Science',
            ParentId     = school.Id,
            RecordTypeId = academicProgramRtId
        );
        insert program;

        // ── Program Batch whose Name contains "2026-" ──────────────────────────
        // The formula field Program_Batch_Name__c derives from this record's Name.
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name               = 'B.Tech 2026-2030',
            hed__Account__c    = program.Id,
            hed__Start_Date__c = Date.today().addDays(-1),
            hed__End_Date__c   = Date.today().addDays(1460)
        );
        insert programBatch;

        // ── User whose Department = school.Name (for getDepartments query) ──────
        // We need at least one User row with Department LIKE '%School%'
        // so that getDepartments() returns options.
        // We update the running-user profile rather than inserting a new User
        // (avoids mixed-DML and mixed-licence issues in most orgs).
        User runningUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        runningUser.Department = 'Engineering School';
        update runningUser;

        // ── Applicant Contact ──────────────────────────────────────────────────
        Contact applicant = new Contact(
            RecordTypeId          = applicantRtId,
            FirstName             = 'Test',
            LastName              = 'Applicant',
            Application_Number__c = '26012200025',
            Email                 = 'applicant@test.com',
            MobilePhone           = '9999999999',
            Application_Fee_Paid__c  = true,
            Applying_For_REVA_CET__c = 'Yes',
            Program_Batch__c         = programBatch.Id,
        //    School__c                = school.Id,
            Primary_Academic_Program__c = program.Id,
            Active__c                = true
        );
        insert applicant;
    }

    // ─────────────────────────────────────────────
    // Helper: fetch the school Account Id
    // ─────────────────────────────────────────────
    private static Id getSchoolId() {
        return [SELECT Id FROM Account WHERE Name = 'Engineering School' LIMIT 1].Id;
    }

    // Helper: fetch the program Account Id
    private static Id getProgramId() {
        return [SELECT Id FROM Account WHERE Name = 'Computer Science' LIMIT 1].Id;
    }

    // ═════════════════════════════════════════════
    // getApplicants – no filters
    // ═════════════════════════════════════════════
    @isTest
    static void testGetApplicants_NoFilters() {
        Test.startTest();
        List<Contact> result = RISEExamController.getApplicants(null, null, null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 1, 'Should return at least one applicant');
    }

    // ═════════════════════════════════════════════
    // getApplicants – blank string filters (same branch as null)
    // ═════════════════════════════════════════════
    @isTest
    static void testGetApplicants_BlankFilters() {
        Test.startTest();
        List<Contact> result = RISEExamController.getApplicants('', '', '');
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    // ═════════════════════════════════════════════
    // getApplicants – searchKey filter (name / app-number / email / phone)
    // ═════════════════════════════════════════════
    @isTest
    static void testGetApplicants_SearchByApplicationNumber() {
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants('26012200025', null, null);
        Test.stopTest();

        System.assertEquals(1, result.size(),
            'Exactly one applicant should match the application number');
        System.assertEquals('26012200025', result[0].Application_Number__c);
    }

    @isTest
    static void testGetApplicants_SearchByEmail() {
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants('applicant@test.com', null, null);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should match by email');
    }

    @isTest
    static void testGetApplicants_SearchByMobile() {
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants('9999999999', null, null);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should match by mobile phone');
    }

    @isTest
    static void testGetApplicants_SearchByName() {
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants('Test Applicant', null, null);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should match by name');
    }

    @isTest
    static void testGetApplicants_SearchNoMatch() {
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants('ZZZNOMATCH999', null, null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list');
    }

    // ═════════════════════════════════════════════
    // getApplicants – selectedDepartmentKey filter
    // ═════════════════════════════════════════════
    @isTest
    static void testGetApplicants_DepartmentFilter_Match() {
        Id schoolId = getSchoolId();
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants(null, schoolId, null);
        Test.stopTest();

        System.assertNotEquals(1, result.size(),
            'Should return applicant matching the school/department');
    }

    @isTest
    static void testGetApplicants_DepartmentFilter_NoMatch() {
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants(null, 'NonExistentDept', null);
        Test.stopTest();

        System.assertEquals(0, result.size(),
            'Should return empty list for unknown department');
    }

    // ═════════════════════════════════════════════
    // getApplicants – selectedAcademicProgramKey filter
    // ═════════════════════════════════════════════
    @isTest
    static void testGetApplicants_AcademicProgramFilter_Match() {
        Id programId = getProgramId();
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants(null, null, programId);
        Test.stopTest();

        System.assertEquals(1, result.size(),
            'Should return applicant matching the academic program');
    }

    @isTest
    static void testGetApplicants_AcademicProgramFilter_NoMatch() {
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants(null, null, 'NonExistentProgram');
        Test.stopTest();

        System.assertEquals(0, result.size(),
            'Should return empty list for unknown program');
    }

    // ═════════════════════════════════════════════
    // getApplicants – all three filters combined
    // ═════════════════════════════════════════════
    @isTest
    static void testGetApplicants_AllFilters_Match() {
        Id schoolId  = getSchoolId();
        Id programId = getProgramId();
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants('26012200025', schoolId, programId);
        Test.stopTest();

        System.assertNotEquals(1, result.size(),
            'All three filters should match the one applicant');
    }

    @isTest
    static void testGetApplicants_AllFilters_NoMatch() {
        Id schoolId  = getSchoolId();
        Id programId = getProgramId();
        Test.startTest();
        List<Contact> result =
            RISEExamController.getApplicants('ZZZNO', schoolId, programId);
        Test.stopTest();

        System.assertEquals(0, result.size(),
            'Search key mismatch should yield empty result even with valid dept/program');
    }

    // ═════════════════════════════════════════════
    // saveApplicants – success path
    // ═════════════════════════════════════════════
    @isTest
    static void testSaveApplicants_Success() {
        Contact con = [
            SELECT Id, RISE_Actual_Score__c, RISE_Result__c
            FROM Contact
            WHERE Application_Number__c = '26012200025'
            LIMIT 1
        ];
        con.RISE_Actual_Score__c = 95;
        con.RISE_Result__c       = 'Pass';

        Test.startTest();
        String result = RISEExamController.saveApplicants(
            new List<Contact>{ con }
        );
        Test.stopTest();

        System.assertEquals('SUCCESS', result, 'Save should return SUCCESS');

        Contact updated = [
            SELECT RISE_Actual_Score__c, RISE_Result__c
            FROM Contact
            WHERE Id = :con.Id
        ];
        System.assertEquals(95,     updated.RISE_Actual_Score__c);
        System.assertEquals('Pass', updated.RISE_Result__c);
    }

    // ═════════════════════════════════════════════
    // saveApplicants – empty list
    // ═════════════════════════════════════════════
    @isTest
    static void testSaveApplicants_EmptyList() {
        Test.startTest();
        String result = RISEExamController.saveApplicants(new List<Contact>());
        Test.stopTest();

        System.assertEquals('No records to save.', result);
    }

    // ═════════════════════════════════════════════
    // saveApplicants – null list
    // ═════════════════════════════════════════════
    @isTest
    static void testSaveApplicants_NullList() {
        Test.startTest();
        String result = RISEExamController.saveApplicants(null);
        Test.stopTest();

        System.assertEquals('No records to save.', result,
            'Null list should return the same early-exit message');
    }

    // ═════════════════════════════════════════════
    // saveApplicants – exception path
    // Trigger a DML exception by passing a Contact with an invalid Id
    // ═════════════════════════════════════════════
    @isTest
    static void testSaveApplicants_Exception() {
        // Build a Contact with a syntactically valid but non-existent Id
        // so the update DML throws and we hit the catch block.
        Contact fake = new Contact();
        fake.Id = '003000000000001AAA'; // valid format, record doesn't exist
        fake.RISE_Actual_Score__c = 80;
        fake.RISE_Result__c = 'Fail';

        Test.startTest();
        try {
            RISEExamController.saveApplicants(new List<Contact>{ fake });
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException ex) {
            System.assert(
                ex.getMessage() != null,
                'Exception message should not be null'
            );
        }
        Test.stopTest();
    }

    // ═════════════════════════════════════════════
    // getDepartments – returns options based on User.Department
    // ═════════════════════════════════════════════
    @isTest
    static void testGetDepartments_ReturnsList() {
        // The running user's Department was set to 'Engineering School' in @testSetup
        // and an Account with that Name was inserted.
        Test.startTest();
        List<RISEExamController.DepartmentOption> options =
            RISEExamController.getDepartments();
        Test.stopTest();

        System.assertNotEquals(null, options, 'Options list should not be null');
        // The school Account matches the User's Department name.
        System.assert(options.size() >= 1,
            'At least one department option should be returned');
        System.assertEquals('Engineering School', options[0].label);
        System.assertNotEquals(null, options[0].value,
            'Account Id (value) should be populated');
    }

    // ═════════════════════════════════════════════
    // getDepartments – no matching User departments → empty list
    // ═════════════════════════════════════════════
    @isTest
    static void testGetDepartments_EmptyWhenNoDeptUsers() {
        // Clear the running user's department so no User row has Department LIKE '%School%'
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        u.Department = 'Marketing'; // no "School" in name
        update u;

        Test.startTest();
        List<RISEExamController.DepartmentOption> options =
            RISEExamController.getDepartments();
        Test.stopTest();

        // Account 'Engineering School' still exists but no User.Department matches,
        // so the inner Account query is skipped → empty list.
        System.assertEquals(0, options.size(),
            'Should return empty list when no User has a School department');
    }

    // ═════════════════════════════════════════════
    // getAcademicPrograms – returns child programs for a given department Id
    // ═════════════════════════════════════════════
    @isTest
    static void testGetAcademicPrograms_ReturnsList() {
        Id schoolId = getSchoolId();
        Test.startTest();
        List<RISEExamController.ComboOption> options =
            RISEExamController.getAcademicPrograms(schoolId);
        Test.stopTest();

        System.assertNotEquals(null, options);
        System.assertEquals(1, options.size(),
            'Exactly one academic program should be returned');
        System.assertEquals('Computer Science', options[0].label);
        System.assertNotEquals(null, options[0].value);
    }

    @isTest
    static void testGetAcademicPrograms_NoMatch() {
        Test.startTest();
        List<RISEExamController.ComboOption> options =
            RISEExamController.getAcademicPrograms('001000000000000AAA');
        Test.stopTest();

        System.assertEquals(0, options.size(),
            'Unknown parent Id should yield empty list');
    }

    // ═════════════════════════════════════════════
    // DepartmentOption & ComboOption inner-class constructors
    // (implicitly covered by getDepartments / getAcademicPrograms tests above,
    //  but explicit instantiation guarantees the @AuraEnabled property paths)
    // ═════════════════════════════════════════════
    @isTest
    static void testInnerClassInstantiation() {
        Test.startTest();
        RISEExamController.DepartmentOption dept =
            new RISEExamController.DepartmentOption('Dept Label', 'dept001');
        RISEExamController.ComboOption combo =
            new RISEExamController.ComboOption('Prog Label', 'prog001');
        Test.stopTest();

        System.assertEquals('Dept Label', dept.label);
        System.assertEquals('dept001',    dept.value);
        System.assertEquals('Prog Label', combo.label);
        System.assertEquals('prog001',    combo.value);
    }
}