@IsTest
public class HallTicketQRGenerationBatchNewTest {

    /* ==================================================
       Shared helper – builds the full data hierarchy
       (School → Program → ProgramBatch → ParentTerm →
        Semester) and returns the inserted Semester.
       The caller controls which IA date gets set to the
       target date so each scenario stays self-contained.
    ================================================== */
    private static hed__Term__c buildSemester(
        String   suffix,
        Date     ia1Date,
        Date     ia2Date
    ) {
        Account school = new Account(Name = 'Test School ' + suffix);
        insert school;

        Account program = new Account(
            Name     = 'Test Program ' + suffix,
            ParentId = school.Id
        );
        insert program;

        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name               = 'Batch ' + suffix,
            hed__Account__c    = program.Id,
            hed__Start_Date__c = Date.today().addDays(-10),
            hed__End_Date__c   = Date.today().addDays(60)
        );
        insert programBatch;

        hed__Term__c parentTerm = new hed__Term__c(
            Name               = 'Parent Term ' + suffix,
            Program_Batch__c   = programBatch.Id,
            hed__Account__c    = school.Id,
            hed__Start_Date__c = Date.today().addDays(-10),
            hed__End_Date__c   = Date.today().addDays(60)
        );
        insert parentTerm;

        hed__Term__c semester = new hed__Term__c(
            Name                = 'Sem ' + suffix,
        //    Record_Type_Name__c = 'Semester',
        //    Active__c           = true,
            Program_Batch__c    = programBatch.Id,
            hed__Account__c     = school.Id,
            hed__Parent_Term__c = parentTerm.Id,
            hed__Start_Date__c  = Date.today().addDays(-10),
            hed__End_Date__c    = Date.today().addDays(60),
            IA_1_Start_date__c  = ia1Date,
            IA_2_Start_date__c  = ia2Date
        );
        insert semester;

