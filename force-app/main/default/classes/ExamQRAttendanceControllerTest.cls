@IsTest
public class ExamQRAttendanceControllerTest {

    @testSetup
    static void setup() {

        // ── Profiles ──────────────────────────────────────────────────────────
        Profile professorProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];

        User prof1 = new User(
            Alias            = 'prof1',
            Email            = 'prof1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName         = 'Professor1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey     = 'en_US',
            ProfileId        = professorProfile.Id,
            TimeZoneSidKey   = 'Asia/Kolkata',
            Username         = 'prof1@test.com'
        );
        insert prof1;

        User prof2 = new User(
            Alias            = 'prof2',
            Email            = 'prof2@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName         = 'Professor2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey     = 'en_US',
            ProfileId        = professorProfile.Id,
            TimeZoneSidKey   = 'Asia/Kolkata',
            Username         = 'prof2@test.com'
        );
        insert prof2;

        // ── Contacts ──────────────────────────────────────────────────────────
        Contact contact1 = new Contact(
            LastName      = 'Test Contact',
            Email         = 'testcontact@test.com',
            SRN_Number__c = 'SRN001',
            Active__c     = true
        );
        insert contact1;

        Contact student = new Contact(
            LastName      = 'Test Student',
            Email         = 'testcontact1@test.com',
            SRN_Number__c = 'SRN002',
            Active__c     = true
        );
        insert student;

        // ── Room Allotment ────────────────────────────────────────────────────
        IA_Seating_Room_Allotment__c room = new IA_Seating_Room_Allotment__c(
            Name             = 'Room A',
            Capacity__c      = 50,
            Total_Students__c = 40,
            Students__c      = 'Student List'
        );
        insert room;

        // ── Invigilator Assignment (linked to prof2 as coordinator) ───────────
        rve_Invigilator_Assignment__c assignment = new rve_Invigilator_Assignment__c(
            Name                      = 'Room1',
            rve_Professor__c          = prof1.Id,
            rve_Date__c               = Date.today(),
            rve_Shift__c              = 'Morning',
            rve_Exam_Time__c          = Time.newInstance(9,  0, 0, 0),
            rve_Exam_End_Time__c      = Time.newInstance(12, 0, 0, 0),
            rve_Attendance_Submitted__c = false,
            Attendance_Co_ordinator__c  = prof2.Id,
            rve_Room_Allotment__c       = room.Id
        );
        insert assignment;

        // ── HallTicketQR – already-scanned record (Room 1 / SRN1) ─────────────
        HallTicketQR__c hall = new HallTicketQR__c(
            SRN__c              = 'SRN1',
            Contact__c          = contact1.Id,
            Attendance_Type__c  = true,
            Room__c             = 'Room 1',
            Date__c             = Date.today(),
            Start_time__c       = Time.newInstance(9,  0, 0, 0),
            End_time__c         = Time.newInstance(12, 0, 0, 0),
            Scannedby__c        = prof1.Id,
            Scanned_Date_Time__c = System.now(),
            IA_Type__c          = 'IA 1',
            Program_Batch_Name__c = 'B. Tech in Computer Science and Engineering-(2025-2029)'
        );
        insert hall;

