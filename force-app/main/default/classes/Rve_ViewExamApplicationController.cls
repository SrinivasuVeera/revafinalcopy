public without sharing class Rve_ViewExamApplicationController {
    
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class ExamApplicationWrapper{
        @AuraEnabled
        public Contact student{get;set;}
        @AuraEnabled
        public Rve_Exam_Notification__c selectedEN{get;set;}
        @AuraEnabled
        public Rve_Exam_Application__c selectedEA{get;set;}
        @AuraEnabled
        public Student_Fee_Payment__c StudentFeePayment{get;set;}
    }
    
    @AuraEnabled
    public static ExamApplicationWrapper getContactDetails(String applicationId){
        ExamApplicationWrapper examWrapper = new ExamApplicationWrapper();
        Contact student = new Contact();
        Rve_Exam_Notification__c selectedEN = new Rve_Exam_Notification__c();
        Rve_Exam_Application__c selectedEA = new Rve_Exam_Application__c();
        Student_Fee_Payment__c StudentFeePayment = new Student_Fee_Payment__c();
        List<User> lUsers = [SELECT Id,Contact.Id,Name,ContactId,Email FROM User WHERE Id = :userinfo.getUserId()];
        System.debug('lUsers '+lUsers);
        if(lUsers != null && lUsers.size() > 0){
            List<Contact> currentStudent = [Select Id, Name, Active_Semester__c, Application_Number__c, Select_Category__c, Father_Name__c, Mother_Name1__c, Mother_Name__c, Course__c, School_Name__c, File_Passport_Size_Photo__c from Contact Where Id = :lUsers[0].ContactId];
            System.debug('currentStudent '+currentStudent);
            if(currentStudent != null && currentStudent.size() > 0){
                student = currentStudent[0];
            }
        }
        if(student != null){
            System.debug('student '+student);
            List<Rve_Exam_Application__c> examApplications = [Select Id, Name, Rve_Amount__c, Rve_Applied_Date__c, Rve_Exam_Notification__c, Rve_Logisys_Field_Check__c, Rve_Payment_Date__c, Rve_Payment_Status__c, Rve_Payment_Type__c, Rve_Registration_Number__c, Rve_Application_Number__c, Rve_Status__c, Rve_Student__c, Rve_Exam_Notification__r.Rve_Start_Date__c, Rve_Exam_Notification__r.Rve_End_Date__c,(Select Id, Name , Rve_QP_Code__c, Rve_Semester__c, Rve_Subject__c,Course_Code__c From Rve_Exam_Application_Line_Items__r) From Rve_Exam_Application__c Where Id = :applicationId];
            System.debug('examApplications '+examApplications);
            if(examApplications != null && examApplications.size() > 0){
                selectedEA = examApplications[0];
            }
            if(selectedEA != null){
                System.debug('39=> '+selectedEA);
                List<Rve_Exam_Notification__c> examNotifications = [Select Id, Name, Rve_Publish__c, Rve_Semester__c From Rve_Exam_Notification__c Where Id =:selectedEA.Rve_Exam_Notification__c];
                System.debug('examNotifications '+examNotifications);
                if(examNotifications != null && examNotifications.size() > 0){
                    selectedEN = examNotifications[0];
                    System.debug('44=> '+selectedEN);
                }
                
                List<Student_Fee_Payment__c> StudentFeePayments = [Select Id, Name, Mode_of_Payment__c, Payment_Date__c, Line_Item_Payment_Status__c, Amount__c, SF_Transaction_ID__c From Student_Fee_Payment__c Where Student_Fee__r.Reva_Exam_Application__c = :selectedEA.Id];
                System.debug('StudentFeePayments=> '+StudentFeePayments);
                if(StudentFeePayments != null && StudentFeePayments.size() > 0){
                    StudentFeePayment = StudentFeePayments[0];
                }
            }
        }
        examWrapper.student             = student;
        examWrapper.selectedEN          = selectedEN;
        examWrapper.selectedEA          = selectedEA;
        examWrapper.StudentFeePayment   = StudentFeePayment;
        System.debug('examWrapper '+examWrapper);
        return examWrapper;
    }
    
    @AuraEnabled
    public static List<Rve_Exam_Application__c> getExamApplicationList(){
        try {
            Contact student = new Contact();
            List<Rve_Exam_Application__c> examApplicationList = new List<Rve_Exam_Application__c>();
            List<User> lUsers = [SELECT Id,Contact.Id,Name,ContactId,Email FROM User WHERE Id = :userinfo.getUserId()];
            System.debug('lUsers '+lUsers);
            if(lUsers != null && lUsers.size() > 0){
                List<Contact> currentStudent = [Select Id, Name, Active_Semester__c, Application_Number__c, Select_Category__c, Father_Name__c, Mother_Name__c, Mother_Name1__c, Course__c, School_Name__c, File_Passport_Size_Photo__c from Contact Where Id = :lUsers[0].ContactId];
                System.debug('currentStudent '+currentStudent);
                if(currentStudent != null && currentStudent.size() > 0){
                    student = currentStudent[0];
                    examApplicationList = [Select Id, Name, Rve_Amount__c, Rve_Applied_Date__c, Rve_Exam_Notification__c, Rve_Student__r.SRN_Number__c, Rve_Student__r.Application_Number__c, Rve_Logisys_Field_Check__c, Rve_Payment_Date__c, Rve_Payment_Status__c, Rve_Payment_Type__c, Rve_Registration_Number__c, Rve_Status__c, Rve_Student__c, Rve_Application_Number__c From Rve_Exam_Application__c Where Rve_Student__c = :student.Id];
                }
            }
            return examApplicationList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static String getPdfFileAsBase64String(String studentId, String applicationId) {
        PageReference pdfPage = Page.ExamApplicationPDF;
        pdfPage.getParameters().put('id',studentId);
        pdfPage.getParameters().put('application',applicationId);
        Blob pdfBlob = pdfPage.getContent();
        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        return base64Pdf;
    }
    
    
  @AuraEnabled(cacheable=true)
public static List<Rve_Exam_Application_Line_Item__c> getExampleTimeTable(string userId) {
    
    List<Rve_Exam_Application_Line_Item__c> lineApplication = new List<Rve_Exam_Application_Line_Item__c>();
    
    Set<Id> exAppId = new Set<Id>();
    
    Id currentUserContactId;
    
    try {
        currentUserContactId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
        System.debug('currentUserContactId: ' + currentUserContactId);
    } catch (Exception e) {
        System.debug('Error retrieving current user\'s ContactId: ' + e.getMessage());
    }
    
    for(Rve_Exam_Application__c app : [SELECT Id, Name, Rve_Student__c, Rve_Exam_Notification__r.Rve_Publish__c  
                                        FROM Rve_Exam_Application__c 
                                        WHERE Rve_Exam_Notification__r.Rve_Publish__c = TRUE]) {
        exAppId.add(app.Id);  
    }
System.debug('currentUserContactId: ' + exAppId);
    
    if (!exAppId.isEmpty()) {
        lineApplication = [SELECT Id, Rve_Subject__c, Rve_QP_Code__c, Rve_Semester__c, Course_Code__c, Rve_Exam_Application__c, Date_Of_Examination__c,
                           Rve_Start_Time__c, Rve_End_Time__c, Rve_Batch__c
                           FROM Rve_Exam_Application_Line_Item__c
                           WHERE Rve_Exam_Application__c IN :exAppId];
        System.debug('currentUserContactId: ' + lineApplication);
    } else {
        System.debug('No Rve_Exam_Application__c records found');
    }
    
    return lineApplication;
}

}