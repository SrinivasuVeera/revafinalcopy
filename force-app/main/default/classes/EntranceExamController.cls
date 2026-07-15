public class EntranceExamController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getExamNameOptions() {
        Schema.DescribeFieldResult fieldResult = Entrance_Exam__c.National_level__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isActive()) {
                options.add(entry.getLabel());
            }
        }
        return options;
    }
    
   /* @AuraEnabled(cacheable=true)
    public static List<String> getStateExamNameOptions() {
        Schema.DescribeFieldResult fieldResult = Entrance_Exam__c.State_level__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isActive()) {
                options.add(entry.getLabel());
            }
        }
        return options;
    }*/

    @AuraEnabled(cacheable=true)
    public static List<String> getStateOptions() {
        Schema.DescribeFieldResult fieldResult = Entrance_Exam__c.State__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isActive()) {
                options.add(entry.getLabel());
            }
        }
        return options;
    }
    
        
    @AuraEnabled(cacheable=true)
    public static List<String> getAllotedCategoryOptions() {
        Schema.DescribeFieldResult fieldResult = Entrance_Exam__c.Allotted_Category__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isActive()) {
                options.add(entry.getLabel());
            }
        }
        return options;
    }
    
    @AuraEnabled
    public static void createEntranceExamRecord(List<ExamWrapper> exams) {
        
        Id userId = UserInfo.getUserId();
        System.Debug('applicantId:'+userId);
        hed__Application__c app= [SELECT id, Name FROM hed__Application__c WHERE hed__Applicant__c = :[SELECT ContactId FROM User WHERE Id = :userId].ContactId Limit 1];
        app.Entrance_Exam__c = true;
        update app;
        
        List<Entrance_Exam__c> recordsToInsert = new List<Entrance_Exam__c>();
        
        for (ExamWrapper exam : exams) {
            system.debug('state:'+exam.totalMarks);
            System.debug('exam.examType'+exam.examType);
            if(exam.examType != null ){
                 recordsToInsert.add(new Entrance_Exam__c(
                Application__c = app.id,
                Name  = exam.examName,
                Rank__c = exam.rank,
                Roll_No__c = exam.rollNo,
                Exam_Type__c = exam.examType,
                State__c = exam.state,
                Total_Marks__c = exam.totalMarks,
                Scored_Marks__c = exam.scoredMarks,
                Allotted_Category__c = exam.allotegCat
            ));
            }
        }
        
        // Insert all records in one DML operation
        insert recordsToInsert;
    }
    public class ExamWrapper {
        @AuraEnabled public String examName {get;set;}
        @AuraEnabled public String rank {get;set;}
        @AuraEnabled public String rollNo {get;set;}
        @AuraEnabled public String examType {get; set;}
        @AuraEnabled public String state {get; set;}
        @AuraEnabled public String totalMarks {get; set;}
        @AuraEnabled public String scoredMarks {get; set;}
        @AuraEnabled public String allotegCat {get; set;}
    }
    
    @AuraEnabled
    public static void updateEntranceExamField( Boolean entranceExamValue) {
        Id userId = UserInfo.getUserId();
        System.Debug('applicantId:'+userId);
        hed__Application__c app= [SELECT id, Name FROM hed__Application__c WHERE hed__Applicant__c = :[SELECT ContactId FROM User WHERE Id = :userId].ContactId Limit 1];
        
        if (String.isNotBlank(app.Id)) {
            app.Entrance_Exam__c = entranceExamValue;
            update app;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Boolean EntranceExamRecords() {
        Boolean checkbox = false;
        Id userId = UserInfo.getUserId();
        System.Debug('applicantId:' + userId);
        hed__Application__c app = [
            SELECT Id, Name, Entrance_Exam__c 
            FROM hed__Application__c 
            WHERE hed__Applicant__c = :[SELECT ContactId FROM User WHERE Id = :userId].ContactId 
            LIMIT 1
        ];
        if (app.Entrance_Exam__c == true) {
            checkbox = true;
        }
        return checkbox;
    }
    
    @AuraEnabled
    public static List<Entrance_Exam__c> getSavedEntranceExams(Id applicantId) {
        Id userId = UserInfo.getUserId();
        System.Debug('applicantId:' + userId);
        hed__Application__c app = [
            SELECT Id, Name, Entrance_Exam__c 
            FROM hed__Application__c 
            WHERE hed__Applicant__c = :[SELECT ContactId FROM User WHERE Id = :userId].ContactId 
            LIMIT 1
        ];
        return [SELECT Id, Exam_Type__c,Application__r.Entrance_Exam__c, Name, Rank__c, Roll_No__c, State__c,
                Total_Marks__c,Scored_Marks__c,Allotted_Category__c
                FROM Entrance_Exam__c 
                WHERE Application__c = :app.Id];
    }
    
    @AuraEnabled
    public static void deleteEntranceExamRecord(Id examId) {
        try {
            delete [SELECT Id FROM Entrance_Exam__c WHERE Id = :examId];
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting record: ' + e.getMessage());
        }
    }

 @AuraEnabled(cacheable=true)
public static List<String> getStateExamNameOptions() {
    // Query the custom setting to fetch state exam names
    List<Entrance_Exam_Name__c> customSettingRecords = [
        SELECT Name,State__c,Exam_Name__c 
        FROM Entrance_Exam_Name__c
      ];
    
    // Extract the names into a list
    List<String> options = new List<String>();
    for (Entrance_Exam_Name__c record : customSettingRecords) {
        options.add(record.Exam_Name__c);
    }
    
    return options;
}

@AuraEnabled(cacheable=true)
public static String getStateByExamName(String examName) {
       String state = '';
    system.debug('examName:'+examName);
    // Example logic: Fetch state based on exam name from a custom object
    List<Entrance_Exam_Name__c> exams = [SELECT State__c FROM Entrance_Exam_Name__c WHERE Exam_Name__c = :examName LIMIT 1];
      system.debug('state:'+exams);
    if (!exams.isEmpty()) {
        state = exams[0].State__c;
    }
     system.debug('state:'+state);
    return state;
}

}