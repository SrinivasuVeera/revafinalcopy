public class PartialPAFNotificationService implements Queueable, Database.AllowsCallouts {
    
    private List<NotificationData> notificationDataList;
    private String whatsappTemplateName;
    
    public class NotificationData {
        public String  contactId        { get; set; }
        public String  contactName      { get; set; }
        public String  contactEmail     { get; set; }
        public String  contactPhone     { get; set; }
        public String  studentPaymentId { get; set; }
        public Decimal remainingAmount  { get; set; }
        public String  programName      { get; set; } 
        public String  counselorName    { get; set; }
        public String  counselorPhone    { get; set; }
        
        public NotificationData(
            String  contactId,
            String  contactName,
            String  contactEmail,
            String  contactPhone,
            String  studentPaymentId,
            Decimal remainingAmount,
            String  programName,     
             String  counselorName ,
            String  counselorPhone 
        ) {
            this.contactId        = contactId;
            this.contactName      = contactName;
            this.contactEmail     = contactEmail;
            this.contactPhone     = contactPhone;
            this.studentPaymentId = studentPaymentId;
            this.remainingAmount  = remainingAmount;
            this.programName      = programName;   
            this.counselorName    = counselorName;
            this.counselorPhone   = counselorPhone;
        }
    }
    
    public PartialPAFNotificationService(
        List<NotificationData> notificationDataList,
        String whatsappTemplateName
    ) {
        this.notificationDataList  = notificationDataList;
        this.whatsappTemplateName  = whatsappTemplateName;
        system.debug('Notification list'+ this.notificationDataList);
    }
    
    public void execute(QueueableContext context) {
        
        String domain = '';
        
        List<Domain> domainList = [
            SELECT Domain
            FROM Domain
            WHERE HttpsOption = 'CommunityAlt'
            LIMIT 1
        ];
        
        if(!domainList.isEmpty()) {
            domain = 'https://' + domainList[0].Domain;
        }
        
        
        sendWhatsAppNotifications(domain);
        sendEmails(domain);
    }
    
    private String buildPaymentLink(
        String domain,
        String contactId,
        String studentPaymentId
    ) {
        return domain +
               '/Admissions/s/payment-page?contactId=' + contactId +
               '&isPAF=true' +
               '&stupayid=' + studentPaymentId;
    }
    
  /*   private void sendEmails(String domain) {
        
        List<Messaging.SingleEmailMessage> emailList =
            new List<Messaging.SingleEmailMessage>();
       OrgWideEmailAddress orgWide = [
            SELECT Id
             FROM OrgWideEmailAddress
            WHERE DisplayName = 'REVA Alerts'
             LIMIT 1
         ];
        for(NotificationData data : notificationDataList) {
            
             if(String.isBlank(data.contactEmail)) {
                 continue;
            }
            
            String paymentLink = buildPaymentLink(
                 domain,
                 data.contactId,
                 data.studentPaymentId
             );
            
             Messaging.SingleEmailMessage mail =
                new Messaging.SingleEmailMessage();
            
             mail.setToAddresses(new List<String>{ data.contactEmail });
             mail.setOrgWideEmailAddressId(orgWide.Id);
             mail.setSubject('Payment Link for Completion of PAF – Action Required');
            
             String body =
                 'Dear ' + data.contactName + ',<br/><br/>' +
                
                 'This is to inform you that your payment for the ' +
                 'PAF (Provisional Admission Fee) is partially completed.' +
                
                 '<br/><br/>' +
                
                'Kindly use the payment link provided below to complete ' +
                 'the remaining payment and ensure your application is ' +
                'processed without any delay.' +
                
                 '<br/><br/>' +
                
                '🔗 <b>Payment Link:</b><br/>' +
                
                 '<a href="' + paymentLink + '">' + paymentLink + '</a>' +
                
                 '<br/><br/>' +
                
                 'For any queries, feel free to reach out to your counsellor.' +
                
                 '<br/><br/>' +
                
                 'Regards<br/>' +
                 'REVA University';
            
             mail.setHtmlBody(body);
             emailList.add(mail);
         }
        
         if(!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
             System.debug('Emails Sent : ' + emailList.size());
         }
     }

    
    private void sendWhatsAppNotifications(String domain) {
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [
            SELECT Template_Field__c,
                   Template_ID__c
            FROM WhatsApp_Notification_Template__mdt
            WHERE Template_ID__c = :whatsappTemplateName
        ];
        
        if(templateMetadata.isEmpty()) {
            System.debug('No WhatsApp Template Found For : ' + whatsappTemplateName);
            return;
        }
        
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(NotificationData data : notificationDataList) {
            
            if(String.isBlank(data.contactPhone)) {
                System.debug('Skipping WhatsApp — No Phone For Contact : ' + data.contactId);
                continue;
            }
            
            String paymentLink = buildPaymentLink(
                domain,
                data.contactId,
                data.studentPaymentId
            );
            
            Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
            
            notification.templateId = whatsappTemplateName;
            notification.params     = new Map<String, String>();
            
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                
                String[] keys = metadata.Template_Field__c.split(',');
                
                for(String key : keys) {
                    
                    String trimmedKey = key.trim();
                    
                    if(trimmedKey == 'applicant_name') {
                        notification.params.put(trimmedKey, data.contactName);
                        
                    } else if(trimmedKey == 'URL') {
                        notification.params.put(trimmedKey, paymentLink);
                        
                    } 
                  
                }
            }
            
            // ✅ Clean phone — same as reference class
            String cleanPhone = data.contactPhone
                .replace('+', '')
                .replace('-', '')
                .trim();
            
            if(!phoneNumbersToNotifications.containsKey(cleanPhone)) {
                phoneNumbersToNotifications.put(
                    cleanPhone,
                    new List<Yellow_AI_Utility.WhatsAppNotification>{ notification }
                );
            }
        }
        
        if(!phoneNumbersToNotifications.isEmpty()) {
            HttpResponse response =
                Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('WhatsApp Response : '           + response);
            System.debug('WhatsApp Notifications Sent : ' + phoneNumbersToNotifications.size());
        }
    }*/
    private void sendEmails(String domain) {

    EmailTemplate template = [
        SELECT HtmlValue, Subject
        FROM EmailTemplate
        WHERE DeveloperName = 'Partial_PAF_Payment_Reminder'
        LIMIT 1
    ];

    List<Messaging.SingleEmailMessage> emailList =
        new List<Messaging.SingleEmailMessage>();

    OrgWideEmailAddress orgWide = [
        SELECT Id
        FROM OrgWideEmailAddress
        WHERE DisplayName = 'REVA Alerts'
        LIMIT 1
    ];

    for(NotificationData data : notificationDataList) {
        system.debug('iwjwwxwixwixix'+data);

        if(String.isBlank(data.contactEmail)) continue;

        String paymentLink = buildPaymentLink(
            domain,
            data.contactId,
            data.studentPaymentId
        );

            String body = template.HtmlValue;
            body = body.replace('{{{Recipient.Name}}}',data.contactName);
            body = body.replace('{{{Recipient.Program_Name__c}}}',data.programName);
            body = body.replace('{{{Recipient_Student_Fee_Payment__c}}}',paymentLink);
            body = body.replace('{{{Recipient.Owner_Name__c}}}',data.counselorName);
        Messaging.SingleEmailMessage mail =
            new Messaging.SingleEmailMessage();

        mail.setToAddresses(new List<String>{ data.contactEmail });
        mail.setOrgWideEmailAddressId(orgWide.Id);
        mail.setSubject(template.Subject);
        mail.setHtmlBody(body);

        emailList.add(mail);
    }

    if(!emailList.isEmpty()) {
        Messaging.sendEmail(emailList);
        System.debug('Emails Sent : ' + emailList.size());
    }
}
    
        
    private void sendWhatsAppNotifications(String domain) {
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [
            SELECT Template_Field__c,
                   Template_ID__c
            FROM WhatsApp_Notification_Template__mdt
            WHERE Template_ID__c = :whatsappTemplateName
        ];
        
        if(templateMetadata.isEmpty()) {
            System.debug('No WhatsApp Template Found For : ' + whatsappTemplateName);
            return;
        }
        
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(NotificationData data : notificationDataList) {
            
            if(String.isBlank(data.contactPhone)) {
                System.debug('Skipping WhatsApp — No Phone For Contact : ' + data.contactId);
                continue;
            }
            
            String paymentLink = buildPaymentLink(
                domain,
                data.contactId,
                data.studentPaymentId
            );
            
            Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
            
            notification.templateId = whatsappTemplateName;
            notification.params     = new Map<String, String>();
            
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                
                String[] keys = metadata.Template_Field__c.split(',');
                
                for(String key : keys) {
                    
                    String trimmedKey = key.trim();
                    
                    if(trimmedKey == 'studentname') {
                        notification.params.put(trimmedKey, data.contactName);
                        
                    } else if(trimmedKey == 'programname') {
                        notification.params.put(trimmedKey, data.programName);
                        
                    } else if(trimmedKey == 'link') {
                        notification.params.put(trimmedKey, paymentLink);
                        
                    } else if(trimmedKey == 'name') {
                        notification.params.put(trimmedKey, data.counselorName);
                        
                    } else if(trimmedKey == 'phone') {
                        notification.params.put(trimmedKey, data.counselorPhone);
                        
                    } 
                  
                }
            }
            
            // ✅ Clean phone — same as reference class
            String cleanPhone = data.contactPhone
                .replace('+', '')
                .replace('-', '')
                .trim();
            
            if(!phoneNumbersToNotifications.containsKey(cleanPhone)) {
                phoneNumbersToNotifications.put(
                    cleanPhone,
                    new List<Yellow_AI_Utility.WhatsAppNotification>{ notification }
                );
            }
        }
        
        if(!phoneNumbersToNotifications.isEmpty()) {
            HttpResponse response =
                Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('WhatsApp Response : '           + response);
            System.debug('WhatsApp Notifications Sent : ' + phoneNumbersToNotifications.size());
        }
    }

}