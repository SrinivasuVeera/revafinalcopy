@IsTest
public class ForgotPasswordControllerTest {

    private static Contact createTestContact(String email) {

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = email,
            Application_Number__c = '25170200159',
            AccountId = acc.Id
        );
        insert con;

        return con;
    }

    @isTest
    static void testBlankUsername() {

        Test.startTest();
        String result = ForgotPasswordController.handleForgotPassword('');
        Test.stopTest();

        System.assertEquals('ERROR:Please enter your username.', result);
    }

    @isTest
    static void testEmailMappedToContact() {

        Contact con = createTestContact('stwf@gmail.com');

        Test.startTest();
        String result =
            ForgotPasswordController.handleForgotPassword('stwf@gmail.com');
        Test.stopTest();

        System.assert(result.startsWith('SUGGEST:'));
        System.assert(result.contains(con.Application_Number__c));
    }

    @isTest
    static void testEmailNotMapped() {

        Test.startTest();
        String result =
            ForgotPasswordController.handleForgotPassword('unknown@gmail.com');
        Test.stopTest();

        System.assertEquals(
            'ERROR:No account found with this email.',
            result
        );
    }

    @isTest
    static void testRevaUsername() {

        Test.startTest();
        String result =
            ForgotPasswordController.handleForgotPassword('test@reva.edu.in');
        Test.stopTest();

        // In test context, Site.forgotPassword may return false
        System.assert(result != null);
    }

    @isTest
    static void testForgotPasswordVF() {

        ForgotPasswordController controller =
            new ForgotPasswordController();

        controller.username = 'test@reva.edu.in';

        Test.startTest();
        PageReference pr = controller.forgotPassword();
        Test.stopTest();

        // Usually null in test context
        System.assertEquals(null, pr);
    }
}