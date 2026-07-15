global class WelcomeEmailerToNonEng_Batch implements Database.Batchable<sObject> {
    
    global database.QueryLocator start(Database.BatchableContext bc) {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        return Database.getQueryLocator([
            SELECT Id, Name, Active__c, Quota__c,Ready_to_be_Transitioned__c, School_Name__c, ReportsToId, Personal_Email__c, Father_Email_ID__c, Mother_Email_ID__c, Email, Program_Batch_Name__c, 
                   Program_Batch__r.hed__Start_Date__c, hed__WorkEmail__c, Active_Semester__r.hed__Start_Date__c, Active_Semester__r.Active__c
            FROM Contact 
            WHERE Program_Type__c IN ('Diploma','UG') AND School_Name__c NOT IN ('School of Architecture','School of Legal Studies','School of Computing and Information Technology')
            AND (NOT School_Name__c LIKE '%Engineering%')
            AND Ready_to_be_Transitioned__c = TRUE AND  Program_Batch_Name__c LIKE '%(2025-%' AND (NOT Name LIKE '%test%') AND Quota__c = 'Management Quota'                 
          ]);
    }

    global void execute(Database.BatchableContext bc, List<Contact> conlist) {
    Id ConParentTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    for (Contact con : conlist) {
        List<String> lst_ToEmail = new List<String>();
        List<String> lst_CCEmail = new List<String>();
        Set<Id> set_Reportid = new Set<Id>();
         String imageUrl = 'https://reva-university--revapar.sandbox.my.salesforce.com/servlet/servlet.ImageServer?id=015Bh000001lMMH&oid=00DIp0000000UzX&lastMod=1750936366000';
        string mentor = 'https://reva-university--couat1908.sandbox.my.salesforce.com/servlet/servlet.ImageServer?id=015Il000000XvzI&oid=00D0T0000000qZR&lastMod=1739946723000';
        String textBody = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' +
    '<html><head><META http-equiv="Content-Type" content="text/html; charset=utf-8"></head>' +
    '<body>' +

    // Clickable Image
    
    '<img src="' + imageUrl + '" alt="Image" style="width: 100%; max-width: 800px; height: auto; display: block; margin: 0 auto;">' +
    

    +

    '</body></html>';

        set_Reportid.add(con.id);
        //if (con.hed__WorkEmail__c != null) lst_ToEmail.add(con.hed__WorkEmail__c);
        if (con.Personal_Email__c != null) lst_ToEmail.add(con.Personal_Email__c);
        if(set_Reportid.size()>0)
                {     
                    for(Contact objcon : [Select Id,Name,Email,ReportsToid from contact where ReportsToid in:set_Reportid and RecordTypeId=:ConParentTypeId])
                    {
                        if(objcon.Email != null) lst_CCEmail.add(objcon.Email);                
                    }
                } 
        

        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (!owea.isEmpty()) {
            email.setOrgWideEmailAddressId(owea[0].Id);
        }

        if (!lst_ToEmail.isEmpty()) {
            email.setToAddresses(lst_ToEmail);
        }
         if(lst_CCEmail.size()>0) email.setCCAddresses(lst_CCEmail);

        // Fetch all the files you want to attach
       /* List<ContentVersion> cversions = [SELECT Title, Id, PathOnClient, FileType, VersionData 
                                           FROM ContentVersion 
                                           WHERE Title IN ('PIC', 'Selection Trails date2024')];

        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

        // Loop through the ContentVersion records and add each as an attachment
        for (ContentVersion cversion : cversions) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(cversion.Title + '.' + cversion.FileType); // Set the file name
            attachment.setBody(cversion.VersionData); // Set the file content
            attachments.add(attachment);
        }

        // Attach the files to the email
        if (!attachments.isEmpty()) {
            email.setFileAttachments(attachments);
        } */

        email.setSubject('Induction Orientation- 2025-2026');
        email.setHtmlBody(textBody);
        emails.add(email);
    }
    
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}

    global void finish(Database.BatchableContext bc) {
        // Add any cleanup or final actions here
    }
}