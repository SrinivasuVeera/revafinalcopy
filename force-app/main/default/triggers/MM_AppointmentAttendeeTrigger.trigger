trigger MM_AppointmentAttendeeTrigger on sfal__AppointmentAttendee__c (after insert) {
    MM_AppointmentAttendeeTriggerHandler.sendMeetingInvite(trigger.newMap);
}