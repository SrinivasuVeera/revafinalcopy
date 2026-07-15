public class RveDisplayPaidRVandPCResultsRecordsToCOE {
    public class ResultWrapper {
        @AuraEnabled public Id resultId;
        @AuraEnabled public String courseName;
        @AuraEnabled public String courseId;
        @AuraEnabled public Decimal maxMarks;
        @AuraEnabled public Decimal securedMarks;
        @AuraEnabled public String result;
        @AuraEnabled public String studentName;
        @AuraEnabled public String srnNumber;
        @AuraEnabled public String courseCode;
        @AuraEnabled public String programBatch;
        @AuraEnabled public String semester;
        @AuraEnabled public Boolean appliedForPhotocopy;
        @AuraEnabled public Boolean appliedForRevaluation;
        @AuraEnabled public Boolean feePaidForPhotocopy;
        @AuraEnabled public Boolean showUpload;
        @AuraEnabled public Boolean showRemove;

    }

    
    @AuraEnabled(cacheable=true)
public static List<ResultWrapper> fetchResultRecordsForCOE() {
    List<ResultWrapper> wrapList = new List<ResultWrapper>();

    List<hed__Term_Grade__c> resultList = [
        SELECT Id,
               Course__r.Name,
               Course__r.hed__Course_ID__c,
               Course__r.Total_Maximum_Marks_IA_External__c,
               Total_Secured_Marks_Course__c,
               hed__Result__c,
               hed__Contact__r.Name,
               SRN_Number__c,
               AppliedForPhotoCopy__c,
               AppliedForRevaluation__c,
               Fee_Paid_For_Photocopy__c,
               Fee_Paid_For_Revaluation__c,
               Photocopy_Uploaded__c,
               hed__Term__r.Name,
               hed__Term__r.Program_Batch__r.Name
        FROM hed__Term_Grade__c
        WHERE (AppliedForPhotoCopy__c = TRUE AND Fee_Paid_For_Photocopy__c = TRUE)
           OR (AppliedForRevaluation__c = TRUE AND Fee_Paid_For_Revaluation__c = TRUE)
        ORDER BY LastModifiedDate DESC
    ];

    for (hed__Term_Grade__c r : resultList) {
        ResultWrapper w = new ResultWrapper();
        w.resultId = r.Id;
        w.courseName = r.Course__r != null ? r.Course__r.Name : '';
        w.courseId = r.Course__r != null ? r.Course__r.hed__Course_ID__c : '';
        w.maxMarks = r.Course__r.Total_Maximum_Marks_IA_External__c;
        w.securedMarks = r.Total_Secured_Marks_Course__c;
        w.result = r.hed__Result__c;
        w.studentName = r.hed__Contact__r != null ? r.hed__Contact__r.Name : '';
        w.srnNumber = r.SRN_Number__c;
        w.courseCode = r.Course__r.hed__Course_ID__c;
        w.programBatch = (r.hed__Term__r != null && r.hed__Term__r.Program_Batch__r != null) ? r.hed__Term__r.Program_Batch__r.Name : '';
        w.semester = r.hed__Term__r != null ? r.hed__Term__r.Name : '';
        w.appliedForPhotocopy = r.AppliedForPhotoCopy__c;
        w.appliedForRevaluation = r.AppliedForRevaluation__c;
        w.feePaidForPhotocopy = r.Fee_Paid_For_Photocopy__c;

        // ✅ Upload is allowed ONLY for photocopy
        w.showUpload = r.AppliedForPhotoCopy__c == true &&
                       r.Fee_Paid_For_Photocopy__c == true &&
                       r.Photocopy_Uploaded__c == false;

        // ✅ Show preview/remove ONLY for uploaded photocopy
        w.showRemove = r.AppliedForPhotoCopy__c == true &&
                       r.Fee_Paid_For_Photocopy__c == true &&
                       r.Photocopy_Uploaded__c == true;

        wrapList.add(w);
    }

    return wrapList;
}

}