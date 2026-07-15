global with sharing class FacilityRequestCancellationController {
     private static final String COMMON_SENDER = 'alerts@reva.edu.in';
   @AuraEnabled(cacheable=true)
    public static List<Facility_Request__c> getUserFacilityRequests() {

        String currentUserEmail = UserInfo.getUserEmail(); 

        return [
            SELECT Id, Name, Facility_Type__c, Building_Name__c, Floor__c, Room_No__c,
                   Start_Date__c, End_Date__c, Start_Time__c, End_Time__c,CreatedBy.Email,
                   TemplateName__c, Requester_Email__c, RequesterName__c, Requester_Phone__c,
                   Additional_Amenities_Required2__c, Reason_of_Cancelation__c
            FROM Facility_Request__c
            WHERE CreatedBy.Email = :currentUserEmail
             // AND TemplateName__c != 'Rejected'
            ORDER BY Start_Date__c DESC
        ];
    }

    @AuraEnabled
    global static String cancelFacilityRequest(Id recordId, String reason) {

        Facility_Request__c req = [
            SELECT Id, Name, TemplateName__c, Start_Date__c, End_Date__c,
                   Start_Time__c, End_Time__c,
                   Requester_Email__c, RequesterName__c, Requester_Phone__c,
                   Facility__c, Facility__r.Name,
                   Approver_Email__c, Approver_Name__c, Approver_phone__c,
                   Reason_of_Cancelation__c
            FROM Facility_Request__c
            WHERE Id = :recordId
            LIMIT 1
        ];

               // Validate start date/time presence
        if (req.Start_Date__c == null || req.Start_Time__c == null) {
            return 'Unable to determine event start time. Cancellation cannot be processed.';
        }

        // Combine Start Date + Start Time → Datetime
        Datetime eventStartDateTime = Datetime.newInstance(req.Start_Date__c, req.Start_Time__c);

        // Cutoff = 2 hours before start
        Datetime cutoffTime = eventStartDateTime.addHours(-2);

        // Compare against now
        if (Datetime.now() > cutoffTime) {
            return 'You can cancel this booking only up to 2 hours before the event start time.';
        }
        //Approval
        Boolean isUnderApproval = false;

        List<ProcessInstance> pi = [
            SELECT Id, Status
            FROM ProcessInstance
            WHERE TargetObjectId = :recordId
            LIMIT 1
        ];

        if (!pi.isEmpty() && pi[0].Status == 'Pending') {
            isUnderApproval = true;
        }
        
    // Recall approval process ONLY if TemplateName__c = "Requested"
     if (isUnderApproval) {
            System.debug(' Record is under approval. Initiating recall...');

            try {
                List<ProcessInstanceWorkitem> pendingItems = [
                    SELECT Id
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId = :recordId
                ];

                for (ProcessInstanceWorkitem wi : pendingItems) {
                    Approval.ProcessWorkitemRequest recallReq = new Approval.ProcessWorkitemRequest();
                    recallReq.setAction('Removed');
                    recallReq.setWorkitemId(wi.Id);

                    Approval.process(recallReq);
                }

                System.debug(' Approval request recalled successfully.');

            } catch (Exception ex) {
                System.debug(' Error recalling approval: ' + ex.getMessage());
                return 'Error recalling approval process. Contact administrator.';
            }
        } else {
            System.debug('ℹ No active approval process found. Skipping recall.');
        }

        //if approved
        req.TemplateName__c = 'Rejected';
        req.Reason_of_Cancelation__c = reason;
        
        try {
            update req;
          // sendCancellationEmails(req);
          //  sendWhatsAppNotifications(req);
          if (!String.isBlank(reason)) {
           Eventhallcanclenotification.sendAll(req.Id);
          }
            
        } catch (Exception e) {
         System.debug(' CANCEL ERROR: ' + e.getMessage());
         System.debug(' CANCEL ERROR STACK: ' + e.getStackTraceString());
         throw e; // IMPORTANT → shows real error in console
         }

        return 'Your booking has been cancelled successfully.';
     }

    global static void sendCancellationEmails(Facility_Request__c req) {
    String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
    String recordUrl = baseUrl + '/lightning/r/Facility_Request__c/' + req.Id + '/view';

    // ---------- Date & Time Formatting ----------
    String startDateFormatted = 'N/A';
    String endDateFormatted   = 'N/A';
    String startTimeFormatted = 'N/A';
    String endTimeFormatted   = 'N/A';

    // If both Date and Time are present, merge them into a Datetime
    if (req.Start_Date__c != null) {
        startDateFormatted = req.Start_Date__c.format(); // default org/user date format
        if (req.Start_Time__c != null) {
            Datetime startDT = Datetime.newInstance(req.Start_Date__c, req.Start_Time__c);
            startTimeFormatted = startDT.format('hh:mm a', 'Asia/Kolkata');
        }
    }

    if (req.End_Date__c != null) {
        endDateFormatted = req.End_Date__c.format();
        if (req.End_Time__c != null) {
            Datetime endDT = Datetime.newInstance(req.End_Date__c, req.End_Time__c);
            endTimeFormatted = endDT.format('hh:mm a', 'Asia/Kolkata');
        }
    }

    // ---------- Build Event Details ----------
    String eventDetails =
        //'Event Name: ' + req.Name + '\n' +
        //'Facility: ' + req.Facility__r.Name + '\n' +
        'Facility: ' + (req.Facility__r != null ? req.Facility__r.Name : 'N/A') + '\n'+
        'Start Date: ' + startDateFormatted + '\n' +
        'Start Time: ' + startTimeFormatted + '\n' +
        'End Date: ' + endDateFormatted + '\n' +
        'End Time: ' + endTimeFormatted + '\n' +
        'Reason for Cancellation: ' + (req.Reason_of_Cancelation__c != null ? req.Reason_of_Cancelation__c : 'N/A') + '\n\n';

     // Email to Request user 
    if (String.isNotBlank(req.Requester_Email__c)) {
        Messaging.SingleEmailMessage userMail = new Messaging.SingleEmailMessage();
        userMail.setToAddresses(new String[]{req.Requester_Email__c});
        userMail.setSubject('Event Hall Booking Cancellation Confirmed');
        userMail.setPlainTextBody(
            'Dear ' + req.RequesterName__c + ',\n\n' +
            'Your Event Hall booking has been successfully cancelled.\n\n' +
            eventDetails +
            'Regards,\nREVA University'
        );
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ userMail });
        System.debug('>>> [sendCancellationEmails] Sent cancellation mail to User: ' + req.Requester_Email__c);
    }

    // Email to Admin 
    String adminEmail;
    String adminName;

    if (req.Approver__r != null && String.isNotBlank(req.Approver_Email__c)) {
        adminEmail = req.Approver_Email__c;
        adminName = req.Approver_Name__c;
    } else {
        adminEmail = 'facilities@reva.edu.in';
        adminName = 'Facility Admin';
    }

    Messaging.SingleEmailMessage adminMail = new Messaging.SingleEmailMessage();
    adminMail.setToAddresses(new String[]{adminEmail});
    adminMail.setSubject('Event Hall Booking is Cancelled');
    adminMail.setPlainTextBody(
        'Dear ' + adminName + ',\n\n' +
        'Event Hall booking has been cancelled by ' + req.RequesterName__c + '.\n\n' +
        eventDetails +
        'Cancelled By: ' + req.RequesterName__c + 
        (String.isNotBlank(req.Requester_Phone__c) ? ' (' + req.Requester_Phone__c + ')' : '') + '\n\n' +
        'Please click on the link to see the details:\n' + recordUrl + '\n\n' +
        'Regards,\nREVA University'
    );
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ adminMail });
    System.debug('>>> Sent cancellation mail to Admin: ' + adminEmail);

    // Email to Facility Contacts
    List<Facility_Contact__c> contacts = [
        SELECT Id, Contact_Name__c, Contact_Email__c, Contact_Mobile__c
        FROM Facility_Contact__c
        WHERE Facility__c = :req.Facility__c
    ];

    if (!contacts.isEmpty()) {
        List<Messaging.SingleEmailMessage> facilityEmails = new List<Messaging.SingleEmailMessage>();
        for (Facility_Contact__c fc : contacts) {
            if (String.isNotBlank(fc.Contact_Email__c)) {
                Messaging.SingleEmailMessage fcMail = new Messaging.SingleEmailMessage();
                fcMail.setToAddresses(new String[]{fc.Contact_Email__c});
                fcMail.setSubject('Event Hall Booking Cancellation Notice');
                fcMail.setPlainTextBody(
                    'Dear Team,\n\n' +
                    'The event hall booking has been cancelled. Please find the details below:\n\n' +
                    eventDetails +
                    'Regards,\nREVA University'
                );
                facilityEmails.add(fcMail);
                System.debug('>>> [sendCancellationEmails] Queued email for Facility Contact: ' + fc.Contact_Email__c);
            }
        }

        if (!facilityEmails.isEmpty()) {
            Messaging.sendEmail(facilityEmails);
            System.debug('>>> [sendCancellationEmails] Sent ' + facilityEmails.size() + ' Facility Contact emails.');
        }
    }
}
        
