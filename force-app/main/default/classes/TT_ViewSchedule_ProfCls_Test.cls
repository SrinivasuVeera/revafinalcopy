@Istest
public class TT_ViewSchedule_ProfCls_Test 
{
    Public static testmethod Void SectionMethod()
    {       
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
        Account objAcc = TT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = TT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAcc.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.ownerid = userinfo.getUserId();
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        objcon.OwnerId = userinfo.getuserid();
        insert objcon;
        
        hed__Course__c obj_Cour = TT_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        string termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();        
        hed__Term__c obj_Term = TT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today();
        obj_Term.hed__End_Date__c= system.today();
        Insert obj_Term;
        
        hed__Term__c objTermParent = TT_TestDataFactory.createTerm('test term',objAcc.id,termRecTypeId);
        objTermParent.hed__Parent_Term__c = obj_Term.id;
        insert objTermParent;
        
        hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        hed__Course_Enrollment__c obj_CourEnroll = TT_TestDataFactory.createCourseEnrollment(objCon.id, obj_CourOff.Id);
        obj_CourEnroll.RecordTypeId=enrollRecTypeId;
        obj_CourEnroll.Section__c = objTermParent.id;
        Insert obj_CourEnroll;
        
        hed__Course_Offering_Schedule__c objcourseSch = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
        objcourseSch.Date__c = system.today();
        objcourseSch.hed__Start_Time__c = system.now().time();
        objcourseSch.hed__End_Time__c = system.now().time();
        insert objcourseSch; 
        
        objcourseSch.hed__Start_Time__c = system.now().time();
        objcourseSch.hed__End_Time__c = system.now().time();
        update objcourseSch; 
        
        TT_ViewSchedule_ProfCls.ScheduleWrp swrap = new TT_ViewSchedule_ProfCls.ScheduleWrp();
        swrap.schDate =objcourseSch.Date__c;
        swrap.schId =objcourseSch.id;
        swrap.slotNum =2;
        swrap.timeSlot ='12';
        swrap.programName =objAcc.Name;
        swrap.semNumber =7;
        swrap.secName ='test section';
        swrap.groupName ='test group';
        swrap.courseName='test course'; 
        swrap.schstatus='Scheduled'; 
        
        list<TT_ViewSchedule_ProfCls.ScheduleWrp> lst_swrap = new list<TT_ViewSchedule_ProfCls.ScheduleWrp>();
        lst_swrap.add(swrap);
        test.startTest();
        TT_ViewSchedule_ProfCls.getSchedule(system.today());   
        test.stopTest();
        system.assertEquals(system.today(), objcourseSch.Date__c);
    }  
}