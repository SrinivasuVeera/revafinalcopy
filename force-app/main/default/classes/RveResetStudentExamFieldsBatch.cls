public class RveResetStudentExamFieldsBatch implements Database.Batchable<SObject> {
    public static Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Date yesterday = Date.today().addDays(-1);
        
        return Database.getQueryLocator([
            SELECT Id,Name, Checking_Eligibility_for_Exam__c, Description, Exam_Approval__c,Date_of_Approval__c,Active_Semester__c,
            Active_Semester__r.RecordType.DeveloperName,RecordType.DeveloperName,RecordTypeId,Active_Semester__r.Name
            FROM Contact
            WHERE Active_Semester__r.RecordType.DeveloperName = 'Semester'
            AND (Active_Semester__r.Exam_End_Date__c = YESTERDAY OR Active_Semester__r.IA_1_End_date__c = YESTERDAY OR Active_Semester__r.IA_2_End_date__c= YESTERDAY)
            AND RecordTypeId = :studentRecordTypeId
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        Try{
            List<Exam_Approval_History__c> examApprovalHistoryList = new List<Exam_Approval_History__c>();
            
            for (Contact con : scope) {
                // Check condition to create Exam_Approval_History__c
                if (con.RecordTypeId == studentRecordTypeId &&
                    con.Checking_Eligibility_for_Exam__c == 'Ineligible' &&
                    con.Exam_Approval__c == false) {
                        
                        Exam_Approval_History__c history = new Exam_Approval_History__c();
                        history.Name = con.Name + ' - ' + con.Active_Semester__r.Name;// newly added by for name 23042025
                        history.Contact__c = con.Id;
                        history.Approved__c = false;
                        history.Semester__c = con.Active_Semester__c;
                        history.Approved_Date__c = Date.today().addDays(-1);
                        examApprovalHistoryList.add(history);
                    }
                //Reset Contact related Fields
                con.Checking_Eligibility_for_Exam__c = null;
                con.Date_of_Approval__c = null;
                con.Description = null;
                con.Exam_Approval__c = false;
            }
            
            // Insert history records if any
            if (!examApprovalHistoryList.isEmpty()) {
                insert examApprovalHistoryList;
            }
            // Update contact records and capture SaveResults
            if (!scope.isEmpty()) {
                List<Database.SaveResult> SR= Database.update(scope);
            } 
        }catch(exception e){
            system.debug('Exception-->'+e.getMessage());
            system.debug('Exception-->'+e.getLineNumber());
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
        // Optional: Add logging or notification logic here
        System.debug('ResetStudentExamFieldsBatch completed successfully.');
    }
}