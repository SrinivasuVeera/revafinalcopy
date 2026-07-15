@isTest
private class HallTicketDownloadControllerTest {
   
    @TestSetup
    static void makeData() {        
        Account university = new Account(
            Name = 'Test University',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Educational_Institution').getRecordTypeId()
        );
        insert university;

        Account faculty = new Account(
            Name = 'Test Faculty',
            ParentId = university.Id
        );
        insert faculty;

        Account school = new Account(
            Name = 'Test School',
            ParentId = university.Id
        );
        insert school;
       
        Account program = new Account(
            Name = 'Test Program',
            ParentId = faculty.Id
        );
        insert program;
       
        hed__Program_Plan__c programPlan = new hed__Program_Plan__c(
            Name = 'Test Batch 2025',
            hed__Account__c = program.Id,
            hed__Start_Date__c = system.today().addDays(-5),
        hed__End_Date__c = system.today().addyears(+1)
        );
        insert programPlan;

        hed__Term__c semester = new hed__Term__c(
            Name = 'Sem 1 2025',
            Program_Batch__c = programPlan.Id,
            hed__Account__c = program.Id,
            hed__Start_Date__c = system.today().addDays(-5),
        hed__End_Date__c = system.today().addyears(+1)
        );
        insert semester;

        Contact student = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            SRN_Number__c = 'R21SG101',
            Student_Status__c = 'Pursuing',
            Active_Semester__c = semester.Id,
            Checking_Eligibility_for_Exam__c = 'Eligible',
            Email = 'john.doe@test.com'
        );
        insert student;

        Rve_Exam_Notification__c iaNotification = new Rve_Exam_Notification__c(
            RecordTypeId = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName()
                .get('hed_IA_Notification').getRecordTypeId(),
            Rve_Publish__c = true,
            hed_IA_Type__c = 'IA 1',           
            Rve_End_Date__c = system.today(),
            rve_Exam_Start_Date__c = system.today(),
            Rve_Semester__c = semester.Id
        );
        insert iaNotification;

