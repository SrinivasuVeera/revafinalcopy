public class MM_AppointmentAttendeeTriggerHandler {
    public static void sendMeetingInvite(Map<id,sfal__AppointmentAttendee__c> appAttdMap){
    
        List<Task> insertTask = new List<Task>();
        List<Event> lstEvent = new List<Event>();
        Id eventRtId = Schema.SObjectType.event.getRecordTypeInfosByName().get('SupportEvent').getRecordTypeId();
        List<sfal__AppointmentAttendee__c> appAttndList = [SELECT Id,Name,sfal__Appointment__r.Name,sfal__Appointment__r.sfal__AppointmentLocation__c,sfal__Attendee__c, 
                                                           sfal__Appointment__r.sfal__WebMeetingLink__c,sfal__Appointment__r.sfal__Description__c, 
                                                           sfal__Appointment__r.sfal__StartDateTime__c,sfal__Appointment__r.sfal__EndDateTime__c,
                                                           sfal__Attendee__r.contactId,sfal__Appointment__r.sfal__AppointmentLocation__r.Name,
                                                           sfal__Appointment__r.Category__c,sfal__Appointment__r.Sub_Category__c,
                                                           Send_Meeting_Invite__c FROM sfal__AppointmentAttendee__c WHERE Id =:appAttdMap.keySet() 
                                                           AND Send_Meeting_Invite__c =True];
        
        for(sfal__AppointmentAttendee__c apAtd:appAttndList){
            if(apAtd.Send_Meeting_Invite__c == true){
                Task tsk = new task();
                tsk.WhatId =apAtd.Id;
                tsk.Subject = apAtd.sfal__Appointment__r.Name;
                tsk.ownerId =  apAtd.sfal__Attendee__c;
                tsk.Category__c = apAtd.sfal__Appointment__r.Category__c;
                tsk.Sub_Category__c = apAtd.sfal__Appointment__r.Sub_Category__c;
                insertTask.add(tsk);
                
                event objEvent = new event();
                objEvent.WhatId = apAtd.Id; 
                obJEvent.Subject = apAtd.sfal__Appointment__r.Name;
                objEvent.ownerId = apAtd.sfal__Attendee__c;
                objEvent.RecordTypeId = eventRtId;
                objEvent.WhoId =  apAtd.sfal__Attendee__r.contactId;
                objEvent.Location = apAtd.sfal__Appointment__r.sfal__AppointmentLocation__r.Name;
                objEvent.Description = '';
                objEvent.Category__c = apAtd.sfal__Appointment__r.Category__c;
                objEvent.Sub_Category__c = apAtd.sfal__Appointment__r.Sub_Category__c;
                if(apAtd.sfal__Appointment__r.sfal__WebMeetingLink__c != null){
                    objEvent.Description = apAtd.sfal__Appointment__r.sfal__WebMeetingLink__c;
                }
                if(apAtd.sfal__Appointment__r.sfal__Description__c != null){
                    objEvent.Description =  objEvent.Description+' '+ apAtd.sfal__Appointment__r.sfal__Description__c;
                }
                
                objEvent.StartDateTime = apAtd.sfal__Appointment__r.sfal__StartDateTime__c;
                objEvent.EndDateTime = apAtd.sfal__Appointment__r.sfal__EndDateTime__c;
                lstEvent.add(objEvent);
            }
        }
        if(!insertTask.isEmpty()){
                insert insertTask;
                insert lstEvent;
            }
            
    }
}