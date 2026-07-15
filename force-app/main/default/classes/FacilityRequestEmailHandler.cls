public class FacilityRequestEmailHandler {

    public static void sendEmails(List<Id> facilityRequestIds) {
        if (facilityRequestIds == null || facilityRequestIds.isEmpty()) return;

        List<Facility_Request__c> requests = [
            SELECT Id, Name, TemplateName__c, Facility__c, RequesterName__c, Reqester_Phone_Number__c,
                   Start_Date__c, Start_Time__c, End_Date__c, End_Time__c,
                   Additional_Amenities_Required2__c, Facility__r.Name
            FROM Facility_Request__c
            WHERE Id IN :facilityRequestIds
        ];

        Set<Id> facilityIds = new Set<Id>();
        for (Facility_Request__c req : requests) {
            if (req.Facility__c != null && req.TemplateName__c == 'Approved') {
                facilityIds.add(req.Facility__c);
            }
        }

        if (facilityIds.isEmpty()) return;

        Map<Id, List<String>> facilityIdToEmails = new Map<Id, List<String>>();
        for (Facility_Contact__c fc : [
            SELECT Facility__c, Contact__r.Email
            FROM Facility_Contact__c
            WHERE Facility__c IN :facilityIds AND Contact__r.Email != null
        ]) {
            if (!facilityIdToEmails.containsKey(fc.Facility__c)) {
                facilityIdToEmails.put(fc.Facility__c, new List<String>());
            }
            facilityIdToEmails.get(fc.Facility__c).add(fc.Contact__r.Email);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Facility_Request__c req : requests) {
            if (req.TemplateName__c != 'Approved') continue;

            List<String> contactEmails = facilityIdToEmails.get(req.Facility__c);
            if (contactEmails == null || contactEmails.isEmpty()) continue;

            for (String email : contactEmails) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{email});
                mail.setSubject('New Facility Request Approved - ' + req.Name);

                String body = 'Dear Team,<br/><br/>' +
                              'The event hall request has been approved, so please make the necessary arrangements. The details were added below<br/><br/>' +
                              '<b>Request ID:</b> ' + req.Name + '<br/>' +
                              '<b>Facility:</b> ' + (req.Facility__r.Name != null ? req.Facility__r.Name : 'N/A') + '<br/>' +
                              '<b>Requester Name:</b> ' + (req.RequesterName__c != null ? req.RequesterName__c : 'N/A') + '<br/>' +
                              '<b>Requester Phone:</b> ' + (req.Reqester_Phone_Number__c != null ? req.Reqester_Phone_Number__c : 'N/A') + '<br/>' +
                              '<b>Start Date:</b> ' + formatDateToDDMMYYYY(req.Start_Date__c)  + '<br/>' +
                              '<b>Start Time:</b> ' + formatOnlyTime(req.Start_Time__c) + '<br/>' +
                              '<b>End Date:</b> ' + formatDateToDDMMYYYY(req.End_Date__c) + '<br/>' +
                              '<b>End Time:</b> ' + formatOnlyTime(req.End_Time__c) + '<br/>' +
                              '<b>Additional Amenities:</b> ' + (req.Additional_Amenities_Required2__c != null ? req.Additional_Amenities_Required2__c : 'N/A') + '<br/><br/>' +
                              'Regards,<br/><br/>' +
                              'REVA University.';

                mail.setHtmlBody(body);
                emails.add(mail);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('Emails sent: ' + emails.size());

            // Callouts only when not testing
            if (!Test.isRunningTest()) {
                List<String> requestIds = new List<String>();
                for (Id reqId : facilityRequestIds) {
                    requestIds.add(String.valueOf(reqId));
                }
                InfraApprovalSMS.makeCalloutAsync(requestIds);
                FacilityWhatAppNotifications.makeCalloutAsync(requestIds);
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