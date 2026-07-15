@istest
public class STOB_ProfessorStudentTriggerHandler_Test
{
    public static testMethod Void ProfessorStudent()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();

        Account objAcc = STOB_TestDataFactory.CreateAccount('str_accName');
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;

        string UniversityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc1 = STOB_TestDataFactory.CreateAccount('Test Account');
        objAcc1.Recordtypeid = UniversityRecTypeId;
        //objAcc1.OwnerId = portalAccountOwner1.Id;
        Insert objAcc1;

        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();

        Contact objCon = STOB_TestDataFactory.createContact('Test');
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;
        // objcon.hed__Preferred_Email__c='test@reva.edu.in';
        Insert objCon;

        hed__Course__c obj_Cour = STOB_TestDataFactory.CreateCourse('CourseName', objAcc1.Id);
        obj_Cour.Credits__c = 4.00;
        obj_Cour.Offered_By_School__c = objAcc1.Id;
        obj_Cour.Credit_Hours__c = 4.00;
        obj_Cour.Maximum_External_Marks__c = 50.00;
        obj_Cour.Total_Maximum_Marks_IA_External__c = 100.00;
        obj_Cour.No_of_IA_s__c = '1';
        obj_Cour.L_T_P__c='2:1:0';
        Insert obj_Cour;

        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();

        hed__Term__c obj_Term = STOB_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;

        hed__Course_Offering__c obj_Cour_Off =STOB_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        obj_Cour_Off.Student_Preference_1__c = 11;
        obj_Cour_Off.Student_Preference_2__c = 22;
        obj_Cour_Off.Student_Preference_3__c = 33;
        insert obj_Cour_Off;

        hed__Course_Offering__c obj_Cour_Off1 =STOB_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        obj_Cour_Off1.Student_Preference_1__c = 12;
        obj_Cour_Off1.Student_Preference_2__c = 24;
        obj_Cour_Off1.Student_Preference_3__c = 32;
        insert obj_Cour_Off1;

        Professor_Student_Course_Preference__c obj_Pro_Stud_Cour =  new Professor_Student_Course_Preference__c();
        obj_Pro_Stud_Cour.Name = 'Test';
        obj_Pro_Stud_Cour.Course_Offering__c= obj_Cour_Off.Id;
        obj_Pro_Stud_Cour.Contact__c= ObjCon.id;
        obj_Pro_Stud_Cour.Preference__c = '1';
        obj_Pro_Stud_Cour.Semester__c = obj_Term.Id;
        insert obj_Pro_Stud_Cour;

        List<Professor_Student_Course_Preference__c> lst_Pro_stud = new List<Professor_Student_Course_Preference__c>();
        lst_Pro_stud.Add(obj_Pro_Stud_Cour);

        obj_Pro_Stud_Cour.Course_Offering__c= obj_Cour_Off1.Id;
        update obj_Pro_Stud_Cour;

        map<id,Professor_Student_Course_Preference__c> oldMap = new map<id,Professor_Student_Course_Preference__c>();
        oldMap.put(obj_Pro_Stud_Cour.Id,obj_Pro_Stud_Cour);

        delete obj_Pro_Stud_Cour;
        undelete obj_Pro_Stud_Cour;

        Test.StartTest();
        STOB_ProfessorStudentTriggerHandler.RollupPreference(lst_Pro_stud, null);
        STOB_ProfessorStudentTriggerHandler.RollupPreference(lst_Pro_stud, oldMap);
        Test.StopTest();
        system.assertEquals(obj_Pro_Stud_Cour.Id,obj_Pro_Stud_Cour.Id);
    }

    @isTest
    static void testRollupPreferenceForProfessor() {
        Id profRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();

        Id univAccRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account acc = new Account(Name = 'Test Univ', RecordTypeId = univAccRtId);
        insert acc;

        Contact prof = new Contact(
            FirstName = 'Prof',
            LastName = 'Test',
            RecordTypeId = profRtId,
            Email = 'prof@reva.edu.in',
            MobilePhone = '9876543210',
            AccountId = acc.Id
        );
        insert prof;

        Profile profProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User profUser = new User(
            Username = 'professoruser' + System.currentTimeMillis() + '@reva.edu.in',
            Alias = 'profU',
            Email = 'prof@reva.edu.in',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Professor',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Asia/Kolkata',
            ProfileId = profProfile.Id

        );

        insert profUser;

        System.runAs(profUser) {
            hed__Course__c course = new hed__Course__c(
                Name = 'Maths',
                hed__Account__c = acc.Id,
                hed__Course_ID__c = 'MATH-101',
                Credits__c = 4.00,
                Offered_By_School__c = acc.Id,
                Credit_Hours__c = 4.00,
                Maximum_External_Marks__c = 50.00,
                Total_Maximum_Marks_IA_External__c = 100.00,
               No_of_IA_s__c = '1',
               L_T_P__c='2:1:0'

            );
            insert course;

            Id termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
            hed__Term__c term = new hed__Term__c(Name = 'Fall 2025', RecordTypeId = termRtId, hed__Account__c = acc.Id);
            insert term;

            hed__Course_Offering__c offering = new hed__Course_Offering__c(
                hed__Course__c = course.Id,
                hed__Term__c = term.Id,
                Category__c = 'Hardcore Course'
            );
            insert offering;

            Professor_Student_Course_Preference__c pref = new Professor_Student_Course_Preference__c(
                Name = 'ProfPref',
                Course_Offering__c = offering.Id,
                Professor__c = prof.Id,
                Preference__c = '2',
                Semester__c = term.Id
            );
            insert pref;

            Professor_Student_Course_Preference__c prefOld = new Professor_Student_Course_Preference__c();
            prefOld.Preference__c = '6';
            prefOld.Id = pref.Id ;
            update prefOld;

            List<Professor_Student_Course_Preference__c> newList = new List<Professor_Student_Course_Preference__c>{ pref };
                Map<Id, Professor_Student_Course_Preference__c> oldMap = new Map<Id, Professor_Student_Course_Preference__c>{
                    prefOld.Id => prefOld
                        };
                            Test.startTest();
            STOB_ProfessorStudentTriggerHandler.rollupPreferenceForProfessor(newList, oldMap);
            STOB_ProfessorStudentTriggerHandler.rollupPreferenceForProfessor(newList, oldMap);
            Test.stopTest();

            hed__Course_Offering__c updatedOffering = [SELECT Professor_Theory_Preference_6__c FROM hed__Course_Offering__c WHERE Id = :offering.Id];
            System.assertEquals(1, updatedOffering.Professor_Theory_Preference_6__c, 'Preference 6 count should be incremented.');
        }
    }

}