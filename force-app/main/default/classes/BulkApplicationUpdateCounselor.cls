public class BulkApplicationUpdateCounselor implements Database.Batchable<hed__Application__c>, Database.Stateful {
    public List<Id> recordIds;
    public List<hed__Application__c> query =new List<hed__Application__c>();
    public Id newOwnerId;
    List<hed__Application__c> applicationsToUpdate = new List<hed__Application__c>();
    List<Contact> contactsToUpdate = new List<Contact>();

    public BulkApplicationUpdateCounselor(List<Id> recordIds, Id newOwnerId) {
        this.recordIds = recordIds;
        this.newOwnerId = newOwnerId;
    }

    public Iterable<hed__Application__c> start(Database.BatchableContext context) {
        query = [SELECT Id, Name, hed__Applicant__c, ownerid, owner.name FROM hed__Application__c WHERE Id IN :recordIds];
        return query;
    }

    public void execute(Database.BatchableContext context, List<hed__Application__c> scope) {
        List<Account> accountsToUpdate = new List<Account>();
		List<randa__Application_Review__c> applicationReviewsToUpdate = new List<randa__Application_Review__c>();
        Set<Id> appSet = new Set<Id>();
        Set<Id>  conSet = new Set<Id>();
        for (hed__Application__c app : scope) {
            app.OwnerId = newOwnerId;
            applicationsToUpdate.add(app);
            conSet.add(app.hed__applicant__c);
            appSet.add(app.id);
        }
         for(Contact con: [SELECT Id, OwnerId, owner.name, Account.Id, Account.OwnerId FROM Contact WHERE Id IN :conSet]){
            con.OwnerId = newOwnerId;
            contactsToUpdate.add(con);
            Account relatedAccount = con.Account;
            if (relatedAccount != null) {
                relatedAccount.OwnerId = newOwnerId;
                accountsToUpdate.add(relatedAccount);
            }
        }
        for(randa__Application_Review__c ar: [SELECT Id, Name, OwnerId, randa__Application__c, randa__Reviewer__c, randa__Applicant__c, randa__Status__c FROM randa__Application_Review__c where randa__Application__c=: appSet]){
            ar.ownerId = newOwnerId;
            applicationReviewsToUpdate.add(ar);
        }
        if(applicationsToUpdate.size() > 0){
            update applicationsToUpdate;
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
        sendTo.add(usr.Email);
        mail.setToAddresses(sendTo);

        List<String> sendCC = new List<String>();
        sendCC.add('shinil.tp@reva.edu.in'); 
        sendCC.add('kirankumar.jena@reva.edu.in'); 
        sendCC.add('lalkumar.baburao@cloudodyssey.co');
        mail.setCcAddresses(sendCC);
        mail.setSubject('Bulk councellor re-assignment ' + System.now());
        String body='' ;
        
        body = 'Bulk councellor re-assignment status   <br/>';
        body += '<br/> ' + query.size() + ' total number of records processing were completed.';
        body += '<br/> Total list of Success '+contactsToUpdate.size() + '<br/>';
        mail.setHtmlBody(body);
        mails.add(mail);  
        System.debug('mail '+mails);
       
        
        
        
        // To counsellor user
        Messaging.SingleEmailMessage usermail = new Messaging.SingleEmailMessage();   
        List<OrgWideEmailAddress> EmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 
        mail.setOrgWideEmailAddressId(EmailAddress[0].Id);
        user recvuser=[select id, email from user where Id=:newOwnerId];
        List<String> sendToAdd = new List<String>();
        sendToAdd.add(recvuser.Email);
        usermail.setToAddresses(sendToAdd);   
        usermail.setSubject('Bulk Applications are assigned to you ' + System.now());
        String body1='' ;        
        body1 = 'Bulk Applications are assigned to you  <br/>';
        body1 += '<br/> ' + query.size() + ' total number of records assigned.';
        body1 += '<br/> Total list of Success '+contactsToUpdate.size() + '<br/>';
        usermail.setHtmlBody(body1);
        mails.add(usermail);  
        Messaging.sendEmail(mails); 
    }

    public class UpdateOwnerInput {
        @InvocableVariable(required=true)
        public List<Id> recordIds;

        @InvocableVariable(required=true)
        public Id newOwnerId;
    }
}