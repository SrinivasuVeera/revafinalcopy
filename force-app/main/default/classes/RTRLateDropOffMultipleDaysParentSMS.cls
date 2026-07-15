global class RTRLateDropOffMultipleDaysParentSMS implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public List<String> recordIds;
    
    public RTRLateDropOffMultipleDaysParentSMS(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id, contact__r.Father__r.name, Contact__r.RH_Parent_Phone_Number__c, Route_Master__r.Name, Contact__r.MobilePhone,Route_Pick_Up_Point__r.Name, Contact__r.Name,Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    public void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c lateDropMultipleRequest = [select id,RTR_Number_of_Minutes__c, RTR_Start_Date__c, RTR_End_Date__c, RTR_Descriptions__c
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('latePickRequest-->> '+lateDropMultipleRequest);
        
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        
        for(Transport_Registeration__c trReg : scope) {
            
            String phoneNumber = trReg.Contact__r.RH_Parent_Phone_Number__c;
			String parentname = trReg.contact__r.Father__r.name;            
            Date startDate = lateDropMultipleRequest.RTR_Start_Date__c;            
            Datetime rtrDateTime = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
            String schStartDate = rtrDateTime.format('dd.MM.yyyy');            
            System.debug('Formatted Schedule Date: ' + schStartDate); 
            
            Date endDate = lateDropMultipleRequest.RTR_End_Date__c;            
            Datetime rtrendDateTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day());
            String schEndDate = rtrendDateTime.format('dd.MM.yyyy');            
            System.debug('Formatted Schedule Date: ' + schEndDate);
            
            String lateTime = String.valueof(lateDropMultipleRequest.RTR_Number_of_Minutes__c);
            String reason = lateDropMultipleRequest.RTR_Descriptions__c;
            
            String message = 'Dear Mr./Ms. '+ parentname +',' +' We’d like to inform you that there is slight change in the regular schedule for the University bus drop-off from  ' + 
                schStartDate  + ' to '+ schEndDate + ' due to '+ reason + ' for your ward. The bus will leave the campus ' + lateTime +' minutes later than the regular schedule. REVA University';
            
            SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
            if(phoneNumber!=null && message!=null){
            shrtMessage.dltContentId = '1007563749464375462';
            shrtMessage.message = message;
            shrtMessage.recipient = phoneNumber;
            System.debug('receipent -->> '+phoneNumber);
            messageList.add(shrtMessage);
            }
        }
        
        if(messageList.size() > 0) {
            SMS_API_Utility.SendSMSOneToMany('RTR Late Drop-Off Multiple Days', messageList);
        }
        
        
    }
    
    public void finish(Database.BatchableContext context) {
        
    }
}