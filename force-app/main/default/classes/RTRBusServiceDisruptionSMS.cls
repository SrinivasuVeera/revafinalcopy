global class RTRBusServiceDisruptionSMS implements Database.Batchable<sObject>, Database.AllowsCallouts{
    	 
public List<String> recordIds;
    
    global RTRBusServiceDisruptionSMS(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id,contact__r.Name, Route_Master__r.Name, Contact__r.MobilePhone,Route_Pick_Up_Point__r.Name, Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    global void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c routeChangeRequest = [select id,RTR_Routes__r.Name,Registration_Number__c
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('routeChangeRequest-->> '+routeChangeRequest);
        
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        
        for(Transport_Registeration__c trReg : scope) {
            if(trReg.Route_Master__r.Name == routeChangeRequest.RTR_Routes__r.Name){
            String stuName = trReg.contact__r.Name;
            String phoneNumber = trReg.Contact__r.MobilePhone;
            String routeNumber = routeChangeRequest.RTR_Routes__r.Name;
            String regNumber = routeChangeRequest.Registration_Number__c;
            String message = 'Dear ' + stuName +','+ ' Bus Number '
                + routeNumber + ' is down today due to a mechanical issue. '+ 'Please use an alternate REVA bus  '+ regNumber + '.' +' REVA University';
            
            SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
            if(phoneNumber!=null && message!=null){
            shrtMessage.dltContentId = '1007375886464633781';
            shrtMessage.message = message;
            shrtMessage.recipient = phoneNumber;
            System.debug('receipent -->> '+phoneNumber);
            messageList.add(shrtMessage);
            }
        }
        }
        if(messageList.size() > 0) {
            SMS_API_Utility.SendSMSOneToMany('RTR Bus Service Disruption', messageList);
        }
        
        
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}