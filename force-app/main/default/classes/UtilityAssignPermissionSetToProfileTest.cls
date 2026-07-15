@isTest
public class UtilityAssignPermissionSetToProfileTest {

    @isTest
    static void testAssignPermissionSet() {
        // Step 1: Create a test user with the Standard User profile
        Profile testProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        if (testProfile == null) {
            System.assert(false, 'No valid profile found for testing.');
        }

        List<User> testUsers = new List<User>();
        for (Integer i = 1; i <= 5; i++) {
            testUsers.add(new User(
                LastName = 'TestUser' + i,
                Email = 'testuser' + i + '33eee367000@example.com',
                Username = 'testuser' + i + '3qse33233221@example.com',
                Alias = 'tuser' + i,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = testProfile.Id
            ));
        }
        insert testUsers;

         // Create an active test user for runAs
        User testAdminUser = new User(
            LastName = 'AdminUser',
            Email = 'adminuser5532ygwggewghhew@example.com',
            Username = 'adminusergygysgugugwugiwq8e@example.com',
            Alias = 'adminusr',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            IsActive = true
        );
        insert testAdminUser;
        System.runAs(testAdminUser) {
            PermissionSet testPermissionSet = new PermissionSet();
            testPermissionSet.Name = 'Test_Permission_Set';
            testPermissionSet.Label = 'Test Permission Set';
            insert testPermissionSet;

            // Step 3: Assign permission set to users
            Test.startTest();
            UtilityAssignPermissionSetToProfileUsers.assignPermissionSet(testProfile.Name, testPermissionSet.Name);
            Test.stopTest();

            // Step 4: Verify PermissionSetAssignment
            List<PermissionSetAssignment> assignedPermissions = [SELECT Id, AssigneeId, PermissionSetId 
                                                                  FROM PermissionSetAssignment 
                                                                  WHERE PermissionSetId = :testPermissionSet.Id];
            System.assertEquals(testUsers.size(), assignedPermissions.size(), 'All test users should have the permission set assigned.');
        }
    }

    @isTest
    static void testInvalidProfile() {
        Test.startTest();

        UtilityAssignPermissionSetToProfileUsers.assignPermissionSet('Invalid_Profile_Name', 'Test_Permission_Set');

        Test.stopTest();
    }

    @isTest
    static void testInvalidPermissionSet() {
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Test.startTest();

        UtilityAssignPermissionSetToProfileUsers.assignPermissionSet(testProfile.Name, 'Invalid_Permission_Set');

        Test.stopTest();
    }
}