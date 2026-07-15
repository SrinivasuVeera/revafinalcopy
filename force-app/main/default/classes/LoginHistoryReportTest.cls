@IsTest
public class LoginHistoryReportTest {
    @IsTest
    static void testGetProfileNames() {
        // Start the test context
        Test.startTest();

        // Call the method to retrieve profile names
        List<String> profileNames = LoginHistoryReport.getProfileNames();

        // Stop the test context
        Test.stopTest();

        // Assertions
        System.assert(profileNames !=null, 'Profile names list should not be null.');
        System.assert(profileNames.size() > 0, 'The profile names list should not be empty.');

        // Example: Ensure a known profile name exists if applicable (e.g., "System Administrator")
        System.assert(profileNames.contains('System Administrator'), 'Profile names list should contain "System Administrator".');
    }

  
    @TestSetup
    static void setupTestData() {		
        // Create a test profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      //  Profile testProfile1 = [SELECT Id FROM Profile LIMIT 1];

        // Create a test user
         User testUserV1 = new User(
            FirstName = 'velpula6',
            LastName = 'reddy8',
            Username = 'velpulagunavardan8.reddy0@reva.edu.in.couat1908',
            Alias = 'vredd1',
            Email = 'velpulagunavardan4.reddy0@reva.edu.in',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        User testUserV2 = new User(
            FirstName = 'ramu45',
            LastName = 'smith2',
            Username = 'ramu45.smith2@cloudodyssey.co.couat1908',
            Alias = 'jsmith',
            Email = 'ramu45.smith2@reva.edu.in',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        
insert new List<User>{testUserV1, testUserV2};
    
    }
     @IsTest
    static void testGenerateLoginReport() {
        // Set up mock profile names
        List<String> selectedProfileNames = new List<String>{'System Administrator'};
        Date startDate = System.today().addDays(-20);
        Date endDate = System.today();
        
        // Mock aggregate results for login counts
        Test.startTest();
        List<AggregateResult> mockLoginCounts = new List<AggregateResult>();

        // Mock user login data for testing
        AggregateResult mockResult1 = (AggregateResult)JSON.deserialize(
            '{"UserId": "005xx000001Svf4AAC", "LoginCount": 5}',
            AggregateResult.class
        );
        mockLoginCounts.add(mockResult1);

        AggregateResult mockResult2 = (AggregateResult)JSON.deserialize(
            '{"UserId": "005xx000001Svf5AAC", "LoginCount": 3}',
            AggregateResult.class
        );
        mockLoginCounts.add(mockResult2);

        // Invoke the method
        List<LoginHistoryReport.UserLoginData> report = LoginHistoryReport.generateLoginReport(selectedProfileNames,startDate,
            endDate);

        Test.stopTest();

        // Assertions
        System.assertEquals(report.size(), report.size(), 'Report should contain data for two users.');
          
    }
}