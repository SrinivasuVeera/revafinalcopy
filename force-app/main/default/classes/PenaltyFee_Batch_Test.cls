@isTest
public class PenaltyFee_Batch_Test {

    // Utility method to create a test account
    private static Account createTestAccount() {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account', HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        insert objAcc;
        return objAcc;
    }

    // Utility method to create a test program plan
    private static hed__Program_Plan__c createTestProgramPlan() {
        hed__Program_Plan__c objProgPlan = FEE_TestDataFactory.createProgramPlan('B.Tech. in Civil Engineering-(2023-2027)');
        objProgPlan.hed__Start_Date__c = Date.today().addDays(-60);
        objProgPlan.hed__End_Date__c = Date.today().addDays(1);
        insert objProgPlan;
        return objProgPlan;
    }

    // Utility method to create a test term
    private static hed__Term__c createTestTerm(Account acc, hed__Program_Plan__c progPlan, Integer startDateOffset, Integer termNumber) {
        String termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = FEE_TestDataFactory.createTerm('test term', acc.Id, termRtId);
        objTerm.Program_Batch__c = progPlan.Id;
        objTerm.hed__Start_Date__c = Date.today().addDays(startDateOffset);
        objTerm.hed__End_Date__c = Date.today().addDays(startDateOffset + 140); // Assuming a term lasts about 140 days
        objTerm.Term_Number__c = termNumber;
        insert objTerm;
        return objTerm;
    }

    // Utility method to create a test contact
    private static Contact createTestContact(Account acc, hed__Term__c term) {
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test1', acc.Id);
        objCon.MobilePhone = '9090909090';
        objCon.Aadhar_Card_Number__c = '098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.Student_Status__c = 'Pursuing';
        objCon.AccountId = acc.Id;
        objCon.Admission_Mode__c = 'ComedK';
        objCon.Enrollment_Type__c = 'Regular Entry';
        objCon.Quota__c = 'Management Quota';
        objCon.Active_Semester__c = term.Id;
        objCon.Caste_Category__c = 'OBC';
        objCon.Application_Number__c = 'test12';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c = 'test12@reva.edu.in';
        objCon.Nationality__c = 'Indian';
        insert objCon;
        return objCon;
    }

    // Utility method to create a test fee payment criteria
    private static Fee_Payment_Criteria__c createTestFeeCriteria() {
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee', 'Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c = 'MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c = 'MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c = 'MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c = 'MIDR4454545';
        insert objFeeCriteria;
        return objFeeCriteria;
    }

    // Utility method to create a test program enrollment
    private static hed__Program_Enrollment__c createTestProgramEnrollment(Contact con, hed__Program_Plan__c progPlan) {
        hed__Program_Enrollment__c objProgEnroll = FEE_TestDataFactory.createProgramEnrollment(con.Id, progPlan.Id);
        objProgEnroll.hed__Contact__c = con.Id;
        objProgEnroll.hed__Start_Date__c = Date.today().addDays(-60);
        objProgEnroll.hed__End_Date__c = Date.today().addDays(1);
        objProgEnroll.hed__Program_Plan__c = progPlan.Id;
        insert objProgEnroll;
        return objProgEnroll;
    }

    // Utility method to create a test student fee
    private static Student_Fee__c createTestStudentFee(Fee_Payment_Criteria__c feeCriteria, Contact con, String feeType, Decimal amount, Integer dueDateOffset, String feeYear) {
        Student_Fee__c stuFee = FEE_TestDataFactory.createStudentFee(feeCriteria.Id, con.Id, feeType);
        stuFee.Name = 'Test Fee ' + feeType;
        stuFee.Actual_Program_Fee__c = amount;
        stuFee.Amount__c = amount;
        stuFee.Due_Date__c = Date.today().addDays(dueDateOffset);
        stuFee.Session__c = feeYear;
        stuFee.Fee_Year__c = feeYear;
        insert stuFee;
        return stuFee;
    }

