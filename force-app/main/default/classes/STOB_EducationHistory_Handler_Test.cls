@isTest
public class STOB_EducationHistory_Handler_Test 
{
    public static testMethod Void Method()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
        objAcc.Recordtypeid = UniversityRecId;
        Insert objAcc;
            
        Contact objCon = STOB_TestDataFactory.createContact('Test');
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.AccountId = objAcc.Id;
        Insert objCon;
        
        hed__Program_Plan__c objProgplan = STOB_TestDataFactory.createProgramPlan('Prog Plan');
        Insert objProgplan;
        
        hed__Program_Enrollment__c objProgEnrlmt = STOB_TestDataFactory.createprogramEnrollment(objProgplan.Id);
        objProgEnrlmt.hed__Account__c=objAcc.id;
        objProgEnrlmt.hed__Contact__c=objCon.id;
        objProgEnrlmt.hed__Eligible_to_Enroll__c=true;
        objProgEnrlmt.hed__Start_Date__c = system.today().addDays(-1);
        objProgEnrlmt.hed__End_Date__c = system.today().addDays(1);
        insert objProgEnrlmt;
                             
        hed__Education_History__c objHedEducation = STOB_TestDataFactory.createEducationHistory(objCon.Id);
        objHedEducation.hed__Contact__c = objCon.Id;
        objHedEducation.Mandatory_for_SRN_Generation__c =true;
        objHedEducation.Data__c = true;
        Insert objHedEducation;       
        
        objHedEducation.hed__Verification_Status__c='Approved';
        update objHedEducation;
        
        list<hed__Education_History__c> lst_EduHst = new list<hed__Education_History__c>();
        lst_EduHst.add(objHedEducation);

        Test.startTest();
        STOB_EducationHistory_Handler.updatePrgmEnrlmtStatus(lst_EduHst,null);
        Test.stopTest();
        
        System.assertEquals(objHedEducation.hed__Verification_Status__c, 'Approved');
    }
}