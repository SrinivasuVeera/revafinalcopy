@Istest
public class OE_AllocationCtr_Test 
{ 
    public static testMethod Void AllocationCtr()
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
        insert objcon;
        
        hed__Program_Plan__c objProgPlan = MSTR_TestDataFactory.createProgramPlan('test program plan');
        objProgPlan.hed__Account__c = objAccount.id;
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(3);
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-13; 
        objTerm.hed__End_Date__c =system.today()+5;
        objTerm.Term_Number__c = 2;
        objTerm.RecordTypeId = termRtId;
        //objTerm.Active__c =true;
        insert objTerm;        
        
        string termRtId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test term1',objAccount.id,termRtId1);
        objTerm1.Program_Batch__c  = objProgPlan.id;
        objTerm1.hed__Start_Date__c = system.today()-13; 
        objTerm1.hed__End_Date__c =system.today()+5;
        objTerm1.Term_Number__c = 2;
        objTerm1.RecordTypeId = termRtId1;
        objTerm1.hed__Parent_Term__c = objTerm.id;
        insert objTerm1;
        
        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Name = 'test course';
        objCourse.Category__c = 'Hardcore Course';
        objCourse.HardCore_Sub_Type__c = 'Theory';
        objCourse.Max_Students__c = 05;
        insert objCourse; 
        
        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        objCourseOff1.hed__Course__c = objCourse.id;
         insert objCourseOff1;
        
        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'Open Elective';
        objCourseOff.Sequence__c =1;
        objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
        objCourseOff.Offered_By_School__c = objAccount.id;
        objCourseOff.hed__Term__c = objTerm.Id;
        objCourseOff.hed__Course__c = objCourse.id;
        insert objCourseOff;
        
        Id devRecordTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByDeveloperName().get('Group_Allocation').getRecordTypeId();
        hed__Term__c objTerm2 = MSTR_TestDataFactory.createTerm('test term1',objAccount.id,devRecordTypeId);
        objTerm2.Program_Batch__c  = objProgPlan.id;
        objTerm2.hed__Start_Date__c = system.today()-13; 
        objTerm2.hed__End_Date__c =system.today()+5;
        objTerm2.Term_Number__c = 2;
        objTerm2.Course_Offering__c = objCourseOff.id;
        objTerm2.RecordTypeId = devRecordTypeId;
        objTerm2.hed__Parent_Term__c = objTerm.id;
        objTerm2.hed__Account__c= objAccount.id;
        insert objTerm2;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        hed__Course_Enrollment__c obj_CourseEnroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, objCourseOff.Id);
        obj_CourseEnroll.RecordTypeId=enrollRecTypeId;
        obj_CourseEnroll.Semester_ID__c = objTerm.id;
        Insert obj_CourseEnroll;
        
        Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOff.id,objTerm.id);
        objProfStuOE.Contact__c = objcon.id;
        objProfStuOE.Student_Preference__c = true;
        objProfStuOE.Preference__c = '1';
        insert objProfStuOE;   
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id; 
        insert objProgEnroll;
        
        OE_AllocationCtr.StudentPrefListWrp objAll= new OE_AllocationCtr.StudentPrefListWrp(true,true,objProfStuOE.id,objcon.id,1,'testname','srnnum','testsec','cours'); 
        OE_AllocationCtr.StudentPrefListWrp objAll1 = new OE_AllocationCtr.StudentPrefListWrp(true,objTerm.id,obj_CourseEnroll.Id, objcon.id, 1, 'stud1', 'srn123', 'section1');
        OE_AllocationCtr.EachOEoptionWrp  objEach = new OE_AllocationCtr.EachOEoptionWrp('key', 'value');
        
        list< OE_AllocationCtr.StudentPrefListWrp> list_All = new list< OE_AllocationCtr.StudentPrefListWrp>();
        list_All.add(objAll1); 
        
        list< OE_AllocationCtr.StudentPrefListWrp> list_All1 = new list< OE_AllocationCtr.StudentPrefListWrp>();
        list_All1.add(objAll);
        
        list< OE_AllocationCtr.EachOEoptionWrp> list_Each = new  list< OE_AllocationCtr.EachOEoptionWrp>();
        list_Each.add(objEach);
        
        OE_AllocationCtr.AllOEStudentPrefWrp objAllStu = new OE_AllocationCtr.AllOEStudentPrefWrp(objCourse.id,'courseName',list_All,new set<string>{'sem'});
        
        OE_AllocationCtr.AllOEStudentPrefWrp objAllStu1 = new OE_AllocationCtr.AllOEStudentPrefWrp(objCourse.id,'courseName',list_All1,new set<string>{'sem'});
        
        
        set<OE_AllocationCtr.AllOEStudentPrefWrp> set_All = new  set<OE_AllocationCtr.AllOEStudentPrefWrp>();
        set_All.add(objAllStu);
        
        //OE_AllocationCtr.AllOEStudentPrefWrp objAllo = new OE_AllocationCtr.AllOEStudentPrefWrp(objCourse.Id,'test',list_All); 
        
        //OE_AllocationCtr.AllOEStudentPrefWrp objAl1 = new OE_AllocationCtr.AllOEStudentPrefWrp(objCourse.Id,'test',list_All1); 
        
        
        
        list<OE_AllocationCtr.AllOEStudentPrefWrp> list_Allocwrp = new  list< OE_AllocationCtr.AllOEStudentPrefWrp>();
        list_Allocwrp.add(objAllStu);
        
        string KRAJsonRating=Json.serialize(new list<OE_AllocationCtr.AllOEStudentPrefWrp>{objAllStu});
        string KRAJsonRating1=Json.serialize(new list<OE_AllocationCtr.AllOEStudentPrefWrp>{objAllStu1});
        
        test.starttest();
        OE_AllocationCtr.fetchOEOfferings('2', false);
        OE_AllocationCtr.getStudentPrefBySubj('2', false); 
        OE_AllocationCtr.fetchexistingTerms(objCourseOff.Id, '2');
        OE_AllocationCtr.createTermGroups(objCourseOff.Id, 1, '2');
        OE_AllocationCtr.deleteGroupCtr(objCourse.Id, '2','test term1');
        OE_AllocationCtr.fetchConnectionGroups('test course','2', 1);
        OE_AllocationCtr.saveGroupChangeConnection(KRAJsonRating, objCourseOff.Id);
        OE_AllocationCtr.saveGroupChangeConnection(KRAJsonRating, objCourseOff.Id);
        OE_AllocationCtr.getNextChar('str');
        OE_AllocationCtr.saveCourseConnection(KRAJsonRating1);
       
        test.stoptest();
        system.assertEquals(objProfStuOE.Student_Preference__c,true);
    }
}