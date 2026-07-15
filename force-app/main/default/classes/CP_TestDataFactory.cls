public class CP_TestDataFactory
{
    public static Account CreateAccount(string str_accName,String str_RecTypeId)
    {
        Account objAccount = new Account();
        objAccount.Name = str_accName;
        objAccount.RecordTypeId =  str_RecTypeId;
        return objAccount;
    }
    
    public static Contact createContact(string str_lastName)
    {
        Contact objContact = new Contact();
        objContact.LastName = str_lastName;
        return objContact;
    }
    
    public static hed__Term__c createTerm(String str_TermName,String str_AccId,String str_RecTypeId)
    {
        hed__Term__c objTerm = new hed__Term__c();
        objTerm.Name =  str_TermName;
        objTerm.hed__Account__c = str_AccId;
        objTerm.RecordTypeId =  str_RecTypeId;
        return objTerm;       
    }  
      
    public static hed__Program_Plan__c createProgramPlan(string str_ProgName)
    {
        hed__Program_Plan__c objProgramPlan = new hed__Program_Plan__c();
        objProgramPlan.Name = str_ProgName;
        return objProgramPlan;      
    }  
      
    public static hed__Plan_Requirement__c createPlanRequirement(String str_PlanReqName)
    {
        hed__Plan_Requirement__c objPlanReq = new hed__Plan_Requirement__c();
        objPlanReq.Name = str_PlanReqName;
        return objPlanReq;
    }
    
    public static hed__Course__c CreateCourse(string str_CourseName,string str_Accid)
    {
        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name = str_CourseName;
        objCourse.hed__Account__c = str_Accid;
        return objCourse;      
    }
    
    public static hed__Course_Offering__c createCourseOffering(string str_courseOffName,string str_TermId,String str_CourseId)
    {
        hed__Course_Offering__c objCourseOff = new hed__Course_Offering__c();
        objCourseOff.Name = str_courseOffName;
        objCourseOff.hed__Course__c = str_CourseId;
        objCourseOff.hed__Term__c = str_TermId;         
        return objCourseOff; 
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