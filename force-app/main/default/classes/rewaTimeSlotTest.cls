@isTest
public class rewaTimeSlotTest {

    @isTest(seeAllData=true)
    static void testFetchCustomMetadataMap() {
        

        // Call the fetchCustomMetadataMap method
        Test.startTest();
        Map<String, List<RSW_Manodhaara_CMT__mdt>> resultMap = rewaTimeSlot.fetchCustomMetadataMap();
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, resultMap, 'Result map should not be null');
        
        // Assuming you have some specific entries in the map based on your logic,
        // you may want to add assertions based on your expected result.
        // For example:
        // System.assertEquals(1, resultMap.size(), 'Expected 1 entry in the map');
        // System.assertEquals(1, resultMap.get('10:00 AM - 11:00 AM').size(), 'Expected 1 record for the time slot');
    }
}