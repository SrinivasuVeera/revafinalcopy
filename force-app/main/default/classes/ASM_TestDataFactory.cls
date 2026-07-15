@isTest
public class ASM_TestDataFactory {
    
    public static Account createAcc(Integer i){
        Account acc = new Account();
        acc.Name = 'Test Acc'+i;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        acc.School_Head__c = Userinfo.getUserId();
        return acc;
    }
    
    public static Account createSchoolAcc(Integer i){
        Account acc = new Account();
        acc.Name = 'Test Acc'+i;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        acc.School_Head__c = Userinfo.getUserId();
        return acc;
    }
    public static Contact createContact(Integer i, Id accId){
        Contact con = new Contact();
        con.LastName = 'Student '+i;
        con.SRN_Number__c = 'SRN000'+i;
        con.AccountId = accId;
        con.Nationality__c = 'Indian';
        con.MobilePhone ='8963210547';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        con.Program_Batch__c = createProgramPlan('test').Id;
        return con;
    }
    public static User createStudentUser(String uniqueKey){
        Long randNumLong = System.currentTimeMillis();
        User uBuyer = new User(Alias = uniqueKey,
                               Email = uniqueKey + randNumLong + '@reva.com',
                               EmailEncodingKey = 'UTF-8',
                               FirstName = 'Ben',
                               LastName = 'Israel',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_AU',
                               TimeZoneSidKey = 'Australia/Sydney',
                               Username = uniqueKey + randNumLong + '@reva.com',
                               CommunityNickname = uniqueKey + randNumLong,
                               //UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Buyer'].Id,
                               ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile'].Id,
                               IsActive = true);
        return uBuyer;
    }
    
    public static hed__Program_Enrollment__c createProgramEnrollment(Id conId, String prgPlan){
        hed__Program_Enrollment__c pgmEnr = new hed__Program_Enrollment__c();
        pgmEnr.hed__Contact__c = conId;
        pgmEnr.hed__Program_Plan__c = prgPlan;
        pgmEnr.hed__Start_Date__c = System.today();
        pgmEnr.hed__End_Date__c  = System.today().addDays(1); 
        return pgmEnr;
    }
    
