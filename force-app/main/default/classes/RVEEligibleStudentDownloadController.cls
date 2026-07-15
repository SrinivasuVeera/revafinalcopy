public with sharing class RVEEligibleStudentDownloadController {
    
    public class OptionWrapper {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        
        public OptionWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    public String schoolId { get; set; }
    public String batchId { get; set; }
    public String semesterId { get; set; }
    public String eligibility { get; set; }
    public String examType { get; set;}
    
    public List<Contact> students { get; set; }
    public String schoolName { get; set; }
    public String batchName { get; set; }
    public String semesterName { get; set; }
    public String examEligible { get; set; }
    
    Public RVEEligibleStudentDownloadController(){
        schoolId = ApexPages.currentPage().getParameters().get('schoolId');
        batchId = ApexPages.currentPage().getParameters().get('batchId');
        semesterId = ApexPages.currentPage().getParameters().get('semesterId');
        eligibility = ApexPages.currentPage().getParameters().get('eligibility');
        examType = ApexPages.currentPage().getParameters().get('examType');
        // Get filtered students by calling your existing method
        If(schoolId!=NULL && batchId !=NULL && semesterId != NULL && eligibility != NULL){
            students = RVEEligibleStudentDownloadController.getFilteredStudents(schoolId, batchId, semesterId, eligibility,examType);
            schoolName = students[0].School__r.Name;
            batchName = students[0].Program_Batch__r.Name;
            semesterName = students[0].Active_Semester__r.Name;
            examEligible = students[0].Checking_Eligibility_for_Exam__c;
            
        }
    }
    // Get schools where the user is School Head or Vertical Head
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getUserSchools() {
        Id userId = UserInfo.getUserId();
        List<OptionWrapper> schoolOptions = new List<OptionWrapper>();
        
        for (Account acc : [
            SELECT Id, Name
            FROM Account
            WHERE School_Head__c = :userId OR Examination_Vertical_Head__c = :userId
        ]) {
            schoolOptions.add(new OptionWrapper(acc.Id, acc.Name));
        }
        
        return schoolOptions;
    }
    
    // Get Program Batches based on selected School (school Id = ParentId of Account)
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getProgramBatches(Id schoolId) {
        List<OptionWrapper> batchOptions = new List<OptionWrapper>();
        
        for (hed__Program_Plan__c batch : [
            SELECT Id, Name
            FROM hed__Program_Plan__c
            WHERE hed__Account__r.ParentId = :schoolId
        ]) {
            batchOptions.add(new OptionWrapper(batch.Id, batch.Name));
        }
        
        return batchOptions;
    }
    
    // Get Semesters based on selected Program Batch
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getSemesters(Id programBatchId) {
        List<OptionWrapper> semesterOptions = new List<OptionWrapper>();
        
        for (hed__Term__c term : [
            SELECT Id, Name
            FROM hed__Term__c
            WHERE Program_Batch__c = :programBatchId
        ]) {
            semesterOptions.add(new OptionWrapper(term.Id, term.Name));
        }
        
        return semesterOptions;
    }
    
    // Get Students
    
    @AuraEnabled
    public static List<Contact> getFilteredStudents(Id schoolId, Id programBatchId, Id semesterId, String eligibility, String examType) {
        System.debug('--- Method getFilteredStudents Called ---');
        System.debug('Input Params => SchoolId: ' + schoolId + ', BatchId: ' + programBatchId + ', SemesterId: ' + semesterId + ', Eligibility: ' + eligibility + ', ExamType: ' + examType);
        
        Set<Id> ineligibleIds = new Set<Id>();
        Set<Id> approvedByDirectorIds = new Set<Id>();
        
        hed__Term__c  termRecord = [SELECT Id,Name,Active__c from hed__Term__c where Id=:semesterId ];
        List<Contact> students = new List<Contact>();
        
        if(termRecord.Active__c==TRUE){
            if (eligibility == 'Ineligible') {
               // if (!ineligibleIds.isEmpty() ||ineligibleIds!=NULL) {
                    students = [
                        SELECT Id, Name, Email, Exam_Approval__c, School__r.Name, Active_Semester__r.Name,Program_Batch__r.Name,SRN_Number__c,MobilePhone,
                        Checking_Eligibility_for_Exam__c,Total_average_current_sem_attendance__c,Description,
                        (SELECT Id, Amount_Pending__c FROM Student_Fees__r WHERE Due_Date__c <= TODAY AND Amount_Pending__c > 0)
                        FROM Contact
                        WHERE Checking_Eligibility_for_Exam__c='Ineligible'
                        AND School__c = :schoolId
                        AND Program_Batch__c = :programBatchId
                        AND Active_Semester__c = :semesterId
                    ];
                } else if (eligibility == 'Approved by School Director') {
                   
                        students = [
                            SELECT Id, Name, Email, Exam_Approval__c, School__r.Name, Active_Semester__r.Name,Program_Batch__r.Name,SRN_Number__c,MobilePhone,
                            Checking_Eligibility_for_Exam__c,Total_average_current_sem_attendance__c,Description,
                            (SELECT Id, Amount_Pending__c FROM Student_Fees__r WHERE Due_Date__c <= TODAY AND Amount_Pending__c > 0)
                            FROM Contact
                            WHERE Checking_Eligibility_for_Exam__c='Eligible' AND Exam_Approval__c=TRUE
                            AND School__c = :schoolId
                            AND Program_Batch__c = :programBatchId
                            AND Active_Semester__c = :semesterId
                        ];
                   
                } else if (eligibility == 'Eligible') {
                        students = [
                            SELECT Id, Name, Email, Exam_Approval__c, School__r.Name, Active_Semester__r.Name,Program_Batch__r.Name,SRN_Number__c,MobilePhone,
                            Checking_Eligibility_for_Exam__c,Total_average_current_sem_attendance__c,Description,
                            (SELECT Id, Amount_Pending__c FROM Student_Fees__r WHERE Due_Date__c <= TODAY AND Amount_Pending__c > 0)
                            FROM Contact
                            WHERE School__c = :schoolId
                            // AND Active_Semester__r.Active__c=TRUE// new,ay added
                            AND Checking_Eligibility_for_Exam__c = 'Eligible'//newly added
                            AND Program_Batch__c = :programBatchId
                            AND Active_Semester__c = :semesterId
                            AND Exam_Approval__c =false
                        ];
                    } 
                }
            
        
        else{
            
            List<Exam_Approval_History__c> approvalHistoryRecords = [
                SELECT Contact__c, Approved__c, Approved_By__r.Profile.Name
                FROM Exam_Approval_History__c
                WHERE Semester__c = :semesterId
                AND Exam_Type__c = :examType];
            
            System.debug('Fetched Exam_Approval_History__c records: ' + approvalHistoryRecords);
            
            
            If(!approvalHistoryRecords.isEmpty() || approvalHistoryRecords!=NULL){
                for (Exam_Approval_History__c history : approvalHistoryRecords) {
                    if (history.Approved__c && history.Approved_By__r.Profile.Name == 'School Director') {
                        approvedByDirectorIds.add(history.Contact__c);
                    } else if (!history.Approved__c) {
                        ineligibleIds.add(history.Contact__c);
                    }
                }
                System.debug('Ineligible Contact Ids: ' + ineligibleIds);
                System.debug('ApprovedByDirector Contact Ids: ' + approvedByDirectorIds);
            }
            
            // Final query filter
            //List<Contact> students = new List<Contact>();
            
            if (eligibility == 'Ineligible') {
                if (!ineligibleIds.isEmpty() ||ineligibleIds!=NULL) {
                    students = [
                        SELECT Id, Name, Email, Exam_Approval__c, School__r.Name, Active_Semester__r.Name,Program_Batch__r.Name,SRN_Number__c,MobilePhone,
                        Checking_Eligibility_for_Exam__c,Total_average_current_sem_attendance__c,Description,
                        (SELECT Id, Amount_Pending__c FROM Student_Fees__r WHERE Due_Date__c <= TODAY AND Amount_Pending__c > 0)
                        FROM Contact
                        WHERE Id IN :ineligibleIds
                        AND School__c = :schoolId
                        AND Program_Batch__c = :programBatchId
                        AND Active_Semester__c = :semesterId
                    ];
                } 
            } else if (eligibility == 'Approved by School Director') {
                if (!approvedByDirectorIds.isEmpty()) {
                    students = [
                        SELECT Id, Name, Email, Exam_Approval__c, School__r.Name, Active_Semester__r.Name,Program_Batch__r.Name,SRN_Number__c,MobilePhone,
                        Checking_Eligibility_for_Exam__c,Total_average_current_sem_attendance__c,Description,
                        (SELECT Id, Amount_Pending__c FROM Student_Fees__r WHERE Due_Date__c <= TODAY AND Amount_Pending__c > 0)
                        FROM Contact
                        WHERE Id IN :approvedByDirectorIds
                        AND School__c = :schoolId
                        AND Program_Batch__c = :programBatchId
                        AND Active_Semester__c = :semesterId
                    ];
                }
            } else if (eligibility == 'Eligible') {
                Set<Id> allExcluded = new Set<Id>();
                allExcluded.addAll(ineligibleIds);
                allExcluded.addAll(approvedByDirectorIds);
                System.debug('All excluded Contact Ids: ' + allExcluded);
                //if (!allExcluded.isEmpty()) {
                if (allExcluded != Null){
                    students = [
                        SELECT Id, Name, Email, Exam_Approval__c, School__r.Name, Active_Semester__r.Name,Program_Batch__r.Name,SRN_Number__c,MobilePhone,
                        Checking_Eligibility_for_Exam__c,Total_average_current_sem_attendance__c,Description,
                        (SELECT Id, Amount_Pending__c FROM Student_Fees__r WHERE Due_Date__c <= TODAY AND Amount_Pending__c > 0)
                        FROM Contact
                        WHERE School__c = :schoolId
                        // AND Active_Semester__r.Active__c=TRUE// new,ay added
                        AND Checking_Eligibility_for_Exam__c = 'Eligible'//newly added
                        AND Program_Batch__c = :programBatchId
                        AND Active_Semester__c = :semesterId
                        AND Id NOT IN :allExcluded
                    ];
                } 
            }
        }
        System.debug('Final Filtered Students: ' + students);
        return students;
    }
    
    
}