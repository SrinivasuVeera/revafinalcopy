public class IAMarksAcknowledgementBySystemBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date targetDate = System.today().addDays(-Integer.valueOf(System.Label.IA_Marks_Acknowledgement_Days));

        return Database.getQueryLocator([
            SELECT Id, IA_Type__c, Semester__r.IA_2_Result_Date__c, Semester__c 
            FROM IA_Marks__c 
            WHERE IA_Type__c = 'IA2' 
            AND Semester__r.IA_2_Result_Date__c = :targetDate 
            AND Acknowledged__c = false
            AND Semester__r.Active__c = true
        ]);
    }

    public void execute(Database.BatchableContext BC, List<IA_Marks__c> iaMarksList) {
        List<IA_Marks__c> updatedMarks = new List<IA_Marks__c>();
        for (IA_Marks__c iaMark : iaMarksList) {
            IA_Marks__c IAmarks = new IA_Marks__c(
                Id = iaMark.Id,
                Acknowledged__c = true,
                Acknowledgment_Response__c = 'Acknowledged by System'
            );
            updatedMarks.add(IAmarks);
        }
        if (!updatedMarks.isEmpty()) {
            update updatedMarks;
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('IA Marks Acknowledgement Batch Completed.');
    }
}