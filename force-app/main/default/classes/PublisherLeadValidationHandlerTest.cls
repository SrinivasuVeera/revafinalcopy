@istest
public class PublisherLeadValidationHandlerTest {
    @testSetup
    static void createTestData() {

        // Publisher Profile
        Profile publisherProfile = [
            SELECT Id, Name
            FROM Profile
            WHERE Name = 'Reva Publisher'
            LIMIT 1
        ];

      

        // Publisher User
        User publisherUser = new User(
            FirstName = 'Publisher',
            LastName = 'User',
            Alias = 'pubusr',
            Email = 'publisher@test.com',
            Username = 'publisher' + System.currentTimeMillis() + '@test.com',
            ProfileId = publisherProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert publisherUser;

    
        // Create Account
        Account acc = new Account(
            Name = 'School of Engineering'
        );
        insert acc;
        
        // Create Program Plan
        hed__Program_Plan__c pp = new hed__Program_Plan__c(
            Name = 'Engineering Batch',
            hed__Account__c = acc.Id
        );
        insert pp;
        
        // Create Fee Master
        Fee_Master__c fm = new Fee_Master__c(
            Program_Batch__c = pp.Id,
            Program_Name_Display__c = 'b.tech computer science',
            Applicant_Category__c = 'Non-Resident Indian(NRI)',
            Fee_Type__c = 'Application Fee',
            Application_Number_Prefix__c = '240401',
            Fee_Amount__c = 1000,
            IsActive__c = true
        );
        
        insert fm;
    }

    // =========================================
    // Test Valid Publisher Lead
    // =========================================
@isTest
static void testValidPublisherLead() {

    User publisherUser = [
        SELECT Id
        FROM User
        WHERE Alias = 'pubusr'
        LIMIT 1
    ];

    Fee_Master__c fm = [
        SELECT Id,
               School_Name__c,
               Program_Name_Display__c
        FROM Fee_Master__c
        LIMIT 1
    ];

    System.runAs(publisherUser) {

        Lead validLead = new Lead(
            LastName = 'Valid Lead',
            Company = 'Test Company',
            School__c = fm.School_Name__c,
            Program_Name_Display__c = fm.Program_Name_Display__c
        );

        Test.startTest();

        insert validLead;
        List<Lead> leadList = new List<Lead>{ validLead };
        PublisherLeadValidationTriggerHandler.validateSchoolAndProgram(leadList);

        Test.stopTest();

        System.assertNotEquals(null, validLead.Id);
    }
}
    // =========================================
    // Test Invalid Publisher Lead
    // =========================================
    @isTest
    static void testInvalidPublisherLead() {

        User publisherUser = [
            SELECT Id
            FROM User
            WHERE Alias = 'pubusr'
            LIMIT 1
        ];

        Lead invalidLead = new Lead(
            LastName = 'Invalid Lead',
            Company = 'Test Company',
            OwnerId = publisherUser.Id,
            School__c = 'Invalid School',
            Program_Name_Display__c = 'Invalid Program'
        );

        Test.startTest();

        try {

            insert invalidLead;

          

        } catch (DmlException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Invalid School and Program combination.'
                )
            );
        }

        Test.stopTest();
    }

    @isTest
    static void testBlankValues() {

        User publisherUser = [
            SELECT Id
            FROM User
            WHERE Alias = 'pubusr'
            LIMIT 1
        ];

        Lead blankLead = new Lead(
            LastName = 'Blank Lead',
            Company = 'Test Company',
            OwnerId = publisherUser.Id
        );

        Test.startTest();

        insert blankLead;

        Test.stopTest();

        System.assertNotEquals(
            null,
            blankLead.Id
        );
    }
}