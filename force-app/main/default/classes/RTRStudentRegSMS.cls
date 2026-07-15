public class RTRStudentRegSMS {
    @InvocableMethod(label='RTR Send SMS Notifications to Student' description='RTR Send notifications via SMS')
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
                                                      Where Id IN:recordIds AND Registration_Type__c='Student' LIMIT 50000];
        
        if(!TrRegList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            
            for(Transport_Registeration__c trReg : TrRegList) {
                String stuName = trReg.Contact__r.Name;
                String appNumber = trReg.Contact__r.Application_Number__c;
                String routeNumber = trReg.Route_Master__r.Name;
                String pickPoint = trReg.Route_Pick_Up_Point__r.Name;
                String phoneNumber = trReg.Contact__r.MobilePhone;
                
				String message = 'Dear ' + stuName +', ' +'We are pleased to inform you that your transport registration for REVA transport has been successfully processed and approved for Route Number: '+ routeNumber + ' REVA University';
                
                SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                shrtMessage.dltContentId = '1007662471495875508';
                shrtMessage.message = message;
                shrtMessage.recipient = phoneNumber;
                messageList.add(shrtMessage);
            }
            
            if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('RTRStudent Registration Confirmation', messageList);
            }
        }
    }  
}