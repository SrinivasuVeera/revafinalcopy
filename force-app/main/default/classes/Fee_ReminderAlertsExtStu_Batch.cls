global class Fee_ReminderAlertsExtStu_Batch implements Database.Batchable<sObject> 
{
    global database.QueryLocator start(Database.BatchableContext bc) {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        System.debug('Start method executed');
        
        return DataBase.getQueryLocator([
            Select id, Name, Active__c, SRN_Number__c, School_Name__c, Program_Type__c,Program_Batch_Name__c, 
            ReportsToid, Personal_Email__c,hed__WorkEmail__c
            FROM Contact 
            WHERE Student_Status__c = 'Pursuing' 
            AND Program_Type__c != 'Ph.D'
            AND RecordTypeId = :ContactRecTypeId AND (NOT Program_Batch_Name__c LIKE '%-2024)%') AND (Program_Batch_Name__c LIKE '%(2021-%'OR Program_Batch_Name__c LIKE '%(2020-%' OR Program_Batch_Name__c LIKE '%(2019-%')
        ]);
    }
    
    global void execute(Database.BatchableContext Bc, List<Contact> lstCon) {           
        for(Contact con : lstCon) {
            Id ConParentTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
            List<String> lst_ToEmail = new List<String>();
            set<id> set_Reportid = new set<id>();
            list<string> lst_CCEmail = new list<string>();
            List<Messaging.SingleEmailMessage> lst_Email = new List<Messaging.SingleEmailMessage>();
            // String programBatchName = con.Program_Batch_Name__c;
            
            String imageUrl = 'https://reva-university.my.salesforce.com/servlet/servlet.ImageServer?id=015J4000001T3pP&oid=00D5j000008ej8d&lastMod=1721035318000';
            String facebookImageUrl = 'https://reva-university.my.salesforce.com/servlet/servlet.ImageServer?id=015J4000001T3tC&oid=00D5j000008ej8d&lastMod=1721035433000';
            String whatsappImageUrl = 'https://reva-university.my.salesforce.com/servlet/servlet.ImageServer?id=015J4000001T3IS&oid=00D5j000008ej8d&lastMod=1721035383000';
            String twitterImageUrl = 'https://reva-university.my.salesforce.com/servlet/servlet.ImageServer?id=015J4000001T3jX&oid=00D5j000008ej8d&lastMod=1721035477000';
            String instagramImageUrl = 'https://reva-university.my.salesforce.com/servlet/servlet.ImageServer?id=015J4000001T3y7&oid=00D5j000008ej8d&lastMod=1721035551000';
            String youtubeImageUrl = 'https://reva-university.my.salesforce.com/servlet/servlet.ImageServer?id=015J4000001T395&oid=00D5j000008ej8d&lastMod=1721035612000';
            
            // Email body with image and social media icons
            String textBody = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' +
                '<html><head><META http-equiv="Content-Type" content="text/html; charset=utf-8"></head>' +
                '<body>' +
                '<img src="' + imageUrl + '" alt="REVA University" style="width: 100%; max-width: 800px; height: auto; display: block; margin: 0 auto;">' +
                '<div style="text-align: center; margin-top: 20px;">' +
                '<a href="https://www.reva.edu.in/student-housing" style="color: #fff; background-color: #f57f26; padding: 10px 20px; text-decoration: none; border-radius: 10px; display: inline-block;">Book now</a>' +
                '</div>' +
                '<div style="text-align: center; margin-top: 20px;">' +
                '<a href="https://whatsapp.com/channel/0029Va9WGa5BFLgWBTXcqh0W">' +
                '<img src="' + whatsappImageUrl + '" alt="WhatsApp" style="width: 15px; height: 15px; padding: 2px 2px;">' +
                '</a>' +
                '<a href="https://www.facebook.com/REVAUniversityofficial">' +
                '<img src="' + facebookImageUrl + '" alt="Facebook" style="width: 15px; height: 15px; padding: 2px 2px;">' +
                '</a>' +
                '<a href="https://www.twitter.com/REVAuniversity">' +
                '<img src="' + twitterImageUrl + '" alt="Twitter" style="width: 15px; height: 15px; padding: 2px 2px;">' +
                '</a>' +
                '<a href="https://www.instagram.com/revauniversity_official">' +
                '<img src="' + instagramImageUrl + '" alt="Instagram" style="width: 15px; height: 15px; padding: 2px 2px;">' +
                '</a>' +
                '<a href="https://www.youtube.com/@revauniversity_official">' +
                '<img src="' + youtubeImageUrl + '" alt="YouTube" style="width: 15px; height: 15px; padding: 2px;">' +
                '</a>' +
                '<span style="vertical-align: top; display: inline-block; line-height: 16px; margin-left: 0px;">/REVAUniversity</span>' +
                '</div>' +
                '<div style="text-align: center; margin-top: 10px;">' +
                '<a href="https://www.reva.edu.in" style="color: #000; text-decoration: none;">reva.edu.in</a>' +
                '</div>' +
                '</body></html>';
            
            if(con.hed__WorkEmail__c != null) lst_ToEmail.add(con.hed__WorkEmail__c);
            if(con.Personal_Email__c != null) lst_CCEmail.add(con.Personal_Email__c);
            set_Reportid.add(con.id);
            if(set_Reportid.size()>0)
            {     
                for(Contact objcon : [Select Id,Name,Email,ReportsToid from contact where ReportsToid in:set_Reportid and RecordTypeId=:ConParentTypeId])
                {
                    if(objcon.Email != null) lst_CCEmail.add(objcon.Email);                
                }
            }
            OrgWideEmailAddress[] owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            
            if(lst_ToEmail.size() > 0) email.setToAddresses(lst_ToEmail);                    
            if(lst_CCEmail.size()>0) email.setCCAddresses(lst_CCEmail);
            
            email.setSubject('REVA University! Book your Reservation at REVA Hostel'); 
            email.setHtmlBody(textBody);
            lst_Email.add(email);
            if(lst_Email.size() > 0 && lst_ToEmail.size() > 0) {
                Messaging.sendEmail(lst_Email);
            }
        }
    }
   
    global void finish(DataBase.BatchableContext bc)
    {
        //BatchClass_Utility.sendBatchClassFailureMail('Fee Module', bc.getJobId(), 'Fee Due Date','Student Fees');
    }
}