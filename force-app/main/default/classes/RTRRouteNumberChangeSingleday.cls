global class RTRRouteNumberChangeSingleday implements Database.Batchable<sObject>, Database.AllowsCallouts{
    	 
public List<String> recordIds;
    
    global RTRRouteNumberChangeSingleday(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id,contact__r.Name, Route_Master__r.Name, Contact__r.MobilePhone,Route_Pick_Up_Point__r.Name, Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    global void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c routeChangeRequest = [select id, RTR_Descriptions__c,RTR_Date__c,RTR_Routes__r.Name,RTR_New_Number__r.Name
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('routeChangeRequest-->> '+routeChangeRequest);
        
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        
        for(Transport_Registeration__c trReg : scope) {
            if(trReg.Route_Master__r.Name == routeChangeRequest.RTR_Routes__r.Name){
            String stuName = trReg.contact__r.Name;
            String phoneNumber = trReg.Contact__r.MobilePhone;
            Date schDate = routeChangeRequest.RTR_Date__c;            
            Datetime rtrDateTime = Datetime.newInstance(schDate.year(), schDate.month(), schDate.day());
            String scheduleDate = rtrDateTime.format('dd/MM/yyyy');            
            System.debug('Formatted Schedule Date: ' + scheduleDate); 
                        
            //String reason = routeChangeRequest.RTR_Descriptions__c;
            
            String newRouteNumber = routeChangeRequest.RTR_New_Number__r.Name;
            String routeNumber = routeChangeRequest.RTR_Routes__r.Name;
            
            String message = 'Dear ' + stuName +','+ ' This is to inform you that the route number '
                + routeNumber + ' bus is cancelled on '+ scheduleDate  + ', ' + 'you can take route number  '+ newRouteNumber +' instead. '+' REVA University';
            
            SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
            if(phoneNumber!=null && message!=null){
            shrtMessage.dltContentId = '1007083624798832011';
            shrtMessage.message = message;
            shrtMessage.recipient = phoneNumber;
            System.debug('receipent -->> '+phoneNumber);
            messageList.add(shrtMessage);
            }
        }
        }
        if(messageList.size() > 0) {
            SMS_API_Utility.SendSMSOneToMany('RTR Route Number Change Single day', messageList);
        }
        
        
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}