@isTest
private class Reva_CustomExceptionTest {
    @isTest static void testRevaCustomException() {
        try {
            // Simulate a scenario that causes the exception to be thrown
            throw new Reva_CustomException('Test Exception');
        } catch (Reva_CustomException e) {
            // Verify that the exception is caught
            System.assertEquals('Test Exception', e.getMessage(), 'The exception message should match the expected message.');
        }
    }
}