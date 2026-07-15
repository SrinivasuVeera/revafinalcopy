public class QueueableSendApplicationNumberSMS  implements System.Queueable , Database.AllowsCallouts {
    Public Static final String SMS_TYPE = 'Application_Number';
    
    List<contact> conRecords;
    set<Id> batchContactIds = new set<Id>();
   
    public QueueableSendApplicationNumberSMS (list<contact> conRecords){
        this.conRecords = conRecords;
        for(contact c : conRecords){
            batchContactIds.add(c.id);
        }
    } 
    
    public void execute(QueueableContext context){
        QueueableSendApplicationNumberSMS.sendApplicationNumber(conRecords);
        Appl_ContactTriggerHandler.createApplicantUser(batchContactIds);
    }
    
    
    public static void sendApplicationNumber(list<contact> conRecords){
        for(contact contact : conRecords){
            if( contact.Application_Fee_Paid__C == true && contact.Record_Type_Name__c == 'Applicant'){
                
                string mobile = contact.MobilePhone;
                mobile = mobile.remove('+91-');
                
                List<String> requiredVariables =  new List<String>();
                if(contact.Country_Code__c == 'India (+91)'){
                    requiredVariables.add(contact.Application_Number__C);
                    RegistrationFormUtility.futureSMS(SMS_TYPE, mobile, requiredVariables); 
                }
            }
        }
        
    }
    
   
}