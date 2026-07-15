public  without sharing class revaSWAppointmentController {
    @AuraEnabled(cacheable=true)
    public static String getUserProfile() {
        // Get the current user's profile name
        Id profileId = UserInfo.getProfileId();
        String profileName = [SELECT Name FROM Profile WHERE Id = :profileId LIMIT 1].Name;
        
        // Define the profiles that are eligible to see the appointment type selection
        Set<String> eligibleProfiles = new Set<String>{'System Administrator', 'Professor'};
            
            // Check if the current profile is in the eligible set
           // return eligibleProfiles.contains(profileName);
           return profileName;
        
    }
    

    
    @AuraEnabled(cacheable=true)
    public static List<AppointmentWrapper> getAppointments() {
        List<AppointmentWrapper> appointments = new List<AppointmentWrapper>();
        
        try {
            // Get the Id and profile name of the current user
            Id currentUserId = UserInfo.getUserId();
            
            String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
            String currentUserEmail = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Email;
            
            // Query appointment and case information based on user profile
            if (profileName == 'Professor') {
                // Professor can see appointments they created (referrals)
                List<ManodhaaraAppointment__c> appointmentRecords = [SELECT Id, Name, Appointment_Date__c,HomeWork__c, Case__r.CaseNumber, Case__c, RSW_Appointment_Type__c,
                                                                     Appointment_Status__c, Time_Slot__c, Counsellig_Points__c, Email__c, Microsoft_Teams_Link__c, Counselling_Points__c,
                                                                     Medical_Information__c, Next_Follow_Up_Date__c, Start_Date_Time__c,Case__r.Owner.Name,
                                                                     End_Date_Time__c, Appointment_Date_Formatted__c, Time_Slot_Formatted__c, Case__r.OwnerId, Case__r.Description__c
                                                                     FROM ManodhaaraAppointment__c WHERE Appointment_Status__c != 'Cancelled'
                                                                     AND CreatedById = :currentUserId ORDER BY CreatedDate Desc];
                
              
                // Add appointments to the list
                for (ManodhaaraAppointment__c appointment : appointmentRecords) {
                    AppointmentWrapper wrapper = new AppointmentWrapper();
                    wrapper.appointmentId = appointment.Id;
                    wrapper.appointmentNumber = appointment.Name;
                    wrapper.appointmentDate = appointment.Appointment_Date_Formatted__c;
                    wrapper.notes = appointment.HomeWork__c;
                    wrapper.caseNumber = appointment.Case__r.CaseNumber;
                    wrapper.microsoftTeamsLink = appointment.Microsoft_Teams_Link__c;
                    wrapper.caseDescription = appointment.Case__r.Description__c;
                    wrapper.appointmentStatus = appointment.Appointment_Status__c; 
                    wrapper.timeSlot = appointment.Time_Slot_Formatted__c;
                    wrapper.counsellingPoints = appointment.Counselling_Points__c;
                    wrapper.email = appointment.Email__c;
                    wrapper.studentName = appointment.Case__r.Owner.Name;
                    wrapper.medicalInformation = appointment.Medical_Information__c;
                    wrapper.nextFollowUpdate = appointment.Next_Follow_Up_Date__c;
                    wrapper.appointmentType = appointment.RSW_Appointment_Type__c;
                    appointments.add(wrapper);
                }
            } else  {
                // Student can see appointments created by them or referrals for them
                List<ManodhaaraAppointment__c> appointmentRecords = [SELECT Id, Name, Appointment_Date__c,HomeWork__c, Case__r.CaseNumber,RSW_Appointment_Type__c,
                                                                     Appointment_Status__c, Time_Slot__c, Counsellig_Points__c, Email__c, Microsoft_Teams_Link__c, Counselling_Points__c,
                                                                     Medical_Information__c, Next_Follow_Up_Date__c, Start_Date_Time__c,Case__r.Owner.Name,
                                                                     End_Date_Time__c, Appointment_Date_Formatted__c, Time_Slot_Formatted__c, Case__r.OwnerId, Case__r.Description__c
                                                                     FROM ManodhaaraAppointment__c WHERE Appointment_Status__c != 'Cancelled'
                                                                     AND (CreatedById = :currentUserId OR Case__r.OwnerId = :currentUserId OR Email__c = :currentUserEmail) ORDER BY Id Desc];
                
                // Add appointments to the list
                for (ManodhaaraAppointment__c appointment : appointmentRecords) {
                    AppointmentWrapper wrapper = new AppointmentWrapper();
                    wrapper.appointmentId = appointment.Id;
                    wrapper.appointmentNumber = appointment.Name;
                    system.debug('appointment.Name:'+appointment.Name);
                    wrapper.appointmentDate = appointment.Appointment_Date_Formatted__c;
                    wrapper.notes = appointment.HomeWork__c;
                    wrapper.caseNumber = appointment.Case__r.CaseNumber;
                    wrapper.microsoftTeamsLink = appointment.Microsoft_Teams_Link__c;
                    wrapper.caseDescription = appointment.Case__r.Description__c;
                    wrapper.appointmentStatus = appointment.Appointment_Status__c; 
                    wrapper.timeSlot = appointment.Time_Slot_Formatted__c;
                    wrapper.counsellingPoints = appointment.Counselling_Points__c;
                    wrapper.email = appointment.Email__c;
                    wrapper.studentName = appointment.Case__r.Owner.Name;
                    wrapper.medicalInformation = appointment.Medical_Information__c;
                    wrapper.nextFollowUpdate = appointment.Next_Follow_Up_Date__c;
                    wrapper.appointmentType = appointment.RSW_Appointment_Type__c;
                    appointments.add(wrapper);
                }
            }
        } catch (Exception e) {
           // System.debug('An error occurred: ' + e.getMessage());
        }
        
        return appointments;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ManodhaaraAppointment__c> upcomingSessions() {
        Id currentUserId = UserInfo.getUserId();
        String currentUserEmail = [SELECT Email FROM User WHERE Id = :currentUserId LIMIT 1].Email;
        // Fetch appointments from source
        List<ManodhaaraAppointment__c> allAppointments = [SELECT Id, Name,Appointment_Status__c, Appointment_Date__c, Time_Slot_Formatted__c  FROM ManodhaaraAppointment__c WHERE Email__c = :currentUserEmail];

        // Filter appointments based on status and future date
        List<ManodhaaraAppointment__c> filteredAppointments = new List<ManodhaaraAppointment__c>();
        for (ManodhaaraAppointment__c appointment : allAppointments) {
            if (appointment.Appointment_Status__c == 'Scheduled' && appointment.Appointment_Date__c >= Date.today()) {
                filteredAppointments.add(appointment);
            }
        }

        return filteredAppointments;
    }

    
    @AuraEnabled
    public static void cancelAppointment(String appointmentId , String cancellationReason) {
        //String appointmentId = params.get('appointmentId');
        //system.debug('appointmentID'+appointmentId);
        if (String.isNotBlank(appointmentId)) {
            ManodhaaraAppointment__c appointment = [SELECT Id, Appointment_Status__c, Reason_For_Cancellation__c FROM ManodhaaraAppointment__c WHERE Id = :appointmentId LIMIT 1];
            
            
            if (appointment != null) {
                appointment.Appointment_Status__c = 'Cancelled';
                appointment.Reason_For_Cancellation__c = cancellationReason;
                update appointment;
               // Event deleteEvent = [SELECT Id from Event Where WhatId =:appointmentId];
               // // Check if there are related events before attempting to delete
               // if([SELECT Id from Event Where WhatId =:appointmentId] != null)
                    
             List<Event> relatedEvents = [SELECT Id FROM Event WHERE WhatId = :appointmentId];
            if (!relatedEvents.isEmpty()) {
                // Delete related events
                delete relatedEvents;
            }
                
            } else {
               // System.debug('No appointment found with ID: ' + appointmentId);
            }
        } else {
          //  System.debug('Appointment ID is blank or null.');
        }
    }
    
    @AuraEnabled
    public static NewAppointmentWrapper CreateNewAppointment(String appointmentId){
        
        ManodhaaraAppointment__c appointmentRecords = [SELECT Id, Name, Appointment_Date__c,HomeWork__c, Case__r.CaseNumber,  Case__c, RSW_Appointment_Type__c,
                                                                     Appointment_Status__c, Time_Slot__c, Counsellig_Points__c, Email__c,
                                                                     Medical_Information__c, Next_Follow_Up_Date__c, Start_Date_Time__c,Case__r.Owner.Name,
                                                                     End_Date_Time__c, Appointment_Date_Formatted__c, Time_Slot_Formatted__c, Case__r.OwnerId,Severity__c, 
                                                                     Mode_Of_Counselling__c, Case__r.RecordTypeId,Description__c, 
                                                                     Case__r.contactId, How_Am_I_Feeling_Today__c, Presenting_problem__c, Preferred_Language__c, 
                                                                     Angry__c, Stressed__c, Sad__c, Lonely__c, Hurt__c, Confused__c, Frightened__c, Anxious__c
                                                                     FROM ManodhaaraAppointment__c WHERE Id = :appointmentId ];
        
        
        //System.debug('Appointment records: '+appointmentRelatedCase);
        NewAppointmentWrapper newAppo = new NewAppointmentWrapper();

        If(appointmentRecords.Id != NULL){
            
            newAppo.appointmentId = appointmentRecords.Id;
            newAppo.appointmentNumber = appointmentRecords.name;
            newAppo.severity = appointmentRecords.Severity__c;
            newAppo.modeOfCounselling = appointmentRecords.Mode_Of_Counselling__c;
            newAppo.description = appointmentRecords.Description__c;
            newAppo.contactId = appointmentRecords.Case__r.contactId;
            newAppo.appointmentType = appointmentRecords.RSW_Appointment_Type__c;
            newAppo.howAmIFeeling = appointmentRecords.How_Am_I_Feeling_Today__c;
            newAppo.presentingProblem = appointmentRecords.Presenting_problem__c;
            newAppo.preferredLanguage = appointmentRecords.Preferred_Language__c;
            newAppo.angry = appointmentRecords.Angry__c;
            newAppo.stressed = appointmentRecords.Stressed__c;
            newAppo.sad = appointmentRecords.Sad__c;
            newAppo.lonely = appointmentRecords.Lonely__c;
            newAppo.hurt = appointmentRecords.Hurt__c;
            newAppo.confused = appointmentRecords.Confused__c;
            newAppo.frightened = appointmentRecords.Frightened__c;
            newAppo.anxious = appointmentRecords.Anxious__c;
            
        }
        system.debug('newAppo==>'+newAppo);
        Return newAppo;
        
       
        
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsForStudentPortal(String searchString) {
        String studentRecordtype = 'Student'; // Replace with the actual Profile Id
        searchString = '%' + searchString + '%';
        return [SELECT Id, Name,email,SRN_Number__c,Application_Number__c FROM Contact WHERE  Name LIKE :searchString];
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ManodhaaraAppointment__c> getExistingAppointments(String contactEmail) {
        return [SELECT Id, Appointment_Status__c FROM ManodhaaraAppointment__c WHERE Email__c =: contactEmail AND Appointment_Status__c IN ('Initiated', 'Scheduled')];
        //return [SELECT Id, Appointment_Status__c FROM ManodhaaraAppointment__c WHERE Email__c = 'srinivasu.veera@cloudodyssey.co' AND Appointment_Status__c IN ('Initiated', 'Scheduled')]; 
    }
    
    
   @AuraEnabled(cacheable=true)
    public static Boolean checkManodaraAppointments() {
        // Get the logged-in user's email (You might need to replace this with your actual logic)
        String loggedInUserEmail = UserInfo.getUserEmail();

        // Query Manodara appointments with 'Scheduled' or 'Initiated' status for the logged-in user's email
        List<ManodhaaraAppointment__c> manodaraAppointments = [SELECT Id FROM ManodhaaraAppointment__c
                                                             WHERE Email__c = :loggedInUserEmail
                                                             AND (Appointment_Status__c = 'Scheduled' OR Appointment_Status__c = 'Initiated')];

        // Return true if there are any Manodara appointments, otherwise return false
        return !manodaraAppointments.isEmpty();
    }
     
    
    // Wrapper class to hold appointment and case information
    public class AppointmentWrapper {
        @AuraEnabled public Id appointmentId;
        @AuraEnabled public String appointmentNumber;
        @AuraEnabled public Date appointmentDate;
        @AuraEnabled public String notes;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String microsoftTeamsLink;
        @AuraEnabled public String caseDescription;
        @AuraEnabled public String studentName;
        @AuraEnabled public String appointmentStatus;
        @AuraEnabled public String timeSlot;
        @AuraEnabled public String counsellingPoints;
        @AuraEnabled public String email;
        @AuraEnabled public String medicalInformation;
        @AuraEnabled public Date nextFollowUpdate;
        @AuraEnabled public String appointmentType;
    }
    
    public class NewAppointmentWrapper{
        @AuraEnabled public Id appointmentId;
        @AuraEnabled public String appointmentNumber;
        @AuraEnabled public Date appointmentDate;
        @AuraEnabled public String severity;
        @AuraEnabled public String modeOfCounselling;
        @AuraEnabled public String description;
        @AuraEnabled public Date selectedDate;
        @AuraEnabled public String timeSlot;
        @AuraEnabled public String selectedAppointmentType;
        @AuraEnabled public String preferredLanguage;
        @AuraEnabled public Id contactId;
        @AuraEnabled public String appointmentType;
        @AuraEnabled public String howAmIFeeling;
        @AuraEnabled public String presentingProblem;
        @AuraEnabled public Decimal angry;
        @AuraEnabled public Decimal stressed;
        @AuraEnabled public Decimal sad;
        @AuraEnabled public Decimal lonely;
        @AuraEnabled public Decimal hurt;
        @AuraEnabled public Decimal confused;
        @AuraEnabled public Decimal frightened;
        @AuraEnabled public Decimal anxious;
        }
}