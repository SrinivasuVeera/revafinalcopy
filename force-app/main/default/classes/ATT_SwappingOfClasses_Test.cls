@isTest
public class ATT_SwappingOfClasses_Test 
{
    public static Testmethod Void SwapMethod()
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
        objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
        hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('CourseName', objAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        obj_Cour.Category__c ='Hardcore Course';
        obj_Cour.HardCore_Sub_Type__c = 'Theory';
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();        
        hed__Term__c obj_Term = ATT_TestDataFactory.createTerm('TermName',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_CourOff =ATT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        hed__Course_Enrollment__c obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
        obj_CourEnroll.RecordTypeId= enrollRecTypeId;
        obj_CourEnroll.Section__c = obj_Term.id;
        Insert obj_CourEnroll;
        
        hed__Course_Offering_Schedule__c objcourseSch = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
        objcourseSch.Date__c = system.today();
        objcourseSch.Teaching_Method__c ='ICT';
        objcourseSch.Course_Plan_Completed__c ='No';
        insert objcourseSch;
        
        objcourseSch.hed__Start_Time__c =  time.newInstance(5, 20, 20, 50);
        objcourseSch.hed__End_Time__c =  time.newInstance(5, 20, 20, 50);
        update objcourseSch;
        
        test.startTest();
        ATT_SwappingOfClasses.DisplaySemesterRecords();
        ATT_SwappingOfClasses.DisplayCourseOffering(obj_Term.id);
        ATT_SwappingOfClasses.SavingSwappingRecords(objcourseSch.id,objcourseSch.id);
        test.stoptest();
        system.assertequals(objcourseSch.Section__c,obj_Term.id);
    }
    public static Testmethod Void SwapMethod1()
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
        objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1]; 
        User usr = new User(Alias = 'test', Email='testuser12@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testuser12@testorg.com');
        insert usr ;
        System.runAs(usr)
        {
            objcon.ownerId = usr.id;
            update objcon;
        }
        
        hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('CourseName', objAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        obj_Cour.Category__c ='Hardcore Course';
        obj_Cour.HardCore_Sub_Type__c = 'Theory';
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();        
        hed__Term__c obj_Term = ATT_TestDataFactory.createTerm('TermName',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_CourOff =ATT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();        
        hed__Course_Enrollment__c obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
        obj_CourEnroll.RecordTypeId= enrollRecTypeId;
        obj_CourEnroll.Section__c = obj_Term.id;
        Insert obj_CourEnroll;
        
        hed__Course_Offering_Schedule__c objcourseSch = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
        objcourseSch.Date__c = system.today();
        insert objcourseSch;
        
        objcourseSch.hed__Start_Time__c =  time.newInstance(5, 20, 20, 50);
        objcourseSch.hed__End_Time__c =  time.newInstance(5, 20, 20, 50);
        update objcourseSch;        
        
        test.startTest();
        ATT_SwappingOfClasses.DisplaySwappingRecords(obj_Term.id, objcourseSch.id);
        test.stoptest();
        system.assertequals(objcourseSch.Section__c,obj_Term.id);
    }
}