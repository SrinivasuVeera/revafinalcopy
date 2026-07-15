public class RouteChangeSMSHR {
 @InvocableMethod(label='Route change SMS Notifications to HR' description='Route Change Send notifications via SMS to HR')
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
            SELECT Id, RTRStudent_Faculty_NonFaculty__r.Name, RecordType.Name, RTRStudent_Faculty_NonFaculty__r.MobilePhone,RTRStudent_Faculty_NonFaculty__r.Employee_Number__c		
            FROM RTR_Reva_Transport_Request__c  
            WHERE Id IN :recordIds
            LIMIT 50000
        ];
        
        system.debug('ListName'+TrRegList);
        User us =[select Id, Name, MobilePhone, Profile_Name__c  from User where Name ='K Latha Raju'];
        if(!TrRegList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            
            for(RTR_Reva_Transport_Request__c trReg : TrRegList) {
                String stuName = trReg.RTRStudent_Faculty_NonFaculty__r.Name;
                System.debug('stuName'+stuName);
                String transportAdmin = us.Name;
                String empCode = trReg.RTRStudent_Faculty_NonFaculty__r	.Employee_Number__c;
                String phoneNumber =  us.MobilePhone;
                system.debug('phoneNumber'+phoneNumber);                
				String message = 'Dear ' + transportAdmin +',  Route change request from  '+stuName+ ' is approved by Transport Admin. Employee Code:'+ empCode + ' Regards, REVA University.';
                SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                shrtMessage.dltContentId = '1007090655356793633';
                shrtMessage.message = message;
                System.debug('message');
                shrtMessage.recipient = phoneNumber;
                messageList.add(shrtMessage);
                System.debug('messageList'+messageList);
            }
            
            if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('transport_route_change_hr', messageList);
            }
        }
    } 
}