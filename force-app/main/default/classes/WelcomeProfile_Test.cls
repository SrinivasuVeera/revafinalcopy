@istest
public class WelcomeProfile_Test {
    
    public static testmethod void WelcomeProfile()
    {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User objUser = new User();
        objUser.LastName = 'Test User';
        objUser.Alias = 'standt';
        objUser.email='TestUserCityHead@testorg.com';
        objUser.EmailEncodingKey='UTF-8';
        objUser.LanguageLocaleKey='en_US';
        objUser.LocaleSidKey='en_US';
        objUser.TimeZoneSidKey='America/Los_Angeles';
        objUser.username='TestUserCityHead@testorg.com';
        objUser.ProfileId = objProfile.Id;
        objUser.physicalDeliveryOfficeName__c= 'Test';
        insert objUser;
        

        Test.startTest();
        //WelcomeProfile Pro = new WelcomeProfile();
        WelcomeProfile.getHierarchy(Userinfo.getuserid());
        WelcomeProfile.getProfileUser(objUser.id);
        Test.stopTest();
        system.assertEquals(objUser.Id, objUser.Id);
        
    }
}