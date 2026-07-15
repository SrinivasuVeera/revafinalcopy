public class MSTR_TestDataFactory 
{
    public static Account CreateAccount(string str_accName,String RecTypeId)
    {
        User adminUser = [Select Id, UserRoleId,UserType From User Where Profile.Name='System Administrator'  and IsActive = true AND UserRoleId != null Limit 1];

        Account objAccount = new Account();
        objAccount.Name = str_accName;
        objAccount.OwnerId = adminUser.Id;
        objAccount.RecordTypeId =  RecTypeId;
        return objAccount;
    }
    
    public static Account CreateAccount1(string str_accName1)
    {
        Account objAccount1 = new Account();
        objAccount1.Name = str_accName1;
        return objAccount1;
    }
    
    
    
    public static Contact createContact(string str_lastName)
    {
        Contact objContact = new Contact();
        objContact.LastName = str_lastName;
        objContact.Nationality__c = 'Indian';
        objContact.MobilePhone = '9876543210';
        objContact.PAN_Number__c = 'BDCPJ1034G';
        objContact.Aadhar_Card_Number__c = '123456789010';
        return objContact;
    }
    
    public static hed__Term__c createTerm(String TermName,String AccId,String RecTypeId)
    {
        hed__Term__c objTerm = new hed__Term__c();
        objTerm.Name =  TermName;
        objTerm.hed__Account__c = AccId;
        objTerm.RecordTypeId =  RecTypeId;
        return objTerm;       
    }    
    public static hed__Program_Plan__c createProgramPlan(string str_ProgName)
    {
        hed__Program_Plan__c objProgramPlan = new hed__Program_Plan__c();
        objProgramPlan.Name = str_ProgName;
        return objProgramPlan;      
    }    
    public static hed__Plan_Requirement__c createPlanRequirement(String PlanReqName)
    {
        hed__Plan_Requirement__c objPlanReq = new hed__Plan_Requirement__c();
        objPlanReq.Name = PlanReqName;
        return objPlanReq;
    }
    public static hed__Course__c CreateCourse(string CourseName,string Accid)
    {
        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name = CourseName;
        objCourse.hed__Account__c = Accid;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';
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
    
    
    public static hed__Program_Enrollment__c createProgEnrollment(string contactid,String AccountId)
    {
        hed__Program_Enrollment__c objProgEnrollment = new hed__Program_Enrollment__c();
        objProgEnrollment.hed__Contact__c = contactid;
        objProgEnrollment.hed__Account__c = AccountId;
        return objProgEnrollment; 
    }
    public static Student_Semester_Mapping__c createStudenttermMapping(string StuTermName,String RecId)
    {
        Student_Semester_Mapping__c objStuMapping = new Student_Semester_Mapping__c();
        objStuMapping.Name= StuTermName;
        objStuMapping.RecordTypeId = RecId;         
        return objStuMapping; 
    }
    
    public static hed__Course_Enrollment__c createCourseEnrollment(string objContactId , String objCourseOffId)
    {
        hed__Course_Enrollment__c obj_Cour_Enroll = new hed__Course_Enrollment__c();
        obj_Cour_Enroll.hed__Contact__c = objContactId;
        obj_Cour_Enroll.hed__Course_Offering__c = objCourseOffId;
        return obj_Cour_Enroll;
    }
    public static Professor_Student_Course_Preference__c CreateProfessorStudent(String ProfStudentName,String CourseOffid,String termid)
    {
        Professor_Student_Course_Preference__c objProfStu = new Professor_Student_Course_Preference__c();
        objProfStu.Name = ProfStudentName;
        objProfStu.Course_Offering__c = CourseOffid;
        objProfStu.Semester__c= termid;
        return objProfStu;
    }  
    
    /*public static City__c CreateCity(String StrcityName,String districtId)
{
City__c objcity = new City__c();
objcity.Name = StrcityName;
objcity.District__c = districtId;
return objcity;
}  */       
    
}