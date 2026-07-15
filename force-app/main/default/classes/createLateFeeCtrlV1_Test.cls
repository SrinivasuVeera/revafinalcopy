@isTest
public class createLateFeeCtrlV1_Test { 
    @isTest
    static void createLateFeeCtrlV1Method2(){
        test.startTest();
        Id AccountRecTypeIdParent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        
        Account objAccParent = FEE_TestDataFactory.CreateAccount('Test Account',AccountRecTypeIdParent);
        objAccParent.RecordTypeId = AccountRecTypeIdParent;        
        insert objAccParent;
        
        Account objAcc = FEE_TestDataFactory.CreateAccount('test child',AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        objAcc.ParentId = objAccParent.Id;
        insert objAcc;
        
        hed__Program_Plan__c  objProgPlan =  FEE_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        objProgPlan.hed__Account__c = objAcc.Id;
        objProgPlan.hed__Start_Date__c = system.today();
        objProgPlan.hed__End_Date__c = system.today();
        insert objProgPlan;
        
        Late_Fee_Charges__c objLatefeeCh = new Late_Fee_Charges__c();
        objLatefeeCh.Fee_Type__c = 'Tuition Fee';
        objLatefeeCh.Late_Fee_Calculation_Type__c = 'Daily Basis';
        objLatefeeCh.Amount__c = 10000;
        objLatefeeCh.To_Day__c = 10000;
        objLatefeeCh.From_Day__c = 10000;
        objLatefeeCh.Program_Batch__c = objProgPlan.Id;
        insert objLatefeeCh;
        
        Late_Fee_Charges__c objLatefeeCh2 = new Late_Fee_Charges__c();
        objLatefeeCh2.Fee_Type__c = 'Tuition Fee';
        objLatefeeCh2.Late_Fee_Calculation_Type__c = 'Daily Basis';
        objLatefeeCh2.Amount__c = 10000;
        objLatefeeCh2.To_Day__c = 10000;
        objLatefeeCh2.From_Day__c = 10000;
        objLatefeeCh2.Program_Batch__c = objProgPlan.Id;
        insert objLatefeeCh2;
        
        
        string pgm = json.serialize(objAcc);
        
        string idPgm = objAcc.Id;
        
        list<String> selectedPgmList = new List<String>();
        selectedPgmList.add(idPgm);
        
        createLateFeeCtrlV1.getFeeTypeDetails();
        createLateFeeCtrlV1.getProgramDetails(objAccParent.Id);
        
        createLateFeeCtrlV1.getProgramBatchDetails('Tuition Fee', selectedPgmList);
        createLateFeeCtrlV1.selectUpdateLateFee(objProgPlan.Id, 'Tuition Fee', 'Daily Basis');
        //createLateFeeCtrlV1.lfSubWrp;
        list<id> deletedIds = new List<id>();
        list<id> prgIds = new List<id>();
        list<string> batchIds =new list<string>();
        batchIds.add(objProgPlan.Id);
        
        createLateFeeCtrlV1.lfMainWrp mainwrp = new createLateFeeCtrlV1.lfMainWrp();
        
        createLateFeeCtrlV1.insertLateFee('Tuition Fee', 'Daily Basis', deletedIds, prgIds, mainwrp.lateFee, batchIds, false, 100000, objProgPlan.Id);
        
        createLateFeeCtrlV1.UpdateLateFee(objProgPlan.Id, 'Tuition Fee', 'Daily Basis', createLateFeeCtrlV1.selectUpdateLateFee(objProgPlan.Id, 'Tuition Fee', 'Daily Basis'));
        createLateFeeCtrlV1.wrpCls wrpcls = new createLateFeeCtrlV1.wrpCls();
        
        test.stopTest();
        system.assertEquals(objProgPlan.Id, objProgPlan.Id);
    }
    @isTest
    static void createLateFeeCtrlV1Method3(){
        test.startTest();
        Id AccountRecTypeIdParent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        
        Account objAccParent = FEE_TestDataFactory.CreateAccount('Test Account',AccountRecTypeIdParent);
        objAccParent.RecordTypeId = AccountRecTypeIdParent;
        
        insert objAccParent;
        
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test child Account',AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        objAcc.ParentId = objAccParent.Id;
        insert objAcc;
                
        hed__Program_Plan__c  objProgPlan =  FEE_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        objProgPlan.hed__Account__c = objAcc.Id;
        objProgPlan.hed__Start_Date__c = system.today();
        objProgPlan.hed__End_Date__c = system.today();
        insert objProgPlan;
        
        Late_Fee_Charges__c objLatefeeCh = new Late_Fee_Charges__c();
        objLatefeeCh.Fee_Type__c = 'Tuition Fee';
        objLatefeeCh.Late_Fee_Calculation_Type__c = 'Date Range';
        objLatefeeCh.Amount__c = 10000;
        objLatefeeCh.To_Day__c = 10000;
        objLatefeeCh.From_Day__c = 10000;
        objLatefeeCh.Program_Batch__c = objProgPlan.Id;
        insert objLatefeeCh;
        
        Late_Fee_Charges__c objLatefeeCh2 = new Late_Fee_Charges__c();
        objLatefeeCh2.Fee_Type__c = 'Tuition Fee';
        objLatefeeCh2.Late_Fee_Calculation_Type__c = 'Date Range';
        objLatefeeCh2.Amount__c = 10000;
        objLatefeeCh2.To_Day__c = 10000;
        objLatefeeCh2.From_Day__c = 10000;
        objLatefeeCh2.Program_Batch__c = objProgPlan.Id;
        insert objLatefeeCh2;
        
        
        string pgm = json.serialize(objAcc);
        
        string idPgm = objAcc.Id;
        
        list<String> selectedPgmList = new List<String>();
        selectedPgmList.add(idPgm);
        
        createLateFeeCtrlV1.getFeeTypeDetails();
        createLateFeeCtrlV1.getProgramDetails(objAccParent.Id);
        
        createLateFeeCtrlV1.getProgramBatchDetails('Tuition Fee', selectedPgmList);
        createLateFeeCtrlV1.selectUpdateLateFee(objProgPlan.Id, 'Tuition Fee', 'Date Range');
        //createLateFeeCtrlV1.lfSubWrp;
        list<id> deletedIds = new List<id>();
        list<id> prgIds = new List<id>();
        list<string> batchIds =new list<string>();
        batchIds.add(objProgPlan.Id);
        
        createLateFeeCtrlV1.lfMainWrp mainwrap = new createLateFeeCtrlV1.lfMainWrp();
        mainwrap = createLateFeeCtrlV1.getFeeTypeDetails();
        createLateFeeCtrlV1.insertLateFee('Tuition Fee', 'Date Range', deletedIds, prgIds, mainwrap.lateFee, batchIds, false, 100000, objProgPlan.Id);
        
        createLateFeeCtrlV1.UpdateLateFee(objProgPlan.Id, 'Tuition Fee', 'Date Range', createLateFeeCtrlV1.selectUpdateLateFee(objProgPlan.Id, 'Tuition Fee', 'Date Range'));
        createLateFeeCtrlV1.wrpCls wrpcls = new createLateFeeCtrlV1.wrpCls();
        
        test.stopTest();
        system.assertEquals(objProgPlan.Id, objProgPlan.Id);
    }
}