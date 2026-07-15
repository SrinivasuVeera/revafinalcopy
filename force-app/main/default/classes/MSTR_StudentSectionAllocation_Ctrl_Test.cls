@isTest
public class MSTR_StudentSectionAllocation_Ctrl_Test  
{ 
    public static testMethod Void SectionAllocationMethod()
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
        objcon.AccountId= objAccount.id;
        objcon.Accountid = objAccount1.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        //objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objCon.RecordTypeId = ContactRecTypeId;
        objCon.Student_Status__c = 'Pursuing';
        insert objcon;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Name = 'testing';
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Account__c = objAccount.id;
        objTerm.Section_Number__c = 1;
        insert objTerm;
        
        hed__Term__c objTermParent = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        objTermParent.hed__Account__c = objAccount.id;
        objTerm.Section_Number__c = 1;
        insert objTermParent;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
       
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Account__c = objAccount.id;
        obj_Term.Program_Batch__c = objProgPlan.id;
        Insert obj_Term;
        
         
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today()+22;
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123'; 
        objProgEnroll.hed__Contact__c = objcon.id;
        objProgEnroll.hed__Account__c = objAccount.id;
        objProgEnroll.Section__c = obj_Term.id;
        objProgEnroll.Semester__c = objTerm.id;
        insert objProgEnroll; 
       
          
        MSTR_StudentSectionAllocation_Ctrl.ProgramEnrollmentWrp wrapProg = new MSTR_StudentSectionAllocation_Ctrl.ProgramEnrollmentWrp();
        wrapProg.studentName ='test Contact';
        wrapProg.progEnrollId = objProgEnroll.id;
        wrapProg.appNumber = objProgEnroll.Application_Number__c;
        
        list<MSTR_StudentSectionAllocation_Ctrl.ProgramEnrollmentWrp> lst_wrapProg = new list<MSTR_StudentSectionAllocation_Ctrl.ProgramEnrollmentWrp>(); 
        lst_wrapProg.add(wrapProg);      
        
        String myJSON = JSON.serialize(lst_wrapProg);
        
        Test.starttest();
        MSTR_StudentSectionAllocation_Ctrl.getTermDetails(objTerm.id);
        MSTR_StudentSectionAllocation_Ctrl.createStudTermSection(myJSON ,objTerm);
        MSTR_StudentSectionAllocation_Ctrl.getProgEnrollDetails(objProgEnroll);
        test.stoptest();
        system.assertEquals(objTerm.Id, objTerm.Id);
    }
    public static testMethod Void SectionAllocationMethod1()
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
        objcon.Accountid  = objAccount.id;
        objcon.Accountid = objAccount1.id;
        objCon.RecordTypeId = ContactRecTypeId;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        //objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objCon.Student_Status__c = 'Pursuing';
        insert objcon;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.name = 'testing';
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.Actual_Students_Per_Section__c =4;
        insert objTerm;
        
        hed__Term__c objTermParent = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
         Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
       
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Account__c = objAccount.id;
        obj_Term.Program_Batch__c = objProgPlan.id;
        Insert obj_Term;

         
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today()+22;
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Section__c = obj_Term.id;
        objProgEnroll.Semester__c = objTerm.id;
         insert objProgEnroll; 
        
      
        Test.starttest();
        MSTR_StudentSectionAllocation_Ctrl.getTermDetails(objTerm.id);
        MSTR_StudentSectionAllocation_Ctrl.getSectionAndStudents(objTerm,'Alphabetical Order');
        test.stoptest();
        system.assertEquals(objTerm.Id, objTerm.Id);
    }
    public static testMethod Void SRNMethod()
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
        objCon.Student_Status__c = 'Pursuing'; 
        insert objcon;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.name = 'testing';
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        //objProgPlan.Program_Batch_Name__c = 'test';
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.Actual_Students_Per_Section__c = 4;
        insert objTerm;
        
        hed__Term__c objTermParent = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        
         Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
       
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Account__c = objAccount.id;
        obj_Term.Program_Batch__c = objProgPlan.id;
        obj_Term.Section_Number__c = 1;
        Insert obj_Term;

        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today()+1;
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Section__c = obj_Term.id;
        objProgEnroll.Semester__c = objTerm.id;
         insert objProgEnroll; 
         
        
        Test.starttest();
        MSTR_StudentSectionAllocation_Ctrl.getSectionAndStudents(objTerm,'SRN Number');
        test.stoptest();
        system.assertEquals(objTerm.Id, objTerm.Id);
    }
}