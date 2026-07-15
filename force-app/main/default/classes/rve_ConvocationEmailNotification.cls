global class rve_ConvocationEmailNotification implements Database.Batchable<sObject>, Database.AllowsCallouts {
List<List<Contact>> contactIds;
    
     // Constructor to accept contactIds parameter
    global rve_ConvocationEmailNotification(List<List<Contact>> contactIds) {
        this.contactIds = contactIds;
        system.debug(this.contactIds);
    }

    // Query to retrieve Contact records
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([SELECT Id, Name,SRN_Number__c, Personal_Email__c, Program_Batch__r.rve_Convocation_Date_Time__c, Program_Batch__r.rve_Convocation_Time__c FROM Contact WHERE Id IN :contactIds[0]]);
    }

    // Process each batch of Contact records
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Contact con : scope) {
            // Generate PDF content
            PageReference pageRef = Page.Convocation_QR_Code;
            pageRef.getParameters().put('id', con.Id); // Pass Contact Id to the Visualforce page
            Blob pdfContent;
            if(!Test.isRunningTest()){
            try {
                pdfContent = pageRef.getContentAsPDF();
            } catch (VisualforceException e) {
                // Handle error
                System.debug('Error generating PDF content for contact ' + con.Id + ': ' + e.getMessage());
                continue; // Skip to the next contact
            }
                }
            else{
                pdfContent = Blob.valueOf('Test PDF Content'); // Placeholder content for test context
            }
            
            // Create email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Convocation QR Code');
            email.setToAddresses(new List<String>{con.Personal_Email__c});
            String convocationDate = con.Program_Batch__r.rve_Convocation_Date_Time__c.date().format();
            // Attach PDF to email
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('QR_Code_' + con.SRN_Number__c + '.pdf');
            attachment.setBody(pdfContent);
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
            email.setHtmlBody('Dear ' + con.Name + ',<br><br>'
    + 'Greetings from REVA University!<br><br>'
    + 'We proudly invite you to the 9th Annual Convocation Ceremony of REVA University that will be held on ' + convocationDate + '.<br><br>'
    + 'The Convocation ceremony begins at '+con.Program_Batch__r.rve_Convocation_Time__c+' and will be held at Saugandhika, REVA University.<br><br>'
    + 'We are attaching a programme schedule.<br><br>'
    + 'As you prepare to embark on the next chapter of your life, your presence would add immense joy to the convocation celebration.<br><br>'
    + 'Every year we have a wonderful turnout on the occasion. It would be delightful to have you and your family for the convocation this year. It is a time for us to congratulate you and celebrate your success.<br><br>'
    + 'Let\'s commemorate this milestone together and create lasting memories. We look forward to celebrating with you.<br><br>'
    + 'If you could please return the RSVP by filling on below form, it would be much appreciated. We look forward to your attendance at the Convocation Ceremony.<br><br>'
    + '<p style="text-align: center;">'
    + '<span>'
    +'   <a href="https://reva-university--codev1.sandbox.my.site.com/StudentPortal/survey/runtimeApp.app?invitationId=0Ki1e0000000pDS&surveyName=survey_for_convecation&UUID=26c8c8af-150c-41de-92ee-95a1c0e31012"'
    +'        style="color: white; background-color: #0070D2; border: 1px solid #0070D2; border-radius: 4px; padding: 10px 20px; text-decoration: none; display: inline-block;"'
    +'        target="_blank">'
    +'        Open RSVP'
    +'    </a>'
    +'</span>'
+'</p>'
    + 'Warm regards<br><br>'
    + 'Registrar<br><br>'
    + 'REVA University<br><br>'
    + 'Rukmini Knowledge Park | Kattigenahalli |<br><br>'
    + 'Yelahanka | Bengaluru | Karnataka 560 064');


            // Add email to list
            emails.add(email);
        }
        
        // Send emails
        Messaging.sendEmail(emails);
    }

    // Finish method (optional)
    global void finish(Database.BatchableContext BC) {
        // Optionally implement any post-processing logic
    }
}