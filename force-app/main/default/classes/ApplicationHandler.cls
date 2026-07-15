public class ApplicationHandler {
    public static void handleBeforeUpdate(List<hed__Application__c> newApplications, Map<Id, hed__Application__c> oldMap) {
        for (hed__Application__c app : newApplications) {
            // Check if Provisional_Admission_Fee_Paid__c field changed
            if (app.Provisional_Admission_Fee_Paid__c != oldMap.get(app.Id).Provisional_Admission_Fee_Paid__c) {
                // If Provisional_Admission_Fee_Paid__c changed to true, set PAF_Paid_Date__c to today's date
                if (app.Provisional_Admission_Fee_Paid__c) {
                    app.PAF_Paid_Date__c = Date.today();
                } else {
                    // If Provisional_Admission_Fee_Paid__c changed to false, set PAF_Paid_Date__c to null (blank)
                    app.PAF_Paid_Date__c = null;
                }
            }
        }
    }
}


/*public class ApplicationHandler {
    public static void handleBeforeUpdate(List<hed__Application__c> newApplications, Map<Id, hed__Application__c> oldMap) {
        for (hed__Application__c app : newApplications) {
            // Check if Provisional_Admission_Fee_Paid__c field changed to true
            if (app.Provisional_Admission_Fee_Paid__c && !oldMap.get(app.Id).Provisional_Admission_Fee_Paid__c) {
                app.PAF_Paid_Date__c = Date.today();
            }
        }
    }
}*/