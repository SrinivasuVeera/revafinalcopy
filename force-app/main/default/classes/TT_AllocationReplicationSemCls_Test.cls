@isTest
public class TT_AllocationReplicationSemCls_Test {
    
    @isTest
    public static void TT_AllocationReplicationSemMethod(){
        
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = TT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        
        Id termRecTypeId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
        hed__Term__c obj_Term1 = TT_TestDataFactory.createTerm('Parent TermName',objAccount.Id, termRecTypeId1);
        obj_Term1.RecordTypeId = termRecTypeId1;
        obj_Term1.hed__Start_Date__c = system.today();
        obj_Term1.hed__End_Date__c = system.today()+2;
        obj_Term1.IA_1_Start_date__c = system.today();
        obj_Term1.IA_1_End_date__c = system.today();
        obj_Term1.IA_2_Start_date__c = system.today();
        obj_Term1.IA_2_End_date__c = system.today();
        Insert obj_Term1;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
        hed__Term__c obj_Term = TT_TestDataFactory.createTerm('Test Term',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Parent_Term__c =obj_Term1.id;        
        Insert obj_Term;
       
        BusinessHours obJBH= [SELECT id,name,isdefault from BusinessHours where name= 'REVA Business Hours'];
        for(integer i=1;i<30;i++){
            system.debug('test bh ++++++'+BusinessHours.isWithin(obJBH.id, date.newInstance(2022, 10, i)));
        }
        
        hed__Time_Block__c obj_Tb = new hed__Time_Block__c();
        obj_Tb.Name = 'test';
        obj_Tb.hed__Start_Time__c = time.newInstance(8, 30, 0, 0);
        obj_Tb.hed__End_Time__c = time.newInstance(16, 30, 0, 0);
        
        insert obj_Tb;
        
        hed__Facility__c objFacility =  new hed__Facility__c();
        objFacility.Name = 'test';
        
        insert objFacility;
        
        hed__Course__c obj_Cour = TT_TestDataFactory.CreateCourse('Test Course', objAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        Insert obj_Cour;
        
        hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        hed__Course_Offering__c obJCourse_Off1 = TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.Id);
        obJCourse_Off1.Semester_Course_offering__c = obj_CourOff.id;
        insert obJCourse_Off1;
       
        hed__Course_Offering_Schedule__c  objCourse_Sch = TT_TestDataFactory.CreateCourseSchedule(obJCourse_Off1.Id, obj_Term.Id);
        objCourse_Sch.hed__Time_Block__c = obj_Tb.Id;
        objCourse_Sch.hed__Facility__c = objFacility.Id;
        objCourse_Sch.Teaching_Method__c = 'ICT';
        objCourse_Sch.School_Head__c  = userinfo.getUserId();
        objCourse_Sch.Display_Name__c = 'test';
        objCourse_Sch.Batch_Group__c = obj_Term1.Id;
        objCourse_Sch.Break__c = true;
        objCourse_Sch.hed__Start_Time__c = time.newInstance(8, 30, 0, 0);
        objCourse_Sch.hed__End_Time__c = time.newInstance(16, 30, 0, 0);
        //objCourse_Sch.hed__Monday__c =true;
        insert objCourse_Sch;
        
         Course_Plan_Unit__c objcourseUnit = TT_TestDataFactory.createCoursePlanUnit('Test Course Plan Unit',obj_CourOff.Id,obj_Cour.Id);
        insert objcourseUnit;
        
         Course_Plan_Topic__c obj_CoursePlanTopic = TT_TestDataFactory.createCoursePlanTopic('Course Plan',objcourseUnit.Id);
        obj_CoursePlanTopic.Course_Plan_Unit__c  = objcourseUnit.Id;
        Insert obj_CoursePlanTopic;
        
        
        Test.startTest();
        TT_AllocationReplicationSemCls ttAllBatch = new TT_AllocationReplicationSemCls(obj_Term1.Id);
        set<id> idset = new set<id>{objAccount.Id};
            ttAllBatch.programIdSet = idset;
        database.executeBatch(ttAllBatch);
        
        Test.stopTest();
    }
    //@isTest
    public static void TT_AllocationReplicationSemMethod2(){
        
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = TT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        
        Id termRecTypeId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
        hed__Term__c obj_Term1 = TT_TestDataFactory.createTerm('Parent TermName',objAccount.Id, termRecTypeId1);
        obj_Term1.RecordTypeId = termRecTypeId1;
        obj_Term1.hed__Start_Date__c = system.today();
        obj_Term1.hed__End_Date__c = system.today()+10;
        obj_Term1.IA_1_Start_date__c = system.today();
        obj_Term1.IA_1_End_date__c = system.today();
        obj_Term1.IA_2_Start_date__c = system.today();
        obj_Term1.IA_2_End_date__c = system.today();
        Insert obj_Term1;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
        hed__Term__c obj_Term = TT_TestDataFactory.createTerm('Test Term',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Parent_Term__c =obj_Term1.id;        
        Insert obj_Term;
       
        BusinessHours obJBH= [SELECT id,name,isdefault from BusinessHours where name= 'REVA Business Hours'];
       
        
        hed__Time_Block__c obj_Tb = new hed__Time_Block__c();
        obj_Tb.Name = 'test';
        obj_Tb.hed__Start_Time__c = time.newInstance(6, 0, 0, 0);
        obj_Tb.hed__End_Time__c = time.newInstance(22, 0, 0, 0);
        
        insert obj_Tb;
        
        hed__Facility__c objFacility =  new hed__Facility__c();
        objFacility.Name = 'test';
        
        insert objFacility;
        
        hed__Course__c obj_Cour = TT_TestDataFactory.CreateCourse('Test Course', objAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        Insert obj_Cour;
        
        hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        hed__Course_Offering__c obJCourse_Off1 = TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.Id);
        obJCourse_Off1.Semester_Course_offering__c = obj_CourOff.id;
        insert obJCourse_Off1;
       
        hed__Course_Offering_Schedule__c  objCourse_Sch = TT_TestDataFactory.CreateCourseSchedule(obJCourse_Off1.Id, obj_Term.Id);
        objCourse_Sch.hed__Time_Block__c = obj_Tb.Id;
        objCourse_Sch.hed__Facility__c = objFacility.Id;
        objCourse_Sch.Teaching_Method__c = 'ICT';
        objCourse_Sch.School_Head__c  = userinfo.getUserId();
        //objCourse_Sch.Date__c = system.today();
        objCourse_Sch.Display_Name__c = 'test';
        //objCourse_Sch.hed__Time_Block__c = obj_Tb.Id;
        objCourse_Sch.Batch_Group__c = obj_Term1.Id;
        objCourse_Sch.Break__c = true;
        objCourse_Sch.hed__Start_Time__c = time.newInstance(6, 0, 0, 0);
        objCourse_Sch.hed__End_Time__c = time.newInstance(22, 0, 0, 0);
        objCourse_Sch.hed__Monday__c =false;
        objCourse_Sch.hed__Tuesday__c =true;
        objCourse_Sch.hed__Wednesday__c =false;
        objCourse_Sch.hed__Thursday__c = false;
        objCourse_Sch.hed__Friday__c =false;
        objCourse_Sch.hed__Saturday__c =false;
        objCourse_Sch.hed__Sunday__c =true;
        //objCourse_Sch.Section__c = obj_Term1.id;
        insert objCourse_Sch;
        
         Course_Plan_Unit__c objcourseUnit = TT_TestDataFactory.createCoursePlanUnit('Test Course Plan Unit',obj_CourOff.Id,obj_Cour.Id);
        insert objcourseUnit;
        
         Course_Plan_Topic__c obj_CoursePlanTopic = TT_TestDataFactory.createCoursePlanTopic('Course Plan',objcourseUnit.Id);
        obj_CoursePlanTopic.Course_Plan_Unit__c  = objcourseUnit.Id;
        Insert obj_CoursePlanTopic;
        
        
        Test.startTest();
        TT_AllocationReplicationSemCls ttAllBatch = new TT_AllocationReplicationSemCls(obj_Term1.Id);
        set<id> idset = new set<id>{objAccount.Id};
            ttAllBatch.programIdSet = idset;
        database.executeBatch(ttAllBatch);
        
        Test.stopTest();
    }
    @isTest
    public static void TT_AllocationReplicationSemMethod3(){
        
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = TT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        
        Id termRecTypeId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
        hed__Term__c obj_Term1 = TT_TestDataFactory.createTerm('Parent TermName',objAccount.Id, termRecTypeId1);
        obj_Term1.RecordTypeId = termRecTypeId1;
        obj_Term1.hed__Start_Date__c = system.today();
        obj_Term1.hed__End_Date__c = system.today()+2;
        obj_Term1.IA_1_Start_date__c = system.today();
        obj_Term1.IA_1_End_date__c = system.today();
        obj_Term1.IA_2_Start_date__c = system.today();
        obj_Term1.IA_2_End_date__c = system.today();
        Insert obj_Term1;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
        hed__Term__c obj_Term = TT_TestDataFactory.createTerm('Test Term',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Parent_Term__c =obj_Term1.id;        
        Insert obj_Term;
       
        BusinessHours obJBH= [SELECT id,name,isdefault from BusinessHours where name= 'REVA Business Hours'];
       
        
        hed__Time_Block__c obj_Tb = new hed__Time_Block__c();
        obj_Tb.Name = 'test';
        obj_Tb.hed__Start_Time__c = time.newInstance(8, 30, 0, 0);
        obj_Tb.hed__End_Time__c = time.newInstance(16, 30, 0, 0);
        
        insert obj_Tb;
        
        hed__Facility__c objFacility =  new hed__Facility__c();
        objFacility.Name = 'test';
        
        insert objFacility;
        
        hed__Course__c obj_Cour = TT_TestDataFactory.CreateCourse('Test Course', objAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        Insert obj_Cour;
        
        hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        hed__Course_Offering__c obJCourse_Off1 = TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.Id);
        obJCourse_Off1.Semester_Course_offering__c = obj_CourOff.id;
        insert obJCourse_Off1;
       
        hed__Course_Offering_Schedule__c  objCourse_Sch = TT_TestDataFactory.CreateCourseSchedule(obJCourse_Off1.Id, obj_Term.Id);
        objCourse_Sch.hed__Time_Block__c = obj_Tb.Id;
        objCourse_Sch.hed__Facility__c = objFacility.Id;
        objCourse_Sch.Teaching_Method__c = 'ICT';
        objCourse_Sch.School_Head__c  = userinfo.getUserId();
        //objCourse_Sch.Date__c = system.today();
        objCourse_Sch.Display_Name__c = 'test';
        //objCourse_Sch.hed__Time_Block__c = obj_Tb.Id;
        objCourse_Sch.Batch_Group__c = obj_Term1.Id;
        objCourse_Sch.Break__c = true;
        objCourse_Sch.hed__Start_Time__c = time.newInstance(8, 30, 0, 0);
        objCourse_Sch.hed__End_Time__c = time.newInstance(16, 30, 0, 0);
        //objCourse_Sch.hed__Monday__c =true;
        //objCourse_Sch.hed__Monday__c =false;
        //objCourse_Sch.hed__Tuesday__c =true;
        objCourse_Sch.hed__Wednesday__c =true;
        //objCourse_Sch.hed__Thursday__c = true;
        //objCourse_Sch.hed__Friday__c =true;
        //objCourse_Sch.hed__Saturday__c =true;
        //objCourse_Sch.hed__Sunday__c =true;
        //objCourse_Sch.Section__c = obj_Term1.id;
        insert objCourse_Sch;
        
         Course_Plan_Unit__c objcourseUnit = TT_TestDataFactory.createCoursePlanUnit('Test Course Plan Unit',obj_CourOff.Id,obj_Cour.Id);
        insert objcourseUnit;
        
         Course_Plan_Topic__c obj_CoursePlanTopic = TT_TestDataFactory.createCoursePlanTopic('Course Plan',objcourseUnit.Id);
        obj_CoursePlanTopic.Course_Plan_Unit__c  = objcourseUnit.Id;
        Insert obj_CoursePlanTopic;
        
        
        Test.startTest();
        TT_AllocationReplicationSemCls ttAllBatch = new TT_AllocationReplicationSemCls(obj_Term1.Id);
        set<id> idset = new set<id>{objAccount.Id};
            ttAllBatch.programIdSet = idset;
        database.executeBatch(ttAllBatch);
        
        Test.stopTest();
    }
}