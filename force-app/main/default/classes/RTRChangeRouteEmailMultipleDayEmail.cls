global class RTRChangeRouteEmailMultipleDayEmail implements Database.Batchable<sObject>, Database.AllowsCallouts{
    	 
public List<String> recordIds;
    
    global RTRChangeRouteEmailMultipleDayEmail(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id,contact__r.Name,contact__r.email, Route_Master__r.Name, Contact__r.MobilePhone,Route_Pick_Up_Point__r.Name, Registration_Status__c, Reva_Transport__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE (Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true)');               
    }
    global void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        RTR_Reva_Transport_Request__c routeChangeRequestviaMultiple = [select id, RTR_Descriptions__c, RTR_Start_Date__c,  RTR_End_Date__c, Via__r.Name, RTR_Routes__r.Name,RTR_Pick_Up_Point__r.Name
                                                          from RTR_Reva_Transport_Request__c where id IN: recordIds];
        
        System.debug('routeChangeRequestviaMultiple-->> '+routeChangeRequestviaMultiple);
                
      List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        
        
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
            
            String Body = 'Dear ' + stuName +','+ ' \n\nHope this email finds you well.This is to inform you that the route number '
                + routeNumber + '  bus will go to '+ pickupPoint  + ' via '+ viapickupPoint + ' from ' + strtDate + ' to ' +  endDate + '. '+'\n\nBest Regards,' + '\nTransport Department' +'\nREVA University';
            
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setSubject('Change of Route');
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