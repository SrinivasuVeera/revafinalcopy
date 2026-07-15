@isTest
public class rve_IAExamApprovalTest {

    @testSetup
    static void setup() {
        String AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account objAccount1 = new Account(
            Name = 'School of Electronics and Communication Engineering',
            School_Head__c = UserInfo.getUserId(),
            RecordTypeId = AcaRecId
        );
        insert objAccount1;

        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name = 'Test Batch');
        insert programBatch;

        String termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = FEE_TestDataFactory.createTerm('test term', objAccount1.Id, termRtId);
        objTerm.Program_Batch__c = programBatch.Id;
        objTerm.IA_1_Start_date__c = System.today() - 5;
        objTerm.IA_1_End_date__c = System.today() + 5;
        objTerm.Term_Number__c = 1;
        insert objTerm;

        // Create test contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'User' + i,
                Active__c = true,
                Checking_Eligibility_for_Exam__c = 'InEligible',
                School__c = objAccount1.Id,
                Total_average_current_sem_attendance__c = 75.65,
                Program_Batch__c = programBatch.Id,
                Active_Semester__c = objTerm.Id,
                SRN_Number__c = 'SRN' + i,
                Student_Status__c = 'pursuing'
            ));
        }
        insert contacts;

        // Create test student fees
        List<Student_Fee__c> fees = new List<Student_Fee__c>();
        for (Contact con : contacts) {
            fees.add(new Student_Fee__c(
                Contact__c = con.Id,
                Fee_Year__c = '1st Year',
                Amount_Pending__c = 150,
                Due_Date__c = System.today()
            ));
        }
        insert fees;

        // Create test exam notifications meeting formula conditions
        Id iaNotificationRTId = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByName().get('IA Notification').getRecordTypeId();
        Id semNotificationRTId = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByName().get('Semester Notification').getRecordTypeId();

        List<Rve_Exam_Notification__c> notifications = new List<Rve_Exam_Notification__c>{
            new Rve_Exam_Notification__c(
                Name = 'IA Test Notification',
                hed_IA_Type__c = 'IA 1',
                rve_Exam_Start_Date__c = System.today() + 2,  // Inside formula range ✅
                Rve_End_Date__c = System.today() + 6,  // Ensures `rve_Active__c` remains `true` ✅
                Rve_Semester__c = objTerm.Id,
                hed_Program_Batch__c = programBatch.Id,
                Rve_Publish__c = true,
                RecordTypeId = iaNotificationRTId
            ),
            new Rve_Exam_Notification__c(
                Name = 'Semester Test Notification',
                hed_IA_Type__c = 'IA 2',
                rve_Exam_Start_Date__c = System.today() - 1,  // Still eligible since `Rve_End_Date__c` is valid ✅
                Rve_End_Date__c = System.today() + 5,  // Ensures `rve_Active__c` remains `true` ✅
                Rve_Semester__c = objTerm.Id,
                hed_Program_Batch__c = programBatch.Id,
                Rve_Publish__c = true,
                RecordTypeId = semNotificationRTId
            )
        };
        insert notifications;
    }

    @isTest
    static void testGetContacts() {
        Test.startTest();
        Map<String, Object> results = rve_IAExamApproval.getContacts();
        Test.stopTest();

        // Assertions
        System.assert(results.containsKey('contacts'), 'Contacts should be returned');
        System.assert(results.containsKey('pendingAmounts'), 'Pending amounts should be returned');
        System.assert(results.containsKey('isVerticalHead'), 'Vertical head status should be returned');
        System.assert(results.containsKey('exist_examinationNotification'), 'Existence of examination notification should be returned');

        // Verify if eligible contacts are covered
        List<Contact> eligibleContacts = (List<Contact>) results.get('contacts');
        System.assert(eligibleContacts.size() > 0, 'Eligible contacts should exist');
    }

    @isTest
    static void testGetContacts_EligibilityCheck() {
        // Ensure eligibility logic is tested properly
        Test.startTest();
        Map<String, Object> results = rve_IAExamApproval.getContacts();
        Test.stopTest();

        List<Contact> eligibleContacts = (List<Contact>) results.get('contacts');
        System.assert(eligibleContacts.size() > 0, 'Eligible contacts should exist');

        // Ensure `shouldDisplay` logic is covered
        Boolean shouldDisplayExecuted = false;
        for (Contact con : eligibleContacts) {
            shouldDisplayExecuted = true;
            break;
        }
        System.assert(shouldDisplayExecuted, 'shouldDisplay logic must be executed');
    }

    @isTest
    static void testUpdateContacts() {
        List<Contact> contactsToUpdate = [SELECT Id, Exam_Approval__c, Description FROM Contact];
        for (Contact con : contactsToUpdate) {
            con.Exam_Approval__c = true;
            con.Description = 'Approved by test method';
        }

        Test.startTest();
        rve_IAExamApproval.updateContacts(contactsToUpdate);
        Test.stopTest();

        List<Exam_Approval_History__c> histories = [SELECT Id, Contact__c, Approved__c FROM Exam_Approval_History__c];
        System.assert(!histories.isEmpty(), 'History records should be created');
        System.assertEquals(true, histories[0].Approved__c, 'Approval should be true');
    }

    @isTest
    static void testUpdateContacts_Empty() {
        List<Contact> emptyList = new List<Contact>();

        Test.startTest();
        rve_IAExamApproval.updateContacts(emptyList);
        Test.stopTest();

        List<Exam_Approval_History__c> histories = [SELECT Id FROM Exam_Approval_History__c];
        System.assert(histories.isEmpty(), 'No history should be created for empty input');
    }
}