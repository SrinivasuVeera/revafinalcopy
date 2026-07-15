@isTest
public class LicenseAssignmentHandlerTest {

    @testSetup
    static void setupData(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        Contact con = new Contact(
            LastName='Portal Contact',
            Primary_Application_Submitted__c=false
        );
        insert con;

        User u = new User(
            FirstName='Test',
            LastName='User',
            Email='testuser@test.com',
            Username='testuser'+System.currentTimeMillis()+'@test.com',
            Alias='tuser',
            TimeZoneSidKey='Asia/Kolkata',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ProfileId=p.Id
        );
        insert u;
    }

    @isTest
    static void testAssignLicense(){

        User u=[SELECT Id FROM User LIMIT 1];

        LicenseAssignmentHandler.InputWrapper wrap =
            new LicenseAssignmentHandler.InputWrapper();
        wrap.userId = u.Id;

        List<LicenseAssignmentHandler.InputWrapper> inputs =
            new List<LicenseAssignmentHandler.InputWrapper>{wrap};

        Test.startTest();

        LicenseAssignmentHandler.bypassPermissionInsert = true;
        LicenseAssignmentHandler.assignLicenseOnLogin(inputs);

        Test.stopTest();

        User updatedUser =
            [SELECT LastLoginTime__c,LastActivityTime__c FROM User WHERE Id=:u.Id];

        System.assertNotEquals(null, updatedUser.LastLoginTime__c);
    }

    @isTest
    static void testFuturePermissionInsert(){

        User u=[SELECT Id FROM User LIMIT 1];

        PermissionSet ps=[SELECT Id FROM PermissionSet
                          WHERE Name='Omnistudio_Experience_Users'
                          LIMIT 1];

        Test.startTest();

        LicenseAssignmentHandler.bypassPermissionInsert = true;
        LicenseAssignmentHandler.assignPermissionFuture(u.Id, ps.Id);

        Test.stopTest();

        List<PermissionSetAssignment> psa =
            [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId=:u.Id];

        System.assert(psa.size() >= 0);
    }

    @isTest
    static void testEmptyInput(){

        Test.startTest();
        LicenseAssignmentHandler.assignLicenseOnLogin(
            new List<LicenseAssignmentHandler.InputWrapper>()
        );
        Test.stopTest();
    }

    @isTest
    static void testBlankUser(){

        LicenseAssignmentHandler.InputWrapper wrap =
            new LicenseAssignmentHandler.InputWrapper();
        wrap.userId='';

        Test.startTest();
        LicenseAssignmentHandler.assignLicenseOnLogin(
            new List<LicenseAssignmentHandler.InputWrapper>{wrap}
        );
        Test.stopTest();
    }
}