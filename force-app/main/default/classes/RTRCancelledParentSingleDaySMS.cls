global class RTRCancelledParentSingleDaySMS implements Database.Batchable<sObject>, Database.AllowsCallouts{
    	 
public List<String> recordIds;
    
    global RTRCancelledParentSingleDaySMS(List<String> recordIds) {
        this.recordIds = recordIds;
    }
     
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id,contact__r.Name, contact__r.Father__r.name, Contact__r.RH_Parent_Phone_Number__c, Route_Master__r.Name ,Route_Pick_Up_Point__r.Name, Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    global void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c cancelledRequest = [select id, RTR_Descriptions__c, RTR_Date__c
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('earlyPickRequest-->> '+cancelledRequest);
        
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
      
        for(Transport_Registeration__c trReg : scope) {
           
            String parentName = trReg.contact__r.Father__r.name;
            String phoneNumber = trReg.Contact__r.RH_Parent_Phone_Number__c;
            Date schDate = cancelledRequest.RTR_Date__c;            
            Datetime rtrDateTime = Datetime.newInstance(schDate.year(), schDate.month(), schDate.day());
            String scheduleDate = rtrDateTime.format('dd.MM.yyyy');            
            System.debug('Formatted Schedule Date: ' + scheduleDate); 
            
            String reason = cancelledRequest.RTR_Descriptions__c;
            
            String message = 'Dear Mr./Ms. ' + parentName + ',' + ' This is to inform you that due to '
                + reason + ' the University bus will not be operational on '+ scheduleDate  + ' for your ward. '+' REVA University';
            
            SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
            if(phoneNumber!=null && message!=null){
            shrtMessage.dltContentId = '1007892956175942835';
            shrtMessage.message = message;
            shrtMessage.recipient = phoneNumber;
            System.debug('receipent -->> '+phoneNumber);
            messageList.add(shrtMessage);
            }
        }
        
        if(messageList.size() > 0) {
            SMS_API_Utility.SendSMSOneToMany('RTRCancelledParentSingleDay', messageList);
        }
        
        
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}