public class transportadminrejectparent {
    @InvocableMethod(label='Transport admin reject cancel SMS Notifications to parent' description='Transport cancel Send notifications via SMS to HR')
    public static void rtrSMSNotificationStudent(List<String> recordIds) {
     
            makeCalloutAsync(recordIds);  
       
    }

    @Future(callout=true)
   public static void makeCalloutAsync(list<ID> recordIds){
          list<Transport_Registeration__c> treg = [SELECT Id,Name,Registration_Status__c, Contact__c,contact__r.SRN_Number__c,
                                                        contact__r.Student_Full_Name__c,contact__r.MobilePhone,Contact__r.Father__r.Student_Full_Name__c,
                                                        contact__r.RH_Parent_Phone_Number__c
                   from Transport_Registeration__c where Id IN :recordIds ];
       
        
            string srnno=treg[0].Contact__r.SRN_Number__c;
             String requestId = treg[0].Name;
          list<RTR_Reva_Transport_Request__c> treq = [
            SELECT Id, Cancellation_Date__c,SRN_EmployeeID__c
                  FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c =:srnno and RecordTypeName__c='Transport Cancellation' ];
            
            
            Datetime dt = treq[0].Cancellation_Date__c;
            Date onlyDate = dt.date();
          // Convert Date to Datetime to apply custom formatting
Datetime formattedDatetime = Datetime.newInstance(onlyDate.year(), onlyDate.month(), onlyDate.day());
String schDate = formattedDatetime.format('dd/MM/yyyy');  
            String srnnumber = srnno;
                system.debug('srn:'+srnnumber);
           // String scheduleDate = schDate.format();
               // system.debug('dateformat:'+scheduleDate);
                
            String stuname = treg[0].contact__r.Student_Full_Name__c;
            String phonenumber =  treg[0].contact__r.MobilePhone;
            string parent=treg[0].Contact__r.Father__r.Student_Full_Name__c;
          system.debug('\n'+parent+'\n');
          string parentnumber=treg[0].contact__r.RH_Parent_Phone_Number__c;

            List<SMS_API_Utility.shortMessageWrp> messageList1 = new List<SMS_API_Utility.shortMessageWrp>();
            SMS_Types__mdt sms2 = [
                SELECT Dlt_Content_Id__c, DeveloperName, Unicode__c, SMS_Name__c, Sender__c, SMS_Template_long__c
                FROM SMS_Types__mdt
                WHERE Dlt_Content_Id__c='1007470846995871900' ];
        system.debug('smstype:'+sms2);
                          
                             SMS_API_Utility.shortMessageWrp shrtMessage1 = new SMS_API_Utility.shortMessageWrp();
         string messages1= 'Dear '+parent+
                ',\nYour ward’s transport cancellation request (Request Id: - '+requestId+')is rejected.' +
                '\nRegards\nREVA University';
         shrtMessage1.dltContentId = sms2.Dlt_Content_Id__c;
                shrtMessage1.message = messages1;
                System.debug('message');
                shrtMessage1.recipient =parentnumber ;
                messageList1.add(shrtMessage1);
            system.debug('short message'+shrtmessage1);
             
        
           System.debug('messageList'+messageList1);
       
            SMS_API_Utility.SendSMSOneToMany('Rejection from transport admin parent', messageList1);
        
        
    }
        

    }