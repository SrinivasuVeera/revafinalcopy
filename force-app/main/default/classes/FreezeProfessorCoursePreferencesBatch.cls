/**
 * @description This batch class is responsible for freezing professor course preferences
 *              for specific terms based on certain criteria. It implements the
 *              Database.Batchable and Database.Stateful interfaces to process large
 *              volumes of data and maintain state across batch transactions.
 *
 * @author Devender Jadala
 * @team Cloud odyssey
 * @createdDate 08/08/2025
 * @lastModifiedDate 08/08/2025
 * @lastModifiedBy  Devender Jadala
 */

public class FreezeProfessorCoursePreferencesBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Set<Id> termIds = new Set<Id>();

    /**
     * @description This is the constructor for the FreezeProfessorCoursePreferencesBatch class.
     * Initializes the batch with terms that meet the criteria for freezing professor preferences.
     *
     * @param termsToProcess List of new hed__Term__c records.

     */
    public FreezeProfessorCoursePreferencesBatch(List<hed__Term__c> termsToProcess) {
        for (hed__Term__c term : termsToProcess) {
            if (
                term != null && term.Allow_Professors_for_Preferences__c == false
            ) {
                termIds.add(term.Id);
            }
        }
    }

    /**
     * @description This method defines the query to fetch the records to be processed in the batch.
     * @param context The batch context provided by the system.
     * @return A Database.QueryLocator object containing the query results.
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        if (termIds.isEmpty()) {
            return Database.getQueryLocator([SELECT Id FROM Professor_Student_Course_Preference__c WHERE Id = NULL]);
        }

        return Database.getQueryLocator([
            SELECT Id, Professor_Preference__c
            FROM Professor_Student_Course_Preference__c
            WHERE Semester__c IN :termIds
            AND Semester__r.Allow_Professors_for_Preferences__c = false
            AND Course_Offering__c != null
            AND Preference__c != null
            AND Professor__c != null
            AND Semester__c != null
            AND Preference_No__c != null
            AND Professor_Preference__c = false
        ]);
    }

    /**
     * @description This method processes a batch of Professor_Student_Course_Preference__c records
     *              and updates their Professor_Preference__c field to true.
     * @param context The batch context provided by the system.
     * @param scope The list of Professor_Student_Course_Preference__c records to process.
     */
    public void execute(Database.BatchableContext context, List<Professor_Student_Course_Preference__c> scope) {
        List<Professor_Student_Course_Preference__c> toUpdate = new List<Professor_Student_Course_Preference__c>();

        for (Professor_Student_Course_Preference__c pref : scope) {

                pref.Professor_Preference__c = true;
                toUpdate.add(pref);
        }

        if (!toUpdate.isEmpty()) {
            try {
                update toUpdate;
            } catch (DmlException dmlEx) {
                // Handle DML exception (e.g., log the error)
                System.debug('DML Exception: ' + dmlEx.getMessage());
            }
        }
    }

    /**
     * @description This method is called after all batches are processed.
     *              It can be used to perform any final operations or cleanup.
     * @param context The batch context provided by the system.
     */
    public void finish(Database.BatchableContext context) {
        // Optional: Implement any post-batch operations if needed
        System.debug('Batch processing completed.');

    }
}