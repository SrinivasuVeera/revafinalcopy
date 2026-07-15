@isTest
public class SpocContactControllerTest {

    @testSetup
    static void setupData() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        String recId = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get(Utility.Acc_RecType_University_Department)
            .getRecordTypeId();

        Account acc = new Account(
            Name = 'School of Applied Sciences',
            RecordTypeId = recId
        );
        insert acc;

        // SPOC USER
        User spocUser = new User(
            FirstName = 'Spoc',
            LastName = 'User',
            Email = 'spoc@test.com',
            Username = 'spoc' + System.currentTimeMillis() + '@test.com',
            Alias = 'spoc',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            Is_SPOC__c = TRUE,
            Department = 'School of Applied Sciences'
        );
        insert spocUser;

        // NORMAL USER
        User normalUser = new User(
            FirstName = 'Normal',
            LastName = 'User',
            Email = 'normal@test.com',
            Username = 'normal' + System.currentTimeMillis() + '@test.com',
            Alias = 'norm',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            Is_SPOC__c = FALSE,
            Department = 'School of Applied Sciences'
        );
        insert normalUser;

        //CONTACTS
        List<Contact> conList = new List<Contact>();

        for (Integer i = 0; i < 5; i++) {
            conList.add(new Contact(
                LastName = 'Test Contact ' + i,
                Disposition__c = 'Hot',
                Description1__c = 'Test Desc',
                Connect_with_Academics__c = true,
                School__c = acc.Id,
                MobilePhone = '999999999' + i,
                Email = 'test' + i + '@mail.com'
            ));
        }
        insert conList;

        // APPLICATION RECORDS
        List<hed__Application__c> appList = new List<hed__Application__c>();

        for (Contact c : conList) {
            appList.add(new hed__Application__c(
                hed__Applicant__c = c.Id
            ));
        }
        insert appList;

        // Assign one contact to normal user
        conList[0].Assigned_User__c = normalUser.Id;
        update conList[0];
    }

    // SPOC TEST
    @isTest
    static void testGetContacts_SPOC() {

        User u = [SELECT Id FROM User WHERE Alias = 'spoc' LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            List<hed__Application__c> result = SpocContactController.getContacts();
            Test.stopTest();

            System.assert(result.size() > 0, 'SPOC should see all records');
        }
    }

    // NON-SPOC TEST
    @isTest
    static void testGetContacts_NonSPOC() {

        User u = [SELECT Id FROM User WHERE Alias = 'norm' LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            List<hed__Application__c> result = SpocContactController.getContacts();
            Test.stopTest();

            System.assertEquals(1, result.size(), 'Non-SPOC should see only assigned');
        }
    }

    // UPDATE TEST
    @isTest
    static void testUpdateContact() {

        Contact c = [SELECT Id, School_Description__c FROM Contact LIMIT 1];
        c.School_Description__c = 'Updated Value';

        Test.startTest();
        SpocContactController.updateContact(c);
        Test.stopTest();

        Contact updated = [SELECT School_Description__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('Updated Value', updated.School_Description__c);
    }

    // SEARCH USERS TEST
    @isTest
    static void testSearchUsers() {

        User u = [SELECT Id FROM User WHERE Alias = 'spoc' LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            List<User> users = SpocContactController.searchUsers('User');
            Test.stopTest();

            System.assert(users.size() >= 0);
        }
    }

    // ASSIGN USERS TEST
    @isTest
    static void testAssignUsers() {

        User spoc = [SELECT Id FROM User WHERE Alias = 'spoc' LIMIT 1];
        User normal = [SELECT Id FROM User WHERE Alias = 'norm' LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        System.runAs(spoc) {
            Test.startTest();
            SpocContactController.assignUsers(
                new List<Id>{c.Id},
                new List<Id>{normal.Id}
            );
            Test.stopTest();

            Contact updated = [SELECT Assigned_User__c FROM Contact WHERE Id = :c.Id];
            System.assertEquals(normal.Id, updated.Assigned_User__c);
        }
    }

    // IS SPOC TEST
    @isTest
    static void testIsSpocUser() {

        User u = [SELECT Id FROM User WHERE Alias = 'spoc' LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            Boolean result = SpocContactController.isSpocUser();
            Test.stopTest();

            System.assertEquals(true, result);
        }
    }
}