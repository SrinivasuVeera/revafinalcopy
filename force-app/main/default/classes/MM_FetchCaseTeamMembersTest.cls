@isTest
private class MM_FetchCaseTeamMembersTest {
    @isTest
    static void appointAttendeInsert(){
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        
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
             con.hed__WorkEmail__c='123@reva.edu.in';
            con.Email = 'test@reva.edu.in';
            //ObjCon1.Email ='test@342bctest.com';
            con.hed__Preferred_Email__c='Personal Email';
            
            
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
            string caseRtMenteeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mentee').getRecordTypeId();
            Case cse = new Case();
            cse.RecordTypeId = caseRtMenteeId;
            cse.Origin = 'Email';
            cse.ContactId = con.Id;
            
            insert cse;
            CaseTeamRole  ctr= [SELECT Id, Name, AccessLevel FROM CaseTeamRole Where Name='Student Member' limit 1 ];
            CaseTeamMember ctm = new CaseTeamMember();
            ctm.MemberId = con.id;
            ctm.ParentId = cse.Id;
            ctm.TeamRoleId = ctr.Id;
            insert ctm;
            
            sfal__Appointment__c appt = new sfal__Appointment__c();
            appt.sfal__StartDateTime__c = system.today();
            appt.sfal__EndDateTime__c  =system.today().addDays(7);
            appt.sfal__RelatedCase__c = cse.Id;
            appt.sfal__WebMeetingLink__c ='googgle.com';
            appt.sfal__Description__c = 'Test';
            appt.Name = 'TestAppt';
            
            insert appt;
            sfal__AppointmentAttendee__c apAtd = new sfal__AppointmentAttendee__c();
            apAtd.sfal__Attendee__c = newUser1.id;
            apATd.Generate_Attendees__c = true;
            apATd.sfal__Appointment__c = appt.Id;
            apAtd.sfal__AdviseeRecord__c = cse.id;
            apAtd.sfal__StatusUpdatedDate__c = system.today();
            apAtd.Send_Meeting_Invite__c = true;
            insert apAtd;
          
           Test.startTest();
            MM_FetchCaseTeamMembers.getCaseTeamMembers(appt.Id);
            MM_FetchCaseTeamMembers.SaveAttendee(appt.Id, newUser1.id, true);
            List<CaseTeamMember> cst =[select id,MemberId,Member.name,ParentId  from CaseTeamMember]; 
            system.assertEquals(1, cst.size());
            Test.stopTest();
            
        }
        
        
    }
}