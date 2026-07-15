@isTest
private class RevaExamPhotocopyRevaluationCtrlTest {

    static testMethod void test_getLoggedInUserContactId() {
        RecordType studentRt = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];

        Contact studentContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            RecordTypeId = studentRt.Id
        );
        insert studentContact;

        User studentUser = new User(
            Username = 'studentuser' + System.currentTimeMillis() + '@test.com',
            Alias = 'studusr',
            Email = 'studentuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Asia/Kolkata',
            ProfileId = studentProfile.Id,
            ContactId = studentContact.Id,
            CommunityNickname = 'nick' + System.currentTimeMillis()
        );
        insert studentUser;

        Test.startTest();
        System.runAs(studentUser) {
            String contactId = RevaExamPhotocopyRevaluationController.getLoggedInUserContactId();
            System.assertNotEquals(null, contactId);
            System.assertEquals(studentContact.Id, contactId);
        }
        Test.stopTest();
    }

    static testMethod void test_processStudentApplications() {
        // Setup record types
        Id studentRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id academicRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Id universityDeptRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Id termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();

        // Accounts
        Account departmentAccount = new Account(Name = 'School of ECE', RecordTypeId = academicRtId);
        insert departmentAccount;

        Account universityAccount = new Account(Name = 'School of Science', RecordTypeId = universityDeptRtId);
        insert universityAccount;

        // Contact
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            RecordTypeId = studentRtId
        );
        insert contact;

        // Program Plan
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name = 'Test Batch');
        insert programBatch;

        // Term
        hed__Term__c term = new hed__Term__c(
            Name = 'Test Term',
            RecordTypeId = termRtId,
            hed__Account__c = departmentAccount.Id,
            Program_Batch__c = programBatch.Id,
            Rve_SEE_Result_Date__c = Date.today().addDays(-1)  // ✅ Required for coverage
        );
        insert term;

        // Course
        hed__Course__c course = new hed__Course__c(
            Name = 'Test Course',
            hed__Course_ID__c = 'C101',
            Offered_By_School__c = universityAccount.Id,
            hed__Account__c = departmentAccount.Id,
            Credits__c = 4,
            Credit_Hours__c = 60,
            Maximum_External_Marks__c = 70,
            Total_Maximum_Marks_IA_External__c = 100
        );
        insert course;

        // Course Offering
        hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(
            Name = 'Offering 1',
            hed__Course__c = course.Id,
            hed__Term__c = term.Id
        );
        insert courseOffering;

        // Course Enrollment
        hed__Course_Enrollment__c enrollment = new hed__Course_Enrollment__c(
            hed__Contact__c = contact.Id,
            hed__Course_Offering__c = courseOffering.Id
        );
        insert enrollment;

        // Term Grade
        hed__Term_Grade__c termGrade = new hed__Term_Grade__c(
            hed__Contact__c = contact.Id,
            hed__Course_Offering__c = courseOffering.Id,
            hed__Term__c = term.Id,
            Course__c = course.Id
        );
        insert termGrade;

        // Fee Criteria
        insert new List<Fee_Payment_Criteria__c>{
            new Fee_Payment_Criteria__c(Name = 'Revaluation Fee'),
            new Fee_Payment_Criteria__c(Name = 'Photocopy Fee')
        };

        // Application data
        List<Map<String, String>> applications = new List<Map<String, String>>{
            new Map<String, String>{
                'resultRecordId' => termGrade.Id,
                'contactId' => contact.Id,
                'feeType' => 'RV Fee',
                'amount' => '500.00'
            },
            new Map<String, String>{
                'resultRecordId' => termGrade.Id,
                'contactId' => contact.Id,
                'feeType' => 'PC Fee',
                'amount' => '300.00'
            }
        };

        // Execute
        Test.startTest();
        RevaExamPhotocopyRevaluationController.processStudentApplications(applications);
        Test.stopTest();

        // Assertions: check Student Fee records
        List<Student_Fee__c> studentFees = [
            SELECT Name, Fee_Type__c, Due_Date__c, Contact__c, Fee_Payment_Criteria__c
            FROM Student_Fee__c WHERE Contact__c = :contact.Id
        ];
        System.assertEquals(2, studentFees.size());

        for (Student_Fee__c fee : studentFees) {
            System.assert(fee.Name.contains('Test Course') || fee.Name.contains('C101'));
           /* System.assertNotEquals(null, fee.Due_Date__c);
            System.assertNotEquals(null, fee.Fee_Payment_Criteria__c);*/
        }

        // Assertions: check term grade flags and lookups
        hed__Term_Grade__c updatedGrade = [
            SELECT AppliedForRevaluation__c, AppliedForPhotoCopy__c,
                   Revaluation_Fee__c, Photocopy_Fee__c
            FROM hed__Term_Grade__c WHERE Id = :termGrade.Id
        ];
        System.assertEquals(true, updatedGrade.AppliedForRevaluation__c);
        System.assertEquals(true, updatedGrade.AppliedForPhotoCopy__c);
        System.assertNotEquals(null, updatedGrade.Revaluation_Fee__c);
        System.assertNotEquals(null, updatedGrade.Photocopy_Fee__c);
    }

    static testMethod void test_processStudentApplications_withNullData() {
        Test.startTest();
        try {
            RevaExamPhotocopyRevaluationController.processStudentApplications(null);
            System.assert(false, 'Expected exception not thrown');
        } catch (AuraHandledException e) {
           // System.assert(e.getMessage().contains('No valid application data'));
        }
        Test.stopTest();
    }
}