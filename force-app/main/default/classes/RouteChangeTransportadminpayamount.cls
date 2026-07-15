public class RouteChangeTransportadminpayamount {
@InvocableMethod(label='Transport admin approval Route Change SMS Notifications to finance' description='Transport cancel Send notifications via SMS to HR')
    public static void rtrSMSNotificationStudent(List<String> recordIds) {
     
            makeCalloutAsync(recordIds);  
       
    }

    @Future(callout=true)
    public static void makeCalloutAsync(list<ID> recordIds){
           list<Transport_Registeration__c> treg = [SELECT Id,Name,Registration_Status__c, Contact__c,contact__r.SRN_Number__c,
                                                        contact__r.Student_Full_Name__c,contact__r.MobilePhone,contact__r.Parent_Full_Name__c,
                                                        contact__r.RH_Parent_Phone_Number__c
                   from Transport_Registeration__c where Id IN :recordIds ];
       
        
            string srnno=treg[0].Contact__r.SRN_Number__c;
             String requestId = treg[0].Name;
          list<RTR_Reva_Transport_Request__c> treq = [
            SELECT Id, Cancellation_Date__c,SRN_EmployeeID__c,RouteChangeAmountToPay__c
                  FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c =:srnno and RecordTypeName__c='Route Change Request' ];
            
            //system.debug('request:'+reqList);
           
                decimal extraAmountPay = treq[0].RouteChangeAmountToPay__c;
             //Datetime dt = treq[0].Cancellation_Date__c;
            //Date onlyDate = dt.date();
          // Convert Date to Datetime to apply custom formatting
//Datetime formattedDatetime = Datetime.newInstance(onlyDate.year(), onlyDate.month(), onlyDate.day());
//String schDate = formattedDatetime.format('dd/MM/yyyy');  
            String srnnumber = srnno;
                system.debug('srn:'+srnnumber);
           // String scheduleDate = schDate.format();
               // system.debug('dateformat:'+scheduleDate);
                
            String stuname = treg[0].contact__r.Student_Full_Name__c;
            String phonenumber =  treg[0].contact__r.MobilePhone;
          string parent=treg[0].contact__r.Parent_Full_Name__c;
          string parentnumber=treg[0].contact__r.RH_Parent_Phone_Number__c;
         
                User us =[select Id, Name, MobilePhone, Profile.Name from User where Name ='Bharathi S' limit 1];
        string transno=us.MobilePhone;
        string transname=us.Name;
       
                

            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            SMS_Types__mdt sms = [
                SELECT Dlt_Content_Id__c, DeveloperName, Unicode__c, SMS_Name__c, Sender__c, SMS_Template_long__c
                FROM SMS_Types__mdt
                WHERE Dlt_Content_Id__c='1007053527011667174' ];
        system.debug('smstype:'+sms);
        
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                            
         string messages='Dear,'+stuname+

'\nIn order to complete the route-changing process, please pay '+extraAmountPay+ ' rupees through the student portal.'+'\nRegards,\nREVA University';
         shrtMessage.dltContentId = sms.Dlt_Content_Id__c;
                shrtMessage.message = messages;
                System.debug('message');
                shrtMessage.recipient = phonenumber;
                messageList.add(shrtMessage);
            system.debug('short message'+shrtmessage);
             
        
           System.debug('messageList'+messageList);
       
            SMS_API_Utility.SendSMSOneToMany('Payment information from the finance in', messageList);
    }
}