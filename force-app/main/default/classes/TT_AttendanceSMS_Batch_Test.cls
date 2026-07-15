@isTest
public class TT_AttendanceSMS_Batch_Test 
{
    public static testMethod void AttendanceSMSBtch()
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
        insert objcon;
        
        Contact objcon1 = ATT_TestDataFactory.createContact('test Contact1');
        objcon1.AccountId = objAcc.id;
        objcon1.Professor_Across_Schools__c = true;
        objcon1.Application_Number__c = '1232';
        objcon1.hed__WorkEmail__c='1232@reva.edu.in';
        objcon1.Email = 'test2@gmail.com';
        objcon1.MobilePhone ='8963210547';
        objcon1.SRN_Number__c='Srni123';
        objcon1.RecordTypeId = ContactRecTypeId;
        objcon1.Nationality__c = 'Indian';
        objcon1.Aadhar_Card_Number__c ='369845632147'; 
        objcon1.PAN_Number__c ='HRAPO4561D';
        objcon1.Father__c = objcon.id;
        insert objcon1;
                
        hed__Course__c obj_Cour = TT_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        string termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();        
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
        
        hed__Course_Offering_Schedule__c objcourseSch = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
        objcourseSch.Date__c = system.today();
        objcourseSch.hed__Start_Time__c =  time.newInstance(5, 20, 20, 50);
        objcourseSch.hed__End_Time__c = time.newInstance(5, 20, 20, 55);
        insert objcourseSch;          
        objcourseSch.hed__Start_Time__c =  time.newInstance(5, 20, 20, 50);
        objcourseSch.hed__End_Time__c = time.newInstance(5, 20, 20, 55);
        update objcourseSch;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        hed__Course_Enrollment__c obj_CourEnroll = TT_TestDataFactory.createCourseEnrollment(objCon1.id, obj_CourOff.Id);
        obj_CourEnroll.RecordTypeId=enrollRecTypeId;
        Insert obj_CourEnroll;        
        
        hed__Attendance_Event__c obj_AttEvent = TT_TestDataFactory.createAttendanceEvent(objcourseSch.id, objcon1.id, obj_CourEnroll.id);
        obj_AttEvent.hed__Attendance_Type__c = 'Absent';
        obj_AttEvent.hed__Date__c = system.today();
        insert obj_AttEvent;
        
        set<id> set_AttdEvtsIds = New set<id>();
        set_AttdEvtsIds.add(obj_AttEvent.id);
        
        SMS_API_Utility.shortMessageWrp shortMsg = New SMS_API_Utility.shortMessageWrp();
        shortMsg.message = 'TestMsg';
        shortMsg.recipient = 'TestRecp';
        shortMsg.dltContentId = 'DLTID001';
        
        List<SMS_API_Utility.shortMessageWrp> listshort = new List<SMS_API_Utility.shortMessageWrp>();
        listshort.add(shortMsg);
        
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        TT_AttendanceSMS_Batch btch = new TT_AttendanceSMS_Batch(set_AttdEvtsIds);
        database.executeBatch(btch);
        Test.stopTest();
        system.assertEquals(obj_AttEvent.Course_Offering_Schedule__c,objcourseSch.Id);        
    }
}