global class RTRRouteNumberChangeEmailMultipleDays implements Database.Batchable<sObject>, Database.AllowsCallouts{
    	 
public List<String> recordIds;
    
    global RTRRouteNumberChangeEmailMultipleDays(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id,contact__r.Name,contact__r.email, Route_Master__r.Name, Contact__r.MobilePhone,Route_Pick_Up_Point__r.Name, Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    global void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c routeChangeRequest = [select id, RTR_Descriptions__c,RTR_Start_Date__c,RTR_End_Date__c,RTR_Routes__r.Name,RTR_New_Number__r.Name
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('routeChangeRequest-->> '+routeChangeRequest);
        
       List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        
        for(Transport_Registeration__c trReg : scope) {
            if(trReg.Route_Master__r.Name == routeChangeRequest.RTR_Routes__r.Name){
            String stuName = trReg.contact__r.Name;
            Date schDate = routeChangeRequest.RTR_Start_Date__c;            
            Datetime rtrDateTime = Datetime.newInstance(schDate.year(), schDate.month(), schDate.day());
            String scheduleDate = rtrDateTime.format('dd/MM/yyyy');            
            System.debug('Formatted Schedule Date: ' + scheduleDate); 
            
            Date schEndDate = routeChangeRequest.RTR_End_Date__c;            
            Datetime rtrEndDateTime = Datetime.newInstance(schEndDate.year(), schEndDate.month(), schEndDate.day());
            String scheduleEndDate = rtrEndDateTime.format('dd/MM/yyyy');            
            System.debug('Formatted Schedule EndDate: ' + scheduleEndDate); 
                                    
            String reason = routeChangeRequest.RTR_Descriptions__c;            
            String newRouteNumber = routeChangeRequest.RTR_New_Number__r.Name;
            String routeNumber = routeChangeRequest.RTR_Routes__r.Name;
            
            String Body = 'Dear ' + stuName +','+ '\n\nHope this email finds you well.This is to inform you that the route number '
                + routeNumber + ' bus is cancelled from '+ scheduleDate  + ' to '+ scheduleEndDate +'. ' + 'You can take route number '+ newRouteNumber +' instead. '+'\n\nBest Regards,' + '\nTransport Department' +'\nREVA University';
                
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setSubject('Change of Route Number');
             mail.setplaintextbody(Body);
             mail.setToAddresses(new List<String>{trReg.contact__r.email});
             emailList.add(mail);  
            
            }
        }
        
		if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }	     	
       
    }
    
    global void finish(Database.BatchableContext context) {
        
    }

}