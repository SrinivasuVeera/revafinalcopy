@Istest
public class TT_AllocationReplicationCls_Test 
{
    Public static testmethod Void AllocationnMethod()
    {
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();        
        Account objAccount1 = TT_TestDataFactory.CreateAccount('child Account1',AcaRecId);
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;
        
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution).getRecordTypeId();
        Account objAccount = TT_TestDataFactory.CreateAccount('parent Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
        objAccount1.parentid = objAccount.id;
        update objAccount1;
        
        string AcaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();        
        Account objAccount2 = TT_TestDataFactory.CreateAccount('child Account2',AcaRecId2);
        objAccount2.RecordTypeid = AcaRecId;
        objAccount2.parentid = objAccount1.id;
        insert objAccount2;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = TT_TestDataFactory.createTerm('test parent term',objAccount2.id,termRtId);
        objTerm.hed__Start_Date__c = system.today().addmonths(-1);
        objTerm.hed__End_Date__c = system.Today().addmonths(+4);
        insert objTerm;
        
        hed__Term__c objTermParent = TT_TestDataFactory.createTerm('test child term',objAccount2.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
                        
        hed__Course__c objCourse = TT_TestDataFactory.CreateCourse('CourseName', objAccount2.Id);
        objCourse.hed__Course_ID__c ='123';
        Insert objCourse;
        
        hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', objTermParent.Id, objCourse.id);
        insert obj_CourOff;
        
        hed__Course_Offering__c obj_CourOff1 =TT_TestDataFactory.createCourseOffering('courseOffName', objTermParent.Id, objCourse.id);
        obj_CourOff1.Semester_Course_offering__c =obj_CourOff.id;
        insert obj_CourOff1;
        
        hed__Course_Offering_Schedule__c objcourseSch = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,objTermParent.id);
        objcourseSch.hed__Start_Time__c = system.now().time();
        objcourseSch.hed__End_Time__c = system.now().time();
        objcourseSch.hed__Monday__c =false;
        objcourseSch.hed__Tuesday__c =true;
        objcourseSch.hed__Wednesday__c =true;
        objcourseSch.hed__Thursday__c = true;
        objcourseSch.hed__Friday__c =true;
        objcourseSch.hed__Saturday__c =true;
        objcourseSch.hed__Sunday__c =true;
        insert objcourseSch;
        
        hed__Course_Offering_Schedule__c objcourseSch1 = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,objTermParent.id);
        objcourseSch1.hed__Start_Time__c = system.now().time();
        objcourseSch1.hed__End_Time__c = system.now().time();
        objcourseSch1.hed__Monday__c =false;
        objcourseSch1.hed__Tuesday__c =false;
        objcourseSch1.hed__Wednesday__c =true;
        objcourseSch1.hed__Thursday__c = true;
        objcourseSch1.hed__Friday__c =true;
        objcourseSch1.hed__Saturday__c =true;
        objcourseSch1.hed__Sunday__c =true;
        insert objcourseSch1;
        
