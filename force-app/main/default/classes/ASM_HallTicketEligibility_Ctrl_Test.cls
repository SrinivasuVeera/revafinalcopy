@Istest
public class ASM_HallTicketEligibility_Ctrl_Test 
{
    public static Testmethod Void HallTicketEligibility()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-15;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Issue_Hall_Ticket__c = false;
        objProgEnroll.SRN_Number__c = '123';
        objProgEnroll.Pending_Survey__c = 4;
        objProgEnroll.Semester__c =objTerm.id;
        objProgEnroll.hed__Contact__c = ObjCon.id;
        insert objProgEnroll; 
        
        hed__Program_Enrollment__c objPrgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objPrgEnroll.hed__Start_Date__c = system.today()-2;
        objPrgEnroll.hed__End_Date__c = system.today();
        objPrgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objPrgEnroll.Application_Number__c ='1345';
        objPrgEnroll.Issue_Hall_Ticket__c = false;
        objPrgEnroll.SRN_Number__c = 'RE123';
        objPrgEnroll.Pending_Survey__c = 1;
        objPrgEnroll.Semester__c =objTerm.id;
        objPrgEnroll.hed__Contact__c = ObjCon.id;
        insert objPrgEnroll; 
        
        List<hed__Program_Enrollment__c> list_Enroll = New  List<hed__Program_Enrollment__c> ();
        list_Enroll.Add(objProgEnroll);
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Total_Classes_Attended__c = 60;
        obj_Cour_Enroll.Total_Classes_Completed__c =20;
        Insert obj_Cour_Enroll; 
       
        Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Due_Date__c = system.today().addDays(-1);
        objStudentFee.Program_Enrollment__c = objProgEnroll.Id; 
        Insert objStudentFee;
        
