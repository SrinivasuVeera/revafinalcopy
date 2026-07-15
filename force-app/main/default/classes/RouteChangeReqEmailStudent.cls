public class RouteChangeReqEmailStudent {
 @InvocableMethod(label='Send Transport Cancellation Emails to Students')
    public static void sendEmails(List<String> recordIds) {
        System.debug('Invoked sendEmails with recordIds: ' + recordIds);
        if (recordIds != null && !recordIds.isEmpty()) {
            sendEmailForStudents(recordIds);
        }
    }

    public static void sendEmailForStudents(List<String> recordIds) {
        System.debug('Inside sendEmailForStudents with recordIds: ' + recordIds);

        // Query Transport_Registeration__c records
        List<Transport_Registeration__c> regList = [
            SELECT Id, Name, Registration_Status__c,
                   Contact__r.Name, Contact__r.Email, Contact__r.SRN_Number__c
            FROM Transport_Registeration__c
            WHERE Id IN :recordIds 
        ];

        // Prepare SRN set
        Set<String> srnSet = new Set<String>();
        for (Transport_Registeration__c reg : regList) {
            if (reg.Contact__r != null && !String.isBlank(reg.Contact__r.SRN_Number__c)) {
                srnSet.add(reg.Contact__r.SRN_Number__c);
            }
        }

        // Map SRN to latest RTR_Reva_Transport_Request__c
        Map<String, RTR_Reva_Transport_Request__c> srnToRequestMap = new Map<String, RTR_Reva_Transport_Request__c>();
        for (RTR_Reva_Transport_Request__c req : [
            SELECT Id, SRN_EmployeeID__c, Cancellation_Date__c
            FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c IN :srnSet
            ORDER BY LastModifiedDate DESC NULLS LAST
        ]) {
            if (!srnToRequestMap.containsKey(req.SRN_EmployeeID__c)) {
                srnToRequestMap.put(req.SRN_EmployeeID__c, req);
            }
        }

        // Get OrgWideEmailAddress (Avoid hardcoding in real scenario: use Custom Metadata or Custom Setting)
        OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts' LIMIT 1];

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (Transport_Registeration__c reg : regList) {
            if (reg.Contact__r == null || String.isBlank(reg.Contact__r.Email) || String.isBlank(reg.Contact__r.SRN_Number__c)) {
                System.debug('Skipping record due to missing SRN or Email');
                continue;
            }

            RTR_Reva_Transport_Request__c transportReq = srnToRequestMap.get(reg.Contact__r.SRN_Number__c);
            String canDate = (transportReq != null && transportReq.Cancellation_Date__c != null)
                ? String.valueOf(transportReq.Cancellation_Date__c)
                : 'N/A';

            String status = reg.Registration_Status__c;
            String studentName = reg.Contact__r.Name;
            String subject;
            String body;

            switch on status {
                when 'Route Change Request Submitted' {
                    subject = 'Route Change Request Submitted';
                    body = 'Dear ' + studentName + ',\n\n' +
                        'Your route change request \n' +
                        'Request ID: ' +reg.Name + '\n' +
                        'is under processing. Please be patient.'+'\n\n' +
                        'Regards,\nREVA University';
                }
                when 'Route change Transport admin Rejected' {
                    subject = 'Route Change Request Rejected';
                    body = 'Dear ' + studentName + ',\n\n' +
                        'Your Route Change request (Request ID: ' + reg.Name + ') has been rejected.\n\n' +
                        'Regards,\nREVA University';
                }
                when 'Route change Transport admin Approved' {
                    subject = 'Route change Transport admin Approved';
                    body = 'Dear ' + studentName + ',\n\n' +
                        'Your Route change request (Request ID: ' + reg.Name + ') has been approved by the Transport Admin.\n' +
                        'Kindly be patient for the final approval.\n\n' +
                        'Regards,\nREVA University';
                }
                when 'Route change Finance team approved' {
                    subject = 'Route change Completed';
                    body = 'Dear ' + studentName + ',\n\n' +
                        'Your Route change request (Request ID: ' + reg.Name + ') process is completed; for more details, check in the portal.\n\n' +
                        'Regards,\nREVA University';
                }
                when else {
                    System.debug('Unknown status. Skipping email for request: ' + reg.Name);
                    continue;
                }
            }

            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            emailMsg.setToAddresses(new String[] { reg.Contact__r.Email });
            emailMsg.setSubject(subject);
            emailMsg.setOrgWideEmailAddressId(owa.Id);
            emailMsg.setPlainTextBody(body);

            emailsToSend.add(emailMsg);
        }

        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend);
                System.debug('Emails sent successfully to students.');
            } catch (Exception e) {
                System.debug('Failed to send some emails: ' + e.getMessage());
            }
        } else {
            System.debug('No emails prepared for sending.');
        }
    
}
}