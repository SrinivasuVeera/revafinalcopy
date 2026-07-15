public class rve_update_Checking_inEligilble_contact {
    
    @InvocableMethod
    public static void updateInEligibility(List<List<String>> ActiveProgramBatchList) {
        List<Contact> listToUpdateinEligible = new List<Contact>();
        try {
            list<hed__Program_Plan__c> programplan =[ SELECT Id, Name 
                                                     FROM hed__Program_Plan__c 
                                                     WHERE Id IN :ActiveProgramBatchList[0]];
            
            // Collect all program IDs to use in a single query for ineligible students
            Set<Id> programIds = new Set<Id>();
            for (hed__Program_Plan__c program : programplan) {
                programIds.add(program.Id);
            }
            
            // Query ineligible students for all programs at once
            DataBase.executeBatch(new UpdateInEligibleStudentBatch(programIds));
        } catch (Exception e) {
            System.debug('An error occurred during update: ' + e.getMessage());
            throw new AuraHandledException('Failed to update eligibility: ' + e.getMessage());
        }
    }
    
       
}