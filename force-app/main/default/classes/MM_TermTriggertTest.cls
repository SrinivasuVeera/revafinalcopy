@isTest
private class MM_TermTriggertTest {

    @isTest
    static void insertTermRecord(){
       User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive= true AND UserRoleId != NULL LIMIT 1];


        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(adminUser){
            string acrtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            string acRcName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getName();
            Account acc = new Account();
            acc.Name = 'TestAcc';
            acc.RecordTypeId = acrtId;

            insert Acc;

            string cortId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
            string coRcName = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Professor').getName();
            contact con = new contact();
            con.LastName = 'testCon';
            con.RecordTypeId = cortId;
            con.AccountId = acc.id;


            insert con;
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            User newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = con.id
                //UserRoleId = ur.Id
            );
            insert newUser1;
            string rtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
            hed__Term__c term = new hed__Term__c();
            term.Name = 'test term';
            term.hed__Account__c = acc.Id;
            term.Confirm_Mentor_Mapping__c = false;
            term.RecordTypeId = rtId;
            insert term;

            system.debug(' term '+term);

            //string ccRtId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get('Student Section').getRecordTypeId();
            Id ccRtId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get('Student Section').getRecordTypeId();
            system.debug('ccRtId '+ccRtId);
            hed__Course__c course = new hed__Course__c();
            course.Name = 'EEE';
            course.hed__Course_ID__c = 'EEE1';
            course.hed__Account__c = acc.Id;
            course.Credits__c = 4.00;
            course.Offered_By_School__c = acc.Id;
            course.Credit_Hours__c = 4.00;
            course.Maximum_External_Marks__c = 50.00;
            course.Total_Maximum_Marks_IA_External__c = 100.00;
            course.No_of_IA_s__c = '1';
            course.L_T_P__c='2:1:0';

            insert course;

            system.debug('course '+course);

            hed__Course_Offering__c courseOffering = new hed__Course_Offering__c();
            courseOffering.hed__Course__c = course.id;
            courseOffering.Name = 'EEE';
            courseOffering.hed__Term__c = term.Id;
            insert courseOffering;

            system.debug('courseOffering '+courseOffering);

            hed__Program_Enrollment__c PE = new hed__Program_Enrollment__c();
            PE.hed__Contact__c =con.Id;
            PE.hed__Account__c = acc.Id;

            insert  PE;
            system.debug('PE '+PE);

            Student_Semester_Mapping__c SSM  = new Student_Semester_Mapping__c();
            SSM.RecordTypeId = ccRtId;
            SSM.Name = 'SSM';
            SSM.Program_Enrollment__c = PE.Id;
            SSM.Section__c = term.ID;


            Insert SSM;
            system.debug('SSM '+SSM);

            Professors_Assigned__c FA = new Professors_Assigned__c();
            FA.Contacts__c = con.id;
            FA.Semester_Section__c = term.Id;
            FA.Name = 'TestRajiv';

            insert FA;
            system.debug('FA '+FA);

            term.Name = 'testterm1';
            term.Confirm_Mentor_Mapping__c = true;
            update term;

            system.debug('updated term '+term);

        }
    }








}