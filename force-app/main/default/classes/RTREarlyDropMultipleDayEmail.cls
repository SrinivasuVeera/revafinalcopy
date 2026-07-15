global class RTREarlyDropMultipleDayEmail implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public List<String> recordIds;
    
    public RTREarlyDropMultipleDayEmail(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id, Route_Master__r.Name, contact__r.email, Contact__r.MobilePhone,Route_Pick_Up_Point__r.Name, Contact__r.Name,Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    public void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c lateDropMultipleRequest = [select id,RTR_Number_of_Minutes__c, RTR_Start_Date__c, RTR_End_Date__c, RTR_Descriptions__c
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('lateDropMultipleRequest-->> '+lateDropMultipleRequest);
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        for(Transport_Registeration__c trReg : scope) {
                                 
			String name = trReg.Contact__r.name;            
            Date startDate = lateDropMultipleRequest.RTR_Start_Date__c;            
            Datetime rtrDateTime = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
            String schStartDate = rtrDateTime.format('dd.MM.yyyy');            
            System.debug('Formatted Schedule Date: ' + schStartDate); 
            
            Date endDate = lateDropMultipleRequest.RTR_End_Date__c;            
            Datetime rtrendDateTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day());
            String schEndDate = rtrendDateTime.format('dd.MM.yyyy');            
            System.debug('Formatted Schedule Date: ' + schEndDate);
            
            String EarlyTime = String.valueof(lateDropMultipleRequest.RTR_Number_of_Minutes__c);
            String reason = lateDropMultipleRequest.RTR_Descriptions__c;
            
            String Body = 'Dear ' + name + ','+ '\n\nHope this email finds you well. We’d like to inform you that the University bus will leave the campus '+ EarlyTime + 'mins earlier than the regular schedule from '+ schStartDate +'to '+ schEndDate +'due to  '+ reason +'.'+
               '\n\nBest Regards,' + '\nTransport Department' + '\nREVA University';  
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setSubject('Early Drop-Off');
             mail.setplaintextbody(Body);
             mail.setToAddresses(new List<String>{trReg.contact__r.email});
             emailList.add(mail); 
            
            }
    

        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
     
    }
}
    public void finish(Database.BatchableContext context) {
        
    }

}