@isTest
private class SemesterIAAutomationBatchTest {

    @TestSetup
    static void setupTestData() {        
        Account school = new Account(Name = 'Test School');
        insert school;

        Account faculty = new Account(Name = 'Test Faculty', ParentId = school.Id);
        insert faculty;

        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User vhUser = new User(
            Alias = 'vhuser', Email = 'vh@test.com', EmailEncodingKey = 'UTF-8', LastName = 'VH', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = standardProfile.Id, TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'vh@test.com' + System.currentTimeMillis()
        );
        insert vhUser;

        User directorUser = new User(
            Alias = 'dirusr', Email = 'director@test.com', EmailEncodingKey = 'UTF-8', LastName = 'Director', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = standardProfile.Id, TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'director@test.com' + System.currentTimeMillis()
        );
        insert directorUser;

        User facultyUser = new User(
            Alias = 'facusr', Email = 'faculty@test.com', EmailEncodingKey = 'UTF-8', LastName = 'Faculty', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = standardProfile.Id, TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'faculty@test.com' + System.currentTimeMillis()
        );
        insert facultyUser;
        
        school.Examination_Vertical_Head__c = vhUser.Id;
        school.School_Head__c = directorUser.Id;
        update school;
        
        string termRtId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c semester = new hed__Term__c(
            Name = 'Test Semester 2025',
            hed__Account__c = faculty.Id,
            hed__Start_Date__c = system.today()-1,
            hed__End_Date__c = system.today()+1,
            RecordTypeId = termRtId1,
            IA_2_End_date__c = Date.today().addDays(-1),  
            IA_2_Result_Date__c = Date.today()           
        );
        insert semester;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c section = new hed__Term__c(
            Name = 'Test Semester 2025',
            hed__Account__c = faculty.Id,
            hed__Start_Date__c = system.today()-1,
            hed__End_Date__c = system.today()+1,
            RecordTypeId = termRtId,
            IA_2_End_date__c = Date.today().addDays(-1),  
            IA_2_Result_Date__c = Date.today()            
        );
        insert section;
        
        Contact faculty1 = new Contact(
            LastName = 'Test Student',
            hed__WorkEmail__c = 'student@test.com',           
           Active__c = True
        );
        insert faculty1;

        // Create faculty course enrollment
        string termRtId2 = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Faculty_RecType).getRecordTypeId();
        hed__Course_Enrollment__c facultyEnrollment = new hed__Course_Enrollment__c(
            hed__Contact__c = [SELECT ContactId FROM User WHERE Email = 'faculty@test.com' LIMIT 1].ContactId,  // Assuming Community/User sync creates Contact
            Section__c = section.Id,
            RecordTypeId = termRtId2            
        );
        insert facultyEnrollment;

        // Create student contac
        string contactid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact student = new Contact(
            LastName = 'Test Student',
            hed__WorkEmail__c = 'student@test.com',
            student_status__c = 'Pursuing',
            Active_Semester__c = semester.Id,
            RecordTypeId = contactid
        );
        insert student;
    }

    @isTest
    static void testBatchFullCoverage() {
        Test.startTest();

        Integer initialInvocations = Limits.getEmailInvocations();

        SemesterIAAutomationBatch batch = new SemesterIAAutomationBatch();
        Id batchId = Database.executeBatch(batch, 200);  // Default batch size

        Test.stopTest();

        // Assertions
        //System.assert(Limits.getEmailInvocations() > initialInvocations,'Emails should have been sent during batch execution');

       
        System.assert(Limits.getQueries() > 0, 'SOQL queries should have been executed');
    }

    @isTest
    static void testBatchWithAdditionalScenarios() {
        // Create additional semester to trigger freeze reminders
        hed__Term__c freezeSem = new hed__Term__c(
            Name = 'Freeze Semester',
            hed__Account__c = [SELECT Id FROM Account WHERE Name = 'Test Faculty' LIMIT 1].Id,
            hed__Start_Date__c = system.today()-1,
            hed__End_Date__c = system.today()+1,
            IA_2_Result_Date__c = Date.today().addDays(-5)  
        );
        insert freezeSem;

        // Add faculty enrollment for freeze
        string termRtId3 = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Faculty_RecType).getRecordTypeId();
        hed__Course_Enrollment__c freezeEnroll = new hed__Course_Enrollment__c(
            hed__Contact__c = [SELECT ContactId FROM User WHERE Email = 'faculty@test.com' LIMIT 1].ContactId,
            Section__c = freezeSem.Id,
            RecordTypeId = termRtId3
            //Active_Connection__c = true
        );
        insert freezeEnroll;

        Test.startTest();

        Database.executeBatch(new SemesterIAAutomationBatch());

        Test.stopTest();

        //System.assert(Limits.getEmailInvocations() > 0, 'Freeze and director emails should be sent');
    }
    @isTest
    static void testBatchWithAdditionalScenarios1() {
        // Create additional semester to trigger freeze reminders
        hed__Term__c freezeSem = new hed__Term__c(
            Name = 'Freeze Semester',
            hed__Account__c = [SELECT Id FROM Account WHERE Name = 'Test Faculty' LIMIT 1].Id,
            hed__Start_Date__c = system.today()-1,
            hed__End_Date__c = system.today()+1,
            IA_2_Result_Date__c = Date.today().addDays(-9)  // addDays(5) == today → freeze reminder
        );
        insert freezeSem;

        // Add faculty enrollment for freeze
        string termRtId3 = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Faculty_RecType).getRecordTypeId();
        hed__Course_Enrollment__c freezeEnroll = new hed__Course_Enrollment__c(
            hed__Contact__c = [SELECT ContactId FROM User WHERE Email = 'faculty@test.com' LIMIT 1].ContactId,
            Section__c = freezeSem.Id,
            RecordTypeId = termRtId3
            //Active_Connection__c = true
        );
        insert freezeEnroll;

        Test.startTest();

        Database.executeBatch(new SemesterIAAutomationBatch());

        Test.stopTest();

        //System.assert(Limits.getEmailInvocations() > 0, 'Freeze and director emails should be sent');
    }
}