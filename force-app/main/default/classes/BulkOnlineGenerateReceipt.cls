public class BulkOnlineGenerateReceipt {
     public static void generateReceipt(list<Student_payment__C> studentPayments){
        
        List<ContentVersion> receiptContent = new List<ContentVersion>();
        for(Student_Payment__C payment : [select id,Payment_Status__c,Fee_Type__c,contact__r.Email,contact__c,
                                          Contact__r.Application_Number__c,contact__r.Name,Transaction_Id__c,
                                          Payment_Gateway__c FROM Student_Payment__c WHERE Id =: studentPayments]){
            
            if(payment.Payment_Status__c == 'Success' && payment.Fee_Type__c == 'Application Fee'){
                   
                   PageReference pdfPage = Page.Receipt_PDF_Generation;
                   pdfPage.getParameters().put('id',payment.Id);
                   pdfPage.getParameters().put('transactionId',payment.Transaction_Id__c);
                   pdfPage.getParameters().put('paymentGateway',payment.Payment_Gateway__c);
                                      
                   Blob pdfBlob; 
                   if(Test.isRunningTest()){
                       pdfBlob = Blob.valueOf('Test Content');
                   }
                   else{
                       pdfBlob = pdfPage.getContent();
                   }

                   ContentVersion cv = new ContentVersion();
                   cv.VersionData = pdfBlob;
                   cv.Title = payment.Contact__r.Application_Number__c+'-'+payment.contact__r.Name.deleteWhitespace()+'-'+DateTime.now().format('dd-MMM-yyyy');
                   cv.PathOnClient = 'TestFile.pdf';
                   cv.FirstPublishLocationId=payment.Id;
                   receiptContent.add(cv);                           

               }
        }
        
        insert receiptContent;

        Map<Id, Id> contentPaymentMap = new Map<Id, Id>();
        Map<Id, String> paymentContactEmailMap = new Map<Id, String>();
        Map<Id, Id> paymentContactIdMap = new Map<Id, Id>();
        for(ContentVersion cv : receiptContent){
            contentPaymentMap.put(cv.Id, cv.FirstPublishLocationId);
        }
        for(Student_payment__C sp : studentPayments){
            paymentContactEmailMap.put(sp.Id, sp.Contact__r.Email);
        }
        for(Student_payment__C sp : studentPayments){
            paymentContactIdMap.put(sp.Id, sp.Contact__c);
        }
        OrgWideEmailAddress owa = [select id, Address from OrgWideEmailAddress][0];
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Send_Receipt_by_Mail_Template'];
        
        for(ContentVersion cv : receiptContent){
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owa.Id);
            email.setToAddresses(new List<String>{paymentContactEmailMap.get(contentPaymentMap.get(cv.Id))});
            email.setTargetObjectId(paymentContactIdMap.get(contentPaymentMap.get(cv.Id)));//stPay.Contact__c); 
            email.setWhatId(cv.FirstPublishLocationId); 
            email.setTemplateID(emailTemplate.Id); 
            email.setEntityAttachments(new List<Id>{cv.Id});
            
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        } 
    }
    
    
      public static void generatePAFReceipt(list<Student_payment__C> studentPayments){
        
        List<ContentVersion> receiptContent = new List<ContentVersion>();
        for(Student_Payment__C payment : [select id,Payment_Status__c,Fee_Type__c,contact__r.Email,contact__c,
                                          Contact__r.Application_Number__c,contact__r.Name,Transaction_Id__c,Payment_Mode_Type__c,
                                          Payment_Gateway__c FROM Student_Payment__c WHERE Id =: studentPayments]){
            
            if(payment.Payment_Status__c == 'Success' && payment.Fee_Type__c != 'Application Fee'){
                   
                   PageReference pdfPage = Page.Fee_ProvisionalAdmissionFeeReceipt;
                   pdfPage.getParameters().put('id',payment.Id);
                   pdfPage.getParameters().put('transactionId',payment.Transaction_Id__c);
                   pdfPage.getParameters().put('paymentGateway',payment.Payment_Gateway__c);
                  
                   
                   Blob pdfBlob; 
                   if(Test.isRunningTest()){
                       pdfBlob = Blob.valueOf('Test Content');
                   }
                   else{
                       pdfBlob = pdfPage.getContent();
                   }

                   ContentVersion cv = new ContentVersion();
                   cv.VersionData = pdfBlob;
                   cv.Title = payment.Contact__r.Application_Number__c+'-'+payment.contact__r.Name.deleteWhitespace()+'-'+DateTime.now().format('dd-MMM-yyyy');
                   cv.PathOnClient = 'TestFile.pdf';
                   cv.FirstPublishLocationId=payment.Id;
                   receiptContent.add(cv);                           

               }
        }
        
        insert receiptContent;

        Map<Id, Id> contentPaymentMap = new Map<Id, Id>();
        Map<Id, String> paymentContactEmailMap = new Map<Id, String>();
        Map<Id, Id> paymentContactIdMap = new Map<Id, Id>();
        for(ContentVersion cv : receiptContent){
            contentPaymentMap.put(cv.Id, cv.FirstPublishLocationId);
        }
        for(Student_payment__C sp : studentPayments){
            paymentContactEmailMap.put(sp.Id, sp.Contact__r.Email);
        }
        for(Student_payment__C sp : studentPayments){
            paymentContactIdMap.put(sp.Id, sp.Contact__c);
        }
        OrgWideEmailAddress owa = [select id, Address from OrgWideEmailAddress][0];
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Online_and_Offline_PAF_Receipt_Template'];
        
        for(ContentVersion cv : receiptContent){
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owa.Id);
            email.setToAddresses(new List<String>{paymentContactEmailMap.get(contentPaymentMap.get(cv.Id))});
            email.setTargetObjectId(paymentContactIdMap.get(contentPaymentMap.get(cv.Id)));//stPay.Contact__c); 
            email.setWhatId(cv.FirstPublishLocationId); 
            email.setTemplateID(emailTemplate.Id); 
            email.setEntityAttachments(new List<Id>{cv.Id});
            
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        } 
    }

}