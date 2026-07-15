@IsTEst
public class MSTR_UpdateCourConSRN_Batch_Test 
{
	public static testmethod void UpdateCourse()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.FirstName  = 'Test Contact';
        objcon.LastName  ='C';
        objcon.Employee_Number__c ='EP1237';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Active__c = true;
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Student_Status__c ='Pursuing';
        objcon.SRN_Number__c ='SRN123';
        insert objcon;
        
        List<Contact> list_Con = new List<Contact>();
        list_Con.add(objcon);
        
        objcon.SRN_Number__c ='SRN1234';
        update objcon;
        
        ContactHistory conHis =  new ContactHistory();
        conHis.ContactId = objcon.Id;
        conHis.Field = 'SRN_Number__c';
        Insert conHis;
                
        List<ContactHistory> list_ConHistory = new List<ContactHistory>();
        list_ConHistory.add(conHis);
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
        objCourse.Category__c = 'Hardcore Course';
        objCourse.HardCore_Sub_Type__c = 'Theory';
        insert objCourse; 
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        insert objCourseOff1;
        
        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'Open Elective';
        objCourseOff.Sequence__c =1;
        objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
        objCourseOff.Active__c =true;
        objCourseOff.Assigned__c = 2;
        insert objCourseOff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Course_Enrollment__c obj_CourEnroll = MSTR_TestDataFactory.createCourseEnrollment(objCon.id, objCourseOff.Id);
        obj_CourEnroll.RecordTypeId=enrollRecTypeId;
        obj_CourEnroll.Section__c = objTerm.id;
        obj_CourEnroll.Semester_ID__c = objTerm.Id;
        Insert obj_CourEnroll;
        
        Test.startTest();
        MSTR_UpdateCourseConnectionSRN_Batch Btch = new MSTR_UpdateCourseConnectionSRN_Batch();
        Database.executeBatch(Btch);
        Test.stopTest();
        system.assertEquals(objCourseOff.Assigned__c,2);
    }
}