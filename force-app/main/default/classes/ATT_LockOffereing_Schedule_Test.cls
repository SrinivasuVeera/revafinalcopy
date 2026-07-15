@isTest
public class ATT_LockOffereing_Schedule_Test 
{
    public static testMethod Void LockingMethod()
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
        objcon.ownerid = userinfo.getUserId();
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';       
        insert objcon;
        
        hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('Test Course', objAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
        hed__Term__c obj_Term = ATT_TestDataFactory.createTerm('Test Term',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_CourOff =ATT_TestDataFactory.createCourseOffering('Test CourseOffering', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        hed__Course_Enrollment__c obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
        obj_CourEnroll.RecordTypeId= enrollRecTypeId;
        obj_CourEnroll.Section__c = obj_Term.id;
        Insert obj_CourEnroll;
        
        hed__Course_Offering_Schedule__c objcourseSch = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
        objcourseSch.hed__Start_Time__c = system.now().time();
        objcourseSch.hed__End_Time__c = system.now().time();
        objcourseSch.Date__c = system.today().adddays(-2);
        objcourseSch.Teaching_Method__c ='ICT';
        objcourseSch.Course_Plan_Completed__c ='Yes';
        objcourseSch.Status__c ='Scheduled';
        insert objcourseSch;        
        
        test.startTest();
        ATT_LockOffereing_Schedule objsch = new ATT_LockOffereing_Schedule();
        String Sch = '0 0 * * * ?';
        system.schedule('lock offering',Sch, objsch);
        test.stoptest();
        system.assertEquals('Scheduled', objcourseSch.Status__c);
    }
}