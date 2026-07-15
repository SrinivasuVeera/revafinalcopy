@isTest
public class NPF_DocumentCreationUsingURL_Test {

    public static  testmethod void StudentFeeMethod()
    {
        string houseHoldRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
        objAcc.Recordtypeid = houseHoldRecType;
        Insert objAcc;
        
        string studRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objCon = STOB_TestDataFactory.createContact('Test');
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.AccountId = objAcc.Id;
        objCon.RecordTypeId = studRecordType;
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
                             
        string recordTpId =  Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get(Utility.Educ_History_Object_RecType_Edu_Details).getRecordTypeId(); 
        hed__Education_History__c objHedEducation = STOB_TestDataFactory.createEducationHistory(objCon.Id);
        objHedEducation.hed__Contact__c = objCon.Id;
        objHedEducation.RecordTypeId = recordTpId;
        objHedEducation.Mandatory_for_SRN_Generation__c =true;
        objHedEducation.Data__c = true;
        objHedEducation.Board__c = 'IGSE Board';
        objHedEducation.File_Url__c = 'https://97-s16.nopaperforms.in/uploads/student/document/97/2228/2022/05/28/62919d4d9737f211514290_IMG_30011.JPG';
        Insert objHedEducation;       

        List<hed__Education_History__c> lst_Educa = new List<hed__Education_History__c>();
        lst_Educa.add(objHedEducation);
        Test.startTest();
        NPF_DocumentCreationUsingURL.CreateFile(lst_Educa);
        Test.stopTest();
        
        System.assertEquals(objHedEducation.RecordTypeId, recordTpId);
         
    }
}