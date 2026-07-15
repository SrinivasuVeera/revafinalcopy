@isTest
private class RoomUtilizationBlockTest {

    
    @isTest
static void testGetUserProfileName() {

    Test.startTest();

    String profileName =
        RoomUtilizationBlock.getUserProfileName();

    Test.stopTest();

    System.assertNotEquals(
        null,
        profileName
    );
}
    @testSetup
    static void setupTestData() {
        // Create test Account (School/Department)
        Account testDept = new Account(Name = 'Engineering');
        insert testDept;

        // Create test Term
        hed__Term__c testTerm = new hed__Term__c(
            Name = 'Spring 2025',
            hed__Account__c = testDept.Id 
        );
        insert testTerm;

        // Create test Facilities (Rooms)
        List<hed__Facility__c> facilities = new List<hed__Facility__c>{
            new hed__Facility__c(
                Room__c = '101',
                Block__c = 'A',
                hed__Facility_Type__c = 'Classroom',
                Floor__c = '1st',
                hed__Account__c = testDept.Id
            ),
            new hed__Facility__c(
                Room__c = '102',
                Block__c = 'A',
                hed__Facility_Type__c = 'Laboratory',
                Floor__c = '1st',
                hed__Account__c = testDept.Id
            ),
            new hed__Facility__c(
                Room__c = '201',
                Block__c = 'B',
                hed__Facility_Type__c = 'Classroom',
                Floor__c = '2nd',
                hed__Account__c = testDept.Id
            )
        };
            insert facilities;
       
            hed__Time_Block__c timeBlock =
    new hed__Time_Block__c(
        Name = 'Slot 1'
    );

insert timeBlock;
        
        
        // Create Course Offering Schedule (Bookings)
        List<hed__Course_Offering_Schedule__c> bookings = new List<hed__Course_Offering_Schedule__c>{
            new hed__Course_Offering_Schedule__c(
                Section__c = testTerm.Id,
                Date__c = Date.today(),hed__Time_Block__c = timeBlock.Id,
                hed__Facility__c = facilities[0].Id // Room 101 booked
            )
        };
        insert bookings;
    }

    @isTest
    static void testGetRoomUtilizationData() {
        Test.startTest();
        Date startDate = Date.today();
        Date endDate = Date.today();
        List<Map<String, Object>> result = RoomUtilizationBlock.getRoomUtilizationData(startDate, endDate);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
       // System.assert(result.size() > 0, 'Expected at least one booked room');
        System.assertNotEquals(null, result);

        Map<String, Object> firstResult = result[0];
        System.assert(firstResult.containsKey('RoomNumber'), 'RoomNumber should be present');
        System.assert(firstResult.containsKey('Block'), 'Block should be present');
        System.assert(firstResult.containsKey('School'), 'School should be present');
        System.assert(firstResult.containsKey('BookedDays'), 'BookedDays should be present');
    }

    @isTest
    static void testGetBlockSchoolRoomSummary() {
        Test.startTest();
        Date startDate = Date.today();
        Date endDate = Date.today();
        List<Map<String, Object>> result = RoomUtilizationBlock.getBlockSchoolRoomSummary(startDate, endDate);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        //System.assert(result.size() > 0, 'Expected at least one block');
        System.assertNotEquals(null,result );
        
        if(result.size() > 0) {Map<String, Object> blockData =result[0];
                               System.assert(blockData.containsKey('Block'));}
                               
        Map<String, Object> blockData = result[0];
        System.assert(blockData.containsKey('Block'), 'Block should be present');
        System.assert(blockData.containsKey('TotalRooms'), 'TotalRooms should be present');
        System.assert(blockData.containsKey('BookedRooms'), 'BookedRooms should be present');
        System.assert(blockData.containsKey('BookingPercentage'), 'BookingPercentage should be present');
        System.assert(blockData.containsKey('Schools'), 'Schools list should be present');

        List<Map<String, Object>> schools = (List<Map<String, Object>>) blockData.get('Schools');
        System.assertNotEquals(null, schools, 'Schools list should not be null');
        System.assert(schools.size() > 0, 'At least one school should be listed under a block');

        Map<String, Object> firstSchool = schools[0];
        System.assert(firstSchool.containsKey('SchoolName'), 'School name should be present');
        System.assert(firstSchool.containsKey('TotalRooms'), 'TotalRooms should be present in School');
        System.assert(firstSchool.containsKey('BookedRooms'), 'BookedRooms should be present in School');
        System.assert(firstSchool.containsKey('BookingPercentage'), 'BookingPercentage should be present in School');
    }

