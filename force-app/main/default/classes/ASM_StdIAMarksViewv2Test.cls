@isTest
public class ASM_StdIAMarksViewv2Test 
{
    @TestSetup
    static void setup() 
    {
        // string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Id uniDeptRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        // Get the UserType of the current user
        String userId = UserInfo.getUserId();
        User adminUser = [SELECT Id, UserRoleId, UserType FROM User WHERE Id = :userId LIMIT 1];
        //User adminUser = [SELECT Id, UserRoleId, UserType FROM User WHERE Id = :userId LIMIT 1];        
        // Get a UserRole that matches the UserType
        //      UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];        
        // Update the UserRoleId
        //   adminUser.UserRoleId = userrole.Id;
        try {
            update adminUser;
        } catch (DmlException e) {
            System.debug('DML Exception: ' + e.getMessage());
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug('Error on record ' + e.getDmlIndex(i) + ': ' + e.getDmlMessage(i));
            }
        }
        
        /* UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
string userId = userinfo.getUserId();
User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
adminUser.UserRoleId = userRole.Id;
update adminUser;  
*/
        User newUser1 = new user();
        contact objCon = new contact();
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        system.runAs(adminUser){               
            // objAcc.Recordtypeid = HouseholdRecId;
            objAcc.Recordtypeid = uniDeptRecordTypeId1;
            Insert objAcc;
            
            string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
            objCon = ASM_TestDataFactory.createContact(2,objAcc.Id);
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objCon.RecordTypeId = StudentRecId;
            objCon.AccountId = objAcc.Id;
            objcon.Application_Number__c = 'test123';
            objcon.SRN_Number__c ='123';
            objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
            objcon.Nationality__c ='Indian';
            Insert objCon; 
            
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'Asia/Kolkata',
                alias='nuser',
                lastname='lastname',
                contactId = objcon.id
                // UserRoleId = userrole.Id
            );
            insert newUser1;
        }  
        system.runAs(adminUser){    
            Mandatory_Courses_Category_Values__c objMan = new Mandatory_Courses_Category_Values__c();
            objMan.Name = 'Hardcore Course';
            insert objMan;
            
            List<hed__Course__c> list_Crs = new List<hed__Course__c>();
            for(integer i=1;i<=3;i++){
                String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
                list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
            }
            Insert list_Crs;
            
            hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan.Provisionally_Admitted_Students__c = 20;
            objProgPlan.Intake__c =20;
            objProgPlan.Intake_Per_Section__c=5;
            insert objProgPlan;
            
            string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
            hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
            objTerm.Program_Batch__c  = objProgPlan.id;
            objTerm.hed__Start_Date__c = system.today();
            objTerm.hed__End_Date__c = system.today();
            objTerm.IA_1_Result_date__c = system.today();
            insert objTerm;
            
            ObjCon.Active_Semester__c = objTerm.Id;
            Update ObjCon;
            
            string termRtId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections ).getRecordTypeId();
            
            hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId1);
            objTermParent.hed__Parent_Term__c = objTerm.id;
            objTermParent.IA_1_Start_date__c = system.today();
            objTermParent.IA_2_End_date__c = system.today();
            insert objTermParent;
            
            hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
            objProgEnroll.hed__Start_Date__c = system.today()-1;
            objProgEnroll.hed__End_Date__c = system.today();
            objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
            objProgEnroll.Application_Number__c ='123';
            objProgEnroll.Section__c = objTerm.id;
            insert objProgEnroll; 
            
            Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
            
            hed__Term__c obj_Term = ASM_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
            obj_Term.RecordTypeId = termRecTypeId;
            obj_Term.hed__Parent_Term__c = objTerm.id;
            Insert obj_Term;
            
            string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
            
            Student_Semester_Mapping__c obj_Stud_Sem = ASM_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
            obj_Stud_Sem.RecordTypeId= recordTypeName;
            obj_Stud_Sem.Active__c = true; 
            obj_Stud_Sem.Program_Enrollment__c= objProgEnroll.id;
            obj_Stud_Sem.Start_Date__c = system.today();
            obj_Stud_Sem.End_Date__c = system.today();
            obj_Stud_Sem.Section__c = objTermParent.id;
            obj_Stud_Sem.Student_Batch__c= obj_Term.id;
            insert obj_Stud_Sem;
            
            string recordTypeName1 = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
            
            Student_Semester_Mapping__c obj_Stud_Sem1 = ASM_TestDataFactory.createStudenttermMapping('StuTerm', recordTypeName1);
            obj_Stud_Sem1.RecordTypeId= recordTypeName1;
            obj_Stud_Sem1.Active__c =true;
            obj_Stud_Sem1.Program_Enrollment__c= objProgEnroll.id;
            obj_Stud_Sem1.Start_Date__c = system.today();
            obj_Stud_Sem1.End_Date__c = system.today();
            obj_Stud_Sem1.Section__c = objTermParent.id;
            obj_Stud_Sem1.Student_Batch__c= obj_Term.id;
            insert obj_Stud_Sem1;   
            
            string recordTypeName22 = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Group).getRecordTypeId();
            
            Student_Semester_Mapping__c obj_Stud = ASM_TestDataFactory.createStudenttermMapping('StuTerm', recordTypeName22);
            obj_Stud.RecordTypeId= recordTypeName22;
            obj_Stud.Active__c = true; 
            obj_Stud.Program_Enrollment__c= objProgEnroll.id;
            obj_Stud.Start_Date__c = system.today();
            obj_Stud.End_Date__c = system.today();
            obj_Stud.Section__c = objTermParent.id;
            obj_Stud.Student_Batch__c= obj_Term.id;
            insert obj_Stud;
            
            /* Account schAcc = ASM_TestDataFactory.createSchoolAcc(1);
Insert schAcc;*/
            Id uniDeptRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            
            // Create a University Department account to satisfy Offered_By_School__c filter
            Account schAcc = new Account(
                Name = 'Test University Department',
                RecordTypeId = uniDeptRecordTypeId
            );
            insert schAcc;
            
            //hed__Course__c list_Cr = ASM_TestDataFactory.CreateCourse(1, schAcc.Id, 'Hardcore Course');
            
            hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, list_Crs[0].id);
            obj_Cour_Off.Category__c ='Hardcore Course'; 
            obj_Cour_Off.hed__Term__c = obj_Term.Id;
            obj_Cour_Off.hed__Term__c = objTermParent.Id;
            obj_Cour_Off.Offered_By_School__c = schAcc.Id;
            obj_Cour_Off.Publish_to_Students__c = true;
            obj_Cour_Off.IA_Marks_Update_Status__c ='Completed';
            insert obj_Cour_Off;
            
            Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            SYstem.debug('166=> '+enrollRecTypeId);
            
            /*   RecordType rt = [
SELECT Id 
FROM RecordType 
WHERE SObjectType = 'hed__Course_Enrollment__c' 
AND Name = 'Student'
LIMIT 1
];

System.debug()*/
            hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
            obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
            obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
            obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
            obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
            obj_Cour_Enroll.Section__c = objTermParent.id;
            Insert obj_Cour_Enroll;
            
            IA_Marks__c iam = ASM_TestDataFactory.createIAMarks(obj_Cour_Enroll.Id,obj_Cour_Off.Id,'IA1');
            ASM_IAMarksTrgHandler.rollupCountUpdate = false;
            iam.Course_Connection__c = obj_Cour_Enroll.Id;
            iam.Semester__c = objTerm.Id;
            Insert iam;
            
            // Query the record to get the record type name
            hed__Course_Enrollment__c queriedEnrollment = [
                SELECT Id, RecordType.Name 
                FROM hed__Course_Enrollment__c 
                WHERE Id = :obj_Cour_Enroll.Id
            ];
            System.debug('iam=> '+iam.IA_Type__c);
            System.debug('iam=> '+objTerm.IA_1_Result_date__c);
            System.debug('189=> '+obj_Cour_Enroll.hed__Contact__c);
            System.debug('190=> '+queriedEnrollment.RecordType.Name);
            System.debug('191=> '+newUser1.contactId);
            obj_Cour_Off.Publish_to_Students__c = true;
            Update obj_Cour_Off;
        }
    }
    static testMethod void exe(){
        User std = [SELECT Id,contactId FROM User WHERE username='newUser@epeople.com' limit 1];
        hed__Course_Enrollment__c CourseConnection = [Select Id,hed__Contact__c,RecordType.Name from hed__Course_Enrollment__c where hed__Contact__c=:std.contactId];
        hed__Term__c Semester = [Select Id,IA_1_Result_date__c from hed__Term__c where IA_1_Result_date__c=:System.today()];
        IA_Marks__c IAmarks = [Select Id,Course_Offering__r.hed__Course__r.Name,Semester__c,IA_Type__c,
                               Course_Offering__r.hed__Course__r.Maximum_Internal_Marks__c,
                               Theory_Secured_Marks__c,Seminar_Secured_Marks__c,Quiz_Secured_marks__c,
                               Analysis_and_Synthesis_Secured_Marks__c,Continuous_Learning_Secured_Marks__c,
                               Ethical_Attitude_Secured_Marks__c,Independent_Learning_Secured_Marks__c,
                               Literature_Survey_Secured_Marks__c,Selection_of_Topic_Secured_Marks__c,
                               Oral_Presentation_Secured_Marks__c,Report_Writing_Secured_Marks__c,Course_Type__c,
                               Knowledge_of_Exercise_Secured_Marks__c,Execution_of_Exercise_Secured_Marks__c,
                               Description_of_Experiment_Secured_Mark__c,Viva_Voce_Practical_Secured_Marks__c,
                               Punctuality_Secured_Marks__c,Results_Secured_Marks__c,Course_Connection__c,
                               Course_Offering__r.hed__Course__r.Seminar_Maximum_Marks__c,
                               Course_Offering__r.hed__Course__r.Quiz_Maximum_Marks__c,
                               Course_Offering__r.hed__Course__r.Theory_Maximum_Marks__c,
                               Course_Offering__r.hed__Course__r.Analysis_and_Synthesis_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Literature_Survey_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Ethical_Attitude_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Independent_Learning_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Oral_Presentation_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Report_Writing_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Continuous_Learning_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Selection_of_Topic_Max_marks__c,
                               Course_Offering__r.hed__Course__r.Knowledge_of_Exercise_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Execution_of_Exercise_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Description_of_Experiment_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Viva_Voce_Practical_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Punctuality_Max_Marks__c,
                               Course_Offering__r.hed__Course__r.Results_Max_Marks__c from IA_Marks__c where IA_Type__c='IA1'];
        System.debug('std=> '+std);
        System.debug('IAMArksCourseConnection=> '+IAmarks.Course_Connection__c+' IA_Type__c=> '+IAmarks.IA_Type__c);
        System.debug('IAmarks=> '+IAmarks.Semester__c+' Date=> '+IAmarks);
        System.debug('SemesterId=> '+Semester+' Semester=> '+Semester.IA_1_Result_date__c);
        System.debug('CourseConnection=> '+CourseConnection +' '+CourseConnection.RecordType.Name);
        System.runAs(std){

        hed__Term__c sem = [
            SELECT Id
            FROM hed__Term__c
            WHERE IA_1_Result_date__c = :System.today()
            LIMIT 1
        ];
    
        Test.startTest();
    
        ASM_StdIAMarksViewv2.dataWpr result1 =
            ASM_StdIAMarksViewv2.fetchData('IA1', null);
    
        ASM_StdIAMarksViewv2.dataWpr result2 =
            ASM_StdIAMarksViewv2.fetchData('IA1', sem.Id);
    
        Test.stopTest();
    
        System.assertNotEquals(null, result1);
        System.assertNotEquals(null, result2);
        System.assert(result2.semesters.size() > 0);
    }
        
    }
    
    /*****************************************************************************/
    static testMethod void testUpdateAcknowledgment() {
        // Fetch the existing IA_Marks__c record created during setup
        IA_Marks__c existingMark = [SELECT Id, Acknowledged__c, Acknowledgment_Response__c FROM IA_Marks__c WHERE IA_Type__c = 'IA1' LIMIT 1];
        
        // Run as the student user
        User std = [SELECT Id FROM User WHERE Username = 'newUser@epeople.com' LIMIT 1];
        System.runAs(std) {
            Test.startTest();
            // Call the method with test response
            ASM_StdIAMarksViewv2.updateAcknowledgment(existingMark.Id, 'Test acknowledgment response');
            Test.stopTest();
        }
        
        // Query the record again to verify updates
        IA_Marks__c updatedMark = [SELECT Acknowledged__c, Acknowledgment_Response__c FROM IA_Marks__c WHERE Id = :existingMark.Id];
        
        System.assertEquals(true, updatedMark.Acknowledged__c, 'Acknowledged__c should be true');
        System.assertEquals('Test acknowledgment response', updatedMark.Acknowledgment_Response__c, 'Acknowledgment_Response__c should match input');
    }
    
    /***********************************************************************************/
    
}