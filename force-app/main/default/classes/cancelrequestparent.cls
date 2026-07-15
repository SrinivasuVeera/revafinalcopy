global class cancelrequestparent {

    @InvocableMethod(label='Transport cancel request SMS Notifications to parent' description='Transport cancel Send notifications via SMS to HR')
    public static void rtrSMSNotificationStudent(List<String> recordIds) {
        System.debug('Received IDs: ' + recordIds);
        makeCalloutAsync(recordIds);  
    }

    @Future(callout=true)
      public static void makeCalloutAsync(list<ID> recordIds){
          Transport_Registeration__c treg = [SELECT Id,Name,Registration_Status__c, Contact__c,contact__r.SRN_Number__c,
                                                        contact__r.Student_Full_Name__c,contact__r.MobilePhone,Contact__r.Father__r.Student_Full_Name__c,
                                                        contact__r.RH_Parent_Phone_Number__c
                   from Transport_Registeration__c where Id IN :recordIds limit 1];
       
        
            string srnno=treg.Contact__r.SRN_Number__c;
             String requestId = treg.Name;
          RTR_Reva_Transport_Request__c treq = [
            SELECT Id, Cancellation_Date__c,SRN_EmployeeID__c
                  FROM RTR_Reva_Transport_Request__c
            WHERE SRN_EmployeeID__c =:srnno and RecordTypeName__c='Transport Cancellation' limit 1];
            
            
            Datetime dt = treq.Cancellation_Date__c;
            Date onlyDate = dt.date();
          // Convert Date to Datetime to apply custom formatting
Datetime formattedDatetime = Datetime.newInstance(onlyDate.year(), onlyDate.month(), onlyDate.day());
String schDate = formattedDatetime.format('dd/MM/yyyy');  
            String srnnumber = srnno;
                system.debug('srn:'+srnnumber);
           // String scheduleDate = schDate.format();
               // system.debug('dateformat:'+scheduleDate);
                
            String stuname = treg.contact__r.Student_Full_Name__c;
            String phonenumber =  treg.contact__r.MobilePhone;
            string parent=treg.Contact__r.Father__r.Student_Full_Name__c;
          system.debug('\n'+parent+'\n');
          string parentnumber=treg.contact__r.RH_Parent_Phone_Number__c;

            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            SMS_Types__mdt sms1 = [
                SELECT Dlt_Content_Id__c, DeveloperName, Unicode__c, SMS_Name__c, Sender__c, SMS_Template_long__c
                FROM SMS_Types__mdt
                WHERE Dlt_Content_Id__c='1007437586552594866' ];
        system.debug('smstype:'+sms1);
                          
                             SMS_API_Utility.shortMessageWrp shrtMessage1 = new SMS_API_Utility.shortMessageWrp();
         string messages1= 'Dear ' + parent +
                ',\nYour ward '+stuname+' has requested REVA Transport cancellation.'+

'\nRequest ID:'+requestId+

'\nApplied Date:' +schDate+
                '\nRegards,\nREVA University';
         shrtMessage1.dltContentId = sms1.Dlt_Content_Id__c;
                shrtMessage1.message = messages1;
                System.debug('message');
                shrtMessage1.recipient =parentnumber ;
                messageList.add(shrtMessage1);
            system.debug('short message'+shrtmessage1);
             
        
           System.debug('messageList'+messageList);
       
            SMS_API_Utility.SendSMSOneToMany('cancel request parent', messageList);
        
        
    }
        

    }