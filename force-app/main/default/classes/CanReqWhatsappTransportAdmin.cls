public class CanReqWhatsappTransportAdmin {

    @InvocableMethod(label='Send Transport Cancellation WhatsApp Notifications to Transport Admin')
    public static void sendWhatsAppNotifications(List<String> recordIds) {
        if (recordIds != null && !recordIds.isEmpty()) {
            sendWhatsAppMessages(recordIds);
        }
    }

    @future(callout=true)
    public static void sendWhatsAppMessages(List<String> recordIds) {
        // Query registration and related student details
        List<Transport_Registeration__c> regList = [
            SELECT Id, Name, Registration_Status__c,
                   Contact__r.Name, Contact__r.SRN_Number__c
            FROM Transport_Registeration__c
            WHERE Id IN :recordIds
        ];

        // Collect SRNs
        Set<String> srnSet = new Set<String>();
        Map<String, Transport_Registeration__c> srnToRegMap = new Map<String, Transport_Registeration__c>();
        for (Transport_Registeration__c reg : regList) {
            if (reg.Contact__r != null && !String.isBlank(reg.Contact__r.SRN_Number__c)) {
                String srn = reg.Contact__r.SRN_Number__c;
                srnSet.add(srn);
                srnToRegMap.put(srn, reg);
            }
        }

        // Fetch latest transport request per SRN
        Map<String, RTR_Reva_Transport_Request__c> srnToRequestMap = new Map<String, RTR_Reva_Transport_Request__c>();
        for (RTR_Reva_Transport_Request__c req : [
            SELECT Id, Cancellation_Date__c, SRN_EmployeeID__c,
                   RTR_Student__r.Name,
                   RTR_Route_Pick_Up_Point__r.Name,
                   RTR_Route_Pick_Up_Point__r.RTR_Route_Master__r.Name
            FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c IN :srnSet
            ORDER BY LastModifiedDate DESC
        ]) {
            if (!srnToRequestMap.containsKey(req.SRN_EmployeeID__c)) {
                srnToRequestMap.put(req.SRN_EmployeeID__c, req);
            }
        }

        // Get transport admin name (used as "transport_admin")
        User transportAdmin;
        try {
            transportAdmin = [SELECT LastName,MobilePhone FROM User WHERE Name = 'Lakshmanan G' LIMIT 1];
        } catch (Exception e) {
            System.debug('Transport Admin user not found: ' + e.getMessage());
            return;
        }

        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

        // Hardcoded transport admin phone (update with actual number if dynamic logic is needed)
        String adminPhone = transportAdmin.MobilePhone; // Replace with actual phone if required

        for (String srn : srnSet) {
            Transport_Registeration__c reg = srnToRegMap.get(srn);
            RTR_Reva_Transport_Request__c req = srnToRequestMap.get(srn);
            if (reg == null || req == null) continue;

            String status = reg.Registration_Status__c;
            String templateId;

            if (status == 'Cancellation Request Submitted') {
                templateId = 'transport_can_req_admin';
            } else if (status == 'Cancellation Approved') {
                templateId = 'transport_can_req_compl_admin';
            } else {
                continue;
            }

            String studentName = reg.Contact__r.Name;
            String requestId = reg.Name;
            String cancellationDate = req.Cancellation_Date__c != null
                ? String.valueOf(req.Cancellation_Date__c)
                : 'N/A';
            String pickUp = req.RTR_Route_Pick_Up_Point__r?.Name != null
                ? req.RTR_Route_Pick_Up_Point__r.Name
                : 'N/A';
            String routeNo = req.RTR_Route_Pick_Up_Point__r?.RTR_Route_Master__r?.Name != null
                ? req.RTR_Route_Pick_Up_Point__r.RTR_Route_Master__r.Name
                : 'N/A';

            Yellow_AI_Utility.WhatsAppNotification notif = new Yellow_AI_Utility.WhatsAppNotification();
            notif.templateId = templateId;
            notif.params = new Map<String, String>();

            if (templateId == 'transport_can_req_admin') {
                notif.params.put('transport_admin', transportAdmin.LastName);
                notif.params.put('name_of_the_student', studentName);
                notif.params.put('request_id', requestId);
                notif.params.put('srn_number', srn);
                notif.params.put('6', routeNo);
                notif.params.put('yelahanka', pickUp);
                notif.params.put('date_of_request', cancellationDate);
            } else if (templateId == 'transport_can_req_compl_admin') {
                notif.params.put('transport_admin', transportAdmin.LastName);
                notif.params.put('name_of_the_student', studentName);
                notif.params.put('req_id', requestId);
                notif.params.put('srn_number', srn);
                notif.params.put('route_no', routeNo);
                notif.params.put('pick_up_point', pickUp);
            }

            if (!phoneToNotifications.containsKey(adminPhone)) {
                phoneToNotifications.put(adminPhone, new List<Yellow_AI_Utility.WhatsAppNotification>());
            }
            phoneToNotifications.get(adminPhone).add(notif);
        }

        if (!Test.isRunningTest()) {
            HttpResponse res = Yellow_AI_Utility.sendWhatsAppNotifications(phoneToNotifications);
            System.debug('Admin WhatsApp response: ' + res);
        }
    }
}