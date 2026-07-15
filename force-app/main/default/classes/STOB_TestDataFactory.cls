public class STOB_TestDataFactory 
{
    public static Account CreateAccount(string str_accName)
    {
        Account objAccount = new Account();
        objAccount.Name = str_accName;
        return objAccount;
    }
    
    public static Contact createContact(string str_lastName)
    {
        Contact objContact = new Contact();
        objContact.LastName = str_lastName;
        return objContact;
    }
    
    public static hed__Education_History__c createEducationHistory(string str_ConId)
    {
        hed__Education_History__c objEduHis = new hed__Education_History__c();
        objEduHis.hed__Contact__c = str_ConId;
        return objEduHis;       
    }
    
    public static hed__Program_Plan__c createProgramPlan(string str_ProgName)
    {
        hed__Program_Plan__c objProgramPlan = new hed__Program_Plan__c();
        objProgramPlan.Name = str_ProgName;
        return objProgramPlan;      
    }
    
    public static hed__Program_Enrollment__c createprogramEnrollment(string str_ProgPlan)
    {
        hed__Program_Enrollment__c objProgramEnrollment = new hed__Program_Enrollment__c();
        objProgramEnrollment.hed__Program_Plan__c = str_ProgPlan;
        return objProgramEnrollment;
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
    /*public static Professor_Student_Course_Preference__c CreateProfessorStudent(String ProfStudentName,String CourseOffid,String termid)
    {
        Professor_Student_Course_Preference__c objProfStu = new Professor_Student_Course_Preference__c();
         objProfStu.Name = ProfStudentName;
         objProfStu.Course_Offering__c = CourseOffid;
         objProfStu.Term__c = termid;
         return objProfStu;
    }*/
}