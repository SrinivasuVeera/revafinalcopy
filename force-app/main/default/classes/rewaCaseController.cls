public without sharing class rewaCaseController {
    @AuraEnabled
    public static void createAppointmentCaseEvent(String severity, String modeOfCounselling, String preferredLanguage, string howAmIFeeling, string presentingProblem, String description, Date selectedDate, String timeSlot, String selectedAppointmentType, Integer selectYear,Integer selectMonth,Integer selectDay,Integer selectStarthours,Integer selectStartminutes,Integer selectEndhours,Integer selectEndminutes,string selectContact,Integer angry, Integer stressed, Integer sad, Integer lonely, Integer hurt, Integer confused, Integer frightened ,Integer anxious, String OtherPresentingProblem) {
        
        // Get the current user's contact Id
        Id currentUserId = UserInfo.getUserId();
       //system.debug('angry==:'+angry);
        
        //Get the record type id
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Manodhaara' LIMIT 1];
        //system.debug('recordTypes--:'+recordTypes[0].Id);
        
        
        String email;
        ID ids;
        //system.debug('selectContact:'+selectContact);
        if (!string.isBlank(selectContact)) {
            //Get existing contact details
            Contact con = [SELECT Id , hed__WorkEmail__c FROM Contact WHERE Id=:selectContact LIMIT 1]; 
            email = con.hed__WorkEmail__c; 
            
            // Get existing user details
            User userId = [SELECT Id , Email FROM User WHERE email =:con.hed__WorkEmail__c LIMIT 1];
            ids = userId.Id;
        } else {
            User userInfos = [SELECT Id, contactId, FirstName, LastName, Email From User WHERE Id=:currentUserId];
            //system.debug('userInfos:'+userInfos);
            email = userInfos.Email; // Use the logged-in user's contact Id
            ids = userInfos.ID;
        }
        
        //System.debug('ContactId--->>> '+email);
       
        
        //Contact currentUserContact = [SELECT Id,Name FROM Contact WHERE OwnerId = :currentUserId LIMIT 1];
        //system.debug('currentUserContact:'+currentUserContact.Name);
        
        // Check if the user's contact has an open case
        List<Case> existingCase = [SELECT Id, Status, Contactemail, OwnerId FROM Case WHERE Contactemail = :email AND Status != 'Closed' AND RecordType.Name ='Manodhaara'LIMIT 1];
        
        //Get the contact record with selected email id
        List<Contact> conList = [SELECT Id, hed__WorkEmail__c, hed__AlternateEmail__c,Personal_Email__c, Email from Contact WHERE hed__WorkEmail__c =: email];
        
        if (!existingCase.isEmpty()) {
            // An existing open case is found, so create a new appointment related to it
            ManodhaaraAppointment__c newAppointment = new ManodhaaraAppointment__c(
                Case__c = existingCase[0].Id,
                Appointment_Date__c = selectedDate,
                RSW_Appointment_Type__c = selectedAppointmentType,
                Severity__c = severity,
                Mode_Of_Counselling__c = modeOfCounselling,
                How_Am_I_Feeling_Today__c = howAmIFeeling,
                Preferred_Language__c = preferredLanguage,
                Presenting_problem__c = presentingProblem,
                Description__c = description,
                Angry__c = Angry,
                Stressed__c = Stressed,
                Sad__c = Sad,
                Lonely__c = Lonely,
                Hurt__c = Hurt,
                Confused__c = Confused,
                Frightened__c = Frightened,
                Anxious__c = Anxious,
                Start_Date_Time__c = DateTime.newInstance(selectYear, selectMonth, selectDay, selectStarthours, selectStartminutes, 0),
                End_Date_Time__c = DateTime.newInstance(selectYear, selectMonth, selectDay, selectEndhours, selectEndminutes, 0),
                Other_Presenting_Problem__c = OtherPresentingProblem
                // Add other Appointment fields as needed
            );
            insert newAppointment;
            
            
            
            // Fetch Event details (assuming it's a separate method)
            fetchEventDetails(selectedDate);
        }
        else {
            // Create a Case record
            Case newCase = new Case(
                Severity__c = severity,
                Description = description,
                ModeOfCounselling__c = modeOfCounselling,
                PreferredLanguage__c = preferredLanguage,
                Description__c = description,
                OwnerId = ids,
                contactId = conList[0].id,
                RecordTypeId = recordTypes[0].Id
                
            );
            insert newCase;
            
            //quering out the case
            Case caseupdated= [SELECT Id , Contactemail, contactId FROM Case WHERE Id =:newCase.Id LIMIT 1 ];
            
            
            // Create an Appointment record related to the Case
            ManodhaaraAppointment__c newAppointment = new ManodhaaraAppointment__c(
                Case__c = newCase.Id,
                Appointment_Date__c = selectedDate,
                RSW_Appointment_Type__c = selectedAppointmentType,
                Severity__c = severity,
                Mode_Of_Counselling__c = modeOfCounselling,
                How_Am_I_Feeling_Today__c = howAmIFeeling,
                Preferred_Language__c = preferredLanguage,
                Presenting_problem__c = presentingProblem,
                Description__c = description,
                Angry__c = Angry,
                Stressed__c = Stressed,
                Sad__c = Sad,
                Lonely__c = Lonely,
                Hurt__c = Hurt,
                Confused__c = Confused,
                Frightened__c = Frightened,
                Anxious__c = Anxious,
                Start_Date_Time__c = DateTime.newInstance(selectYear, selectMonth, selectDay, selectStarthours, selectStartminutes, 0),
                End_Date_Time__c = DateTime.newInstance(selectYear, selectMonth, selectDay, selectEndhours, selectEndminutes, 0)
                
                // Add other Appointment fields as needed
            );
            insert newAppointment;
            // Assuming each time slot is 1 hour
            
            
            fetchEventDetails(selectedDate);
        }  
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Event> fetchEventDetails(Date selectedDate) {
        
        //getting counsellor details
        Counsellor_Details__mdt counsellorId = [SELECT Id__c from Counsellor_Details__mdt][0];
         Id UserId = counsellorId.Id__c;
       
        return [
            SELECT Id, Subject, StartDateTime, EndDateTime, EndDate
            FROM Event
            WHERE EndDate = :selectedDate
            AND OwnerId = :UserId
        ];
    }
    
      @AuraEnabled(cacheable=true)
    public static List<Event> getEvents() {
        Counsellor_Details__mdt counsellorId = [SELECT Id__c from Counsellor_Details__mdt][0];
         Id UserId = counsellorId.Id__c;
        
        return [SELECT Id, Subject, StartDateTime, IsAllDayEvent, EndDateTime 
                FROM Event WHERE OwnerId = :UserId
                ORDER BY CreatedDate DESC
                LIMIT 100];
    }
    

@AuraEnabled(cacheable=true)
    public static void RescheduleAppointment(ID ids) {
        System.debug('ids--- ' + ids);
       
        
    }
    
    
 public static void updateCaseEmailFromContactEmail(List<Case> newCases) {
        Set<Id> contactIds = new Set<Id>();
        List<Case> casesToUpdate = new List<Case>();
        
        // Collecting the Contact Ids from the new Cases
        for (Case newCase : newCases) {
            if (newCase.ContactId != null) {
                contactIds.add(newCase.ContactId);
               // system.debug('newCase.ContactId:'+newCase.ContactId);
            }
        }
        
        // Fetching the Contact Emails
        Map<Id, Contact> contactIdToEmailMap = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id IN :contactIds]);
        
        // Updating Case Emails
        for (Case newCase : newCases) {
            if (newCase.ContactId != null && contactIdToEmailMap.containsKey(newCase.ContactId)) {
                newCase.Contact_Email__c = contactIdToEmailMap.get(newCase.ContactId).Email;
              //  system.debug('newCase.Contact_Email__c:'+newCase.Contact_Email__c);
                casesToUpdate.add(newCase); // Add to the list of cases to update
            }
        }
        
        // Update the Cases
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
           // system.debug('casesToUpdate:'+casesToUpdate);
        }
    }
    
     
    @AuraEnabled(cacheable=true)
    public static List<CaseWithAppointments> getCasesWithAppointments(Id contactId) {
        List<CaseWithAppointments> casesWithAppointments = new List<CaseWithAppointments>();
        
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Manodhaara' LIMIT 1];
        //system.debug('recordTypes--:'+recordTypes[0].Id);

        // Query Cases and related Manodhaara Appointments for the given Contact
        List<Case> cases = [SELECT Id,CaseNumber, Description, (SELECT Id,Name, Appointment_Date__c, Time_Slot_Formatted__c, Notes_For_Counsellor__c FROM ManodhaaraAppointments__r Order By Name Desc) FROM Case WHERE (ContactId = :contactId AND RecordTypeId = :recordTypes[0].Id) Order By CaseNumber Desc];

        for (Case caseRecord : cases) {
            CaseWithAppointments caseWithAppointments = new CaseWithAppointments();
            caseWithAppointments.Cases = caseRecord;
            caseWithAppointments.Appointments = caseRecord.ManodhaaraAppointments__r;

            casesWithAppointments.add(caseWithAppointments);
        }

        return casesWithAppointments;
    }

    public class CaseWithAppointments {
        @AuraEnabled public Case Cases { get; set; }
        @AuraEnabled public List<ManodhaaraAppointment__c> Appointments { get; set; }
    }
}