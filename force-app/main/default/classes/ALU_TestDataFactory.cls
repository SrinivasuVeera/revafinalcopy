public class ALU_TestDataFactory
{
    public static Account CreateAccount(string str_accName,String RecTypeId)
    {
        Account objAccount = new Account();
        objAccount.Name = str_accName;
        objAccount.RecordTypeId =  RecTypeId;
        return objAccount;
    }    
    public static Contact createContact(string str_lastName)
    {
        Contact objContact = new Contact();
        objContact.LastName = str_lastName;
        return objContact;
    }
    public static hed__Program_Enrollment__c createProgEnrollment(string contactid,String AccountId)
    {
        hed__Program_Enrollment__c objProgEnrollment = new hed__Program_Enrollment__c();
        objProgEnrollment.hed__Contact__c = contactid;
        objProgEnrollment.hed__Account__c = AccountId;
        return objProgEnrollment; 
    }
    
    public static hed__Program_Plan__c createProgramPlan(string str_ProgName)
    {
        hed__Program_Plan__c objProgramPlan = new hed__Program_Plan__c();
        objProgramPlan.Name = str_ProgName;
        return objProgramPlan;      
    }    
    
    public static Proxy_Attendance__c CreateProxyAttendance(string contactid)
    {
        Proxy_Attendance__c objProxy = new Proxy_Attendance__c();
        objProxy.Contact__c = contactid;
        return objProxy;
    }
    public static hed__Term__c createTerm(String TermName,String AccId,String RecTypeId)
    {
        hed__Term__c objTerm = new hed__Term__c();
        objTerm.Name =  TermName;
        objTerm.hed__Account__c = AccId;
        objTerm.RecordTypeId =  RecTypeId;
        return objTerm;       
    }    
    public static hed__Course__c CreateCourse(string CourseName,string Accid)
    {
        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name = CourseName;
        objCourse.hed__Account__c = Accid;
        return objCourse;      
    }
    public static hed__Course_Offering__c createCourseOffering(string courseOffName,string TermId,String CourseId)
    {
        hed__Course_Offering__c objCourseOff = new hed__Course_Offering__c();
        objCourseOff.Name = courseOffName;
        objCourseOff.hed__Course__c = CourseId;
        objCourseOff.hed__Term__c = TermId;         
        return objCourseOff; 
    }
    public static hed__Course_Offering_Schedule__c CreateCourseSchedule(String CourseoffId,string sectionid)
    {
        hed__Course_Offering_Schedule__c objCourseSch = new hed__Course_Offering_Schedule__c();
        objCourseSch.hed__Course_Offering__c = CourseoffId;
        objCourseSch.Section__c = sectionid;
        return objCourseSch;
    } 
    public static hed__Course_Enrollment__c createCourseEnrollment(string objContactId , String objCourseOffId)
    {
        hed__Course_Enrollment__c obj_Cour_Enroll = new hed__Course_Enrollment__c();
        obj_Cour_Enroll.hed__Contact__c = objContactId;
        obj_Cour_Enroll.hed__Course_Offering__c = objCourseOffId;
        return obj_Cour_Enroll;
    }
    public static hed__Attendance_Event__c createAttendanceEvent(string CourseSchId,string conid,string courseEnrollId)
    {
        hed__Attendance_Event__c objAttEvent = new hed__Attendance_Event__c();
        objAttEvent.Course_Offering_Schedule__c = CourseSchId;
        objAttEvent.hed__Contact__c = conid;
        objAttEvent.hed__Course_Connection__c  =courseEnrollId;
        return objAttEvent;        
    }
    public static Alumni_Activities__c createAlumniActivities(string objContactId)
    {
        Alumni_Activities__c objAluActiv = new Alumni_Activities__c();
        objAluActiv.Contact__c = objContactId;
        return objAluActiv;
    }
    public static Alumni_Event_Registrations__c createAlumniEventReg(string objContactId, string objAluActivities)
    {
        Alumni_Event_Registrations__c objAlumniEventReg = new Alumni_Event_Registrations__c();
        objAlumniEventReg.Contact__c = objContactId;
        objAlumniEventReg.Alumni_Activities_Event__c = objAluActivities;
        return objAlumniEventReg;
    }
    
    public static Student_Fee__c createStudentFee(string objContactId)
    {
        Student_Fee__c objStufee = new Student_Fee__c();
        objStufee.Name = 'term';
        objStufee.Contact__c = objContactId;
        objStufee.Amount_Pending__c = 5000;
        return objStufee;  
    }
    
    public static hed__Term_Grade__c createResults(string objContactId)
    {
      hed__Term_Grade__c objReslt = new hed__Term_Grade__c();
      objReslt.hed__Contact__c = objContactId;
      objReslt.hed__Result__c = 'Fail';
      return objReslt;
    }
    public static Alumni_Payments__c createPayments(string objContactId)
    {
        Alumni_Payments__c objAluPay = new Alumni_Payments__c();
        objAluPay.Contact__c = objContactId;
        objAluPay.Amount__c = 20200;
        return objAluPay;
    }
}