@isTest
public class STOB_ProgramEnrollmentTrg_Handler_Test 
{
    public static testMethod Void ValidationMethod()
    {
        string houseHoldRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
        objAcc.Recordtypeid = houseHoldRecType;
        Insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact objCon = STOB_TestDataFactory.createContact('Test');
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
        hed__Program_Plan__c objProgramplan = STOB_TestDataFactory.createProgramPlan('Btech');
        objProgramplan.hed__Account__c = objAcc.Id;
        Insert objProgramplan;
        
        hed__Program_Enrollment__c objProgEnrlmt = STOB_TestDataFactory.createprogramEnrollment(objProgramplan.Id);
        objProgEnrlmt.hed__Account__c=objAcc.id;
        objProgEnrlmt.hed__Contact__c=objCon.id;
        objProgEnrlmt.hed__Eligible_to_Enroll__c=true;
        objProgEnrlmt.hed__Start_Date__c = system.today().addDays(-1);
        objProgEnrlmt.hed__End_Date__c = system.today().addDays(1);
        objProgEnrlmt.SRN_Number__c ='R23IA830';
        insert objProgEnrlmt;
        
        List<hed__Program_Enrollment__c> list_programEnrollments = new List<hed__Program_Enrollment__c>();
        list_programEnrollments.add(objProgEnrlmt);
        
        Database.DeleteResult result = Database.delete(objProgEnrlmt, false);       
        
        Test.startTest();
        STOB_ProgramEnrollmentTrg_Handler.AddValidationONProgramEnrollment(list_programEnrollments);
        Test.StopTest();
        System.assertEquals('You Can Not Delete The Program Enrollment',result.getErrors()[0].getMessage());
    }
}