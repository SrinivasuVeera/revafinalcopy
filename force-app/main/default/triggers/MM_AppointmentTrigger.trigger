trigger MM_AppointmentTrigger on sfal__Appointment__c (after insert,after update) {
    
    /*if(appointmentTriggerHandler.appointmentTriggerRecurisve == false){
appointmentTriggerHandler.createAppointmentAttendesMethod2(trigger.new, trigger.oldMap);
}*/
    
    if(MM_AppointmentTriggerHandler.appointmentTriggerRecurisve == false ){
        if(Trigger.isInsert){
            for(sfal__Appointment__c ap:trigger.new){
                if(ap.Generate_Attendees__c == true){
                    
                    MM_appointmentTriggerHandler.createAppointmentAttendesMethod2(trigger.new);
                }
            }
        }
        
    }
    
    if(MM_AppointmentTriggerHandler.appointmentTriggerRecurisve == false ){
        if(Trigger.IsUpdate){
            for(sfal__Appointment__c apt:trigger.new){
                if(apt.Generate_Attendees__c == true && trigger.OldMap.get(apt.Id).Generate_Attendees__c != apt.Generate_Attendees__c){
                    MM_AppointmentTriggerHandler.createAppointmentAttendesMethod2(trigger.new);
                }
                if(apt.Generate_Attendees__c == true && trigger.OldMap.get(apt.Id).Generate_Attendees__c == apt.Generate_Attendees__c && apt.Appointment_Status__c != trigger.OldMap.get(apt.Id).Appointment_Status__c ){
                   
                    MM_AppointmentTriggerHandler.meetingStatus(trigger.newMap);
                }
            }
        }
    }
    

}