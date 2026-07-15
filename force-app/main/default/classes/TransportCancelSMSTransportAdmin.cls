public class TransportCancelSMSTransportAdmin{
 @InvocableMethod(label='Transport cancel SMS Notifications to admin' description='Transport cancel Send notifications via SMS to admin')
    public static void rtrSMSNotificationStudent(List<String> recordIds) {
        if(recordIds != null && !recordIds.isEmpty()) { 
            makeCalloutAsync(recordIds);  
        } else {
            System.debug('RecordIds List is Empty');
        }
    }
    
    @Future(callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
        system.debug('Hello'+recordIds);
        List<RTR_Reva_Transport_Request__c> TrRegList = [
            SELECT Id, RTR_Student__r.Name, RecordType.Name, RTR_Student__r.MobilePhone,RTR_Student__r.Employee_Number__c		
            FROM RTR_Reva_Transport_Request__c  
            WHERE Id IN :recordIds
            LIMIT 50000
        ];
        
        system.debug('ListName'+TrRegList);
        User us= [select Id, Name, MobilePhone  from User where Name ='lakshmanan g' limit 1];
        if(!TrRegList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            
            for(RTR_Reva_Transport_Request__c trReg : TrRegList) {
                String stuName = trReg.RTR_Student__r.Name;
                System.debug('stuName'+stuName);
                String transportAdmin = us.Name;
                String empCode = trReg.RTR_Student__r.Employee_Number__c;
                String phoneNumber =  us.MobilePhone;
                system.debug('phoneNumber'+phoneNumber);                
				String message = 'Dear ' + transportAdmin +', '+stuName+ ' has requested to cancel the transport registration. Please Approve it. Employee Code:'+ empCode + ' Regards, REVA University.';
                SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                shrtMessage.dltContentId = '1007629949208172280';
                shrtMessage.message = message;
                System.debug('message');
                shrtMessage.recipient = phoneNumber;
                messageList.add(shrtMessage);
                System.debug('messageList'+messageList);
            }
            
            if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('transport_cancel_req_tr_admin', messageList);
            }
        }
    } 
}