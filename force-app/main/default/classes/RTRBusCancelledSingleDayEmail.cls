global class RTRBusCancelledSingleDayEmail implements Database.Batchable<sObject>, Database.AllowsCallouts{
    	 
public List<String> recordIds;
    
    global RTRBusCancelledSingleDayEmail(List<String> recordIds) {
        this.recordIds = recordIds;
    }
         
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id,contact__r.Name, contact__r.email, Route_Master__r.Name, Contact__r.MobilePhone,Route_Pick_Up_Point__r.Name, Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    global void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c cancelledRequest = [select id, RTR_Descriptions__c, RTR_Date__c
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('cancelledRequest-->> '+cancelledRequest);
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                       
        for(Transport_Registeration__c trReg : scope) {
           
            String stuName = trReg.contact__r.Name;
            String phoneNumber = trReg.Contact__r.MobilePhone;
            Date schDate = cancelledRequest.RTR_Date__c;            
            Datetime rtrDateTime = Datetime.newInstance(schDate.year(), schDate.month(), schDate.day());
            String scheduleDate = rtrDateTime.format('dd.MM.yyyy');                       
            System.debug('Formatted Schedule Date: ' + scheduleDate);
                        
            String reason = cancelledRequest.RTR_Descriptions__c;
            String Body = 'Dear ' + stuName + ','+ '\n\nHope this email finds you well. This is to inform you that due to '+ reason + ', '+ 'the University bus service is not operational on '+ scheduleDate +'.'+
               '\n\nWe regret the inconvenience this may cause and appreciate your understanding.' + '\n\nBest Regards,' + '\nTransport Department' + '\nREVA University';  
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setSubject('Bus Cancelled');
             mail.setplaintextbody(Body);
             mail.setToAddresses(new List<String>{trReg.contact__r.email});
             emailList.add(mail);                       
        }
        
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }	     
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}