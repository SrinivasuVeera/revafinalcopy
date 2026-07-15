public class RouteChangeReqWhatsappParent {
@InvocableMethod(label='Send Route Change WhatsApp Notifications to Parents')
    public static void sendWhatsAppNotifications(List<String> recordIds) {
        if (recordIds != null && !recordIds.isEmpty()) {
            sendWhatsAppMessages(recordIds);
        }
    }

    @future(callout=true)
    public static void sendWhatsAppMessages(List<String> recordIds) {
        List<Transport_Registeration__c> regList = [
            SELECT Id, Name, Registration_Status__c,
                   Contact__r.Id, Contact__r.Name, Contact__r.SRN_Number__c,
                   Contact__r.Father__r.Name, Contact__r.RH_Parent_Phone_Number__c
            FROM Transport_Registeration__c
            WHERE Id IN :recordIds
        ];

        // Prepare SRNs
        Set<String> srnSet = new Set<String>();
        for (Transport_Registeration__c reg : regList) {
            if (reg.Contact__r != null && !String.isBlank(reg.Contact__r.SRN_Number__c)) {
                srnSet.add(reg.Contact__r.SRN_Number__c);
            }
        }

        // Get latest request per SRN
        Map<String, RTR_Reva_Transport_Request__c> srnToRequestMap = new Map<String, RTR_Reva_Transport_Request__c>();
        for (RTR_Reva_Transport_Request__c req : [
            SELECT Id, SRN_EmployeeID__c, Cancellation_Date__c,New_Route_Master__r.Name,New_Route_Pick_Up_Point__r.Name
            FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c IN :srnSet
            ORDER BY LastModifiedDate DESC
        ]) {
            if (!srnToRequestMap.containsKey(req.SRN_EmployeeID__c)) {
                srnToRequestMap.put(req.SRN_EmployeeID__c, req);
            }
        }

        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

        for (Transport_Registeration__c reg : regList) {
            String status = reg.Registration_Status__c;
            String templateId;

            if (status == 'Route Change Request Submitted') {
                templateId = 'transport_rchg_req_parent';
            } else if (status == 'Route change Finance team approved') {
                templateId = 'transport_rchg_req_aprd_parent';
            }else {
                continue;
            }

            String fatherPhone = reg.Contact__r.RH_Parent_Phone_Number__c;
            if (String.isBlank(fatherPhone)) continue;

            String studentName = reg.Contact__r.Name;
            String parentName = reg.Contact__r.Father__r != null ? reg.Contact__r.Father__r.Name : 'Parent';
            String reqId = reg.Name;
            String cancellationDate = 'N/A';
            string newRouteMAster;
			string newPickupPoint;

            RTR_Reva_Transport_Request__c transportReq = srnToRequestMap.get(reg.Contact__r.SRN_Number__c);
            if (transportReq != null && transportReq.Cancellation_Date__c != null) {
                cancellationDate = String.valueOf(transportReq.Cancellation_Date__c);
                newRouteMAster = String.valueOf(transportReq.New_Route_Master__r.Name);
				newPickupPoint = String.valueOf(transportReq.New_Route_Pick_Up_Point__r.Name);
            }

            Yellow_AI_Utility.WhatsAppNotification notif = new Yellow_AI_Utility.WhatsAppNotification();
            notif.templateId = templateId;
            notif.params = new Map<String, String>();

            if (templateId == 'transport_can_req_parent') {
                notif.params.put('Parent_name', parentName);
                notif.params.put('Name of the student', studentName);
                notif.params.put('557', reqId);
            } else if (templateId == 'transport_can_approved_parent') {
                notif.params.put('parent_name', parentName);
                notif.params.put('Name of the student', studentName);
                notif.params.put('6565656', reqId);
                notif.params.put('route_number', newRouteMAster);
                notif.params.put('pick_up_point', newPickupPoint);
            }

            if (!phoneToNotifications.containsKey(fatherPhone)) {
                phoneToNotifications.put(fatherPhone, new List<Yellow_AI_Utility.WhatsAppNotification>());
            }
            phoneToNotifications.get(fatherPhone).add(notif);
        }

        if (!Test.isRunningTest()) {
            HttpResponse res = Yellow_AI_Utility.sendWhatsAppNotifications(phoneToNotifications);
            System.debug('Parent WhatsApp response: ' + res);
        }
    }
}