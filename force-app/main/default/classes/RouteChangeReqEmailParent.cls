public class RouteChangeReqEmailParent {
@InvocableMethod(label='Send route change Emails to Parents')
    public static void sendEmails(List<String> recordIds) {
        System.debug('Invoked sendEmails with recordIds: ' + recordIds);
        if (recordIds != null && !recordIds.isEmpty()) {
            sendEmailForParent(recordIds);
        }
    }

    public static void sendEmailForParent(List<String> recordIds) {
        System.debug('Inside sendEmailForParent with recordIds: ' + recordIds);

        List<Transport_Registeration__c> regRequests = [
            SELECT Id, Name, Registration_Status__c,
                   Contact__r.SRN_Number__c, Contact__r.Name,
                   Contact__r.Father_Email_ID__c,
                   Contact__r.Father__r.Name
            FROM Transport_Registeration__c 
            WHERE Id IN :recordIds
        ];

        if (regRequests.isEmpty()) {
            System.debug('No Transport_Registeration__c records found.');
            return;
        }

        Set<String> srnSet = new Set<String>();
        for (Transport_Registeration__c reg : regRequests) {
            if (reg.Contact__r != null && !String.isBlank(reg.Contact__r.SRN_Number__c)) {
                srnSet.add(reg.Contact__r.SRN_Number__c);
            }
        }

        Map<String, RTR_Reva_Transport_Request__c> srnToRequestMap = new Map<String, RTR_Reva_Transport_Request__c>();
        for (RTR_Reva_Transport_Request__c req : [
            SELECT Id, Cancellation_Date__c, SRN_EmployeeID__c, RecordType.Name
            FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c IN :srnSet
            ORDER BY LastModifiedDate DESC NULLS LAST
        ]) {
            if (!srnToRequestMap.containsKey(req.SRN_EmployeeID__c)) {
                srnToRequestMap.put(req.SRN_EmployeeID__c, req);
            }
        }
System.debug('srnToRequestMap-->> '+srnToRequestMap);
        OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts' LIMIT 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Transport_Registeration__c reg : regRequests) {
            String srn = reg.Contact__r != null ? reg.Contact__r.SRN_Number__c : null;
            String status = reg.Registration_Status__c;
            String reqId = reg.Name;
            String studentName = reg.Contact__r != null ? reg.Contact__r.Name : null;
            String parentName = reg.Contact__r.Father__r != null ? reg.Contact__r.Father__r.Name : null;
            String email = reg.Contact__r.Father_Email_ID__c;

            if (String.isBlank(srn) || String.isBlank(status) || String.isBlank(email)) {
                System.debug('Missing SRN, Status, or Parent Email. Skipping: ' + reqId);
                continue;
            }

            RTR_Reva_Transport_Request__c req = srnToRequestMap.get(srn);
            if (req == null || req.RecordType == null || req.RecordType.Name != 'Route Change Request') {
                System.debug('No valid Route Change Request found for SRN: ' + srn);
                continue;
            }

            String canDate = req.Cancellation_Date__c != null
                ? String.valueOf(req.Cancellation_Date__c): 'N/A';
            String subject;
            String body;

            switch on status {
                when 'Route Change Request Submitted' {
                    subject = 'Route Change Request Submitted';
                    body = 'Dear ' + parentName + ',\n\n' +
                        'Your ward ' + studentName + ' has requested REVA Route Change Request.\n' +
                        'Request ID: ' + reqId + '\n' +
                        'Regards,\nREVA University';
                }
                
                when 'Route change Transport admin Rejected' {
                    subject = 'Route change Transport admin Rejected';
                    body = 'Dear ' + parentName + ',\n\n' +
                        'Your ward\'s Route Change Request (Request ID: ' + reqId + ') has been rejected.\n\n' +
                        'Regards,\nREVA University';
                }
                when 'Route change Finance team approved' {
                    subject = 'Route change Completed';
                    body = 'Dear ' + parentName + ',\n\n' +
                        'Your ward ' + studentName + '\'s Route Change Request (Request ID: ' + reqId + ') has been approved.\n\n' +
                        'Regards,\nREVA University';
                }
                when else {
                    System.debug('Status not eligible for parent email: ' + status);
                    continue;
                }
            }

            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            emailMsg.setToAddresses(new String[] { email });
            emailMsg.setSubject(subject);
            emailMsg.setOrgWideEmailAddressId(owa.Id);
            emailMsg.setPlainTextBody(body);
            emails.add(emailMsg);
        }

        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
                System.debug('Parent emails sent successfully.');
            } catch (Exception e) {
                System.debug('Error sending parent emails: ' + e.getMessage());
            }
        } else {
            System.debug('No parent emails to send.');
        }
    }
}