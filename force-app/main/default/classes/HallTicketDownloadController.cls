public with sharing class HallTicketDownloadController {
    
    @AuraEnabled
    public static List<String> getUniversityList(String nameStr){
        List<String> universityList =  new List<String>();
        Map<String, String> defult = new Map<String, String>();
        for(Account acc:[select id, Name from account where recordtype.developername = 'Educational_Institution' and name =:nameStr limit 1 ]){
            universityList.add( acc.Id+'##'+acc.Name);
        }
        if(FeatureManagement.checkPermission('Cancel_Schedule_Freeze_School')) {
            defult =  TT_CancelScheduleController.getDefaultValues();            
            universityList.add(defult.get('faculty'));
            universityList.add(defult.get('school'));
        }
        return universityList;
    }
    @AuraEnabled
    public static List<String> getAccountBasedOnParentIdList(Id parentId){
        List<String> facultyList =  new List<String>();
        for(Account acc:[select id, Name from account where parentId =:parentId]){
            facultyList.add(acc.Id+'##'+acc.Name);
        }
        return facultyList;
    }
    @AuraEnabled
    public static List<String> getProgramBatchList(Id programId){
        List<String> programBatchList =  new List<String>();
        for(hed__Program_Plan__c pp:[select id, Name from hed__Program_Plan__c where hed__Account__c =:programId AND Active__c = TRUE]){
            programBatchList.add(pp.Id+'##'+pp.Name);
        }
        return programBatchList;
    }
    
    @AuraEnabled
    public static List<String> getSemesterList(Id programBId){
        List<String> semesterList =  new List<String>();
        for(hed__Term__c sem:[select id, Name from hed__Term__c where Program_Batch__c =:programBId AND Active__c = TRUE]){
            semesterList.add(sem.Id+'##'+sem.Name);
        }
        return semesterList;
    }
    
    @AuraEnabled
    public static Boolean validateExamNotification(String semesterId, String iaType) {
        try {
            List<Rve_Exam_Notification__c> examNotifications;
            
            if (iaType == 'Semester Exam') {
                examNotifications = [SELECT Id FROM Rve_Exam_Notification__c 
                                     WHERE RecordType.DeveloperName = 'hed_Semester_Notification'
                                     AND Rve_Publish__c = true 
                                     AND rve_Active__c = true
                                     AND Rve_Semester__c = :semesterId
                                     LIMIT 1];
            } else { // IA 1 or IA 2
                examNotifications = [SELECT Id FROM Rve_Exam_Notification__c 
                                     WHERE RecordType.DeveloperName = 'hed_IA_Notification'
                                     AND Rve_Publish__c = true 
                                     AND hed_IA_Type__c = :iaType
                                     AND rve_Active__c = true
                                     AND Rve_Semester__c = :semesterId
                                     LIMIT 1];
            }
            
            return !examNotifications.isEmpty();
        } catch (Exception e) {
            throw new AuraHandledException('Validation error: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Id> saveBulkPdfAsFile(String semesterId,String eligibility,List<Id> studentIds, Integer batchSize) {
        List<Id> contentVersionIds = new List<Id>();
        
       hed__Term__c sem=[select id, Name from hed__Term__c where id =:semesterId AND Active__c = TRUE];
        
        Integer size = 20; // default
        if (batchSize != null && batchSize >= 5 && batchSize <= 100) {
            size = batchSize;
        }

        Integer total = studentIds.size();
        Integer batches = (total + size - 1) / size;

        try {
            for (Integer i = 0; i < batches; i++) {
                Integer start = i * size;
                Integer endIdx = Math.min(start + size, total);
                List<Id> batch = new List<Id>();
                
                for (Integer j = start; j < endIdx; j++) {
                    batch.add(studentIds[j]);
                }

                Blob pdfBlob = generatePdfForBatch(semesterId, eligibility, batch);

                ContentVersion cv = new ContentVersion();
                cv.Title = 'HallTickets_' + eligibility +'_'+ sem.Name + '_Part' + (i + 1) + '_of_' + batches;
                cv.PathOnClient = cv.Title + '.pdf';
                cv.VersionData = pdfBlob;
                cv.IsMajorVersion = true;
                insert cv;

                contentVersionIds.add(cv.Id);
            }

            shareWithCurrentUser(contentVersionIds);
            return contentVersionIds;

        } catch (Exception e) {
            throw new AuraHandledException('PDF Generation Failed: ' + e.getMessage() + ' | Line: ' + e.getLineNumber());
        }
    }

    // Generate PDF for one batch
    private static Blob generatePdfForBatch(String semesterId, String eligibility, List<Id> batchIds) {
        PageReference pdfPage = Page.HallTicketPDFBulk;
        pdfPage.getParameters().put('semesterId', semesterId);
        pdfPage.getParameters().put('eligibility', eligibility);
        pdfPage.getParameters().put('selectedIds', String.join(batchIds, ','));
        pdfPage.setRedirect(false);

        if (Test.isRunningTest()) {
            return Blob.valueOf('Unit Test PDF - ' + batchIds.size() + ' students');
        }
        return pdfPage.getContentAsPDF();
    }

    // Share with current user
    private static void shareWithCurrentUser(List<Id> cvIds) {
        Id userId = UserInfo.getUserId();
        List<ContentVersion> cvs = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvIds];
        Set<Id> docIds = new Set<Id>();
        for (ContentVersion cv : cvs) {
            docIds.add(cv.ContentDocumentId);
        }

        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        for (Id docId : docIds) {
            linksToInsert.add(new ContentDocumentLink(
                ContentDocumentId = docId,
                LinkedEntityId = userId,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ));
        }
        if (!linksToInsert.isEmpty()) {
            try { insert linksToInsert; } catch (Exception e) { /* ignore dupes */ }
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<StudentWrapper> getEligibleStudents(String semesterId, String eligibility) {
        List<StudentWrapper> result = new List<StudentWrapper>();
        
        for (Contact c : [SELECT Id, Name, SRN_Number__c
                          FROM Contact
                          WHERE Active_Semester__c = :semesterId
                          AND Student_Status__c = 'Pursuing'
                          AND Checking_Eligibility_for_Exam__c = :eligibility
                          AND SRN_Number__c != null
                          ORDER BY Name]) {
                              
                              result.add(new StudentWrapper(c.Id, c.Name, c.SRN_Number__c));
                          }
        return result;
    }  
    public class StudentWrapper {
        @AuraEnabled public Id    Id            {get;set;}
        @AuraEnabled public String Name         {get;set;}
        @AuraEnabled public String SRN {get;set;}
        
        public StudentWrapper(Id id, String name, String srn) {
            this.Id = id;
            this.Name = name;
            this.SRN = srn;
        }
    }
}