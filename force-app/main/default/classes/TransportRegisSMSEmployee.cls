public class TransportRegisSMSEmployee{
  @InvocableMethod(label='Transport Registration SMS Notifications to Employee' description='Transport Registration Send notifications via SMS')
    public static void rtrSMSNotificationStudent(List<String> recordIds) {
        if(recordIds != null && !recordIds.isEmpty()) { 
            makeCalloutAsync(recordIds);  
        } else {
            System.debug('RecordIds List is Empty');
        }
    }
    
    @Future(callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
        List<Transport_Registeration__c> TrRegList = [Select id, Contact__r.id, Route_Master__r.Name, Route_Pick_Up_Point__r.Name, Contact__r.Name, 
                                                      Contact__r.Application_Number__c, Contact__r.MobilePhone From Transport_Registeration__c 
                                                      Where Id IN:recordIds LIMIT 50000];
        
        if(!TrRegList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            
            for(Transport_Registeration__c trReg : TrRegList) {
                String stuName = trReg.Contact__r.Name;
                System.debug('stuName'+stuName);
                String phoneNumber = trReg.Contact__r.MobilePhone;
				String message = 'Dear ' + stuName +', ' +'Your transport registration is successful. Enjoy your ride! Regards, REVA University';
                SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                shrtMessage.dltContentId = '1007906716831310000';
                shrtMessage.message = message;
                System.debug('message');
                shrtMessage.recipient = phoneNumber;
                messageList.add(shrtMessage);
                System.debug('messageList'+messageList);
            }
            
            if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('transport_regis_employee', messageList);
            }
        }
    }  
}