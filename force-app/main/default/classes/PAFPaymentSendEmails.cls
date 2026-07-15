public class PAFPaymentSendEmails {
    
    
    public static String ApplicantName;
    public static String ApplicantNumber;
    public static String PhoneNumber;
    Public static string ApplicantOwnerName;
    Public static string ApplicantOwnerMobile;
    
    public static void sendDirectPaymentLinkEmail(Map<Id,Map<String,String>> conEmailSourceMap){
        System.debug('Email Map : ' + conEmailSourceMap);
        System.enqueueJob(new PAFPaymentEmailQueueable(conEmailSourceMap));
    }
    public static void sendConfirmEmail(Map<Id,Map<String,String>> ConfirmconEmailSourceMap){
        
        List<Contact> conList = [
            SELECT Id, Name, Email, Application_Number__c,Admission_Mode__c,
            Primary_Academic_Program_Name__c, Owner.Email
            FROM Contact
            WHERE Id IN :ConfirmconEmailSourceMap.keySet()
        ];
        
        Map<Id,hed__Application__c> appMap = new Map<Id,hed__Application__c>();
        
        for(hed__Application__c app : [
            SELECT Id, hed__Applicant__c, hed__Application_Status__c
            FROM hed__Application__c
            WHERE hed__Applicant__c IN :ConfirmconEmailSourceMap.keySet()
        ]){
            appMap.put(app.hed__Applicant__c, app);
        }        
        
        Map<Id, Decimal> annualFeeMap = new Map<Id, Decimal>();
        Map<Id, Decimal> pafFeeMap = new Map<Id, Decimal>();
        
        for(Student_Fee__c fee : [
            SELECT Contact__c, Actual_Program_Fee__c, Provisional_Admission_Fee__c
            FROM Student_Fee__c
            WHERE Contact__c IN :ConfirmconEmailSourceMap.keySet()
            AND Fee_Type__c IN ('University Fee','Tuition Fee')
            AND Fee_Year__c = '1st Year'
        ]){
            
            if(!annualFeeMap.containsKey(fee.Contact__c)){
                annualFeeMap.put(fee.Contact__c,0);
            }
            
            if(fee.Actual_Program_Fee__c != null){
                annualFeeMap.put(
                    fee.Contact__c,
                    annualFeeMap.get(fee.Contact__c) + fee.Actual_Program_Fee__c
                );
            }
            
            if(fee.Provisional_Admission_Fee__c != null){
                pafFeeMap.put(fee.Contact__c, fee.Provisional_Admission_Fee__c);
            }
        }
        
        Map<Id, Decimal> paymentMap = new Map<Id, Decimal>();
        
        for(Student_Payment__c pay : [
            SELECT Amount__c, Contact__c
            FROM Student_Payment__c
            WHERE Contact__c IN :ConfirmconEmailSourceMap.keySet()
            AND Payment_Status__c = 'Success'
            AND (Fee_Type__c LIKE '%University%' OR Fee_Type__c LIKE '%Tuition%')
        ]){
            
            if(!paymentMap.containsKey(pay.Contact__c)){
                paymentMap.put(pay.Contact__c,0);
            }
            
            paymentMap.put(
                pay.Contact__c,
                paymentMap.get(pay.Contact__c) + pay.Amount__c
            );
        }
        
        OrgWideEmailAddress owea = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE DisplayName = 'REVA Alerts'
            LIMIT 1
        ];
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        
        for(Contact con : conList){
            
            hed__Application__c app = appMap.get(con.Id);
            if(app == null) continue;
            
            Decimal totalAnnualFee = annualFeeMap.containsKey(con.Id) ? annualFeeMap.get(con.Id) : 0;
            Decimal totalPAFFee = pafFeeMap.containsKey(con.Id) ? pafFeeMap.get(con.Id) : 0;
            Decimal totalFeePaidSucess = paymentMap.containsKey(con.Id) ? paymentMap.get(con.Id) : 0;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(owea.Id);
            mail.setToAddresses(new List<String>{con.Email});
            
            String body = '';
            
            if((app.hed__Application_Status__c == 'Partial Paid'
                || app.hed__Application_Status__c == 'Provisionally Offered')
               && totalFeePaidSucess < totalPAFFee){
                   
                   mail.setSubject('REVA University – Partial Payment Confirmation');
                   
                   body += 'Dear ' + con.Name + ',<br/><br/>';
                   body += 'Application No: ' + con.Application_Number__c + '<br/>';
                   body += 'Programme: ' + con.Primary_Academic_Program_Name__c + '<br/><br/>';
                   
                   body += 'Greetings from REVA University!<br/><br/>';
                   
                   body += 'Thank you for making the Partial payment towards your provisional admission. ';
                   body += 'We truly appreciate your interest in joining REVA University and are pleased to inform you that your seat has been blocked for the above-mentioned programme.<br/><br/>';
                   
                   body += 'Kindly note that your admission ₹'+ totalPAFFee +' and seat will be provisionally confirmed upon payment of 50% of the first-year programme fee. ';
                   body += 'We kindly request you to complete the remaining provisional admission fee at the earliest to proceed further.<br/><br/>';
                   
                   body += '<b>Fee Details:</b><br/>';
                   body += 'Annual Program Fee: ₹ ' + totalAnnualFee + '<br/>';
                   body += 'Fee Paid: ₹ ' + totalFeePaidSucess + '<br/><br/>';
                   
                   body += 'Upon receipt of the required payment, we will share your Provisional Admission Letter and guide you through the next steps of the admission process.<br/><br/>';
                   
                   body += 'If you require any assistance regarding the payment process or admission formalities, please feel free to contact us. We are happy to support you at every step.<br/><br/>';
                   
                   body += 'We look forward to welcoming you to the REVA University community.<br/><br/>';
                   
                   body += 'Warm regards,<br/>';
                   body += ConfirmconEmailSourceMap.get(con.Id).get('CounsellorName') + '<br/>';
                   body += con.Owner.Email + '<br/>';
                   body += ConfirmconEmailSourceMap.get(con.Id).get('CounsellorMobileNo') + '<br/>';
                   body += 'REVA University';
                   
               }
            else{
                
                mail.setSubject('REVA - Fee Payment Confirmation');
                
                body = 'Dear '+ con.Name + ',<br/>';
                body += '<br/> We have received your Provisional Admission Fee of Rs. '
                    + ConfirmconEmailSourceMap.get(con.Id).get('TotalFee') + '.<br/>';
                
                body += '<br/> For any further clarity, connect with your admission counselor '
                    + ConfirmconEmailSourceMap.get(con.Id).get('CounsellorName')
                    + ' on '
                    + ConfirmconEmailSourceMap.get(con.Id).get('CounsellorMobileNo') + '<br/>';
                
                body += '<br/> Regards, <br/> REVA University';
                
            }
            
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        
        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);
        }
    }
    public static void sendRejectionEmail(Map<Id,Map<String,String>> RejectconEmailSourceMap){
        List<Contact> conList = [Select id, name, Email FROM Contact WHERE id =: RejectconEmailSourceMap.keySet()];
        system.debug('conList::'+conList);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> lstEmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 
        
        for(Contact con : conList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            List<String> sendTo = new List<String>();
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo);
            mail.setSubject('REVA - Payment Status');
            String body='' ;
            
            body = 'Dear '+ con.Name + ',<br/>';
            body += '<br/> We regret to inform you that the ' + (RejectconEmailSourceMap.get(con.Id)).get('ModeofPayment') + ' payment associated with Application No:' + (RejectconEmailSourceMap.get(con.Id)).get('Applicationno') + ', amounting to ' + (RejectconEmailSourceMap.get(con.Id)).get('Amount') +  ', was rejected at ' + (RejectconEmailSourceMap.get(con.Id)).get('Dateandtime') +  '.';
            body += ' Please contact your admission counselor for further guidance on the necessary procedure to resolve this issue.<br/>';
            body += ' <br/> Thank you for your attention to this matter.<br/>';
            body += '<br/> Regards, <br/> REVA University';
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        if(mails.size() > 0){
            Messaging.sendEmail(mails); 
        }
    }
    
    
    
    public static void WhatstappNotificationCounselor(List<Contact> conRecs,Set<Id> stuPaySet, String whatsappTemplateName){
        System.debug('Hellooooooooo:::::');
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        Map<Id,Map<String,String>> RejectconEmailSourceMapOwner = new Map<Id,Map<String,String>>();
        notification1.templateId = whatsappTemplateName;
        Map<String,String> RejectEmailSourceMapOwner = new Map<String,String>();  
        // Fetch keys from custom metadata based on templateId
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        List<Student_payment__c> stuPayList=[SELECT Id, Name,Payment_Mode_Type__c, Amount__c, Contact__c, Billdesk_Url__c, payment_status__c FROM Student_payment__c WHERE Contact__c =:conRecs and id =: stuPaySet ORDER BY CreatedDate Desc];
        Map<Id,Decimal> conStuPayAmount = new Map<Id,Decimal>();
        Map<Id,Id> conStuPayIdMap = new Map<Id,Id>();
        Map<Id,string> conStuPayModeMap = new Map<Id,string>();
        for(Student_payment__c stupay : stuPayList){
            conStuPayAmount.put(stupay.Contact__c,stupay.Amount__c);
            conStuPayIdMap.put(stupay.Contact__c,stupay.Id);
            conStuPayModeMap.put(stupay.Contact__c,stupay.Payment_Mode_Type__c);
        }
        
        
        for( contact stu : conRecs ){
            notification1.params = new Map<String, String>();
            //Map<String,String> CounselorMobile = new Map<String,String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'payment_reject_counselor') {
                    for (String key : keys) {
                        if (key == 'CounselorName') {
                            notification1.params.put(key, stu.Owner.Name);
                            RejectEmailSourceMapOwner.put(key, stu.Owner.Name);
                        }else if (key == 'modeofpayment') {
                            notification1.params.put(key.trim(), String.valueOf(conStuPayModeMap.get(stu.Id)));
                            RejectEmailSourceMapOwner.put(key.trim(), String.valueOf(conStuPayModeMap.get(stu.Id)));
                        } else if (key == 'Applictionno') {
                            notification1.params.put(key.trim(), stu.Application_Number__c);
                            RejectEmailSourceMapOwner.put(key.trim(), stu.Application_Number__c);
                        } 
                        else if (key == 'ApplicantName') {
                            notification1.params.put(key, stu.Name); 
                            RejectEmailSourceMapOwner.put(key, stu.Name);
                        } else if (key == 'Amount') {
                            notification1.params.put(key.trim(), String.valueOf(conStuPayAmount.get(stu.Id))); //PAF amount entered by the counselor
                            RejectEmailSourceMapOwner.put(key.trim(), String.valueOf(conStuPayAmount.get(stu.Id)));
                        }
                        else if (key == 'DateandTime') {         
                            DateTime currentDateTime = System.now();
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime); 
                            RejectEmailSourceMapOwner.put(key.trim(), formattedDateTime);
                        } 
                        
                    }
                }
                
            }
            if(RejectEmailSourceMapOwner.size() > 0){
                RejectconEmailSourceMapOwner.put(stu.Id,RejectEmailSourceMapOwner);
            }
            
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                if(stu.owner.mobilephone !=null){
                    String plusRemoved = stu.owner.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                    system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                }       
        }
        if(RejectconEmailSourceMapOwner.size() > 0){
            //if AddedbyRajashekar
            if(RecursiveTriggerHandler.isEmail)
            {
                RecursiveTriggerHandler.isEmail = false;
                sendRejectionEmailOwner(RejectconEmailSourceMapOwner);
            }
        }
        // if Added by Rajashekar
        if(!system.isbatch()){
            System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
        }
    }
    
    
    public static void sendRejectionEmailOwner(Map<Id,Map<String,String>> RejectconEmailSourceMapOwner){
        List<Contact> conList = [Select id, name,owner.Name,owner.Email, Email FROM Contact WHERE id =: RejectconEmailSourceMapOwner.keySet()];
        system.debug('conList::'+conList);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> lstEmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 
        
        for(Contact con : conList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            List<String> sendTo = new List<String>();
            sendTo.add(con.owner.Email);
            mail.setToAddresses(sendTo);
            mail.setSubject('REVA - Payment Status');
            String body='' ;
            
            body = 'Dear '+ con.owner.Name + ',<br/>';
            body += '<br/> We regret to inform you that the ' + (RejectconEmailSourceMapOwner.get(con.Id)).get('modeofpayment') + ' payment associated with Application No:' + (RejectconEmailSourceMapOwner.get(con.Id)).get('Applictionno') + ','  + (RejectconEmailSourceMapOwner.get(con.Id)).get('ApplicantName') +', amounting to ' + (RejectconEmailSourceMapOwner.get(con.Id)).get('Amount') +  ', was rejected at ' + (RejectconEmailSourceMapOwner.get(con.Id)).get('DateandTime') +  '.<br/>';
            body += '<br/> Regards, <br/> REVA University';
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        if(mails.size() > 0){
            Messaging.sendEmail(mails); 
        }
    }
    
    
    @Future(callout=true)
    public static void makeCalloutAsync( Set<Id> stuPaySet) {
        List<Student_payment__c> stuPayList = [SELECT Id, Name, Mode_of_Payment__c,Payment_Mode_Type__c, Amount__c, Contact__r.Owner.Name, Contact__r.Owner.mobilephone,Contact__c,contact__r.Name,Contact__r.Application_Number__c,Contact__r.MobilePhone, Billdesk_Url__c, payment_status__c FROM Student_payment__c WHERE Id IN :stuPaySet ORDER BY CreatedDate DESC];
        System.debug('stuPayList::'+stuPayList);
        for(Student_payment__c sp:stuPayList){
            ApplicantName = sp.contact__r.Name;
            ApplicantNumber = sp.Contact__r.Application_Number__c;
            ApplicantOwnerName = sp.Contact__r.owner.Name;
            if(sp.Contact__r.mobilephone != null){
                String plusRemoved = sp.Contact__r.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                PhoneNumber = correctedWhatsappNumber;
            }
            if(sp.Contact__r.Owner.mobilephone != null){
                String plusRemoved = sp.Contact__r.Owner.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                ApplicantOwnerMobile= correctedWhatsappNumber;
            }
            if (!stuPayList.isEmpty()) {
                List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>(); // Define messageList here
                for (Student_payment__c trReg : stuPayList) {
                    // Determine which method to call based on TemplateName__c value
                    if (trReg.payment_status__c == 'Failed') {
                        System.debug('Rejected');
                        RejectedSmsApplicant(trReg, messageList);
                        RejectedSmsOwner(trReg, messageList);
                    }
                    /*  if (trReg.payment_status__c == 'Pending') {

LinkSmsApplicant(trReg, messageList);
SMS_API_Utility.SendSMSOneToMany('Admission_Payment_Link', messageList);
ConfirmSmsApplicant(trReg, messageList);
SMS_API_Utility.SendSMSOneToMany('Partial_Payment_Confirmation', messageList);
}*/
                }
                if (!messageList.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('Payment_Rejection_Applicant', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Payment_Rejection_Counsellor', messageList);
                    
                }
            } else {
                System.debug('No related records found for the provided IDs');
            }
        }
    }
    
    public static void RejectedSmsApplicant(Student_payment__c stuPaySet, List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        String ApplicantName = ApplicantName;       
        String ModeofPayment = stuPaySet.Payment_Mode_Type__c;
        String ApplicationNo=ApplicantNumber;
        Decimal Amountrejected=stuPaySet.Amount__C;
        Datetime DateandTime = system.now();
        string phnNumber=PhoneNumber;
        String message = 'Dear ' + ApplicantName +  ',\n\nWe regret to inform you that the ' + ModeofPayment + ' payment vide App No ' + ApplicationNo + ', of Rs. ' + Amountrejected + ' , was rejected today at ' + DateandTime + '.\n\nPlease contact your admission counselor for further guidance to resolve this issue.\n\nRegards\nREVA University';
        
        // Assuming you have a method to send SMS and you pass the message and phone number
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007237864665829023';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
    
    public static void RejectedSmsOwner(Student_payment__c stuPaySet, List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        String ApplicantName = ApplicantName;       
        String ModeofPayment = stuPaySet.Payment_Mode_Type__c;
        String ApplicationNo=ApplicantNumber;
        Decimal Amountrejected=stuPaySet.Amount__C;
        Datetime DateandTime = system.now();
        string phnNumber=ApplicantOwnerMobile;
        String message = 'Dear ' + ApplicantOwnerName +  ',\n\nYou are being informed that a ' + ModeofPayment + ' payment vide App No ' + ApplicationNo + ' ' + ApplicantName + ', of Rs. ' + Amountrejected + ' , was rejected on ' + DateandTime + '.\n\nRegards\nREVA University';
        
        // Assuming you have a method to send SMS and you pass the message and phone number
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007175550024129634';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
    
    
}