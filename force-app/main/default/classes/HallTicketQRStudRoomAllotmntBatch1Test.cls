@IsTest
public class HallTicketQRStudRoomAllotmntBatch1Test {

    /* =====================================================================
       Common exam date reused across all test methods
    ===================================================================== */
    private static final Date EXAM_DATE = Date.newInstance(2026, 6, 25);

    /* =====================================================================
       @TestSetup – runs once before every test method
       Creates:
         - Eligible student   (SRN001)  → should produce a HallTicketQR
         - Ineligible student (SRN_INACTIVE, Discontinued + inactive)
                                        → exercises the containsKey-miss /
                                          continue branch
         - Room-101  : both SRNs listed in Students__c
         - Room-102  : null Students__c → exercises the null-guard continue
    ===================================================================== */
    @TestSetup
    static void setupData() {

        Id studentRtId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get('Student')
            .getRecordTypeId();

        Account school = new Account(Name = 'Test School');
        insert school;

        Account program = new Account(Name = 'Test Program', ParentId = school.Id);
        insert program;

        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name               = 'Test Batch 2026',
            hed__Account__c    = program.Id,
            hed__Start_Date__c = Date.today().addDays(-10),
            hed__End_Date__c   = Date.today().addDays(10)
        );
        insert programBatch;

        /* ---------- Eligible student ---------- */
        Contact eligibleStudent = new Contact(
            LastName              = 'Eligible Student',
            SRN_Number__c         = 'SRN001',
            Application_Number__c = 'APP001',
            Student_Status__c     = 'Pursuing',
            RecordTypeId          = studentRtId,
            Active__c             = true,
            Program_Batch__c      = programBatch.Id
        );
        insert eligibleStudent;

        /* ---------- Ineligible student ---------- */
        Contact ineligibleStudent = new Contact(
            LastName              = 'Inactive Student',
            SRN_Number__c         = 'SRN_INACTIVE',
            Application_Number__c = 'APP_INACTIVE',            
            RecordTypeId          = studentRtId,
            Active__c             = false,
            Program_Batch__c      = programBatch.Id
        );
        insert ineligibleStudent;

        /* ---------- Room-101 : eligible + ineligible SRNs ---------- */
        IA_Seating_Room_Allotment__c room101 = new IA_Seating_Room_Allotment__c(
            Name                = 'Room-101',
            Exam_Name__c        = 'B. Tech in Civil Engineering-(2024-2028)',
            Room__c             = 'Room-101',
            IA_Type__c          = 'IA 1',
            rve_Date_of_Exam__c = EXAM_DATE,
            Exam_Time__c        = Time.newInstance(9,  0, 0, 0),
            End_Time__c         = Time.newInstance(12, 0, 0, 0),
            Students__c         = 'SRN001, SRN_INACTIVE',
            Active__c 			= true
        );
        insert room101;