// WhatsApp Notifications 
    global static void sendWhatsAppNotifications(Facility_Request__c req) {
       try {
        
        // Map of Phone → List of Notifications
       
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = 
            new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

        // ----------  Event Details ----------
        String facilityName = req.Facility__r.Name != null ? req.Facility__r.Name : 'N/A';
        String startDate = req.Start_Date__c != null ? req.Start_Date__c.format() : 'N/A';
        String endDate   = req.End_Date__c != null ? req.End_Date__c.format() : 'N/A';
        String startTime = (req.Start_Date__c != null && req.Start_Time__c != null)
            ? Datetime.newInstance(req.Start_Date__c, req.Start_Time__c).format('hh:mm a', 'Asia/Kolkata') : 'N/A';
        String endTime   = (req.End_Date__c != null && req.End_Time__c != null)
            ? Datetime.newInstance(req.End_Date__c, req.End_Time__c).format('hh:mm a', 'Asia/Kolkata') : 'N/A';
        String reason    = String.isBlank(req.Reason_of_Cancelation__c) ? 'N/A' : req.Reason_of_Cancelation__c;

        // ---------- Build Dynamic Variables ----------
        Map<String, String> commonParams = new Map<String, String>{
            'event_hall_name' => facilityName,
            'start_date' => startDate,
            'end_date' => endDate,
            'start_time' => startTime,
            'end_time' => endTime,
            'Reason' => reason
        };

        //  USER WhatsApp Notification → FACILITY_CANCEL_USER
       
        if (String.isNotBlank(req.Requester_Phone__c)) {
            Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
            notification.templateId = 'eventhallcancelationuser'; // Template ID from metadata
            notification.params = new Map<String, String>(commonParams);
            notification.params.put('Name', req.RequesterName__c);

            String cleanNumber = req.Requester_Phone__c.replace('+', '').replace('-', '');
            phoneNumbersToNotifications.put(cleanNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
        }

        //APPROVER WhatsApp Notification → FACILITY_CANCEL_APPROVER
        
        if ( String.isNotBlank(req.Approver_phone__c)) {
            Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
            notification.templateId = 'eventhallcancelationadmin';
            notification.params = new Map<String, String>(commonParams);
            notification.params.put('Admin_Name', req.Approver_Name__c);
            notification.params.put('requested_person', req.RequesterName__c);

            String cleanNumber = req.Approver_phone__c.replace('+', '').replace('-', '');
            phoneNumbersToNotifications.put(cleanNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
        }

        //  FACILITY TEAM WhatsApp Notification → FACILITY_CANCEL_FACILITY
       
        List<Facility_Contact__c> contacts = [
            SELECT Contact_Mobile__c
            FROM Facility_Contact__c
            WHERE Facility__c = :req.Facility__c
        ];

        if (!contacts.isEmpty()) {
            for (Facility_Contact__c fc : contacts) {
                if (fc.Contact__r != null && String.isNotBlank(fc.Contact_Mobile__c)) {
                    Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                    notification.templateId = 'eventhallcancelationteam';
                    notification.params = new Map<String, String>(commonParams);

                    String cleanNumber = fc.Contact_Mobile__c.replace('+', '').replace('-', '');
                    phoneNumbersToNotifications.put(cleanNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                }
            }
        }

        // SEND WHATSAPP NOTIFICATIONS
       
        if (!phoneNumbersToNotifications.isEmpty()) {
            System.debug(' Sending WhatsApp notifications: ' + phoneNumbersToNotifications.keySet());
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug(' WhatsApp Response: ' + (response != null ? response.getBody() : 'No response'));
        } else {
            System.debug('️ No valid phone numbers found for WhatsApp notifications.');
        }

    } catch (Exception e) {
        System.debug('Error in sendWhatsAppNotifications: ' + e.getMessage());
    }
}
    global static final String TEMPLATE_FACILITY_TEAM = 'eventhallcancelationteam-FACILITY_CANCEL_FACILITY';
    global static final String TEMPLATE_APPROVER = 'eventhallcancelationadmin-FACILITY_CANCEL_APPROVER';
    global static final String TEMPLATE_USER = 'eventhallcancelationuser-FACILITY_CANCEL_USER';
}