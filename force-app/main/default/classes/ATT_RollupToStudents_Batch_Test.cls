@Istest
public class ATT_RollupToStudents_Batch_Test 
{
    public static Testmethod Void RollupToStudents()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
        Account objAcc = ATT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = ATT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAcc.id;
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
        
        hed__Course__c obj_Cour = ASM_TestDataFactory.CreateCourse(1, objAcc.Id, 'Hardcore Integrated Course');
        Insert obj_Cour;
        
        string termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();        
        hed__Term__c obj_Term = ATT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today();
        obj_Term.hed__End_Date__c= system.today();
        Insert obj_Term;
        
        hed__Term__c objTermParent = ATT_TestDataFactory.createTerm('test term',objAcc.id,termRecTypeId);
        objTermParent.hed__Parent_Term__c = obj_Term.id;
        insert objTermParent;
        
        hed__Course_Offering__c obj_CourOff =ASM_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        hed__Course_Offering_Schedule__c objcourseSch = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
        objcourseSch.Date__c = system.today();
        insert objcourseSch;          
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        hed__Course_Enrollment__c obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(objCon.id, obj_CourOff.Id);
        obj_CourEnroll.RecordTypeId=enrollRecTypeId;
        Insert obj_CourEnroll;        
        
        hed__Attendance_Event__c obj_AttEvent = ATT_TestDataFactory.createAttendanceEvent(objcourseSch.id, objCon.id, obj_CourEnroll.id);
        insert obj_AttEvent;
        
        Test.startTest();
        ATT_RollupToStudents_Batch btch = new ATT_RollupToStudents_Batch();
        database.executeBatch(btch);
        Test.stopTest();
        system.assertEquals(obj_AttEvent.Course_Offering_Schedule__c,objcourseSch.Id);        
    }
}