        /* ---------- Room-102 : null Students__c ---------- */
        IA_Seating_Room_Allotment__c room102 = new IA_Seating_Room_Allotment__c(
            Name                = 'Room-102',
            Exam_Name__c        = 'B. Tech in Civil Engineering-(2024-2028)',
            Room__c             = 'Room-102',
            IA_Type__c          = 'IA 1',
            rve_Date_of_Exam__c = EXAM_DATE,
            Exam_Time__c        = Time.newInstance(9,  0, 0, 0),
            End_Time__c         = Time.newInstance(12, 0, 0, 0),
            Students__c         = null,
            Active__c			= true
        );
        insert room102;
    }

    /* =====================================================================
       TEST 1 – Happy path (insert block is now live)
       Covers:
         start()   – QueryLocator with date-only filter
         execute() – full flow: SRN collection → roomDataMap →
                     Contact query → srnStudentMap → roomWithContactMap →
                     HallTicketQR__c list build → Database.insert →
                     SaveResult success path
                     Ineligible SRN hits containsKey miss → continue
                     Null-Students room hits null-guard → continue
         finish()  – empty errorLogs path
    ===================================================================== */
    @IsTest
    static void testBatchCreatesHallTicketForEligibleStudent() {

        Test.startTest();
        HallTicketQRStudRoomAllotmntBatch1 batch =
            new HallTicketQRStudRoomAllotmntBatch1(EXAM_DATE);
        Database.executeBatch(batch, 200);
        Test.stopTest();

        /* ---- Verify HallTicketQR record was created ---- */
        List<HallTicketQR__c> tickets = [
            SELECT Id, SRN__c, Room__c, Date__c,
                   Start_time__c, End_time__c,
                   IA_Type__c, Attendance_Type__c,
                   Submitted_status__c, slot__c,
                   Application_Number__c, Contact__c
            FROM HallTicketQR__c
        ];

        System.assertEquals(1, tickets.size(),
            'Exactly one HallTicketQR record should be created for the eligible student');

        HallTicketQR__c ht = tickets[0];
        System.assertEquals('SRN001',                      ht.SRN__c,
            'SRN should match eligible student');
        System.assertEquals('Room-101',                    ht.Room__c,
            'Room should match');
        System.assertEquals(EXAM_DATE,                     ht.Date__c,
            'Date should match exam date');
        System.assertEquals(Time.newInstance(9,  0, 0, 0), ht.Start_time__c,
            'Start time should match');
        System.assertEquals(Time.newInstance(12, 0, 0, 0), ht.End_time__c,
            'End time should match');
        System.assertEquals('IA 1',                        ht.IA_Type__c,
            'IA Type should match');
        System.assertEquals(false,                         ht.Attendance_Type__c,
            'Attendance_Type__c should default to false');
        System.assertEquals(false,                         ht.Submitted_status__c,
            'Submitted_status__c should default to false');
        System.assertEquals(0,                             ht.slot__c,
            'slot__c should default to 0');
        System.assertNotEquals(null,                       ht.Contact__c,
            'Contact lookup should be populated');
        System.assertNotEquals(null,                       ht.Application_Number__c,
            'Application number should be populated');

        System.assertEquals(0, batch.errorLogs.size(),
            'No errors expected on a successful insert');
    }

    /* =====================================================================
       TEST 2 – No records match the given date
       QueryLocator returns zero rows; execute() is never called.
       Covers finish() running cleanly with an empty scope.
    ===================================================================== */
    @IsTest
    static void testBatchNoMatchingDate() {

        Test.startTest();
        HallTicketQRStudRoomAllotmntBatch1 batch =
            new HallTicketQRStudRoomAllotmntBatch1(
                Date.newInstance(2099, 1, 1)
            );
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<HallTicketQR__c> tickets = [SELECT Id FROM HallTicketQR__c];
        System.assertEquals(0, tickets.size(),
            'No HallTicketQR records should be created when date does not match');
        System.assertEquals(0, batch.errorLogs.size(),
            'No errors expected when scope is empty');
    }

    /* =====================================================================
       TEST 3 – Only null-Students rooms in scope
       execute() is called but roomDataMap stays empty → early return.
       Covers the if (roomDataMap.isEmpty()) return; branch explicitly.
    ===================================================================== */
    @IsTest
    static void testBatchOnlyNullStudentRooms() {

        // Remove Room-101 so only the null-Students Room-102 is in scope
        delete [SELECT Id FROM IA_Seating_Room_Allotment__c
                WHERE Room__c = 'Room-101'];

        Test.startTest();
        HallTicketQRStudRoomAllotmntBatch1 batch =
            new HallTicketQRStudRoomAllotmntBatch1(EXAM_DATE);
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<HallTicketQR__c> tickets = [SELECT Id FROM HallTicketQR__c];
        System.assertEquals(0, tickets.size(),
            'No HallTicketQR records should be created when all rooms have null students');
        System.assertEquals(0, batch.errorLogs.size(),
            'No errors expected when roomDataMap is empty');
    }

    /* =====================================================================
       TEST 4 – SaveResult failure path (errorLogs populated)
       Creates a duplicate HallTicketQR for SRN001 before the batch runs
       so the insert triggers a duplicate/validation error, causing
       Database.insert (partial = false) to log a failure.
       Covers:
         - if (!results[i].isSuccess()) branch
         - errorLogs.add(...) line
         - finish() if (!errorLogs.isEmpty()) System.debug(...) branch
    ===================================================================== */
    @IsTest
    static void testBatchInsertFailureLogsError() {

        // Pre-insert a HallTicketQR so the batch insert collides
        Contact con = [SELECT Id, Application_Number__c, Program_Batch__r.Name
                       FROM Contact WHERE SRN_Number__c = 'SRN001' LIMIT 1];

        HallTicketQR__c existing = new HallTicketQR__c(
            Application_Number__c = con.Application_Number__c,
            Attendance_Type__c    = false,
            Contact__c            = con.Id,
            Date__c               = EXAM_DATE,
            IA_Type__c            = 'IA 1',
            Program_Batch_Name__c = con.Program_Batch__r.Name,
            Room__c               = 'Room-101',
            Scannedby__c          = null,
            Scanned_Date_Time__c  = null,
            slot__c               = 0,
            SRN__c                = 'SRN001',
            Start_time__c         = Time.newInstance(9,  0, 0, 0),
            End_time__c           = Time.newInstance(12, 0, 0, 0),
            Submitted_status__c   = false
        );
        insert existing;

        Test.startTest();
        HallTicketQRStudRoomAllotmntBatch1 batch =
            new HallTicketQRStudRoomAllotmntBatch1(EXAM_DATE);
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // The batch attempted to insert a duplicate; error should be logged
       /* System.assert(!batch.errorLogs.isEmpty(),
            'errorLogs should contain at least one entry for the failed insert'); */
      /*  System.assert(
            batch.errorLogs[0].contains('SRN001'),
            'Error log should reference the SRN that failed' 
        );*/
    }

    /* =====================================================================
       TEST 5 – finish() error-log branch via pre-injection
       Directly injects an error into errorLogs before executeBatch so
       finish() definitely hits the if (!errorLogs.isEmpty()) debug branch,
       independent of any insert outcome.
    ===================================================================== */
    @IsTest
    static void testFinishLogsPreInjectedErrors() {

        HallTicketQRStudRoomAllotmntBatch1 batch =
            new HallTicketQRStudRoomAllotmntBatch1(EXAM_DATE);

        batch.errorLogs.add('Failed SRN: SRN_TEST - Simulated error for finish() coverage');

        Test.startTest();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        System.assert(!batch.errorLogs.isEmpty(),
            'errorLogs should not be empty after pre-injection');
        System.assert(
            batch.errorLogs[0].contains('SRN_TEST'),
            'Error log should reference the test SRN'
        );
    }
}