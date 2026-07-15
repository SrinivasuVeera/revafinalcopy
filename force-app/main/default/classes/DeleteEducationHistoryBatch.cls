global class DeleteEducationHistoryBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
     String query;

     global void setQuery(String queryString) {
        query = queryString;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<hed__Education_History__c> recordsToDelete = new List<hed__Education_History__c>();
        System.debug('Number of records in scope: ' + scope.size());
        for (hed__Education_History__c record : (List<hed__Education_History__c>)scope) {
            if (record.ContentDocumentLinks == null || record.ContentDocumentLinks.isEmpty()) {
                recordsToDelete.add(record);
            }
        }
         System.debug('Number of records to delete: ' + recordsToDelete.size());
        // Delete the records
        try {
            delete recordsToDelete;
            System.debug('Deleted ' + recordsToDelete.size() + ' records.');
        } catch (Exception e) {
            System.debug('Error deleting records: ' + e.getMessage());
            // Handle the exception (e.g., log it or send an email notification)
        }
    }
    
    global void finish(Database.BatchableContext BC) {
       
    }
}