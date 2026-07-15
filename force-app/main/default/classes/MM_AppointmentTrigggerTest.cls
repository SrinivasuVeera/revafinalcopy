@isTest
private class MM_AppointmentTrigggerTest {
    
    
    
    @isTest
    static void AppointmentRecord(){
        
        
        
        // Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        
        
        
        //Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        //UserRole role = new UserRole(DeveloperName = 'PowerPartner', Name = 'PowerPartner');
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(adminUser){
            
            Set<String> customerUserTypes2 = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
                
                string acrtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            string acRcName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getName();
            
            Account acc = new Account();
            acc.Name = 'newAcc1';
            acc.RecordTypeId = acrtId;
            
            insert Acc;
            
            string cortId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
            string coRcName = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Professor').getName();
            
            contact con = new contact();
            con.LastName = 'portalTestUserv1';
            con.RecordTypeId = cortId;
            con.AccountId = acc.id;
            
            
            insert con;
            UserRole role = [Select PortalType, PortalAccountId From UserRole where PortalType ='CustomerPortal' limit 1];
            //ID ProfileID = [ Select id from Profile where name = 'Customer Portal Manager Custom'].id;
            //Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
            
            //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            //name = 'System Administrator'
            //Profile prfile = [select Id,name from Profile where UserType ='Standard' limit 1];
            //Profile prfile = [Select Id from Profile where   UserType in :customerUserTypes2 limit 1];
            //Profile prfile = [SELECT Id FROM Profile WHERE  UserType = 'CSPLitePortal'];
            //
            Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
                UserRole ur = [Select id,PortalType, PortalAccountId From UserRole where PortalType ='CustomerPortal' limit 1];
            system.debug('ur '+ur);
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
            
            
            Case cse = new Case();
            cse.Origin = 'Email';
            
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
            appt.Appointment_Status__c = 'Scheduled';
            
            appt.Name = 'TestAppt';
            
            insert appt;
            appt.Generate_Attendees__c = true;  
            appt.Appointment_Status__c = 'Scheduled';
            update appt;
            
            appt.Generate_Attendees__c = true;  
            appt.Appointment_Status__c = 'Cancelled';
            update appt;
            
            //  List<sfal__AppointmentAttendee__c> apattdLists = [select id from sfal__AppointmentAttendee__c where sfal__Appointment__c =: appt.id];
            //  system.debug('apattdList' + apattdLists);
            //  system.debug('apattdList' + apattdLists.size() );
            //  system.assertEquals(1, apattdLists.size());
        }
        
        
        
    }
    /*@isTest
    static void AppointmentRecord2(){
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(adminUser){
            string acrtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            string acRcName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getName();
            
            Account acc = new Account();
            acc.Name = 'newAcc1';
            acc.RecordTypeId = acrtId;
            
            insert Acc;
            
            string cortId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
            string coRcName = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Professor').getName();
            
            contact con = new contact();
            con.LastName = 'portalTestUserv1';
            con.RecordTypeId = cortId;
            con.AccountId = acc.id;
            
            
            insert con;
            UserRole role = [Select PortalType, PortalAccountId From UserRole where PortalType ='CustomerPortal' limit 1];
            UserRole ur = [Select id,PortalType, PortalAccountId From UserRole where PortalType ='CustomerPortal' limit 1];
            system.debug('ur '+ur);
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
            
            
            Case cse = new Case();
            cse.Origin = 'Email';
            
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
            appt.Generate_Attendees__c = true;  
            appt.Appointment_Status__c = 'Scheduled';
            
            appt.Name = 'TestAppt';
            
            insert appt;
            
            appt.sfal__Description__c = 'Desc';
            update appt;
            
            sfal__Appointment__c  sfApt = [SELECT id,Name,Generate_Attendees__c,Appointment_Status__c,
                                           sfal__StartDateTime__c,sfal__EndDateTime__c FROM  sfal__Appointment__c where Name ='TestAppt' Limit 1];
            system.debug('sfApt '+sfApt);
            sfApt.Generate_Attendees__c = true;  
            sfApt.Appointment_Status__c = 'Cancelled';
            
            update sfApt;
            system.debug('sfApt '+sfApt);    
            sfal__AppointmentAttendee__c appAttendee = [SELECT Id,sfal__Appointment__r.Appointment_Status__c ,sfal__Appointment__r.Name,
                                                        (SELECT Id,Subject,Meeting_Status__c FROM Tasks),
                                                        (SELECT Id, Subject,Meeting_Status__c FROM Events) 
                                                        FROM sfal__AppointmentAttendee__c Where sfal__Appointment__r.Name ='TestAppt'];
            system.assertEquals(sfApt.Appointment_Status__c, appAttendee.sfal__Appointment__r.Appointment_Status__c);
        }
    }*/
    
}