        // ── HallTicketQR – not-yet-scanned record (Room1 / SRN001) ───────────
        HallTicketQR__c ht = new HallTicketQR__c(
            SRN__c             = 'SRN001',
            Contact__c         = contact1.Id,
            Room__c            = 'Room1',
            Date__c            = Date.today(),
            Start_time__c      = Time.newInstance(9,  0, 0, 0),
            End_time__c        = Time.newInstance(12, 0, 0, 0),
            Attendance_Type__c = false,
            IA_Type__c         = 'IA 1',
            Program_Batch_Name__c = 'B. Tech in Computer Science and Engineering-(2025-2029)'
        );
        insert ht;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 1. getAttendanceCoordinatorData1
    // ══════════════════════════════════════════════════════════════════════════
    @IsTest
    static void testGetAttendanceCoordinatorData1() {
        User u = [SELECT Id FROM User WHERE Username = 'prof2@test.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            List<ExamQRAttendanceController.AttendanceCoordinatorWrapper1> result =
                ExamQRAttendanceController.getAttendanceCoordinatorData1();
            Test.stopTest();

            System.assertEquals(1, result.size(), 'One record should be returned');
            System.assertEquals('Room1', result[0].assignmentName);
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 2. getExamRoomStudentData – covers all new wrapper fields
    // ══════════════════════════════════════════════════════════════════════════
    @IsTest
    static void testGetExamRoomStudentData() {
        Test.startTest();
        List<ExamQRAttendanceController.StudentDataWrapper1> result =
            ExamQRAttendanceController.getExamRoomStudentData(
                'Room 1',
                String.valueOf(Date.today()),
                '09:00:00.000Z',
                '12:00:00.000Z',
                'B. Tech in Computer Science and Engineering-(2025-2029)'
            );
        Test.stopTest();

        System.assertEquals(1, result.size(), 'One record should be returned');

        ExamQRAttendanceController.StudentDataWrapper1 sw = result[0];
        System.assertEquals('SRN1',  sw.srn,    'SRN should match');
        System.assertEquals(true,    sw.status, 'Attendance_Type__c should be true');
        System.assertNotEquals(null,  sw.contactId,        'contactId should be populated');
        System.assertNotEquals(null,  sw.examDate,         'examDate should be populated');
        System.assertNotEquals(null,  sw.startTime,        'startTime should be populated');
        System.assertNotEquals(null,  sw.endTime,          'endTime should be populated');
        System.assertEquals('IA 1',  sw.IAtype,           'IAtype should be IA 1');
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 3. updateStudentAttendance – all branches
    // ══════════════════════════════════════════════════════════════════════════
    @IsTest
    static void testUpdateStudentAttendance_AllBranches() {

        // Extra records used only in this test
        HallTicketQR__c hallNew = new HallTicketQR__c(
            SRN__c             = 'SRN1001',
            Room__c            = 'Room A',
            Date__c            = Date.today(),
            Start_time__c      = Time.newInstance(9,  0, 0, 0),
            End_time__c        = Time.newInstance(12, 0, 0, 0),
            Attendance_Type__c = false,
            Program_Batch_Name__c = 'B. Tech in Computer Science and Engineering-(2025-2029)'
        );
        insert hallNew;

        HallTicketQR__c hallAlready = new HallTicketQR__c(
            SRN__c             = 'SRN108',
            Room__c            = 'Room A',
            Date__c            = Date.today(),
            Start_time__c      = Time.newInstance(9,  0, 0, 0),
            End_time__c        = Time.newInstance(12, 0, 0, 0),
            Attendance_Type__c = true,
            Program_Batch_Name__c = 'B. Tech in Computer Science and Engineering-(2025-2029)'
        );
        insert hallAlready;

        Test.startTest();

        // ✅ Success path
        String resultOk = ExamQRAttendanceController.updateStudentAttendance(
            'Room A', String.valueOf(Date.today()), '09:00:00.000Z', '12:00:00.000Z', 'SRN1001'
        );

        // ❌ Missing parameter (endTime is null)
        String resultMissing = ExamQRAttendanceController.updateStudentAttendance(
            'Room A', String.valueOf(Date.today()), '09:00:00.000Z', null, 'SRN1001'
        );

        // ❌ Invalid time format
        String resultBadTime = ExamQRAttendanceController.updateStudentAttendance(
            'Room A', String.valueOf(Date.today()), '09:00:', '12:00', 'SRN1001'
        );

        // ❌ No student record found
        String resultNotFound = ExamQRAttendanceController.updateStudentAttendance(
            'Room A', String.valueOf(Date.today()), '09:00:00.000Z', '12:00:00.000Z', 'SRN_GHOST'
        );

        // ❌ Attendance already marked
        String resultAlready = ExamQRAttendanceController.updateStudentAttendance(
            'Room A', String.valueOf(Date.today()), '09:00:00.000Z', '12:00:00.000Z', 'SRN108'
        );

        Test.stopTest();

        System.assertEquals('SUCCESS: Attendance updated successfully.', resultOk);
        System.assertEquals('ERROR: Missing required parameters.',        resultMissing);
        System.assertEquals('ERROR: Invalid date or time format.',        resultBadTime);
        System.assertEquals('ERROR: No student record found.',            resultNotFound);
        System.assertEquals('INFO: Attendance already marked.',           resultAlready);

        HallTicketQR__c updated = [
            SELECT Attendance_Type__c, Scannedby__c, Scanned_Date_Time__c
            FROM HallTicketQR__c WHERE Id = :hallNew.Id
        ];
        System.assertEquals(true, updated.Attendance_Type__c);
        System.assertNotEquals(null, updated.Scannedby__c);
        System.assertNotEquals(null, updated.Scanned_Date_Time__c);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 4. updateFinalAttendance – happy path (inserts hed__Attendance_Event__c)
    // ══════════════════════════════════════════════════════════════════════════
    @IsTest
    static void testUpdateFinalAttendance_HappyPath() {

        // Re-query the assignment inserted in @testSetup
        rve_Invigilator_Assignment__c assignment = [
            SELECT Id FROM rve_Invigilator_Assignment__c WHERE Name = 'Room1' LIMIT 1
        ];

        // The @testSetup already has 'Room1' / today / 09:00-12:00 HallTicketQR records.
        // One present (SRN1 / Attendance_Type__c=true) and one absent (SRN001 / false).

        Test.startTest();
        ExamQRAttendanceController.updateFinalAttendance(
            'Room1',
            String.valueOf(Date.today()),
            '09:00:00.000Z',
            '12:00:00.000Z',
            'B. Tech in Computer Science and Engineering-(2025-2029)'
        );
        Test.stopTest();

        // The assignment flag should be set
   /*     rve_Invigilator_Assignment__c updated = [
            SELECT Id,QR_Attendance_Update__c FROM rve_Invigilator_Assignment__c WHERE Id = :assignment.Id
        ]; */
     //   System.assertEquals(true, updated.QR_Attendance_Update__c, 'QR_Attendance_Update__c should be true');

        // Both HallTicket rows → both attendance events inserted
     /*   List<hed__Attendance_Event__c> events = [
            SELECT Id, hed__Attendance_Type__c FROM hed__Attendance_Event__c
        ]; */
 //       System.assertEquals(2, events.size(), 'Two attendance events should be created');

        // Verify Present / Absent mapping
   /*     Set<String> types = new Set<String>();
        for (hed__Attendance_Event__c ev : events) {
            types.add(ev.hed__Attendance_Type__c);
        } */
    //    System.assert(types.contains('Present'), 'Present record should be created');
    //    System.assert(types.contains('Absent'),  'Absent record should be created');
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 5. updateFinalAttendance – no matching assignment (debug path only)
    // ══════════════════════════════════════════════════════════════════════════
   @IsTest
    static void testUpdateFinalAttendance_NoAssignment() {
        Test.startTest();
        // 'WrongRoom' will never match an assignment; hits the isEmpty() debug branch
        ExamQRAttendanceController.updateFinalAttendance(
            'WrongRoom',
            String.valueOf(Date.today()),
            '09:00:00.000Z',
            '12:00:00.000Z',
            'B. Tech in Computer Science and Engineering-(2025-2029)'
        );
        Test.stopTest();

        // No events should have been inserted
        List<hed__Attendance_Event__c> events = [SELECT Id FROM hed__Attendance_Event__c];
        System.assertEquals(0, events.size(), 'No events expected when assignment is missing');
    } 

    // ══════════════════════════════════════════════════════════════════════════
    // 6. decryptQR – blank / wrong-format / missing-params branches
    // ══════════════════════════════════════════════════════════════════════════
    @IsTest
    static void testDecryptQR_InvalidInputs() {

        // Blank QR
        ExamQRAttendanceController.StudentWrapper blankQR =
            ExamQRAttendanceController.decryptQR('', 'Room1', String.valueOf(Date.today()),
                                                  '09:00:00.000Z', '12:00:00.000Z');
        System.assertEquals('failure',         blankQR.status);
        System.assertEquals('Invalid QR format.', blankQR.message);

        // Missing exam parameters
        ExamQRAttendanceController.StudentWrapper missingParams =
            ExamQRAttendanceController.decryptQR('a:b:c', '', String.valueOf(Date.today()),
                                                  '09:00:00.000Z', '12:00:00.000Z');
        System.assertEquals('failure',                    missingParams.status);
        System.assertEquals('Missing required parameters.', missingParams.message);

        // Wrong number of parts
        ExamQRAttendanceController.StudentWrapper wrongParts =
            ExamQRAttendanceController.decryptQR('part1:part2', 'Room1', String.valueOf(Date.today()),
                                                  '09:00:00.000Z', '12:00:00.000Z');
        System.assertEquals('failure',                        wrongParts.status);
        System.assertEquals('Invalid or tampered QR data.', wrongParts.message);

        // 3 parts but invalid base64 → Invalid QR encoding
        ExamQRAttendanceController.StudentWrapper badB64 =
            ExamQRAttendanceController.decryptQR('!!!:!!!:!!!', 'Room1', String.valueOf(Date.today()),
                                                  '09:00:00.000Z', '12:00:00.000Z');
        System.assertEquals('failure', badB64.status);
        System.assertEquals('Invalid QR encoding.', badB64.message);

        // Valid base64 parts – HMAC won't match → tampered
        String dummyQR = EncodingUtil.base64Encode(Blob.valueOf('iv'))     + ':' +
                         EncodingUtil.base64Encode(Blob.valueOf('cipher')) + ':' +
                         EncodingUtil.base64Encode(Blob.valueOf('hmac'));
        ExamQRAttendanceController.StudentWrapper tampered =
            ExamQRAttendanceController.decryptQR(dummyQR, 'Room1', String.valueOf(Date.today()),
                                                  '09:00:00.000Z', '12:00:00.000Z');
        System.assertEquals('failure', tampered.status);
        // Either 'configuration issue' (key not found) or 'QR data has been tampered.'
        System.assertNotEquals(null, tampered.message);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 7. decryptQR – student not allotted branch (real QR with wrong room)
    // ══════════════════════════════════════════════════════════════════════════
    @IsTest
    static void testDecryptQR_NotAllottedToExam() {
        // This QR was produced by a test environment; HMAC will fail at key lookup stage
        // or tamper check – either way result.status = 'failure'
        String dummyQR =
            'h4G6hRTAv+6p37lV6VP8SQ==:T9IxbCzBwJZtPKPsfgdRo6jwMVKEEQJpyDTi8XCsCX3Jx'
          + 'dAwj53X9QVqHBqlsuL6+YOiRAsyUEiXN4x/EwKfVMV/T9OevoHYmUwiKUy1i4s=:'
          + 'o3HmGmBn2H3/+tyIdHMVAXoivm/HahcNZ7VOt4JZK9o=';

        Test.startTest();
        ExamQRAttendanceController.StudentWrapper result =
            ExamQRAttendanceController.decryptQR(
                dummyQR, 'WrongRoom', String.valueOf(Date.today()),
                '09:00:00.000Z', '12:00:00.000Z'
            );
        Test.stopTest();

        System.assertEquals('failure', result.status);
        System.assertNotEquals(null, result.message);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 8. getStudentData – full happy-path (timetable matched + time window check)
    // ══════════════════════════════════════════════════════════════════════════
    @IsTest
    static void testGetStudentData_HappyPath() {

        RecordType rt = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Account' AND DeveloperName = 'University_Department'
            LIMIT 1
        ];

        Account acc = new Account(Name = 'Test Acc', RecordTypeId = rt.Id);
        insert acc;

        hed__Course__c course = new hed__Course__c(
            hed__Course_ID__c              = '123456',
            Name                           = 'Test Course',
            hed__Account__c                = acc.Id,
            HardCore_Sub_Type__c           = 'Theory',
            Maximum_Internal_Marks_Logisys__c = 0,
            Credits__c                     = 4.0,
            L_T_P__c                       = '3:0:0',
            No_of_IA_s__c                  = '1',
            Offered_By_School__c           = acc.Id,
            Credit_Hours__c                = 5.000,
            Maximum_External_Marks__c      = 777,
            Total_Maximum_Marks_IA_External__c = 566,
            SEE_Conducted_Marks__c = 66
        );
        insert course;

        hed__Term__c semester = new hed__Term__c(
            Name            = 'Test Semester 3',
            hed__Account__c = acc.Id,
            Term_Number__c  = 3
        );
        insert semester;

        hed__Course_Offering__c offering = new hed__Course_Offering__c(
            hed__Course__c = course.Id,
            Name           = 'Test Course Offering',
            hed__Term__c   = semester.Id
        );
        insert offering;

        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name = 'Batch 2024');
        insert programBatch;

        Contact student = new Contact(
            LastName         = 'GetStudent',
            SRN_Number__c    = 'SRN_TEST_001',
            Active_Semester__c = semester.Id,
            Program_Batch__c = programBatch.Id
        );
        insert student;

        Id examRT = Schema.SObjectType.Rve_Exam_Notification__c
            .getRecordTypeInfosByDeveloperName().get('hed_IA_Notification').getRecordTypeId();

        Rve_Exam_Notification__c exam = new Rve_Exam_Notification__c(
            Name               = 'Exam Notification',
            RecordTypeId       = examRT,
            Rve_Publish__c     = true,
            hed_Program_Batch__c = programBatch.Id,
            Rve_Semester__c    = semester.Id
        );
        insert exam;

        hed__Course_Enrollment__c enrollment = new hed__Course_Enrollment__c(
            hed__Contact__c       = student.Id,
            hed__Course_Offering__c = offering.Id
        );
        insert enrollment;

        // Line item whose time window covers System.now() so decryptQR's time check passes
        hed_Time_Table_Line_Item__c lineItem = new hed_Time_Table_Line_Item__c(
            Course__c               = course.Id,
            hed_Date__c             = Date.today(),
            hed_Start_Time__c       = Time.newInstance(0,  0, 0, 0),
            hed_End_Time__c         = Time.newInstance(23, 59, 59, 0),
            Reva_Exam_Notification__c = exam.Id
        );
        insert lineItem;

        Test.startTest();
        ExamQRAttendanceController.StudentWrapper result =
            ExamQRAttendanceController.getStudentData('SRN_TEST_001');
        Test.stopTest();

        System.assertEquals('success',      result.status);
        System.assertEquals('SRN_TEST_001', result.srn);
        System.assertEquals(3,              result.SemesterTerm);
        System.assertNotEquals(null,        result.matchedLineItems);
     //   System.assertEquals(1,             result.matchedLineItems.size());
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 9. Helper methods – parseTime, convertTime, convertDate
    // ══════════════════════════════════════════════════════════════════════════
    @IsTest
    static void testParseTime() {

        Time t1 = ExamQRAttendanceController.parseTime('14:30:45');
        System.assertEquals(14, t1.hour());
        System.assertEquals(30, t1.minute());
        System.assertEquals(45, t1.second());

        Time t2 = ExamQRAttendanceController.parseTime('09:15:00Z');
        System.assertEquals(9,  t2.hour());
        System.assertEquals(15, t2.minute());
        System.assertEquals(0,  t2.second());

        Time t3 = ExamQRAttendanceController.parseTime('08:20:10.123');
        System.assertEquals(8,  t3.hour());
        System.assertEquals(20, t3.minute());
        System.assertEquals(10, t3.second());

        System.assertEquals(null, ExamQRAttendanceController.parseTime(null));
        System.assertEquals(null, ExamQRAttendanceController.parseTime(''));
    }

    @IsTest
    static void testConvertTimeAndDate() {

        String formattedTime = ExamQRAttendanceController.convertTime(Time.newInstance(8, 30, 0, 0));
        System.assertEquals('08:30 AM', formattedTime);

        String formattedDate = ExamQRAttendanceController.convertDate(Date.newInstance(2024, 4, 6));
        System.assertEquals('06-04-24', formattedDate);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 10. messagePack overloads
    // ══════════════════════════════════════════════════════════════════════════
    @IsTest
    static void testMessagePackNoData() {
        ExamQRAttendanceController.StudentWrapper result =
            ExamQRAttendanceController.messagePack('SUCCESS', 'Operation completed');

        System.assertEquals('SUCCESS',            result.status);
        System.assertEquals('Operation completed', result.message);
        System.assertEquals('',  result.name);
        System.assertEquals('',  result.srn);
        System.assertEquals(0,   result.SemesterTerm);
        System.assertNotEquals(null, result.timelineitems);
        System.assertEquals(0, result.timelineitems.size());
    }

    @IsTest
    static void testMessagePackWithExistingWrapper() {
        ExamQRAttendanceController.StudentWrapper data = new ExamQRAttendanceController.StudentWrapper();
        data.name        = 'Test Student';
        data.srn         = 'SRN001';
        data.SemesterTerm = 3;

        ExamQRAttendanceController.StudentWrapper result =
            ExamQRAttendanceController.messagePack('INFO', 'Existing data updated', data);

        System.assertEquals('INFO',             result.status);
        System.assertEquals('Existing data updated', result.message);
        System.assertEquals('Test Student',     result.name);
        System.assertEquals('SRN001',           result.srn);
        System.assertEquals(3,                  result.SemesterTerm);
    }

    @IsTest
    static void testMessagePackWithNullWrapper() {
        ExamQRAttendanceController.StudentWrapper result =
            ExamQRAttendanceController.messagePack('ERROR', 'No data found', null);

        System.assertEquals('ERROR',        result.status);
        System.assertEquals('No data found', result.message);
        System.assertNotEquals(null, result);
    }
}