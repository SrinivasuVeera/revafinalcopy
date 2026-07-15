public without sharing class VacationRequestController {
    
    @AuraEnabled
    public static String updateVacationRequest(Date vacateDate,  Id staffQuartersRequestId, string selectedVacateReason) {
        System.debug('vacateDate**********'+vacateDate);
        try {
            Staff_Quarters_Request__c requestToUpdate = new Staff_Quarters_Request__c();
            requestToUpdate = [SELECT id, Name, Vacation_Date__c, Vacation_Initiated_Date__c, Status__c FROM Staff_Quarters_Request__c WHERE id =: staffQuartersRequestId LIMIT 1];
            requestToUpdate.Vacation_Initiated_Date__c = Date.today();
            requestToUpdate.Vacation_Date__c = vacateDate;
            requestToUpdate.Status__c = 'Vacation Initiated';
            requestToUpdate.Cancellation_Reason__c = selectedVacateReason;
            update requestToUpdate; 
            
            return 'Success';
        } catch (Exception ex) {
            return 'Error: ' + ex.getMessage();
        }
    }
    
    @AuraEnabled
    //Confirmation mail sending to Teaching and non-teaching profile users
    public static string sendConfirmationEmail(String userId){
        
        User recipient = [SELECT Email FROM User where id =:userId LIMIT 1];
        
        EmailTemplate emailTemplate = [SELECT Id,Subject FROM EmailTemplate WHERE DeveloperName = 'Vacation_Approval' LIMIT 1];
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{recipient.Email});
        email.setTemplateId(emailTemplate.Id);
        email.setSubject(emailTemplate.Subject);
        
        //  email.setTargetObjectId(recipientId);
        email.setSaveAsActivity(false);
        email.setPlainTextBody('Vacation request for has been approved.');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        return 'successful';
    }
}