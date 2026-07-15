public class CanReqEmailParent {
    
    @InvocableMethod(label='Send Transport Cancellation Emails to Parents')
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
            if (req == null || req.RecordType == null || req.RecordType.Name != 'Transport Cancellation') {
                System.debug('No valid Transport Cancellation request found for SRN: ' + srn);
                continue;
            }

            String canDate = req.Cancellation_Date__c != null
                ? String.valueOf(req.Cancellation_Date__c): 'N/A';
            String subject;
            String body;

            switch on status {
                when 'Cancellation Request Submitted' {
                    subject = 'Transport Cancellation Request Submitted';
                    body = 'Dear ' + parentName + ',\n\n' +
                        'Your ward ' + studentName + ' has requested REVA Transport cancellation.\n' +
                        'Request ID: ' + reqId + '\n' +
                        'Date: ' + canDate + '\n\n' +
                        'Regards,\nREVA University';
                }
                
                when 'Transport Admin Rejected' {
                    subject = 'Transport Cancellation Request Rejected';
                    body = 'Dear ' + parentName + ',\n\n' +
                        'Your ward\'s transport cancellation request (Request ID: ' + reqId + ') has been rejected.\n\n' +
                        'Regards,\nREVA University';
                }
                when 'Cancellation Approved' {
                    subject = 'Transport Cancellation Request Approved';
                    body = 'Dear ' + parentName + ',\n\n' +
                        'Your ward ' + studentName + '\'s transport cancellation request (Request ID: ' + reqId + ') has been approved.\n\n' +
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