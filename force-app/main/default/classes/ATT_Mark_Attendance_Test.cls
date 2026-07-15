@isTest
public class ATT_Mark_Attendance_Test 
{
    public static testMethod Void MarkAttMethod()
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
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Student_Status__c = 'Pursuing';
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
        hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('CourseName', objAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        obj_Cour.Category__c ='Hardcore Course';
        obj_Cour.L_T_P__c = '0:0:0';
        obj_Cour.Credits__c = 3;
        obj_Cour.Credit_Hours__c = 3.0;
        obj_Cour.Maximum_External_Marks__c = 23;
        obj_Cour.Total_Maximum_Marks_IA_External__c = 5;
        obj_Cour.No_of_IA_s__c = '2';
        obj_Cour.HardCore_Sub_Type__c = 'Theory';
        obj_Cour.Offered_By_School__c = objAccount.id; 
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
        
        hed__Attendance_Event__c objAttEvent = ATT_TestDataFactory.createAttendanceEvent(objcourseSch.id,ObjCon.id,obj_CourEnroll.id);
        insert objAttEvent;
        
        Proxy_Attendance__c objproxy = ATT_TestDataFactory.CreateProxyAttendance(objCon.id);
        objproxy.Date_To__c = Datetime.now();
        insert objproxy;
        
        ATT_Mark_Attendance.studentWarp stuwrap = new ATT_Mark_Attendance.studentWarp();
        stuwrap.checkBox =true;
        stuwrap.enrollId = obj_CourEnroll.id;
        stuwrap.contId = ObjCon.id;
        
        list<ATT_Mark_Attendance.studentWarp> lst_stuwrap = new list<ATT_Mark_Attendance.studentWarp>();
        lst_stuwrap.add(stuwrap);
        
        List<ContentDocumentLink> lst_CondocLink = New List<ContentDocumentLink>();
        List<ContentVersion> lst_Contnvrsn = New List<ContentVersion>();
        
        ContentVersion objContVrsn = New ContentVersion();
        objContVrsn.title = 'Test';
        objContVrsn.PathOnClient = objContVrsn.Title + '.snote';
        objContVrsn.VersionData = Blob.valueof('this is a test');
        objContVrsn.FirstPublishLocationId = obj_CourOff.Id;
        
        lst_Contnvrsn.add(objContVrsn);
        Insert objContVrsn;
        
        List<ContentDocument> lst_Documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Id =: objcourseSch.Id];        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        if(!lst_Documents.isEmpty())
        {
            contentlink.ShareType= 'C';
            contentlink.LinkedEntityId = obj_CourOff.Id;
            contentlink.ContentDocumentId = lst_Documents[0].Id;
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;          
        }        
        lst_CondocLink.add(contentlink); 
        
        Course_Plan_Unit__c objcourseUnit = TT_TestDataFactory.createCoursePlanUnit('Test Course Plan Unit',obj_CourOff.Id,obj_Cour.Id);
        insert objcourseUnit;
        
        Course_Plan_Topic__c obj_CoursePlanTopic = TT_TestDataFactory.createCoursePlanTopic('Course Plan',objcourseUnit.Id);
        obj_CoursePlanTopic.Course_Plan_Unit__c  = objcourseUnit.Id;
        Insert obj_CoursePlanTopic;
        
        test.starttest();
        ATT_Mark_Attendance.getCOSDetails(objcourseSch.id);
        ATT_Mark_Attendance.getAttachment(objcourseSch.id);
        ATT_Mark_Attendance.getpreviousDetails(objcourseSch.id,true);       
        ATT_Mark_Attendance.getProxyList(system.now(),system.now());
        ATT_Mark_Attendance.saveAttendance(objcourseSch.id,'ICT','Yes','Test Reason',lst_stuwrap,null,null,obj_CoursePlanTopic.id);
        ATT_Mark_Attendance.getStudentDetails(objcourseSch.id); 
        test.stoptest();
        system.assertEquals(objcourseSch.Teaching_Method__c,'ICT');        
    }
}