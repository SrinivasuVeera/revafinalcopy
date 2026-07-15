global class SSP_ANNOUNCEMENT_BATCH implements Database.Batchable<sObject> {
    
    global database.QueryLocator start(Database.BatchableContext bc) {
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        return Database.getQueryLocator([
            SELECT Id, Quota__c, Name, Student_Status__c, RecordTypeId, Email, hed__WorkEmail__c, Program_Type__c
            FROM Contact 
            WHERE Student_Status__c = 'Pursuing' AND RecordTypeId = :contactRecTypeId AND Program_Type__c IN ('UG', 'PG') 
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> lstCon) {
        List<Messaging.SingleEmailMessage> lst_Email = new List<Messaging.SingleEmailMessage>();
        
        // Fetch the PDF content
        Blob pdfBlob;
        String pdfDocumentName = 'Invitation for RCL 2024 Grand Opening';
        
        List<Document> pdfDocuments = [SELECT Id, Name, Body FROM Document WHERE Name = :pdfDocumentName LIMIT 1];
        
        
        if (pdfDocuments.size() > 0 && pdfDocuments[0].Body != null) {
            // Convert the Blob content to base64
            pdfBlob = pdfDocuments[0].Body;
            
            for (Contact con : lstCon) {
                List<String> lst_ToEmail = new List<String>();
                
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Invitation_for_RCL_2024_Grand_Opening.pdf');
                attachment.setBody(pdfBlob);
                attachment.setContentType('application/pdf');
                system.debug('contactlist==='+lstCon);
                 System.debug('filename === ' + attachment.getFileName());
                
                String textBody = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><META http-equiv="Content-Type" content="text/html; charset=utf-8"></head><body>' +
                    'Dear Esteemed Members of the REVA University,' +
                    '<p>We are delighted to extend an invitation to the distinguished members of the REVA University for the <b>4th Edition of the REVA Cricket League (RCL) 2024</b>. This prestigious event is scheduled to unfold at the REVA University Grounds on the 20th of January.' +
                    '<p>Featuring <b>"The Hundred," Karnataka\'s first 100-Ball Cricket Tournament, RCL 2024</b> promises an exhilarating display of sportsmanship, teamwork, and corporate camaraderie.'+
                    '<p><b>Event Details:</b>'+'<br>'+'Date: 20th January 2024'+'<br>'+'Time: 7:00 AM Onwards'+'<br>'+'Venue: REVA University Grounds'+
                    '<p>We look forward to <b>your active presence at the event</b> and <b>inspiring the 20 corporate teams</b> that have enthusiastically participated in the tournament. The RCL has become a <b>symbol of excellence</b> in corporate sports, and your attendance would not only honour the event but also inspire the participants.'+
                    '<p>Parallel league matches will be run in both REVA and Pendleton grounds. Please find the invite and details of RCL fixtures to know the overall matches and schedules.'+
                    '<p>We look forward to your gracious presence.'+'<br>'+'Thank you for your time and consideration.'+
                    '<p><b>About RACE:</b> REVA Academy for Corporate Excellence (RACE) is an initiative of ' +
                        '<a href="https://www.reva.edu.in" ' +
                        'style="color:blue;margin-top:0pt;margin-bottom:0pt;text-align:center;">REVA University</a>' +
                        ', which offers a range of specialized, techno-functional programs custom-designed to suit the needs of working professionals to enhance their careers. Each program is planned, designed, and delivered by highly renowned corporate trainers and industry leaders with years of experience. Our programs follow a blended learning model with flexible contact classes and a robust online learning management system with 24/7 support.  Our current focus areas are Analytics, Cybersecurity, Artificial Intelligence and Cloud Architecture and Security. Our cohorts have a minimum of 4 years and 25 years of work experience and come from 100-plus marquee organizations. Please find more details on RACE programs ' +
                        '<a href="https://race.reva.edu.in" ' +
                        'style="color:blue;margin-top:0pt;margin-bottom:0pt;text-align:center;">here</a>.' +
                        '</body></html>';

                if (con.hed__WorkEmail__c != null) {
                    system.debug('emails==='+con.hed__WorkEmail__c);
                    lst_ToEmail.add(con.hed__WorkEmail__c);
                }
                            if (lst_ToEmail.isEmpty()) {

                System.debug('No recipient email address found for contact: ' + con.Name);
                continue; 
            }
                            
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                OrgWideEmailAddress[] owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea[0].Id);
                }
                
                if (lst_ToEmail.size() > 0) {
                    email.setToAddresses(lst_ToEmail);
                }
                
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                email.setSubject('Invitation to the REVA Cricket League 2024 - Opening Matches');
                email.setHtmlBody(textBody);
               
                lst_Email.add(email);
            }
        } else {
            // Handle the case where the Document is not found or doesn't have content
        }
        
        // Send the emails
        if (lst_Email.size() > 0) {
            Messaging.sendEmail(lst_Email);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Perform any cleanup or additional actions after the batch processing is complete
    }
}