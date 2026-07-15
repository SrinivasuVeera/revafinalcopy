@Istest
public class MSTR_MappingSTMtoProgmEnroll_Batch_Test 
{
    public static testMethod Void MappingSTMtoProgmEnroll()
    {
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household ).getRecordTypeId();        
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId);
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.Accountid = objAccount.id;
        objcon.Accountid = objAccount1.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        //objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objCon.RecordTypeId = ContactRecTypeId;
        insert objcon;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        string termRtId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
        hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId1);
        objTerm1.Program_Batch__c  = objProgPlan.id;
        insert objTerm1;
        
         string termRtId2 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm2 = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId2);
        objTerm2.Program_Batch__c  = objProgPlan.id;
        insert objTerm2;
                
        hed__Term__c objTermParent = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';  
        objProgEnroll.Section__c = objTerm.id;
        objProgEnroll.Batch__c = objTerm1.id;
        insert objProgEnroll; 
        
        string studentTermRecId =  Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Section).getRecordTypeId();    
        Student_Semester_Mapping__c objStuMapping = MSTR_TestDataFactory.createStudenttermMapping('Test student',studentTermRecId); 
        objStuMapping.Active__c = True;
        objStuMapping.Mapped_to_Program_Enrollment__c = false;
        objStuMapping.Program_Enrollment__c = objProgEnroll.id;
        objStuMapping.Section__c=objTerm2.id;
       
        insert objStuMapping;
        
        
         string studentTermRecId1 =  Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();    
        Student_Semester_Mapping__c objStuMapping1 = MSTR_TestDataFactory.createStudenttermMapping('Test student',studentTermRecId1); 
        objStuMapping1.Active__c = True;
        objStuMapping1.Mapped_to_Program_Enrollment__c = false;
        objStuMapping1.Program_Enrollment__c = objProgEnroll.id;
         objStuMapping1.Student_Batch__c = objTerm1.id;
        //objStuMapping1.Section__c=objTerm1.id;
        insert objStuMapping1;                 
        
        test.starttest();
        Set<Id> set_STMIds = new Set<Id>();
        set_STMIds.add(objStuMapping1.Id);
        MSTR_MappingSTMtoProgmEnroll_Batch btch = new MSTR_MappingSTMtoProgmEnroll_Batch(set_STMIds);
        database.executebatch(btch);
        test.stoptest();       
        system.assertEquals(objProgEnroll.Id, objProgEnroll.Id);
    }
}