public class BulkLeadUpdateCounselor implements Database.Batchable<Lead>, Database.Stateful {
    public List<Id> recordIds;
    public List<Lead> query =new List<Lead>();
    public Id newOwnerId;
    List<Lead> leadsToUpdate = new List<Lead>();
     public string OwnerName;
     public string OwnerMailId;
     public string AddtionalMailId;
    String dataTable = '<table border="1"><tr><th> Name </th><th> Application Number </th><th> Previous Owner </th><th> Re-assigned Owner </th><th> Re-assigned By </th><th> Re-Assigned Date</th></tr>';

    public BulkLeadUpdateCounselor(List<Id> recordIds, Id newOwnerId) {
        this.recordIds = recordIds;
        this.newOwnerId = newOwnerId;
    }

    public Iterable<Lead> start(Database.BatchableContext context) {
        query = [SELECT Id, LastName, FirstName, Name,Application_Number__c, Check_OwnerChnage__c,MobilePhone, Email, ownerid,owner.name FROM Lead WHERE Id IN :recordIds];
        return query;
    }

    public void execute(Database.BatchableContext context, List<Lead> scope) {
        user ur=[select id, Name,Email from user where id = : newOwnerId];
        String currentUserName = UserInfo.getName();
         User adtinal=[select id, Name, email from User where Profile.Name='Additional Registrar' and IsActive = true ];
        AddtionalMailId = adtinal.Email;
        for (Lead lead : scope) {
            lead.OwnerId = newOwnerId;
            lead.Check_OwnerChnage__c=true;
            OwnerName= ur.Name;
            OwnerMailId=ur.Email;
            leadsToUpdate.add(lead);
            
            dataTable += '<tr>';
            dataTable += '<td>' + lead.Name + '</td>';
            dataTable += '<td>' + lead.Application_Number__c + '</td>';
            dataTable += '<td>' + lead.Owner.Name + '</td>';
            dataTable += '<td>' + ur.Name + '</td>'; 
            dataTable += '<td>' + currentUserName + '</td>'; 
            dataTable += '<td>' + system.now() + '</td>';

        }
        if(leadsToUpdate.size() > 0){
            update leadsToUpdate;
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
       
         SendCC.add(AddtionalMailId);
      
        mail.setCcAddresses(sendCC);
        mail.setSubject('Bulk councellor re-assignment ' + System.now());
        String body='' ;
        
        body = 'Dear '+ OwnerName +', <br/>';
        body += '<br/> I hope this message finds you well. I wanted to inform you that the following leads have been re-assigned to you for further handling:<br/>' ; 
        body +=  '<br/>'+ dataTable + '<br/>';
        body += '<br/> Please proceed with the necessary procedures for each lead and ensure appropriate follow-up.<br/>';        
        body += '<br/> Thank you for your attention to this matter.<br/><br/>Best regards,<br/>REVA University <br/><br/>';
        mail.setHtmlBody(body);
        mails.add(mail);  
        System.debug('mail '+mails);
        
        
      /*  Messaging.SingleEmailMessage usermail = new Messaging.SingleEmailMessage();   
        List<OrgWideEmailAddress> EmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 
        mail.setOrgWideEmailAddressId(EmailAddress[0].Id);
        user recvuser=[select id, email from user where Id=:newOwnerId];
        List<String> sendToAdd = new List<String>();
        sendToAdd.add('');
        usermail.setToAddresses(sendToAdd);   
        usermail.setSubject('Bulk leads are assigned to you ' + System.now());
        String body1='' ; 
        body1 = 'Dear heloo'+ OwnerName +', <br/>';
        body1 += '<br/> I hope this message finds you well. I wanted to inform you that the following leads have been re-assigned to you for further handling:<br/>' ;
        body1 +=  '<br/>'+ dataTable + '<br/>';
        body1 += '<br/> Please proceed with the necessary procedures for each lead and ensure appropriate follow-up.<br/>';
        body1 += '<br/> Thank you for your attention to this matter.<br/><br/>Best regards,<br/>REVA University<br/>';
      
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