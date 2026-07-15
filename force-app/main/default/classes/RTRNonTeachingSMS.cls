public class RTRNonTeachingSMS {
	@InvocableMethod(label='RTR Send SMS Notifications to Non Teaching Staff' description='RTR Send notifications via SMS')
    public static void rtrSMSNotificationNonTeaching(List<String> recordIds) {
        if(recordIds != null && !recordIds.isEmpty()) { 
            makeCalloutAsync(recordIds);  
        } else {
            System.debug('RecordIds List is Empty');
        }
    }
    
    @Future(callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
        List<Transport_Registeration__c> TrRegList = [Select id, Contact__r.id, Route_Master__r.Name, Route_Pick_Up_Point__r.Name, 
                                                     Contact__r.MobilePhone,Contact__r.name From Transport_Registeration__c 
                                                     Where Id IN:recordIds AND Registration_Type__c='Non Teaching' ORDER BY CreatedDate DESC LIMIT 50000];
        System.debug('TrRegList-->> '+TrRegList);
        
        if(!TrRegList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            
            for(Transport_Registeration__c trReg : TrRegList) {
                if(trReg.Contact__r.MobilePhone!=null){
 					String facName = trReg.Contact__r.name;
                    String routeNumber = trReg.Route_Master__r.Name;
                    String pickPoint = trReg.Route_Pick_Up_Point__r.Name;
                    String phoneNumber = trReg.Contact__r.MobilePhone;
                    
                    String message = 'Dear '+ facName + '\nYour Registration for REVA Transport has been approved.\nDetails:\nRoute No: ' + routeNumber + '\nPickup Point: ' + pickPoint + '\nREVA University';
                    
                    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                    shrtMessage.dltContentId = '1007533344562060112';
                    shrtMessage.message = message;
                    shrtMessage.recipient = phoneNumber;
                    messageList.add(shrtMessage);
                }
                else{
                    System.debug('Parent Number is not found');
                }
            }
            
            if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('RTR Confirmation Registration Faculty', messageList);
            }
        }
    }  
}