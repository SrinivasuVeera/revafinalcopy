public class BulkContactUpdateCounselor implements Database.Batchable<Contact>, Database.Stateful {
    public List<Id> recordIds;
    public List<Contact> query =new List<Contact>();
    public Id newOwnerId;
    List<Contact> contactsToUpdate = new List<Contact>();
    public string OwnerName;
     public string OwnerMailId;
     public string AddtionalMailId;
     String dataTable = '<table border="1"><tr><th> Name </th><th> Application Number </th><th> Previous Owner </th><th> Re-assigned Owner </th><th> Re-assigned By </th><th> Re-Assigned Date</th></tr>';
    List<Id> contactIds = new List<Id>();
    public BulkContactUpdateCounselor(List<Id> recordIds, Id newOwnerId) {
        this.recordIds = recordIds;
        this.newOwnerId = newOwnerId;
    }

    public Iterable<Contact > start(Database.BatchableContext context) {
        query = [SELECT Id, OwnerId, owner.name, Account.Id, Account.OwnerId FROM Contact WHERE Id IN :recordIds];
        return query;
    }

    public void execute(Database.BatchableContext context, List<Contact> scope) {
 
        List<Account> accountsToUpdate = new List<Account>();
        List<hed__Application__c> ApplicantsToUpdate = new List<hed__Application__c>();
		List<randa__Application_Review__c> applicationReviewsToUpdate = new List<randa__Application_Review__c>();
        
        Set<Id> appSet = new Set<Id>();
        user ur=[select id, Name,Email from user where id = : newOwnerId];
        User adtinal=[select id, Name, email from User where Profile.Name='Additional Registrar' and IsActive = true ];
        AddtionalMailId = adtinal.Email;
        system.debug('Mail Additional'+ AddtionalMailId);
        String currentUserName = UserInfo.getName();
        List<String> Datarow = new List<String>();
        Set<Id>  conSet = new Set<Id>();
        for (Contact contact : scope) {
            contactIds.add(contact.Id);
            contact.OwnerId = newOwnerId;
            contact.Check_OwnerChnage__c= true;
            contactsToUpdate.add(contact);
            conSet.add(contact.id);
            Account relatedAccount = contact.Account;
            if (relatedAccount != null) {
                relatedAccount.OwnerId = newOwnerId;
                accountsToUpdate.add(relatedAccount);
            }
        }
        for(hed__Application__c app: [SELECT Id, Name,Application_Number__c,hed__Applicant__c,hed__Applicant__r.Name,hed__Applicant__r.Owner.Name FROM hed__Application__c where hed__applicant__c =: conSet]){
            
            app.ownerId = newOwnerId;
            ApplicantsToUpdate.add(app);
            OwnerName= ur.Name;
            OwnerMailId=ur.Email;
            dataTable += '<tr>';
            dataTable += '<td>' + app.hed__Applicant__r.Name + '</td>';
            dataTable += '<td>' + app.Application_Number__c + '</td>';
            dataTable += '<td>' + app.hed__Applicant__r.Owner.Name + '</td>';
            dataTable += '<td>' + ur.Name + '</td>'; 
            dataTable += '<td>' + currentUserName + '</td>'; 
            dataTable += '<td>' + system.now() + '</td>';
        }
         dataTable += '</table>';
        
        for(randa__Application_Review__c ar: [SELECT Id, Name, OwnerId, randa__Application__c, randa__Reviewer__c, randa__Applicant__c, randa__Status__c FROM randa__Application_Review__c where randa__Application__c=: appSet]){
            ar.ownerId = newOwnerId;
            applicationReviewsToUpdate.add(ar);
        }
        
         if(ApplicantsToUpdate.size() > 0){
          update ApplicantsToUpdate;
        }
        if(contactsToUpdate.size() > 0){
            update contactsToUpdate;
        }
        if(accountsToUpdate.size() > 0){
            update accountsToUpdate;
        }
        if(applicationReviewsToUpdate.size() > 0){
            update applicationReviewsToUpdate;
        }
        
    }

    public void finish(Database.BatchableContext context) {
        
        // Optional: Any post-processing logic here
        System.debug('batch apex has been finished');
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
        List<OrgWideEmailAddress> lstEmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 
        mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
        User usr =[select Id,Name,Email from User where Id =:userinfo.getUserId()];
        List<String> sendTo = new List<String>();
        sendTo.add(OwnerMailId);
        mail.setToAddresses(sendTo);

        List<String> sendCC = new List<String>();
        //sendCC.add('shinil.tp@reva.edu.in'); 
        //sendCC.add('kirankumar.jena@reva.edu.in'); 
       
          sendCC.add(AddtionalMailId);
       
        mail.setCcAddresses(sendCC);
        mail.setSubject('Bulk councellor re-assignment ' + System.now());
        String body='' ;
        
        body = 'Dear '+ OwnerName +', <br/>';
        body += '<br/> I hope this message finds you well. I wanted to inform you that the following leads have been re-assigned to you for further handling:<br/>' ;
        body +=  '<br/>'+ dataTable + '<br/>';
        body += '<br/> Please proceed with the necessary procedures for each lead and ensure appropriate follow-up.<br/>';
        body += '<br/> Thank you for your attention to this matter.<br/><br/>Best regards,<br/>REVA University';
        mail.setHtmlBody(body);
        mails.add(mail);  
        System.debug('mail '+mails);
        
        

       // To councellor     
    /*    Messaging.SingleEmailMessage usermail = new Messaging.SingleEmailMessage();   
        List<OrgWideEmailAddress> EmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 
        mail.setOrgWideEmailAddressId(EmailAddress[0].Id);
        user recvuser=[select id, email from user where Id=:newOwnerId];
        List<String> sendToAdd = new List<String>();
        sendToAdd.add(recvuser.Email);
        usermail.setToAddresses(sendToAdd);   
        usermail.setSubject('Bulk Contacts are assigned to you  ' + System.now());
        String body1='' ;        
        body1 = 'Bulk Contacts are assigned to you  <br/>';
        body1 += '<br/> ' + query.size() + ' total number of records assigned.';
        body1 += '<br/> Total list of Success '+contactsToUpdate.size() + '<br/>';
        usermail.setHtmlBody(body1);
        //mails.add(usermail);  */
        Messaging.sendEmail(mails); 
      
    }

    public class UpdateOwnerInput {
        @InvocableVariable(required=true)
        public List<Id> recordIds;

        @InvocableVariable(required=true)
        public Id newOwnerId;
    }
}