@IsTest
public class PicklistValuesControllerTest {
    
  @IsTest
    static void testGetPicklistValues() {
        List<String> picklistValues = PicklistValuesController.getPicklistValues('Account', 'Industry');
        System.assertNotEquals(null, picklistValues, 'The returned list should not be null.');
        System.assert(picklistValues.size() > 0, 'The returned list should contain some picklist values.');
    }
    
      @IsTest
    static void testInsertMenuRecords() {
        // Create a sample JSON string to test the method
        String sampleJson = '[{"type": "Breakfast", "menuItems": ["Aloo Paratha", "Idly"], "startTime": "07:00:00.000", "endTime": "09:00:00.000", "mealDate": "2024-08-17"}]';
        
        // Call the method with the sample JSON string
        Test.startTest();
        PicklistValuesController.insertMenuRecords(sampleJson);
        Test.stopTest();

        // Fetch the inserted records to validate
        List<Reva_Mess_Menu__c> insertedRecords = [SELECT Type__c, Mess_Items__c, Start_Time__c, End_Time__c, Date__c FROM Reva_Mess_Menu__c WHERE Type__c = 'Breakfast'];

        // Assertions to ensure the records were inserted correctly
        System.assertEquals(1, insertedRecords.size(), 'One record should have been inserted.');
        System.assertEquals('Breakfast', insertedRecords[0].Type__c, 'The Type__c field should be "Breakfast".');
        System.assertEquals('Aloo Paratha;Idly', insertedRecords[0].Mess_Items__c, 'The Mess_Items__c field should contain "Aloo Paratha;Idly".');
        System.assertEquals(Time.newInstance(7, 0, 0, 0), insertedRecords[0].Start_Time__c, 'The Start_Time__c field should match the parsed time.');
        System.assertEquals(Time.newInstance(9, 0, 0, 0), insertedRecords[0].End_Time__c, 'The End_Time__c field should match the parsed time.');
        System.assertEquals(Date.newInstance(2024, 8, 17), insertedRecords[0].Date__c, 'The Date__c field should match the parsed date.');
    }
 /***************************************************************************/
    @IsTest
    static void testGetMealTimings() {
        // Insert test data for the custom setting Meal_Timings__c directly inside the test method
        Meal_Timings__c breakfastTiming = new Meal_Timings__c(
            Name = 'Breakfast',
            Start_Time__c = '07:00 AM',
            End_Time__c = '09:00 AM'
        );

        Meal_Timings__c lunchTiming = new Meal_Timings__c(
            Name = 'Lunch',
            Start_Time__c = '12:00 PM',
            End_Time__c = '02:00 PM'
        );

        Meal_Timings__c dinnerTiming = new Meal_Timings__c(
            Name = 'Dinner',
            Start_Time__c = '07:00 PM',
            End_Time__c = '09:00 PM'
        );

        // Insert the test data into the custom setting
        insert breakfastTiming;
        insert lunchTiming;
        insert dinnerTiming;

        // Call the Apex method to be tested
        Map<String, Meal_Timings__c> mealTimingsMap = PicklistValuesController.getMealTimings();

        // Perform assertions to verify the behavior
        System.assertNotEquals(null, mealTimingsMap, 'Meal timings map should not be null');
        System.assertEquals(3, mealTimingsMap.size(), 'There should be 3 meal timings in the map');

        // Check specific values in the map
        Meal_Timings__c breakfastTimingResult = mealTimingsMap.get('Breakfast');
        System.assertNotEquals(null, breakfastTimingResult, 'Breakfast timing should be in the map');
        System.assertEquals('07:00 AM', breakfastTimingResult.Start_Time__c, 'Breakfast start time should be 07:00 AM');

        Meal_Timings__c lunchTimingResult = mealTimingsMap.get('Lunch');
        System.assertNotEquals(null, lunchTimingResult, 'Lunch timing should be in the map');
        System.assertEquals('12:00 PM', lunchTimingResult.Start_Time__c, 'Lunch start time should be 12:00 PM');

        Meal_Timings__c dinnerTimingResult = mealTimingsMap.get('Dinner');
        System.assertNotEquals(null, dinnerTimingResult, 'Dinner timing should be in the map');
        System.assertEquals('07:00 PM', dinnerTimingResult.Start_Time__c, 'Dinner start time should be 07:00 PM');
    }
    
}