        Rve_Exam_Notification__c semesterNotification = new Rve_Exam_Notification__c(
            RecordTypeId = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName()
                .get('hed_Semester_Notification').getRecordTypeId(),
            Rve_Publish__c = true,
            Rve_End_Date__c = system.today(),
            rve_Exam_Start_Date__c = system.today(),
            Rve_Semester__c = semester.Id
        );
        insert semesterNotification;
    }

    @isTest
    static void testGetUniversityList() {
        Account university = [SELECT Id, Name FROM Account WHERE Name = 'Test University' LIMIT 1];
        
        Test.startTest();
        List<String> result = HallTicketDownloadController.getUniversityList('Test University');
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return one university');
        System.assert(result[0].contains(university.Id), 'Should contain university Id');
        System.assert(result[0].contains(university.Name), 'Should contain university Name');
    }

    @isTest
    static void testGetAccountBasedOnParentIdList() {
        Account university = [SELECT Id FROM Account WHERE Name = 'Test University' LIMIT 1];
        
        Test.startTest();
        List<String> result = HallTicketDownloadController.getAccountBasedOnParentIdList(university.Id);
        Test.stopTest();

        System.assert(result.size() >= 2, 'Should return at least two accounts (faculty and school)');
        Boolean hasFaculty = false, hasSchool = false;
        for (String item : result) {
            if (item.contains('Test Faculty')) hasFaculty = true;
            if (item.contains('Test School')) hasSchool = true;
        }
        System.assert(hasFaculty, 'Should include Test Faculty');
        System.assert(hasSchool, 'Should include Test School');
    }

    @isTest
    static void testGetProgramBatchList() {
        Account program = [SELECT Id FROM Account WHERE Name = 'Test Program' LIMIT 1];
        
        Test.startTest();
        List<String> result = HallTicketDownloadController.getProgramBatchList(program.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return one program batch');
        System.assert(result[0].contains('Test Batch 2025'), 'Should contain batch name');
    }

    @isTest
    static void testGetSemesterList() {
        hed__Program_Plan__c programPlan = [SELECT Id FROM hed__Program_Plan__c WHERE Name = 'Test Batch 2025' LIMIT 1];
        
        Test.startTest();
        List<String> result = HallTicketDownloadController.getSemesterList(programPlan.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return one semester');
        System.assert(result[0].contains('Sem 1 2025'), 'Should contain semester name');
    }

    @isTest
    static void testValidateExamNotification() {
        hed__Term__c semester = [SELECT Id FROM hed__Term__c WHERE Name = 'Sem 1 2025' LIMIT 1];
        
        Test.startTest();
        Boolean iaResult = HallTicketDownloadController.validateExamNotification(semester.Id, 'IA 1');
        Boolean semesterResult = HallTicketDownloadController.validateExamNotification(semester.Id, 'Semester Exam');
        Test.stopTest();

        System.assertEquals(true, iaResult, 'Should return true for IA 1 notification');
        System.assertEquals(true, semesterResult, 'Should return true for Semester Exam notification');
    }

     @isTest
    static void getEligibleStudents() {
        hed__Term__c semester = [SELECT Id FROM hed__Term__c WHERE Name = 'Sem 1 2025' LIMIT 1];
        Contact con = [Select Id from Contact WHERE SRN_Number__c = 'R21SG101' LIMIT 1];
        
        Test.startTest();
        List<HallTicketDownloadController.StudentWrapper> results =
            HallTicketDownloadController.getEligibleStudents(semester.Id, 'Eligible');
        Test.stopTest();        

       System.assertEquals(1, results.size(), 'Should return 2 eligible students');
        Set<String> srns = new Set<String>();
        for (HallTicketDownloadController.StudentWrapper sw : results) {
            srns.add(sw.SRN);
        }

        System.assert(srns.contains('R21SG101'), 'Result should contain R21SG101');
        
    }
    @isTest static void test_saveBulkPdfAsFile_oneStudent() {
        hed__Term__c sem = [SELECT Id,Name FROM hed__Term__c LIMIT 1];
        Contact c = [SELECT Id FROM Contact WHERE SRN_Number__c = 'R21SG101' LIMIT 1];

        Test.startTest();
        List<Id> cvIds = HallTicketDownloadController.saveBulkPdfAsFile(
                            sem.Id, 'Eligible', new List<Id>{c.Id}, null);
        Test.stopTest();

        System.assertEquals(1, cvIds.size(), 'One PDF file');
        ContentVersion cv = [SELECT Title, PathOnClient FROM ContentVersion WHERE Id = :cvIds[0]];
        System.assert(cv.Title.startsWith('HallTickets_Eligible_Sem 1 2025_Part1_of_1'),
                      'Title format');
        System.assert(cv.PathOnClient.endsWith('.pdf'));
    }

    @isTest static void test_saveBulkPdfAsFile_twoBatches() {
        hed__Term__c sem = [SELECT Id FROM hed__Term__c LIMIT 1];
        List<Contact> cons = [SELECT Id FROM Contact];
        List<Id> ids = new List<Id>();
        for (Contact c : cons) ids.add(c.Id);

        List<Contact> extras = new List<Contact>();
        for (Integer i=3; i<=35; i++) {
            extras.add(new Contact(
                FirstName = 'X'+i, LastName = 'Y',
                SRN_Number__c = 'R21SG'+String.valueOf(100+i).leftPad(3,'0'),
                Student_Status__c = 'Pursuing',
                Active_Semester__c = sem.Id,
                Checking_Eligibility_for_Exam__c = 'Eligible'
            ));
        }
        insert extras;
        for (Contact c : extras) ids.add(c.Id);

        Test.startTest();
        List<Id> cvIds = HallTicketDownloadController.saveBulkPdfAsFile(
                            sem.Id, 'Eligible', ids, 20);
        Test.stopTest();

        System.assertEquals(2, cvIds.size(), '35 students → 2 PDFs');
        List<ContentVersion> cvs = [SELECT Title FROM ContentVersion WHERE Id = :cvIds];
        
    }
    @isTest static void test_saveBulkPdfAsFile_customBatch() {
        hed__Term__c sem = [SELECT Id FROM hed__Term__c LIMIT 1];
        List<Id> ids = new List<Id>(new Map<Id,Contact>([SELECT Id FROM Contact]).keySet());

        Test.startTest();
        List<Id> cvIds = HallTicketDownloadController.saveBulkPdfAsFile(
                            sem.Id, 'Eligible', ids, 10);
        Test.stopTest();

        Integer expectedBatches = (ids.size() + 9) / 10;
        System.assertEquals(expectedBatches, cvIds.size(),
                            'Batch size 10 → '+expectedBatches+' files');
    }
    @isTest static void test_saveBulkPdfAsFile_noStudents() {
        hed__Term__c sem = [SELECT Id FROM hed__Term__c LIMIT 1];

        Test.startTest();
        List<Id> cvIds = HallTicketDownloadController.saveBulkPdfAsFile(
                            sem.Id, 'Eligible', new List<Id>(), 20);
        Test.stopTest();

        System.assert(cvIds.isEmpty(), 'No PDFs when no students');
    }
    @isTest static void test_sharing() {
        hed__Term__c sem = [SELECT Id FROM hed__Term__c LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        List<Id> cvIds = HallTicketDownloadController.saveBulkPdfAsFile(
                            sem.Id, 'Eligible', new List<Id>{c.Id}, null);
        Test.stopTest();

        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvIds[0]].ContentDocumentId;
        List<ContentDocumentLink> links = [
            SELECT Id FROM ContentDocumentLink
            WHERE ContentDocumentId = :docId
              AND LinkedEntityId = :UserInfo.getUserId()
        ];
        System.assertEquals(1, links.size(), 'PDF shared with current user');
    }
}