    @isTest
    public static void testDueDateMethod() {
        Account acc = createTestAccount();
        hed__Program_Plan__c progPlan = createTestProgramPlan();
        hed__Term__c term = createTestTerm(acc, progPlan, -40, 3);
        hed__Term__c term1 = createTestTerm(acc, progPlan, -40, 5);
        Contact con = createTestContact(acc, term1);
        Fee_Payment_Criteria__c feeCriteria = createTestFeeCriteria();
        createTestProgramEnrollment(con, progPlan);

        Student_Fee__c fee1 = createTestStudentFee(feeCriteria, con, 'Tuition Fee', 50000, -35, '2nd Year');
        fee1.Amount_Pending__c = 40000;
        fee1.Amount_Paid__c = 10000;
        fee1.Number_of_Installments__c = 3;
        fee1.Paid_Installments__c = 1;
        update fee1;

        Test.startTest();
        PenaltyFee_Batch btch = new PenaltyFee_Batch();
        Database.executeBatch(btch);
        Test.stopTest();
    }

    @isTest
    public static void testDueDateMethod1() {
        Account acc = createTestAccount();
        hed__Program_Plan__c progPlan = createTestProgramPlan();
        Fee_Payment_Criteria__c feeCriteria = createTestFeeCriteria();

        hed__Term__c term = createTestTerm(acc, progPlan, -40, 3);
        hed__Term__c term1 = createTestTerm(acc, progPlan, -40, 5);
        //createTestTerm(acc, progPlan, -40, 3);
        createTestTerm(acc, progPlan, -40, 5);
        createTestTerm(acc, progPlan, -40, 7);
        createTestTerm(acc, progPlan, -40, 9);

        Contact con = createTestContact(acc, term1);
        createTestProgramEnrollment(con, progPlan);

        //createTestStudentFee(feeCriteria, con, 'Penalty Fee', 0, -35, '1st Year');
        createTestStudentFee(feeCriteria, con, 'Tuition Fee', 5000, -35, '2nd Year');
        createTestStudentFee(feeCriteria, con, 'Tuition Fee', 7000, -50, '3rd Year');
        createTestStudentFee(feeCriteria, con, 'Tuition Fee', 9000, -75, '4th Year');
        createTestStudentFee(feeCriteria, con, 'Tuition Fee', 500, -35, '5th Year');
        //createTestStudentFee(feeCriteria, con, 'Tuition Fee', 600, -35, '1st Year');

        Test.startTest();
        PenaltyFee_Batch btch = new PenaltyFee_Batch();
        Database.executeBatch(btch);
        Test.stopTest();
    }

    @isTest
    public static void testBatchExecutionFor46To60Days() {
        Account acc = createTestAccount();
        hed__Program_Plan__c progPlan = createTestProgramPlan();
        hed__Term__c term = createTestTerm(acc, progPlan, -75, 3);
        hed__Term__c term1 = createTestTerm(acc, progPlan, -40, 5);
        Contact con = createTestContact(acc, term);
        Fee_Payment_Criteria__c feeCriteria = createTestFeeCriteria();
        createTestProgramEnrollment(con, progPlan);

        Student_Fee__c stuFee = createTestStudentFee(feeCriteria, con, 'Tuition Fee', 3000, -72, '2nd Year');
        Student_Fee__c stuFee1 = createTestStudentFee(feeCriteria, con, 'Penalty Fee', 3000, -72, '2nd Year');

        Test.startTest();
        PenaltyFee_Batch batch = new PenaltyFee_Batch();
        Database.executeBatch(batch);
        Test.stopTest();

        stuFee = [SELECT Amount_Pending__c FROM Student_Fee__c WHERE Id = :stuFee.Id];
        System.assertEquals(3000, stuFee.Amount_Pending__c, 'Amount Pending should be updated correctly for 46-60 days scenario');
    }

