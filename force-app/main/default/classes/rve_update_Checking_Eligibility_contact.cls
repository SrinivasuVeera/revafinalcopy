public class rve_update_Checking_Eligibility_contact {
    
    @InvocableMethod
    public static void updateEligibility(List<List<String>> ActiveProgramBatchList) {
        
        List<Contact> listToUpdateEligible = new List<Contact>();
        try{
            
            list<hed__Program_Plan__c> programplan =[ SELECT Id, Name 
                                                     FROM hed__Program_Plan__c 
                                                     WHERE Id IN :ActiveProgramBatchList[0]];
            system.debug('programplan are===>'+programplan);
            if(!programplan.isEmpty()){            
             // Collect all program IDs to use in a single query for ineligible students
            Set<Id> programIds = new Set<Id>();
            for (hed__Program_Plan__c program : programplan) {
                programIds.add(program.Id);
            }
            
            // Query ineligible students for all programs at once
            DataBase.executeBatch(new UpdateEligibleStudentBatch(programIds));
            } 
        }catch(Exception e){
            System.debug('An error occurred during update: ' + e.getMessage() + ' on line number: ' + e.getLineNumber());
            
        }
        
        
    }
}

/*public class rve_update_Checking_Eligibility_contact {

// Method to update the Checking_Eligibility_for_Exam__c field to 'Eligible'
@InvocableMethod
public static void updateEligibility(String ActiveProgramBatch) {
// Get eligible students
List<Contact> eligibleStudents = rveSeatingArrangementUpdated.getEligibleStudents(ActiveProgramBatch);
list<Contact> listtoupdateeligible = new list<Contact>();
// Update the Checking_Eligibility_for_Exam__c field for each eligible student
for (Contact student : eligibleStudents) {
student.Checking_Eligibility_for_Exam__c = 'Eligible';
listtoupdateeligible.add(student);
}

// Perform the update in the database
if (!listtoupdateeligible.isEmpty()) {
update listtoupdateeligible;

}
}
}*/