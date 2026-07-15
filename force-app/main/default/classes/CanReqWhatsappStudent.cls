public class CanReqWhatsappStudent {

    @InvocableMethod(label='Send Transport Cancellation WhatsApp Notifications to Students')
    public static void sendWhatsAppNotifications(List<String> recordIds) {
        if (recordIds != null && !recordIds.isEmpty()) {
            sendWhatsAppMessages(recordIds);
        }
    }

    @future(callout=true)
    public static void sendWhatsAppMessages(List<String> recordIds) {
        List<Transport_Registeration__c> regList = [
            SELECT Id, Name, Registration_Status__c,
                   Contact__r.Id, Contact__r.Name, Contact__r.MobilePhone, Contact__r.SRN_Number__c
            FROM Transport_Registeration__c
            WHERE Id IN :recordIds
        ];

		system.debug('regList' + regList);

        // Prepare SRN set
        Set<String> srnSet = new Set<String>();
        for (Transport_Registeration__c reg : regList) {
            if (reg.Contact__r != null && !String.isBlank(reg.Contact__r.SRN_Number__c)) {
                srnSet.add(reg.Contact__r.SRN_Number__c);
            }
        }
		system.debug('srnSet ' + srnSet);
        // Get the latest Transport Request for each SRN
        Map<String, RTR_Reva_Transport_Request__c> srnToRequestMap = new Map<String, RTR_Reva_Transport_Request__c>();
        for (RTR_Reva_Transport_Request__c req : [
            SELECT Id, SRN_EmployeeID__c, Cancellation_Date__c
            FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c IN :srnSet
            ORDER BY LastModifiedDate DESC
        ]) {
            if (!srnToRequestMap.containsKey(req.SRN_EmployeeID__c)) {
                srnToRequestMap.put(req.SRN_EmployeeID__c, req);
            }
        }
			System.debug('srnToRequestMap>>>' + srnToRequestMap);
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

        for (Transport_Registeration__c reg : regList) {
            String status = reg.Registration_Status__c;
            String templateId;

            if (status == 'Cancellation Request Submitted') {
                templateId = 'transport_can_req_student';
            } else if (status == 'Transport Admin Rejected') {
                templateId = 'transport_canc_req_rejected';
            } else if (status == 'Transport Admin Approved') {
                templateId = 'transport_can_req_approved_admin';
            } else if (status == 'Cancellation Approved') {
                templateId = 'transport_can_req_completed';
            } else {
                continue;
            }

            if (reg.Contact__r == null || String.isBlank(reg.Contact__r.MobilePhone)) continue;

            RTR_Reva_Transport_Request__c transportReq = srnToRequestMap.get(reg.Contact__r.SRN_Number__c);
            String cancellationDate = (transportReq != null && transportReq.Cancellation_Date__c != null)
                ? String.valueOf(transportReq.Cancellation_Date__c)
                : 'N/A';

            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :templateId
            ];

            Yellow_AI_Utility.WhatsAppNotification notif = new Yellow_AI_Utility.WhatsAppNotification();
            notif.templateId = templateId;
            notif.params = new Map<String, String>();

            string studentName = reg.Contact__r.Name;
             String reqId = reg.Name;
            if (templateId == 'transport_can_req_student') {
                notif.params.put('student_name', studentName);
                notif.params.put('7686868',reqId);
                notif.params.put('date_applied', cancellationDate);
            } else if (templateId == 'transport_canc_req_rejected') {
                notif.params.put('request_id', reqId);
                notif.params.put('student_name', studentName);
            } else if (templateId == 'transport_can_req_approved_admin') {
                notif.params.put('student_name', studentName);
                notif.params.put('request_id', reqId);
            } else if (templateId == 'transport_can_req_completed') {
                notif.params.put('student_name', studentName);
                notif.params.put('request_id', reqId);
            }

            String phone = reg.Contact__r.MobilePhone;
            if (!phoneToNotifications.containsKey(phone)) {
                phoneToNotifications.put(phone, new List<Yellow_AI_Utility.WhatsAppNotification>());
            }
            phoneToNotifications.get(phone).add(notif);
        }

        if (!Test.isRunningTest()) {
            HttpResponse res = Yellow_AI_Utility.sendWhatsAppNotifications(phoneToNotifications);
            System.debug('WhatsApp response: ' + res);
        }
    }
}