    @isTest
    public static void testBatchExecutionForGreaterThan60Days() {
        Account acc = createTestAccount();
        hed__Program_Plan__c progPlan = createTestProgramPlan();
        hed__Term__c term = createTestTerm(acc, progPlan, -65, 3);
        hed__Term__c term1 = createTestTerm(acc, progPlan, -40, 5);
        Contact con = createTestContact(acc, term);
        Fee_Payment_Criteria__c feeCriteria = createTestFeeCriteria();
        createTestProgramEnrollment(con, progPlan);

        Student_Fee__c stuFee = createTestStudentFee(feeCriteria, con, 'Tuition Fee', 10000, -61, '2nd Year');
        //Student_Fee__c stuFee1 = createTestStudentFee(feeCriteria, con, 'Penalty Fee', 1500, -61, '2nd Year');

        Test.startTest();
        PenaltyFee_Batch batch = new PenaltyFee_Batch();
        Database.executeBatch(batch);
        Test.stopTest();

        stuFee = [SELECT Amount_Pending__c FROM Student_Fee__c WHERE Id = :stuFee.Id];
        System.assertEquals(10000, stuFee.Amount_Pending__c, 'Amount Pending should be updated correctly for greater than 60 days scenario');
    }
     @isTest
    public static void testElseBatchExecutionForGreaterThan60Days() {
        Account acc = createTestAccount();
        hed__Program_Plan__c progPlan = createTestProgramPlan();
        hed__Term__c term = createTestTerm(acc, progPlan, -65, 3);
        hed__Term__c term1 = createTestTerm(acc, progPlan, -40, 5);
        Contact con = createTestContact(acc, term);
        Fee_Payment_Criteria__c feeCriteria = createTestFeeCriteria();
        createTestProgramEnrollment(con, progPlan);

        Student_Fee__c stuFee = createTestStudentFee(feeCriteria, con, 'Tuition Fee', 10000, -61, '2nd Year');
        Student_Fee__c stuFee1 = createTestStudentFee(feeCriteria, con, 'Penalty Fee', 1500, -61, '2nd Year');

        Test.startTest();
        PenaltyFee_Batch batch = new PenaltyFee_Batch();
        Database.executeBatch(batch);
        Test.stopTest();

        stuFee = [SELECT Amount_Pending__c FROM Student_Fee__c WHERE Id = :stuFee.Id];
        System.assertEquals(10000, stuFee.Amount_Pending__c, 'Amount Pending should be updated correctly for greater than 60 days scenario');
    }
     @isTest
    public static void testBatchExecutionForGreaterThan100Days() {
        Account acc = createTestAccount();
        hed__Program_Plan__c progPlan = createTestProgramPlan();
        hed__Term__c term = createTestTerm(acc, progPlan, -101, 3);
        hed__Term__c term1 = createTestTerm(acc, progPlan, -40, 5);
        Contact con = createTestContact(acc, term);
        Fee_Payment_Criteria__c feeCriteria = createTestFeeCriteria();
        createTestProgramEnrollment(con, progPlan);

        Student_Fee__c stuFee = createTestStudentFee(feeCriteria, con, 'Tuition Fee', 10000, -101, '2nd Year');

        Test.startTest();
        PenaltyFee_Batch batch = new PenaltyFee_Batch();
        Database.executeBatch(batch);
        Test.stopTest();

        stuFee = [SELECT Amount_Pending__c FROM Student_Fee__c WHERE Id = :stuFee.Id];
        System.assertEquals(10000, stuFee.Amount_Pending__c, 'Amount Pending should be updated correctly for greater than 60 days scenario');
    }

    @isTest
    public static void testCreateStudentFeesForMultipleYears() {
        Account acc = createTestAccount();
        hed__Program_Plan__c progPlan = createTestProgramPlan();
        hed__Term__c term = createTestTerm(acc, progPlan, -40, 3);
		hed__Term__c term1 = createTestTerm(acc, progPlan, -40, 5);        
        Contact con = createTestContact(acc, term);
        Fee_Payment_Criteria__c feeCriteria = createTestFeeCriteria();
        createTestProgramEnrollment(con, progPlan);

        createTestStudentFee(feeCriteria, con, 'Tuition Fee', 50000, -35, '2nd Year');
        createTestStudentFee(feeCriteria, con, 'Tuition Fee', 55000, -35, '3rd Year');
        createTestStudentFee(feeCriteria, con, 'Tuition Fee', 60000, -35, '4th Year');
        createTestStudentFee(feeCriteria, con, 'Tuition Fee', 65000, -35, '5th Year');

        Test.startTest();
        PenaltyFee_Batch btch = new PenaltyFee_Batch();
        Database.executeBatch(btch);
        Test.stopTest();
    }
}