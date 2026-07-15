public without sharing class attachNOCToStaffQuatresRequest{
    @AuraEnabled
    public static void createStaffQuartersRequestAttachment(id requestId) {
        // Retrieve existing StaffQuartersRequest record
        Staff_Quarters_Request__c staffQuartersRequest = [SELECT Id, Name FROM Staff_Quarters_Request__c WHERE Id = :requestId LIMIT 1];
        if (staffQuartersRequest != null) {
            // Convert formData to Blob
            // Blob pdfBody = Blob.valueOf(formData);
            PageReference pdfPages = Page.StaffVacationNOC;
            System.debug('quarter request id: '+ staffQuartersRequest.id);
            pdfPages.getParameters().put('Id', staffQuartersRequest.id);
            Blob pdfBlobs;
   system.debug('pdfPages'+pdfPages);
            if (pdfPages != null) {
                if(!test.isRunningTest()){
                    pdfBlobs = pdfPages.getContent();
                }else{
                    pdfBlobs = blob.valueof('This is a mock PDF content for testing.');
                }
                // pdfBlobs = pdfPages.getContent();
                System.debug('entered if block');
            } else {
                pdfBlobs = Blob.valueOf('Test');
                System.debug('entered else block');
            }
            Blob myBlob = pdfBlobs; // blob variable
            String blobString = EncodingUtil.base64Encode(myBlob);
            System.debug('Blob Data: ' + blobString);
            // system.debug('pdf'+ pdfBlobs);
            // Create a new Attachment record and associate it with the StaffQuartersRequest record
            Attachment attachment = new Attachment();
            attachment.ParentId = staffQuartersRequest.Id;
            attachment.Body = pdfBlobs;
            attachment.Name = 'HostelManagementNOC.pdf';
            attachment.ContentType = 'application/pdf';
            insert attachment;
            
            // Fetch the user to whom you want to send the email
            User recipient = [SELECT Id, Email, Name FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name = 'Warden') LIMIT 1];//[SELECT Id, Email FROM User WHERE Name = 'Warden user' LIMIT 1];
            System.debug('recepiet: '+ recipient);
            System.debug('user email: '+ recipient.Email);
                  
          // Create a new email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(recipient.Email != null){
                email.setToAddresses(new List<String>{recipient.Email});
            }else{
                email.setToAddresses(new List<String>{'vamshi.udutha@cloudodyssey.co'});
            }
            
            email.setSubject('Staff Quarters NOC');
            email.setPlainTextBody('Please find attached No Objection Certificate');
            
            // Attach the PDF to the email
            Messaging.EmailFileAttachment attachmentToEmail = new Messaging.EmailFileAttachment();
            attachmentToEmail.setFileName('HostelManagementNOC.pdf');
            attachmentToEmail.setBody(pdfBlobs);
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachmentToEmail});
            
            // Send the email
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
   
            
        }else {
            // Handle the case where formData is null or empty
            System.debug('Invalid formData. Make sure formData is not null or empty.');
        }
    } 
}