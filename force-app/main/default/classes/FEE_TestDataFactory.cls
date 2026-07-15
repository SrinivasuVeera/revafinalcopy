public class FEE_TestDataFactory 
{
    public static Account CreateAccount(string str_accName,string str_rectypeId)
    {
        Account objAccount = new Account();
        objAccount.Name = str_accName;
        objAccount.RecordTypeId = str_rectypeId;
        return objAccount;
    }
    
    public static Contact createContact(string str_lastName,string str_AccId)
    {
        Contact objContact = new Contact();
        objContact.LastName = str_lastName;
        objContact.AccountId = str_AccId;
        return objContact;
    }
    
    public static hed__Program_Plan__c createProgramPlan(string str_ProgName)
    {
        hed__Program_Plan__c objProgramPlan = new hed__Program_Plan__c();
        objProgramPlan.Name = str_ProgName;
        return objProgramPlan;      
    }
    
    public static hed__Program_Enrollment__c createProgramEnrollment(string str_Con,string str_Progplan)
    {
        hed__Program_Enrollment__c objProgEnroll = new hed__Program_Enrollment__c();
        objProgEnroll.hed__Contact__c = str_Con;
        objProgEnroll.hed__Program_Plan__c = str_Progplan;
        objProgEnroll.hed__Start_Date__c = system.today();
        objProgEnroll.hed__End_Date__c  = system.today().addDays(1); 
        return objProgEnroll;
    }
    
    public static Fee_Payment_Criteria__c createFeePaymentCriteria(string str_FeeType,string str_PaymentType)
    {
        Fee_Payment_Criteria__c objFeeCrtr = new Fee_Payment_Criteria__c();
        objFeeCrtr.Fee_Type__c = str_FeeType;
        objFeeCrtr.Payment_Type__c = str_PaymentType;
        return objFeeCrtr;
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
    public static Student_Payment__c createStudentPayment(string str_Contact)
    {
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Contact__c =  str_Contact;
        return objStuPayment;
    }    
    public static Student_Fee_Payment__c CreateStudentFeePayment(string StuFeeId,string StuPayId)
    {
        Student_Fee_Payment__c objStuFeePay = new Student_Fee_Payment__c();
        objStuFeePay.Student_Fee__c = StuFeeId;
        objStuFeePay.Student_Payment__c = StuPayId;
        return objStuFeePay;
    }  
    public static Case createCase(string caseStatus,string caseOrigin)
    {
        case objcase = new case();
        objcase.Status = caseStatus;
        objcase.Origin = caseOrigin;
        return objcase;
    }
    public static hed__Term__c createTerm(String TermName,String AccId,String RecTypeId)
    {
        hed__Term__c objTerm = new hed__Term__c();
        objTerm.Name =  TermName;
        objTerm.hed__Account__c = AccId;
        objTerm.RecordTypeId =  RecTypeId;
        return objTerm;       
    }    
}