public without sharing class Reva_ExamApplication_Ctrl {
    
    public static List<contact> getStudentDetails(){
        List<contact> currentStudent = new List<Contact>();
        List<User> lUsers = [Select Id,Contact.Id from user where Id =:UserInfo.getUserId() and contactId!=NULL];
               System.debug('lUsers '+lUsers);

        if(lUsers != null && lUsers.size() > 0){
            currentStudent = [Select Id, Name, Active_Semester__c,Active_Semester__r.Name, Primary_Academic_Program__r.Program_Type__c, 
                            Program_Batch__c,Application_Number__c, Select_Category__c, Father_Name__c, 
                            Mother_Name__c, Course__c, School_Name__c, File_Passport_Size_Photo__c, 
                            Personal_Email__c, MobilePhone, Father_Email_ID__c, Father_Mobile_Number__c,
                            Mother_Email_ID__c, Mother_Mobile_Number__c, SRN_Number__c 
                             from Contact Where Id = :lUsers[0].ContactId];
            System.debug('currentStudent '+currentStudent);
        }
        if(currentStudent!=NULL){
       System.debug('currentStudent '+currentStudent);

              return currentStudent;
        }else{
            return NULL;
        }
         
    }
    @AuraEnabled(cacheable=true)
    public static List<Rve_Exam_Notification__c> getExamNotificationDetails(){
        List<contact> student = getStudentDetails();
        Id mainExamRecordType = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName().get('hed_Semester_Notification').getRecordTypeId();
        List<Rve_Exam_Notification__c> currentNotification = [select Id,Rve_Semester__r.Name,Name, Rve_End_Date__c, Rve_Fee__c, Rve_Late_Fee__c, Rve_Publish__c, Rve_Start_Date__c,CreatedDate from Rve_Exam_Notification__c where Rve_Semester__c =:student[0].Active_Semester__c AND Rve_Publish__c= TRUE AND RecordTypeId = :mainExamRecordType limit 1]; 
        return currentNotification;
    }

    // This method will check that exam application has been already created ot not.
    @AuraEnabled(cacheable=true)
    public static Boolean examApplicationEligibility(){
        try {
            List<contact> student = getStudentDetails();
            List<Rve_Exam_Application__c> examApplicationList = new List<Rve_Exam_Application__c>();
            Id mainExamRecordType = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName().get('hed_Semester_Notification').getRecordTypeId();
            List<Rve_Exam_Notification__c> currentNotification = [select Id,Rve_Semester__r.Name,Name, Rve_End_Date__c, Rve_Fee__c, Rve_Late_Fee__c, Rve_Publish__c, Rve_Start_Date__c,createdDate from Rve_Exam_Notification__c where Rve_Semester__c =:student[0].Active_Semester__c AND Rve_Publish__c= TRUE AND RecordTypeId = :mainExamRecordType limit 1]; 
            if(currentNotification != null && currentNotification.size() > 0){
                examApplicationList = [Select Id, Name, Rve_Exam_Notification__c from Rve_Exam_Application__c Where Rve_Exam_Notification__c =:currentNotification[0].Id AND Rve_Student__c =:student[0].Id];
            }
            else {
                return true;
            }
            if(examApplicationList != null && examApplicationList.size() > 0){
                return true;
            }
            return false;      
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    @AuraEnabled(cacheable=true)
    public static List<hed__Course_Enrollment__c> getCourseDetails(List<Contact> condetails){
        // List<contact> condetails = getStudentDetails();
        List<hed__Course_Enrollment__c> enrollments = new List<hed__Course_Enrollment__c>();
        enrollments =[Select id,Name,hed__Contact__c, hed__Status__c, Course_Offering_ID_Formula__c,hed__Course_Offering__r.hed__Course__r.Name ,hed__Course_Offering__c, hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c from hed__Course_Enrollment__c where hed__Status__c='Current' AND hed__Contact__c =:condetails[0].Id];
        return enrollments;
    }

    @AuraEnabled(cacheable=true)
    public static List<hed__Term_Grade__c> getBacklogDetails(List<Contact> condetails){
        // List<contact> condetails = getStudentDetails();
        List<hed__Term_Grade__c> results = new List<hed__Term_Grade__c>();
        results = [Select Id, hed__Contact__c, hed__Course_Connection__c, hed__Course_Offering__c,  hed__Course_Offering__r.hed__Course__r.Name, hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c, hed__Credits_Attempted__c, hed__Credits_Earned__c, hed__Letter_Grade__c, hed__Numerical_Grade__c, hed__Percent_Grade__c, hed__Result__c, hed__Term_Grade_Type__c, hed__Term__c, CGPA__c, Course_Code__c, Course__c, Credit_Points__c, Cumulative_Grade_Point__c, Examination_Month_Year__c, External_ID__c, Father_Guardian_Name__c, Grade_Points__c, Grade__c, Maximum_Marks_Course_Level__c, Mother_Name__c, No_of_Credits__c, Passing_Criteria__c, Program__c, Recent_Result_Updated_Date__c, Remarks__c, Result_Summary__c, SGPA__c, SRN_Number__c, School__c, Secured_External_Marks__c, Secured_Internal_Marks__c, Total_Maximum_Marks_Semester__c, Total_Secured_Marks_Course_Level__c, Total_Secured_Marks_Semester__c, Total_Maximum_Marks_Course__c, Total_Secured_Marks_Course__c, Program_Name__c, School_Name__c From hed__Term_Grade__c Where (hed__Result__c = 'Fail' OR hed__Result__c = 'Dropped') AND hed__Contact__c =:condetails[0].Id];
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static List<rve_Fee_Detail__mdt> getFeeDetails(){
        List<rve_Fee_Detail__mdt> results = new List<rve_Fee_Detail__mdt>();
        results = [Select Id,Label, DeveloperName, Amount__c from rve_Fee_Detail__mdt];
        System.debug('Results=> '+results);
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean checkIsFinalYearStudent(Id ProgramBatchId, Id ActiveSemesterId){
        Map<Id,hed__Term__c> results =  new Map<Id, hed__Term__c>([Select Id, Name From hed__Term__c Where Program_Batch__c =:ProgramBatchId Order by Name desc Limit 1]);
        if(results != null && results.containsKey(ActiveSemesterId)){
            return true;
        }
        return false;
    }

    public class ExamDetailsWrapper {
        @AuraEnabled public List<hed__Course_Enrollment__c> courses {get; set;}
        @AuraEnabled public List<hed__Term_Grade__c> backlogs {get; set;}
        @AuraEnabled public List<rve_Fee_Detail__mdt> feeDetails {get; set;}
        @AuraEnabled public Contact contactDetails {get; set;}
        @AuraEnabled public Boolean isFinalYearStudent {get; set;}

        public ExamDetailsWrapper(List<hed__Course_Enrollment__c> couresRecord, List<hed__Term_Grade__c> backlogsRecord, List<rve_Fee_Detail__mdt> feeDetailsRecord, Contact contactDetailsRecord, Boolean isFinalYearStudentRecord){
            this.courses = couresRecord;
            this.backlogs = backlogsRecord;
            this.feeDetails = feeDetailsRecord;
            this.contactDetails = contactDetailsRecord;
            this.isFinalYearStudent = isFinalYearStudentRecord;
        }
    }

    @AuraEnabled(cacheable=true)
    public static ExamDetailsWrapper getExamDetails(){
        List<Contact> condetails = getStudentDetails();
        List<hed__Course_Enrollment__c> courses = new List<hed__Course_Enrollment__c>();
        List<hed__Term_Grade__c> backlogs = new List<hed__Term_Grade__c>();
        List<rve_Fee_Detail__mdt> feeDetails = new List<rve_Fee_Detail__mdt>();
        Contact contactDetails = new Contact();
        Boolean isFinalYearStudent = false;
        
        if(condetails != null && condetails.size() > 0){
            courses = getCourseDetails(condetails);
            backlogs = getBacklogDetails(condetails);
            feeDetails = getFeeDetails();
            contactDetails = Condetails[0];
            if(contactDetails.Program_Batch__c != null){
                isFinalYearStudent = checkIsFinalYearStudent(contactDetails.Program_Batch__c, contactDetails.Active_Semester__c);
            }
        }

        ExamDetailsWrapper wrapObj = new ExamDetailsWrapper(courses, backlogs, feeDetails, contactDetails, isFinalYearStudent);
        return wrapObj;
    }

    @AuraEnabled
    public static Boolean insertRecords(Rve_Exam_Application__c examApplication, List<Rve_Exam_Application_Line_Item__c> lineItemObjs){
        try {
            List<Contact> condetails = getStudentDetails();
            if(condetails == null || condetails.size() == 0){
                return false;
            }
      system.debug('data'+[Select Id, Name, Fee_Type__c, Payment_Type__c From Fee_Payment_Criteria__c Where Fee_Type__c = 'Examination & Valuation Fee' AND Payment_Type__c = 'Full Payment' Limit 1]);
            List<Fee_Payment_Criteria__c> FeePaymentCriteria = [Select Id, Name, Fee_Type__c, Payment_Type__c From Fee_Payment_Criteria__c Where Fee_Type__c = 'Examination & Valuation Fee' AND Payment_Type__c = 'Full Payment' Limit 1];
            if(FeePaymentCriteria == null || FeePaymentCriteria.size() ==0 ){
                return false;
            }

            System.debug('examApplication :'+examApplication);
            System.debug('lineItemObjs :'+lineItemObjs);

            insert examApplication;
       system.debug('examApplication'+examApplication.Id);
            for(Rve_Exam_Application_Line_Item__c item : lineItemObjs){
                item.Rve_Exam_Application__c = examApplication.Id;
                
            }
            insert lineItemObjs;

            Student_Fee__c studentFee               = new Student_Fee__c();
            
            studentFee.Name                         = examApplication.Name;
            studentFee.Reva_Exam_Application__c     = examApplication.Id;
            studentFee.Amount__c                    = examApplication.Rve_Amount__c;
            studentFee.Amount_Pending__c            = examApplication.Rve_Amount__c;
            studentFee.Fee_Type__c                  = 'Examination & Valuation Fee';
            studentFee.Payment_Type__c              = 'Full Payment';
            studentFee.Payment_Mode_Type__c         = 'Online';
            studentFee.Fee_Payment_Criteria__c      = FeePaymentCriteria[0].Id;
            studentFee.Contact__c                   = condetails[0].Id;
            studentFee.Student_Personal_Email__c    = condetails[0].Personal_Email__c;
            studentFee.Student_Mobile_Number__c     = condetails[0].MobilePhone;
            studentFee.Father_Email_ID__c           = condetails[0].Father_Email_ID__c;
            studentFee.Father_Mobile_Number__c      = condetails[0].Father_Mobile_Number__c;
            studentFee.Mother_Email_ID__c           = condetails[0].Mother_Email_ID__c;
            studentFee.Mother_Mobile_Number__c      = condetails[0].Mother_Mobile_Number__c;

            System.debug('studentFee : '+studentFee);

            insert studentFee;
            System.debug('Amount=> '+ studentFee.Amount__c +'PaymentType=> '+studentFee.Payment_Type__c);

            return true;

        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}