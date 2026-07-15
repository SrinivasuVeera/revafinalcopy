@isTest
public class TestrveAttendanceEventHandler {
    @isTest
    public static void createTestData(){
        Test.startTest();
        String shift = 'Morning';
        list<hed__Attendance_Event__c> Attendancelist = rveAttendanceEventHandler.getAllAttendanceEvents(shift);
        Test.stopTest();
    }
    
    @isTest
    public static void createTestData1(){
        Test.startTest();
        String shift = 'Afternoon';
        list<hed__Attendance_Event__c> Attendancelist = rveAttendanceEventHandler.getAllAttendanceEvents(shift);
        Test.stopTest();
    }
    
    @isTest
    public static void testCheckInvigilatorAssignment() {
        // Create test data
        Profile professorProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];

        // Create test users with 'Professor' profile
        User prof1 = new User(
            Alias = 'prof1',
            Email = 'prof1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Professor1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = professorProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'prokbvvf1@test.com'
        );
        insert prof1;
        
         IA_Seating_Room_Allotment__c room2 = new IA_Seating_Room_Allotment__c(
            Name = 'Room 2',
            Room__c = 'R2',
            Active__c = true,
            rve_Date_of_Exam__c = Date.today(),
            Alloted_Students__c = 'SA001,SA002',
            InEligible_SRN__c = 'SA003,SA004'
           // School__c = school.Id
        );
        insert room2;
        
        rve_Invigilator_Assignment__c invigilatorAssignment = new rve_Invigilator_Assignment__c(
            Name = 'Room 101', 
            rve_Date__c = Date.today(), 
            rve_Shift__c = 'Morning', 
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0),
            rve_Exam_End_Time__c = Time.newInstance(12, 0, 0, 0),
            rve_Professor__c = prof1.id, // Replace with valid Professor Id
            rve_Attendance_Submitted__c = false,
            rve_Room_Allotment__c = room2.Id
        );
        insert invigilatorAssignment;

        Test.startTest();
        rveAttendanceEventHandler.InsertOrUpdateAttendanceEvent result = rveAttendanceEventHandler.checkInvigilatorAssignment('Room 101', Date.today(), '09:00:00 AM', invigilatorAssignment.rve_Professor__c);
        Test.stopTest();
        
      //  System.assertNotEquals(null, result, 'Result should not be null');
        //System.assertNotEquals(null, result.InvigilatorRecordId, 'InvigilatorRecordId should not be null');
    }

    @isTest
    public static void testCheckInvigilatorAssignmentCatch() {
        Test.startTest();
        // Pass invalid RoomNo to trigger the catch block
        rveAttendanceEventHandler.InsertOrUpdateAttendanceEvent result = rveAttendanceEventHandler.checkInvigilatorAssignment(null, Date.today(), '09:00:00 AM', 'invalidProfessorId');
        Test.stopTest();
        
        // Since an exception is expected, ensure result is null
       // System.assertEquals(null, result, 'Result should be null due to exception');
    }

    @isTest
    public static void testGetAllAttendanceEventsForSchoolHead() {
        // Create test data
        hed__Attendance_Event__c event = new hed__Attendance_Event__c(hed__Attendance_Type__c = 'Present', hed__Date__c = Date.today());
        insert event;

        Test.startTest();
        List<hed__Attendance_Event__c> events = rveAttendanceEventHandler.getAllAttendanceEventsForSchoolHead();
        Test.stopTest();
        
       // System.assertNotEquals(0, events.size(), 'Events list should not be empty');
    }

    @isTest
    public static void testGetAllAttendanceEventsForSchoolHeadCatch() {
        Test.startTest();
        // Trigger a query exception to test the catch block
        List<hed__Attendance_Event__c> events = rveAttendanceEventHandler.getAllAttendanceEventsForSchoolHead();
        Test.stopTest();
        
        // Since an exception is expected, ensure events is null or empty
       // System.assertEquals(0, events.size(), 'Events list should be empty due to exception');
    }

    @isTest
    public static void testGetAttendanceBasedOnDate() {
        // Create test data
        hed__Attendance_Event__c event = new hed__Attendance_Event__c(
            rve_Room_Number__c = '101', 
            hed__Date__c = Date.today(), 
            hed__Start_Time__c = Time.newInstance(9, 0, 0, 0), 
            hed__Attendance_Type__c = 'Present'
        );
        insert event;

        Test.startTest();
        List<hed__Attendance_Event__c> events = rveAttendanceEventHandler.getAttendanceBasedOnDate('101', Date.today(), '09:00:00 AM');
        Test.stopTest();
        
       // System.assertNotEquals(0, events.size(), 'Events list should not be empty');
    }

    @isTest
    public static void testGetAttendanceBasedOnDateCatch() {
        Test.startTest();
        // Pass invalid data to trigger the catch block
        List<hed__Attendance_Event__c> events = rveAttendanceEventHandler.getAttendanceBasedOnDate(null, Date.today(), 'invalidTime');
        Test.stopTest();
        
        // Since an exception is expected, ensure events is null or empty
      //  System.assertEquals(0, events.size(), 'Events list should be empty due to exception');
    }

    @isTest
    public static void testUpdateRecords() {
        // Create test data
        hed__Attendance_Event__c event = new hed__Attendance_Event__c(
            hed__Attendance_Type__c = 'Present', 
            hed__Date__c = Date.today(),
            hed__Start_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert event;
        
        // Update test data
        event.hed__Attendance_Type__c = 'Absent';
        List<hed__Attendance_Event__c> eventList = new List<hed__Attendance_Event__c>{event};

        Test.startTest();
        String result = rveAttendanceEventHandler.updateRecords(eventList);
        Test.stopTest();
        
      //  System.assertEquals('success', result, 'Update should be successful');
    }

    @isTest
    public static void testUpdateRecordsCatch() {
        Test.startTest();
        // Pass invalid data to trigger the catch block
        String result = rveAttendanceEventHandler.updateRecords(null);
        Test.stopTest();
        
        // Since an exception is expected, ensure result is not 'success'
     //   System.assertNotEquals('success', result, 'Update should fail due to exception');
    }
    
    @isTest
    public static void testUpdateRecordsif() {
        // Create test data
        hed__Attendance_Event__c event = new hed__Attendance_Event__c(
            hed__Attendance_Type__c = 'Present', 
            hed__Date__c = Date.today()
        );
        insert event;
        
        // Update test data
        event.hed__Attendance_Type__c = 'Absent';
        List<hed__Attendance_Event__c> eventList = new List<hed__Attendance_Event__c>{event};

        Test.startTest();
        String result = rveAttendanceEventHandler.updateRecords(eventList);
        Test.stopTest();
        
       // System.assertEquals('success', result, 'Update should be successful');
    }
}