    public static hed__Term__c createTerm(String TermName,String AccId,String RecTypeId)
    {
        hed__Term__c objTerm = new hed__Term__c();
        objTerm.Name =  TermName;
        objTerm.hed__Account__c = AccId;
        objTerm.RecordTypeId =  RecTypeId;
        objTerm.hed__Start_Date__c = System.today().addDays(-40);
        objTerm.hed__End_Date__c = System.today().addDays(100);
        objTerm.IA_1_Start_date__c = System.today().addDays(-10);
        objTerm.IA_1_End_date__c = System.today().addDays(10);
        objTerm.IA_2_Start_date__c = System.today().addDays(40);
        objTerm.IA_2_End_date__c = System.today().addDays(80);
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
    public static hed__Course__c CreateCourse(Integer i,string Accid, String cat,String Hardcore)
    {
        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name = 'Course '+i;
        objCourse.hed__Account__c = Accid;
        objCourse.Category__c = cat;
        objCourse.HardCore_Sub_Type__c = Hardcore;
        objCourse.Credits__c =3;
        objCourse.Offered_By_School__c=Accid;
        objCourse.Credit_Hours__c=39;
        objCourse.L_T_P__c='210';
        objCourse.Maximum_External_Marks__c=50;
      //  objCourse.Maximum_Internal_Marks__c=25;
        objCourse.Total_Maximum_Marks_IA_External__c=100;
        objCourse.No_of_IA_s__c = '1';
     //   objCourse.Maximum_Internal_Marks_Logisys__c = 0;
        
        objCourse.hed__Course_ID__c = 'CRS00'+i;
        return objCourse;      
    }
    public static hed__Course__c CreateCourse(Integer i,string Accid, String cat)
    {
        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name = 'Course '+i;
        objCourse.hed__Account__c = Accid;
        objCourse.Category__c = cat;
        objCourse.HardCore_Sub_Type__c = 'Theory';
        objCourse.Maximum_Internal_Marks_Logisys__c = 0;
        objCourse.hed__Course_ID__c = 'CRS00'+i;
        objCourse.Credits__c =3;
        objCourse.Offered_By_School__c=Accid;
        objCourse.Credit_Hours__c=39;
        objCourse.L_T_P__c='210';
        objCourse.Maximum_External_Marks__c=50;
      //  objCourse.Maximum_Internal_Marks__c=25;
        objCourse.Total_Maximum_Marks_IA_External__c=100;
        objcourse.No_of_IA_s__c = '1';
        return objCourse;      
    }
    public static hed__Course_Offering__c createCourseOffering(string courseOffName,string TermId,String CourseId)
    {
        hed__Course_Offering__c objCourseOff = new hed__Course_Offering__c();
        objCourseOff.Name = courseOffName;
        objCourseOff.hed__Course__c = CourseId;
        objCourseOff.hed__Term__c = TermId;   
        objCourseOff.School_Head__c = UserInfo.getUserId();
        objCourseOff.RVE_Professor_freeze__c = false;
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
    public static IA_Marks__c createIAMarks(Id crsConId, Id crsOffId, String iaType){
        IA_Marks__c iam = new IA_Marks__c();
        iam.Course_Connection__c = crsConId;
        iam.Course_Offering__c = crsOffId;
        iam.IA_Type__c = iaType;
        iam.Theory_Secured_Marks__c = 1;
        iam.Seminar_Secured_Marks__c = 1;
        iam.Quiz_Secured_marks__c = 1;
        iam.Knowledge_of_Exercise_Secured_Marks__c = 1;
        iam.Execution_of_Exercise_Secured_Marks__c = 1;
        iam.Viva_Voce_Practical_Secured_Marks__c = 1;
        iam.Punctuality_Secured_Marks__c = 1;
        iam.Results_Secured_Marks__c = 1;
        iam.Selection_of_Topic_Secured_Marks__c = 1;
        iam.Analysis_and_Synthesis_Secured_Marks__c = 1;
        iam.Continuous_Learning_Secured_Marks__c = 1;
        iam.Report_Writing_Secured_Marks__c = 1;
        iam.Description_of_Experiment_Secured_Mark__c = 1;
        iam.Literature_Survey_Secured_Marks__c = 1;
        iam.Oral_Presentation_Secured_Marks__c = 1;
        iam.Ethical_Attitude_Secured_Marks__c = 1;
        iam.Independent_Learning_Secured_Marks__c = 1;
        iam.Name='test';
        iam.Total_Secured_Marks_New__c = 1;
        return iam;
    }
    
    public static hed__Term_Grade__c createResSummary(Id conId,Id semId,Id crsOffId){
        hed__Term_Grade__c resSmry = new hed__Term_Grade__c();
        resSmry.hed__Contact__c = conId;
        resSmry.hed__Course_Offering__c = crsOffId;
        resSmry.hed__Term__c = semId;
        resSmry.Secured_External_Marks__c = 10;
        resSmry.Secured_Internal_Marks__c = 10;
        return resSmry;
    }
    
    public static hed__Term_Grade__c createResult(Id conId,Id semId, Id crsConId, Id crsOffId){
        hed__Term_Grade__c resSmry = new hed__Term_Grade__c();
        resSmry.hed__Contact__c = conId;
        resSmry.hed__Term__c = semId;
        resSmry.Secured_External_Marks__c = 10;
        resSmry.Secured_Internal_Marks__c = 10;
        resSmry.hed__Course_Connection__c = crsConId;
        resSmry.hed__Course_Offering__c = crsOffId;
        return resSmry;
    }
    public static Fee_Payment_Criteria__c createFeePaymentCriteria1(string str_PaymentType)
    {
        Fee_Payment_Criteria__c objFeeCrtr1 = new Fee_Payment_Criteria__c();
        objFeeCrtr1.Payment_Type__c = str_PaymentType;
        return objFeeCrtr1;
    }
    
    public static Student_Fee__c createStudentFee(string str_FeeCriteria,string str_Contact,string FeeType)
    {
        Student_Fee__c objStudentfee = new Student_Fee__c();
        objStudentfee.Fee_Payment_Criteria__c = str_FeeCriteria;
        objStudentfee.Contact__c = str_Contact;
        objStudentfee.Fee_Type__c =FeeType;
        return objStudentfee;
    }
}