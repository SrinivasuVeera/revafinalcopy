public with sharing class ExamApplicationPDF {
    public Contact student {get;set;}
    public Rve_Exam_Notification__c examApplicationNotification {get;set;}
    public List<Rve_Exam_Application__c> examApplications {get;set;}
    public Student_Fee_Payment__c StudentFeePayment {get;set;}
    public list<Rve_Exam_Application_Line_Item__c> lineItems {get;set;}
    public String examApplicationHeader {get;set;}
    public ExamApplicationPDF(ApexPages.StandardController controller) {
        try{
            examApplicationHeader = '';
            student = new Contact();
            examApplicationNotification = new Rve_Exam_Notification__c();
            examApplications = new List<Rve_Exam_Application__c>();
            StudentFeePayment = new Student_Fee_Payment__c();
            String studentId = Apexpages.currentPage().getParameters().get('id');
            String applicationId = Apexpages.currentPage().getParameters().get('application');
            List<Contact> currentStudent = [Select Id, Name, Active_Semester__c, Application_Number__c, Select_Category__c, Father_Name__c, Mother_Name1__c, Mother_Name__c, Course__c, School_Name__c, File_Passport_Size_Photo__c from Contact Where Id =:studentId];
            System.debug('currentStudent '+currentStudent);
            if(currentStudent != null && currentStudent.size() > 0){
                student = currentStudent[0];
            }
            if(student != null){
                System.debug('student '+student);
                examApplications = [Select Id, Rve_Application_Number__c,Name, Rve_Amount__c, Rve_Applied_Date__c, Rve_Exam_Notification__c, Rve_Logisys_Field_Check__c, Rve_Payment_Date__c, Rve_Payment_Status__c, Rve_Payment_Type__c, Rve_Registration_Number__c, Rve_Status__c, Rve_Student__c, Rve_Exam_Notification__r.Rve_Start_Date__c, Rve_Exam_Notification__r.Rve_End_Date__c From Rve_Exam_Application__c Where Id =:applicationId];
               lineItems = new List<Rve_Exam_Application_Line_Item__c>();
                lineItems= [Select Id, Name , Rve_QP_Code__c, Rve_Semester__c, Rve_Subject__c, Course_Code__c From Rve_Exam_Application_Line_Item__c where Rve_Exam_Application__c=:applicationId];
                System.debug('examApplications '+examApplications);
                System.debug('lineItems '+lineItems);
                if(examApplications != null && examApplications.size() > 0){
                    //examApplication = examApplications[0];
                     system.debug('examApplication-->'+examApplications);
                    // Set Exam Application Header
                    Date startDate = (Date) examApplications[0].Rve_Exam_Notification__r.Rve_Start_Date__c;
                    Integer startDateYear = startDate.year();
                    Integer startDateMonth = startDate.month();
                    Integer startDateDay = startDate.day();
                    DateTime startDateTime = DateTime.newInstance(startDateYear,startDateMonth,startDateDay);
                    Date endDate = (Date) examApplications[0].Rve_Exam_Notification__r.Rve_End_Date__c;
                    Integer endDateYear = endDate.year();
                    Integer endDateMonth = endDate.month();
                    Integer endDateDay = endDate.day();
                    DateTime endDateTime = DateTime.newInstance(endDateYear,endDateMonth,endDateDay);
                    examApplicationHeader = (startDateTime.format('MMMM')).toUppercase() + (startDateMonth != endDateMonth ? '/'+ (endDateTime.format('MMMM')).toUppercase() : '') + ' ' + startDateYear + ' EXAMINATION'.toUppercase();

                }
                if(examApplications != null){
                    List<Rve_Exam_Notification__c> examNotifications = [Select Id, Name, Rve_Publish__c, Rve_Semester__c From Rve_Exam_Notification__c Where Id =:examApplications[0].Rve_Exam_Notification__c];
                    System.debug('examNotifications '+examNotifications);
                    if(examNotifications != null && examNotifications.size() > 0){
                        examApplicationNotification = examNotifications[0];
                    }

                    List<Student_Fee_Payment__c> StudentFeePayments = [Select Id, Name, Mode_of_Payment__c, Payment_Date__c, Line_Item_Payment_Status__c, Amount__c, SF_Transaction_ID__c From Student_Fee_Payment__c Where Student_Fee__r.Reva_Exam_Application__c = :examApplications[0].Id];
                    if(StudentFeePayments != null && StudentFeePayments.size() > 0){
                        StudentFeePayment = StudentFeePayments[0];
                    }
                }
            }
            System.debug('Student : '+student);
            System.debug('examApplicationNotification : '+examApplicationNotification);
            System.debug('examApplication : '+examApplications);
            System.debug('StudentFeePayment : '+StudentFeePayment);
        }catch(exception e){
            System.debug(e.getCause());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            System.debug(e.getTypeName());
        }
    }
}