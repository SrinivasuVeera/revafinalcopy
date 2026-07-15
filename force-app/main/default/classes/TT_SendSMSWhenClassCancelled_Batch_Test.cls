@isTest
public class TT_SendSMSWhenClassCancelled_Batch_Test 
{
    public static testMethod void SendClassCancelledSMS_Batch()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();        
        Account objAcc = TT_TestDataFactory.CreateAccount('test acc', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        hed__Course__c obj_Cour = TT_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        obj_Cour.hed__Course_ID__c ='123';
        obj_Cour.L_T_P__c = '3:0:0';
        obj_Cour.Credits__c = 2;
        obj_Cour.Offered_By_School__c = objAcc.Id;
        obj_Cour.Credit_Hours__c = 3.0;
        obj_Cour.Maximum_External_Marks__c = 10;
        obj_Cour.Total_Maximum_Marks_IA_External__c = 100.0;
        Insert obj_Cour;        
       
        
        string termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();        
        hed__Term__c obj_Term = TT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today();
        obj_Term.hed__End_Date__c= system.today();
        Insert obj_Term;
        
        string recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objcon = TT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAcc.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = recordTypeId;
        objcon.Student_Status__c = 'Pursuing';
        objcon.ownerid = userinfo.getUserId();
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        objcon.Active_Section__c = obj_Term.id;
        objcon.school__c =objAcc.id;
        insert objcon;
        
        hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        hed__Course_Offering_Schedule__c objcourseSch = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
        objcourseSch.hed__Start_Time__c =  time.newInstance(5, 20, 20, 50);
        objcourseSch.hed__End_Time__c = time.newInstance(5, 20, 20, 55);
        objcourseSch.Date__c = system.today();
        objcourseSch.Batch_Group__c = obj_Term.id;
        objcourseSch.Section__c = obj_Term.id;
        insert objcourseSch;  
        
        SMS_API_Utility.shortMessageWrp shortMsg = New SMS_API_Utility.shortMessageWrp();
        shortMsg.message = 'TestMsg';
        shortMsg.recipient = 'TestRecp';
        shortMsg.dltContentId = 'DLTID001';
        
        List<SMS_API_Utility.shortMessageWrp> listshort = new List<SMS_API_Utility.shortMessageWrp>();
        listshort.add(shortMsg);
        
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        TT_SendSMSWhenClassCancelled_Batch btch = new TT_SendSMSWhenClassCancelled_Batch('school',objAcc.id,string.valueof(system.today()),string.valueof(system.today()),'test');
        database.executeBatch(btch);
        TT_SendSMSWhenClassCancelled_Batch btch1 = new TT_SendSMSWhenClassCancelled_Batch('section',obj_Term.id,string.valueof(system.today()),string.valueof(system.today()),'test');
        database.executeBatch(btch1);
        TT_SendSMSWhenClassCancelled_Batch btch2 = new TT_SendSMSWhenClassCancelled_Batch('university',obj_Term.id,string.valueof(system.today()),string.valueof(system.today()),'test');
        database.executeBatch(btch2);
        TT_SendSMSWhenClassCancelled_Batch btch3 = new TT_SendSMSWhenClassCancelled_Batch('faculty',obj_Term.id,string.valueof(system.today()),string.valueof(system.today()),'test');
        database.executeBatch(btch3);
        TT_SendSMSWhenClassCancelled_Batch btch4 = new TT_SendSMSWhenClassCancelled_Batch('programBatch',obj_Term.id,string.valueof(system.today()),string.valueof(system.today()),'test');
        database.executeBatch(btch4);
        TT_SendSMSWhenClassCancelled_Batch btch5 = new TT_SendSMSWhenClassCancelled_Batch('semester',obj_Term.id,string.valueof(system.today()),string.valueof(system.today()),'test');
        database.executeBatch(btch5);
        Test.stopTest();
        //system.assertEquals(obj_AttEvent.Course_Offering_Schedule__c,objcourseSch.Id);  
    }
    
}