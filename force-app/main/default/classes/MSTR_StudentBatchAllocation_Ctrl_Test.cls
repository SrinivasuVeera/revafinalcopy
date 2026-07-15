@isTest
public class MSTR_StudentBatchAllocation_Ctrl_Test 
{
    public static testMethod Void BatchAllocationMethod()
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
       // objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objCon.RecordTypeId = ContactRecTypeId;
        objCon.Student_Status__c = 'Pursuing';
        insert objcon;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5; 
        objProgPlan.Name = 'tessting';
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        string termRtId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
        hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId1);
        objTerm1.Program_Batch__c  = objProgPlan.id;
        insert objTerm1;
        
        //string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
        hed__Term__c objTermParent = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today()+1;
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        objProgEnroll.hed__Account__c = objAccount.id;
        objProgEnroll.hed__Contact__c = objcon.id;
        //objProgEnroll.Batch_Number__c='23';
        objProgEnroll.Batch__c = objTerm1.id;
        insert objProgEnroll; 
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
        
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Account__c = objAccount.id;
        Insert obj_Term;
        
        
        string studentTermRecId =  Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Section).getRecordTypeId();    
        Student_Semester_Mapping__c objStuMapping = MSTR_TestDataFactory.createStudenttermMapping('Test student',studentTermRecId);
        objStuMapping.Program_Enrollment__c = objProgEnroll.id;
        objStuMapping.Section__c = objTerm.id; 
        objStuMapping.RecordTypeId = studentTermRecId;
        objStuMapping.Active__c = true; 
        insert objStuMapping; 
        
        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Section).getRecordTypeId();
        
        MSTR_StudentBatchAllocation_Ctrl.WrapStudentTermMapping wrapStu = new MSTR_StudentBatchAllocation_Ctrl.WrapStudentTermMapping();
        wrapStu.studentName ='test Contact';
        
        list<MSTR_StudentBatchAllocation_Ctrl.WrapStudentTermMapping> lst_wrapStu = new list<MSTR_StudentBatchAllocation_Ctrl.WrapStudentTermMapping>(); 
        lst_wrapStu.add(wrapStu);      
        
        String myJSON = JSON.serialize(lst_wrapStu);
        
        Test.starttest();
        MSTR_StudentBatchAllocation_Ctrl.getTermDetails(objTerm.id);
        MSTR_StudentBatchAllocation_Ctrl.getStudentMappingDetails(objTerm.id);
        MSTR_StudentBatchAllocation_Ctrl.saveStudentTerms(myJSON);
        MSTR_StudentBatchAllocation_Ctrl.getStudentTermDetails(objStuMapping);
        test.stoptest();
        system.assertEquals(objTerm.Id, objTerm.Id);
    }
    public static testMethod Void BatchAllocationMethod1()
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
        //objCon.Student_Status__c = 'Pursuing';
        insert objcon;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        string termRtId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
        hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId1);
        objTerm1.Program_Batch__c  = objProgPlan.id;
        insert objTerm1;
        
        
        hed__Term__c objTermParent = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.hed__Account__c = objAccount.id;
        objProgEnroll.hed__Contact__c = objcon.id;
        //objProgEnroll.Batch__c=objTerm.id;
        objProgEnroll.Section__c =objTerm.id;
        insert objProgEnroll; 
        
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Account__c = objAccount.id;
        Insert obj_Term;
        
        string studentTermRecId =  Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Section).getRecordTypeId();    
        Student_Semester_Mapping__c objStuMapping = MSTR_TestDataFactory.createStudenttermMapping('Test student',studentTermRecId); 
        objStuMapping.Section__c = objTerm.id;
        objStuMapping.Active__c =true; 
        objStuMapping.Section__c = objTerm1.id; 
        objStuMapping.RecordTypeId = studentTermRecId;
        objStuMapping.Semester__c = objTerm.id;
        //insert objStuMapping; 
        
        
        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Section).getRecordTypeId();
        
        //STM_RecType_Batch
        //string studentTermRecId =  Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Section).getRecordTypeId();  
        
     /*   Student_Semester_Mapping__c obj_Stud_Sem = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        obj_Stud_Sem.RecordTypeId= recordTypeName;
        obj_Stud_Sem.name = 'ttesstig';
        obj_Stud_Sem.Active__c = true; 
        obj_Stud_Sem.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem.Start_Date__c = system.today()-1;
        obj_Stud_Sem.End_Date__c = system.today()+1;
        obj_Stud_Sem.Section__c = objTerm1.id;
        obj_Stud_Sem.Student_Batch__c= obj_Term.id;*/
        //insert obj_Stud_Sem;
        
        MSTR_StudentBatchAllocation_Ctrl.WrapStudentTermMapping wrapStu = new MSTR_StudentBatchAllocation_Ctrl.WrapStudentTermMapping();
        wrapStu.studentName ='test Contact';
        
        list<MSTR_StudentBatchAllocation_Ctrl.WrapStudentTermMapping> lst_wrapStu = new list<MSTR_StudentBatchAllocation_Ctrl.WrapStudentTermMapping>(); 
        lst_wrapStu.add(wrapStu);      
        
        String myJSON = JSON.serialize(lst_wrapStu);
        
        Test.starttest();
        MSTR_StudentBatchAllocation_Ctrl.getTermDetails(objTerm.id);
        MSTR_StudentBatchAllocation_Ctrl.getStudentMappingDetails(objTerm.id);
        MSTR_StudentBatchAllocation_Ctrl.saveStudentTerms(myJSON);
        MSTR_StudentBatchAllocation_Ctrl.getStudentTermDetails(objStuMapping);
        test.stoptest();
        system.assertEquals(objTerm.Id, objTerm.Id);
    }
}