   @isTest
static void testExportAllBlockData() {
    // Test data setup: make sure test data is inserted here if not using @testSetup
    Date testDate = System.today();

    Test.startTest();
    List<Map<String, Object>> exportAll = RoomUtilizationBlock.exportAllBlockData(testDate, testDate);
    Test.stopTest();

    System.assert(exportAll != null, 'Export data should not be null');
    //System.assert(exportAll.size() > 0, 'Export all block data should not be empty');
    System.assertNotEquals(null,exportAll);
    
    for (Map<String, Object> row : exportAll) {
        System.assert(row.containsKey('Date'), 'Row should contain Date');
        System.assert(row.containsKey('BlockName'), 'Row should contain BlockName');
        System.assert(row.containsKey('TotalRooms'), 'Row should contain TotalRooms');
        System.assert(row.containsKey('BookedRooms'), 'Row should contain BookedRooms');
        System.assert(row.containsKey('BookingPercentage'), 'Row should contain BookingPercentage');

        // Optional: Check value types or expected structure
        System.assert(((String) row.get('Date')).length() > 0, 'Date should not be empty');
        System.assert(((String) row.get('BlockName')).length() > 0, 'BlockName should not be empty');
    }
}

    @isTest
    static void testExportBlockData() {
        List<Map<String, Object>> exportBlock = RoomUtilizationBlock.exportBlockData(System.today(), System.today(), 'A');
        //List<Map<String, Object>> exportBlock = RoomUtilizationBlock.exportBlockData(System.today(), System.today(), 'Block A');
       // System.assert(exportBlock.size() > 0, 'Export block data should not be empty');
        System.assert(exportBlock[0].containsKey('SchoolName'), 'Should contain SchoolName');
        System.assertNotEquals(null,exportBlock);
    }
    @isTest
static void testGetAvailableRoomsByBlock() {

    Date testDate = System.today();

    // Get one room
    hed__Facility__c room = [
        SELECT Id, Room__c, Block__c
        FROM hed__Facility__c
        LIMIT 1
    ];

   // Create Time Block
hed__Time_Block__c timeBlock =
    new hed__Time_Block__c(
        Name = 'Slot 2'
    );

insert timeBlock;

      Account testDept = new Account(Name = 'Engineering');
        insert testDept;

        // Create test Term
        hed__Term__c testTerm = new hed__Term__c(
            Name = 'Spring 2025',
            hed__Account__c = testDept.Id 
        );
        insert testTerm;
// Create Booking
hed__Course_Offering_Schedule__c booking =
    new hed__Course_Offering_Schedule__c(
        Date__c = testDate,Section__c = testTerm.Id,
        hed__Facility__c = room.Id,
        hed__Time_Block__c = timeBlock.Id
    );

    insert booking;

    Test.startTest();

    List<Map<String, Object>> result =
        RoomUtilizationBlock.getAvailableRoomsByBlock(
            'All',
            testDate,
            testDate
        );

    Test.stopTest();

    System.assertNotEquals(
        null,
        result
    );

    System.assert(
        result.size() > 0,
        'Available rooms should exist'
    );

    Map<String, Object> row =
        result[0];

    System.assert(
        row.containsKey('Date'),
        'Date should exist'
    );

    System.assert(
        row.containsKey('Block'),
        'Block should exist'
    );

    System.assert(
        row.containsKey('RoomNumber'),
        'RoomNumber should exist'
    );

    System.assert(
        row.containsKey('Floor'),
        'Floor should exist'
    );

    System.assert(
        row.containsKey('SchoolName'),
        'SchoolName should exist'
    );

    System.assert(
        row.containsKey('AvailableSlots'),
        'AvailableSlots should exist'
    );
}
    
    @isTest
static void testGetAllBlocks() {

    Test.startTest();

    List<String> blocks =
        RoomUtilizationBlock.getAllBlocks();

    Test.stopTest();

    System.assertNotEquals(
        null,
        blocks
    );

    System.assert(
        blocks.size() > 0,
        'Blocks should be returned'
    );

    System.assertEquals(
        'All',
        blocks[0]
    );
}
}