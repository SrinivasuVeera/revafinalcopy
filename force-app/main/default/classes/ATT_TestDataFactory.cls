public class ATT_TestDataFactory 
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
    public static Course_Plan_Unit__c createCoursePlanUnit(string str_CourseplanunitName,string str_courseOff,string str_course)
    {
        Course_Plan_Unit__c objCoursePlanUnit = new Course_Plan_Unit__c();
        objCoursePlanUnit.Name =str_CourseplanunitName;
        objCoursePlanUnit.Course_Offering__c = str_courseOff;
        objCoursePlanUnit.Course__c = str_course;
        return objCoursePlanUnit;
    }  
    public static Course_Plan_Topic__c createCoursePlanTopic(string str_CourseplanName,string str_CoursePlanUnit)
    {
        Course_Plan_Topic__c objCourseplanTopic = new Course_Plan_Topic__c();
        objCourseplanTopic.Name = str_CourseplanName;
        objCourseplanTopic.Course_Plan_Unit__c = str_CoursePlanUnit;
        return objCourseplanTopic;
    }
}