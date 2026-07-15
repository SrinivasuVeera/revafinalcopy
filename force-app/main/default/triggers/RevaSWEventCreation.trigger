trigger RevaSWEventCreation on ManodhaaraAppointment__c (after update) {

    //getting counsellor details
     Counsellor_Details__mdt counsellorId = [SELECT Id__c from Counsellor_Details__mdt][0];
    
     List<ManodhaaraAppointment__c> approvedAppointments = new List<ManodhaaraAppointment__c>();

    // Loop through the trigger records to find approved appointments
    for (ManodhaaraAppointment__c appointment : Trigger.new) {
        // Check if the Appointment_Status__c field is changed to "Approved"
        if (Trigger.oldMap.get(appointment.Id).Appointment_Status__c != 'Scheduled' &&
            appointment.Appointment_Status__c == 'Scheduled') {
            approvedAppointments.add(appointment);
        }
    }
    
    if (!approvedAppointments.isEmpty()) {
        List<Event> eventsToInsert = new List<Event>();

        for (ManodhaaraAppointment__c approvedAppointment : approvedAppointments) {
            Event newEvent = new Event();
            // Set appropriate fields on the Event object based on the ManodhaaraAppointment__c fields
            newEvent.Subject = 'Appointment: ' + approvedAppointment.Name;
            newEvent.WhatId = approvedAppointment.Id;
            newEvent.OwnerId = counsellorId.Id__c;
            newEvent.StartDateTime = approvedAppointment.Start_Date_Time__c;
            newEvent.EndDateTime = approvedAppointment.End_Date_Time__c; // Adjust based on your requirements
            // Set other fields as needed
            eventsToInsert.add(newEvent);
        }

        // Insert events
        insert eventsToInsert;
    }
}