global class RTRLateDropParentEmailMultipleDays implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public List<String> recordIds;
    
    public RTRLateDropParentEmailMultipleDays(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id, contact__r.email, Contact__r.Father__r.Email, Contact__r.Mother__r.Email, Contact__r.Guardian__r.Email,'+
                                        'Route_Master__r.Name, Contact__r.MobilePhone,Route_Pick_Up_Point__r.Name, Registration_Status__c, Reva_Transport__r.Name, Contact__r.Father__r.name,  Contact__r.Mother__r.name, Contact__r.Guardian__r.name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    public void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c lateDropMultipleRequest = [select id,RTR_Number_of_Minutes__c, RTR_Start_Date__c, RTR_End_Date__c, RTR_Descriptions__c
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('lateDropMultipleRequest-->> '+lateDropMultipleRequest);
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        for(Transport_Registeration__c trReg : scope) {
                                 
			String parName;            
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
            
             if(trReg.Contact__r.Father__r.Email!=null){
                parName= trReg.contact__r.Father__r.name; 
                System.debug('parName-->> '+parName);
            }
            else if(trReg.Contact__r.Mother__r.Email!=null && trReg.Contact__r.Father__r.Email == null){
                parName = trReg.contact__r.Mother__r.name;
                 System.debug('parName-->> '+parName);
            }
            else if(trReg.Contact__r.Mother__r.Email == null && trReg.Contact__r.Father__r.Email ==null && trReg.Contact__r.Guardian__r.Email!=null ){
                 parName = trReg.contact__r.Guardian__r.name; 
                 System.debug('parName-->> '+parName);
            }
            
            String Body = 'Dear Mr./Ms. ' + parName + ','+ '\n\nHope this email finds you well. We’d like to inform you that the University bus will leave the campus '+ lateTime + 'mins earlier than the regular schedule from '+ schStartDate +'to '+ schEndDate +'due to  '+ reason +'.'+
               '\n\nWe regret the inconvenience this may cause and appreciate your understanding.' + '\n\nBest Regards,' + '\nTransport Department' + '\nREVA University';  
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setSubject('Late Drop-Off');
             mail.setplaintextbody(Body);
            
             if(trReg.Contact__r.Father__r.Email!=null){                            
             mail.setToAddresses(new List<String>{trReg.Contact__r.Father__r.Email});
             emailList.add(mail); 
                
            } else if(trReg.Contact__r.Mother__r.Email!=null && trReg.Contact__r.Father__r.Email == null){
               
             mail.setToAddresses(new List<String>{trReg.Contact__r.Mother__r.Email});
             emailList.add(mail);  
                
            }
            else if(trReg.Contact__r.Mother__r.Email == null && trReg.Contact__r.Father__r.Email ==null && trReg.Contact__r.Guardian__r.Email!=null ){
             mail.setToAddresses(new List<String>{trReg.Contact__r.Guardian__r.Email});
             emailList.add(mail);   
            } 
            
            }
    

        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
     
    }
}
    public void finish(Database.BatchableContext context) {
        
    }

}