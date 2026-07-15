@isTest
public class TT_AllocationReplicationCtr_Test 
{    
    @isTest
    public static void AllocationMethod()
    {    
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = TT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Id termRecTypeId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
        hed__Term__c obj_Term1 = TT_TestDataFactory.createTerm('Parent TermName',objAccount.Id, termRecTypeId1);
        obj_Term1.RecordTypeId = termRecTypeId1;
        obj_Term1.hed__Start_Date__c = system.today();
        obj_Term1.hed__End_Date__c = system.today()+2;
        obj_Term1.IA_1_Start_date__c = system.today();
        obj_Term1.IA_1_End_date__c = system.today();
        obj_Term1.IA_2_Start_date__c = system.today();
        obj_Term1.IA_2_End_date__c = system.today();
        Insert obj_Term1;
        
        List<ID> lst_ids = new list<ID>();        
        lst_ids.add(obj_Term1.Id);
        test.starttest();
        TT_AllocationReplicationSemCls ttAllBatch = new TT_AllocationReplicationSemCls(obj_Term1.Id);
        TT_AllocationReplicationCtr.replicateSchedule(lst_ids);
        database.executeBatch(ttAllBatch);
        test.stoptest();
    }
}