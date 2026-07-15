public class CanReqEmailFinanceDept {

    @InvocableMethod(label='Send Transport Cancellation Email to Finance')
    public static void sendEmails(List<String> recordIds) {
        System.debug('Invoked Finance Email Method with recordIds: ' + recordIds);
        if (recordIds != null && !recordIds.isEmpty()) {
            sendEmailForFinance(recordIds);
        } else {
            System.debug('No recordIds received.');
        }
    }

    public static void sendEmailForFinance(List<String> recordIds) {
        List<Transport_Registeration__c> regList = [
            SELECT Id, Name, Registration_Status__c, Contact__r.SRN_Number__c
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

        // Query for the relevant RTR_Reva_Transport_Request__c records
        for (RTR_Reva_Transport_Request__c req : [
            SELECT Id, Name, RTR_Status__c, Cancellation_Date__c, RecordType.Name,
                   RTR_Student__r.Name, SRN_EmployeeID__c
            FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c IN :srnSet
            ORDER BY CreatedDate DESC NULLS LAST 
        ]) {
            if (!srnToReqMap.containsKey(req.SRN_EmployeeID__c)) {
                srnToReqMap.put(req.SRN_EmployeeID__c, req);
            }
        }

        // Getting Finance User Info
        User financeUser;
        try {
            financeUser = [
                SELECT Email, LastName FROM User
                WHERE Profile.Name = 'Finance Manager' AND Name = 'Bharathi S'
                LIMIT 1
            ];
        } catch (QueryException e) {
            System.debug('Finance User (Bharathi S) not found. Error: ' + e.getMessage());
            return;
        }
        String financeEmail = financeUser.Email;
        String financeName = financeUser.LastName;

        // Org Wide Email Address 
        OrgWideEmailAddress owa;
        try {
            owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts' LIMIT 1];
        } catch (QueryException e) {
            System.debug('Org Wide Email Address with DisplayName "REVA Alerts" not found. Error: ' + e.getMessage());
            return;
        }

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();

        for (String srn : srnSet) {
            Transport_Registeration__c reg = srnToRegMap.get(srn);
            RTR_Reva_Transport_Request__c req = srnToReqMap.get(srn);

            if (reg == null || req == null) {
                System.debug('Skipping SRN ' + srn + ' - Missing registration or request.');
                continue;
            }

            // Checking if the status is 'Transport Admin Approved' before sending to Finance
            if (reg.Registration_Status__c != 'Transport Admin Approved') {
                System.debug('Skipping SRN ' + srn + ' - Status is not "Transport Admin Approved". Current status: ' + reg.Registration_Status__c);
                continue;
            }

            String studentName = req.RTR_Student__r != null ? req.RTR_Student__r.Name : 'N/A';
            String cancellationDate = req.Cancellation_Date__c != null
                ? String.valueOf(req.Cancellation_Date__c)
                : 'N/A';
            String requestId = reg.Name;

            String approvalLink = 'N/A';

            // ---> Generate Approval Link <---
            // Querying the ProcessInstanceWorkitem for this specific request for finance approval
            ProcessInstanceWorkitem piw = null;
            try {
                // Query for the active work item for the target object the RTR_Reva_Transport_Request__c record
                piw = [
                    SELECT Id, ProcessInstance.TargetObjectId
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId = :req.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
                approvalLink = baseUrl + '/' + piw.Id; 
                System.debug('Generated approval link for finance for SRN ' + srn + ': ' + approvalLink);
            } catch (QueryException e) {
                System.debug('No active ProcessInstanceWorkitem found for request ID: ' + req.Id + ' for finance approval. Error: ' + e.getMessage());                
            }            

            String subject = 'Transport Cancellation - Awaiting Finance Approval (Request ID: ' + requestId + ')';
            String body = 'Dear Sir,<br><br>' +
                          'The transport cancellation request (Request ID: ' + requestId + ') of ' + studentName +
                          ' has been approved by the transport admin. Please proceed with further procedures by clicking the link below:<br><br>' +
                          approvalLink + '<br><br>' +
                          '<b>SRN:</b> ' + srn + '<br>' +
                          '<b>Requested Date:</b> ' + cancellationDate + '<br><br>' +
                          'Regards,<br>REVA University';

            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            emailMsg.setToAddresses(new String[] { financeEmail });
            emailMsg.setSubject(subject);
            emailMsg.setOrgWideEmailAddressId(owa.Id);
            emailMsg.setHtmlBody(body);
            emailList.add(emailMsg);
        }

        if (!emailList.isEmpty()) {
            try {
                Messaging.sendEmail(emailList);
                System.debug('Finance emails sent successfully.');
            } catch (Exception e) {
                System.debug('Error sending Finance emails: ' + e.getMessage());
            }
        } else {
            System.debug('No eligible Finance emails to send.');
        }
    }
}