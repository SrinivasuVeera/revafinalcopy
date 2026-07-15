/*
 Classs Name : SendEmailHostelFeeRemain.
 Supporting Class : NumberTOWordConvertion.
 Schdule Class : schedulableSendEmailHostelFeeRemainder.  
 Job Name : schedulableSendEmailHostelFeeRemainder. 
 Pupose : Send Reminder to student for pay hostel pending fee.
 Version : 1.0
 Date : 08-Nov-2023.
 User Story : REVA-102.
 Devloper : Rajnish.
  
*/
global class SendEmailHostelFeeRemainder implements Database.Batchable<sObject>
{
    global Database.QueryLocator  start(Database.BatchableContext BC)
    {
        Date remaiderDate=System.today().addDays(10);
         String paymentType = 'Partial Payment';
        system.debug('remaiderDate:'+[SELECT Id, Name, Contact__r.Name, Program_Batch_Start_Year__c, Program_Batch__c, Student_Personal_Email__c, Father_Email_ID__c, Amount_Pending__c, Hostel_Due_Date__c, Payment_Type__c FROM Student_Fee__c limit 2]);
       
        String query ='SELECT Id, Name, Contact__r.Name, Program_Batch_Start_Year__c,Contact__r.Mobilephone, Program_Batch__c, Student_Personal_Email__c, Father_Email_ID__c, Amount_Pending__c, Hostel_Due_Date__c, Payment_Type__c FROM Student_Fee__c WHERE Student_Personal_Email__c != null AND Amount_Pending__c > 0 AND Payment_Type__c = :paymentType AND Hostel_Due_Date__c <= :remaiderDate';
        
        return Database.getQueryLocator(query);
    } 
 
    global void execute(Database.BatchableContext BC, List<Student_Fee__c> lstscope)
    {
         String Duedate=''; 
     	system.debug('lstscope:'+lstscope);  
        NumberTOWordConvertion   convertWord=new NumberTOWordConvertion();
        
  		OrgWideEmailAddress owa = [select id, Address from OrgWideEmailAddress][0];
        List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
  
         for (Student_Fee__c sf : lstscope) 
         {
           
               if(sf.Student_Personal_Email__c != null && sf.Amount_Pending__c >0) 
               {
                    
                   
                    if(sf.Hostel_Due_Date__c !=null){
                        Datetime dtDate=Datetime.newInstance(sf.Hostel_Due_Date__c.year(),sf.Hostel_Due_Date__c.month(),sf.Hostel_Due_Date__c.day());
                        Duedate=dtDate.format('dd-MMM-YYYY');                       
                    }
                    
                    
                    decimal PendingAmount=sf.Amount_Pending__c;
                    String AmountinWord = convertWord.getNumberTOWordConvertion(PendingAmount);
            
                  Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                   List<String> sendTo = new List<String>();
                   List<String> ccTo = new List<String>();
                    
                 mail.setOrgWideEmailAddressId(owa.Id);
                  sendTo.add(sf.Student_Personal_Email__c);
                  mail.setToAddresses(sendTo);
                  mail.setReplyTo('noreply@salesforce.com');                  
                    if(sf.Father_Email_ID__c !=null){
                        ccTo.add(sf.Father_Email_ID__c);
                    }
                    else{
                        ccTo.add('noreply@salesforce.com');
                    }
                  mail.setCcAddresses(ccTo);
                  mail.setBccSender(false);
               // mail.setSubject('Hostel Fee Reminder');
               /*   String body = 'Dear Student: ' + sf.Name + '.'+'<br/>';
                  body += 'Class : ' + sf.Program_Batch__c + '.'+'<br/>';
                  body += 'Year of Studying : ' + sf.Program_Batch_Start_Year__c + '.'+'<br/>';                   
                  body += 'Please pay your pending fee before due date : ' + Duedate + '.'+'<br/>';
                  body += 'Due Amount is : '+ sf.Amount_Pending__c + ' RS/-' +'('+ AmountinWord + ')'+' .'+'<br/>';
                  body += 'If you already pay, please ignore this email.';*/
                  
                  mail.setSubject('Hostel Fee Payment Reminder');
                   String body = 'Dear ' + sf.Contact__r.Name + ',<p>';
                   body += 'Greetings from REVA University! <p> ';    
                   body += 'This email is to remind you that your hostel payment is due by '+ Duedate + '. Please ensure that the payment is made on time to avoid any inconvenience or late fees. ';
				   body += 'If you have already made the payment, Kindly disregard this message. <p>';               
                   body+= 'Thank You &amp; Warm regards,<br/>';
                   body+=  'REVA University</p>';
                  mail.setHtmlBody(body);
                  mails.add(mail);
                 }
  		}
          system.debug('mails=='+mails);
          Messaging.sendEmail(mails);
        
        
              String templateId = 'hostel_fee_reminder_students';
            
            WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];
            
            // Map to store notifications for each contact's phone number
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

            // Iterate through contacts to create notifications
            for (Student_Fee__c clist : lstscope) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();
 				
                notification.params.put('Student_name', clist.Contact__r.Name); 
                notification.params.put('due_date', Duedate);
        
                if(clist.Contact__r.Mobilephone !=null){
                    String plusRemoved = clist.Contact__r.Mobilephone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});                 
                 }  
             
                System.debug('Phone Number -->'+clist.Contact__r.Mobilephone);
                
              //  HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
             
            }     
            System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));

         	
	}
 
    global void finish(Database.BatchableContext BC)
    {
       // String jobId = System.scheduleBatch(new SendEmailHostelFeeRemainder(),'Job Name',1);
       // System.debug('Scheduled Job Id: '+ jobId);
      //  String jobId = System.scheduleBatch(new SendEmailHostelFeeRemainder(), 'Hourly Batch Job', 1);
    }
}