        hed__Course_Offering_Schedule__c objcourseSch2 = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,objTermParent.id);
        objcourseSch2.hed__Start_Time__c = system.now().time();
        objcourseSch2.hed__End_Time__c = system.now().time();
        objcourseSch2.hed__Monday__c =false;
        objcourseSch2.hed__Tuesday__c =false;
        objcourseSch2.hed__Wednesday__c =false;
        objcourseSch2.hed__Thursday__c = true;
        objcourseSch2.hed__Friday__c =true;
        objcourseSch2.hed__Saturday__c =true;
        objcourseSch2.hed__Sunday__c =true;
        insert objcourseSch2;
        
        hed__Course_Offering_Schedule__c objcourseSch3 = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,objTermParent.id);
        objcourseSch3.hed__Start_Time__c = system.now().time();
        objcourseSch3.hed__End_Time__c = system.now().time();
        objcourseSch3.hed__Monday__c =false;
        objcourseSch3.hed__Tuesday__c =false;
        objcourseSch3.hed__Wednesday__c =false;
        objcourseSch3.hed__Thursday__c = false;
        objcourseSch3.hed__Friday__c =true;
        objcourseSch3.hed__Saturday__c =true;
        objcourseSch3.hed__Sunday__c =true;
        insert objcourseSch3;
        
        Course_Plan_Unit__c objcourseUnit = TT_TestDataFactory.createCoursePlanUnit('Test Course Plan Unit',obj_CourOff1.Id,objCourse.Id);
        insert objcourseUnit;
        
        Course_Plan_Unit__c objcourseUnit1 = TT_TestDataFactory.createCoursePlanUnit('Test Course Plan Unit',obj_CourOff1.Id,objCourse.Id);
        insert objcourseUnit1;
        
        Course_Plan_Topic__c obj_CoursePlanTopic = TT_TestDataFactory.createCoursePlanTopic('Course Plan',objcourseUnit.Id);
        obj_CoursePlanTopic.Course_Plan_Unit__c  = objcourseUnit.Id;
        Insert obj_CoursePlanTopic;
        
        Course_Plan_Topic__c obj_CoursePlanTopic1 = TT_TestDataFactory.createCoursePlanTopic('Course Plan',objcourseUnit1.Id);
        obj_CoursePlanTopic1.Course_Plan_Unit__c  = objcourseUnit1.Id;
        Insert obj_CoursePlanTopic1;
        
        Test.starttest();
        TT_AllocationReplicationCls btch = new  TT_AllocationReplicationCls(objAccount.id);
        database.executebatch(btch);
        test.stoptest();
        system.assertEquals(objAccount1.parentid, objAccount.id);
    }
    Public static testmethod Void AllocationnMethod1()
    {
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();        
        Account objAccount1 = TT_TestDataFactory.CreateAccount('child Account1',AcaRecId);
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;
        
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution).getRecordTypeId();
        Account objAccount = TT_TestDataFactory.CreateAccount('parent Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
        objAccount1.parentid = objAccount.id;
        update objAccount1;
        
        string AcaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();        
        Account objAccount2 = TT_TestDataFactory.CreateAccount('child Account2',AcaRecId2);
        objAccount2.RecordTypeid = AcaRecId;
        objAccount2.parentid = objAccount1.id;
        insert objAccount2;
        
        
         string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = TT_TestDataFactory.createTerm('test parent term',objAccount2.id,termRtId);
        objTerm.hed__Start_Date__c = system.today().addmonths(-1);
        objTerm.hed__End_Date__c = system.Today().addmonths(+4);
        insert objTerm;        
        
        hed__Term__c objTermParent = TT_TestDataFactory.createTerm('test child term',objAccount2.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
                
        hed__Course__c objCourse = TT_TestDataFactory.CreateCourse('CourseName', objAccount2.Id);
        objCourse.hed__Course_ID__c ='123';
        Insert objCourse;
        
        hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', objTermParent.Id, objCourse.id);
        insert obj_CourOff;
        
        hed__Course_Offering__c obj_CourOff1 =TT_TestDataFactory.createCourseOffering('courseOffName', objTermParent.Id, objCourse.id);
        obj_CourOff1.Semester_Course_offering__c =obj_CourOff.id;
        insert obj_CourOff1;
        
        hed__Course_Offering_Schedule__c objcourseSch = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,objTermParent.id);
        objcourseSch.hed__Start_Time__c = system.now().time();
        objcourseSch.hed__End_Time__c = system.now().time();
        objcourseSch.hed__Monday__c =false;
        objcourseSch.hed__Tuesday__c =false;
        objcourseSch.hed__Wednesday__c =false;
        objcourseSch.hed__Thursday__c = false;
        objcourseSch.hed__Friday__c =false;
        objcourseSch.hed__Saturday__c =true;
        objcourseSch.hed__Sunday__c =true;
        insert objcourseSch;
        
        hed__Course_Offering_Schedule__c objcourseSch1 = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,objTermParent.id);
        objcourseSch1.hed__Start_Time__c = system.now().time();
        objcourseSch1.hed__End_Time__c = system.now().time();
        objcourseSch1.hed__Monday__c =false;
        objcourseSch1.hed__Tuesday__c =false;
        objcourseSch1.hed__Wednesday__c =false;
        objcourseSch1.hed__Thursday__c = false;
        objcourseSch1.hed__Friday__c =false;
        objcourseSch1.hed__Saturday__c =false;
        objcourseSch1.hed__Sunday__c =true;
        insert objcourseSch1;
        
        Course_Plan_Unit__c objcourseUnit = TT_TestDataFactory.createCoursePlanUnit('Test Course Plan Unit',obj_CourOff1.Id,objCourse.Id);
        insert objcourseUnit;
        
        Course_Plan_Unit__c objcourseUnit1 = TT_TestDataFactory.createCoursePlanUnit('Test Course Plan Unit',obj_CourOff1.Id,objCourse.Id);
        insert objcourseUnit1;
        
        Course_Plan_Topic__c obj_CoursePlanTopic = TT_TestDataFactory.createCoursePlanTopic('Course Plan',objcourseUnit.Id);
        obj_CoursePlanTopic.Course_Plan_Unit__c  = objcourseUnit.Id;
        Insert obj_CoursePlanTopic;
        
        Course_Plan_Topic__c obj_CoursePlanTopic1 = TT_TestDataFactory.createCoursePlanTopic('Course Plan',objcourseUnit1.Id);
        obj_CoursePlanTopic1.Course_Plan_Unit__c  = objcourseUnit1.Id;
        Insert obj_CoursePlanTopic1;
        
        Test.starttest();
        TT_AllocationReplicationCls btch = new  TT_AllocationReplicationCls(objAccount.id);
        database.executebatch(btch);
        test.stoptest(); 
        system.assertEquals(objAccount1.parentid, objAccount.id);
    }
}