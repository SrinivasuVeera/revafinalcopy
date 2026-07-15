global class RTRChangeOfRouteMultipleDaysVia implements Database.Batchable<sObject>, Database.AllowsCallouts{
    	 
public List<String> recordIds;
    
    global RTRChangeOfRouteMultipleDaysVia(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id,contact__r.Name, Route_Master__r.Name, Contact__r.MobilePhone,Route_Pick_Up_Point__r.Name, Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    global void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c routeChangeRequestviaMultiple = [select id, RTR_Descriptions__c, RTR_Start_Date__c,  RTR_End_Date__c, Via__r.Name, RTR_Routes__r.Name,RTR_Pick_Up_Point__r.Name
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('routeChangeRequestviaMultiple-->> '+routeChangeRequestviaMultiple);
        
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        
        for(Transport_Registeration__c trReg : scope) {
            if(trReg.Route_Master__r.Name == routeChangeRequestviaMultiple.RTR_Routes__r.Name){
            String stuName = trReg.contact__r.Name;
            String phoneNumber = trReg.Contact__r.MobilePhone;
            Date schStartDate = routeChangeRequestviaMultiple.RTR_Start_Date__c;            
            Datetime rtrDateTime = Datetime.newInstance(schStartDate.year(), schStartDate.month(), schStartDate.day());
            String strtDate = rtrDateTime.format('dd/MM/yyyy');            
            System.debug('Formatted Schedule Date: ' + strtDate); 
            
            Date schEndDate = routeChangeRequestviaMultiple.RTR_End_Date__c;            
            Datetime rtrendDateTime = Datetime.newInstance(schEndDate.year(), schEndDate.month(), schEndDate.day());
            String endDate = rtrendDateTime.format('dd/MM/yyyy');            
            System.debug('Formatted Schedule Date: ' + endDate); 
                             
            String reason = routeChangeRequestviaMultiple.RTR_Descriptions__c;            
            String pickupPoint = routeChangeRequestviaMultiple.RTR_Pick_Up_Point__r.Name;
            String routeNumber = routeChangeRequestviaMultiple.RTR_Routes__r.Name;
            String viapickupPoint = routeChangeRequestviaMultiple.Via__r.Name;
            
            String message = 'Dear ' + stuName +','+ ' This is to inform you that the route number '
                + routeNumber + ' bus will reach '+ pickupPoint  + ' via '+ viapickupPoint + ' from ' + strtDate + ' to ' +  endDate + '. '+' REVA University';
            
            SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
            if(phoneNumber!=null && message!=null){
            shrtMessage.dltContentId = '1007938366159226216';
            shrtMessage.message = message;
            shrtMessage.recipient = phoneNumber;
            System.debug('receipent -->> '+phoneNumber);
            messageList.add(shrtMessage);
            }
        }
        }
        if(messageList.size() > 0) {
            SMS_API_Utility.SendSMSOneToMany('RTR Change of Route-Multiple Days', messageList);
        }
        
        
    }
    
    global void finish(Database.BatchableContext context) {
        
    }

}