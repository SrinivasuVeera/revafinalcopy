public class RouteChangeReqEmailTransportAdmin {
@InvocableMethod(label='Send Route Change Emails to Transport Admin')
    public static void sendEmails(List<String> recordIds) {
        System.debug('Invoked sendEmails Transport Admin method with recordIds: ' + recordIds);
        if (recordIds != null && !recordIds.isEmpty()) {
            sendEmailForAdmin(recordIds);
        }
    }
    
    public static void sendEmailForAdmin(List<String> recordIds) {
        System.debug('Inside sendEmailForAdmin method');
        
        List<Transport_Registeration__c> regRequests = [
            SELECT Id, Name, Registration_Status__c, Contact__r.SRN_Number__c
            FROM Transport_Registeration__c
            WHERE Id IN :recordIds
        ];
        
        if (regRequests.isEmpty()) {
            System.debug('No transport registration records found.');
            return;
        }
        
        Set<String> srnSet = new Set<String>();
        Map<String, Transport_Registeration__c> srnToRegMap = new Map<String, Transport_Registeration__c>();
        
        for (Transport_Registeration__c reg : regRequests) {
            if (reg.Contact__r != null && !String.isBlank(reg.Contact__r.SRN_Number__c)) {
                srnSet.add(reg.Contact__r.SRN_Number__c);
                srnToRegMap.put(reg.Contact__r.SRN_Number__c, reg);
            }
        }
        
        Map<String, RTR_Reva_Transport_Request__c> srnToReqMap = new Map<String, RTR_Reva_Transport_Request__c>();
        // Query for transport requests. We use a map to easily retrieve them by SRN.
        for (RTR_Reva_Transport_Request__c req : [
            SELECT Id, Cancellation_Date__c, RecordType.Name, RTR_Student__r.Name,
            SRN_EmployeeID__c, RTR_Route_Pick_Up_Point__r.Name,
            RTR_Route_Pick_Up_Point__r.RTR_Route_Master__r.Name
            FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c IN :srnSet AND RecordType.Name = 'Route Change Request'
            ORDER BY CreatedDate DESC NULLS LAST
        ]) {
            // Only adding if not already in the map to ensure that we getting one request per SRN (the most recent)
            if (!srnToReqMap.containsKey(req.SRN_EmployeeID__c)) {
                srnToReqMap.put(req.SRN_EmployeeID__c, req);
            }
        }
        
        // Get OrgWideEmailAddress
        OrgWideEmailAddress owa;
        try {
            owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts' LIMIT 1];
        } catch (QueryException e) {
            System.debug('Org Wide Email Address with DisplayName "REVA Alerts" not found. Error: ' + e.getMessage());
            return;
        }
        
        // Transport Admin User
        User transportAdminDetails;
        try {
            transportAdminDetails = [SELECT Email, LastName FROM User WHERE Name = 'Lakshmanan G' LIMIT 1];
        } catch (QueryException e) {
            System.debug('Transport Admin User with Name "Lakshmanan" not found. Error: ' + e.getMessage());
            return;
        }
        String transportAdminEmail = transportAdminDetails.Email;
        String transportAdminName = transportAdminDetails.LastName;
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        for (String srn : srnSet) {
            Transport_Registeration__c reg = srnToRegMap.get(srn);
            RTR_Reva_Transport_Request__c req = srnToReqMap.get(srn);
            
            if (reg == null || req == null || req.RecordType == null || req.RecordType.Name != 'Route Change Request') {
                System.debug('Skipping SRN: ' + srn + ' - No matching request or invalid record type.');
                continue;
            }
            
            String status = reg.Registration_Status__c;
            String studentName = req.RTR_Student__r != null ? req.RTR_Student__r.Name : 'N/A';
            String routeNumber = req.RTR_Route_Pick_Up_Point__r?.RTR_Route_Master__r?.Name != null ? req.RTR_Route_Pick_Up_Point__r.RTR_Route_Master__r.Name : 'N/A';
            String pickUp = req.RTR_Route_Pick_Up_Point__r?.Name != null ? req.RTR_Route_Pick_Up_Point__r.Name : 'N/A';
            String cancellationDate = req.Cancellation_Date__c != null
                ? String.valueOf(req.Cancellation_Date__c)
                : 'N/A';
            
            String subject;
            String body;
            String approvalLink = 'N/A';
            
            // Querying the process instance and work item for the specific request
            ProcessInstanceWorkitem piw = null;
            try {
                piw = [
                    SELECT Id, ProcessInstance.TargetObjectId
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId = :req.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
                String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
                approvalLink = baseUrl + '/' + piw.Id; // This link will take directly to the approval page
                System.debug('Generated approval link for SRN ' + srn + ': ' + approvalLink);
            } catch (QueryException e) {
                System.debug('No active ProcessInstanceWorkitem found for request ID: ' + req.Id + '. Error: ' + e.getMessage());
            }
            
            
            switch on status {
                when 'Route Change Request Submitted' {
                    subject = 'Route Change Request Submitted by Student';
                    body = 'Dear ' + transportAdminName + ',<br><br>' +
                        'The student ' + studentName + ' has requested (Request ID: ' + reg.Name + ') for Route change. Please proceed with the process by clicking the link below.<br><br>' +
                        approvalLink + '<br><br>' +
                        '<b>SRN:</b> ' + srn + '<br>' +
                        '<b>Route Number:</b> ' + routeNumber + '<br>' +
                        '<b>Pick Up Point:</b> ' + pickUp + '<br>' +
                        '<b>Requested Date:</b> ' + cancellationDate + '<br><br>' +
                        'Regards,<br>REVA University';
                    
                }
                when 'Route change Finance team approved' {
                    subject = 'Route change Request Completed';
                    body = 'Dear ' + transportAdminName + ',<br><br>' +
                        'The student ' + studentName + '\'s Route change request (Request ID:'+reg.Name+') is Completed.<br><br>' +                        
                        'SRN: ' + srn + '<br>' +
                        'Route Number: ' + routeNumber + '<br>' +
                        'Pick Up Point: ' + pickUp + '<br><br>' +
                        'Regards,<br>REVA University';
                }
                when else {
                    System.debug('Skipping status for SRN: ' + srn + ' - Not eligible for email: ' + status);
                    continue;
                }
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { transportAdminEmail });
            email.setSubject(subject);
            email.setHtmlBody(body);
            email.setOrgWideEmailAddressId(owa.Id);
            emailList.add(email);
        }
        
        if (!emailList.isEmpty()) {
            try {
                Messaging.sendEmail(emailList);
                System.debug('Transport Admin emails sent successfully.');
            } catch (Exception e) {
                System.debug('Failed to send emails: ' + e.getMessage());
            }
        } else {
            System.debug('No emails prepared to send.');
        }
    }
}