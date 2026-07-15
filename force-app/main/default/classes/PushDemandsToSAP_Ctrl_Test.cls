@isTest
public class PushDemandsToSAP_Ctrl_Test 
{
    @isTest
    public static void PushDemandsToSAP()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ATT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = ATT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.ownerid = userinfo.getUserId();
        objcon.Nationality__c = 'Indian';
        objcon.Student_Status__c = 'Pursuing';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
        set<id> set_contIds = new set <id>();
        set_contIds.add(objcon.id);
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        objProgEnroll.hed__Contact__c = objcon.id;
        insert objProgEnroll; 
        
       
        
        List<hed__Program_Enrollment__c> lst_progrma_Enroll = new List<hed__Program_Enrollment__c>();
        lst_progrma_Enroll.add(objProgEnroll);
        
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'University Fee');       //'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=10000;
        objStudentFee1.Amount_Paid__c=50000;
        objStudentFee1.Fee_Year__c = '1st Year';
        objStudentFee1.Contact__c = objCon.id;
        objStudentFee1.Due_Date__c = system.today() - 1;
        objStudentFee1.Fee_Type__c = 'University Fee';
        objStudentFee1.Integrated_with_SAP__c = true;
        objStudentFee1.Program_Enrollment__c = objProgEnroll.id;
        Insert objStudentFee1;
        
    
        
        String ClassName = 'SAP_DemandAPI_Batch';

        List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors,ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name=:ClassName];
        
        Test.startTest();
        
        SAP_ReconAPICalloutMock fakeResponse = new SAP_ReconAPICalloutMock(200,'OK','{"StatusMessage":"Success","StatusCode":0,"ResponseData":[{"StatusMessage":"1","StatusCode":0,"SFDCRecordId":"' + objStudentFee1.Id + '","responseObject":"1","ErrorMsg":"Mode of payment Failure","DemandNo":"12347"}]}',null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        PushDemandsToSAP_Ctrl.getProgramPlans();
        SAP_DemandAPI_Batch Batch = new SAP_DemandAPI_Batch(set_contIds,'2022');
        database.executeBatch(Batch);
        PushDemandsToSAP_Ctrl.getProgEnrollNoGRN(objStudentFee1.Program_Enrollment__r.id, '1st Year');
        PushDemandsToSAP_Ctrl.PushDemandsToSAP(lst_progrma_Enroll, objProgPlan.id, '2022');
        PushDemandsToSAP_Ctrl.getProcessPercentage();
        Test.stopTest();
        //system.assertEquals(objcon.Joining_REVA__c,'yes');
    }
     @isTest
    public static void PushDemandsToSAP1()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ATT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = ATT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.ownerid = userinfo.getUserId();
        objcon.Nationality__c = 'Indian';
        objcon.Student_Status__c = 'Pursuing';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
        set<id> set_contIds = new set <id>();
        set_contIds.add(objcon.id);
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        objProgEnroll.hed__Contact__c = objcon.id;
        insert objProgEnroll; 
        
         hed__Program_Enrollment__c objProgEnroll1 = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll1.hed__Start_Date__c = system.today()-1;
        objProgEnroll1.hed__End_Date__c = system.today();
        objProgEnroll1.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll1.Application_Number__c ='123';
        objProgEnroll1.Section__c = objTerm.id;
        objProgEnroll1.hed__Contact__c = objcon.id;
        insert objProgEnroll1; 
        
        List<hed__Program_Enrollment__c> lst_progrma_Enroll = new List<hed__Program_Enrollment__c>();
        lst_progrma_Enroll.add(objProgEnroll);
        
                List<hed__Program_Enrollment__c> lst_progrma_Enroll1 = new List<hed__Program_Enrollment__c>();
        lst_progrma_Enroll1.add(objProgEnroll1);

        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'University Fee');       //'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=10000;
        objStudentFee1.Amount_Paid__c=50000;
        objStudentFee1.Fee_Year__c = '1st Year';
        objStudentFee1.Contact__c = objCon.id;
        objStudentFee1.Due_Date__c = system.today() - 1;
        objStudentFee1.Fee_Type__c = 'University Fee';
        objStudentFee1.Integrated_with_SAP__c = true;
        objStudentFee1.Program_Enrollment__c = objProgEnroll.id;
        Insert objStudentFee1;
        
        // Create a Student_Fee__c record for Tuition Fee
        Student_Fee__c objStudentFeeTuition = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');
        objStudentFeeTuition.Amount__c = 60000;
        objStudentFeeTuition.Amount_Pending__c = 20000;
        objStudentFeeTuition.Amount_Paid__c = 40000;
        objStudentFeeTuition.Fee_Year__c = '1st Year';
        objStudentFeeTuition.Contact__c = objCon.id;
        objStudentFeeTuition.Due_Date__c = system.today() - 1;
        objStudentFeeTuition.Fee_Type__c = 'Tuition Fee';
        objStudentFeeTuition.Integrated_with_SAP__c = true;
        objStudentFeeTuition.Program_Enrollment__c = objProgEnroll.id;
        Insert objStudentFeeTuition;
        
        set<id> setIds = new set<id>();
        setIds.add(objStudentFee1.id);
        
        PushDemandsToSAP_Ctrl.ProgramEnrollementWrap wrap = new PushDemandsToSAP_Ctrl.ProgramEnrollementWrap();
        wrap.lstPrgEnroll = lst_progrma_Enroll;
        wrap.lstPrgEnrollPushedSap = lst_progrma_Enroll1;
        wrap.set_IdToBePused = setIds;
        
        Map<string, Student_Fee__c> map_StudentFee = new Map<string, Student_Fee__c>();
        map_StudentFee.put(objProgEnroll.id+'University Fee', objStudentFee1);
        map_StudentFee.put(objProgEnroll.id+'Tuition Fee', objStudentFeeTuition);
        
        
        List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Status=:'Completed'];
        
        Test.startTest();
        
        SAP_ReconAPICalloutMock fakeResponse = new SAP_ReconAPICalloutMock(200,'OK','{"StatusMessage":"Success","StatusCode":0,"ResponseData":[{"StatusMessage":"1","StatusCode":0,"SFDCRecordId":"' + objStudentFee1.Id + '","responseObject":"1","ErrorMsg":"Mode of payment Failure","DemandNo":"12347"}]}',null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        PushDemandsToSAP_Ctrl.getProgramPlans();
        SAP_DemandAPI_Batch Batch = new SAP_DemandAPI_Batch(set_contIds,'2022');
        database.executeBatch(Batch);
        PushDemandsToSAP_Ctrl.getProgEnrollNoGRN(objProgPlan.id, '1st Year');
        PushDemandsToSAP_Ctrl.PushDemandsToSAP(lst_progrma_Enroll, objProgPlan.id, '2022');
        PushDemandsToSAP_Ctrl.getProcessPercentage();
        Test.stopTest();
        //system.assertEquals(objcon.Joining_REVA__c,'yes');
    }
}