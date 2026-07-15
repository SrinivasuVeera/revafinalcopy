public class RTRParentSMS {
    @InvocableMethod(label='RTR Send SMS Notifications to Parent' description='RTR Send notifications via SMS')
    public static void rtrSMSNotificationParent(List<String> recordIds) {
        if(recordIds != null && !recordIds.isEmpty()) { 
            makeCalloutAsync(recordIds);  
        } else {
            System.debug('RecordIds List is Empty');
        }
    }
    
    @Future(callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
        List<Transport_Registeration__c> TrRegList = [Select id, Contact__r.id, Contact__r.name, Route_Master__r.Name, Route_Pick_Up_Point__r.Name, contact__r.Father__r.name,
                                                      Contact__r.Application_Number__c, Contact__r.RH_Parent_Phone_Number__c From Transport_Registeration__c 
                                                      Where Id IN:recordIds AND Registration_Type__c='Student' ORDER BY CreatedDate DESC LIMIT 50000];
        System.debug('TrRegList-->> '+TrRegList);
        
        if(!TrRegList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            
            for(Transport_Registeration__c trReg : TrRegList) {
                if(trReg.Contact__r.RH_Parent_Phone_Number__c!=null){
                String parentName =trReg.contact__r.Father__r.name; 
                String studName =  trReg.Contact__r.name;   
                //String appNumber = trReg.Contact__r.Application_Number__c;
                String routeNumber = trReg.Route_Master__r.Name;
                //String pickPoint = trReg.Route_Pick_Up_Point__r.Name;
                String phoneNumber = trReg.Contact__r.RH_Parent_Phone_Number__c;
                
                String message = 'Dear Mr./Ms. ' + parentName  + ' We are pleased to inform you that the transport registration for your ward '+ studName + ' has been successfully processed and approved for the REVA Transport for route number: '+ routeNumber +'. ' + ' REVA University';
                    
                SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                shrtMessage.dltContentId = '1007142518095817180';
                shrtMessage.message = message;
                shrtMessage.recipient = phoneNumber;
                messageList.add(shrtMessage);
            }
                else{
                    System.debug('Parent Number is not found');
                }
            }
            
            if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('RTR Confirmation Registration Parent', messageList);
            }
        }
    }  
}