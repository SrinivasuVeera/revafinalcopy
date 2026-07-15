public class  RHStudentFeePaymentReceiptPDFGenerator {
    
    // Method for asynchronous PDF generation
    @Future(callout=true)
    public static void generateReceiptPDFAsync(Id paymentId) {
        Student_Fee_Payment__c payment = [SELECT Id, Amount__c, Student_Fee__c, Transaction_Date_Time__c, Line_Item_Payment_Status__c  
                                          FROM Student_Fee_Payment__c 
                                          WHERE Id = :paymentId LIMIT 1];
        if (payment != null && payment.Student_Fee__c != null) {
            // Query the Student_Fee__c record to get associated contact and father details
            Student_Fee__c studentFee = [SELECT Id, Contact__c,Contact__r.Name,Contact__r.Father__c, Contact__r.Email, Contact__r.Active_Semester__r.Name, 
                                         Contact__r.Program_Batch__r.Name, Contact__r.RH_Current_Pursuing_Year_of_Student__c,
                                         Payment_Type__c,Contact__r.Father__r.Name,Contact__r.Mother__r.Name FROM Student_Fee__c WHERE Id = :payment.Student_Fee__c LIMIT 1];
            if (studentFee != null && studentFee.Contact__c != null) {
                System.debug('Student Fee: ' + studentFee);
                System.debug('Student Email: ' + studentFee.Contact__r.Email);
                
                /*Reva_Hostel_Request__c hostelRequest = [SELECT Id, Reva_Hostel_Room__r.Block__c, Reva_Hostel_Room__r.Floor__c,Reva_Hostel_Room__r.Name
                                                        FROM Reva_Hostel_Request__c 
                                                        WHERE Hostel_Room_Request_For__c = :studentFee.Contact__c LIMIT 1];*/
                // Generate PDF receipt
                Blob receiptBlob = generateReceiptPDF(payment);
                
                // Set file name with transaction date-time
                DateTime transactionDateTime = payment.Transaction_Date_Time__c != null ? payment.Transaction_Date_Time__c : Datetime.now();
                String fileName = 'PaymentReceipt_' + transactionDateTime.format('yyyyMMdd_HHmmss') + '.pdf';
                
                // Insert attachment to Student Fee Payment record
                Attachment attachment1 = new Attachment();
                attachment1.ParentId = payment.Id;
                attachment1.Name = fileName;
                attachment1.Body = receiptBlob;
                insert attachment1;
                
                
                try {
                    // Insert as ContentVersion
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.VersionData = receiptBlob;
                    contentVersion.Title = fileName;
                    contentVersion.PathOnClient = fileName;
                    ContentVersion.ContentLocation = 'S';
                    ContentVersion.Origin = 'H';
                    ContentVersion.SharingOption  = 'A';
                    contentVersion.FirstPublishLocationId = userinfo.getUserId();
                    
                } catch (Exception e) {
                    System.debug('Error inserting ContentVersion or ContentDocumentLink: ' + e.getMessage());
                }
                
                // Generate HTML email body
                String studentEmailBody = createEmailBodyForStudent(payment, studentFee);
                
                
                
                // Attach receipt to the email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(fileName);
                attachment.setBody(receiptBlob);
                
                
                // Send email to student
                String studentEmail = studentFee.Contact__r.Email;
                if (studentEmail != null) {
                    System.debug('Sending email to student: ' + studentEmail);
                    sendEmail(studentFee.Contact__c, payment.Id, studentEmail, attachment, studentEmailBody);
                }
                
                // Send email to father
                if (studentFee.Contact__r.Father__c != null) {
                    Contact fatherContact = [SELECT Id, Email, Father__r.Name FROM Contact WHERE Id = :studentFee.Contact__r.Father__c LIMIT 1];
                    String fatherEmail = fatherContact != null ? fatherContact.Email : null;
                    String fatherName = fatherContact != null ? fatherContact.Father__r.Name : null;
                    if (fatherEmail != null) {
                        System.debug('Sending email to father: ' + fatherEmail);
                        String fatherEmailBody = createEmailBodyForParent(payment, studentFee, fatherName);
                        sendEmail(studentFee.Contact__r.Father__c, payment.Id, fatherEmail, attachment, fatherEmailBody);
                    }
                }
                
                // Send email to mother
                if (studentFee.Contact__r.Mother__c != null) {
                    Contact motherContact = [SELECT Id, Email, Mother__r.Name FROM Contact WHERE Id = :studentFee.Contact__r.Mother__c LIMIT 1];
                    String motherEmail = motherContact != null ? motherContact.Email : null;
                    String motherName = motherContact != null ? motherContact.Mother__r.Name : null;
                    if (motherEmail != null) {
                        System.debug('Sending email to mother: ' + motherEmail);
                        String motherEmailBody = createEmailBodyForParent(payment, studentFee, motherName);
                        sendEmail(studentFee.Contact__r.Mother__c, payment.Id, motherEmail, attachment, motherEmailBody);
                    }
                }
                
            }
        }
    }
    
    
    
    Public static Blob generateReceiptPDF(Student_Fee_Payment__c payment) {
        
         /*String baseUrl = URL.getOrgDomainUrl().toExternalForm();
         system.debug('baseUrl===>'+baseUrl);
    
         String fullUrl = baseUrl+'/BillDeskResponse/apex/revahostelstudentfeepaymentreceiptpage?paymentId='+payment.Id;
    
   		 PageReference receiptPage = new PageReference(fullUrl); */
                   //https://reva-university--couat1908.sandbox.my.salesforce-sites.com/BillDeskResponse
       String s ='https://reva-university.my.salesforce-sites.com/BillDeskResponse/apex/revahostelstudentfeepaymentreceiptpage?paymentId='+payment.Id;
       // String s ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/BillDeskResponse/apex/revahostelstudentfeepaymentreceiptpage?paymentId='+payment.Id;
        /*String baseUrl = System.Label.Hostel_Payment_Receipt_URL;
        String s = baseUrl + payment.Id;*/
        PageReference receiptPage = new PageReference(s);
        
        system.debug('receiptPage:==>'+receiptPage);
        // Generate PDF
        Blob receiptBlob;
        try {
            receiptBlob = receiptPage.getContentAsPDF();
            system.debug('receiptBlob :==>'+receiptBlob);
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData = receiptBlob;
            contentVersion.Title = 'test.pdf';
            contentVersion.PathOnClient = 'test'+'.pdf';
            contentVersion.FirstPublishLocationId = userinfo.getUserId();
            
        } catch (Exception e) {
            // Handle error
            System.debug('Error generating receipt PDF: ' + e.getMessage());
            receiptBlob = Blob.valueOf('Error generating receipt PDF: ' + e.getMessage());
        }
        
        return receiptBlob;
    }
    
    // create HTML body
    Public static String createEmailBodyForStudent(Student_Fee_Payment__c payment, Student_Fee__c studentFee) {
        NumberTOWordConvertion numberToWordConverter = new NumberTOWordConvertion();
        String amountInWords = numberToWordConverter.getNumberTOWordConvertion(payment.Amount__c);
        String emailBody = '<html>';
        emailBody += '<head>';
        emailBody += '<style>';
        emailBody += '.container { max-width: 600px; margin: 0 auto; padding: 20px; }';
        emailBody += '.header { text-align: center; padding: 10px; }';
        emailBody += '.confirmation { background-color: #0074b9; color: #fff; padding: 10px; }';
        emailBody += '.disclaimer { font-size: 12px; color: #777; text-align: center; margin-top: 20px; }';
        emailBody += '</style>';
        emailBody += '</head>';
        emailBody += '<body>';
        emailBody += '<div class="container">';
        emailBody += '<div class="header">';
        emailBody += '<img src="https://reva-university--c.documentforce.com/servlet/servlet.ImageServer?id=0155j000001gAjy&oid=00D5j000008ej8d&lastMod=1663064494000" style="width:50%;">';
        emailBody += '</div>';
        emailBody += '<div>';
        emailBody += '<h1>Successful Fee Payment Notification</h1>';
        emailBody += '</div>';
        emailBody += '<div class="confirmation">';
        emailBody += '<h2>Payment Confirmation and Receipt</h2>';
        emailBody += '</div>';
        
        // Greeting for student
        emailBody += '<p>Dear ' + studentFee.Contact__r.Name + ',</p>';
        
        // Other details for student
        emailBody += '<p>We are pleased to inform you that a payment has been successfully received for the hostel accommodation of the following student:</p>';
        emailBody += '<p>Student Name: ' + studentFee.Contact__r.Name + '</p>';
        emailBody += '<p>Class: ' + studentFee.Contact__r.Active_Semester__r.name + '</p>';
        emailBody += '<p>Study Stream: ' + studentFee.Contact__r.Program_Batch__r.name + '</p>';
        emailBody += '<p>Year of Study: ' + studentFee.Contact__r.RH_Current_Pursuing_Year_of_Student__c + '</p>';
        emailBody += '<p>Payment Type: ' + studentFee.Payment_Type__c + '</p>';
        /*emailBody += '<p>Payment Iteration Number: ' + payment.Amount__c + '</p>';
        
        emailBody += '<p>Room Number: ' + hostelRequest.Reva_Hostel_Room__r.Name + '</p>';
        emailBody += '<p>Floor: ' + hostelRequest.Reva_Hostel_Room__r.Floor__c + '</p>';
        emailBody += '<p>Block: ' + hostelRequest.Reva_Hostel_Room__r.Block__c + '</p>';*/
        
        emailBody += '<p>Amount (in numbers): ' + payment.Amount__c + '</p>';
        emailBody += '<p>Amount (in words): ' + amountInWords + '</p>';
        emailBody += '<div class="disclaimer">';
        emailBody += '<p><b>Disclaimer:&nbsp; </b> No need for signature for digital and machine-made receipts.</p>';
        emailBody += '</div>';
        emailBody += '</div>';
        emailBody += '</body>';
        emailBody += '</html>';
        
        return emailBody;
    }
    
    /**parent email template html body ***/
    
    Public static String createEmailBodyForParent(Student_Fee_Payment__c payment, Student_Fee__c studentFee,String parentType) {
        NumberTOWordConvertion numberToWordConverter = new NumberTOWordConvertion();
        String amountInWords = numberToWordConverter.getNumberTOWordConvertion(payment.Amount__c);
        String emailBody = '<html>';
        emailBody += '<head>';
        emailBody += '<style>';
        emailBody += '.container { max-width: 600px; margin: 0 auto; padding: 20px; }';
        emailBody += '.header { text-align: center; padding: 10px; }';
        emailBody += '.confirmation { background-color: #0074b9; color: #fff; padding: 10px; }';
        emailBody += '.disclaimer { font-size: 12px; color: #777; text-align: center; margin-top: 20px; }';
        emailBody += '</style>';
        emailBody += '</head>';
        emailBody += '<body>';
        emailBody += '<div class="container">';
        emailBody += '<div class="header">';
        emailBody += '<img src="https://reva-university--c.documentforce.com/servlet/servlet.ImageServer?id=0155j000001gAjy&oid=00D5j000008ej8d&lastMod=1663064494000" style="width:50%;">';
        emailBody += '</div>';
        emailBody += '<div>';
        emailBody += '<h1>Successful Fee Payment Notification</h1>';
        emailBody += '</div>';
        emailBody += '<div class="confirmation">';
        emailBody += '<h2>Payment Confirmation and Receipt</h2>';
        emailBody += '</div>';
        
        // Greeting for student
        //emailBody += '<p>Dear ' + studentFee.Contact__r.Father__r.Name + ',</p>';
        String greeting = '<p>Dear ';
        if (studentFee.Contact__r.Father__r.Name != null && studentFee.Contact__r.Mother__r.Name != null) {
            greeting += studentFee.Contact__r.Father__r.Name + ' and ' + studentFee.Contact__r.Mother__r.Name;
        } else if (studentFee.Contact__r.Father__r.Name != null) {
            greeting += studentFee.Contact__r.Father__r.Name;
        } else if (studentFee.Contact__r.Mother__r.Name != null) {
            greeting += studentFee.Contact__r.Mother__r.Name;
        } else {
            greeting += 'Parent';
        }
        greeting += ',</p>';
        emailBody += greeting;
        // Other details for student
        emailBody += '<p>We are pleased to inform you that a payment has been successfully received for the hostel accommodation of the following student:</p>';
        emailBody += '<p>Student Name: ' + studentFee.Contact__r.Name + '</p>';
        emailBody += '<p>Class: ' + studentFee.Contact__r.Active_Semester__r.name + '</p>';
        emailBody += '<p>Study Stream: ' + studentFee.Contact__r.Program_Batch__r.name + '</p>';
        emailBody += '<p>Year of Study: ' + studentFee.Contact__r.RH_Current_Pursuing_Year_of_Student__c + '</p>';
        emailBody += '<p>Payment Type: ' + studentFee.Payment_Type__c + '</p>';
       /* emailBody += '<p>Payment Iteration Number: ' + payment.Amount__c + '</p>';
        
        emailBody += '<p>Room Number: ' + hostelRequest.Reva_Hostel_Room__r.Name + '</p>';
        emailBody += '<p>Floor: ' + hostelRequest.Reva_Hostel_Room__r.Floor__c + '</p>';
        emailBody += '<p>Block: ' + hostelRequest.Reva_Hostel_Room__r.Block__c + '</p>';*/
        
        emailBody += '<p>Amount (in numbers): ' + payment.Amount__c + '</p>';
        emailBody += '<p>Amount (in words): ' + amountInWords + '</p>';
        emailBody += '<div class="disclaimer">';
        emailBody += '<p><b>Disclaimer:&nbsp; </b> No need for signature for digital and machine-made receipts.</p>';
        emailBody += '</div>';
        emailBody += '</div>';
        emailBody += '</body>';
        emailBody += '</html>';
        return emailBody;
    }
    
    
    /* private static void sendEmail(Id targetObjectId, Id WhatId, String Email1, Messaging.EmailFileAttachment attachment, String emailBody) {
List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
List<String> mails = new List<String>{Email1};
System.debug(email);
System.debug('Target Object Id: ' + targetObjectId);
system.debug('Email1==>'+Email1);
email.setTargetObjectId(targetObjectId); // Set the recipient's Contact or Lead Id
email.setWhatId(WhatId);
email.setToAddresses(mails); // Use both student and parent emails
email.setHtmlBody(emailBody);
email.setSaveAsActivity(false); // Set to true if you want to log emails as activities
email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
emailMessages.add(email);
System.debug('Email added to messages list');
System.debug('To Addresses: ' + email.getToAddresses());
System.debug('Email Body: ' + email.getHtmlBody());
Messaging.sendEmail( emailMessages);
}*/
    Public static void sendEmail(Id targetObjectId, Id WhatId, String Email1, Messaging.EmailFileAttachment attachment, String emailBody) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> mails = new List<String>{Email1};
            
            System.debug('--- Sending Email Process Start ---');
        System.debug('Email instance: ' + email);
        System.debug('Target Object Id: ' + targetObjectId);
        System.debug('What Id: ' + WhatId);
        System.debug('Email1: ' + Email1);
        
        email.setTargetObjectId(targetObjectId); // Set the recipient's Contact or Lead Id
        email.setWhatId(WhatId);
        email.setToAddresses(mails); // Use both student and parent emails
        email.setHtmlBody(emailBody);
        email.setSaveAsActivity(false); // Set to true if you want to log emails as activities
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
        
        emailMessages.add(email);
        System.debug('Email added to messages list');
        System.debug('To Addresses: ' + email.getToAddresses());
        System.debug('Email Body: ' + email.getHtmlBody());
        System.debug('Email instance2: ' + email);
        try {
            Messaging.sendEmail(emailMessages);
            System.debug('Email sent successfully');
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
        }
        
        System.debug('--- Sending Email Process End ---');
    }
    
    
}