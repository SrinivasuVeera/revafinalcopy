global class ALU_AlumniActivitiesEmailAlert_Batch implements Database.Batchable<SObject>
{
    global Id Alumni_Activities_Event_RecType1;
    global Id Alumni_Activities_Event_RecType2;
    global Id Alumni_Activities_Event_RecType3;
    global Id Alumni_Activities_Event_RecType4;
    global List<Alumni_Activities__c> objListAlumni = new List<Alumni_Activities__c>();
    
    global ALU_AlumniActivitiesEmailAlert_Batch()
    {
        Alumni_Activities_Event_RecType1 = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Achievements').getRecordTypeId();
        Alumni_Activities_Event_RecType2 = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Blogs').getRecordTypeId();
        Alumni_Activities_Event_RecType3 = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Job Posting').getRecordTypeId();
        Alumni_Activities_Event_RecType4 = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Events').getRecordTypeId();
        
        objListAlumni = [SELECT Id, Name, RecordTypeId, Achiever__c, Achievement__c, Blog_Name__c, Event_Name__c, Date__c, Venue__c, Company_Name__c, Designation__c, Experience_Required__c, Referral_ID__c
                         FROM Alumni_Activities__c WHERE Approved_by_Admin__c = true AND Email_Sent__c = false AND
                         (RecordTypeId = :Alumni_Activities_Event_RecType1 OR RecordTypeId = :Alumni_Activities_Event_RecType2 OR 
                          RecordTypeId = :Alumni_Activities_Event_RecType3 OR RecordTypeId = :Alumni_Activities_Event_RecType4)];
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string str_Limit=(Test.isRunningTest()) ? ' Limit 1': '';
        String query = 'SELECT Id, ContactId, Profile.Name, ProfileId, Email FROM User WHERE IsActive = true AND Profile.Name = \'Alumni Portal\'  '+ str_Limit;        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<User> lst_User)
    {
        for (User user : lst_User) 
        {
            for (Alumni_Activities__c record : objListAlumni) 
            {
                String recordTypeId = (String)record.get('RecordTypeId');
                if (recordTypeId == Alumni_Activities_Event_RecType1) 
                {
                    // Customize email content for achievements
                    String emailBody = 'Dear Alumni,\n\n We have a new Achiever!!!\n\n' +
                        'Achiever Name: ' + record.Achiever__c + '\n' +
                        'Achievement: ' + record.Achievement__c + '\n\n' +
                        'For more details, please log in to your Alumni Portal\n' +
                        'Alumni Portal --> Achievements Tab --> All Alumni Achievements\n\n' +
                        'Regards,\nREVA University';
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setOrgWideEmailAddressId([SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='REVA University'].id);
                    mail.setSubject('ALU Alumni Activities Update');
                    mail.setToAddresses(new List<String>{user.Email});
                    mail.setPlainTextBody(emailBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                // Send the email
                else if (recordTypeId == Alumni_Activities_Event_RecType2)
                {
                    // Customize email content for blogs
                    String emailBody = 'Dear Alumni,\n\n A Blog has been posted.\n\n' +
                        'Blogger Name: ' + record.Achiever__c + '\n' +
                        'Blog Name: ' + record.Blog_Name__c + '\n\n' +
                        'For more details, please log in to your Alumni Portal\n' +
                        'Alumni Portal  --> Blogs Tab --> All Blogs\n\n' +
                        'Regards,\nREVA University';
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setOrgWideEmailAddressId([SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='REVA University'].id);
                    mail.setSubject('ALU Alumni Activities Update');
                    mail.setToAddresses(new List<String>{user.Email});
                    mail.setPlainTextBody(emailBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                } 
                else if (recordTypeId == Alumni_Activities_Event_RecType3)
                {
                    // Customize email content for job postings
                    String emailBody = 'Dear Alumni,\n\n We have a new Job reference. Please find the below Details\n\n' +
                        'Company Name: ' + record.Company_Name__c+ '\n' +
                        'Designation: ' + record.Designation__c + '\n' +
                        'Experience Required: ' + record.Experience_Required__c+ '\n' +
                        'Referral ID: ' + record.Referral_ID__c + '\n\n' +
                        'For further details, please log in to your Alumni Portal \n' +
                        'Alumni Portal  --> Job Posting Tab --> Open Jobs\n\n' +
                        'Regards,\nREVA University';
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setOrgWideEmailAddressId([SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='REVA University'].id);
                    mail.setSubject('ALU Alumni Activities Update');
                    mail.setToAddresses(new List<String>{user.Email});
                    mail.setPlainTextBody(emailBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                } 
                else if (recordTypeId == Alumni_Activities_Event_RecType4)
                {
                    // Customize email content for events
                    String emailBody = 'Dear Alumni,\n\n We are excited to announce that there is a new Event which is being organized at REVA University. Please find the below Details\n\n' +
                        'Event Name: ' + record.Event_Name__c + '\n' +
                        'Date: ' +  ((DateTime)record.Date__c).format('dd/MM/yyyy')+ '\n\n' +
                        'Venue: ' + record.Venue__c + '\n\n' +
                        'For more details, please log in to your Alumni Portal\n' +
                        'Alumni Portal  --> Event Registration --> Register '+'('+'button'+')'+'\n\n' +
                        'Regards,\nREVA University';
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setOrgWideEmailAddressId([SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='REVA University'].id);
                    mail.setSubject('ALU Alumni Activities Update');
                    mail.setToAddresses(new List<String>{user.Email});
                    mail.setPlainTextBody(emailBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        List<Alumni_Activities__c> userRecordsToUpdate = new List<Alumni_Activities__c>();
        for (Alumni_Activities__c record : objListAlumni) 
        {
            record.Email_Sent__c = true;
            userRecordsToUpdate.add(record);
        }
        
        update userRecordsToUpdate;
    }
}