public class TransportRegisSMSTransportAdmin{
 @InvocableMethod(label='Transport Registration SMS Notifications to admin' description='Transport Registration Send notifications via SMS to admin')
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
        List<Transport_Registeration__c> TrRegList = [Select id, Contact__r.id, Route_Master__r.Name, Route_Pick_Up_Point__r.Name, Contact__r.Name, 
                                                      Contact__r.Application_Number__c, Contact__r.MobilePhone, Contact__r.Employee_Number__c
                                                      From Transport_Registeration__c
                                                      Where Id IN:recordIds LIMIT 50000];
        
        system.debug('ListName'+TrRegList);
        User us= [select Id, Name, MobilePhone  from User where Name ='lakshmanan g' limit 1];
        if(!TrRegList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            
            for(Transport_Registeration__c trReg : TrRegList) {
                String stuName = trReg.Contact__r.Name;
                System.debug('stuName'+stuName);
                String transportAdmin = us.Name;
                String empCode = trReg.Contact__r.Employee_Number__c;
                String phoneNumber =  us.MobilePhone;
                system.debug('phoneNumber'+phoneNumber);                
				String message = 'Dear ' + transportAdmin +', '+stuName+ ' is registered for the transportation. Employee Code: '+ empCode + ' Regards, REVA University.';
                SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                shrtMessage.dltContentId = '1007498698870912017';
                shrtMessage.message = message;
                System.debug('message');
                shrtMessage.recipient = phoneNumber;
                messageList.add(shrtMessage);
                System.debug('messageList'+messageList);
            }
            
            if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('transport_regis_employe_tr_admin', messageList);
            }
        }
    } 
}