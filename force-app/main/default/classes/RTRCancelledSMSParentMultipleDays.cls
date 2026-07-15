global class RTRCancelledSMSParentMultipleDays implements Database.Batchable<sObject>, Database.AllowsCallouts{
    	 
public List<String> recordIds;
    
    global RTRCancelledSMSParentMultipleDays(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id,contact__r.Name, contact__r.Father__r.name, Contact__r.RH_Parent_Phone_Number__c, Route_Master__r.Name,Route_Pick_Up_Point__r.Name, Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    global void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c cancelledRequest = [select id, RTR_Descriptions__c,RTR_Start_Date__c,RTR_End_Date__c
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('cancelledRequest-->> '+cancelledRequest);
        
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        
        for(Transport_Registeration__c trReg : scope) {
            String parentName = trReg.contact__r.Father__r.name;
            String phoneNumber = trReg.Contact__r.RH_Parent_Phone_Number__c;
            Date schDate = cancelledRequest.RTR_Start_Date__c;            
            Datetime rtrDateTime = Datetime.newInstance(schDate.year(), schDate.month(), schDate.day());
            String scheduleDate = rtrDateTime.format('dd.MM.yyyy');            
            System.debug('Formatted Schedule Date: ' + scheduleDate); 
            
            Date schendDate = cancelledRequest.RTR_End_Date__c;            
            Datetime rtrEndDateTime = Datetime.newInstance(schendDate.year(), schendDate.month(), schendDate.day());
            String scheduleEndDate = rtrEndDateTime.format('dd.MM.yyyy');            
            System.debug('Formatted Schedule EndDate: ' + scheduleEndDate); 
            
            String reason = cancelledRequest.RTR_Descriptions__c;
            
            String message = 'Dear Mr./Ms.' + parentName +','+ ' This is to inform you that due to '
                + reason +' the University bus will not be operational from '+ scheduleDate  + ' to ' + scheduleEndDate +'for your ward. '+' REVA University';
            
            SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
            if(phoneNumber!=null && message!=null){
            shrtMessage.dltContentId = '1007395005736638583';
            shrtMessage.message = message;
            shrtMessage.recipient = phoneNumber;
            System.debug('receipent -->> '+phoneNumber);
            messageList.add(shrtMessage);
            }
        }
        
        if(messageList.size() > 0) {
            SMS_API_Utility.SendSMSOneToMany('RTR Bus Cancelled Multiple Days Parents', messageList);
        }
        
        
    }
    
    global void finish(Database.BatchableContext context) {
        
    }

}