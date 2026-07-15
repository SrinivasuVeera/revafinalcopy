public class FacilityRequestFlowHandler {

    @InvocableMethod(label='Send Facility Request WhatsApp Notification')
    public static void sendNotifications(List<Id> facilityRequestIds) {
        if (facilityRequestIds == null || facilityRequestIds.isEmpty()) return;

        // Step 1: Query Facility Requests
        List<Facility_Request__c> requests = [
            SELECT Id, Name, TemplateName__c, Facility__c, RequesterName__c, Reqester_Phone_Number__c,
                   Start_Date__c, Start_Time__c, End_Date__c, End_Time__c,
                   Additional_Amenities_Required2__c, Facility__r.Name
            FROM Facility_Request__c
            WHERE Id IN :facilityRequestIds
        ];

        // Step 2: Collect Facility IDs
        Set<Id> facilityIds = new Set<Id>();
        for (Facility_Request__c req : requests) {
            if (req.Facility__c != null && req.TemplateName__c == 'Approved') {
                facilityIds.add(req.Facility__c);
            }
        }

        if (facilityIds.isEmpty()) return;

        // Step 3: Query Facility Contacts with Mobile Numbers
        Map<Id, List<String>> facilityIdToMobileNumbers = new Map<Id, List<String>>();
        for (Facility_Contact__c fc : [
        SELECT Facility__c, Contact__r.MobilePhone
        FROM Facility_Contact__c
        WHERE Facility__c IN :facilityIds AND Contact__r.MobilePhone != null
    ]) {
        if (!facilityIdToMobileNumbers.containsKey(fc.Facility__c)) {
            facilityIdToMobileNumbers.put(fc.Facility__c, new List<String>());
        }
        facilityIdToMobileNumbers.get(fc.Facility__c).add(fc.Contact__r.MobilePhone);
    }

        System.debug('Facility Contacts Map: ' + facilityIdToMobileNumbers);

        // Step 4: Get Metadata Fields
        String templateId = 'event_hall_booking'; // Replace with actual Template ID
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [
            SELECT Template_Field__c
            FROM WhatsApp_Notification_Template__mdt
            WHERE Template_ID__c = :templateId
        ];

        // Step 5: Build Notifications
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

        for (Facility_Request__c req : requests) {
            if (req.TemplateName__c != 'Approved') continue;

            List<String> mobileNumbers = facilityIdToMobileNumbers.get(req.Facility__c);
            if (mobileNumbers == null || mobileNumbers.isEmpty()) continue;
            System.debug('Facility Request ID: ' + req.Id + ', Mobile Numbers: ' + mobileNumbers);

            for (String phone : mobileNumbers) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();

                // Use static parameter names expected by WhatsApp Template
                notification.params.put('facilty_request_id', req.Name != null ? req.Name : 'N/A');
                notification.params.put('facility_name', req.Facility__r.Name != null ? req.Facility__r.Name : 'N/A');
                notification.params.put('who_created_the_request', req.RequesterName__c != null ? req.RequesterName__c : 'N/A');
                notification.params.put('mobile_no_of_the_requester', req.Reqester_Phone_Number__c != null ? req.Reqester_Phone_Number__c : 'N/A');
                notification.params.put('date_of_starting', formatDateToDDMMYYYY(req.Start_Date__c));
                notification.params.put('end_date', formatDateToDDMMYYYY(req.End_Date__c));
                notification.params.put('start_time', formatOnlyTime(req.Start_Time__c));
                notification.params.put('end_time', formatOnlyTime(req.End_Time__c));
                notification.params.put('additional_amenities_requested', req.Additional_Amenities_Required2__c != null ? req.Additional_Amenities_Required2__c : 'N/A');

                if (!phoneToNotifications.containsKey(phone)) {
                    phoneToNotifications.put(phone, new List<Yellow_AI_Utility.WhatsAppNotification>());
                }
                phoneToNotifications.get(phone).add(notification);
                
                 if (!Test.isRunningTest() && !phoneToNotifications.isEmpty()) {
            HttpResponse res = Yellow_AI_Utility.sendWhatsAppNotifications(phoneToNotifications);
            System.debug('WhatsApp Notification Response: ' + res.getbody());
        }
            }
        }

        
       
    }

    private static String formatOnlyTime(Time t) {
        if (t == null) return 'N/A';
        String amPm = t.hour() >= 12 ? 'PM' : 'AM';
        Integer hour = Math.mod(t.hour(), 12) == 0 ? 12 : Math.mod(t.hour(), 12);
        String paddedMinutes = (t.minute() < 10 ? '0' + t.minute() : String.valueOf(t.minute()));
        return hour + ':' + paddedMinutes + ' ' + amPm;
    }
    
    private static String formatDateToDDMMYYYY(Date d) {
    if (d == null) return 'N/A';
    
    String day = d.day() < 10 ? '0' + d.day() : String.valueOf(d.day());
    String month = d.month() < 10 ? '0' + d.month() : String.valueOf(d.month());
    String year = String.valueOf(d.year());

    return day + '-' + month + '-' + year;
}


}