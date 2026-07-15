@isTest
public class SP_SideMenuControllerTest {

    @isTest
    static void testGetProfileSpecificNavigationMenuItems() {
        // Create a test user with a profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile' LIMIT 1];
        Account acc = new Account();
         acc.name='testaccount';
        insert acc;

        Contact testContact = new Contact(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            AccountId = acc.Id
        );
        insert testContact;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser142@example.com',
            Username = 'testuser5698@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id,
            ContactId = testContact.Id
        );
        insert testUser;

        // Set the current user context
        System.runAs(testUser) {
            Test.startTest();
            
            //Try{
                List<NavigationMenuItem> result = SP_SideMenuController.getProfileSpecificNavigationMenuItems();
            //}catch(exception e){
                
            //}
           

            //System.assertNotEquals(null, result);
            //System.assertNotEquals(0, result.size());

            Test.stopTest();
        }
    }

    @isTest
    static void testGetCurrentUserProfileName() {
        // Create a test user with a profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser567@example2.com',
            Username = 'testuser9480@example2.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id
        );
        insert testUser;

        // Set the current user context
        System.runAs(testUser) {
            Test.startTest();

            // Call the method to test
            String result = SP_SideMenuController.getCurrentUserProfileName();
            System.assertEquals('System Administrator', result);
            
            List<NavigationMenuItem>  results = SP_SideMenuController.getNavigationMenuItems('test');

            Test.stopTest();
        }
    }

    @isTest
    static void testGetNavigationLinkSet() {
        // Create a test NavigationLinkSet
//        NavigationLinkSet testLinkSet = new NavigationLinkSet(
           // Name = 'Test Link Set',
  //          DeveloperName = 'Test_Link_Set',
           // Status = 'Live',
    //        NetworkId = Network.getNetworkId()
      //  );
        //insert testLinkSet;

        Test.startTest();

        // Call the method to test
      //  String result = SP_SideMenuController.getNavigationLinkSet('Test_Link_Set');
        //System.assertNotEquals(null, result);
        //System.assertNotEquals('', result);

        Test.stopTest();
    }

    @isTest
    static void testGetNavigationMenuItems() {
        // Create a test NavigationLinkSet
      //  NavigationLinkSet testLinkSet = new NavigationLinkSet(
        //    Name = 'Test Link Set',
        //    DeveloperName = 'Test_Link_Set',
          //  Status = 'Live',
            //NetworkId = Network.getNetworkId()
     //   );
       // insert testLinkSet;

        // Create a test NavigationMenuItem
       // NavigationMenuItem testMenuItem = new NavigationMenuItem(
        //    Label = 'Test Item',
          //  Target = '/test',
            //Type = 'Standard',
            //NavigationLinkSetId = testLinkSet.Id
        //);
        //insert testMenuItem;

        Test.startTest();
         
        // Call the method to test
       // List<NavigationMenuItem> result = SP_SideMenuController.getNavigationMenuItems(testLinkSet.Id);

       // System.assertNotEquals(null, result);
       // System.assertNotEquals(0, result.size());

        Test.stopTest();
    }

}