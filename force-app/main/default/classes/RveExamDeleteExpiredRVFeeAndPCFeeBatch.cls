global class RveExamDeleteExpiredRVFeeAndPCFeeBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date today = Date.today();
        
        // Fetch all expired RV and PC fee records
        return Database.getQueryLocator([
            SELECT Id, Fee_Type__c, Contact__c, Due_Date__c
            FROM Student_Fee__c
            WHERE Due_Date__c < :today
            AND Fee_Type__c IN ('RV Fee', 'PC Fee')
            AND Amount_Paid__c =0
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Student_Fee__c> feeRecords) {
        if (feeRecords.isEmpty()) return;
        
        Set<Id> feeIds = new Set<Id>();
        for (Student_Fee__c fee : feeRecords) {
            feeIds.add(fee.Id);
        }
        
        // Query hed__Term_Grade__c where any of the fee fields match these IDs
        List<hed__Term_Grade__c> termGradesToUpdate = [
            SELECT Id, AppliedForRevaluation__c, AppliedForPhotoCopy__c,
            Revaluation_Fee__c, Photocopy_Fee__c
            FROM hed__Term_Grade__c
            WHERE Revaluation_Fee__c IN :feeIds OR Photocopy_Fee__c IN :feeIds
        ];
        
        for (hed__Term_Grade__c tg : termGradesToUpdate) {
            if (tg.Revaluation_Fee__c != null && feeIds.contains(tg.Revaluation_Fee__c)) {
                tg.AppliedForRevaluation__c = false;
                tg.Revaluation_Fee__c = null;
            }
            if (tg.Photocopy_Fee__c != null && feeIds.contains(tg.Photocopy_Fee__c)) {
                tg.AppliedForPhotoCopy__c = false;
                tg.Photocopy_Fee__c = null;
            }
        }
        
        if (!termGradesToUpdate.isEmpty()) {
            update termGradesToUpdate;
        }
        
        // Delete the expired student fee records AFTER updating related term grades
        if (!feeRecords.isEmpty()) {
            delete feeRecords;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Expired RV/PC fee batch completed successfully.');
    }
}