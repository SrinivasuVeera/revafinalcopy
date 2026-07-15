@isTest
private class RPL_GetAccademicProgramAndReturnListTest {

    @isTest
    static void testActivateRevaPlacement() {
        // Test input data
        List<String> inputList = new List<String>{'Program1,Program2,Program3'};

        // Call the activateRevaPlacement method
        Test.startTest();
        List<List<String>> result = RPL_GetAccademicProgramAndReturnList.activateRevaPlacement(inputList);
        Test.stopTest();

        // Add assertions to verify the behavior of the activateRevaPlacement method
        // For example, check if the result list contains the expected values after splitting the input string.
        System.assertEquals(1, result.size(), 'Expected one list in the result');
        List<String> outputList = result[0];
        System.assertEquals(3, outputList.size(), 'Expected three programs in the output list');
        System.assertEquals('Program1', outputList[0], 'Expected Program1 in the output list');
        System.assertEquals('Program2', outputList[1], 'Expected Program2 in the output list');
        System.assertEquals('Program3', outputList[2], 'Expected Program3 in the output list');
    }

    // Add more test methods as needed to cover different scenarios and functionality.
}