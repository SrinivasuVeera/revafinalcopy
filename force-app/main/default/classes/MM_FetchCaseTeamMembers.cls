public without sharing class MM_FetchCaseTeamMembers 
{    
    @AuraEnabled
    public static wrapperclass getCaseTeamMembers(string appId)
    {
        wrapperclass objwrap = new wrapperclass();
        set<id> set_caseids = new set<id>();
        set<id> set_conids = new set<id>();
        for(sfal__Appointment__c objapp : [select id,Name,sfal__RelatedCase__c from sfal__Appointment__c where id=:appId])
        {
            objwrap.objAppointment = objapp;
            set_caseids.add(objapp.sfal__RelatedCase__c);
        }
        if(set_caseids.size()>0)
        {            
            for(case objCase : [select id,(select id,MemberId,Member.name,ParentId  from TeamMembers) from case where id in: set_caseids])
            {
                for(CaseTeamMember tm :objCase.TeamMembers)
                {
                    set_conids.add(tm.MemberId);                    
                }
            }
            system.debug('===set_conids==='+set_conids);
            if(set_conids.size()>0)
            {
                for(user objusr :[select id,Name,ContactId from User where ContactId in: set_conids])
                {
                    objwrap.map_user.put(objusr.id,objusr.Name);
                }
            }
        }
        system.debug('===mapCST==='+objwrap.map_user);
        return objwrap;
    }
    @AuraEnabled
    public static Sucesswrapper ValidationAttendee(string appId,string userid,boolean sendmeating)
    {
        Sucesswrapper wrap = new Sucesswrapper();        
        for(sfal__AppointmentAttendee__c objappatt : [select Id,sfal__Appointment__c,sfal__Attendee__c,sfal__Attendee__r.Name,Send_Meeting_Invite__c from sfal__AppointmentAttendee__c
                                                      where sfal__Attendee__c=:userid and sfal__Appointment__c=:appId and Send_Meeting_Invite__c=:sendmeating])
        {
            wrap.ErrMessage ='Already Sent Meeting for '+objappatt.sfal__Attendee__r.Name;
        }
        
        return wrap; 
    }
    @AuraEnabled
    public static Sucesswrapper SaveAttendee(string appId,string userid,boolean sendmeating)
    {
        Sucesswrapper wrap = new Sucesswrapper();
        list<sfal__AppointmentAttendee__c> lst_att = new list<sfal__AppointmentAttendee__c>();
        string Caseid;
        if(!string.isBlank(userid))
        {
            set<id> set_contactids = new set<id>();
            set<id> set_caseids = new set<id>();
            for(user usr :[select id,Name,ContactId from User where id =: userid])
            {
                set_contactids.add(usr.ContactId);                
            }
            if(set_contactids.size()>0)
            {
                for(case objcase :  [select id,Contactid,Subject,Recordtype.Name from case where Contactid in: set_contactids and RecordType.Name =:'Mentee'  order by createddate desc limit 1])
                {
                    Caseid = objcase.id;
                }
            }
            system.debug('===Caseid==='+Caseid);
            if(!string.isBlank(Caseid))
            {                
                sfal__AppointmentAttendee__c objAtt = new sfal__AppointmentAttendee__c();
                objAtt.sfal__Appointment__c = appId;
                objAtt.sfal__Attendee__c = userid;
                objAtt.sfal__AdviseeRecord__c = Caseid;
                objAtt.Send_Meeting_Invite__c = sendmeating;
                lst_att.add(objAtt);
            }
            if(lst_att.size()>0)
            {
                try
                {
                    insert lst_att;
                    wrap.ErrMessage ='Success';
                }catch(exception ex)
                {
                    wrap.ErrMessage ='failure';
                }
            }
        }
        system.debug('===lst_att==='+lst_att);
        return wrap;
    }
    public class wrapperclass
    {
        @AuraEnabled public sfal__Appointment__c objAppointment{get;set;}
        @AuraEnabled public sfal__AppointmentAttendee__c objAttende{get;set;}
        @AuraEnabled public Map<id,string>  map_user{get;set;}
        public wrapperclass()
        {
            objAppointment = new sfal__Appointment__c();
            objAttende = new sfal__AppointmentAttendee__c();
            map_user =  new Map<id,string>();
        }
    } 
    public class Sucesswrapper
    {
        @AuraEnabled public string  ErrMessage{get;set;}       
    }
}