        test.startTest();
        ASM_HallTicketEligibility_Ctrl.getProgramBatchDetails();
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(objTerm.Id,'Open Surveys');
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(null,null);
        ASM_HallTicketEligibility_Ctrl.getSemesterDetails(null);
        ASM_HallTicketEligibility_Ctrl.saveStudentsDetails(list_Enroll);
        test.stopTest();
        system.assertEquals(objStudentFee.Amount_Pending__c,2);
    }
    public static Testmethod Void AttendanceShortage()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-15;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Issue_Hall_Ticket__c = false;
        objProgEnroll.SRN_Number__c = '123';
        objProgEnroll.Pending_Survey__c = 0;
        objProgEnroll.Semester__c =objTerm.id;
        objProgEnroll.hed__Contact__c = ObjCon.id;
        insert objProgEnroll; 
        
        List<hed__Program_Enrollment__c> list_Enroll = New  List<hed__Program_Enrollment__c> ();
        list_Enroll.Add(objProgEnroll);
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Total_Classes_Attended__c = 15;
        obj_Cour_Enroll.Total_Classes_Completed__c = 40;
        Insert obj_Cour_Enroll; 
       
        Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Due_Date__c = system.today().addDays(-1);
        objStudentFee.Program_Enrollment__c = objProgEnroll.Id; 
        Insert objStudentFee;
        
        test.startTest();
        ASM_HallTicketEligibility_Ctrl.getProgramBatchDetails();
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(objTerm.Id,'Attendance Shortage');
        ASM_HallTicketEligibility_Ctrl.getSemesterDetails(objProgPlan.id);
        ASM_HallTicketEligibility_Ctrl.saveStudentsDetails(list_Enroll);
        test.stopTest();
        system.assertEquals(objStudentFee.Amount_Pending__c,2);
    }
    public static Testmethod Void PendingFees()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-15;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Issue_Hall_Ticket__c = false;
        objProgEnroll.SRN_Number__c = '123';
        objProgEnroll.Pending_Survey__c = 0;
        objProgEnroll.Semester__c =objTerm.id;
        objProgEnroll.hed__Contact__c = ObjCon.id;
        insert objProgEnroll; 
        
        List<hed__Program_Enrollment__c> list_Enroll = New  List<hed__Program_Enrollment__c> ();
        list_Enroll.Add(objProgEnroll);
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Total_Classes_Attended__c = 45;
        obj_Cour_Enroll.Total_Classes_Completed__c = 40;
        Insert obj_Cour_Enroll; 
       
        Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Due_Date__c = system.today().addDays(-1);
        objStudentFee.Program_Enrollment__c = objProgEnroll.Id; 
        Insert objStudentFee;
        
        test.startTest();
        ASM_HallTicketEligibility_Ctrl.getProgramBatchDetails();
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(objTerm.Id,'Pending Fees');
        ASM_HallTicketEligibility_Ctrl.getSemesterDetails(objProgPlan.id);
        ASM_HallTicketEligibility_Ctrl.saveStudentsDetails(list_Enroll);
        test.stopTest();
        system.assertEquals(objStudentFee.Amount_Pending__c,2);
    }
     public static Testmethod Void OpenSurveysandAttendanceShortage()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-15;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Issue_Hall_Ticket__c = false;
        objProgEnroll.SRN_Number__c = '123';
        objProgEnroll.Pending_Survey__c = 1;
        objProgEnroll.Semester__c =objTerm.id;
        objProgEnroll.hed__Contact__c = ObjCon.id;
        insert objProgEnroll; 
        
        List<hed__Program_Enrollment__c> list_Enroll = New  List<hed__Program_Enrollment__c> ();
        list_Enroll.Add(objProgEnroll);
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Total_Classes_Attended__c = 30;
        obj_Cour_Enroll.Total_Classes_Completed__c = 50;
        Insert obj_Cour_Enroll; 
       
        Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Due_Date__c = system.today().addDays(-1);
        objStudentFee.Program_Enrollment__c = objProgEnroll.Id; 
        Insert objStudentFee;
        
        test.startTest();
        ASM_HallTicketEligibility_Ctrl.getProgramBatchDetails();
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(objTerm.Id,'Open Surveys & Attendance Shortage');
        ASM_HallTicketEligibility_Ctrl.getSemesterDetails(objProgPlan.id);
        ASM_HallTicketEligibility_Ctrl.saveStudentsDetails(list_Enroll);
        test.stopTest();
        system.assertEquals(objStudentFee.Amount_Pending__c,2);
    }
    public static Testmethod Void OpenSurveysandPendingFee()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-15;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Issue_Hall_Ticket__c = false;
        objProgEnroll.SRN_Number__c = '123';
        objProgEnroll.Pending_Survey__c = 1;
        objProgEnroll.Semester__c =objTerm.id;
        objProgEnroll.hed__Contact__c = ObjCon.id;
        insert objProgEnroll; 
        
        List<hed__Program_Enrollment__c> list_Enroll = New  List<hed__Program_Enrollment__c> ();
        list_Enroll.Add(objProgEnroll);
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Total_Classes_Attended__c = 50;
        obj_Cour_Enroll.Total_Classes_Completed__c = 30;
        Insert obj_Cour_Enroll; 
       
        Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Due_Date__c = system.today().addDays(-1);
        objStudentFee.Program_Enrollment__c = objProgEnroll.Id; 
        Insert objStudentFee;
        
        test.startTest();
        ASM_HallTicketEligibility_Ctrl.getProgramBatchDetails();
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(objTerm.Id,'Open Surveys & Pending Fees');
        ASM_HallTicketEligibility_Ctrl.getSemesterDetails(objProgPlan.id);
        ASM_HallTicketEligibility_Ctrl.saveStudentsDetails(list_Enroll);
        test.stopTest();
        system.assertEquals(objStudentFee.Amount_Pending__c,2);
    }
    public static Testmethod Void AttendanceShortageandPendingFees()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-15;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Issue_Hall_Ticket__c = false;
        objProgEnroll.SRN_Number__c = '123';
        objProgEnroll.Pending_Survey__c = 0;
        objProgEnroll.Semester__c =objTerm.id;
        objProgEnroll.hed__Contact__c = ObjCon.id;
        insert objProgEnroll; 
        
        List<hed__Program_Enrollment__c> list_Enroll = New  List<hed__Program_Enrollment__c> ();
        list_Enroll.Add(objProgEnroll);
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Total_Classes_Attended__c = 30;
        obj_Cour_Enroll.Total_Classes_Completed__c = 50;
        Insert obj_Cour_Enroll; 
       
        Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Due_Date__c = system.today().addDays(-1);
        objStudentFee.Program_Enrollment__c = objProgEnroll.Id; 
        Insert objStudentFee;
        
        test.startTest();
        ASM_HallTicketEligibility_Ctrl.getProgramBatchDetails();
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(objTerm.Id,'Attendance Shortage & Pending Fees');
        ASM_HallTicketEligibility_Ctrl.getSemesterDetails(objProgPlan.id);
        ASM_HallTicketEligibility_Ctrl.saveStudentsDetails(list_Enroll);
        test.stopTest();
        system.assertEquals(objStudentFee.Amount_Pending__c,2);
    }
    public static Testmethod Void OpenSurveysandAttendanceShortageandPendingFees()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-15;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Issue_Hall_Ticket__c = false;
        objProgEnroll.SRN_Number__c = '123';
        objProgEnroll.Pending_Survey__c = 2;
        objProgEnroll.Semester__c =objTerm.id;
        objProgEnroll.hed__Contact__c = ObjCon.id;
        insert objProgEnroll; 
        
        List<hed__Program_Enrollment__c> list_Enroll = New  List<hed__Program_Enrollment__c> ();
        list_Enroll.Add(objProgEnroll);
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Total_Classes_Attended__c = 30;
        obj_Cour_Enroll.Total_Classes_Completed__c = 50;
        Insert obj_Cour_Enroll; 
       
        Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Due_Date__c = system.today().addDays(-1);
        objStudentFee.Program_Enrollment__c = objProgEnroll.Id; 
        Insert objStudentFee;
        
        test.startTest();
        ASM_HallTicketEligibility_Ctrl.getProgramBatchDetails();
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(objTerm.Id,'Open Surveys & Attendance Shortage & Pending Fees');
        ASM_HallTicketEligibility_Ctrl.getSemesterDetails(objProgPlan.id);
        ASM_HallTicketEligibility_Ctrl.saveStudentsDetails(list_Enroll);
        test.stopTest();
        system.assertEquals(objStudentFee.Amount_Pending__c,2);
    }
    public static Testmethod Void FeePendingMethod()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-15;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Issue_Hall_Ticket__c = false;
        objProgEnroll.SRN_Number__c = '123';
        objProgEnroll.Pending_Survey__c = 0;
        objProgEnroll.Semester__c =objTerm.id;
        objProgEnroll.hed__Contact__c = ObjCon.id;
        insert objProgEnroll; 
        
        List<hed__Program_Enrollment__c> list_Enroll = New  List<hed__Program_Enrollment__c> ();
        list_Enroll.Add(objProgEnroll);
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Total_Classes_Attended__c = 40;
        obj_Cour_Enroll.Total_Classes_Completed__c = 90;
        Insert obj_Cour_Enroll; 
       
        Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Due_Date__c = system.today().addDays(-1);
        objStudentFee.Program_Enrollment__c = objProgEnroll.Id; 
        Insert objStudentFee;
       
        test.startTest();
        ASM_HallTicketEligibility_Ctrl.getProgramBatchDetails();
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(objTerm.Id,'Pending Fees');
        ASM_HallTicketEligibility_Ctrl.getSemesterDetails(objProgPlan.id);
        ASM_HallTicketEligibility_Ctrl.saveStudentsDetails(list_Enroll);
        test.stopTest();
        system.assertEquals(objStudentFee.Amount_Pending__c,2);
    }
    public static Testmethod Void OpenSurveysAttendanceShortageMethod()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-15;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Issue_Hall_Ticket__c = false;
        objProgEnroll.SRN_Number__c = '123';
        objProgEnroll.Pending_Survey__c = 0;
        objProgEnroll.Semester__c =objTerm.id;
        objProgEnroll.hed__Contact__c = ObjCon.id;
        insert objProgEnroll; 
        
        hed__Program_Enrollment__c objPrgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objPrgEnroll.hed__Start_Date__c = system.today()-1;
        objPrgEnroll.hed__End_Date__c = system.today();
        objPrgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objPrgEnroll.Application_Number__c ='123';
        objPrgEnroll.Issue_Hall_Ticket__c = false;
        objPrgEnroll.SRN_Number__c = '123';
        objPrgEnroll.Pending_Survey__c = 1;
        objPrgEnroll.Semester__c =objTerm.id;
        objPrgEnroll.hed__Contact__c = ObjCon.id;
        insert objPrgEnroll; 
        
        
        List<hed__Program_Enrollment__c> list_Enroll = New  List<hed__Program_Enrollment__c> ();
        list_Enroll.Add(objProgEnroll);
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Total_Classes_Attended__c = 40;
        obj_Cour_Enroll.Total_Classes_Completed__c = 90;
        Insert obj_Cour_Enroll; 
       
        Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=0;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Due_Date__c = system.today().addDays(-1);
        objStudentFee.Program_Enrollment__c = objProgEnroll.Id; 
        Insert objStudentFee;
        
        Student_Fee__c objStudFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudFee.Amount__c = 50000;
        objStudFee.Amount_Pending__c=0;
        objStudFee.Amount_Paid__c=10000;
        objStudFee.Number_of_Installments__c =3;
        objStudFee.Paid_Installments__c =1;  
        objStudFee.Due_Date__c = system.today().addDays(-1);
        objStudFee.Program_Enrollment__c = objPrgEnroll.Id; 
        Insert objStudFee;
       
        test.startTest();
        ASM_HallTicketEligibility_Ctrl.getProgramBatchDetails();
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(objTerm.Id,'Open Surveys & Attendance Shortage');
        ASM_HallTicketEligibility_Ctrl.getSemesterDetails(objProgPlan.id);
        ASM_HallTicketEligibility_Ctrl.saveStudentsDetails(list_Enroll);
        test.stopTest();
        system.assertEquals(objStudentFee.Amount_Pending__c,0);
    }
    public static Testmethod Void OpenSurveysandPendingFeesMethod()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today()-15;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Issue_Hall_Ticket__c = false;
        objProgEnroll.SRN_Number__c = '123';
        objProgEnroll.Pending_Survey__c = 0;
        objProgEnroll.Semester__c =objTerm.id;
        objProgEnroll.hed__Contact__c = ObjCon.id;
        insert objProgEnroll; 
        
        hed__Program_Enrollment__c objPrgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objPrgEnroll.hed__Start_Date__c = system.today()-1;
        objPrgEnroll.hed__End_Date__c = system.today();
        objPrgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objPrgEnroll.Application_Number__c ='123';
        objPrgEnroll.Issue_Hall_Ticket__c = false;
        objPrgEnroll.SRN_Number__c = '123';
        objPrgEnroll.Pending_Survey__c = 1;
        objPrgEnroll.Semester__c =objTerm.id;
        objPrgEnroll.hed__Contact__c = ObjCon.id;
        insert objPrgEnroll; 
        
        
        List<hed__Program_Enrollment__c> list_Enroll = New  List<hed__Program_Enrollment__c> ();
        list_Enroll.Add(objProgEnroll);
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Total_Classes_Attended__c = 90;
        obj_Cour_Enroll.Total_Classes_Completed__c = 40;
        Insert obj_Cour_Enroll; 
       
        Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=0;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Due_Date__c = system.today().addDays(-1);
        objStudentFee.Program_Enrollment__c = objProgEnroll.Id; 
        Insert objStudentFee;
        
        Student_Fee__c objStudFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudFee.Amount__c = 50000;
        objStudFee.Amount_Pending__c=0;
        objStudFee.Amount_Paid__c=10000;
        objStudFee.Number_of_Installments__c =3;
        objStudFee.Paid_Installments__c =1;  
        objStudFee.Due_Date__c = system.today().addDays(-1);
        objStudFee.Program_Enrollment__c = objPrgEnroll.Id; 
        Insert objStudFee;
       
        test.startTest();
        ASM_HallTicketEligibility_Ctrl.getProgramBatchDetails();
        ASM_HallTicketEligibility_Ctrl.getStudentDetails(objTerm.Id,'Open Surveys & Pending Fees');
        ASM_HallTicketEligibility_Ctrl.getSemesterDetails(objProgPlan.id);
        ASM_HallTicketEligibility_Ctrl.saveStudentsDetails(null);
        test.stopTest();
        system.assertEquals(objStudentFee.Amount_Pending__c,0);
    }
}