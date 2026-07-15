public without Sharing class MM_AppointmentTriggerHandler {
    public static boolean appointmentTriggerRecurisve = false;
    public static void createAppointmentAttendesMethod2(List<sfal__Appointment__c> newAppList){
        List<sfal__AppointmentAttendee__c> appattendeesToInsert = new List<sfal__AppointmentAttendee__c>();
        map<id,sfal__Appointment__c> mapAppointment = new map<id,sfal__Appointment__c>();
        //map<id,sfal__Appointment__c> mapAppointmentName = new map<id,sfal__Appointment__c>();
        map<id,sfal__Appointment__c> mapAppointmentName;
        set<id> caseIds = new set<id>();
        set<id> appoitMentIds = new set<id>();
        for(sfal__Appointment__c ea:newAppList){
            if(ea.Generate_Attendees__c ==true ){
                caseIds.add(ea.sfal__RelatedCase__c); 
                mapAppointment.put(ea.sfal__RelatedCase__c,ea);
                //mapAppointmentName.put(ea.id,ea);
                appoitMentIds.add(ea.Id);
               
            }
            
        }
        If(appoitMentIds.size()>0){
            List<sfal__Appointment__c> obApt = [SELECT Id,Name,sfal__WebMeetingLink__c,sfal__StartDateTime__c,Sub_Category__c,Category__c,Appointment_Status__c,
                                                sfal__EndDateTime__c,sfal__Description__c,sfal__AppointmentLocation__c,sfal__AppointmentLocation__r.Name
                                                from sfal__Appointment__c where id=:appoitMentIds];
            mapAppointmentName = new Map<id,sfal__Appointment__c>(obApt);
        }
        
        set<id> contactIds = new set<id>();
        Map<id,id> mapconUserIds = new Map<id,id>();
        
        //Storing userid and contact id to use it in event creation
        Map<id,id> userConMap = new Map<id,id>();
        Map<id,id> CaseMap = new Map<id,id>();
        
        //system.debug('contactIds '+contactIds);
        List<Case> caseList = new List<Case>();
        for(case objCase : [select id,(select id,MemberId,ParentId  from TeamMembers) from case where id in:caseIds]){
            for(CaseTeamMember tm:objCase.TeamMembers){
                contactIds.add(tm.MemberId);
                
            }
            caseList.add(objCase);
        }
        //system.debug('contactIds '+contactIds); 
        if(!contactIds.isempty()){
            List<user> users = [SELECT Id,ContactId FROM User WHERE contactId =: contactIds];
             for(user u:users){
                    mapconUserIds.put(u.contactId,u.id);
                 userConMap.put(u.Id,u.ContactId);
                }
            Id caseRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mentee').getRecordTypeId();    
            for(case caseRec : [SELECT id,ContactId From Case WHERE ContactId =: contactIds AND RecordTypeId =: caseRtId ORDER By CreatedDate ASC]){
               CaseMap.put(caseRec.ContactId,caseRec.id);
            }
            /*system.debug('contactIds '+contactIds); 
            system.debug('contactIds '+contactIds.size());
            system.debug('users '+users); 
             system.debug('mapconUserIds '+mapconUserIds); 
            system.debug('mapconUserIds '+mapconUserIds.size()); */
        }
       
       //Id attendeeRtId = Schema.SObjectType.sfal__AppointmentAttendee__c.getRecordTypeInfosByName().get('AdvisingEvent').getRecordTypeId();
       
        //system.debug('+++++++++++++'+caseList.size());   
        for(case objCase : caseList){
        //system.debug('+++++++++++++'+objCase.TeamMembers.size());
            for(CaseTeamMember tm:objCase.TeamMembers){
                
                //system.debug('+++++++++++++'+tm.Id);
                
                if(mapconUserIds.containsKey(tm.MemberId)){
                    
                    //system.debug('+++++++++++++'+tm.MemberId);
                    sfal__Appointment__c ap = mapAppointment.get(objCase.id);
                    sfal__AppointmentAttendee__c apat = new sfal__AppointmentAttendee__c();
                    apat.sfal__Appointment__c = ap.Id;
                    apat.sfal__StatusUpdatedDate__c = system.today();
                  //  apat.sfal__AdviseeRecord__c = objCase.Id;
                    if(CaseMap.containsKey(tm.MemberId)){
                        apat.sfal__AdviseeRecord__c =  CaseMap.get(tm.MemberId);
                    }
                    apat.sfal__Attendee__c = mapconUserIds.get(tm.MemberId);
                    //apat.recordTypeId = attendeeRtId;
                    appattendeesToInsert.add(apat); 
                }
                
                
            }
        }
          
        
        if(!appattendeesToInsert.isempty()){
            insert appattendeesToInsert;
          
           Id eventRtId = Schema.SObjectType.event.getRecordTypeInfosByName().get('SupportEvent').getRecordTypeId();     
            MM_AppointmentTriggerHandler.appointmentTriggerRecurisve = true;
            List<Task> insertTask = new List<Task>();
            List<Event> lstEvent = new List<Event>();
            for(sfal__AppointmentAttendee__c apAtd:appattendeesToInsert){
               Task tsk = new task();
               tsk.WhatId = apAtd.Id;
                tsk.Subject = mapAppointmentName.get(apAtd.sfal__Appointment__c).Name;
                tsk.ownerId = apAtd.sfal__Attendee__c;
                tsk.Category__c = mapAppointmentName.get(apAtd.sfal__Appointment__c).Category__c;  
                tsk.Sub_Category__c = mapAppointmentName.get(apAtd.sfal__Appointment__c).Sub_Category__c; 
                tsk.Meeting_Status__c = mapAppointmentName.get(apAtd.sfal__Appointment__c).Appointment_Status__c;
                
                insertTask.add(tsk);
                
                event objEvent = new event();
                objEvent.WhatId = apAtd.Id;
                objEvent.Subject = mapAppointmentName.get(apAtd.sfal__Appointment__c).Name;
                objEvent.ownerId = apAtd.sfal__Attendee__c;
                objEvent.Category__c = mapAppointmentName.get(apAtd.sfal__Appointment__c).Category__c; 
                objEvent.Sub_Category__c = mapAppointmentName.get(apAtd.sfal__Appointment__c).Sub_Category__c;
                objEvent.Meeting_Status__c = mapAppointmentName.get(apAtd.sfal__Appointment__c).Appointment_Status__c;
                
                objEvent.RecordTypeId = eventRtId;
                
                //fetching Contact Id from  userConMap
                objEvent.WhoId = userConMap.get(apAtd.sfal__Attendee__c);
                
                objEvent.Location = mapAppointmentName.get(apAtd.sfal__Appointment__c).sfal__AppointmentLocation__r.Name;
                if( mapAppointmentName.get(apAtd.sfal__Appointment__c).sfal__WebMeetingLink__c != null && +mapAppointmentName.get(apAtd.sfal__Appointment__c).sfal__Description__c != null){
                    objEvent.Description = mapAppointmentName.get(apAtd.sfal__Appointment__c).sfal__WebMeetingLink__c +' '+mapAppointmentName.get(apAtd.sfal__Appointment__c).sfal__Description__c;
                }
                
                objEvent.StartDateTime = mapAppointmentName.get(apAtd.sfal__Appointment__c).sfal__StartDateTime__c;    
                objEvent.EndDateTime = mapAppointmentName.get(apAtd.sfal__Appointment__c).sfal__EndDateTime__c;     
                lstEvent.add(objEvent);
                
                
            }
            
            if(!insertTask.isEmpty()){
                insert insertTask;
                insert lstEvent;
            }
            
        } 
        
    }
    public static void meetingStatus(Map<id,sfal__Appointment__c>newAppMap){
        List<sfal__AppointmentAttendee__c> appAttendesList = [SELECT Id,sfal__Appointment__r.Appointment_Status__c ,
                                                              (SELECT Id,Subject,Meeting_Status__c FROM Tasks),
                                                              (SELECT Id, Subject,Meeting_Status__c FROM Events) 
                                                              FROM sfal__AppointmentAttendee__c WHERE sfal__Appointment__c =:newAppMap.Keyset()];
        list<Task> taskstoUpdate = new List<Task>();
        List<Event> eventsToUpdate = new List<Event>();
         //MM_AppointmentTriggerHandler.appointmentTriggerRecurisve = true;
        for(sfal__AppointmentAttendee__c apATde:appAttendesList){
            //List<Task> tsk = apATde.tasks;
            //tsk.Meeting_Status__c = apATde.sfal__Appointment__r.Appointment_Status__c;
            for(Task tsk:apATde.tasks){
                tsk.Meeting_Status__c = apATde.sfal__Appointment__r.Appointment_Status__c;
                taskstoUpdate.add(tsk);
            }
            for(Event evt:apAtde.events){
                evt.Meeting_Status__c = apATde.sfal__Appointment__r.Appointment_Status__c;
                eventsToUpdate.add(evt);
            }
            
            
        }
        if(!taskstoUpdate.isEmpty()){
            update taskstoUpdate;
            
        }
        if(!eventsToUpdate.isEmpty()){
            update eventsToUpdate;
        }
    }
}