@isTest
public class FreezeProfessorCoursePreBatchTest {

    @testSetup
    static void setupData() {

        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive= true AND UserRoleId != NULL LIMIT 1];
       // UserRole userRole = [SELECT Id FROM UserRole LIMIT 1];


        System.runAs(adminUser) {
            Id accRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            Account acc = new Account(Name = 'TestAcc', RecordTypeId = accRtId);
            insert acc;

            Id profRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
            Contact con = new Contact(LastName = 'TestCon', AccountId = acc.Id, RecordTypeId = profRtId);
            insert con;

            Id termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
            hed__Term__c term = new hed__Term__c(
                Name = 'Test Term',
                hed__Account__c = acc.Id,
                RecordTypeId = termRtId,
                hed__Start_Date__c = system.today().adddays(-16),
                hed__End_Date__c =system.today().adddays(16),
                Allow_Professors_for_Preferences__c = true,
                Approval_Status__c = 'Confirmed'
            );
            insert term;

            hed__Course__c course = new hed__Course__c(
                Name = 'EEE',
                hed__Course_ID__c = 'EEE1',
                hed__Account__c = acc.Id,
                Credits__c = 4,
                Offered_By_School__c = acc.Id,
                Credit_Hours__c = 4,
                Maximum_External_Marks__c = 50,
                Total_Maximum_Marks_IA_External__c = 100,
                No_of_IA_s__c = '1',
				L_T_P__c='1:2:3'
            );
            insert course;

            hed__Course_Offering__c offering = new hed__Course_Offering__c(
                Name = 'EEE Offering',
                hed__Course__c = course.Id,
                hed__Term__c = term.Id
            );
            insert offering;

            Professor_Student_Course_Preference__c pref = new Professor_Student_Course_Preference__c(
                Course_Offering__c = offering.Id,
                Professor__c = con.Id,
                Semester__c = term.Id,
                Preference__c = '1',
                Professor_Preference__c = false
            );
            insert pref;
        }
    }

    @isTest
    static void testBatchFreezesProfessorPreferences() {
        hed__Term__c oldTerm = [SELECT Id, Allow_Professors_for_Preferences__c, Active__c, Approval_Status__c FROM hed__Term__c LIMIT 1];

        oldTerm.Allow_Professors_for_Preferences__c = false;

        Test.startTest();

        update oldTerm;
        Test.stopTest();

        Professor_Student_Course_Preference__c updatedPref = [SELECT Professor_Preference__c FROM Professor_Student_Course_Preference__c LIMIT 1];
        System.assertEquals(true, updatedPref.Professor_Preference__c, 'The Professor_Preference__c field should be updated to true.');
    }
}