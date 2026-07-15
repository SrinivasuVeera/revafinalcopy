public class RouteChangeSMSEmployee {
  @InvocableMethod(label='Route Change SMS Notifications to Employee' description='Route Change Send notifications via SMS')
    public static void rtrSMSNotificationStudent(List<String> recordIds) {
        if (recordIds != null && !recordIds.isEmpty()) { 
            makeCalloutAsync(recordIds);  
        } else {
            System.debug('RecordIds List is Empty');
        }
    }
    
    @Future(callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
        // Query to fetch the transport requests
        List<RTR_Reva_Transport_Request__c> TrRegList = [
            SELECT Id, RTR_Student__r.Name, RecordType.Name, RTR_Student__r.MobilePhone	,RTRStudent_Faculty_NonFaculty__r.Name, RTRStudent_Faculty_NonFaculty__r.MobilePhone	
            FROM RTR_Reva_Transport_Request__c  
            WHERE Id IN :recordIds
            LIMIT 50000
        ];
        
        System.debug('ListName: ' + TrRegList);

        if (!TrRegList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            
            // Iterate over the list of transport requests
            for (RTR_Reva_Transport_Request__c trReg : TrRegList) {
                String stuName = trReg.RTRStudent_Faculty_NonFaculty__r.Name;
                System.debug('Student Name: ' + stuName);

                String phoneNumber = trReg.RTRStudent_Faculty_NonFaculty__r.MobilePhone;
                
                String message = 'Dear ' + stuName + ', Your route change request is approved. Regards REVA University.';
                
                SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                shrtMessage.dltContentId = '1007998745206140000';
                shrtMessage.message = message;
                shrtMessage.recipient = phoneNumber;
                
                messageList.add(shrtMessage);
                System.debug('Message List: ' + messageList);
            }
            
            // Send the SMS if there are messages to be sent
            if (!messageList.isEmpty()) {
                SMS_API_Utility.SendSMSOneToMany('transport_route_change_employee', messageList);
            }
        }
    }  
}