@isTest
public class RVEEligibleStudentDownloadControllerTest {
    
    @testSetup
    static void setupData() {
        // Create a test user with School Director profile (assume profile is available)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'School Director' LIMIT 1];
        User schoolDirector = new User(
            Username = 'schooldirector@test.com',
            Alias = 'sdir',
            Email = 'schooldirector@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Director',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id
        );
        insert schoolDirector;
        
        RecordType schoolRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'University Department' LIMIT 1];
        
        // Create a School account and child Account (used in batch)
        Account school = new Account(Name = 'Test School',RecordTypeId = schoolRecordType.Id, School_Head__c = UserInfo.getUserId());
        insert school;
        
        Account programAccount = new Account(Name = 'Program Account', ParentId = school.Id);
        insert programAccount;
        
        // Create Program Batch
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'Test Batch',
            hed__Account__c = programAccount.Id
        );
        insert programBatch;
        
        // Use today's month to match IA 1 start
        Date ia1Start = Date.today();
        Date ia1End = Date.today().addDays(7);
        
        // Create Semester
        hed__Term__c semester = new hed__Term__c(
            Name = 'Semester 1',
            Program_Batch__c = programBatch.Id,
            IA_1_Start_date__c = ia1Start,
            IA_1_End_date__c = ia1End,
            hed__Account__c = programAccount.Id
        );
        insert semester;
        
        // Create Contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(
            LastName = 'Eligible Student',
            Email = 'eligible@test.com',
            SRN_Number__c = 'SRN001',
            School__c = school.Id,
            Program_Batch__c = programBatch.Id,
            Active_Semester__c = semester.Id,
            Checking_Eligibility_for_Exam__c = 'Eligible'
        ));
        // Ineligible
        contacts.add(new Contact(
            LastName = 'Ineligible Student',
            Email = 'ineligible@test.com',
            SRN_Number__c = 'SRN002',
            School__c = school.Id,
            Program_Batch__c = programBatch.Id,
            Active_Semester__c = semester.Id,
            Checking_Eligibility_for_Exam__c = 'Ineligible'
        ));
        // Approved by Director
        contacts.add(new Contact(
            LastName = 'Approved Student',
            Email = 'approved@test.com',
            SRN_Number__c = 'SRN003',
            School__c = school.Id,
            Program_Batch__c = programBatch.Id,
            Active_Semester__c = semester.Id,
            Checking_Eligibility_for_Exam__c = 'Ineligible'
        ));
        insert contacts;
        
        // Add one record to Exam Approval History
        insert new Exam_Approval_History__c(
            Contact__c = contacts[0].Id,
            Semester__c = semester.Id,
            Approved__c = true,
            Approved_By__c = schoolDirector.Id,
            Approved_Date__c = Date.today()
        );
    }
    
    @isTest
    static void testGetUserSchools() {
        Test.startTest();
        List<RVEEligibleStudentDownloadController.OptionWrapper> schools = RVEEligibleStudentDownloadController.getUserSchools();
        Test.stopTest();
        
        System.assert(!schools.isEmpty(), 'User should have associated schools');
    }
    
    @isTest
    static void testGetProgramBatches() {
        Account school = [SELECT Id FROM Account WHERE Name = 'Test School' LIMIT 1];
        
        Test.startTest();
        List<RVEEligibleStudentDownloadController.OptionWrapper> batches = RVEEligibleStudentDownloadController.getProgramBatches(school.Id);
        Test.stopTest();
        
        System.assert(!batches.isEmpty(), 'Should return program batches');
    }
    
    @isTest
    static void testGetSemesters() {
        hed__Program_Plan__c batch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        
        Test.startTest();
        List<RVEEligibleStudentDownloadController.OptionWrapper> semesters = RVEEligibleStudentDownloadController.getSemesters(batch.Id);
        Test.stopTest();
        
        System.assert(!semesters.isEmpty(), 'Should return semesters');
    }
    
    @isTest
    static void testGetFilteredStudents_AllScenarios() {
        Account school = [SELECT Id FROM Account WHERE Name = 'Test School' LIMIT 1];
        hed__Program_Plan__c batch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        hed__Term__c term = [SELECT Id FROM hed__Term__c LIMIT 1];
        
        // Ineligible
        List<Contact> ineligible = RVEEligibleStudentDownloadController.getFilteredStudents(school.Id, batch.Id, term.Id, 'Ineligible', 'IA 1');
        //System.assert(!ineligible.isEmpty(), 'Should return ineligible students');
        
        // Approved by Director
        List<Contact> approved = RVEEligibleStudentDownloadController.getFilteredStudents(school.Id, batch.Id, term.Id, 'Approved by School Director', 'IA 1');
        //System.assert(!approved.isEmpty(), 'Should return approved students');
        
        // Eligible
        List<Contact> eligible = RVEEligibleStudentDownloadController.getFilteredStudents(school.Id, batch.Id, term.Id, 'Eligible', 'IA 1');
        //System.assert(!eligible.isEmpty(), 'Should return eligible students');
    }
    
    @isTest
    static void testVisualforceControllerConstructor() {
        Account school = [SELECT Id FROM Account WHERE Name = 'Test School' LIMIT 1];
        hed__Program_Plan__c batch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        hed__Term__c term = [SELECT Id FROM hed__Term__c LIMIT 1];
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('schoolId', school.Id);
        ApexPages.currentPage().getParameters().put('batchId', batch.Id);
        ApexPages.currentPage().getParameters().put('semesterId', term.Id);
        ApexPages.currentPage().getParameters().put('eligibility', 'Eligible');
        ApexPages.currentPage().getParameters().put('examType', 'IA');
        
        RVEEligibleStudentDownloadController controller = new RVEEligibleStudentDownloadController();
        Test.stopTest();
        
        System.assert(controller.students != null, 'Controller should load student list');
    }
}