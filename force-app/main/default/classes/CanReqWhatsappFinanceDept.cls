public class CanReqWhatsappFinanceDept {

    @InvocableMethod(label='Send Transport Cancellation WhatsApp to Finance')
    public static void sendWhatsAppNotifications(List<String> recordIds) {
        if (recordIds != null && !recordIds.isEmpty()) {
            sendWhatsAppMessages(recordIds);
        }
    }

    @future(callout=true)
    public static void sendWhatsAppMessages(List<String> recordIds) {
        List<Transport_Registeration__c> regList = [
            SELECT Id, Name, Registration_Status__c, Contact__r.Name, Contact__r.SRN_Number__c
            FROM Transport_Registeration__c
            WHERE Id IN :recordIds
        ];

        if (regList.isEmpty()) {
            System.debug('No Transport_Registeration__c records found.');
            return;
        }

        Set<String> srnSet = new Set<String>();
        Map<String, Transport_Registeration__c> srnToRegMap = new Map<String, Transport_Registeration__c>();

        for (Transport_Registeration__c reg : regList) {
            if (reg.Contact__r != null && !String.isBlank(reg.Contact__r.SRN_Number__c)) {
                srnSet.add(reg.Contact__r.SRN_Number__c);
                srnToRegMap.put(reg.Contact__r.SRN_Number__c, reg);
            }
        }

        Map<String, RTR_Reva_Transport_Request__c> srnToReqMap = new Map<String, RTR_Reva_Transport_Request__c>();
        for (RTR_Reva_Transport_Request__c req : [
            SELECT Id, Cancellation_Date__c, SRN_EmployeeID__c, RTR_Student__r.Name
            FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c IN :srnSet
            ORDER BY LastModifiedDate DESC
        ]) {
            if (!srnToReqMap.containsKey(req.SRN_EmployeeID__c)) {
                srnToReqMap.put(req.SRN_EmployeeID__c, req);
            }
        }

        // Get Finance User (Vishali Perni)
        User financeUser;
        try {
            financeUser = [SELECT LastName, MobilePhone FROM User WHERE Name = 'Bharathi S' LIMIT 1];
        } catch (Exception e) {
            System.debug('Finance user not found: ' + e.getMessage());
            return;
        }

        String financePhone = financeUser.MobilePhone;
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

        for (String srn : srnSet) {
            Transport_Registeration__c reg = srnToRegMap.get(srn);
            RTR_Reva_Transport_Request__c req = srnToReqMap.get(srn);

            if (reg == null || req == null) continue;
            if (reg.Registration_Status__c != 'Transport Admin Approved') continue;

            String templateId = 'transport_can_req_finance';
            String studentName = reg.Contact__r.Name;
            String requestId = reg.Name;
            String cancellationDate = req.Cancellation_Date__c != null
                ? String.valueOf(req.Cancellation_Date__c)
                : 'N/A';

            Yellow_AI_Utility.WhatsAppNotification notif = new Yellow_AI_Utility.WhatsAppNotification();
            notif.templateId = templateId;
            notif.params = new Map<String, String>{
                'request_id' => requestId,
                'student_name' => studentName,
                'srn_number' => srn,
                'requested_date' => cancellationDate
            };

            if (!phoneToNotifications.containsKey(financePhone)) {
                phoneToNotifications.put(financePhone, new List<Yellow_AI_Utility.WhatsAppNotification>());
            }
            phoneToNotifications.get(financePhone).add(notif);
        }

        if (!Test.isRunningTest()) {
            HttpResponse res = Yellow_AI_Utility.sendWhatsAppNotifications(phoneToNotifications);
            System.debug('Finance WhatsApp response: ' + res);
        }
    }
}