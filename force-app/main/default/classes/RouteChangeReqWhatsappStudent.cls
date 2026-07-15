public class RouteChangeReqWhatsappStudent {
@InvocableMethod(label='Send Route Change WhatsApp Notifications to Students')
    public static void sendWhatsAppNotifications(List<String> recordIds) {
        if (recordIds != null && !recordIds.isEmpty()) {
            sendWhatsAppMessages(recordIds);
        }
    }

    @future(callout=true)
    public static void sendWhatsAppMessages(List<String> recordIds) {
        List<Transport_Registeration__c> regList = [
            SELECT Id, Name, Registration_Status__c,RouteChangeAmountToPay__c,
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
            SELECT Id, SRN_EmployeeID__c, Cancellation_Date__c,New_Route_Master__R.Name,New_Route_Pick_Up_Point__r.Name
            FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c IN :srnSet and RecordType.DeveloperName = 'Route_Change_Request'
            ORDER BY LastModifiedDate DESC
        ]) {
            if (!srnToRequestMap.containsKey(req.SRN_EmployeeID__c)) {
                srnToRequestMap.put(req.SRN_EmployeeID__c, req);
            }
        }
            System.debug('srnToRequestMap>>>' + srnToRequestMap);
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

        for (Transport_Registeration__c reg : regList) {
            system.debug ('phoneNumber >> '+ reg.Contact__r.MobilePhone);
            String status = reg.Registration_Status__c;
            decimal amounttoPay = reg.RouteChangeAmountToPay__c;
            String amountToPayStr = String.valueOf(amountToPay);
            String templateId;

            if (status == 'Route Change Request Submitted') {
                templateId = 'transport_route_change_req_student';
            } else if (status == 'Route change Transport admin Rejected') {
                templateId = 'transport_rchg_rejected_student';
            } else if (status == 'Route change Finance team approved') {
                templateId = 'transport_rchg_done_student';
            } else if (status == 'Route change Transport admin Approved' && amounttoPay > 0) {
                templateId = 'transport_rchg_payment_student';
            }else {
                continue;
            }

            //if (reg.Contact__r != null || String.isNotBlank(reg.Contact__r.MobilePhone)) continue;

            RTR_Reva_Transport_Request__c transportReq = srnToRequestMap.get(reg.Contact__r.SRN_Number__c);
            String cancellationDate = (transportReq != null && transportReq.Cancellation_Date__c != null)
                ? String.valueOf(transportReq.Cancellation_Date__c)
                : 'N/A';
            string newRouteMaster = String.valueOf(transportReq.New_Route_Master__R.Name);
            system.debug('newRouteMaster' + newRouteMaster);
            string newPickuppoint = String.valueOf(transportReq.New_Route_Pick_Up_Point__r.Name);
            system.debug('newPickuppoint' + newPickuppoint);

            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :templateId
            ];
            
            String approvalLink = 'N/A';
            
            // Querying the process instance and work item for the specific request
            ProcessInstanceWorkitem piw = null;
            try {
                piw = [
                    SELECT Id, ProcessInstance.TargetObjectId
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId = :transportReq.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
                String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
                approvalLink = baseUrl + '/' + piw.Id; // This link will take directly to the approval page
                System.debug('Generated approval link for SRN ' + ': ' + approvalLink);
            } catch (QueryException e) {
                System.debug('No active ProcessInstanceWorkitem found for request ID: ' + transportReq.Id + '. Error: ' + e.getMessage());
            }
            Yellow_AI_Utility.WhatsAppNotification notif = new Yellow_AI_Utility.WhatsAppNotification();
            notif.templateId = templateId;
            notif.params = new Map<String, String>();

            
            string studentName = reg.Contact__r.Name;
             String reqId = reg.Name;
            if (templateId == 'transport_route_change_req_student') {
                notif.params.put('student_name', studentName);
                notif.params.put('request_id', reqId);
            } else if (templateId == 'transport_rchg_rejected_student') {
                notif.params.put('request_id', reqId);
                notif.params.put('student_name', studentName);
            } else if (templateId == 'transport_rchg_payment_student') {
                notif.params.put('student_name', studentName);
                notif.params.put('amount',amountToPayStr);
                notif.params.put('www.Link to pay.com',approvalLink);
            } else if (templateId == 'transport_rchg_done_student') {
                notif.params.put('student_name', studentName);
                notif.params.put('request_id', reqId);
                notif.params.put('new_route_number', newRouteMaster);
                notif.params.put('pick_up_point', newPickuppoint);
            }
            
            String phone = reg.Contact__r.MobilePhone;
            System.debug('Phone >> '+phone );
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