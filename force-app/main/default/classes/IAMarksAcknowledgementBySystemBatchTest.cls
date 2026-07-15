@isTest
public class IAMarksAcknowledgementBySystemBatchTest {

    private static void createTestData(Boolean acknowledgedFlag) {
        Integer offsetDays = Integer.valueOf(System.Label.IA_Marks_Acknowledgement_Days);
        Date today = System.today();
        Date targetResultDate = today.addDays(-offsetDays);

        // Create Account (Department)
        String acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account objAccount = new Account(
            Name = 'School of ECE',
            RecordTypeId = acaRecId,
            School_Head__c = UserInfo.getUserId()
        );
        insert objAccount;

        // Create Program Plan
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name = 'Test Batch');
        insert programBatch;

        // Create Term
        String termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId(); // Use correct dev name for rec type
        hed__Term__c objTerm = new hed__Term__c(
            Name = 'Test Term',
            RecordTypeId = termRtId,
            hed__Account__c = objAccount.Id,
            Program_Batch__c = programBatch.Id,
            hed__Start_Date__c = today.addDays(-5),
            hed__End_Date__c = today.addDays(5),
            IA_1_Start_date__c = today.addDays(-2),
            IA_1_End_date__c = today.addDays(2),
            IA_2_Result_Date__c = targetResultDate,
            Term_Number__c = 1
        );
        insert objTerm;

        // Create IA Marks
        IA_Marks__c iaMark = new IA_Marks__c(
            Name = 'Test IA2',
            IA_Type__c = 'IA2',
            Semester__c = objTerm.Id,
            Acknowledged__c = acknowledgedFlag
        );
        insert iaMark;
    }

    @isTest
    static void testBatchExecution() {
        // Create record that qualifies for batch
        createTestData(false);

        Test.startTest();
            Database.executeBatch(new IAMarksAcknowledgementBySystemBatch(), 200);
        Test.stopTest();

        // Verify update
        IA_Marks__c updated = [SELECT Acknowledged__c, Acknowledgment_Response__c FROM IA_Marks__c LIMIT 1];
        System.assertEquals(true, updated.Acknowledged__c, 'Acknowledged__c should be set to true');
        System.assertEquals('Acknowledged by System', updated.Acknowledgment_Response__c, 'Acknowledgment_Response__c should be set correctly');
    }
}