public class STOB_ProgramEnrollmentTrg_Handler
{
    //Throw An Validation On Program Enrollment Before Deletion If SRN Number is Not Blank
    public static void AddValidationONProgramEnrollment(list<hed__Program_Enrollment__c> lst_PrgEnroll)
    {
        for(hed__Program_Enrollment__c objProgEnroll : lst_PrgEnroll)
        {
            if(objProgEnroll.SRN_Number__c != null)
            {
                objProgEnroll.addError('You Can Not Delete The Program Enrollment');
            }
        }
    }
}