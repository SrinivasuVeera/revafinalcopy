@isTest
public class ATT_ProfessorDailyView_Ctr_Test 
{
    public static testMethod Void ProfessorDailyMethod()
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
        //objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.ownerid = userinfo.getUserId();
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
        hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('Test Course', objAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        obj_Cour.HardCore_Sub_Type__c = 'Theory';
        obj_Cour.Category__c = 'Hardcore Course';
        obj_Cour.Credits__c = 3;
        obj_Cour.Offered_By_School__c = objAccount.Id;
        obj_Cour.Credit_Hours__c = 20;
        obj_Cour.L_T_P__c = '2:1:0';
        obj_Cour.No_of_IA_s__c = '1';
        //obj_Cour.Maximum_Internal_Marks__c = 70;
        obj_Cour.Maximum_External_Marks__c = 30;
        obj_Cour.Total_Maximum_Marks_IA_External__c = 85;
        Insert obj_Cour;
        
         Id termRecTypeId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
        hed__Term__c obj_Term1 = ATT_TestDataFactory.createTerm('Parent TermName',objAccount.Id, termRecTypeId1);
        obj_Term1.RecordTypeId = termRecTypeId1;
        obj_Term1.hed__Start_Date__c = system.today();
        obj_Term1.hed__End_Date__c = system.today();
        Insert obj_Term1;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
        hed__Term__c obj_Term = ATT_TestDataFactory.createTerm('Test Term',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Parent_Term__c =obj_Term1.id;        
        Insert obj_Term;
        
        hed__Course_Offering__c obj_CourOff =ATT_TestDataFactory.createCourseOffering('Test CourseOffering', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        hed__Course_Enrollment__c obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
        obj_CourEnroll.RecordTypeId= enrollRecTypeId;
        obj_CourEnroll.Section__c = obj_Term.id;
        obj_CourEnroll.External_Id__c = 'Unique';
        obj_CourEnroll.Logisys_External_Id__c = 'Unique2';
        obj_CourEnroll.Semester_ID__c = 'Section A';   
        Insert obj_CourEnroll;
        
        hed__Course_Offering_Schedule__c objcourseSch = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);        
        objcourseSch.Date__c = system.today();
        objcourseSch.Teaching_Method__c ='ICT';
        objcourseSch.Course_Plan_Completed__c ='No';
        objcourseSch.Professor__c = UserInfo.getUserId();
        insert objcourseSch;        
        
        objcourseSch.hed__Start_Time__c = system.now().time();
        objcourseSch.hed__End_Time__c = system.now().time();
        update objcourseSch;        
        
        test.startTest();
        ATT_ProfessorDailyView_Ctr.postforApproval(system.today(),null);
        ATT_ProfessorDailyView_Ctr.getSchedule(system.today()); 
        test.stopTest();
        system.assertEquals(objcourseSch.Teaching_Method__c,'ICT');
    } 
}