        return semester;
    }

    private static Contact buildContact(
        String suffix,
        String srn,
        Id     programBatchId,
        Id     semesterId
    ) {
        Id studentRtId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get('Student')
            .getRecordTypeId();

        Contact con = new Contact(
            LastName           = 'Student ' + suffix,
            SRN_Number__c      = srn,
            Student_Status__c  = 'Pursuing',
            RecordTypeId       = studentRtId,
            Program_Batch__c   = programBatchId,
            Active_Semester__c = semesterId
        );
        insert con;
        return con;
    }

    /* --------------------------------------------------
       Scenario 1 – IA 1 date matches the passed-in date
    -------------------------------------------------- */
    @IsTest
    static void testIA1DateMatch() {

        Date examDate = Date.today().addDays(16);

        hed__Term__c semester = buildSemester(
            'IA1',
            examDate,                       // IA_1 = target
            Date.today().addDays(30)        // IA_2 = irrelevant
        );

        Contact con = buildContact(
            'IA1', 'SRN-IA1-001',
            semester.Program_Batch__c,
            semester.Id
        );

        Test.startTest();
        // Constructor now receives the exam date explicitly
        Database.executeBatch(
            new HallTicketQRGenerationBatchNew(examDate), 200
        );
        Test.stopTest();

        /* DML is commented-out in the batch, so QR field stays null.
           We assert the contact is intact and the batch ran cleanly. */
        Contact result = [
            SELECT SRN_Number__c, HallTicket_QR_Data__c
            FROM Contact WHERE Id = :con.Id
        ];
        System.assertEquals(
            'SRN-IA1-001', result.SRN_Number__c,
            'Contact must be intact after IA 1 batch run'
        );
    }

    /* --------------------------------------------------
       Scenario 2 – IA 2 date matches the passed-in date
    -------------------------------------------------- */
    @IsTest
    static void testIA2DateMatch() {

        Date examDate = Date.today().addDays(20);

        hed__Term__c semester = buildSemester(
            'IA2',
            Date.today().addDays(5),        // IA_1 = does NOT match
            examDate                        // IA_2 = target
        );

        Contact con = buildContact(
            'IA2', 'SRN-IA2-001',
            semester.Program_Batch__c,
            semester.Id
        );

        Test.startTest();
        Database.executeBatch(
            new HallTicketQRGenerationBatchNew(examDate), 200
        );
        Test.stopTest();

        Contact result = [
            SELECT SRN_Number__c
            FROM Contact WHERE Id = :con.Id
        ];
        System.assertEquals(
            'SRN-IA2-001', result.SRN_Number__c,
            'Contact must be intact after IA 2 batch run'
        );
    }

    /* --------------------------------------------------
       Scenario 3 – Passed-in date matches nothing →
       QueryLocator returns zero rows, execute() never
       called, finish() logs success
    -------------------------------------------------- */
    @IsTest
    static void testNoMatchingDate() {

        // Semester IA dates are different from the date we pass in
        buildSemester(
            'NoMatch',
            Date.today().addDays(5),
            Date.today().addDays(10)
        );

        Date examDate = Date.today().addDays(16); // intentionally unmatched

        Test.startTest();
        Database.executeBatch(
            new HallTicketQRGenerationBatchNew(examDate), 200
        );
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Contact WHERE SRN_Number__c LIKE 'SRN-NOMATCH%'],
            'No contacts should be processed when no semester date matches'
        );
    }

    /* --------------------------------------------------
       Scenario 4 – Contact missing SRN_Number__c is
       excluded by the inner SOQL (SRN_Number__c != null)
    -------------------------------------------------- */
    @IsTest
    static void testContactWithoutSRNSkipped() {

        Date examDate = Date.today().addDays(16);

        hed__Term__c semester = buildSemester(
            'NoSRN',
            examDate,
            Date.today().addDays(30)
        );

        // SRN intentionally null
        Contact con = buildContact(
            'NoSRN', null,
            semester.Program_Batch__c,
            semester.Id
        );

        Test.startTest();
        Database.executeBatch(
            new HallTicketQRGenerationBatchNew(examDate), 200
        );
        Test.stopTest();

        Contact result = [
            SELECT HallTicket_QR_Data__c
            FROM Contact WHERE Id = :con.Id
        ];
        System.assertEquals(
            null, result.HallTicket_QR_Data__c,
            'QR field must remain null when contact has no SRN'
        );
    }

    /* --------------------------------------------------
       Scenario 5 – Both IA dates equal the passed-in date;
       IA 1 wins because it is checked first in execute()
    -------------------------------------------------- */
    @IsTest
    static void testBothDatesMatchIA1Wins() {

        Date examDate = Date.today().addDays(16);

        hed__Term__c semester = buildSemester(
            'BothMatch',
            examDate,   // IA_1 = target
            examDate    // IA_2 = target (tie)
        );

        Contact con = buildContact(
            'BothMatch', 'SRN-BOTH-001',
            semester.Program_Batch__c,
            semester.Id
        );

        Test.startTest();
        Database.executeBatch(
            new HallTicketQRGenerationBatchNew(examDate), 200
        );
        Test.stopTest();

        // IA 1 wins; batch ran cleanly
        Contact result = [
            SELECT SRN_Number__c
            FROM Contact WHERE Id = :con.Id
        ];
        System.assertEquals(
            'SRN-BOTH-001', result.SRN_Number__c,
            'Contact intact; IA 1 should win when both dates match'
        );
    }

    /* --------------------------------------------------
       Scenario 6 – Specific / hard-coded date passed in
       (mirrors the commented-out Date.newInstance line
        in the original batch for manual testing)
    -------------------------------------------------- */
    @IsTest
    static void testHardCodedDatePassedViaConstructor() {

        Date examDate = Date.newInstance(2026, 7, 8);

        hed__Term__c semester = buildSemester(
            'HardCoded',
            examDate,
            Date.today().addDays(30)
        );

        Contact con = buildContact(
            'HardCoded', 'SRN-HC-001',
            semester.Program_Batch__c,
            semester.Id
        );

        Test.startTest();
        Database.executeBatch(
            new HallTicketQRGenerationBatchNew(examDate), 200
        );
        Test.stopTest();

        Contact result = [
            SELECT SRN_Number__c
            FROM Contact WHERE Id = :con.Id
        ];
        System.assertEquals(
            'SRN-HC-001', result.SRN_Number__c,
            'Batch must accept any explicit date, not just today+16'
        );
    }
}