@IsTest
public class ProgrambatchFirstNumbericTest {
 @IsTest
    public static void testExtractFirstFourNumbers() {
        
        // Create a list of Request objects to pass to the Invocable method
        List<ProgrambatchFirstNumberic.Request> requestList = new List<ProgrambatchFirstNumberic.Request>();
        
        // Test case 1: String with more than four numeric characters
        ProgrambatchFirstNumberic.Request request1 = new ProgrambatchFirstNumberic.Request();
        request1.textInput = 'ABC123XYZ4567';
        requestList.add(request1);
        
        // Test case 2: String with fewer than four numeric characters
        ProgrambatchFirstNumberic.Request request2 = new ProgrambatchFirstNumberic.Request();
        request2.textInput = 'A1B2';
        requestList.add(request2);
        
        // Test case 3: String with no numeric characters
        ProgrambatchFirstNumberic.Request request3 = new ProgrambatchFirstNumberic.Request();
        request3.textInput = 'ABCXYZ';
        requestList.add(request3);
        
        // Test case 4: Empty string
        ProgrambatchFirstNumberic.Request request4 = new ProgrambatchFirstNumberic.Request();
        request4.textInput = '';
        requestList.add(request4);
        
        // Test case 5: Null value
        ProgrambatchFirstNumberic.Request request5 = new ProgrambatchFirstNumberic.Request();
        request5.textInput = null;
        requestList.add(request5);
        
        // Call the invocable method
        List<String> result = ProgrambatchFirstNumberic.extractFirstFourNumbers(requestList);
        
        // Assertions to verify the correct behavior
        System.assertEquals(5, result.size(), 'Result list should have 5 elements');

        // Assert the result for each test case
        System.assertEquals('1234', result[0], 'Test case 1 failed: expected 1234');
        System.assertEquals('12', result[1], 'Test case 2 failed: expected 12');
        System.assertEquals('', result[2], 'Test case 3 failed: expected empty string');
        System.assertEquals('', result[3], 'Test case 4 failed: expected empty string');
        System.assertEquals('', result[4], 'Test case 5 failed: expected empty string for null input');
    }
}