global class RTREarlyDropSingleDayEmail implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public List<String> recordIds;
    
    public RTREarlyDropSingleDayEmail(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id, Route_Master__r.Name,contact__r.email,Contact__r.MobilePhone,Route_Pick_Up_Point__r.Name, Contact__r.Name,Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    public void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
       RTR_Reva_Transport_Request__c lateDropRequest = [select id,RTR_Number_of_Minutes__c, RTR_Date__c, RTR_Descriptions__c 
                                                         from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('lateDropRequest-->> '+lateDropRequest);
        
     List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        for(Transport_Registeration__c trReg : scope) {
            
            String stuName = trReg.Contact__r.name;
            Date schDate = lateDropRequest.RTR_Date__c;
            Datetime rtrDateTime = Datetime.newInstance(schDate.year(), schDate.month(), schDate.day());
            String scheduleDate = rtrDateTime.format('dd.MM.yyyy');
            System.debug('Formatted Schedule Date: ' + scheduleDate);              
            String EarlyTime = String.valueof(lateDropRequest.RTR_Number_of_Minutes__c);
            String reason = lateDropRequest.RTR_Descriptions__c;
            
 			String Body = 'Dear ' + stuName + ','+ '\n\nHope this email finds you well. We’d like to inform you that the University bus will leave the campus '+ EarlyTime + ' mins earlier than the regular schedule on '+ scheduleDate +'due to '+ reason +'.'+
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