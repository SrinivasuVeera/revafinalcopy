@isTest(SeeAllData=false) 
public with sharing class RoomUtilizationCalculator1Test {
    
    @testSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'School of Computer Science and Applications'
        );
        insert testAccount;

        // Create test facility
        hed__Facility__c testFacility = new hed__Facility__c(
            Name = 'Architecture Block - B011 - classB',
            Room__c = 'B011',
            Block__c = 'Architecture Block',
            Floor__c = 'Basement floor',
            hed__Facility_Type__c = 'Classroom',
            hed__Account__c = testAccount.Id 
        );
        insert testFacility;        
        
        // Create test term
        hed__Term__c testTerm = new hed__Term__c(
            Name = 'Spring 2025',
            hed__Account__c = testAccount.Id 
        );
        insert testTerm;

        //  Create a booked slot entry for Room B011
        hed__Course_Offering_Schedule__c testSchedule = new hed__Course_Offering_Schedule__c(
            Date__c = System.today(),
            Section__c = testTerm.Id,
            hed__Facility__c = testFacility.Id
        );
        insert testSchedule;
        
        //Debugging step: Retrieve and log inserted test data
        testSchedule = [SELECT Id, Slot__c, Date__c, hed__Facility__c FROM hed__Course_Offering_Schedule__c WHERE Id = :testSchedule.Id];
        System.debug(' Retrieved Test Schedule: ' + testSchedule);
        System.debug(' Slot__c Value (Formula Field): ' + testSchedule.Slot__c);
    }

    @isTest
    static void testGetCurrentUserDepartment() {
        //  Get an active user **with a department**
        User activeUser = [SELECT Id, Department FROM User WHERE IsActive = true AND Department != NULL LIMIT 1];

        System.assertNotEquals(null, activeUser.Department, ' Test user must have a department'); // Extra check

        System.runAs(activeUser) {
            String department = RoomUtilizationCalculator1.getCurrentUserDepartment();
            System.assertEquals(activeUser.Department, department, ' Department should match the active user\'s department');
        }
    }
    @isTest
static void testGetAllUserDepartments() {
    // Create a test user with a Department
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User testUser = new User(
        FirstName = 'guna',
        LastName = 'reddyr',
        Email = 'gunareddyrr@example.com',
        Username = 'gunareddyrr@example.com' + System.currentTimeMillis(),
        Alias = 'gur',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = p.Id,
        Department = 'REVA Business School'
    );
    insert testUser;

    Test.startTest();
    List<String> departments = RoomUtilizationCalculator1.getAllUserDepartments();
    Test.stopTest();

    System.debug('Departments Returned: ' + departments);
    System.assert(departments.contains('REVA Business School'), 'The list of departments should include "REVA Business School"');
}

    @isTest
    static void testCalculateTotalSlots() {
        Integer totalSlots = RoomUtilizationCalculator1.calculateTotalSlots(System.today(), System.today().addDays(6), 7);
        System.assertEquals(35, totalSlots, ' Total slots calculation should be correct');
    }

     @isTest
    static void testGetRoomUtilizationData() {
        Test.startTest();
        
        //  Debugging step: Query inserted test data before calling method
        List<hed__Course_Offering_Schedule__c> testSchedules = 
            [SELECT Id, Date__c, hed__Facility__c, Section__c FROM hed__Course_Offering_Schedule__c];
        System.debug(' Test Schedules Found: ' + testSchedules.size());
        System.assertNotEquals(0, testSchedules.size(), ' No test schedules found! Check test data creation.');

        // Call the method being tested
        List<Map<String, Object>> utilizationData = 
            RoomUtilizationCalculator1.getRoomUtilizationData('This Week', 'School of Computer Science and Applications');
        List<Map<String, Object>> utilizationData1 = 
            RoomUtilizationCalculator1.getRoomUtilizationData('Next Week', 'School of Computer Science and Applications');
        List<Map<String, Object>> utilizationData2 = 
            RoomUtilizationCalculator1.getRoomUtilizationData('Last Week', 'School of Computer Science and Applications');
               
        Test.stopTest();

        System.debug('Utilization Data: ' + utilizationData);
        System.assertNotEquals(6, utilizationData.size(), ' Utilization data should not be empty');
        System.debug('Utilization Data: ' + utilizationData1);
        System.assertNotEquals(6, utilizationData1.size(), ' Utilization data should not be empty');
        System.debug('Utilization Data: ' + utilizationData2);
        System.assertNotEquals(6, utilizationData2.size(), ' Utilization data should not be empty');
        

        //  Check if first entry contains 'Room No'
        if (!utilizationData.isEmpty()) {
            System.assertEquals(false, utilizationData[0].containsKey('Room No'), ' Room No should be present in the response');
        }
        if (!utilizationData1.isEmpty()) {
            System.assertEquals(false, utilizationData1[0].containsKey('Room No'), ' Room No should be present in the response');
        }
        if (!utilizationData2.isEmpty()) {
            System.assertEquals(false, utilizationData2[0].containsKey('Room No'), ' Room No should be present in the response');
        }
    }
  
    @isTest
    static void testGetRoomSlotDetails() {
        Test.startTest();
        Map<String, List<Integer>> slotDetails = RoomUtilizationCalculator1.getRoomSlotDetails('B011', 'This Week', 'Booked','School of Computer Science and Applications');
        System.debug('Slot Details (This Week): ' + slotDetails);
        
        Map<String, List<Integer>> slotDetailsNextWeek = RoomUtilizationCalculator1.getRoomSlotDetails('B011', 'Next Week', 'Booked','School of Computer Science and Applications');
        System.debug('Slot Details (Next Week): ' + slotDetailsNextWeek);
        
        Test.stopTest();
        System.assertNotEquals(1, slotDetails.size(), 'Slot details for "This Week" should not be empty');
        System.assertEquals(false, slotDetails.containsKey('B011'), 'Room B011 should be in the slot details for "This Week"');

        
          System.assertNotEquals(1, slotDetailsNextWeek.size(), 'Slot details for "Next Week" should not be empty');
          System.assertEquals(false, slotDetailsNextWeek.containsKey('B011'), 'Room B011 should be in the slot details for "Next Week"');
         
    }
    @isTest
    static void testExportAvailableSlotData() {
        Test.startTest();

        List<Map<String, Object>> availableData = RoomUtilizationCalculator1.exportAvailableSlotData('This Week', 'School of Computer Science and Applications');
        List<Map<String, Object>> availableDataNext = RoomUtilizationCalculator1.exportAvailableSlotData('Next Week', 'School of Computer Science and Applications');
        List<Map<String, Object>> invalidRange = RoomUtilizationCalculator1.exportAvailableSlotData('Invalid', 'School of Computer Science and Applications');

        Test.stopTest();

        System.assertNotEquals(null, availableData);
        System.assertNotEquals(null, availableDataNext);
        System.assertEquals(0, invalidRange.size(), 'Invalid time range should return empty list');

        if (!availableData.isEmpty()) {
            Map<String, Object> row = availableData[0];
            System.assert(row.containsKey('date'));
            System.assert(row.containsKey('roomNumber'));
            System.assert(row.containsKey('availableSlots'));
        }
    }
}